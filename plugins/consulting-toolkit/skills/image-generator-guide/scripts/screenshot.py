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
        "--batch",
        help="バッチモード: manifest JSON ファイルのパス",
    )

    args = parser.parse_args()

    if args.batch:
        batch(args.batch)
    elif args.html and args.out:
        single(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
