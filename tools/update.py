#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NaowhSR_zhCN 汉化更新工具 —— 原插件更新后，用它低成本补翻。

原插件的界面文本散落在 12 个 .lua 文件里。每次 NaowhSmartReminders 更新
（CurseForge addonID=1682733），都有可能：
    - 新增界面串（我们没翻）
    - 删除/改写旧串（我们的字典条目变成死词条）
    - 行号漂移（串还在，只是挪了位置）

本工具重扫原插件，与上次基线（build/baseline.json）做三方对比，输出：
    build/report.md              人读的汇总报告
    build/new_strings.txt        新增未翻译（要补翻的）
    build/stale_entries.txt      字典里的死词条（可删）
    build/line_drift.txt         行号漂移（仅参考，不用管）
    build/baseline.json          本次扫描结果，成为下次的基线

用法：
    python tools/update.py                 # 只报告，不动字典
    python tools/update.py --append-dict    # 并把新增串以注释形式追加进字典
"""

import argparse
import json
import os
import re
import sys
import io
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# ⚠️ 必须在 import extract_ui_strings **之前** 重配 stdout：
#    那个模块末尾会把 sys.stdout 包成 TextIOWrapper，若我们之后在
#    本模块里再包一次，旧 wrapper 被 GC 时会关掉底层 buffer，
#    后续 print 直接 "I/O operation on closed file"。
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from extract_ui_strings import extract  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(HERE)
ADDON_DIR = r"E:\Games\Wow\_retail_\Interface\AddOns\NaowhSmartReminders"
BUILD = os.path.join(PROJ, "build")
BASELINE = os.path.join(BUILD, "baseline.json")
DICT_FILE = os.path.join(PROJ, "NaowhSR_zhCN_Dict.lua")

# 与 make_worklist.py 保持一致的噪声过滤
NOISE = [
    re.compile(r"^[A-Z][A-Z0-9_]*$"),                    # ALL_CAPS 常量
    re.compile(r"^[A-Za-z]+_[A-Za-z0-9_]+$"),            # Foo_Bar 事件名
    re.compile(r"^[A-Za-z][\w\-]*-\d+\.\d+$"),           # LibFoo-1.0
    re.compile(r"^[\W_]+$"),                             # 纯符号
    re.compile(r"^%[ds%]"),                              # 纯格式占位符
    # ── 以下为实测噪声补漏（首次扫描后新增）────────────────────────────
    re.compile(r"^[%+^$\-]"),                            # 以格式符/模式符开头
    re.compile(r"^\|"),                                  # 以颜色码/纹理标记开头
    re.compile(r"\|[cTrn]"),                             # 串内含颜色码/纹理标记
    re.compile(r"%" ),                                   # 串内含任何格式符
    re.compile(r"^[A-Z][A-Za-z0-9]*[A-Z]"),              # PascalCase（帧名/常量）
    re.compile(r"^[a-z][A-Za-z0-9]*$"),                  # camelCase 单词（键名）
    re.compile(r"^[a-z]+ [a-z]+$"),                      # 全小写双词（键/值）
    re.compile(r"^\d"),                                  # 数字开头
    re.compile(r"^[/\\]"),                               # 以斜杠开头（命令/路径）
    re.compile(r"^\["),                                  # 以方括号开头（Lua 模式）
    re.compile(r"^[\w\-:+]+\(\)$"),                      # Foo() 调用形式
    re.compile(r"^\.[\w]+$"),                            # .field
    re.compile(r"^['\"].*['\"]$"),                       # 被引号包裹
    re.compile(r"^\s"),                                  # 前导空白（拼接碎片）
]


def is_noise(s: str) -> bool:
    if len(s) < 2:
        return True
    if "\\" in s:
        return True
    return any(p.match(s) or p.search(s) for p in NOISE)


def load_dict_entries() -> set:
    """从字典文件里抠出所有已翻译的英文键。"""
    if not os.path.exists(DICT_FILE):
        return set()
    src = open(DICT_FILE, encoding="utf-8").read()
    keys = set()
    # 精确字典 M.DICT 段：["英文"] = "..."
    for m in re.finditer(r'\[\s*"((?:[^"\\]|\\.)*)"\s*\]\s*=', src):
        keys.add(m.group(1).encode().decode("unicode_escape")
                 if "\\" in m.group(1) else m.group(1))
    return keys


def scan() -> dict:
    """重扫原插件，返回 {text: [file:line, ...]}（只取 UI 类）。"""
    files = sorted(f for f in os.listdir(ADDON_DIR) if f.endswith(".lua"))
    by_text = {}
    by_loc = {}
    for f in files:
        rows = extract(os.path.join(ADDON_DIR, f), f)
        for r in rows:
            if r["cat"] != "UI":
                continue
            t = r["text"]
            if is_noise(t):
                continue
            by_text.setdefault(t, []).append(f'{r["file"]}:{r["line"]}')
            by_loc[f'{r["file"]}:{r["line"]}'] = t
    return {"scanned_at": datetime.now().isoformat(timespec="seconds"),
            "addon_dir": ADDON_DIR, "files": files,
            "by_text": by_text, "by_loc": by_loc}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--append-dict", action="store_true",
                    help="把新增串以注释形式追加到字典文件末尾")
    args = ap.parse_args()

    os.makedirs(BUILD, exist_ok=True)
    cur = scan()
    cur_texts = set(cur["by_text"])
    translated = load_dict_entries()

    print(f"扫描 {len(cur['files'])} 个文件，UI 串 {len(cur_texts)} 条去重")
    print(f"字典已有 {len(translated)} 个英文键")

    # ---- 首次运行：建立基线 ----
    if not os.path.exists(BASELINE):
        json.dump(cur, open(BASELINE, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        untranslated = sorted(cur_texts - translated, key=lambda s: (len(s), s))
        write_new(untranslated, cur)
        print(f"\n[首次运行] 已建立基线。未翻译 {len(untranslated)} 条 "
              f"→ build/new_strings.txt")
        return

    old = json.load(open(BASELINE, encoding="utf-8"))
    old_texts = set(old["by_text"])

    added = cur_texts - old_texts          # 原插件新增的串
    removed = old_texts - cur_texts        # 原插件删掉的串
    still = cur_texts & old_texts

    added_untranslated = sorted(added - translated, key=lambda s: (len(s), s))
    added_translated = sorted(added & translated, key=lambda s: (len(s), s))
    stale = sorted(removed & translated, key=lambda s: (len(s), s))

    # 行号漂移：文本相同但位置变了
    drift = []
    for t in still:
        old_loc = set(old["by_text"].get(t, []))
        new_loc = set(cur["by_text"].get(t, []))
        if old_loc != new_loc:
            drift.append((t, sorted(old_loc), sorted(new_loc)))

    write_new(added_untranslated, cur, title="原插件新增、字典缺失")
    write_report(cur, old, added, removed, added_untranslated,
                 added_translated, stale, drift)

    print(f"\n{'='*60}")
    print(f"原插件新增串      {len(added):5d}   （其中已翻译 {len(added_translated)}，"
          f"待补翻 {len(added_untranslated)}）")
    print(f"原插件删除串      {len(removed):5d}   （其中字典死词条 {len(stale)}）")
    print(f"行号漂移          {len(drift):5d}")
    print(f"{'='*60}")
    print(f"报告  → build/report.md")
    if added_untranslated:
        print(f"待补翻 → build/new_strings.txt  （{len(added_untranslated)} 条）")
    if stale:
        print(f"死词条 → build/stale_entries.txt （{len(stale)} 条，可删）")

    if args.append_dict and added_untranslated:
        append_dict(added_untranslated, cur)
        print(f"\n已把 {len(added_untranslated)} 条新增串以注释形式追加到 "
              f"NaowhSR_zhCN_Dict.lua 末尾")

    json.dump(cur, open(BASELINE, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print("基线已更新 → build/baseline.json")


def write_new(items, cur, title="原插件新增、字典缺失"):
    with open(os.path.join(BUILD, "new_strings.txt"), "w",
              encoding="utf-8") as fh:
        fh.write(f"# {title}  --  {len(items)} 条\n")
        fh.write("# 补翻后请粘贴进 NaowhSR_zhCN_Dict.lua 的 M.DICT\n\n")
        for t in items:
            fh.write(f'\n-- {cur["by_text"][t][0]}\n')
            fh.write(f'["{t}"] = "",\n')


def write_report(cur, old, added, removed, add_untr, add_tr, stale, drift):
    L = []
    L.append("# NaowhSR_zhCN 汉化更新报告\n")
    L.append(f"- 本次扫描：{cur['scanned_at']}")
    L.append(f"- 上次基线：{old.get('scanned_at', '?')}")
    L.append(f"- 原插件目录：`{ADDON_DIR}`\n")

    L.append("## 汇总\n")
    L.append("| 项 | 数量 | 说明 |")
    L.append("|---|---|---|")
    L.append(f"| UI 串总数 | {len(cur['by_text'])} | 本次扫描去重后 |")
    L.append(f"| 新增串 | {len(added)} | 原插件新增的 |")
    L.append(f"| ├ 已翻译 | {len(add_tr)} | 字典里正好已有，无需处理 |")
    L.append(f"| └ 待补翻 | {len(add_untr)} | **需要处理** |")
    L.append(f"| 删除串 | {len(removed)} | 原插件删掉的 |")
    L.append(f"| └ 死词条 | {len(stale)} | 字典里可删 |")
    L.append(f"| 行号漂移 | {len(drift)} | 仅参考 |")

    if add_untr:
        L.append(f"\n## 待补翻（{len(add_untr)} 条）\n")
        L.append("打开 `build/new_strings.txt`，逐条填中文，粘回字典。\n")
        for t in add_untr[:40]:
            L.append(f"- `{t}`   — {cur['by_text'][t][0]}")
        if len(add_untr) > 40:
            L.append(f"\n_…另有 {len(add_untr) - 40} 条，见 new_strings.txt_")

    if stale:
        L.append(f"\n## 字典死词条（{len(stale)} 条，可从 M.DICT 删除）\n")
        for t in stale[:40]:
            L.append(f"- `{t}`")
        if len(stale) > 40:
            L.append(f"\n_…另有 {len(stale) - 40} 条_")

    if drift:
        L.append(f"\n## 行号漂移（{len(drift)} 条，不影响翻译）\n")
        for t, o, n in drift[:20]:
            L.append(f"- `{t}`  {o} → {n}")

    open(os.path.join(BUILD, "report.md"), "w", encoding="utf-8").write(
        "\n".join(L) + "\n")

    if stale:
        with open(os.path.join(BUILD, "stale_entries.txt"), "w",
                  encoding="utf-8") as fh:
            fh.write(f"# 字典死词条 {len(stale)} 条（原插件已不再使用）\n")
            fh.write("# 确认无误后从 M.DICT 中删除\n\n")
            for t in stale:
                fh.write(f'["{t}"] = "",\n')

    if drift:
        with open(os.path.join(BUILD, "line_drift.txt"), "w",
                  encoding="utf-8") as fh:
            for t, o, n in drift:
                fh.write(f"{t}\n    旧: {', '.join(o)}\n"
                         f"    新: {', '.join(n)}\n\n")


def append_dict(items, cur):
    stamp = datetime.now().strftime("%Y-%m-%d")
    block = [f"\n{'-'*79}",
             f"--  ★ 待补翻（{stamp} 更新扫描）  --  {len(items)} 条",
             "--  填好中文后，把它们移进上面的 M.DICT 对应分区。",
             "--  本区块是「待办」，不是生效字典：以下条目均为注释，不影响运行。",
             f"{'-'*79}\n"]
    for t in items:
        block.append(f'-- {cur["by_text"][t][0]}')
        block.append(f'-- ["{t}"] = "",\n')
    with open(DICT_FILE, "a", encoding="utf-8") as fh:
        fh.write("\n".join(block))


if __name__ == "__main__":
    main()
