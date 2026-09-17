-------------------------------------------------------------------------------
--  NaowhSR_zhCN_Dict.lua -- 简体中文词典
--
--  术语风格：国服官方术语优先（团队副本 / 地下城 / 首领 / 专精 / 防御技能 /
--            冷却管理器 / 冒险指南 / 减益 / 增益 / 计时条 等）。
--
--  ⚠️ 本文件由 tools/update.py 辅助维护。手工新增词条请遵循：
--     1. 键必须是原插件源码里的**完整字符串字面量**（含颜色码、前导空格、换行 \n）
--     2. 值必须保留原串里的所有颜色码 |cXXXXXXXX ... |r 与换行 |n
--     3. 绝不要为「逻辑键/存档值」建词条 —— 见 docs/拦截点清单.md §5
--
--  编码：UTF-8 无 BOM
-------------------------------------------------------------------------------

local ADDON_NAME = ...

-- 模块表：通过全局名共享，Locale.lua 读的是同一张表。
local M = _G.NaowhSR_zhCN
if not M then
    M = {}
    _G.NaowhSR_zhCN = M
end
M.DICT = M.DICT or {}

M.DICT = {
--==============================================================================
-- 一、窗口骨架 Window.lua
--==============================================================================
-- 页签名（路由键保持英文，但渲染时经 L() 得到中文 —— 见 §6 拦截点）
["Smart Reminders"]                 = "智能提醒",
["Custom Notes"]                    = "自定义备注",
["Profiles"]                        = "配置方案",
["Setup"]                           = "设置",
["Cooldown Presets"]                = "冷却预设",
["Dungeon Bosses"]                  = "地下城首领",
["Raid Bosses"]                     = "团队首领",
["Trash"]                           = "小怪",
["Debuffs"]                         = "减益",
["Ability Reminders"]               = "技能提醒",

["|cff0091edNaowh|r Smart Reminders"] = "|cff0091edNaowh|r 智能提醒",
["Naowh Smart Reminders"]           = "Naowh 智能提醒",
["Coming soon"]                     = "即将推出",
["Click to open settings."]         = "点击打开设置。",
["Drag to move the minimap button."] = "拖动可移动小地图按钮。",

--==============================================================================
-- 二、通用按钮 / 标签
--==============================================================================
["Save"]        = "保存",
["Cancel"]      = "取消",
["Close"]       = "关闭",
["Done"]        = "完成",
["Accept"]      = "确定",
["Create"]      = "创建",
["Delete"]      = "删除",
["Reset"]       = "重置",
["Preview"]     = "预览",
["Settings"]    = "设置",
["None"]        = "无",
["Default"]     = "默认",
["Name"]        = "名称",
["Trigger"]     = "触发条件",
["Instance"]    = "副本",
["Boss"]        = "首领",
-- Bosses.lua:3688  local kind = isRaid and "Raid" or "Dungeon"
--  纯显示用局部变量，不参与比较 / 存档 / 表键，翻译安全。
["Raid"]        = "团队",
["Dungeon"]     = "地下城",
["Counter"]     = "计数器",
["Display"]     = "显示",
["Role"]        = "职责",
["Class"]       = "职业",
["Sound"]       = "音效",
["Voice"]       = "语音",
["Text Color"]  = "文字颜色",
["Everyone"]    = "所有人",
["You"]         = "你",
["Size"]        = "大小",
["Width"]       = "宽度",
["Height"]      = "高度",
["Thickness"]   = "粗细",
["Hear it"]     = "试听",
["Test"]        = "测试",
["Remove"]      = "移除",
["Merge"]       = "合并",
["Import"]      = "导入",
["Select All"]  = "全选",
["Deselect All"] = "取消全选",
["X"]           = "X",

--==============================================================================
-- 三、核心设置 ns.BuildCoreSettings
--==============================================================================
["SMART REMINDERS"]             = "智能提醒",
["PRESET LIST (THIS SPEC)"]     = "预设列表（当前专精）",
["VISIBILITY OPTIONS"]          = "显示选项",
["SIZE AND LOCATION"]           = "大小与位置",
["OPTIONS WINDOW"]              = "设置窗口",
["COLORS"]                      = "颜色",
["SOUNDS AND VOICE"]            = "音效与语音",

["Enable Healer Reminders"]     = "启用治疗提醒",
["Boss Addon"]                  = "首领插件",
["Blizzard Timeline"]           = "暴雪时间轴",
["BigWigs"]                     = "BigWigs",
["DBM"]                         = "DBM",
["Skip When Already Covered"]   = "已有减伤时跳过",
["Warn This Many Seconds Early"] = "提前预警秒数",
["Your Own Cast Covers You For"] = "自身施法覆盖时长",

["Show Icon"]                   = "显示图标",
["Show Text Call Out"]          = "显示文字提示",
["Glow It on the Cooldown Manager"] = "在冷却管理器上高亮",
["Icon Display Duration"]       = "图标显示时长",
["Hide After Casting"]          = "施放后隐藏",
["Reminder Font"]               = "提醒字体",
["Default (Naowh)"]             = "默认（Naowh）",
["Icon Size"]                   = "图标大小",
["Text Size"]                   = "文字大小",
["Text Position"]               = "文字位置",
["Above the Icon"]              = "图标上方",
["Below the Icon"]              = "图标下方",
["Left of the Icon"]            = "图标左侧",
["Right of the Icon"]           = "图标右侧",
["Show a Preview"]              = "显示预览",
["Window Scale"]                = "窗口缩放",
["100%  (default)"]             = "100%（默认）",
["Reset Icon Position"]         = "重置图标位置",

["Play a Sound"]                = "播放音效",
["Speak Which Defensive to Use"] = "朗读要使用的防御技能",
["Voice Volume"]                = "语音音量",
["Alert Sound"]                 = "警报音效",
["Game Default"]                = "游戏默认",
["Re-registers when you change it."] = "修改后会自动重新注册。",
["Default (Naowh)"]             = "默认（Naowh）",

["Color the Defensive Text"]    = "为防御技能文字着色",
["Defensive Text Color"]        = "防御技能文字颜色",

--==============================================================================
-- 四、预设列表编辑器 ns.RenderPresetListEditor
--==============================================================================
["Preset "]                     = "预设 ",
["(unnamed "]                   = "（未命名 ",
["New Preset"]                  = "新建预设",
["Rename Preset"]               = "重命名预设",
["Preset Group"]                = "预设分组",
["Healer Reminder"]             = "治疗提醒",
["Add an Ability by Spell ID"]  = "按法术 ID 添加技能",
["Restore Removed Abilities"]   = "恢复已移除的技能",
["Brings back everything you removed from the choices for this spec."]
                                = "恢复你从本专精选项中移除的全部技能。",
["      No major defensives found for this specialization."]
                                = "      未找到该专精的主要防御技能。",
["      Add an Ability by Spell ID"]
                                = "      按法术 ID 添加技能",
["      Restore Removed Abilities"]
                                = "      恢复已移除的技能",
["AttachRowCog: Settings"]      = "设置",
["Audio, and anything added later."] = "音频，以及之后新增的选项。",
["What each half is called, and leaving the set."] = "两半分别叫什么，以及退出该组合。",
[" (added by you)"]             = "（你添加的）",
["Call for an External"]        = "呼叫外部减伤",
["Call for external"]           = "呼叫外部减伤",

--==============================================================================
-- 五、弹窗：提醒编辑器 / 选择器
--==============================================================================
["BigWigs Message Timer"]       = "BigWigs 消息计时",
["Boss Cast Starts"]            = "首领开始施法",
["Boss Cast Finishes"]          = "首领施法结束",
["BigWigs Message"]             = "BigWigs 消息",
["BigWigs Timer"]               = "BigWigs 计时条",
["Time After Pull"]             = "开怪后时间",
["Gain/Lose a Buff or Debuff"]  = "获得/失去增益或减益",
["Trigger Type"]                = "触发类型",
["Display As"]                  = "显示为",
["Speak (Text-to-Speech)"]      = "朗读（文字转语音）",
["Message Spell ID / Key"]      = "消息法术 ID / 键名",
["Spell ID"]                    = "法术 ID",
["Announce in Chat"]            = "在聊天中通报",
["Edit Callout"]                = "编辑提示文字",
["Defensive"]                   = "防御技能",
["Message"]                     = "消息",
["Timer"]                       = "计时条",
["Bar"]                         = "进度条",
["Circle"]                      = "圆环",
["Warning Time (+before / -after impact)"] = "预警时间（+为命中前 / -为命中后）",
["Reminder"]                    = "提醒",
["Reminder name"]               = "提醒名称",
["Debuff sound"]                = "减益音效",
["Debuff Sounds"]               = "减益音效",
["Custom text"]                 = "自定义文字",
["Custom text (the preset supplies it)"] = "自定义文字（由预设提供）",
["Defensive preset"]            = "防御技能预设",
["Missing preset: "]            = "缺失的预设：",
["Stoneform - Naowh"]           = "石像形态 - Naowh",
["Shadowmeld - Naowh"]          = "影遁 - Naowh",
["Trash & Debuff Alerts"]       = "小怪与减益警报",
["Every dungeon"]               = "所有地下城",
["Rules for every dungeon"]     = "适用于所有地下城的规则",
["+ Debuff Sound"]              = "+ 减益音效",
["Copy From Spec"]              = "从专精复制",
["Copy Trash Rules From"]       = "复制小怪规则自",
["No other spec has any trash or debuff rules saved yet."]
                                = "其他专精尚未保存任何小怪或减益规则。",
["No other spec has any abilities saved yet."]
                                = "其他专精尚未保存任何技能。",
["Test"]                        = "测试",
["%d rule%s"]                   = "%d 条规则",
["%d set up"]                   = "已设置 %d 项",

--==============================================================================
-- 六、首领页面 ns.BuildBossListPage
--==============================================================================
["Raid Bosses"]                 = "团队首领",
["Dungeon Bosses"]              = "地下城首领",
["Select a Raid"]               = "选择团队副本",
["Select a Dungeon"]            = "选择地下城",
["Refresh From the Dungeon Journal"] = "从冒险指南刷新",
["Copy All Raids From a Spec"]  = "从某专精复制全部团队副本",
["Copy All Dungeons From a Spec"] = "从某专精复制全部地下城",
["Close the Dungeon Journal and reopen this page."]
                                = "关闭冒险指南，然后重新打开此页面。",
["Nothing found yet. Open the Adventure Guide once, then use Refresh below."]
                                = "尚未读取到数据。请先打开一次冒险指南，然后使用下方的刷新。",
["Run /nutank bosses to see which step came back empty."]
                                = "运行 /nutank bosses 查看哪一步返回为空。",
["Copy Abilities From"]         = "复制技能自",
["Anything this spec already has is left alone."]
                                = "本专精已有的内容不会被改动。",
["Copy Every %s From"]          = "复制该%s的全部内容自",
["Every %s that spec has set up is copied, and merged in alongside what is already here."]
                                = "该专精设置的全部%s都会被复制，并与现有内容合并。",
["Every %s, not just %s"]       = "每个%s，而不只是%s",
["No major defensives found for this specialization."]
                                = "未找到该专精的主要防御技能。",

["Recording rides BigWigs or DBM broadcasts and neither is installed. With one of them running, every boss you pull records itself here -- there is nothing to switch on."]
                                = "记录功能依赖 BigWigs 或 DBM 的广播，而两者均未安装。只要其中一个在运行，你打的每个首领都会自动记录在此 —— 无需开启任何开关。",
["Boss Addon is set to Blizzard Timeline, which keeps ability identity secret, so there is nothing to record from. Switch it to BigWigs or DBM on the Smart Reminders > Setup tab."]
                                = "首领插件当前设为「暴雪时间轴」，它会隐藏技能标识，因此没有可记录的数据。请在「智能提醒 > 设置」页面切换到 BigWigs 或 DBM。",
["Nothing recorded for this boss yet. Pull it with %s running and its timings appear here once the fight ends. It has to be a real boss encounter -- trash fires no encounter events, so it records nothing."]
                                = "尚未记录该首领的数据。在 %s 运行的情况下开怪，战斗结束后时间轴数据会显示在此。必须是真正的首领战 —— 小怪不会触发首领事件，因此不会产生记录。",

--==============================================================================
-- 七、配置方案页面 ns.BuildProfileSettings
--==============================================================================
["Active Profile"]              = "当前配置方案",
["Match My Spec"]               = "匹配我的专精",
["Choose a profile..."]         = "选择一个配置方案...",
["Delete Profile"]              = "删除配置方案",
["Wipes the chosen profile's settings back to defaults. Every other profile is untouched, and you do not have to be standing in it."]
                                = "把所选配置方案的设置恢复为默认值。其他配置方案不受影响，且你无需处于该方案中。",
["Every setting in it returns to default. Cannot be undone."]
                                = "其中每项设置都会恢复默认，且无法撤销。",
["Removes the chosen profile. Characters using it move to the account's default profile, and the last profile cannot be deleted."]
                                = "删除所选配置方案。使用它的角色会转移到账号默认方案；最后一个方案无法删除。",
["Cannot be undone. Characters using it move to the account's default profile."]
                                = "无法撤销。使用它的角色会转移到账号默认方案。",
["Which settings profile this character uses. Everything on these pages -- priority lists, per-boss orders, callouts, positions -- lives in the profile."]
                                = "该角色使用的设置方案。这些页面上的所有内容 —— 优先级列表、各首领顺序、提示文字、位置 —— 都保存在配置方案中。",
["Loads the profile bound to whatever spec you switch to, on login and on every spec change. A whole-file import sets those bindings up; after that, picking a profile yourself binds it to the spec you are playing."]
                                = "登录时以及每次切换专精时，自动加载与当前专精绑定的配置方案。整份文件导入会建立这些绑定；此后你手动选择方案时，会把它绑定到你当时正在玩的专精。",
["      Share your Smart Reminders"] = "      分享你的智能提醒",
["      Import Smart Reminder Profile"] = "      导入智能提醒配置方案",
["the last profile cannot be deleted"] = "最后一个配置方案无法删除",
["no such profile"]             = "没有该配置方案",

--==============================================================================
-- 八、绑定范围 / 目标选择
--==============================================================================
["Loads for"]                   = "生效范围",
["The spec that made this always loads it. Tick anything here to share it with other specs as well."]
                                = "创建它的专精始终会加载它。勾选下方任意项即可与其他专精共享。",
["Also load for any of these roles"] = "同时为以下职责加载",
["...or any of these classes"]  = "...或以下职业",
["this spec only"]              = "仅本专精",
["this spec"]                   = "本专精",
["any "]                        = "任意 ",
["Raid-Frame Glow"]             = "团队框体高亮",
["Group "]                      = "小队 ",
["The Boss"]                    = "首领",
["Watch YOUR OWN aura (a defensive/buff you gain or lose) or one applied TO the boss (a debuff you or the raid puts on it)."]
                                = "监视你自己的光环（你获得或失去的防御技能/增益），或者施加在首领身上的光环（你或团队给它上的减益）。",
["Glow Player Name (Nameplate/Raid-Frame Glow only)"]
                                = "高亮玩家姓名（仅限姓名板/团队框体高亮）",
["Message/Timer/Icon/Bar/Circle each have their own fixed on-screen spot. Chat Line prints instead of showing anything. Nameplate/Raid-Frame Glow highlight another raider's own frame -- set who below. Nameplate Glow does nothing inside dungeons and raids, where the game keeps friendly nameplates from addons; use Raid-Frame Glow there."]
                                = "消息/计时条/图标/进度条/圆环各有固定的屏幕位置。聊天栏则是打印而非显示。姓名板/团队框体高亮会高亮另一名团员的框体 —— 在下方设置对象。姓名板高亮在地下城和团队副本中无效，因为游戏会阻止插件操作友方姓名板；这些场景请改用团队框体高亮。",
["Text -- %name (your name), %specicon, %time (linger seconds), {spell:ID}"]
                                = "文字 -- %name（你的名字）、%specicon、%time（持续秒数）、{spell:ID}",
["Which of this instance's bosses the options below apply to."]
                                = "下方的选项适用于该副本中的哪些首领。",
["Which of your spec's presets this reminder calls from. When it fires it names the highest defensive on that list still off cooldown."]
                                = "该提醒从你的专精预设中调用。触发时会喊出该列表中冷却已好、优先级最高的防御技能。",
["Mark this reminder so players can opt out with Enable Healer Reminders in Setup."]
                                = "标记该提醒，使玩家可在「设置」中用「启用治疗提醒」将其关闭。",
["What starts this reminder."]  = "该提醒由什么触发。",
["This reminder's text color."] = "该提醒的文字颜色。",
["Plays once when this reminder fires."] = "该提醒触发时播放一次。",
["Reads the Text field aloud through your own client's built-in text-to-speech, using whatever voice/rate you set in the Accessibility panel."]
                                = "通过你客户端内置的文字转语音功能朗读「文字」字段，使用你在「辅助功能」面板中设置的语音与语速。",
["Speaks the fallback line when nothing on your list is up. This step is always last and cannot be moved, but it can be silenced."]
                                = "当列表中没有可用的防御技能时，朗读兜底语句。该步骤始终排在最后且不可移动，但可以静音。",
["Switch the last step back on to use this."]
                                = "请先重新开启最后一步。",
["Sends |cff0091edEXTERNAL!|r to party, raid or instance chat when nothing on your list is up, so whoever is watching for it can react. Group chat only, and at most once every three seconds however many telegraphs land together."]
                                = "当列表中没有可用的防御技能时，向小队、团队或副本频道发送 |cff0091edEXTERNAL!|r，让关注它的人能及时反应。仅限队伍频道，且无论同时有多少个预警，最多每三秒发送一次。",
["The final step, used when nothing on your list is up. Switch it off to say and show nothing at all in that case.\n\nThis is the default for the whole spec. An individual ability can override it from its own cog on a boss page, for hits the raid was never going to answer."]
                                = "最后一步，在列表中没有可用防御技能时使用。将其关闭则在这种情况下不朗读、不显示任何内容。\n\n这是整个专精的默认设置。单个技能可在首领页面通过自身齿轮覆盖此设置，用于团队本就无法应对的伤害。",
["Audio, and anything added later."] = "音频，以及之后新增的选项。",
["need a valid delay in seconds"] = "需要一个有效的秒数延迟",
["need a phase number of 1 or more"] = "阶段编号需为 1 或以上",

--==============================================================================
-- 九、分享包 Packs.lua
--==============================================================================
["Share your Profile"]          = "分享你的配置方案",
["pack name, shown on import"]  = "分享包名称，导入时显示",
["My Reminder Pack"]            = "我的提醒分享包",
["Reminder Pack"]               = "提醒分享包",
["Diagnostic Trace"]            = "诊断追踪",
["Click the text, then Ctrl+A Ctrl+C, and paste it to whoever asked."]
                                = "点击文本，然后 Ctrl+A、Ctrl+C，粘贴给需要的人。",
["Merge a Profile Into Yours"]  = "把配置方案合并进你的",
["Paste their profile string above."] = "请在上方粘贴他们的配置方案字符串。",
["Paste a pack string above."]  = "请在上方粘贴分享包字符串。",
["Take which of their profiles"] = "取用他们的哪些配置方案",
["Pick at least one profile to bring in."] = "请至少选择一个要引入的配置方案。",
["Pick at least one to bring in."] = "请至少选择一项引入。",
["Take which specs"]            = "取用哪些专精",
["Their string names no specs"] = "他们的字符串未指定专精",
["Bring in which profiles:"]    = "引入哪些配置方案：",
["Bring in which of these:"]    = "引入以下哪些内容：",
["Merge it into"]               = "合并到",
["Also take their display, sound and behaviour settings"]
                                = "同时取用他们的显示、音效与行为设置",
["Also take their raid reminders and callout lines"]
                                = "同时取用他们的团队提醒与提示文字",
["Raid reminders and callout lines"] = "团队提醒与提示文字",
["Their display, sound and behaviour settings"]
                                = "他们的显示、音效与行为设置",
["Use each on the character whose spec it covers"]
                                = "让每个配置方案作用于其覆盖专精的角色",
["Save as:"]                    = "保存为：",
["Ready to merge."]             = "可以合并了。",
["Imported Profile"]            = "导入的配置方案",
["spec priority lists"]         = "各专精优先级列表",
["active preset choice"]        = "当前启用的预设",
["per-boss orders"]             = "各首领顺序",
["callout lines"]               = "提示文字",
["custom reminders"]            = "自定义提醒",
["ability on/off"]              = "技能开关",
["audio switches"]              = "音频开关",
["raid reminders"]              = "团队提醒",
["trash and debuff rules"]      = "小怪与减益规则",
["The pack is empty."]          = "分享包为空。",
["The serializer libraries are missing from this build."]
                                = "此版本缺少序列化库。",
["There is nothing to export yet."] = "暂无可导出的内容。",
["The pack could not be serialized."] = "分享包序列化失败。",
["the string could not be read"] = "字符串无法读取",
["Your own existing profiles are not changed."] = "你已有的配置方案不会被改动。",
["Includes display, sound and behaviour settings, which will be applied."]
                                = "包含显示、音效与行为设置，这些都会被应用。",
["Each profile is bound to the specs it covers, and spec-matching is switched on: changing spec, on ANY character, auto-loads the matching one."]
                                = "每个配置方案都绑定到它覆盖的专精，且专精匹配已开启：在任意角色上切换专精都会自动加载匹配的方案。",
["The string is damaged (compression)."] = "字符串已损坏（压缩数据）。",
["The string is damaged (contents)."] = "字符串已损坏（内容）。",
["The string is damaged (profile name)."] = "字符串已损坏（配置方案名称）。",
["This pack needs a newer version of the addon."]
                                = "该分享包需要更新版本的插件。",
["This pack carries only a profile named Default, which is never landed -- every account already has its own."]
                                = "该分享包只包含名为 Default 的配置方案，它不会被导入 —— 每个账号都已经有自己的 Default。",
["there is nothing to read"]    = "没有可读取的内容",
["choose at least one spec"]    = "请至少选择一个专精",
["that profile is not in this string"] = "该配置方案不在这个字符串中",
["the string does not carry a profile"] = "该字符串未包含配置方案",
["choose the profile to merge into"] = "请选择要合并到的配置方案",
["that profile no longer exists"] = "该配置方案已不存在",
["that profile could not be opened"] = "该配置方案无法打开",
["|cffff6060The pack could not be applied.|r"] = "|cffff6060分享包无法应用。|r",
[" Each character will load the one for its spec."]
                                = " 每个角色都会加载与自身专精对应的方案。",
[" Pick one under Active Profile."] = " 请在「当前配置方案」中选择一个。",
["This profile contains an imported pack (%s by %s), so it cannot be shared onward. Build your own profile to share one."]
                                = "该配置方案包含导入的分享包（%s 来自 %s），因此无法再次分享。请构建你自己的配置方案来分享。",

--==============================================================================
-- 十、小怪 / 减益 Integrations + IntegrationOptions
--==============================================================================
["Customize Anchors"]           = "自定义锚点",
["Reminder Anchors"]            = "提醒锚点",
["Exit Config"]                 = "退出配置",
["Sample Reminder"]             = "示例提醒",
["Sample"]                      = "示例",
["Sample Timer"]                = "示例计时",
["Sample Bar"]                  = "示例进度条",
["|T134400:0|t Sample (3.4)"]   = "|T134400:0|t 示例（3.4）",
["Show %s Anchor"]              = "显示%s锚点",
["%s Size"]                     = "%s大小",
["Caption Size"]                = "说明文字大小",
["Number Size"]                 = "数字大小",

["Enabled"]                     = "启用",
["Healer Reminder"]             = "治疗提醒",
["Cast Settings"]               = "施法设置",
["Debuff Settings"]             = "减益设置",
["Text & Test Settings"]        = "文字与测试设置",
["Voice Settings"]              = "语音设置",
["Text & Test"]                 = "文字与测试",
["Cast"]                        = "施法",
["Debuff"]                      = "减益",
["New Debuff Sound"]            = "新建减益音效",
["Rules belong to the current profile and specialization."]
                                = "规则属于当前的配置方案与专精。",
["Display duration (1-15 seconds)"] = "显示时长（1-15 秒）",
["Warn before readiness (0-30 seconds)"] = "就绪前预警（0-30 秒）",
["Timing predicts ability readiness. It does not confirm a cast or its target."]
                                = "计时预测的是技能就绪时间，并不确认施法或其目标。",
["Debuff spell ID"]             = "减益法术 ID",
["Instance ID (0 = every dungeon / raid)"] = "副本 ID（0 = 所有地下城/团队副本）",
["When"]                        = "时机",
["Applied"]                     = "已施加",
["Stack increased"]             = "层数增加",
["Removed"]                     = "已移除",
["Unit"]                        = "单位",
["Me"]                          = "我",
["Party members"]               = "小队成员",
["Use the debuff's aura spell ID. The Stoneform and Shadowmeld voices require Unit: Me and stay silent while that racial is on cooldown, unknown or unusable.\n\nChanges apply after combat and encounter restrictions end. Test previews the voice regardless of cooldown."]
                                = "使用该减益的光环法术 ID。石像形态与影遁语音要求单位为「我」，并在该种族技能冷却中、未知或不可用时保持静默。\n\n改动会在战斗与首领战限制结束后生效。测试会无视冷却直接预览语音。",
["Visual test only. Enable Speak Callout or select a Sound for audio."]
                                = "仅做视觉测试。如需音频，请启用「朗读提示」或选择一个音效。",
["TTS uses Voice and Voice Volume in Setup. Check chat for any playback errors."]
                                = "TTS 使用「设置」中的语音与语音音量。播放错误请查看聊天框。",
["Sound preview requested. Save to keep these settings."]
                                = "已请求音效预览。保存后这些设置才会保留。",
["Check IDs and sound. A racial voice requires Unit: Me."]
                                = "请检查 ID 与音效。种族技能语音要求单位为「我」。",
["Profile or specialization changed. Select the reminder again."]
                                = "配置方案或专精已改变。请重新选择该提醒。",
["The trash ability catalogue is unavailable. Enable the trash timer engine and its data addon, then reopen this page."]
                                = "小怪技能目录不可用。请启用小怪计时引擎及其数据插件，然后重新打开此页面。",
["Trash timer engine unavailable. Enable a compatible timer engine to use predictions."]
                                = "小怪计时引擎不可用。请启用兼容的计时引擎以使用预测功能。",
["The trash timer engine changed; reload before using trash alerts."]
                                = "小怪计时引擎已变更；使用小怪警报前请先重载界面。",
["Aura sounds require the Retail AddAuraSound API."]
                                = "光环音效需要正式服的 AddAuraSound API。",
["Sound changes pending until combat and encounter restrictions end. Existing registrations remain active."]
                                = "音效改动将推迟到战斗与首领战限制结束后生效。现有注册保持有效。",
["Some rules could not load: check selected sound files and the 32-rule limit."]
                                = "部分规则无法加载：请检查所选的音效文件以及 32 条规则上限。",
["Some aura sounds were not accepted by the client."]
                                = "部分光环音效未被客户端接受。",
[" aura sound registrations active. Changes apply outside combat."]
                                = " 条光环音效注册已生效。改动将在脱离战斗后应用。",
["Too many rules; maximum 32 per spec."] = "规则过多；每个专精最多 32 条。",
["No enabled trash rules for this instance and spec."]
                                = "该副本与该专精没有已启用的小怪规则。",
["Check IDs, timing and sound. Stoneform voice requires Unit: Me."]
                                = "请检查 ID、时机与音效。石像形态语音要求单位为「我」。",
["Maximum 32 rules per spec."]  = "每个专精最多 32 条规则。",
["Debuff sound"]                = "减益音效",

--==============================================================================
-- 十一、消息 / 错误提示（用户可见，需翻译）
--==============================================================================
["This client does not support per-ability sounds."]
                                = "此客户端不支持按技能播放音效。",
["Per-ability sounds ride the Blizzard timeline. Boss Addon is set to a boss mod, so they are off."]
                                = "按技能音效依赖暴雪时间轴。首领插件当前设为某个首领模组，因此它们已关闭。",
["Pick a sound file. Built-in game sounds cannot be used here."]
                                = "请选择一个音效文件。内置游戏音效在此不可用。",
["No encounter ability data available yet."] = "尚无可用的首领技能数据。",
["TTS is unavailable in this client."] = "此客户端不支持 TTS。",
["No TTS voices are available. Check WoW's Text to Speech settings."]
                                = "没有可用的 TTS 语音。请检查《魔兽世界》的文字转语音设置。",
["No TTS voice is selected."]   = "未选择 TTS 语音。",
["Voice Volume is zero. Raise it under Smart Reminders > Setup > Sounds and Voice."]
                                = "语音音量为 0。请在「智能提醒 > 设置 > 音效与语音」中调高。",
["WoW could not start TTS playback. Check its Text to Speech settings."]
                                = "《魔兽世界》无法启动 TTS 播放。请检查其文字转语音设置。",
["switch the reminder on first."] = "请先开启该提醒。",
["this message reminder is disabled or belongs to another spec."]
                                = "该消息提醒已禁用，或属于其他专精。",
["this ability is toggled off for this boss, so it will not call out."]
                                = "该技能在此首领处已关闭，因此不会提示。",
["this ability is set to Ability Reminder; the generic callout stays quiet for it."]
                                = "该技能已设为「技能提醒」；通用提示对它保持静默。",
["nothing on your priority list is talented for this spec, so there is nothing to call."]
                                = "你的优先级列表中没有该专精已点出的技能，因此无可提示。",
["voice is off, so the test shows the icon only."]
                                = "语音已关闭，因此测试只显示图标。",
["this tests the bar callout; the ability's messages fire the reminder under BIGWIGS/DBM MESSAGES, which has its own Test."]
                                = "此处测试的是进度条提示；该技能的消息提醒由「BIGWIGS/DBM 消息」触发，那里有自己的测试按钮。",
["|cffff6060Boss Warnings are off in the game options.|r"]
                                = "|cffff6060游戏设置中已关闭首领警告。|r",
["Options, Advanced, Enable Boss Warnings."]
                                = "选项 → 高级 → 启用首领警告。",
["|cffff6060Boss Warnings are turned off|r, so the game sends no timeline data and the tank reminder cannot fire. Turn it back on in Options, Advanced, Combat Warnings, Enable Boss Warnings. Hiding the timeline itself is fine and changes nothing here."]
                                = "|cffff6060首领警告已关闭|r，因此游戏不会发送时间轴数据，坦克提醒无法触发。请在「选项 → 高级 → 战斗警告 → 启用首领警告」中重新开启。隐藏时间轴本身没有问题，对此毫无影响。",
["|cff9a9ea6Nothing else to configure here yet.|r"]
                                = "|cff9a9ea6此处暂无需配置的其他内容。|r",
["|cffff6060Boss Warnings are off in the game options.|r"]
                                = "|cffff6060游戏设置中已关闭首领警告。|r",
["|cffffa300%d saved abilities|r now belong to the spec that made them. Other specs start clean -- your originals are kept if this guessed wrong."]
                                = "|cffffa300%d 个已保存的技能|r 现在归属于创建它们的专精。其他专精从空白开始 —— 若判断有误，你的原始数据仍会保留。",
["|cffff6060Boss Addon is set to %s, but it is not loaded|r -- callouts have nothing to listen to. Install it, or switch Boss Addon on the Smart Reminders Setup tab."]
                                = "|cffff6060首领插件设为 %s，但它未加载|r —— 提示没有可监听的来源。请安装它，或在「智能提醒 → 设置」页面切换首领插件。",
["|cffff6060icon, text and voice are all switched off|r -- there is nothing left to show. Turn one back on in Setup."]
                                = "|cffff6060图标、文字与语音均已关闭|r —— 没有可显示的内容。请在「设置」中重新开启其中一项。",
["|cff0091ed(withheld: this line contained a secret value)|r"]
                                = "|cff0091ed（已隐去：该行包含加密值）|r",

--==============================================================================
-- 十二、角色名 / 首领标记（渲染层翻译，逻辑层安全）
--==============================================================================
-- ⚠️ 这些同时是 FLAG_LABELS 的值与 ROLE_COLOR 的键：
--      Bosses.lua:54   local ROLE_COLOR = { Tank=..., Dps=..., Healer=... }
--      Bosses.lua:2570 if ROLE_COLOR[label] then  ...  ROLE_COLOR[label] .. label
--    查色发生在**源码变量**上（label 来自 extras 切分），不经 L()，
--    因此这里加词条不会破坏取色。
--    渲染出的 "|cffF0A830Tank|r" 由 L() 的「颜色码内嵌片段」分支处理。
["Tank"]        = "坦克",
["Dps"]         = "输出",
["Healer"]      = "治疗",
["Heroic"]      = "英雄",
["Deadly"]      = "致命",
["Important"]   = "重要",
["Interruptible"] = "可打断",
["Magic"]       = "魔法",
["Bleed"]       = "流血",
["Physical"]    = "物理",
["Mixed"]       = "混合",
["Magical"]     = "魔法",
["Unknown"]     = "未知",

--==============================================================================
-- 十三、其他零散文本
--==============================================================================
["Spell "]                      = "法术 ",
["Callout"]                     = "提示文字",
["Speak Text"]                  = "朗读文字",
["Sound"]                       = "音效",
["Defensive"]                   = "防御技能",
["Nothing left to add."]        = "没有可添加的内容了。",
["No major defensives found. Try Show All Cooldowns."]
                                = "未找到主要防御技能。试试「显示全部冷却」。",
["Every cooldown you have. Click one to add it."]
                                = "你拥有的全部冷却技能。点击即可添加。",
["Your major defensives. Click one to add it to the bottom of the list."]
                                = "你的主要防御技能。点击即可添加到列表末尾。",
["      Callouts follow exactly one source."]
                                = "      提示只跟随一个来源。",
["|cffff6060Pick at least one profile to bring in.|r"]
                                = "|cffff6060请至少选择一个要引入的配置方案。|r",
["|cffff6060Pick at least one to bring in.|r"]
                                = "|cffff6060请至少选择一项引入。|r",
["Dispel me"]                   = "驱散我",
["Move out"]                    = "散开",
["Use a defensive"]             = "使用防御技能",
["Voice: "]                     = "语音：",
[" (English)"]                  = "（英语）",
["*"]                           = "*",

--==============================================================================
-- 十四、选项面板长篇说明（NaowhUI_SmartReminders.lua L6600-7000）
--==============================================================================
--  这一批是设置窗口里每个选项的「说明段落」，原插件用 EllesmereUI 的
--  desc 字段渲染。篇幅长、逐条唯一，不需要模板。
--  术语统一：callout = 提示 / defensive = 防御技能 / tank buster = 坦克杀手
--            / timeline = 时间轴 / journal = 地城日志
--==============================================================================

-- ── 显示类型（DISPLAY_TYPE_LABEL，值被拼进 "Show X Anchor" / "X Size"）────
["Icon"]                        = "图标",

-- ── 战斗 / 场景限定 ────────────────────────────────────────────────────
["Combat"]                      = "战斗",
["Encounter"]                   = "首领战",

-- ── 诊断状态行（非 /nsr 日志主体，属界面展示）─────────────────────────
["unknown command '"]           = "未知命令 '",
["' -- /nutank status for diagnostics, or see below."]
                                = "' —— 输入 /nutank status 查看诊断信息，或见下方。",
[", only: "]                    = "，仅限：",
["this client lacks the cooldown API"]
                                = "当前客户端缺少冷却 API",
["this boss is switched off in Smart Reminders"]
                                = "此首领已在「智能提醒」中关闭",
["the boss timeline feature is unavailable here"]
                                = "此处不支持首领时间轴功能",
["icon, text, voice and sound are ALL switched off"]
                                = "图标、文字、语音与音效**全部**已关闭",
["C_EncounterEvents is not available on this client."]
                                = "当前客户端不支持 C_EncounterEvents。",
["no priority list for this spec yet -- add a defensive first."]
                                = "此专精还没有优先级列表 —— 请先添加一个防御技能。",
["no priority list for this spec (or nothing on it is talented)"]
                                = "此专精没有优先级列表（或列表中的技能均未点出）",
["the reminder is switched OFF -- turn it on in Smart Reminders"]
                                = "该提醒处于关闭状态 —— 请在「智能提醒」中开启",
["nothing the journal actively contradicts."]
                                = "地城日志中没有任何与之相悖的记录。",
["open more Dungeon Bosses and Raid Bosses pages to cover the rest."]
                                = "打开更多「地城首领」与「团队首领」页面以覆盖其余部分。",
["the Cooldown Manager returned nothing -- open it once, then retry."]
                                = "冷却管理器未返回数据 —— 请先打开一次，然后重试。",
["the journal has not been scraped yet -- open a Dungeon Bosses or Raid Bosses page once, then retry."]
                                = "尚未抓取地城日志 —— 请先打开一次「地城首领」或「团队首领」页面，然后重试。",
["nothing on your priority list is talented, so there is nothing to show."]
                                = "优先级列表中的技能均未点出，因此没有可显示的内容。",
["nothing on your priority list is talented, so there is nothing to read. Add defensives in Smart Reminders, or check you are on the right spec."]
                                = "优先级列表中的技能均未点出，因此没有可朗读的内容。请在「智能提醒」中添加防御技能，或确认当前专精是否正确。",
["only Play a Sound is on: expect one beep per ability per pull, nothing else"]
                                = "仅开启了「播放音效」：每次战斗每个技能只会响一声，不会有其他提示",
["priority list is EMPTY for this spec, so nothing can ever be called -- add defensives in Smart Reminders first"]
                                = "此专精的优先级列表为空，因此不会触发任何提示 —— 请先在「智能提醒」中添加防御技能",
["no pull to report yet. Fight a boss with BigWigs or DBM running, or open the Ability Reminders tab to browse what has been recorded."]
                                = "暂无战斗记录可报告。请在与首领战斗时启用 BigWigs 或 DBM，或打开「技能提醒」标签页查看已有记录。",

-- ── 选项说明段落 ──────────────────────────────────────────────────────
["Volume of the spoken callouts."]
                                = "语音提示的音量。",
["The icon of the defensive to press."]
                                = "要按下的防御技能的图标。",
["Size of the defensive icon. Independent of the text callout's size."]
                                = "防御技能图标的大小，与文字提示的大小互不影响。",
["Size of the text callout -- the defensive name and fallback line. Independent of the icon's size."]
                                = "文字提示的大小 —— 即防御技能名称与备用文字。与图标大小互不影响。",
["Recolor the defensive callout text -- the spell name shown by the icon. Off uses the default white."]
                                = "为防御技能提示文字重新着色 —— 即图标旁显示的法术名称。关闭时使用默认白色。",
["Font for defensive callouts and ability reminder text. Saved with this profile. Unavailable fonts use the default font."]
                                = "防御提示与技能提醒文字所用的字体。随当前配置方案保存。字体不可用时使用默认字体。",
["Sound files only. A few entries are built-in game sounds rather than files, and the game will not accept those for this."]
                                = "仅支持音效文件。列表中有几项是游戏内置音效而非文件，游戏不接受将它们用于此处。",
["Stays quiet when one of your defensives is already active as the warning fires -- you are covered, no need to stack another."]
                                = "当警告触发时你已有防御技能处于激活状态，则保持静默 —— 既然已有覆盖，无需再叠加一个。",
["How many seconds the defensive icon and callout text stay visible. Defaults to 3 seconds. Hide After Casting can dismiss it early."]
                                = "防御图标与提示文字保持可见的秒数。默认为 3 秒。「施放后隐藏」可让其提前消失。",
["Dismiss the icon and callout text when you cast the suggested defensive. Off by default so they remain for the selected display duration."]
                                = "施放建议的防御技能后，立即关闭图标与提示文字。默认关闭，以便它们在设定的显示时长内一直保留。",
["Which side of the icon the text callout sits on. The text is anchored by its near edge, so it keeps the same gap from the icon however long the defensive's name is."]
                                = "文字提示位于图标的哪一侧。文字以其靠近图标的一边为锚点，因此无论防御技能名称多长，与图标的间距都保持一致。",
["Which text-to-speech voice speaks the callouts. Game Default follows whatever is picked in the game's own Text to Speech options; anything else is this addon's alone and does not change the game's setting. The list is the voices your system has installed."]
                                = "由哪个语音合成音色朗读提示。「游戏默认」跟随游戏自带语音设置中的选择；其他音色仅对本插件生效，不会改动游戏设置。列表来自你系统已安装的音色。",
["Says the callout for the defensive it picked, and your fallback line when nothing is up. On bosses with tank buster data this speaks only for tank busters; on bosses without it yet, it speaks for every timeline ability. In combat the pick comes from the addon's own tracking of your casts."]
                                = "朗读所选防御技能的提示，以及无可用技能时的备用文字。对于有坦克杀手数据的首领，仅对坦克杀手朗读；对于尚无该数据的首领，则对时间轴上的每个技能朗读。战斗中，所选技能来自本插件对你施法记录的自身追踪。",
["Plays a sound when a tank ability is coming. The game plays this one itself, which is the only way it can be limited to tank abilities -- but it also means the sound cannot know whether your defensive is ready. Watch the icon for that.|n|n|cffff6b5eIt plays at most ONCE per boss fight.|r The game will not repeat a registered sound, so a second cast of the same ability is silent. The icon is not affected and marks every cast."]
                                = "坦克技能即将到来时播放音效。此音效由游戏自身播放 —— 这是唯一能将其限定于坦克技能的方式，但也意味着音效无法得知你的防御技能是否就绪，那需要看图标。|n|n|cffff6b5e每场首领战最多只播放一次。|r 游戏不会重复播放已注册的音效，因此同一技能第二次施放时是静默的。图标不受影响，每次施放都会标记。",
["Also glows the called defensive on Blizzard's Cooldown Manager bar, so the answer appears on the bar you are already watching. Needs the Cooldown Manager turned on and that defensive placed on it.|n|n|cffff6b5eOff by default:|r this reaches across to Blizzard's own frames, so it is the first thing to switch off if anything misbehaves in combat."]
                                = "同时在暴雪冷却管理器动作条上高亮被提示的防御技能，让答案出现在你本来就盯着的那条动作条上。需要已开启冷却管理器，且该防御技能已放在其中。|n|n|cffff6b5e默认关闭：|r 此选项会跨界操作暴雪自己的框架，因此若战斗中行为异常，应首先关闭它。",
["Puts a stand-in of the alert on screen while these options are open -- the icon and the text callout exactly as a fight would draw them. DRAG IT to move the alert; the position saves instantly. It hides itself when the options close."]
                                = "在打开这些选项期间，于屏幕上显示一份警报的替身 —— 图标与文字提示的呈现与战斗中完全一致。拖动它即可移动警报位置，位置会即时保存。关闭选项后它会自动隐藏。",
["How close to the hit the alert fires. The game announces abilities about five seconds out; the alert waits and fires this many seconds before impact, so lower is closer to the hit. When the game announces later than this, the alert fires immediately. This is the BASE value every defensive uses -- override one specifically from an ability's own cog on a boss's page, next to that defensive on its preset list. That override can go negative too, to call out AFTER the hit instead of before it."]
                                = "警报触发点距离实际命中有多近。游戏大约提前五秒预告技能；警报会等待，并在命中前这么多秒触发，因此数值越小越接近命中。当游戏预告晚于此数值时，警报立即触发。这是所有防御技能使用的**基准值** —— 可在首领页面中、该防御技能于预设列表旁的齿轮按钮里，为某个技能单独覆盖。该覆盖值也可为负数，从而在命中之后而非之前提示。",
["Show reminders marked Healer Reminder. Turning this off hides them and cancels their pending alerts. Applies to every character and profile; imports do not change it. Native debuff sound changes wait until combat and the encounter end."]
                                = "显示标记为「治疗提醒」的提醒。关闭后会隐藏它们并取消待触发的警报。此设置对所有角色与配置方案生效，导入不会改变它。对原生减益音效的更改会推迟到战斗与首领战结束后生效。",
["Shows what to press when the boss timeline says an ability is about to land. It picks the highest entry on your own list that you have talented and off cooldown. Build that list below -- nothing is set up for you. Works on every specialization."]
                                = "当首领时间轴预告某技能即将落地时，显示该按什么。它会从你自己的列表中，选中排位最高且已点出、且不在冷却中的那一项。请在下方构建该列表 —— 没有任何预置内容。对所有专精均有效。",
["Writes the callout on screen -- \"Barkskin\" -- for whichever defensive it picked, and your fallback line when nothing is up. Only appears for abilities enabled in that boss's ability list, in the Bosses tab. Set each line's own wording in the list below."]
                                = "在屏幕上写出提示文字 —— 例如「树皮术」—— 针对它选中的防御技能；当无可用技能时则显示你的备用文字。仅对「首领」标签页中该首领技能列表里已启用的技能出现。可在下方列表中为每一行设置各自的措辞。",
["Which single source drives the callouts. Blizzard Timeline is the game's own encounter feed -- no addons needed, and per-ability sounds only work here. BigWigs or DBM instead ride that mod's bars and messages -- what powers timer/message reminders and phase (p2) note lines. Ability-timer Raid Reminders are BigWigs only. The other two sources are ignored entirely."]
                                = "由哪个单一来源驱动提示。「暴雪时间轴」是游戏自带的战斗事件源 —— 无需任何插件，且针对单个技能的音效仅在此模式下有效。「BigWigs」或「DBM」则依托该模组的计时条与消息 —— 计时/消息提醒以及阶段（P2）注释行即由此驱动。技能计时的团队提醒仅支持 BigWigs。其余两个来源会被完全忽略。",

-- ── 未完成页面的说明（Window.lua:52/55）──────────────────────────────
["Your own note lines, driven by the same triggers the reminders use. Not finished yet.\n\nNothing is missing in the meantime: reminders still carry their own text, set per reminder from the boss and trash pages."]
                                = "你自己的注释行，由与提醒相同的触发条件驱动。尚未完成。\n\n在此期间功能并无缺失：提醒仍各自带有自己的文字，可在首领与小怪页面中逐个设置。",
["Every reminder for one boss in a single list, instead of one boss page at a time. Not finished yet.\n\nNothing is missing in the meantime: the same reminders are authored per boss from the Dungeon Bosses and Raid Bosses tabs, which is where this page reads them from."]
                                = "把同一个首领的所有提醒汇总到一个列表中，而不必一次看一个首领页面。尚未完成。\n\n在此期间功能并无缺失：这些提醒同样可在「地城首领」与「团队首领」标签页中按首领逐个编写，本页面正是从那里读取它们。",

-- ── 备用方案开关的 tooltip（Bosses.lua:1163，源码为跨行 .. 拼接）─────
--  ⚠️ 键是「运行时的真实值」，即各跨行字面量拼接后的结果。
--     源码写成三行 "..." .. "..." .. "..."，不是单个字面量。
["The final step, used when nothing on your list is up. Switch it off to say and show nothing at all in that case.\n\nThis is the default for the whole spec. An individual ability can override it from its own cog on a boss page, for hits the raid was never going to answer."]
                                = "最后一步的兜底方案：当列表中的技能都不可用时使用。关闭它则在这种情况下既不朗读也不显示任何内容。\n\n这是整个专精的默认值。单个技能可在首领页面中通过其自身的齿轮按钮覆盖，以应对团队本就无从应对的伤害。",

--==============================================================================
-- 十五、漏译补录（用 tools/find_missing.py 反查渲染出口找出）
--==============================================================================
--  起因：用户截图发现红框内三块说明文字仍是英文。
--  根因不是拦截失效，而是旧扫描器的 NOT_UI_CTX 过滤过激 ——
--  它把 SetPoint / SetWordWrap 等相邻语句当作「非 UI 上下文」，
--  连带丢掉了同语句块里的真文本；另外含 "/" 的串被当路径、
--  以 "+"/"%"/"^" 开头的被当格式符。
--  新工具 find_missing.py 改为「反查渲染出口」（SetText / text= /
--  desc= / tooltip= / hint= / note= ...），不再猜。
--==============================================================================

-- ── 短按钮 / 标签 ──────────────────────────────────────────────────────
["OK"]                          = "确定",
["On"]                          = "开",
["Add"]                         = "添加",
["Edit"]                        = "编辑",
["Change"]                      = "更改",
["Target"]                      = "目标",
["Ability"]                     = "技能",
["Journal"]                     = "地下城日志",
["Version"]                     = "版本",
["Audio"]                       = "音效",
["Frame"]                       = "框架",
["Raids"]                       = "团队副本",
["Dungeons"]                    = "地下城",
["Unknown"]                     = "未知",
["Show in"]                     = "显示于",
["set up"]                      = "已设置",
["this one"]                    = "此首领",
["this ability"]                = "此技能",
["uptime bar"]                  = "覆盖时间条",
["Chat Line"]                   = "聊天栏文字",
["Nameplate Glow"]              = "姓名板高亮",
["Call Together"]               = "成组呼叫",
["Called Together"]             = "成组呼叫",
["Spoken text"]                 = "朗读文本",
["not watched"]                 = "未监视",
["not in encounter"]            = "不在首领战中",
["engine gated"]                = "引擎已拦截",
["encounter reset"]             = "首领战重置",
["New Profile"]                 = "新建配置方案",
["New Reminder"]                = "新建提醒",
["Add Abilities"]               = "添加技能",
["Add a Defensive"]             = "添加防御技能",
["Add Preset"]                  = "添加预设",
["Edit Reminder"]               = "编辑提醒",
["Enter SpellID"]               = "输入法术 ID",
["Reset Profile"]               = "重置配置方案",
["Import Profile"]              = "导入配置方案",
["Remove Ability"]              = "移除技能",
["Enable This Boss"]            = "启用此首领",
["Cooldown Preset"]             = "冷却预设",
["Ability Reminder"]            = "技能提醒",
["ABILITY REMINDERS"]           = "技能提醒",
["BIGWIGS/DBM MESSAGES"]        = "BIGWIGS/DBM 消息",
["Rename this preset."]         = "重命名此预设。",
["Linger (seconds)"]            = "停留时长（秒）",
["Loads for: "]                 = "加载于：",
["Failed to build this: "]      = "构建失败：",
["Failed to build this panel: "] = "构建此面板失败：",
["Failed to build the reminder lists: "] = "构建提醒列表失败：",
["That string could not be read."] = "无法读取该字符串。",
["  (not talented)"]            = "  （未点出）",
["Not a spell ID"]              = "不是法术 ID",
["not a spell id"]              = "不是法术 ID",
["+ Add a Ability Reminder"]    = "+ 添加技能提醒",
["+ Add a Raid Reminder"]       = "+ 添加团队提醒",
["+ Add a Dungeon Reminder"]    = "+ 添加地下城提醒",
["+ Use BigWigs Messages"]      = "+ 使用 BigWigs 消息",
["Show seconds after the message"] = "消息之后显示多少秒",
["Seconds After the Phase Starts"] = "阶段开始后多少秒",
["Spec IDs (comma-separated, optional)"] = "专精 ID（逗号分隔，可选）",
["Icon Spell ID (used for Icon display; optional otherwise)"]
                                = "图标法术 ID（用于图标显示；其他情况下可选）",
["Show This Many Seconds Early (blank = at that time)"]
                                = "提前多少秒显示（留空 = 准点显示）",
["Use it on every character on this account, and new ones"]
                                = "应用于此账号上的所有角色，以及今后新建的角色",

-- ── 空状态 / 提示句 ────────────────────────────────────────────────────
["None yet."]                   = "暂无。",
["None yet for this boss."]     = "此首领暂无。",
["None yet for this ability."]  = "此技能暂无。",
["This instance has no bosses in the journal yet."]
                                = "此副本在日志中尚无首领记录。",
["No abilities listed in the journal for this boss."]
                                = "日志中未列出此首领的技能。",
["Nothing in the journal for this boss carries a spell id."]
                                = "日志中此首领的内容均无法术 ID。",
["No BigWigs abilities available for this boss. Enter a spell ID below."]
                                = "此首领没有可用的 BigWigs 技能。请在下方输入法术 ID。",
["Only abilities announced by BigWigs/DBM can trigger a message reminder."]
                                = "只有 BigWigs/DBM 会预告的技能才能触发消息提醒。",
["The Dungeon Journal has not answered yet -- reopen this tab in a moment."]
                                = "地下城日志尚未响应 —— 请稍后重新打开此标签页。",

-- ── 说明段落 ──────────────────────────────────────────────────────────
["Which of your spec's presets this boss calls its defensives from."]
                                = "此首领从你专精的哪个预设中调用防御技能。",
["Called as one. Open the cog to rename either half or take one out."]
                                = "作为一组呼叫。打开齿轮可重命名任一半，或移除其中一项。",
["Take this ability off the boss. Its preset and warning time go with it."]
                                = "将此技能从首领上移除。其预设与警告时间会一并删除。",
["Its cooldown preset and warning time go with it. Adding it back later starts that ability fresh."]
                                = "其冷却预设与警告时间会一并删除。之后重新添加时，该技能将从零开始。",
["Calls out the highest defensive on that preset still ready when this ability is cast."]
                                = "当此技能施放时，呼叫该预设中仍就绪的最高优先级防御技能。",
["Only While I Have the Boss: on. Stays quiet when the boss is on the other tank."]
                                = "「仅当首领在我身上」：开。当首领在另一名坦克身上时保持静默。",
["Only While I Have the Boss: off. This spec does not tank, so calls fire regardless of aggro."]
                                = "「仅当首领在我身上」：关。此专精不担任坦克，因此无论仇恨如何都会呼叫。",
["Speaks this one when it is the defensive to press. Switch it off to keep it in your priority order but stay silent for it -- the icon and text still show."]
                                = "当它是应施放的防御技能时朗读此项。关闭后它仍保留在优先级列表中，但不会朗读 —— 图标与文字仍会显示。",
["Positive calls out before the hit lands, as usual. Negative waits until that many seconds AFTER it lands instead -- for a defensive that only matters once the mechanic is over."]
                                = "正数照常在实际命中之前呼叫。负数则改为等命中之后那么多秒 —— 适用于只有在机制结束后才有意义的防御技能。",
["Off means this ability stays silent when your list is empty, instead of asking the raid for help on a hit nobody was going to answer. Untouched, it follows the spec-wide setting on the Setup page."]
                                = "关闭意味着当你的列表为空时，此技能保持静默，而不会在无人应招的伤害上向团队求助。未改动时，跟随「设置」页面中的专精级设置。",
["Tick the abilities you want reminders for. Marked ones are what the addon knows to be tank hits on this boss. Unticking one drops it from the boss, along with any warning time or reminder set up on it."]
                                = "勾选你希望提醒的技能。已标记的是本插件认定的此首领坦克伤害。取消勾选会将该项从首领上移除，连同其警告时间或已设置的提醒一并删除。",
["Tick this on every cooldown that should be called as a set. When one of them comes up, the rest that are ready are named with it -- \"Vampiric Blood and Icebound Fortitude\". Order does not matter, and one on cooldown is simply left out rather than holding the callout back."]
                                = "在每一个应作为一组呼叫的冷却技能上勾选此项。当其中某个可用时，其余已就绪的会与它一起被念出 —— 如「吸血鬼之血与冰封之韧」。顺序无关紧要，处于冷却中的会被直接略过，而不会拖住整个呼叫。",
["Use a boss-mod message to trigger your defensive preset, immediately or after a delay. Enable Messages for this ability in BigWigs. Bars keep using the ability's own preset and warning time, so both can run together. Test previews the saved output immediately, without waiting for its message or delay."]
                                = "使用首领模组的消息来触发你的防御预设，可立即触发或延迟触发。需在 BigWigs 中为此技能启用「消息」。计时条仍沿用该技能自身的预设与警告时间，因此两者可同时运行。「测试」会立即预览已保存的输出，无需等待其消息或延迟。",
["Every reminder for the selected boss in one place. Phase Start triggers need BigWigs or DBM and only fire on bosses whose module announces phases. Any Combat, at the end of the Instance list, is for reminders that count from entering combat instead of from a boss, so they work on trash and out in the world too."]
                                = "把所选首领的所有提醒集中在一处。「阶段开始」触发器需要 BigWigs 或 DBM，且仅对模组会预告阶段的那些首领生效。列表末尾的「任意战斗」用于从进入战斗开始计时的提醒（而非从首领开始），因此对小怪和野外同样有效。",
["Anything this spec already has is left alone. A rule calls out one of your own spells, so copying from another class brings rules for spells this spec cannot cast."]
                                = "此专精已有的内容一概不动。规则呼叫的是你自己的法术，因此从其他职业复制会引入此专精无法施放的法术规则。",
["A written note tied straight to this ability's own BigWigs cast or bar -- assignable to a role, class, spec, player or subgroup, not just you."]
                                = "直接绑定到此技能自身的 BigWigs 施法或计时条上的书面注释 —— 可指派给角色定位、职业、专精、玩家或小队分组，而不只是你自己。",
["Off means this boss makes no alerts at all -- no defensives, no reminders, nothing -- and its options below disappear until it is back on."]
                                = "关闭意味着此首领完全不产生警报 —— 没有防御提示、没有提醒、什么都没有 —— 其下方的选项也会消失，直到重新开启。",
["No abilities picked for this boss yet. Add Ability lists everything the journal has for the fight, with the known tank hits marked."]
                                = "此首领尚未选取任何技能。「添加技能」会列出日志中该场战斗的全部内容，并标出已知的坦克伤害。",
["Size of this options window and the editors it opens, as a percentage. Turn it down if the window is too big for your screen; 1080p usually wants 80 or below.|n|nSaved for this computer instead of in the profile, so switching profile leaves it alone and an exported pack never carries it to someone on a different monitor."]
                                = "此选项窗口及其打开的编辑器的大小，按百分比计。若窗口在你的屏幕上过大，请调小；1080p 通常设为 80 或更低。|n|n按本机保存而非存入配置方案，因此切换方案不会影响它，导出的分享包也不会把它带给使用不同显示器的他人。",
["The client refuses addons the combat log in this build, so a defensive you press cannot be watched landing -- the press itself is all there is. This is how long after one the callout stays quiet. Set it to the length of what you actually press, or to 0 to hear about every hit even while covered. A tank who pre-pops as the boss engages wants it low: at 10 seconds, a hit five seconds after the press says nothing at all."]
                                = "在当前版本中，客户端拒绝向插件提供战斗记录，因此你施放的防御技能无法被观察是否命中 —— 只有施放本身可查。此项即施放之后提示保持静默的时长。请设为你实际所按技能的长度；设为 0 则即使已有覆盖也会播报每一次命中。在首领接战时就预先开启技能的坦克应把它调低：若设为 10 秒，施放后 5 秒的那次命中将完全不播报。",
["Message fires the instant BigWigs announces it. Timer waits out the bar and fires this many seconds before it ends. Time After Pull fires a fixed number of seconds into the encounter, with no BigWigs mechanic involved. Gain/Lose a Buff or Debuff fires off the combat log directly, reliable even when BigWigs says nothing about it. Phase Start fires a fixed number of seconds after the boss mod announces that phase -- it needs BigWigs or DBM, and only fires on bosses whose module announces phases."]
                                = "「消息」在 BigWigs 预告的瞬间触发。「计时条」等待计时条走完，并在其结束前这么多秒触发。「接战后的时间」在进入首领战后固定秒数触发，不涉及任何 BigWigs 机制。「获得/失去增益或减益」直接依据战斗记录触发，即使 BigWigs 毫无提示也可靠。「阶段开始」在首领模组预告该阶段后固定秒数触发 —— 需要 BigWigs 或 DBM，且仅对模组会预告阶段的那些首领生效。",

-- ── 颜色码包裹的空状态 / 报错（整串命中，L 的颜色码分支亦可用）──────
["|cffff6060Not a spell ID|r"]  = "|cffff6060不是法术 ID|r",
["|cffff6060not a spell id|r"]  = "|cffff6060不是法术 ID|r",
["|cffff6060this journal entry has no spell id to bind to|r"]
                                = "|cffff6060此日志条目没有可绑定的法术 ID|r",
["|cff9a9ea6No presets yet -- add one on the Setup page first.|r"]
                                = "|cff9a9ea6尚无预设 —— 请先在「设置」页面添加一个。|r",
["|cff9a9ea6no spell name found -- boss-mod keys aren't always real spell ids, that's fine|r"]
                                = "|cff9a9ea6未找到法术名称 —— 首领模组的键名并不总是真实法术 ID，这没关系|r",
["|cff9a9ea6Nothing recorded for this boss yet -- pull it with BigWigs running, or type a Spell ID below.|r"]
                                = "|cff9a9ea6此首领尚无记录 —— 请在启用 BigWigs 的情况下接战一次，或在下方输入法术 ID。|r",

-- ── 运行时拼接片段的独立词条 ──────────────────────────────────────────
--  Bosses.lua:3697  head:SetText((uid and "Edit " or "New ") .. (… and "Ability Reminder" or (kind .. " Reminder")))
--  这些片段在别的调用点也会单独出现，必须各自有词条。
["Edit "]                       = "编辑",
["New "]                        = "新建",
[" Reminder"]                   = "提醒",
["  |cff0091ed[tank hit]|r"]    = "  |cff0091ed[坦克伤害]|r",
["  |cffff6060still blocked:|r "] = "  |cffff6060仍被阻挡：|r ",
["|cff0091ed[tank hit]|r"]      = "|cff0091ed[坦克伤害]|r",
}

--==============================================================================
-- 补充：常用按钮文案（首次全量扫描后补录）
--==============================================================================
M.DICT["New"]    = "新建"
M.DICT["Export"] = "导出"
M.DICT[" + Add Preset"] = " + 添加预设"

-- “+” 开头的按钮文案（实测易被误判为格式符而漏掉，统一补录）
M.DICT["+ Add Ability"]              = "+ 添加技能"
M.DICT["+ Add Preset"]               = "+ 添加预设"
M.DICT["+ Debuff Sound"]             = "+ 减益音效"
M.DICT["+ Use BigWigs Messages"]     = "+ 使用 BigWigs 消息"
M.DICT["+ Add a Ability Reminder"]   = "+ 添加技能提醒"
M.DICT["+ Add a Raid Reminder"]      = "+ 添加团队提醒"
M.DICT["+ Add a Dungeon Reminder"]   = "+ 添加地下城提醒"

--==============================================================================
-- 补充：截图反馈第二批（积分/减益音效面板 · 状态行 · 长句说明）
--
-- 来源：
--   NaowhUI_SmartReminders_IntegrationOptions.lua  L555 / L590 / L601 / L602
--   NaowhUI_SmartReminders_Integrations.lua        L253 / L400
--   NaowhUI_SmartReminders_Bosses.lua              L2359
--==============================================================================

-- ── 减益音效面板（IntegrationOptions.lua L555-602）────────────────────────
M.DICT["Saved Debuff Sounds"] = "已保存的减益音效"
M.DICT["None yet. Add one with the button above."] = "暂无。用上方按钮添加一个。"
M.DICT["A debuff sound plays when an aura is applied, stacks or falls off."] =
    "当光环被施加、叠加或消失时播放减益音效。"
M.DICT["Use the debuff's own aura spell ID. These apply wherever you set them, not to one dungeon. Changes are saved only when you click Save."] =
    "请使用减益自身的法术光环 ID。它们在你设定的任何地方生效，而非仅限某个地下城。只有点击保存后改动才会被保存。"

-- ── 小怪计时器状态行（Integrations.lua L253）─────────────────────────────
M.DICT["Trash timers connected. Alerts predict readiness, not a confirmed cast."] =
    "小怪计时器已连接。警报预测的是技能就绪状态，而非已确认的施法。"

-- ── 选项面板长句说明 ─────────────────────────────────────────────────────
M.DICT["Select settings, then Save. Test previews your current choices."] =
    "先选择设置，再点击保存。测试会预览你当前的选项。"
M.DICT["Select an ability to set up its callout, or switch one on to start from the defaults."] =
    "选择一个技能来设置它的提示，或直接开启一个以从默认值开始。"
M.DICT["Debuff sounds live on their own tab. Changes are saved only when you click Save."] =
    "减益音效位于它们自己的页签。只有点击保存后改动才会被保存。"

-- ── Bosses.lua L2359 的提示标签 ──────────────────────────────────────────
M.DICT["Call for an External when nothing of yours is up"] =
    "当你的技能都不可用时呼叫外部减伤"

-------------------------------------------------------------------------------
--  模板 A：纯 Lua 模式（可脱离 string.format 独立匹配）
--
--  ⚠️ 语法是 Lua 的 string.match / gsub 模式，**不是** string.format！
--     数字写法 (%d+) ，字符串写法 (.+) ；替换侧用 %1 %2 引用捕获组。
--
--  用途：处理「英文片段在运行时被拼进句子」的情况，例如
--        "Show " .. DISPLAY_TYPE_LABEL[dt] .. " Anchor"  → "显示防御锚点"
--
--  ⚠️ 全部锚定 ^...$。只有整串恰好匹配才算命中，绝不误伤子串
--     （"Spell" 这种词到处都有，不锚定会翻错地方）。
--  ⚠️ 只在精确字典未命中时才尝试，按模式长度降序匹配。
-------------------------------------------------------------------------------
M.TEMPLATES = {
    -- ── 运行时拼接出的「单词 + 数字」──────────────────────────────────────
    -- 原插件多处用 ("Spell " .. id) / ("Group " .. i) 形式生成显示串，
    -- 这些串不经过 string.format，所以必须是模式模板而非 format 表。
    -- ^...$ 锚定 + (%d+) 捕获，L("Spell 12345") → "法术 12345"。
    ["^Spell (%d+)$"]           = "法术 %1",
    ["^Preset (%d+)$"]          = "预设 %1",
    ["^Spec (%d+)$"]            = "专精 %1",
    ["^Group (%d+)$"]           = "%1 队",

    -- ── 值被拼进英文句子 ──────────────────────────────────────────────────
    -- RaidReminders.lua:1299  "Show " .. DISPLAY_TYPE_LABEL[dt] .. " Anchor"
    ["^Show (.+) Anchor$"]      = "显示%1锚点",
    -- RaidReminders.lua:1432  (DISPLAY_TYPE_LABEL[dt] or dt) .. " Size"
    ["^(.+) Size$"]             = "%1大小",

    -- Bosses.lua:3697  编辑器标题，由三段拼接而成：
    --   (uid and "Edit " or "New ") .. (abilitySpellID and "Ability Reminder"
    --                                   or (kind .. " Reminder"))
    -- 产出形如 "New Ability Reminder" / "Edit Raid Reminder"。
    --
    -- ⚠️ Lua 模式**没有** | 交替运算符（"|" 是字面竖线）！
    --    必须写成 "(Edit|New)" 之外的等价形式，这里用 "(%a+) " 捕获首词，
    --    再靠 L() 把 "New"/"Edit" 各自翻成 "新建"/"编辑"。
    ["^(%a+) Ability Reminder$"]  = "%1技能提醒",
    ["^(%a+) (%a+) Reminder$"]    = "%1%2提醒",

    -- Bosses.lua:2038 / 2046  "any " .. table.concat(roles, "/")
    -- 捕获组是 "Tank/Healer" 形式，由 L() 的斜杠分支逐段翻译。
    ["^any (.+)$"]              = "任意%1",

    -- Bosses.lua:2031 DescribeBindingScope 的 parts 拼接
    ["^this spec %+ (.+)$"]     = "本专精 + %1",
    ["^this spec only$"]        = "仅本专精",

    -- 下拉「语音：<名称>（英语）」
    ["^Voice: (.+) %(English%)$"] = "语音：%1（英语）",

    -- Integrations.lua:400  count .. " aura sound registrations active."
    --                       .. " Changes apply outside combat."
    --
    -- ⚠️ 运行时拼接：数字在源码里是变量，整句不以字面量形式存在，
    --    因此**不能**只加 DICT 词条，必须用模式模板捕获数字。
    --    "0"/"3" 都应命中 → "0 条光环音效注册生效中。……"
    ["^(%d+) aura sound registrations active%. Changes apply outside combat%.$"]
        = "%1 条光环音效注册生效中。改动将在战斗之外生效。",

    -- 颜色码外壳：|cAARRGGBB<内容>|r  （轨道 3 之外的第二条通道，用于
    -- 内容本身还需走模板的情况，如 "|cffF0A830Dps|r"）
    ["^(|c%x%x%x%x%x%x%x%x)(.+)%|r$"] = "%1%2|r",
}

-------------------------------------------------------------------------------
--  模板 B：string.format 格式串（供 M.Lf 使用）
--
--  ⚠️ 语法是 string.format 的格式符：%d %s %g %02d ...
--     **不可**喂给 string.match！ "%d" 在模式里是「数字类」而非捕获组，
--     "%s" 更是完全没有捕获语义 —— 这就是之前模板全部静默失效的根因。
--
--  用法：Lf("Trigger: %s", name) → string.format("触发条件：%s", name)
--        参数本身会先经过 L()，再代入。
-------------------------------------------------------------------------------
M.FORMATS = {
    ["Spell %d"]                  = "法术 %d",
    ["Preset %d"]                 = "预设 %d",
    ["Spec %d"]                   = "专精 %d",
    ["Group %d"]                  = "%d 队",
    ["Trigger: %s"]               = "触发条件：%s",
    ["%s: %s"]                    = "%s：%s",
    ["%d rule"]                   = "%d 条规则",
    ["%d rule%s"]                 = "%d 条规则",
    ["%d set up"]                 = "已设置 %d 项",
    ["%d profile%s imported.%s"]  = "已导入 %d 个配置方案。%s",
    ["P%d +%gs  %s"]              = "阶段%d +%gs  %s",
}

-------------------------------------------------------------------------------
--  显式豁免：这些串即使被识别为 UI 文本也**绝不翻译**
--
--  用途：未来原插件新增串若与逻辑键同形，可在此钉住；也是自文档化的"危险区"备忘。
--  L() 目前不会查这张表（因为白名单机制天然保护未命中项），
--  保留它用于生成工具做差集检查与人工复核。
-------------------------------------------------------------------------------
M.SKIP = {
    -- 页签路由键（靠 FontString 拦截渲染，源码串本身不翻）
    -- 注意：这些**在 DICT 里有条目**，因为 §6 的渲染点需要它们；
    -- 而路由比较发生在源码变量层面，不经 L()，所以安全。
    -- 同理 FLAG_LABELS / ROLE_COLOR 的角色名也在 DICT 里，
    -- 取色发生在源码变量上，不经 L()。

    -- 框架/库标识
    ["LibStub"] = true, ["LibSharedMedia-3.0"] = true,
    ["LibDataBroker-1.1"] = true, ["LibDBIcon-1.0"] = true,
    ["LibCustomGlow-1.0"] = true, ["LibSerialize"] = true, ["LibDeflate"] = true,

    -- 事件名 / 回调名
    ["OnEnter"] = true, ["OnLeave"] = true, ["LeftButton"] = true, ["Master"] = true,

    -- 存档值
    ["Added"] = true, ["ApplicationsIncreased"] = true, ["Removed"] = true,
    ["player"] = true, ["party"] = true, ["timeline"] = true,
    ["bigwigs"] = true, ["dbm"] = true,
    ["TOP"] = true, ["BOTTOM"] = true, ["LEFT"] = true, ["RIGHT"] = true,

    -- 纹理 / 字体名
    ["UnitButton"] = true, ["NaowhGradient"] = true,
    ["GameFontHighlightSmall"] = true,

    -- 品牌名（保持英文，不翻）
    ["Naowh"] = true,

    --==========================================================================
    -- 诊断输出（按用户既定决策：诊断类全部跳过，保持英文）
    -- 这些串从 ns.Print / 调试面板输出，属排查信息，保持原样便于对照日志。
    --==========================================================================
    ["message check: mod="] = true,
    ["message matched: "] = true,
    ["message fire gated: frame="] = true,
    ["message defensive dispatch: "] = true,
    ["message: no enabled reminder matched"] = true,
    ["message: preset has no available configured spells"] = true,
    ["verified uptime: "] = true,
    ["no cooldown ready; waiting until bar expiry"] = true,
    ["late-ready window expired"] = true,
    ["AUTHORING MODE -- CALLING EVERY ABILITY"] = true,

    -- 面板构建失败的诊断标签（同上，保持英文）
    ["|cffff6060ability add picker|r: "] = true,
    ["|cffff6060ability reminder picker|r: "] = true,
    ["|cffff6060raid reminder editor|r: "] = true,
}
