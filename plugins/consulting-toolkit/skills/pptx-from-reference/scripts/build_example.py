#!/usr/bin/env python3
"""build.py の雛形。作業ディレクトリにコピーして案件用に書き換えて使う。

    cp build_example.py <work>/build.py
    python3 build.py --md 入力.md --template ../reference-decks/foo.pptx \
                     --spec deck-spec.json --out 出力.pptx

そのまま実行しても動く（md の見出しからスライドを起こす最小実装）。
ただし **これは足場であって完成形ではない**。references/build-guide.md に従い、
参照デッキから採寸した座標・レイアウト名・配色に合わせて build_slides() を
案件ごとに書き換えること。
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deck_kit import *  # noqa: F401,F403


# --------------------------------------------------------------------------- md 取り込み
def parse_md(path: Path) -> dict:
    """md を「タイトル / セクション（##）/ 小見出し（###）+ 箇条書き」に分解する。"""
    doc = {"title": path.stem, "sections": []}
    section = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        m = re.match(r"^(#{1,4})\s+(.*)$", line)
        if m:
            level, text = len(m.group(1)), m.group(2).strip()
            if level == 1:
                doc["title"] = text
            else:
                section = {"level": level, "heading": text, "blocks": []}
                doc["sections"].append(section)
            continue
        if section is None:
            continue
        indent = len(raw) - len(raw.lstrip(" \t"))
        bullet = re.match(r"^[-*+]\s+(.*)$", line.strip())
        section["blocks"].append(
            {"level": min(indent // 4, 2), "text": strip_md(bullet.group(1) if bullet else line.strip()),
             "bullet": bool(bullet)}
        )
    return doc


def strip_md(text: str) -> str:
    text = re.sub(r"\*\*(.+?)\*\*", r"\1", text)
    text = re.sub(r"`(.+?)`", r"\1", text)
    text = re.sub(r"\[(.+?)\]\(.+?\)", r"\1", text)
    return text.strip()


# --------------------------------------------------------------------------- 作図
def build_slides(prs, doc: dict, st) -> None:
    """★ここを案件ごとに書き換える。以下は最小の足場実装。"""
    W, H = st.canvas
    M = 0.37                       # 左右マージン（参照デッキから採寸し直すこと）
    BODY_W = W - M * 2
    TITLE_LAYOUT = st.layouts[0]
    BODY_LAYOUT = st.layouts[-1]

    # --- 表紙
    s = add_slide(prs, TITLE_LAYOUT)
    try:
        set_placeholder(s, "CENTER_TITLE", doc["title"])
    except KeyError:
        add_text(s, doc["title"], M, H / 2 - 0.5, BODY_W, 1.0, size=32, bold=True,
                 color="FFFFFF", ea=st.ea, latin=st.latin)
    drop_empty_placeholders(s)

    # --- 本文
    for sec in doc["sections"]:
        chunks = chunk_blocks(sec["blocks"], per_slide=7)
        for i, chunk in enumerate(chunks or [[]]):
            s = add_slide(prs, BODY_LAYOUT)
            heading = sec["heading"] + ("（%d/%d）" % (i + 1, len(chunks)) if len(chunks) > 1 else "")
            try:
                set_placeholder(s, "TITLE", heading)
                top = 1.15
            except KeyError:
                add_text(s, heading, M, 0.35, BODY_W, 0.45, size=22, bold=True,
                         ea=st.ea, latin=st.latin)
                top = 1.0
            drop_empty_placeholders(s)
            if chunk:
                add_bullets(s, [(b["level"], b["text"]) for b in chunk],
                            M, top, BODY_W, H - top - 0.7, size=14,
                            ea=st.ea, latin=st.latin)


def chunk_blocks(blocks: list[dict], per_slide: int = 7) -> list[list[dict]]:
    """1 スライドに載せる行数で分割する（レベル 0 の直前で切る）。"""
    out, cur = [], []
    for b in blocks:
        if len(cur) >= per_slide and b["level"] == 0:
            out.append(cur)
            cur = []
        cur.append(b)
    if cur:
        out.append(cur)
    return out


# --------------------------------------------------------------------------- main
def main() -> int:
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--md", required=True, help="コンテンツ元の Markdown パス")
    ap.add_argument("--template", required=True, help="テンプレートに使う参照 pptx のパス")
    ap.add_argument("--spec", default="deck-spec.json", help="analyze_references.py の出力 JSON")
    ap.add_argument("--out", default="output.pptx")
    args = ap.parse_args()

    doc = parse_md(Path(args.md))
    spec = Path(args.spec)
    st = load_style(spec) if spec.is_file() else Style(
        canvas=(13.333, 7.5), latin="Century Gothic", ea="Meiryo UI",
        layouts=[], theme_colors={}, used_colors=[], sizes=[], file=None)
    prs = open_template(args.template)
    if not st.get("layouts"):
        st["layouts"] = list_layouts(prs)
        st["canvas"] = (round(prs.slide_width / 914400, 3), round(prs.slide_height / 914400, 3))

    build_slides(prs, doc, st)
    out = save(prs, args.out)
    print("OK: %d 枚 -> %s" % (len(prs.slides), out))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
