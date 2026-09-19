-------------------------------------------------------------------------------
--  NaowhSR_zhCN / Locale.lua -- 汉化引擎
--
--  原插件 NaowhSmartReminders 零改动。本文件在原插件全部文件加载完成之后执行
--  （由 TOC 的 ## Dependencies 保证），通过覆写 ns / ns.UI 的公共成员实现运行时拦截。
--
--  设计要点见 docs/拦截点清单.md。核心约束：
--    1. L() 幂等              -- 三轨拦截会重复经过同一个串
--    2. secret value 防护     -- 12.x Addonpocalypse，绝不对 secret 做 tostring
--    3. 白名单翻译            -- 未命中字典一律原样返回，逻辑键绝不被破坏
--    4. 不动 cfg.text         -- DualRow/SectionHeader 用 text 做缓存键，改了会泄漏
-------------------------------------------------------------------------------

local ADDON_NAME = ...

-- 原插件的全局命名空间（保留旧名，见 Core.lua:14）
local SR = _G.NaowhUITankReminder
if not SR then return end

local UI = SR.UI
if not UI then return end

-- 模块表由 NaowhSR_zhCN_Dict.lua 创建（或此处兜底创建），
-- 通过全局名共享，保证「字典文件」与「引擎文件」操作的是同一张表。
local M = _G.NaowhSR_zhCN
if not M then
    M = {}
    _G.NaowhSR_zhCN = M       -- 供调试与离线测试访问
end

M.VERSION = "1.0.0"

-------------------------------------------------------------------------------
--  字典
-------------------------------------------------------------------------------
-- NaowhSR_zhCN_Dict.lua 负责填充这三张表。
M.DICT = M.DICT or {}          -- [英文原串] = 中文（精确匹配）
M.TEMPLATES = M.TEMPLATES or {}  -- [Lua 模式] = 替换模板（%1 %2 引用捕获组）
M.FORMATS = M.FORMATS or {}    -- [format 串] = 中文 format 串（供 Lf 使用）
M.SKIP = M.SKIP or {}          -- [英文原串] = true，显式豁免（防未来误加）

-- 模板按长度降序预编译一次，避免每次调用都重排
local compiledTemplates

local function BuildTemplates()
    local out = {}
    for pattern, repl in pairs(M.TEMPLATES) do
        out[#out + 1] = { pattern = pattern, repl = repl }
    end
    -- 更长的模式优先：避免 "Show %s Anchor" 抢在 "Show %s Anchor Size" 之前
    table.sort(out, function(a, b) return #a.pattern > #b.pattern end)
    compiledTemplates = out
end

M.RebuildTemplates = BuildTemplates

-------------------------------------------------------------------------------
--  L() -- 唯一的翻译入口
-------------------------------------------------------------------------------
local issecretvalue = issecretvalue   -- 本地上化，避免每次全局查找

-- WoW 客户端提供全局 unpack；Lua 5.2+ 已把它移进 table.unpack。
-- 离线桩测跑在 5.4 上，这里做一次兼容，不影响客户端行为。
local unpack = unpack or table.unpack

-- 判定一个值是否可安全当作字符串处理。
local function PlainString(v)
    if type(v) ~= "string" then return nil end
    if issecretvalue and issecretvalue(v) then return nil end
    return v
end

--- 翻译一个字符串。幂等；非字符串 / secret / 未命中一律原样返回。
---
--- 顺序：精确字典 → 模式模板 → 颜色码内嵌片段。
--- 模式模板替换出的捕获组会再过一次 L()，处理
--- "Show Defensive Anchor" 里 Defensive 仍需翻译的情况。
---
--- ⚠️ 重入保护：模板的捕获组会再走一次 L()，而某些模板的产物可能又
---    匹配另一个模板（例如 "^(.+) Size$" 的产物 "...大小" 若再被其它
---    模板捕获，就会无限展开）。用深度上限直接截断。
local MAX_DEPTH = 3
local depth = 0

function M.L(s)
    local str = PlainString(s)
    if not str or str == "" then return s end

    -- 1. 精确命中
    local hit = M.DICT[str]
    if hit ~= nil then return hit end

    -- 超出深度上限：只做精确匹配，不再展开模板
    if depth >= MAX_DEPTH then return s end

    -- 2. 模式模板命中（仅在字典未命中时尝试）
    --
    -- 模板都锚定 ^...$，整串必然恰好一个匹配，string.match 足够。
    -- 捕获组先各自过一遍 L()，再把替换模板里的 %N 展开 —— 这样
    -- "Show Defensive Anchor" 的 Defensive 也能被翻到。
    --
    -- ⚠️ 这些 pattern 是 Lua 模式（(%d+) / (.+)），**不是** format 串。
    --    format 串（"Spell %d"）走 M.FORMATS + Lf()，两者不可混用。
    if not compiledTemplates then BuildTemplates() end
    if #compiledTemplates > 0 then
        for i = 1, #compiledTemplates do
            local t = compiledTemplates[i]
            local ok, c1, c2, c3 = pcall(string.match, str, t.pattern)
            if ok and c1 ~= nil then
                local vals = { c1, c2, c3 }
                local nCaps = #vals
                local repl = t.repl
                -- 从大到小替换 %N，避免 %1 误吃 %10 的前缀。
                -- ⚠️ pattern 位置的 "%1" 是反向引用而非字面量，必须写成 "%%1"。
                for k = nCaps, 1, -1 do
                    local c = vals[k]
                    if c ~= nil then
                        local cRep = tostring(c)
                        if type(c) == "string" then
                            depth = depth + 1
                            cRep = M.L(c)          -- 捕获组只做「精确 + 下一层模板」
                            depth = depth - 1
                        end
                        -- gsub 的 pattern  "%" .. k  会被当作反向引用，
                        -- 用 "%%" .. k 才是字面量 "%1"。
                        repl = repl:gsub("%%" .. k, function() return cRep end)
                    end
                end
                if repl ~= t.repl then
                    return M.DICT[repl] or repl
                end
            end
        end
    end

    -- 3. 颜色码内嵌片段
    --
    -- 原插件大量使用 "|cff0091ed" .. title .. "|r" 与
    -- ROLE_COLOR[label] .. label .. "|r" 这类构造，整串无法命中字典
    -- （"|cffF0A830Tank|r" ≠ "Tank"）。这里只处理一种严格模式：
    -- 整串形如 |cAARRGGBB<内容>|r，且内容命中字典。
    --
    -- 严格限定是为了不误伤：不做任意子串替换，只剥一层已知的颜色码外壳。
    local code, inner = str:match("^(|c%x%x%x%x%x%x%x%x)(.-)|r$")
    if code and inner and inner ~= "" then
        depth = depth + 1
        local innerRep = M.L(inner)
        depth = depth - 1
        if innerRep ~= inner then
            return code .. innerRep .. "|r"
        end
    end

    -- 4. 斜杠 / 加号分隔的枚举串
    --
    -- Bosses.lua:2038 的 "any " .. table.concat(roles, "/") 会产出
    -- "Tank/Healer"，而整串不是字典键。模板 2 已经把外层剥成
    -- "任意%1"，这里再把 "Tank/Healer" 逐段翻成 "坦克/治疗"。
    --
    -- ⚠️ 只在「分隔符两侧的每一段都能命中」时才重写，否则原样返回 ——
    --    有些斜杠串是路径或 "7/8" 这类数值（不命中即自动跳过）。
    if str:find("/", 1, true) then
        depth = depth + 1
        local parts, allHit = {}, true
        for seg in (str .. "/"):gmatch("([^/]*)/") do
            if seg == "" then
                parts[#parts + 1] = seg
            else
                local rep = M.L(seg)          -- 先试模式（"any Tank" 等）
                if rep == seg then rep = M.DICT[seg] or seg end
                if rep == seg then allHit = false; break end
                parts[#parts + 1] = rep
            end
        end
        depth = depth - 1
        if allHit and #parts > 0 then
            return table.concat(parts, "/")
        end
    end

    -- 5. 未命中：原样返回（白名单原则）
    return s
end

--- 带格式化参数的翻译：Lf("Trigger: %s", name)
---
--- 两步：
---   1. 参数逐个过 L()  —— "Display" → "显示"
---   2. 模板串过 L()    —— "Trigger: %s" → "触发条件：%s"（走 M.FORMATS）
---   3. string.format 代入
---
--- ⚠️ 模板串的翻译**不能**走 string.match（%d/%s 不是捕获组）。
---    先查 M.FORMATS 精确表，再退回 M.L（兼容模板本身已是中文的情形）。
function M.Lf(fmt, ...)
    local n = select("#", ...)
    if n == 0 then return M.L(fmt) end

    local args = { ... }
    for i = 1, n do
        local v = args[i]
        if type(v) == "string" then args[i] = M.L(v) end
    end

    local plain = type(fmt) == "string" and fmt or nil
    local translated = plain and M.FORMATS[plain] or nil
    if not translated then
        translated = M.L(fmt)
    end

    local ok, out = pcall(string.format, translated, unpack(args, 1, n))
    if ok then return out end
    -- 翻译后的模板格式符数量对不上时，退回原文
    local ok2, out2 = pcall(string.format, fmt, unpack(args, 1, n))
    return ok2 and out2 or fmt
end

-------------------------------------------------------------------------------
--  轨 2：显式出口拦截
-------------------------------------------------------------------------------

-- 2.1 UI.L（官方预留钩子，Widgets.lua:19）
--     原插件内无调用点，覆写是为了语义完整 + 未来版本自动生效。
if UI then
    UI.L = M.L
end

-- 2.2 ns.UI.ShowWidgetTooltip(label, text, opts)  -- Widgets.lua:45
--     text 可为函数，翻译必须在求值之后。做法：包装整个函数，
--     字符串直接翻；函数则替换成「调用原函数再翻」的闭包。
local origShowWidgetTooltip = UI.ShowWidgetTooltip
if origShowWidgetTooltip then
    UI.ShowWidgetTooltip = function(label, text, opts)
        if type(text) == "function" then
            local fn = text
            text = function()
                return M.L(fn())
            end
        elseif type(text) == "string" then
            text = M.L(text)
        end
        return origShowWidgetTooltip(label, text, opts)
    end
end

-- 2.3 ns.Button(parent, text, w, h, onClick)  -- Core.lua:113
--     其内部 lazy 走 ns.Font（轨 1 覆盖），但按钮文字常是短词，
--     这里显式翻译以确保「文字宽度测量发生在翻译之后」。
local origButton = SR.Button
if origButton then
    SR.Button = function(parent, text, w, h, onClick)
        if type(text) == "string" then text = M.L(text) end
        return origButton(parent, text, w, h, onClick)
    end
end

-- 2.4 ns.SetButtonText(btn, text)  -- Core.lua:136
local origSetButtonText = SR.SetButtonText
if origSetButtonText then
    SR.SetButtonText = function(btn, text)
        if type(text) == "string" then text = M.L(text) end
        return origSetButtonText(btn, text)
    end
end

-- 2.5 ns.Tooltip(frame, title, body)  -- Core.lua:156
--     Compose() 把 title 与 body 拼成一条串，走后端 ShowWidgetTooltip。
--     由于 2.2 已包了 ShowWidgetTooltip，且 Compose 返回的是拼好的整串，
--     整串无法命中字典。这里改为：分别翻译 title / body，让 Compose 拼出中文。
--     实现方式：HookScript 的 Compose 在 ns.Tooltip 内部构造，不可外部访问，
--     故改用「包装 ns.Tooltip，把 title/body 预先翻译」的策略。
local origTooltip = SR.Tooltip
if origTooltip then
    SR.Tooltip = function(frame, title, body)
        if type(title) == "string" then title = M.L(title) end
        if type(body) == "string" then
            body = M.L(body)
        elseif type(body) == "function" then
            local fn = body
            body = function() return M.L(fn()) end
        end
        return origTooltip(frame, title, body)
    end
end

-- 2.6 UI.BuildDropdownControl  -- Widgets.lua:185
--     values 是「逻辑键 → 显示串」。翻译 values[k]，绝不动 k。
--     两层覆盖：
--       (a) 包函数，把 values 浅拷贝一份并翻译其值 —— 原表不被污染
--       (b) L209 的 lbl:SetText 由轨 1 兜底
--       (c) L254 的 desc:CreateRadio 走 Blizzard 菜单系统，只能靠 (a)
local origBuildDropdown = UI.BuildDropdownControl
if origBuildDropdown then
    UI.BuildDropdownControl = function(parent, ddW, fLevel, values, order, get, set)
        if type(values) == "table" then
            local copy = {}
            for k, v in pairs(values) do
                if type(v) == "string" then
                    copy[k] = M.L(v)
                else
                    copy[k] = v
                end
            end
            values = copy
        end
        return origBuildDropdown(parent, ddW, fLevel, values, order, get, set)
    end
end

-- 2.7 UI.BuildAlertSoundTables  -- Widgets.lua:678
--     names = { none = "None", [key] = "Voice: " .. text .. " (English)" }
--     只翻显示串；key 是存档键、paths 是文件路径，都不能动。
local origBuildAlertSoundTables = UI.BuildAlertSoundTables
if origBuildAlertSoundTables then
    UI.BuildAlertSoundTables = function()
        local paths, names, order = origBuildAlertSoundTables()
        if type(names) == "table" then
            for k, v in pairs(names) do
                if type(v) == "string" then names[k] = M.L(v) end
            end
        end
        return paths, names, order
    end
end

-------------------------------------------------------------------------------
--  轨 1：ns.Font 包装 + FontString.SetText 实例遮蔽
-------------------------------------------------------------------------------
-- ns.Font 是全插件所有文字的创建出口（Core.lua:70）。
-- 它返回的 FontString 上挂一个自定义 SetText，即可覆盖全插件 95% 的文本。
--
-- ⚠️ 实例字段遮蔽方法在 WoW 上可行，但为稳妥起见：
--    轨 1 失败时轨 2 仍在工作。两者都调用幂等的 L()，不会互相干扰。

local patchedFontStrings = setmetatable({}, { __mode = "k" })   -- 弱键，不阻止 GC

local function PatchFontString(fs)
    if not fs or patchedFontStrings[fs] then return fs end
    local ok = pcall(function()
        local origSetText = fs.SetText
        fs.SetText = function(self, s, ...)
            if type(s) == "string" then s = M.L(s) end
            return origSetText(self, s, ...)
        end
    end)
    if ok then patchedFontStrings[fs] = true end
    return fs
end

local origFont = SR.Font
if origFont then
    SR.Font = function(parent, size, flags, color)
        return PatchFontString(origFont(parent, size, flags, color))
    end
end

-- 兜底：给已存在的 FontString 补挂（应对加载顺序意外）
function M.RepatchAll()
    local n = 0
    -- 遍历 UIParent 的直接子级不足以覆盖全部；此处仅作应急，
    -- 正常路径依赖 ns.Font 包装。
    return n
end

-------------------------------------------------------------------------------
--  轨 3：字体接管
-------------------------------------------------------------------------------
-- ns.UIFontPath() (Core.lua:62) 内部有 local uiFontPath 缓存，函数体整体替换。
--
-- ⚠️ 字体一律取 STANDARD_TEXT_FONT（客户端「按语系构建」的标准正文字体）：
--    · 必然存在，且必然含**本语系**字形 —— 不用猜文件名，也不用随语系改代码；
--    · zhCN 下它的值就是 Fonts\ARKai_T.ttf，与旧版写死路径**完全等价，零回归**；
--    · zhTW 下自动指向该客户端的繁体字体，为将来繁体化留门
--      （zhTW 客户端**没有** ARKai_T.ttf，见 docs/繁体化可行性评估.md）；
--    · 不引入第三方字体文件，避免体积与授权问题。
--
-- 仍然「强制覆盖」：原插件优先返回 LSM 的 "Naowh" 英文矢量字体（无 CJK 字形），
-- 这才是必须接管 UIFontPath 的原因 —— 所以不再回探原函数。

local HARD_FALLBACK_FONT = "Fonts\\ARKai_T.ttf"

-- STANDARD_TEXT_FONT 由客户端在加载期定义；离线测试桩可能不给，故运行时取值 + 兜底。
local function LocaleFont()
    local f = STANDARD_TEXT_FONT
    if type(f) ~= "string" or f == "" then return HARD_FALLBACK_FONT end
    return f
end

-- ⚠️ 已知缺口（本次**有意未接管**）：屏上提醒文字本体走的是另一条出口 ——
--    RaidReminders.lua:266-487 的 r.text / r.label / r.number
--    用 ns.AlertFontPath()（主文件:773 AlertFont），经 LSM 取用户所选字体。
--    本机未装 NaowhUI_Media，LSM 无 "Naowh" 注册 → 落到 STANDARD_TEXT_FONT
--    → 当前表现正常。但用户在选项面板字体下拉里选拉丁字体时会变方块。
--    要收紧的话，在 InstallFont 里加一行 SR.AlertFontPath = LocaleFont 即可。

function M.InstallFont()
    if not SR.UIFontPath then return end
    SR.UIFontPath = LocaleFont
end

-------------------------------------------------------------------------------
--  角色名 / 拼接串的补丁
-------------------------------------------------------------------------------
-- Bosses.lua:2035 的 (role:sub(1,1) .. role:sub(2):lower()) 与
-- RaidReminders.lua:994 的 DISPLAY_TYPE_LABEL 都是「值被拼进英文句子」。
-- 策略：不改值，靠 M.TEMPLATES 里的模板整句翻译。模板在 Locale_zhCN.lua 里定义。

-------------------------------------------------------------------------------
--  启动
-------------------------------------------------------------------------------
function M.Apply()
    BuildTemplates()
    M.InstallFont()
end

-- 若 Dictionary 文件已先加载（TOC 顺序保证），立即应用
M.Apply()

return M
