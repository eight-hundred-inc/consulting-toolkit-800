// ═══════════════════════════════════════════
// 800 Consulting Deck Boilerplate
// ═══════════════════════════════════════════
// 座標・サイズは実PPTXスライドマスター／レイアウトから忠実に採寸
// pptxgenjs API詳細 → pptxスキルの pptxgenjs.md
// QA手順 → pptxスキルの SKILL.md

const pptxgen = require("pptxgenjs");
const path = require("path");
const fs = require("fs");

// ═══════════════════════════════════════════
// Design Tokens
// ═══════════════════════════════════════════

const C = {
  navy:         "1B3928",   // タイトル/セクション背景、コンテンツタイトル色
  navyLight:    "244A33",   // ダーク背景のボトムストライプ
  contentBg:    "FFFFFF",   // コンテンツスライド背景
  accent:       "29BA74",   // メインアクセント（強調テキスト、マーカー）
  text:         "404040",   // 本文テキスト（ダークグレー）— 標準テキスト色
  textDark:     "333333",   // より濃いテキスト（見出し等で必要な場合）
  muted:        "A6A6A6",   // サブテキスト、フッター、非アクティブ
  white:        "FFFFFF",
  separator:    "404040",   // 見出し下セパレーターライン（ダークグレー）
  border:       "D9D9D9",   // テーブルボーダー、セクション区切り線
  lightGray:    "E0E0E0",   // タイトル下セパレーター
  grayBg:       "F2F2F2",   // 薄いグレー背景
  tableBg:      "F0F8F4",   // テーブル交互行（薄ミント）
  lightGreenBg: "E8F5E9",   // 薄いグリーン背景
};

// サブカラー（カテゴリ・フェーズの色分け用）
const SUB = {
  primary:    "29BA74",  // グリーン
  secondary:  "1789B1",  // ブルー
  tertiary:   "D6DF56",  // イエローグリーン（テキスト色には使わない）
  quaternary: "D84A6E",  // ローズ
};

const FONT = {
  latin: "Century Gothic",   // 英数字フォント
  ea:    "Meiryo UI",        // 日本語フォント
  head:  "Meiryo UI",        // 見出し
  body:  "Meiryo UI",        // 本文
};

// ═══════════════════════════════════════════
// Font Size Table (column-responsive)
// ═══════════════════════════════════════════

const FONT_SIZE = {
  kpi:     [48, 40, 36, 30, 24],   // [1列, 2列, 3列, 4列, 5列以上]
  kpiUnit: [18, 16, 14, 12, 11],
  title:   [28, 24, 22, 20, 18],
  subtitle:[20, 18, 16, 14, 13],
  body:    [16, 14, 13, 12, 11],
  caption: [12, 11, 10, 10,  9],
  badge:   [12, 11, 10, 10,  9],
};

function fontSize(category, columns) {
  const idx = Math.min(Math.max(columns - 1, 0), 4);
  return FONT_SIZE[category][idx];
}

// ═══════════════════════════════════════════
// Layout Constants (from PPTX slide master)
// ═══════════════════════════════════════════

const L = {
  margin:        0.28,

  // Content slide positions (from slideLayout3 "Title, Sub-Title and Content")
  sectionLabelX: 0.28,
  sectionLabelY: 0.08,
  sectionLabelW: 6.50,
  sectionLabelH: 0.29,
  titleX:        0.28,
  titleY:        0.39,
  titleW:        9.45,
  titleH:        0.42,
  sepX:          0.28,
  sepY:          0.84,
  sepW:          9.45,
  keyMsgX:       0.28,
  keyMsgY:       0.90,
  keyMsgW:       9.45,
  keyMsgH:       0.25,
  contentX:      0.28,
  contentY:      1.20,
  contentW:      9.45,
  contentH:      3.90,
  footerX:       0.28,
  footerY:       5.25,
  pageNumX:      9.20,
  pageNumY:      5.25,
  pageNumW:      0.50,
  pageNumH:      0.30,

  // Title slide positions (from slideLayout1 "4_タイトル")
  titleSlide: {
    recipientX:  0.49,
    recipientY:  0.38,
    recipientSz: 16,
    titleY:      1.93,
    titleW:      8.86,
    titleH:      1.77,
    titleSize:   36,
    subtitleSz:  14,
    logoGroupX:  0.49,
    logoGroupY:  4.43,
    logoBgW:     0.97,
    logoBgH:     0.33,
    logoImgW:    0.59,
    logoImgH:    0.18,
    footerY:     5.43,
  },

  // Section / Closing slide positions
  section: {
    sectionNumY: 1.4,
    titleY:      1.95,
    subtitleY:   3.2,
    logoY:       4.43,
    stripeY:     5.425,
    stripeH:     0.2,
  },

  // Agenda slide positions (from actual slides)
  agenda: {
    topLineX:    2.17,
    topLineY:    1.28,
    topLineW:    5.65,
    itemsX:      2.21,
    itemsStartY: 1.62,
    bottomLineX: 2.17,
    bottomLineY: 4.63,
    bottomLineW: 5.65,
  },
};

// ═══════════════════════════════════════════
// Logo Helper
// ═══════════════════════════════════════════

function findAsset(filename) {
  const candidates = [
    path.join(__dirname, filename),
    path.join(__dirname, "..", "assets", filename),
    path.join(process.cwd(), filename),
    path.join(process.cwd(), "assets", filename),
  ];
  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  return null;
}

function getLogoPath()      { return findAsset("800-logo.png"); }
function getLogoWhitePath() { return findAsset("800-logo-white.png"); }

// ═══════════════════════════════════════════
// Text Helper
// ═══════════════════════════════════════════

function splitTextWithFonts(text, baseOptions = {}) {
  const segments = [];
  const regex = /([A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)|([^A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)/g;
  let match;
  while ((match = regex.exec(text)) !== null) {
    if (match[1]) {
      segments.push({ text: match[1], options: { ...baseOptions, fontFace: FONT.latin } });
    } else if (match[2]) {
      segments.push({ text: match[2], options: { ...baseOptions, fontFace: FONT.ea } });
    }
  }
  return segments;
}

// ═══════════════════════════════════════════
// Presentation Instance
// ═══════════════════════════════════════════

let pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "Eight Hundred, Inc.";

// ═══════════════════════════════════════════
// Dark Slide Logo Helper (white bg rect + dark logo)
// ═══════════════════════════════════════════

function addDarkSlideLogo(s, y) {
  const TT = L.titleSlide;
  const logoPath = getLogoPath();
  if (!logoPath) return;

  // White semi-transparent background rectangle
  s.addShape(pres.shapes.RECTANGLE, {
    x: TT.logoGroupX, y: y, w: TT.logoBgW, h: TT.logoBgH,
    fill: { color: C.white }, rectRadius: 0.02,
  });
  // Logo image centered within
  const imgX = TT.logoGroupX + (TT.logoBgW - TT.logoImgW) / 2;
  const imgY = y + (TT.logoBgH - TT.logoImgH) / 2;
  s.addImage({ path: logoPath, x: imgX, y: imgY, w: TT.logoImgW, h: TT.logoImgH });
}

// ═══════════════════════════════════════════
// Slide Structure Helpers
// ═══════════════════════════════════════════

// --- Title slide (dark green bg) ---
function addTitleSlide(mainTitle, subtitle, extraInfo) {
  const s = pres.addSlide();
  const T = L.titleSlide;
  s.background = { color: C.navy };

  // Title — dynamic height based on line count
  // 36pt + lineSpacing 1.3 → ~0.65" per visual line
  // splitTextWithFonts can cause extra wrapping beyond \n count, so add +1 line buffer
  const titleLines = (mainTitle || "").split("\n").length;
  const estimatedVisualLines = titleLines + 1; // buffer for font segmentation wrapping
  const titleBoxH = Math.max(T.titleH, estimatedVisualLines * 0.65 + 0.2);

  s.addText(splitTextWithFonts(mainTitle, { fontSize: T.titleSize, color: C.white }), {
    x: T.recipientX, y: T.titleY, w: T.titleW, h: titleBoxH,
    fontFace: FONT.head, fontSize: T.titleSize, color: C.white,
    lineSpacingMultiple: 1.3, margin: 0, valign: "top"
  });

  // Subtitle / date (below title, with minimum Y to prevent overlap)
  // splitTextWithFonts can cause extra visual wrapping beyond \n count,
  // so use a generous minimum Y (from XML subtitle placeholder position)
  const subtitleY = Math.max(T.titleY + titleBoxH + 0.20, 4.05);
  if (subtitle) {
    s.addText(subtitle, {
      x: T.recipientX, y: subtitleY, w: T.titleW, h: 0.40,
      fontFace: FONT.latin, fontSize: T.subtitleSz, color: C.muted, margin: 0
    });
  }

  // Extra info (e.g., meeting name)
  if (extraInfo) {
    s.addText(extraInfo, {
      x: T.recipientX, y: subtitleY + 0.50, w: T.titleW, h: 0.40,
      fontFace: FONT.body, fontSize: 13, color: C.muted, margin: 0
    });
  }

  // Logo (dark logo on white bg, below subtitle/date)
  const logoY = subtitle ? subtitleY + 0.45 : T.logoGroupY;
  addDarkSlideLogo(s, Math.min(logoY, 5.05));

  // Footer
  s.addText("© Eight Hundred, Inc.", {
    x: L.footerX, y: L.footerY, w: 4, h: 0.3,
    fontFace: FONT.body, fontSize: 8, color: C.muted, margin: 0
  });

  return s;
}

// --- Content slide (white bg) ---
function addContentSlide(title, keyMessage, pageNum) {
  const s = pres.addSlide();
  s.background = { color: C.contentBg };

  // Title — 22pt, bold, dark green
  s.addText(splitTextWithFonts(title, { fontSize: 22, color: C.navy, bold: true }), {
    x: L.titleX, y: L.titleY, w: L.titleW, h: L.titleH,
    fontFace: FONT.head, fontSize: 22, color: C.navy, bold: true, margin: 0
  });

  // Separator (light gray thin rectangle)
  s.addShape(pres.shapes.RECTANGLE, {
    x: L.sepX, y: L.sepY, w: L.sepW, h: 0.015,
    fill: { color: C.lightGray }
  });

  // Key message (subtitle below separator)
  if (keyMessage) {
    s.addText(splitTextWithFonts(keyMessage, { fontSize: 12, color: C.text }), {
      x: L.keyMsgX, y: L.keyMsgY, w: L.keyMsgW, h: L.keyMsgH,
      fontFace: FONT.body, fontSize: 12, color: C.text,
      lineSpacingMultiple: 1.3, margin: 0
    });
  }

  // Footer
  s.addText("© Eight Hundred, Inc.", {
    x: L.footerX, y: L.footerY, w: 4, h: 0.3,
    fontFace: FONT.body, fontSize: 8, color: C.muted, margin: 0
  });

  // Page number
  if (pageNum !== undefined) {
    s.addText(String(pageNum), {
      x: L.pageNumX, y: L.pageNumY, w: L.pageNumW, h: L.pageNumH,
      fontFace: FONT.latin, fontSize: 12, color: C.muted,
      align: "right", margin: 0
    });
  }

  return s;
}

// --- Section divider slide (dark green bg) ---
function addSectionSlide(sectionNum, title, subtitle) {
  const s = pres.addSlide();
  const T = L.section;
  s.background = { color: C.navy };

  // Section number
  s.addText(sectionNum, {
    x: 0.8, y: T.sectionNumY, w: 2, h: 0.6,
    fontFace: FONT.head, fontSize: 16, color: C.accent, bold: true, margin: 0
  });

  // Title
  s.addText(title, {
    x: 0.8, y: T.titleY, w: 8.4, h: 1.2,
    fontFace: FONT.head, fontSize: 36, color: C.white, bold: true, margin: 0
  });

  // Subtitle
  if (subtitle) {
    s.addText(subtitle, {
      x: 0.8, y: T.subtitleY, w: 8, h: 0.8,
      fontFace: FONT.body, fontSize: 14, color: C.muted, margin: 0
    });
  }

  // Logo
  addDarkSlideLogo(s, T.logoY);

  // Bottom stripe
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: T.stripeY, w: 10, h: T.stripeH,
    fill: { color: C.navyLight }
  });

  return s;
}

// --- Agenda slide (white bg, numbered list with active highlight) ---
function addAgendaSlide(items, activeIndex, pageNum) {
  const A = L.agenda;
  const s = addContentSlide("アジェンダ", null, pageNum);

  // Top separator line
  s.addShape(pres.shapes.LINE, {
    x: A.topLineX, y: A.topLineY, w: A.topLineW, h: 0,
    line: { color: C.text, width: 2.0 }
  });

  // Agenda items
  const itemHeight = (A.bottomLineY - A.itemsStartY) / Math.max(items.length, 1);
  items.forEach((item, i) => {
    const isActive = (i === activeIndex);
    const yPos = A.itemsStartY + i * itemHeight;

    // Number
    s.addText(`${i + 1}.`, {
      x: A.itemsX, y: yPos, w: 0.5, h: itemHeight,
      fontFace: FONT.latin, fontSize: 20,
      color: isActive ? C.text : C.muted,
      bold: isActive, margin: 0, valign: "top"
    });

    // Text
    s.addText(splitTextWithFonts(item, {
      fontSize: 20,
      color: isActive ? C.text : C.muted,
      bold: isActive
    }), {
      x: A.itemsX + 0.6, y: yPos, w: 5, h: itemHeight,
      fontFace: FONT.head, fontSize: 20,
      color: isActive ? C.text : C.muted,
      bold: isActive, margin: 0, valign: "top"
    });
  });

  // Bottom separator line
  s.addShape(pres.shapes.LINE, {
    x: A.bottomLineX, y: A.bottomLineY, w: A.bottomLineW, h: 0,
    line: { color: C.text, width: 2.0 }
  });

  return s;
}

// --- Closing slide (dark green bg) ---
function addClosingSlide(heading, message) {
  const s = pres.addSlide();
  const T = L.section;
  s.background = { color: C.navy };

  s.addText(heading || "Thank You", {
    x: 0.8, y: 1.6, w: 8.4, h: 1,
    fontFace: FONT.head, fontSize: 44, color: C.white, bold: true, margin: 0
  });

  if (message) {
    s.addText(message, {
      x: 0.8, y: 2.7, w: 8.4, h: 1,
      fontFace: FONT.body, fontSize: 16, color: C.muted,
      lineSpacingMultiple: 1.5, margin: 0
    });
  }

  // Logo
  addDarkSlideLogo(s, T.logoY);

  // Bottom stripe
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: T.stripeY, w: 10, h: T.stripeH,
    fill: { color: C.navyLight }
  });

  // Footer
  s.addText("© Eight Hundred, Inc.", {
    x: L.footerX, y: L.titleSlide.footerY, w: 4, h: 0.3,
    fontFace: FONT.body, fontSize: 8, color: C.muted, margin: 0
  });

  return s;
}

// --- E.O.F slide (white bg, centered "E.O.F") ---
function addEofSlide(pageNum) {
  const s = pres.addSlide();
  s.background = { color: C.contentBg };

  s.addText("E.O.F", {
    x: 0, y: 2.0, w: 10, h: 1.5,
    fontFace: FONT.latin, fontSize: 24, color: C.muted,
    align: "center", valign: "middle", margin: 0
  });

  // Footer
  s.addText("© Eight Hundred, Inc.", {
    x: L.footerX, y: L.footerY, w: 4, h: 0.3,
    fontFace: FONT.body, fontSize: 8, color: C.muted, margin: 0
  });

  // Page number
  if (pageNum !== undefined) {
    s.addText(String(pageNum), {
      x: L.pageNumX, y: L.pageNumY, w: L.pageNumW, h: L.pageNumH,
      fontFace: FONT.latin, fontSize: 12, color: C.muted,
      align: "right", margin: 0
    });
  }

  return s;
}

// ═══════════════════════════════════════════
// Utility: Bullet Item (splitTextWithFonts + bullet safe)
// ═══════════════════════════════════════════

function bulletItem(text, opts = {}) {
  const segs = splitTextWithFonts(text, {
    fontSize: opts.fontSize || 12,
    color: opts.color || C.text,
    bold: opts.bold || false,
    italic: opts.italic || false,
  });
  if (segs.length > 0) {
    segs[0].options.bullet = true;
    segs[0].options.breakLine = false;
  }
  if (segs.length > 0) {
    segs[segs.length - 1].options.breakLine = true;
  }
  return segs;
}

// ═══════════════════════════════════════════
// Utility: Section Label (small gray text at top of content slides)
// ═══════════════════════════════════════════

function addSectionLabel(slide, text) {
  slide.addText(text, {
    x: L.sectionLabelX, y: L.sectionLabelY, w: L.sectionLabelW, h: L.sectionLabelH,
    fontFace: FONT.ea, fontSize: 12, color: C.muted, margin: 0, valign: "bottom"
  });
}

// ═══════════════════════════════════════════
// Utility: Label with Underline (heading + dark gray line)
// ═══════════════════════════════════════════

function addLabel(slide, text, x, y, w, opts = {}) {
  slide.addText(text, {
    x, y, w, h: 0.28,
    fontFace: opts.fontFace || FONT.ea,
    fontSize: opts.fontSize || 12,
    color: opts.color || C.text,
    bold: true, margin: 0,
  });
  slide.addShape(pres.shapes.LINE, {
    x, y: y + 0.3, w, h: 0,
    line: { color: C.separator, width: 0.5 }
  });
}

// ═══════════════════════════════════════════
// Utility: Section Header Bar (accent bg + white text)
// ═══════════════════════════════════════════

function addSectionHeader(slide, text, x, y, w) {
  slide.addShape(pres.shapes.RECTANGLE, {
    x, y, w, h: 0.35,
    fill: { color: C.accent }
  });
  slide.addText(splitTextWithFonts(text, { fontSize: 12, color: C.white, bold: true }), {
    x, y, w, h: 0.35,
    fontFace: FONT.head, fontSize: 12, color: C.white,
    bold: true, align: "center", valign: "middle", margin: 0
  });
}

// ═══════════════════════════════════════════
// Utility: Category Marker (accent circle + label)
// ═══════════════════════════════════════════

function addCategoryMarker(slide, label, x, y) {
  slide.addShape(pres.shapes.OVAL, {
    x, y, w: 0.35, h: 0.35,
    fill: { color: C.accent }
  });
  slide.addText(label, {
    x, y, w: 0.35, h: 0.35,
    fontFace: FONT.latin, fontSize: 14, color: C.white,
    bold: true, align: "center", valign: "middle", margin: 0
  });
}

// ═══════════════════════════════════════════
// Utility: Two-Column Layout with Accent Divider
// ═══════════════════════════════════════════

function addTwoColumnDivider(slide, y, h) {
  slide.addShape(pres.shapes.LINE, {
    x: 5.0, y, w: 0, h,
    line: { color: C.separator, width: 1.0 }
  });
}

// ═══════════════════════════════════════════
// Exports
// ═══════════════════════════════════════════

module.exports = {
  pres, C, SUB, FONT, FONT_SIZE, L,
  fontSize, splitTextWithFonts,
  addTitleSlide, addContentSlide, addSectionSlide,
  addAgendaSlide, addClosingSlide, addEofSlide,
  bulletItem, addSectionLabel, addLabel, addSectionHeader,
  addCategoryMarker, addTwoColumnDivider,
  findAsset, getLogoPath, getLogoWhitePath,
};
