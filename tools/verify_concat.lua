-------------------------------------------------------------------------------
--  拼接串验收：确认「片段拼出来的完整串」也能翻
-------------------------------------------------------------------------------
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)[/\\]") or "."

_G.NaowhUITankReminder = { UI = {}, THEME = { fg = { r = 1, g = 1, b = 1 } } }
local SR = _G.NaowhUITankReminder
local fake = setmetatable({}, { __index = function() return function() end end })
SR.UIFontPath = function() return "x" end
SR.Font = function() return fake end
SR.Button = function() end
SR.SetButtonText = function() end
SR.Tooltip = function() end
SR.UI.ShowWidgetTooltip = function() end
SR.UI.BuildDropdownControl = function() end
SR.UI.BuildAlertSoundTables = function() return {}, {}, {} end

dofile(here .. "/../NaowhSR_zhCN_Dict.lua")
dofile(here .. "/../Locale.lua")
local L = _G.NaowhSR_zhCN.L

-- 复刻源码里的拼接表达式（Bosses.lua:3697）
local function head(uid, abilitySpellID, kind)
    return (uid and "Edit " or "New ")
        .. (abilitySpellID and "Ability Reminder" or (kind .. " Reminder"))
end

local function tankRow(title, roleTag, curated)
    return (title or "Spell 123")
        .. (roleTag and ("  " .. roleTag) or "")
        .. (curated and "  |cff0091ed[tank hit]|r" or "")
end

print("========== 拼接串验收 ==========")
local cases = {
    { "新建 技能提醒",   head(nil, true, "Boss") },
    { "编辑 技能提醒",   head("u1", true, "Boss") },
    { "新建 首领提醒",   head(nil, false, "Boss") },
    { "编辑 团队提醒",   head("u1", false, "Raid") },
    { "技能名 + 坦克标记", tankRow("Spell 999", nil, true) },
    { "Show X Anchor",   "Show Defensive Anchor" },
    { "X Size",          "Circle Size" },
    { "any 角色组",      "any Tank/Healer" },
}
for _, c in ipairs(cases) do
    local out = L(c[2])
    print(string.format("%-18s %s", c[1] .. ":", c[2]))
    print(string.format("%-18s %s", "", out))
    print()
end
