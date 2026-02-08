// ═══════════════════════════════════════════
// 800 Consulting Deck Boilerplate
// ═══════════════════════════════════════════
// このファイルをコピーし、// ═══ SLIDES ═══ 以降を案件内容に差し替えて使う。
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
// Component Helpers
// ═══════════════════════════════════════════

// --- Card (border + left accent bar, NO shadow) ---
function addCard(slide, x, y, w, h, accentColor) {
  accentColor = accentColor || C.accent;
  slide.addShape(pres.shapes.RECTANGLE, {
    x, y, w, h,
    fill: { color: C.cardBg },
    line: { color: C.lightGray, width: 0.5 }
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x, y, w: 0.06, h,
    fill: { color: accentColor }
  });
}

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

// --- Icon badge (circle bg + icon image) ---
async function addIconBadge(slide, icon, x, y, size, bgColor, iconColor) {
  slide.addShape(pres.shapes.OVAL, { x, y, w: size, h: size, fill: { color: bgColor } });
  const img = await iconToBase64Png(icon, "#" + iconColor);
  const pad = size * 0.25;
  slide.addImage({ data: img, x: x + pad / 2, y: y + pad / 2, w: size - pad, h: size - pad });
}

// --- Question card (for discussion slides) ---
async function addQuestionCard(slide, icon, x, y, w, h, question) {
  addCard(slide, x, y, w, h);
  const img = await iconToBase64Png(icon, "#" + C.accent);
  slide.addImage({ data: img, x: x + 0.18, y: y + h / 2 - 0.17, w: 0.34, h: 0.34 });
  slide.addText(question, {
    x: x + 0.65, y: y + 0.1, w: w - 0.85, h: h - 0.2,
    fontFace: FONT.body, fontSize: 12.5, color: C.text,
    valign: "middle", margin: 0
  });
}


// ═══════════════════════════════════════════
// SLIDES — ここから下を案件ごとに差し替える
// ═══════════════════════════════════════════
// 以下はサンプル。5スライドでヘルパー関数の使用例を網羅する。

pres.title = "サンプルデッキ";

async function build() {

  // --- Slide 1: Title ---
  addTitleSlide(
    "プロジェクト提案書",
    "AI活用による業務変革の方向性を提示する。",
    "想定時間：60分"
  );

  // --- Slide 2: Section ---
  addSectionSlide("SECTION 01", "現状分析", "業界動向と貴社の課題整理 — 15分");

  // --- Slide 3: 3-Column Cards ---
  {
    const s = addContentSlide("3つの重点課題");
    const items = [
      { icon: FaUsers,     title: "組織の属人化",     body: "経験豊富なメンバーの暗黙知が共有されず、組織としてのスケーラビリティに課題がある。", color: SUB.primary },
      { icon: FaChartLine,  title: "市場理解の型化",   body: "B2B特有の取引先固有性が強く、汎用的な分析フレームワークが機能しにくい。", color: SUB.secondary },
      { icon: FaHandshake,  title: "提案力の拡張",     body: "素材供給にとどまらず、製品開発全体への伴走型の関係構築を目指す。", color: SUB.quaternary },
    ];
    for (let i = 0; i < 3; i++) {
      const xBase = 0.7 + i * 3.0;
      addCard(s, xBase, 1.2, 2.8, 2.8, items[i].color);
      await addIconBadge(s, items[i].icon, xBase + 1.0, 1.4, 0.7, C.navy, C.white);
      s.addText(items[i].title, {
        x: xBase + 0.15, y: 2.3, w: 2.5, h: 0.4,
        fontFace: FONT.head, fontSize: 14, color: C.navy, bold: true, align: "center", margin: 0
      });
      s.addText(items[i].body, {
        x: xBase + 0.15, y: 2.75, w: 2.5, h: 1.1,
        fontFace: FONT.body, fontSize: 11, color: C.text, margin: 0
      });
    }
  }

  // --- Slide 4: 2x2 Grid ---
  {
    const s = addContentSlide("フレームワーク：4つの観点");
    const gridX = 0.7, gridY = 1.15, cellW = 4.2, cellH = 2.0, gap = 0.2;
    const quadrants = [
      { label: "A", title: "戦略的方向性",   body: "中長期の事業戦略と整合した施策の優先順位付けを行う。",                    color: SUB.primary },
      { label: "B", title: "組織ケイパビリティ", body: "実行に必要な組織能力とスキルギャップを特定し、育成計画を策定する。",      color: SUB.secondary },
      { label: "C", title: "テクノロジー活用",  body: "AI・データ基盤を活用した業務効率化と意思決定の高度化を推進する。",        color: SUB.tertiary },
      { label: "D", title: "実行とモニタリング", body: "KPI設計とPDCAサイクルにより、施策の効果を定量的に検証し改善を回す。", color: SUB.quaternary },
    ];
    for (let i = 0; i < 4; i++) {
      const col = i % 2, row = Math.floor(i / 2);
      const cx = gridX + col * (cellW + gap), cy = gridY + row * (cellH + gap);
      addCard(s, cx, cy, cellW, cellH, quadrants[i].color);
      // Label badge
      s.addShape(pres.shapes.OVAL, { x: cx + 0.15, y: cy + 0.15, w: 0.45, h: 0.45, fill: { color: quadrants[i].color } });
      s.addText(quadrants[i].label, {
        x: cx + 0.15, y: cy + 0.15, w: 0.45, h: 0.45,
        fontFace: FONT.head, fontSize: 18, color: C.white, bold: true, align: "center", valign: "middle", margin: 0
      });
      // Title
      s.addText(quadrants[i].title, {
        x: cx + 0.72, y: cy + 0.17, w: 3.2, h: 0.35,
        fontFace: FONT.head, fontSize: 13, color: C.navy, bold: true, margin: 0
      });
      // Body
      s.addText(quadrants[i].body, {
        x: cx + 0.15, y: cy + 0.7, w: 3.85, h: 1.15,
        fontFace: FONT.body, fontSize: 11, color: C.text, margin: 0
      });
    }
  }

  // --- Slide 5: Closing ---
  addClosingSlide("Thank You", "本日のディスカッションを踏まえ、\n具体的な支援テーマの方向性を固めていきたい。");

  await pres.writeFile({ fileName: "output.pptx" });
  console.log("Done! 5 sample slides created.");
}

build().catch(e => { console.error(e); process.exit(1); });
