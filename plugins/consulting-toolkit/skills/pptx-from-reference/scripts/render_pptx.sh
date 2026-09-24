#!/usr/bin/env bash
# pptx を PNG 化してビジュアル QA に使う。
#   ./render_pptx.sh deck.pptx [outdir] [dpi]
# 依存: LibreOffice (soffice) と poppler (pdftoppm)
set -euo pipefail

PPTX="${1:?usage: render_pptx.sh <deck.pptx> [outdir] [dpi]}"
OUTDIR="${2:-$(dirname "$PPTX")/render}"
DPI="${3:-110}"

command -v soffice >/dev/null || { echo "soffice が見つかりません (brew install --cask libreoffice)"; exit 1; }
command -v pdftoppm >/dev/null || { echo "pdftoppm が見つかりません (brew install poppler)"; exit 1; }

mkdir -p "$OUTDIR"
soffice --headless --norestore --convert-to pdf --outdir "$OUTDIR" "$PPTX" >/dev/null
PDF="$OUTDIR/$(basename "${PPTX%.*}").pdf"
[ -f "$PDF" ] || { echo "PDF 変換に失敗しました: $PDF"; exit 1; }
pdftoppm -png -r "$DPI" "$PDF" "$OUTDIR/slide"
echo "OK: $(ls "$OUTDIR"/slide-*.png 2>/dev/null | wc -l | tr -d ' ') 枚を $OUTDIR に出力"
ls "$OUTDIR"/slide-*.png
