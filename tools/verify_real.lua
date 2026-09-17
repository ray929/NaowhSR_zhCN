-------------------------------------------------------------------------------
--  真实串验收：拿原插件源码里实际出现的串，验证 L() 输出
-------------------------------------------------------------------------------
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)[/\\]") or "."
package.path = here .. "/../?.lua;" .. package.path

-- 桩：让 Locale.lua 能跑
_G.NaowhUITankReminder = { UI = {} }
_G.secretvalues = nil
local SR = _G.NaowhUITankReminder
SR.THEME = { fg = { r = 1, g = 1, b = 1 } }

local fake = setmetatable({}, { __index = function() return function() end end })
SR.UIFontPath = function() return "Fonts\\FRIZQT__.TTF" end
SR.Button = function() end
SR.SetButtonText = function() end
SR.Tooltip = function() end
SR.Font = function() return fake end
SR.UI.ShowWidgetTooltip = function() end
SR.UI.BuildDropdownControl = function() end
SR.UI.BuildAlertSoundTables = function() return {}, {}, {} end

dofile(here .. "/../NaowhSR_zhCN_Dict.lua")
dofile(here .. "/../Locale.lua")
local L = _G.NaowhSR_zhCN.L

local SAMPLES = {
    -- 窗口骨架 / 页签
    "Smart Reminders", "Custom Notes", "Profiles",
    "Setup", "Cooldown Presets", "Dungeon Bosses", "Raid Bosses",
    "Trash", "Debuffs",
    -- 通用按钮
    "Save", "Cancel", "Close", "Delete", "New", "Import", "Export",
    -- 核心设置（含长说明）
    "Volume of the spoken callouts.",
    "The icon of the defensive to press.",
    "Size of the defensive icon. Independent of the text callout's size.",
    -- 模板类
    "Group 3", "Spell 12345", "Show Defensive Anchor", "Bar Size",
    "any Tank/Healer", "this spec only",
    -- 颜色码
    "|cffF0A830Tank|r", "|cffFF6060Dps|r", "|cff6DD09AHealer|r",
    -- 角色名
    "Tank", "Dps", "Healer", "Heroic", "Deadly", "Interruptible",
    -- 不该翻的（白名单透传）
    "LibStub", "OnEnter", "player", "timeline", "bigwigs",
    "Naowh", "Interface\\AddOns\\NaowhSmartReminders\\Media\\LogoAddon.tga",
}

print(string.format("%-62s | %s", "英文原串", "翻译结果"))
print(string.rep("-", 110))
local hit, miss = 0, 0
for _, s in ipairs(SAMPLES) do
    local out = L(s)
    local mark = (out ~= s) and "  译" or "  --"
    if out ~= s then hit = hit + 1 else miss = miss + 1 end
    local disp = out:gsub("\n", "\\n")
    if #disp > 48 then disp = disp:sub(1, 45) .. "..." end
    print(string.format("%-62s | %s", s:gsub("\n", "\\n"), disp .. mark))
end
print(string.rep("-", 110))
print(string.format("命中翻译 %d / 透传 %d", hit, miss))
