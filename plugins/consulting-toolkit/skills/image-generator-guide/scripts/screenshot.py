#!/usr/bin/env python3
"""
HTML を高解像度 PNG に変換する Playwright スクリーンショットスクリプト。
headless で実行し、指定セレクタの要素だけをクロップしてキャプチャする。

依存:
    pip install playwright
    python -m playwright install chromium

使い方（単体）:
    python screenshot.py --html input.html --out output.png
    python screenshot.py --html input.html --out output.png --width 960 --scale 2
    python screenshot.py --html input.html --out output.png --selector .slide

使い方（バッチ）:
    python screenshot.py --batch manifest.json

    manifest.json の形式:
    [
      {"html": "file1.html", "png": "file1.png", "width": 1200},
      {"html": "file2.html", "png": "file2.png", "width": 960}
    ]

使い方（PDF・レイアウト検証向け）:
    python screenshot.py --html input.html --pdf output.pdf

    print CSS を適用して PDF 化する。縦長文書は複数ページに、
    スライドデッキ（@media print で全スライドが展開される）は
    1 スライド 1 ページで出力される。レンダリング検証で
    デッキ全体・縦長文書全体を 1 ファイルで確認する用途に使う。
"""

import argparse
import json
import os
import sys
from pathlib import Path


def _take_screenshot(page, html_path, out_path, selector, scale):
    """1ページ分のスクリーンショットを撮影する。"""
    abs_html = str(Path(html_path).resolve())
    abs_out = str(Path(out_path).resolve())

    # 出力ディレクトリ作成
    out_dir = os.path.dirname(abs_out)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    page.goto(f"file://{abs_html}")
    page.wait_for_load_state("networkidle")

    el = page.query_selector(selector)
    if el:
        el.screenshot(path=abs_out)
        box = el.bounding_box()
        w = int(box["width"] * scale) if box else "?"
        h = int(box["height"] * scale) if box else "?"
    else:
        print(
            f"  警告: セレクタ '{selector}' が見つかりません。"
            f"ページ全体をキャプチャします。",
            file=sys.stderr,
        )
        page.screenshot(path=abs_out, full_page=True)
        w, h = "full", "full"

    print(f"  {Path(out_path).name} ({w}x{h}px)")


def single(args):
    """単体モード: 1つの HTML → PNG 変換。"""
    html_path = args.html
    if not os.path.exists(html_path):
        print(f"エラー: HTML ファイルが見つかりません: {html_path}", file=sys.stderr)
        sys.exit(1)

    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": args.width, "height": 800},
            device_scale_factor=args.scale,
        )
        _take_screenshot(page, html_path, args.out, args.selector, args.scale)
        browser.close()


def to_pdf(args):
    """PDF モード: print CSS を適用して 1 HTML → PDF 変換。

    レイアウト検証向け。スライドデッキは @media print により全スライドが
    展開され 1 スライド 1 ページ（@page で 1280x720）になる。縦長文書は
    print のページ送りで複数ページに分割される。背景色（クリーム紙・
    アクセント帯）を保つため print_background=True で描画する。
    """
    html_path = args.html
    if not os.path.exists(html_path):
        print(f"エラー: HTML ファイルが見つかりません: {html_path}", file=sys.stderr)
        sys.exit(1)

    abs_html = str(Path(html_path).resolve())
    abs_out = str(Path(args.pdf).resolve())
    out_dir = os.path.dirname(abs_out)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": args.width, "height": 800})
        page.goto(f"file://{abs_html}")
        page.wait_for_load_state("networkidle")
        # page.pdf() は既定で print メディアを使う。@page{size} を尊重させ、
        # 背景（配色トークン）も描画する。
        page.pdf(
            path=abs_out,
            print_background=True,
            prefer_css_page_size=True,
        )
        browser.close()

    print(f"  {Path(args.pdf).name} (PDF)")


def batch(manifest_path):
    """バッチモード: manifest.json に定義された複数ファイルを一括変換。"""
    with open(manifest_path) as f:
        items = json.load(f)

    # manifest の親ディレクトリを基準にする（/dev/stdin の場合は cwd）
    base = Path(manifest_path).parent
    if str(base) == "/dev":
        base = Path.cwd()

    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for item in items:
            html = str(base / item["html"])
            png = str(base / item["png"])
            width = item.get("width", 1200)
            scale = item.get("scale", 2)
            selector = item.get("selector", "body")

            page = browser.new_page(
                viewport={"width": width, "height": 800},
                device_scale_factor=scale,
            )
            _take_screenshot(page, html, png, selector, scale)
            page.close()
        browser.close()


def main():
    parser = argparse.ArgumentParser(
        description="HTML を Playwright (headless) で高解像度 PNG に変換する"
    )
    parser.add_argument(
        "--html",
        help="入力 HTML ファイルのパス（単体モード）",
    )
    parser.add_argument(
        "--out",
        help="出力 PNG ファイルのパス（単体モード）",
    )
    parser.add_argument(
        "--width",
        type=int,
        default=1200,
        help="ビューポート幅 (デフォルト: 1200)",
    )
    parser.add_argument(
        "--scale",
        type=int,
        default=2,
        help="デバイスピクセル比 (デフォルト: 2、2倍解像度)",
    )
    parser.add_argument(
        "--selector",
        default="body",
        help="スクリーンショット対象の CSS セレクタ (デフォルト: body)",
    )
    parser.add_argument(
        "--pdf",
        help="PDF モード: print CSS 適用で --html を PDF に変換する出力パス（レイアウト検証向け）",
    )
    parser.add_argument(
        "--batch",
        help="バッチモード: manifest JSON ファイルのパス",
    )

    args = parser.parse_args()

    if args.batch:
        batch(args.batch)
    elif args.html and args.pdf:
        to_pdf(args)
    elif args.html and args.out:
        single(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
