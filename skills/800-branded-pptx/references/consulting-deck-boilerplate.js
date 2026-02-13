// ═══════════════════════════════════════════
// 800 Consulting Deck Boilerplate
// ═══════════════════════════════════════════
// pptxgenjs API詳細 → ../pptx/pptxgenjs.md
// QA手順 → ../pptx/SKILL.md

const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const sharp = require("sharp");

// ─── Icon imports (案件に応じて追加・削除) ───
const {
  FaUsers, FaChartLine, FaHandshake, FaBrain, FaRobot,
  FaLightbulb, FaCogs, FaArrowRight, FaComments, FaBookOpen,
  FaSearch, FaFileAlt, FaPencilAlt, FaMicrophone, FaClipboardList,
  FaChartBar, FaExchangeAlt, FaCheck, FaQuestionCircle,
  FaIndustry, FaCar, FaSync
} = require("react-icons/fa");

// ═══════════════════════════════════════════
// Design Tokens
// ═══════════════════════════════════════════

const C = {
  navy:      "1B3928",   // タイトル/セクション背景、コンテンツタイトル色
  navyLight: "244A33",   // ダーク背景のボトムストライプ
  contentBg: "FFFFFF",   // コンテンツスライド背景
  accent:    "29BA74",   // メインアクセント（左バー、上部ライン、強調）
  text:      "404040",   // 本文テキスト
  muted:     "A6A6A6",   // サブテキスト、フッター
  white:     "FFFFFF",
  lightGray: "E0E0E0",   // ボーダー、セパレーター
  cardBg:    "FFFFFF",   // カード背景
  tableBg:   "F0F8F4",   // テーブル交互行（薄ミント）
  tableHead: "1B3928",   // テーブルヘッダー
};

// サブカラー（カテゴリ・フェーズの色分け用）
const SUB = {
  primary:    "29BA74",  // ティール
  secondary:  "1789B1",  // ブルー
  tertiary:   "D6DF56",  // イエローグリーン（テキスト色には使わない）
  quaternary: "D84A6E",  // ローズ
};

const FONT = { head: "Meiryo UI", body: "Meiryo UI" };

// ═══════════════════════════════════════════
// Icon Renderer
// ═══════════════════════════════════════════

function renderIconSvg(IconComponent, color, size = 256) {
  return ReactDOMServer.renderToStaticMarkup(
    React.createElement(IconComponent, { color, size: String(size) })
  );
}
async function iconToBase64Png(IconComponent, color, size = 256) {
  const svg = renderIconSvg(IconComponent, color, size);
  const pngBuffer = await sharp(Buffer.from(svg)).png().toBuffer();
  return "image/png;base64," + pngBuffer.toString("base64");
}

// ═══════════════════════════════════════════
// Text Helper
// ═══════════════════════════════════════════

function splitTextWithFonts(text, baseOptions = {}) {
  const segments = [];
  const regex = /([A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)|([^A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)/g;
  let match;
  while ((match = regex.exec(text)) !== null) {
    if (match[1]) {
      segments.push({ text: match[1], options: { ...baseOptions, fontFace: "Century Gothic" } });
    } else if (match[2]) {
      segments.push({ text: match[2], options: { ...baseOptions, fontFace: "Meiryo UI" } });
    }
  }
  return segments;
}

// ═══════════════════════════════════════════
// Presentation Instance
// ═══════════════════════════════════════════

let pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "Eight Hundred Inc.";

// ═══════════════════════════════════════════
// Slide Structure Helpers
// ═══════════════════════════════════════════

// --- Section divider slide (dark bg) ---
function addSectionSlide(sectionNum, title, subtitle) {
  const s = pres.addSlide();
  s.background = { color: C.navy };
  // Top accent line
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.03, fill: { color: C.accent } });
  // Section number
  s.addText(sectionNum, { x: 0.8, y: 1.4, w: 2, h: 0.6, fontFace: FONT.head, fontSize: 16, color: C.accent, bold: true, margin: 0 });
  // Title
  s.addText(title, { x: 0.8, y: 1.95, w: 8.4, h: 1.2, fontFace: FONT.head, fontSize: 36, color: C.white, bold: true, margin: 0 });
  // Subtitle
  if (subtitle) {
    s.addText(subtitle, { x: 0.8, y: 3.2, w: 8, h: 0.8, fontFace: FONT.body, fontSize: 14, color: C.muted, margin: 0 });
  }
  // Logo
  s.addText("800", { x: 0.8, y: 4.8, w: 2, h: 0.4, fontFace: "Century Gothic", fontSize: 14, color: C.muted, margin: 0 });
  // Bottom stripe
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 5.425, w: 10, h: 0.2, fill: { color: C.navyLight } });
  return s;
}

// --- Content slide (white bg, nav bar, footer) ---
function addContentSlide(title) {
  const s = pres.addSlide();
  s.background = { color: C.contentBg };
  // Top nav bar
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.04, fill: { color: C.navy } });
  // Title
  s.addText(title, { x: 0.7, y: 0.3, w: 8.6, h: 0.55, fontFace: FONT.head, fontSize: 22, color: C.navy, bold: true, margin: 0 });
  // Separator
  s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y: 0.9, w: 8.6, h: 0.015, fill: { color: C.lightGray } });
  // Footer
  s.addText("© Eight Hundred Inc.", { x: 0.5, y: 5.2, w: 3, h: 0.3, fontFace: FONT.body, fontSize: 8, color: C.muted, margin: 0 });
  return s;
}

// --- Title slide (dark bg) ---
function addTitleSlide(mainTitle, subtitle, extraInfo) {
  const s = pres.addSlide();
  s.background = { color: C.navy };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.035, fill: { color: C.accent } });
  s.addText(mainTitle, { x: 0.8, y: 1.3, w: 8.4, h: 1.3, fontFace: FONT.head, fontSize: 40, color: C.white, bold: true, margin: 0 });
  if (subtitle) {
    s.addText(subtitle, { x: 0.8, y: 2.7, w: 8.4, h: 1, fontFace: FONT.body, fontSize: 15, color: C.muted, lineSpacingMultiple: 1.5, margin: 0 });
  }
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.85, w: 1.2, h: 0.025, fill: { color: C.accent } });
  if (extraInfo) {
    s.addText(extraInfo, { x: 0.8, y: 4.1, w: 3, h: 0.5, fontFace: FONT.body, fontSize: 13, color: C.muted, margin: 0 });
  }
  s.addText("800", { x: 0.8, y: 4.8, w: 2, h: 0.4, fontFace: "Century Gothic", fontSize: 16, color: C.white, margin: 0 });
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 5.425, w: 10, h: 0.2, fill: { color: C.navyLight } });
  return s;
}

// --- Closing slide (dark bg) ---
function addClosingSlide(heading, message) {
  const s = pres.addSlide();
  s.background = { color: C.navy };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.035, fill: { color: C.accent } });
  s.addText(heading || "Thank You", { x: 0.8, y: 1.6, w: 8.4, h: 1, fontFace: FONT.head, fontSize: 44, color: C.white, bold: true, margin: 0 });
  if (message) {
    s.addText(message, { x: 0.8, y: 2.7, w: 8.4, h: 1, fontFace: FONT.body, fontSize: 16, color: C.muted, lineSpacingMultiple: 1.5, margin: 0 });
  }
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 3.9, w: 1.2, h: 0.025, fill: { color: C.accent } });
  s.addText("800", { x: 0.8, y: 4.3, w: 2, h: 0.4, fontFace: "Century Gothic", fontSize: 16, color: C.white, margin: 0 });
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 5.425, w: 10, h: 0.2, fill: { color: C.navyLight } });
  return s;
}
