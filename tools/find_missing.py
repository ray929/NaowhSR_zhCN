#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
漏译探测器 —— 用「渲染出口」反查字典覆盖率。

思路与 extract_ui_strings.py 相反：
  那个脚本猜「哪些字面量像 UI 文本」（会漏），
  这个脚本找「所有真正被渲染出去的字符串」（不漏）。

做法：
  1. 找出所有 *文本渲染出口* 的调用点
     SetText / SetFormattedText / SetLabel / CreateInfo / desc = / tooltip = ...
  2. 提取其参数的「完整字符串表达式」（含 .. 拼接合并）
  3. 过滤掉含 % 格式符的（走 Lf）、含非 ASCII 的（已是中文）
  4. 与现有字典比对，输出未覆盖的

用法：
  python find_missing.py [--dict 路径]
"""

import argparse
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(HERE)
ADDON_DIR = r"E:\Games\Wow\_retail_\Interface\AddOns\NaowhSmartReminders"
DICT_FILE = os.path.join(PROJ, "NaowhSR_zhCN_Dict.lua")
OUT = os.path.join(PROJ, "build", "missing.txt")

STR_RE = re.compile(r'"(?:[^"\\\n]|\\.)*"')
CONCAT_RE = re.compile(r'\s*\.\.\s*')

# 文本渲染出口：这些函数/字段的参数是给人看的
RENDER_SINKS = re.compile(
    r"(?:"
    r"SetText|SetFormattedText|SetLabel|SetTitle|SetMessage|"
    r"CreateInfo|CreateDescription|SetTooltipText|"
    r"\btext\s*=|,\s*text\s*=|"
    r"\btooltip\s*=|"
    r"\bdesc\s*=|"
    r"\bdescription\s*=|"
    r"\bhint\s*=|"
    r"\bnote\s*=|"
    r"\blabel\s*=|"
    r"\btitle\s*=|"
    r"\bbody\s*="
    r")"
)


def strip_comments(src: str) -> str:
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith("--", i):
            m = re.match(r"--\[(=*)\[", src[i:])
            if m:
                eq = m.group(1)
                closer = "]" + eq + "]"
                end = src.find(closer, i + len(m.group(0)))
                end = n if end < 0 else end + len(closer)
                out.append(re.sub(r"[^\n]", " ", src[i:end]))
                i = end
                continue
            end = src.find("\n", i)
            end = n if end < 0 else end
            out.append(" " * (end - i))
            i = end
            continue
        m = re.match(r"\[(=*)\[", src[i:])
        if m:
            eq = m.group(1)
            closer = "]" + eq + "]"
            end = src.find(closer, i + len(m.group(0)))
            end = n if end < 0 else end + len(closer)
            out.append(src[i:end])
            i = end
            continue
        if c in "\"'":
            q = c
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == q:
                    j += 1
                    break
                if src[j] == "\n":
                    break
                j += 1
            out.append(src[i:j])
            i = j
            continue
        out.append(c)
        i += 1
    return "".join(out)


def decode_lua_string(tok: str) -> str:
    body = tok[1:-1]
    out = []
    i, n = 0, len(body)
    while i < n:
        c = body[i]
        if c == "\\" and i + 1 < n:
            nxt = body[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", "\\": "\\",
                       '"': '"', "'": "'"}
            if nxt in mapping:
                out.append(mapping[nxt])
                i += 2
                continue
            if nxt.isdigit():
                j = i + 1
                num = ""
                while j < n and body[j].isdigit() and len(num) < 3:
                    num += body[j]
                    j += 1
                out.append(chr(int(num)))
                i = j
                continue
            out.append(nxt)
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


def expand_concat(clean: str, lo: int, hi: int):
    """把 lo..hi 处的字符串向两侧扩展，吃下整条 .. 链。"""
    while True:
        pre = clean[:lo]
        pm = re.search(r"(\.\.)\s*$", pre)
        if not pm:
            break
        before = pre[:pm.start()]
        sm = re.search(r'"((?:[^"\\\n]|\\.)*)"\s*$', before)
        if not sm:
            break
        lo = sm.start()
    while True:
        post = clean[hi:]
        pm = re.match(r"\s*(\.\.)\s*", post)
        if not pm:
            break
        after = post[pm.end():]
        sm = STR_RE.match(after)
        if not sm:
            break
        hi = hi + pm.end() + sm.end()
    return lo, hi


def load_dict_keys() -> set:
    src = open(DICT_FILE, encoding="utf-8").read()
    keys = set()
    # 表内 ["k"] = ... 与文件尾 M.DICT["k"] = ...
    for m in re.finditer(r"""\[\s*"((?:[^"\\]|\\.)*)"\s*\]""", src):
        keys.add(decode_lua_string('"' + m.group(1) + '"'))
    for m in re.finditer(r"""M\.DICT\[\s*"((?:[^"\\]|\\.)*)"\s*\]""", src):
        keys.add(decode_lua_string('"' + m.group(1) + '"'))
    return keys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--show-skip", action="store_true",
                    help="同时列出含 %% 或非 ASCII 而被跳过的")
    args = ap.parse_args()

    known = load_dict_keys()
    files = sorted(f for f in os.listdir(ADDON_DIR) if f.endswith(".lua"))

    missing = []       # 真漏洞
    skipped = []       # 有原因跳过
    seen_lit = set()

    for f in files:
        raw = open(os.path.join(ADDON_DIR, f), encoding="utf-8").read()
        clean = strip_comments(raw)
        lines = clean.split("\n")

        for sm in STR_RE.finditer(clean):
            # 往前找最近的渲染出口标记
            window = clean[max(0, sm.start() - 200): sm.start()]
            if not RENDER_SINKS.search(window):
                continue

            lo, hi = expand_concat(clean, sm.start(), sm.end())
            if (lo, hi) in seen_lit:
                continue
            seen_lit.add((lo, hi))

            literal = clean[lo:hi]
            parts = STR_RE.findall(literal)
            if not parts:
                continue
            text = "".join(decode_lua_string(p) for p in parts)

            if not text or len(text) < 2:
                continue
            ln = clean.count("\n", 0, lo) + 1

            # 含 % 格式符 → 走 Lf/FORMATS，单独处理
            if "%" in text:
                skipped.append((f, ln, text, "含 % 格式符"))
                continue
            # 含非 ASCII → 已是本地化文本
            if any(ord(ch) > 127 for ch in text):
                skipped.append((f, ln, text, "含非 ASCII"))
                continue
            # 无字母 → 纯符号/数字
            if not re.search(r"[A-Za-z]{2}", text):
                skipped.append((f, ln, text, "无字母"))
                continue
            # 含反斜杠 → 路径
            if "\\" in text:
                skipped.append((f, ln, text, "路径"))
                continue

            if text in known:
                continue

            missing.append((f, ln, text))

    # 去重：同文本保留首次出现
    uniq = {}
    for f, ln, t in missing:
        uniq.setdefault(t, []).append(f"{f}:{ln}")

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(f"# 漏译候选  --  {len(uniq)} 条去重\n")
        fh.write("# 来源：文本渲染出口（SetText / text= / desc= / tooltip= ...）\n")
        fh.write("# 全部为纯 ASCII 英文、不含格式符，理论上应全部翻译\n\n")
        for t in sorted(uniq, key=lambda s: (len(s), s)):
            locs = uniq[t]
            fh.write(f"-- {' / '.join(locs[:3])}\n")
            fh.write(f'["{t}"] = "",\n\n')

    print(f"检查 {len(files)} 个文件，渲染出口字符串 {len(seen_lit)} 处")
    print(f"字典已有 {len(known)} 键")
    print(f"漏译候选 {len(uniq)} 条去重  → build/missing.txt")
    if args.show_skip:
        print(f"\n有原因跳过 {len(skipped)} 处")


if __name__ == "__main__":
    main()
