-------------------------------------------------------------------------------
--  截图红框验收：确认用户截图中未汉化的三块现在都翻了
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

local S = {}
S[#S+1] = "No abilities picked for this boss yet. Add Ability lists everything "
       .. "the journal has for the fight, with the known tank hits marked."
S[#S+1] = "BIGWIGS/DBM MESSAGES"
S[#S+1] = "Use a boss-mod message to trigger your defensive preset, immediately or "
       .. "after a delay. Enable Messages for this ability in BigWigs. "
       .. "Bars keep using the ability's own preset and warning time, so both can run together. Test previews the saved output immediately, without waiting for its message or delay."
S[#S+1] = "None yet for this boss."
-- 顺带核对截图里其余可见文本
S[#S+1] = "Enable This Boss"
S[#S+1] = "Cooldown Preset"
S[#S+1] = "+ Add Ability"
S[#S+1] = "+ Use BigWigs Messages"
S[#S+1] = "Copy From Spec"
S[#S+1] = "Default (Naowh)"

print("============ 截图文本验收 ============")
local ok, bad = 0, 0
for i = 1, #S do
    local out = L(S[i])
    local hit = out ~= S[i]
    if hit then ok = ok + 1 else bad = bad + 1 end
    print(string.format("%s  %s", hit and "[译]" or "[漏]", S[i]:sub(1, 60)))
    if hit then print("      -> " .. out:gsub("\n", " ")) end
    print()
end
print(string.format("翻译 %d / 漏 %d", ok, bad))
