#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从 ui_strings.json 生成翻译工作底稿。

过滤掉明显不是「给人看的文本」的条目（常量、事件名、库名、纹理路径），
按「短标签 / 长句 / 模板（含 %s 等占位符）」分组输出，便于逐条翻译。

用法：
  python make_worklist.py <build_dir>
输出：
  build/worklist.txt      人工翻译用
  build/worklist.json     机器可读，供生成字典
"""

import json
import os
import re
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

# 明显噪声：
#   ALL_CAPS 常量、Foo_Bar 事件名、Foo-1.0 库名、纹理/字体路径、
#   XML 实体、纯符号、单字符
NOISE_PATTERNS = [
    re.compile(r"^[A-Z][A-Z0-9_]*$"),                    # TANK / HELPFUL / RAID
    re.compile(r"^[A-Z][A-Za-z0-9]*_[A-Za-z0-9_]+$"),    # SPELL_CAST_START
    re.compile(r"^[A-Za-z][A-Za-z0-9]*-\d+(\.\d+)*$"),   # LibSharedMedia-3.0
    re.compile(r"^(Interface|Fonts)\\\\"),                # 纹理路径
    re.compile(r"^\d+$"),
    re.compile(r"^[^A-Za-z0-9]+$"),                      # 纯符号
    re.compile(r"^%[a-z]$"),                             # 单个格式符
    re.compile(r"^\.$|^\.\.$"),
]

# 大写的"枚举值"式标签：TOP / BOTTOM / HIGH / RAID / PARTY ...
# 这些既可能是 UI 文本也可能是存档值 —— 一律交给人工判断，标注为 AMBIG
AMBIG_PATTERN = re.compile(r"^[A-Z][A-Za-z]{1,12}$")

# 已知的库 / 框架标识（不可翻）
KNOWN_NON_UI = {
    "LibStub", "LibSharedMedia-3.0", "LibDataBroker-1.1", "LibDBIcon-1.0",
    "LibCustomGlow-1.0", "BigWigs_Message", "BigWigs_Timer", "BigWigs_StopBar",
    "BigWigs_PauseBar", "BigWigs_StopBars", "BigWigs_OnBossDisable",
    "BigWigs_SetStage", "DBM_Announce", "DBM", "DBM_TimerBegin", "DBM_TimerStart",
    "DBM_TimerStop", "DBM_TimerPause", "DBM_SetStage", "INSTANCE_CHAT",
    "FULLSCREEN_DIALOG", "HIGH", "Naowh", "Setup",
    "C_EncounterEvents is not available on this client.",
    "SetEventIconTextures is not available on this client.",
}


def is_noise(t: str) -> bool:
    if t in KNOWN_NON_UI:
        return True
    for p in NOISE_PATTERNS:
        if p.match(t):
            return True
    return False


def has_placeholder(t: str) -> bool:
    # %s %d %1$s 等；注意 %% 是转义
    return bool(re.search(r"%\d*\$?[sdfxq]", t))


def main():
    build = sys.argv[1] if len(sys.argv) > 1 else "build"
    d = json.load(open(os.path.join(build, "ui_strings.json"), encoding="utf-8"))

    ui = {}
    for r in d["rows"]:
        if r["cat"] != "UI":
            continue
        ui.setdefault(r["text"], []).append(r)

    short, long_, templated, ambiguous = [], [], [], []
    for text, locs in ui.items():
        if is_noise(text):
            continue
        first = locs[0]
        entry = {
            "text": text,
            "file": first["file"],
            "line": first["line"],
            "func": first.get("func", ""),
            "count": len(locs),
            "locs": [f'{x["file"]}:{x["line"]}' for x in locs],
        }
        if AMBIG_PATTERN.match(text):
            ambiguous.append(entry)
        elif has_placeholder(text):
            templated.append(entry)
        elif len(text) <= 24:
            short.append(entry)
        else:
            long_.append(entry)

    for group in (short, long_, templated, ambiguous):
        group.sort(key=lambda e: (e["file"], e["line"]))

    result = {
        "addon": d["addon"],
        "groups": {
            "short": short,
            "long": long_,
            "templated": templated,
            "ambiguous": ambiguous,
        },
    }
    json.dump(result, open(os.path.join(build, "worklist.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    with open(os.path.join(build, "worklist.txt"), "w", encoding="utf-8") as fh:
        for name, group in (("短标签", short), ("长句", long_),
                            ("模板（含占位符，需整句翻译）", templated),
                            ("待人工判定（可能是存档值/常量）", ambiguous)):
            fh.write(f"\n{'='*78}\n{name}  --  {len(group)} 条\n{'='*78}\n")
            for e in group:
                fh.write(f'\n[{e["file"]}:{e["line"]}]  func={e["func"]}  x{e["count"]}\n')
                fh.write(repr(e["text"]) + "\n")

    total = len(short) + len(long_) + len(templated) + len(ambiguous)
    print(f"短标签 {len(short)} | 长句 {len(long_)} | 模板 {len(templated)} | 待判定 {len(ambiguous)}")
    print(f"合计 {total} 条")


if __name__ == "__main__":
    main()
