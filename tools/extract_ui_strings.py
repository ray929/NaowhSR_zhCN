#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从 NaowhSmartReminders 源码中提取「完整的 UI 字符串表达式」。

与第一版 scan_strings.py 的关键区别：
  1. 把 Lua 里用 `..` 拼接的多个字符串字面量合并为一个完整表达式
     （原插件大量使用 "前半句 " .. "后半句" 的写法，逐字面量提取毫无意义）
  2. 只保留「看起来是给人看的文本」的表达式，并记录其所在函数名，
     便于按函数拦截点归类
  3. 输出可直接用于生成字典的 TSV / JSON

用法：
  python extract_ui_strings.py <addon_dir> <out_dir>
"""

import json
import os
import re
import sys

# ⚠️ 用 reconfigure 而非重新包 TextIOWrapper。
#    直接赋值 sys.stdout 会在被其它脚本 import 时留下隐患：
#    旧 wrapper 失去引用后 GC 会关掉底层 buffer，导致调用方 print 报
#    "I/O operation on closed file"。
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

# ---------------------------------------------------------------------------
# Lua 词法：剥离注释、合并字符串
# ---------------------------------------------------------------------------

def strip_comments(src: str) -> str:
    """逐字符剥离注释，用空格替换以保持字符偏移与行号不变。"""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        # 长括号注释 --[[ ]] / --[==[ ]==]
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
            # 行注释
            end = src.find("\n", i)
            end = n if end < 0 else end
            out.append(" " * (end - i))
            i = end
            continue
        # 长括号字符串 [[ ]] / [==[ ]==]  -- 内容原样保留
        m = re.match(r"\[(=*)\[", src[i:])
        if m:
            eq = m.group(1)
            closer = "]" + eq + "]"
            end = src.find(closer, i + len(m.group(0)))
            end = n if end < 0 else end + len(closer)
            out.append(src[i:end])
            i = end
            continue
        # 普通字符串：整体跳过，避免里面的 -- 被当注释
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


def line_of(src: str, pos: int) -> int:
    return src.count("\n", 0, pos) + 1


# ---------------------------------------------------------------------------
# 表达式合并：把 "a" .. "b" .. var .. "c" 归并为一个 tab
# ---------------------------------------------------------------------------

STR_RE = re.compile(r'"(?:[^"\\\n]|\\.)*"')
CONCAT_RE = re.compile(r'\s*\.\.\s*')


class Token:
    __slots__ = ("kind", "value", "start", "end")

    def __init__(self, kind, value, start, end):
        self.kind = kind      # 'str' | 'concat' | 'other'
        self.value = value
        self.start = start
        self.end = end


def tokenize_region(text: str, base: int):
    """把一段文本切成 str / concat / other 三类 token。"""
    toks = []
    i, n = 0, len(text)
    while i < n:
        m = STR_RE.match(text, i)
        if m:
            toks.append(Token("str", m.group(0), base + m.start(), base + m.end()))
            i = m.end()
            continue
        m = CONCAT_RE.match(text, i)
        if m:
            toks.append(Token("concat", None, base + m.start(), base + m.end()))
            i = m.end()
            continue
        toks.append(Token("other", text[i], base + i, base + i + 1))
        i += 1
    return toks


def decode_lua_string(tok: str) -> str:
    """把 Lua 字符串字面量（含引号）解码成实际值。"""
    body = tok[1:-1]
    out = []
    i, n = 0, len(body)
    while i < n:
        c = body[i]
        if c == "\\" and i + 1 < n:
            nxt = body[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", "\\": "\\", '"': '"', "'": "'"}
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


# ---------------------------------------------------------------------------
# 判断一个合并后的表达式是不是「UI 文本」
# ---------------------------------------------------------------------------

# 明显不是 UI 文本的上下文关键词（语句里出现即跳过）
NOT_UI_CTX = re.compile(
    r"\b("
    r"tostring|strsub|strsplit|gsub|match|find|format\s*\(\s*\"%|"
    r"RegisterEvent|SetScript|SetPoint|SetSize|SetTexture|SetFont|"
    r"CreateFrame|GetAddOnMetadata|SavedVariables|C_Timer|hooksecurefunc|"
    r"UnitGUID|GetSpellInfo|spellID|itemID|mapID|encounterID|"
    r"EditBox|SetAutoFocus|SLASH_|SlashCmdList"
    r")\b"
)

# 代码味道：不含空格且全小写，大概率是键/标识符
KEYISH = re.compile(r"^[a-z][a-z0-9:_\-]*$")

# 含这些字符说明是给人读的
HUMAN_HINT = re.compile(r"[ .,!?:;'\"]|^[A-Z]")

# 格式化占位符 / 颜色码 / 换行
RICH = re.compile(r"%[ds%]|\|c[0-9a-fA-F]{8}|\|r|\|n|\|T")


def looks_like_ui_text(s: str) -> bool:
    if not s or len(s) < 2:
        return False
    # 纯 ASCII 之外的字符（中文等）→ 已是本地化串，跳过
    if any(ord(ch) > 127 for ch in s):
        return False
    # 键名/路径
    if KEYISH.match(s):
        return False
    if "\\" in s:               # 文件路径、纹理
        return False
    if s.startswith("Interface") or s.startswith("Fonts"):
        return False
    # 至少要有空格 或 富文本标记 或 看起来像句子
    has_space = " " in s
    if not has_space and not RICH.search(s):
        # 单个词：只在首字母大写且长度 > 2 时才认为是 UI（按钮文字）
        return len(s) > 2 and s[0].isupper()
    return bool(HUMAN_HINT.search(s) or RICH.search(s))


# 诊断/日志类关键词：命中即归为 SKIP（按用户要求跳过诊断日志）
DIAG_CTX = re.compile(
    r"\b(diag|trace|log|Debug|DEBUG|audit|PRETEND|withheld)\b",
    re.IGNORECASE,
)


def classify(stmt_context: str, text: str, func: str) -> str:
    """返回 'UI' | 'DIAG' | 'SKIP'"""
    if DIAG_CTX.search(stmt_context) or DIAG_CTX.search(func):
        return "DIAG"
    if NOT_UI_CTX.search(stmt_context):
        return "SKIP"
    if not looks_like_ui_text(text):
        return "SKIP"
    return "UI"


# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------

FUNC_RE = re.compile(r"^\s*(?:local\s+)?function\s+([A-Za-z_][\w.:]*)")


def extract(path: str, fname: str):
    raw = open(path, encoding="utf-8").read()
    clean = strip_comments(raw)

    rows = []
    # 逐行扫描，但表达式可能跨行 → 以「语句」为窗口
    # 简化做法：找出所有字符串字面量，然后向前后扩展合并 `..` 链
    for m in STR_RE.finditer(clean):
        start, end = m.start(), m.end()

        # 向前扩展：跳过空白与 .. 继续吃字符串/变量
        # 只吃「字符串 .. 字符串」形式；遇到变量则停止（无法静态求值）
        lo = start
        while True:
            pre = clean[:lo]
            pm = re.search(r"(\.\.)\s*$", pre)
            if not pm:
                break
            before = pre[: pm.start()]
            sm = re.search(r'"((?:[^"\\\n]|\\.)*)"\s*$', before)
            if not sm:
                break
            lo = sm.start()

        # 向后扩展：字符串 .. 字符串
        hi = end
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

        literal = clean[lo:hi]

        # 同一字面量已在前一轮合并中被包含 → 跳过
        if rows and rows[-1]["_end"] == hi:
            continue

        parts = STR_RE.findall(literal)
        if not parts:
            continue
        value = "".join(decode_lua_string(p) for p in parts)

        ln = line_of(clean, lo)

        # 语句窗口：所在行 + 前后 6 行
        lines = clean.split("\n")
        w = lines[max(0, ln - 7): min(len(lines), ln + 6)]
        ctx = " ".join(w)

        # 最近的函数名
        func = ""
        for i in range(ln - 1, max(-1, ln - 400), -1):
            fm = FUNC_RE.match(lines[i]) if i < len(lines) else None
            if fm:
                func = fm.group(1)
                break

        cat = classify(ctx, value, func)
        rows.append({
            "file": fname,
            "line": ln,
            "text": value,
            "cat": cat,
            "func": func,
            "_end": hi,
        })

    for r in rows:
        r.pop("_end", None)
    return rows


def main():
    addon_dir = sys.argv[1]
    out_dir = sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)

    files = sorted(f for f in os.listdir(addon_dir) if f.endswith(".lua"))
    allrows = []
    for f in files:
        allrows.extend(extract(os.path.join(addon_dir, f), f))

    # 去重（同文本同分类合并，保留首次出现位置 + 全部出现位置）
    bycat = {}
    for r in allrows:
        bycat.setdefault(r["cat"], []).append(r)

    json.dump({"addon": addon_dir, "files": files, "rows": allrows},
              open(os.path.join(out_dir, "ui_strings.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    with open(os.path.join(out_dir, "ui_strings.txt"), "w", encoding="utf-8") as fh:
        for cat in ("UI", "DIAG", "SKIP"):
            rs = bycat.get(cat, [])
            # 按文本去重统计
            uniq = {}
            for r in rs:
                uniq.setdefault(r["text"], []).append(f'{r["file"]}:{r["line"]}')
            fh.write(f"\n{'='*78}\n{cat}  --  {len(rs)} 处，去重后 {len(uniq)} 条\n{'='*78}\n")
            for text in sorted(uniq, key=lambda t: (len(t), t)):
                locs = uniq[text]
                fh.write(f"\n--- {len(locs)} 处  {locs[0]}\n")
                fh.write(repr(text) + "\n")

    print(f"files={len(files)} total={len(allrows)}")
    for cat in ("UI", "DIAG", "SKIP"):
        rs = bycat.get(cat, [])
        uniq = len(set(r["text"] for r in rs))
        print(f"  {cat:5s}  {len(rs):5d} 处  {uniq:5d} 条去重")


if __name__ == "__main__":
    main()
