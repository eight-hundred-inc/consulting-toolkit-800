"""Shared chart utilities — brand palette + save helpers.

Copy this file to your project's figures/ directory and rename to chart_utils.py.
Adjust PRIMARY and font settings to match your project's brand.

See references/brand-palette-guide.md for palette customization.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import os

# ─── Brand palette ───────────────────────────────────────
# Change PRIMARY to your brand's accent color.
# GRAY/TEXT/MUTED/BORDER rarely need changing.
PRIMARY    = "#0052FF"
GRAY       = "#B0B0B0"
GRAY_LIGHT = "#D0D0D0"
GRAY_DARK  = "#707070"
TEXT       = "#404040"
MUTED      = "#595959"
BORDER     = "#D9D9D9"
WHITE      = "#FFFFFF"

# ─── Font settings ───────────────────────────────────────
# RENDER_FONT: system font used by matplotlib during rendering.
#   macOS: "Hiragino Sans"  |  Windows: "Meiryo UI"  |  Linux: "Noto Sans CJK JP"
# SVG_FONTS: font-family written into SVG for the delivery environment.
RENDER_FONT = "Hiragino Sans"
SVG_FONTS   = "'Meiryo UI', 'Century Gothic'"

# ─── Output directory ────────────────────────────────────
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ─── Global rcParams ─────────────────────────────────────
plt.rcParams.update({
    "font.family": RENDER_FONT,
    "font.size": 11,
    "axes.edgecolor": BORDER,
    "axes.linewidth": 0.5,
    "xtick.color": MUTED,
    "ytick.color": TEXT,
    "figure.facecolor": WHITE,
    "axes.facecolor": WHITE,
    "savefig.facecolor": WHITE,
})


def save(fig, name):
    """Save as PNG (300dpi) + SVG with font replacement."""
    png = os.path.join(OUT_DIR, f"{name}.png")
    svg = os.path.join(OUT_DIR, f"{name}.svg")
    fig.savefig(png, format="png", bbox_inches="tight", dpi=300)
    fig.savefig(svg, format="svg", bbox_inches="tight")
    plt.close(fig)

    with open(svg, "r") as f:
        content = f.read()
    content = content.replace(
        f"font-family:{RENDER_FONT}", f"font-family:{SVG_FONTS}"
    )
    content = content.replace(
        f"font-family: {RENDER_FONT}", f"font-family: {SVG_FONTS}"
    )
    with open(svg, "w") as f:
        f.write(content)
    print(f"  {name}.png / .svg")


def clean_spines(ax, left=False, bottom=True):
    """Remove top/right spines. Optionally keep left spine (for vertical bar charts)."""
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_visible(left)
    if bottom:
        ax.spines["bottom"].set_color(BORDER)
    else:
        ax.spines["bottom"].set_visible(False)


def add_vgrid(ax):
    """Vertical grid lines (for horizontal bar charts)."""
    ax.xaxis.grid(True, color=BORDER, linewidth=0.5, zorder=0)


def add_hgrid(ax):
    """Horizontal grid lines (for vertical bar charts)."""
    ax.yaxis.grid(True, color=BORDER, linewidth=0.5, zorder=0)


def comma_fmt(ax, axis="x"):
    """Thousands-comma formatting on axis tick labels."""
    fmt = ticker.FuncFormatter(lambda x, _: f"{int(x):,}")
    if axis == "x":
        ax.xaxis.set_major_formatter(fmt)
    else:
        ax.yaxis.set_major_formatter(fmt)
