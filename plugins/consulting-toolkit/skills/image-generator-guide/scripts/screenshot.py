#!/usr/bin/env python3
"""
HTML を高解像度 PNG に変換する Playwright スクリーンショットスクリプト。

依存:
    pip install playwright
    python -m playwright install chromium

使い方:
    python screenshot.py --html input.html --out output.png
    python screenshot.py --html input.html --out output.png --width 1440 --height 810 --scale 2
    python screenshot.py --html input.html --out output.png --selector .slide
"""

import argparse
import os
import sys

def main():
    parser = argparse.ArgumentParser(
        description="HTML を Playwright で高解像度 PNG に変換する"
    )
    parser.add_argument(
        "--html", required=True,
        help="入力 HTML ファイルのパス"
    )
    parser.add_argument(
        "--out", required=True,
        help="出力 PNG ファイルのパス"
    )
    parser.add_argument(
        "--width", type=int, default=1440,
        help="ビューポート幅 (デフォルト: 1440)"
    )
    parser.add_argument(
        "--height", type=int, default=810,
        help="ビューポート高さ (デフォルト: 810)"
    )
    parser.add_argument(
        "--scale", type=int, default=2,
        help="デバイスピクセル比 (デフォルト: 2、2倍解像度)"
    )
    parser.add_argument(
        "--selector", default=".slide",
        help="スクリーンショット対象の CSS セレクタ (デフォルト: .slide)"
    )
    parser.add_argument(
        "--wait", type=int, default=3000,
        help="レンダリング待機時間 ms (デフォルト: 3000)"
    )
    parser.add_argument(
        "--full-page", action="store_true",
        help="セレクタを無視してページ全体をキャプチャする"
    )

    args = parser.parse_args()

    # HTML ファイルの存在確認
    html_path = os.path.abspath(args.html)
    if not os.path.exists(html_path):
        print(f"エラー: HTML ファイルが見つかりません: {html_path}", file=sys.stderr)
        sys.exit(1)

    # 出力ディレクトリの作成
    out_path = os.path.abspath(args.out)
    out_dir = os.path.dirname(out_path)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print(
            "エラー: playwright がインストールされていません。\n"
            "  pip install playwright\n"
            "  python -m playwright install chromium",
            file=sys.stderr
        )
        sys.exit(1)

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(
            viewport={"width": args.width, "height": args.height},
            device_scale_factor=args.scale,
        )

        # file:// プロトコルで直接開く
        page.goto(f"file://{html_path}")
        page.wait_for_timeout(args.wait)

        if args.full_page:
            page.screenshot(path=out_path, full_page=True)
            actual_w = args.width * args.scale
            actual_h = "full"
        else:
            el = page.query_selector(args.selector)
            if el:
                el.screenshot(path=out_path)
                box = el.bounding_box()
                actual_w = int(box["width"] * args.scale) if box else "?"
                actual_h = int(box["height"] * args.scale) if box else "?"
            else:
                print(
                    f"警告: セレクタ '{args.selector}' が見つかりません。"
                    f"ビューポート全体をキャプチャします。",
                    file=sys.stderr
                )
                page.screenshot(path=out_path)
                actual_w = args.width * args.scale
                actual_h = args.height * args.scale

        browser.close()

    print(f"生成完了: {out_path}")
    print(f"  実寸: {actual_w} x {actual_h} px")
    print(f"  設定: viewport={args.width}x{args.height}, scale={args.scale}")


if __name__ == "__main__":
    main()
