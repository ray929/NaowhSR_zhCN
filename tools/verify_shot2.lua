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

-- 本轮三张截图里出现的全部文本
local S = {
    -- 图 1（减益页）
    "Debuff Sounds",
    "Saved Debuff Sounds",
    "None yet. Add one with the button above.",
    "A debuff sound plays when an aura is applied, stacks or falls off.",
    "Use the debuff's own aura spell ID. These apply wherever you set them, not to one dungeon. Changes are saved only when you click Save.",
    "No enabled trash rules for this instance and spec.",
    -- 图 2（小怪页）
    "Trash & Debuff Alerts",
    -- 图 3（首领页 Last: 行）
    "Call for external",
    "Call for an External",
    -- 状态行
    "Aura sounds require the Retail AddAuraSound API.",
    "Sound changes pending until combat and encounter restrictions end. Existing registrations remain active.",
    "Trash timer engine unavailable. Enable a compatible timer engine to use predictions.",
    "The trash timer engine changed; reload before using trash alerts.",
    "Trash timers connected. Alerts predict readiness, not a confirmed cast.",
    "Too many rules; maximum 32 per spec.",
    "Some rules could not load: check selected sound files and the 32-rule limit.",
    "Some aura sounds were not accepted by the client.",
    -- 面板标题 / 说明
    "Text & Test Settings",
    "Voice Settings",
    "Select a Dungeon",
    "Select settings, then Save. Test previews your current choices.",
    "Timing predicts ability readiness. It does not confirm a cast or its target.",
    "Select an ability to set up its callout, or switch one on to start from the defaults.",
    "Debuff sounds live on their own tab. Changes are saved only when you click Save.",
    -- 拼接 / 格式类
    "0 aura sound registrations active. Changes apply outside combat.",
    "3 aura sound registrations active. Changes apply outside combat.",
    "Call for an External when nothing of yours is up",
}

print("========== 本轮截图文本 ==========")
local miss = {}
for i = 1, #S do
    local out = L(S[i])
    local hit = out ~= S[i]
    if not hit then miss[#miss + 1] = S[i] end
    print(string.format("%s %s", hit and "[译]" or "[漏]", S[i]:sub(1, 68)))
    if hit then print("      -> " .. out:gsub("\n", " "):sub(1, 90)) end
end
print()
print(string.format("漏 %d / 共 %d", #miss, #S))
