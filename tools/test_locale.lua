-------------------------------------------------------------------------------
--  tools/test_locale.lua -- 离线桩测
--
--  用 MSYS2 的 lua 直接跑：
--    D:/msys64/usr/bin/lua.exe tools/test_locale.lua
--
--  验证目标：
--    1. L() 幂等
--    2. L() 对 nil / number / boolean / table 透传
--    3. L() 对 secret value 透传（模拟）
--    4. L() 对已含中文的串透传
--    5. L() 白名单：未命中字典的逻辑键原样返回
--    6. 模板匹配顺序正确（长模式优先）
--    7. Lf 格式符数量不匹配时回退原文
--    8. FontString 实例遮蔽 SetText 的语义可行性
--    9. 颜色码 / 换行 / 前导空格在翻译后是否保持
-------------------------------------------------------------------------------

local pass, fail = 0, 0
local failures = {}

local function check(name, got, want)
    if got == want then
        pass = pass + 1
    else
        fail = fail + 1
        failures[#failures + 1] = string.format(
            "%s\n      期望: %s\n      实际: %s",
            name, tostring(want), tostring(got))
    end
end

local function check_true(name, v)
    check(name, v and true or false, true)
end

-------------------------------------------------------------------------------
--  1. 搭建 WoW API 桩
-------------------------------------------------------------------------------

-- 模拟 secret value：一个特殊 userdata 式的表，issecretvalue 认得它
local SECRET = setmetatable({}, { __tostring = function() return "SECRET" end })

local ADDON_NAME = "NaowhSR_zhCN"

-- 全局桩
_G.issecretvalue = function(v) return v == SECRET end
_G.STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
_G.LibStub = nil

-- 原插件命名空间桩（模拟 Core.lua:13-15 与 Widgets.lua:13-19）
local ns = {}
_G.NaowhUITankReminder = ns
ns._zhDictLoaded = true

-- Core.lua 的关键出口桩
local uiFontPathCalls = 0
ns.UIFontPath = function()
    uiFontPathCalls = uiFontPathCalls + 1
    return "Fonts\\FRIZQT__.TTF"
end
ns.AlertFontPath = ns.UIFontPath
ns.THEME = { fg = { r = 1, g = 1, b = 1 } }

local createdFontStrings = {}
ns.Font = function(parent, size, flags, color)
    local fs = {
        _text = nil,
        SetFont = function() end,
        SetTextColor = function() end,
        GetStringWidth = function() return 10 end,
    }
    function fs:SetText(s)
        self._text = s
    end
    createdFontStrings[#createdFontStrings + 1] = fs
    return fs
end

local buttonTexts = {}
ns.Button = function(parent, text, w, h, onClick)
    local lbl = ns.Font(parent, 12)
    lbl:SetText(text)
    buttonTexts[#buttonTexts + 1] = text
    return { label = lbl, _orig = text }
end
ns.SetButtonText = function(btn, text)
    if not (btn and btn.label) then return end
    btn.label:SetText(text)
end

local tooltipSink = {}
ns.Tooltip = function(frame, title, body) end

-- Widgets.lua 桩
local UI = {}
ns.UI = UI
UI.CONTENT_PAD = 45
UI.L = function(text) return text end        -- 原插件的空实现

local shownTooltips = {}
UI.ShowWidgetTooltip = function(label, text, opts)
    -- 复刻原实现 L56 的函数求值语义
    if type(text) == "function" then text = text() end
    if not text or text == "" then return end
    shownTooltips[#shownTooltips + 1] = text
end
UI.HideWidgetTooltip = function() end

local dropdownMenus = {}
UI.BuildDropdownControl = function(parent, ddW, fLevel, values, order, get, set)
    -- 复刻 L209（SetText 显示）与 L254（菜单项显示）两条路径
    local v = get()
    dropdownMenus[#dropdownMenus + 1] = {
        label = values[v] or tostring(v or ""),
    }
    for _, k in ipairs(order or {}) do
        dropdownMenus[#dropdownMenus + 1] = { radio = values[k] or tostring(k) }
    end
    return { _values = values, _order = order }
end

UI.BuildAlertSoundTables = function()
    local paths = { none = nil }
    local names = { none = "None" }
    local order = { "none" }
    local bundled = {
        { key = "voice:dispel-me", text = "Dispel me" },
        { key = "voice:move-out", text = "Move out" },
    }
    for _, voice in ipairs(bundled) do
        paths[voice.key] = "x.ogg"
        names[voice.key] = "Voice: " .. voice.text .. " (English)"
        order[#order + 1] = voice.key
    end
    return paths, names, order
end

-------------------------------------------------------------------------------
--  2. 加载字典与引擎
-------------------------------------------------------------------------------

local function loadfile_into(path, ...)
    local chunk, err = loadfile(path)
    if not chunk then error("loadfile 失败: " .. tostring(err), 0) end
    return chunk(...)
end

-- 字典与引擎都通过 _G.NaowhSR_zhCN 共享模块表
loadfile_into("NaowhSR_zhCN_Dict.lua", ADDON_NAME)
loadfile_into("Locale.lua", ADDON_NAME)

local M = _G.NaowhSR_zhCN
local L = M.L
local Lf = M.Lf

-------------------------------------------------------------------------------
--  3. 基础行为测试
-------------------------------------------------------------------------------

-- 3.1 精确翻译
check("精确命中: 'Save' -> '保存'", L("Save"), "保存")
check("精确命中: 'Setup' -> '设置'", L("Setup"), "设置")

-- 3.2 幂等：翻译结果再翻一次不变
local once = L("Boss Addon")
local twice = L(once)
check("幂等：L(L(s)) == L(s)", twice, once)
check("幂等且确实被翻译了", once ~= "Boss Addon", true)

-- 3.3 非字符串透传
check("nil 透传", L(nil), nil)
check("number 透传", L(42), 42)
check("boolean 透传", L(true), true)
local t = {}
check("table 透传", L(t), t)

-- 3.4 secret value 透传（关键：绝不能 tostring）
check_true("secret 透传（返回原值，不是字符串）", L(SECRET) == SECRET)

-- 3.5 已含中文的串透传（未来若原插件加了本地化，不会二次处理）
check("中文串透传", L("这是一个中文串"), "这是一个中文串")

-- 3.6 空串
check("空串透传", L(""), "")

-- 3.7 白名单：逻辑键/存档值/事件名一律原样返回
check("逻辑键透传: 'ApplicationsIncreased'",
      L("ApplicationsIncreased"), "ApplicationsIncreased")
check("逻辑键透传: 'timeline'", L("timeline"), "timeline")
check("事件名透传: 'SPELL_CAST_START'", L("SPELL_CAST_START"), "SPELL_CAST_START")
check("库名透传: 'LibSharedMedia-3.0'", L("LibSharedMedia-3.0"), "LibSharedMedia-3.0")
check("纹理路径透传: 'Interface\\\\Buttons\\\\x'",
      L("Interface\\Buttons\\x"), "Interface\\Buttons\\x")
check("未命中长句透传",
      L("some string nobody translated"), "some string nobody translated")

-------------------------------------------------------------------------------
--  4. 模板测试
-------------------------------------------------------------------------------

check("模板: 'Show X Anchor'",
      L("Show Defensive Anchor"), "显示防御技能锚点")
check("模板: 'Show X Anchor'（带空格标签）",
      L("Show Sample Timer Anchor"), "显示示例计时锚点")
check("模板: 'X Size'",
      L("Circle Size"), "圆环大小")
check("模板: 'any X'",
      L("any Tank/Healer"), "任意坦克/治疗")
check("模板: 'this spec + X'",
      L("this spec + any Tank"), "本专精 + 任意坦克")
check("精确: 独立 'Tank'（角色名）", L("Tank"), "坦克")
check("模板: 'Group 3'", L("Group 3"), "3 队")
check("模板: 'Spell 12345'", L("Spell 12345"), "法术 12345")

-- 颜色码内嵌片段（Bosses.lua:2571 的 ROLE_COLOR[label] .. label .. "|r"）
check("颜色码内嵌: '|cffF0A830Tank|r'",
      L("|cffF0A830Tank|r"), "|cffF0A830坦克|r")
check("颜色码内嵌: '|cffFF6060Dps|r'",
      L("|cffFF6060Dps|r"), "|cffFF6060输出|r")
check("颜色码内嵌: '|cff6DD09AHealer|r'",
      L("|cff6DD09AHealer|r"), "|cff6DD09A治疗|r")
check("颜色码内嵌: 内层未命中则整体原样",
      L("|cffff6060untranslated bit|r"), "|cffff6060untranslated bit|r")
check("颜色码内嵌: 多段颜色码不整体处理",
      L("|cffF0A830Tank|r, |cffFF6060Dps|r"),
      "|cffF0A830Tank|r, |cffFF6060Dps|r")

-- 模板顺序：更长的模式优先。'Show X Anchor' 必须赢过 'X Size' 之类
check("模板长度优先: 不误命中 'X Size'",
      L("Show Something Anchor"), "显示Something锚点")

-- 未命中模板的串不受影响
check("不含模板特征的长句透传",
      L("A perfectly normal sentence."), "A perfectly normal sentence.")

-------------------------------------------------------------------------------
--  5. Lf 格式化测试
-------------------------------------------------------------------------------

check("Lf 单参数模板",
      Lf("Spell %d", 123), "法术 123")
check("Lf 多参数",
      Lf("每 %s 个 %s", "A", "B"), "每 A 个 B")

-- 格式符数量不匹配时回退原文（不崩）
local ok_bad = pcall(function() return Lf("%d %d %d", 1) end)
check_true("Lf 格式符不足时不抛异常", ok_bad)

-- 参数本身也会被翻译（用于嵌套场景）
check("Lf 参数嵌套翻译",
      Lf("Trigger: %s", "Display"), "触发条件：显示")

-------------------------------------------------------------------------------
--  6. 颜色码 / 换行 / 前导空格保持
-------------------------------------------------------------------------------

local colored = "|cffff6060Boss Warnings are off in the game options.|r"
local coloredOut = L(colored)
check_true("颜色码翻译后仍含 |cff", coloredOut:find("|cffff6060") ~= nil)
check_true("颜色码翻译后仍含 |r", coloredOut:find("|r") ~= nil)

local leading = "      Callouts follow exactly one source."
local leadingOut = L(leading)
check_true("前导空格保留", leadingOut:sub(1, 6) == "      ")

local multi = "A\n\nB"
check("不含换行的未命中串透传", L(multi), multi)

-------------------------------------------------------------------------------
--  7. 拦截点集成测试
-------------------------------------------------------------------------------

-- 7.1 ns.Font 包装 + FontString 实例遮蔽 SetText
local fs = ns.Font(nil, 12)
fs:SetText("Save")
check("ns.Font 返回的 FontString 被翻译", fs._text, "保存")

-- 7.2 实例遮蔽语义：确认自定义 SetText 确实覆盖了原方法
local orig = fs.SetText
local sawRaw = nil
-- 再挂一次不应破坏（PatchFontString 幂等）
fs:SetText("Cancel")
check("FontString 第二次 SetText 仍工作", fs._text, "取消")

-- 7.3 ns.Button 包装
buttonTexts = {}
ns.Button(nil, "Test", 100, 20, nil)
check("ns.Button 文字被翻译", buttonTexts[1], "测试")

-- 7.4 HeaderText 走 ns.Font
local fs2 = ns.Font(nil, 14)
fs2:SetText("VISIBILITY OPTIONS")
check("SectionHeader 类文字被翻译", fs2._text, "显示选项")

-- 7.5 SetButtonText 包装
local btn = ns.Button(nil, "Preview", 100, 20, nil)
ns.SetButtonText(btn, "Delete")
check("ns.SetButtonText 被翻译", btn.label._text, "删除")

-- 7.6 ShowWidgetTooltip：字符串 text
shownTooltips = {}
UI.ShowWidgetTooltip(nil, "Save", nil)
check("ShowWidgetTooltip 字符串被翻译", shownTooltips[1], "保存")

-- 7.7 ShowWidgetTooltip：函数 text（关键路径，必须先求值再翻译）
shownTooltips = {}
UI.ShowWidgetTooltip(nil, function() return "Cancel" end, nil)
check("ShowWidgetTooltip 函数式 text 被翻译", shownTooltips[1], "取消")

-- 7.8 ShowWidgetTooltip：空白 text 应被原实现短路（不记录）
shownTooltips = {}
UI.ShowWidgetTooltip(nil, "", nil)
check("ShowWidgetTooltip 空串短路仍生效", #shownTooltips, 0)

-- 7.9 ShowWidgetTooltip：nil text
shownTooltips = {}
UI.ShowWidgetTooltip(nil, nil, nil)
check("ShowWidgetTooltip nil 短路仍生效", #shownTooltips, 0)

-- 7.10 下拉：values 被翻译，但 order（逻辑键）不受影响
dropdownMenus = {}
local values = { timeline = "Blizzard Timeline", bigwigs = "BigWigs", dbm = "DBM" }
local order = { "timeline", "bigwigs", "dbm" }
local dd = UI.BuildDropdownControl(nil, 180, 1, values, order,
    function() return "timeline" end, function() end)
-- dropdownMenus[1] = 当前值 label；[2..] = 各菜单项（按 order 顺序）
check("下拉显示串被翻译", dropdownMenus[1].label, "暴雪时间轴")
check("dropdown 的 order（逻辑键）未被改动", dd._order[1], "timeline")
check("dropdown 的 values 原表未被污染", values.timeline, "Blizzard Timeline")
check("菜单项 1（timeline）被翻译", dropdownMenus[2].radio, "暴雪时间轴")
check("菜单项 2 品牌名 BigWigs 保持原样", dropdownMenus[3].radio, "BigWigs")
check("菜单项 3 DBM 保持原样", dropdownMenus[4].radio, "DBM")

-- 7.11 警报音效表：显示名被翻译，key 不变
local paths, names, sorder = UI.BuildAlertSoundTables()
check("音效 'None' 被翻译", names.none, "无")
check("音效 key 未被改动", sorder[2], "voice:dispel-me")
check_true("音效显示名被翻译（含模板）",
           names["voice:dispel-me"] ~= nil and
           names["voice:dispel-me"]:find("驱散我") ~= nil)

-------------------------------------------------------------------------------
--  8. 字体接管测试
-------------------------------------------------------------------------------

local font = ns.UIFontPath()
check("UIFontPath 被替换为中文楷体", font, "Fonts\\ARKai_T.ttf")

-------------------------------------------------------------------------------
--  9. UI.L 别名
-------------------------------------------------------------------------------
check("UI.L 已被覆写为 L", UI.L("Save"), "保存")

-------------------------------------------------------------------------------
--  汇总
-------------------------------------------------------------------------------
print(string.rep("=", 70))
print(string.format("通过 %d  失败 %d", pass, fail))
if fail > 0 then
    print(string.rep("-", 70))
    for _, f in ipairs(failures) do
        print("* " .. f)
    end
    print(string.rep("=", 70))
    os.exit(1)
end
print("全部通过")
print(string.rep("=", 70))
