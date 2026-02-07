# 800 Slide Layout Patterns

スライドレイアウトパターンの詳細仕様。カテゴリ別に整理。

## カラー定数

```javascript
const COLORS = {
  // プライマリ
  teal: "29BA74",            // メインアクセント、ボタン、強調
  darkGreen: "1B3928",       // タイトル・セクション開始背景のみ
  
  // 背景
  white: "FFFFFF",
  lightMint: "E8F5F0",       // セクション終了・まとめ背景
  lightGray: "F5F5F5",       // カード背景
  
  // テキスト
  dark: "404040",            // 本文
  gray: "A6A6A6",            // サブテキスト
  
  // ボーダー
  border: "E0E0E0"
};

const FONTS = {
  ja: "Meiryo UI",
  en: "Century Gothic"
};
```

## テキスト分割ヘルパー関数

同一テキストブロック内で英数字と日本語のフォントを使い分けるための必須関数。

```javascript
/**
 * テキストを英数字/日本語で分割し、適切なフォントを適用
 * @param {string} text - 分割するテキスト
 * @param {object} baseOptions - 共通オプション（bold, italic等）
 * @returns {array} pptxgenjs用のテキスト配列
 */
function splitTextWithFonts(text, baseOptions = {}) {
  const segments = [];
  const regex = /([A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)|([^A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)/g;
  let match;
  
  while ((match = regex.exec(text)) !== null) {
    if (match[1]) {
      // 英数字・記号 → Century Gothic
      segments.push({
        text: match[1],
        options: { ...baseOptions, fontFace: "Century Gothic" }
      });
    } else if (match[2]) {
      // 日本語 → Meiryo UI
      segments.push({
        text: match[2],
        options: { ...baseOptions, fontFace: "Meiryo UI" }
      });
    }
  }
  return segments;
}

// 使用例
slide.addText(
  splitTextWithFonts("AI導入で売上30%向上"),
  { x: 0.5, y: 1.0, w: 9, h: 0.6, fontSize: 24, color: "404040" }
);
```

---

## A. タイトル・セクション系

### 1. タイトルスライド

ダークグリーン背景のメインタイトル。

```javascript
function createTitleSlide(pres, title, subtitle, company) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // メインタイトル（混在テキストはsplitTextWithFontsを使用）
  slide.addText(
    splitTextWithFonts(title, { color: "FFFFFF" }),
    { x: 0.5, y: 2.0, w: 9, h: 1.2, fontSize: 32 }
  );
  
  // サブタイトル
  if (subtitle) {
    slide.addText(
      splitTextWithFonts(subtitle, { color: "FFFFFF" }),
      { x: 0.5, y: 3.3, w: 9, h: 0.5, fontSize: 16 }
    );
  }
  
  // 会社名・発表者（下部）
  if (company) {
    slide.addText(
      splitTextWithFonts(company, { color: "FFFFFF", italic: true }),
      { x: 0.5, y: 4.5, w: 9, h: 0.4, fontSize: 12 }
    );
  }
  
  // ロゴ（英数字のみなのでCentury Gothic直接指定）
  slide.addText("≠800", {
    x: 0.5, y: 5.0, w: 1.5, h: 0.4,
    fontSize: 14, fontFace: "Century Gothic",
    color: "FFFFFF"
  });
  
  return slide;
}
```

### 2. セクション開始スライド

新しい章の始まりを印象づける。

```javascript
function createSectionStartSlide(pres, sectionNum, sectionTitle, description) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // セクション番号+タイトル
  slide.addText(`第${sectionNum}章 ${sectionTitle}`, {
    x: 0.5, y: 1.8, w: 9, h: 0.8,
    fontSize: 28, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  // 説明文
  if (description) {
    slide.addText(description, {
      x: 0.5, y: 2.8, w: 9, h: 0.6,
      fontSize: 14, fontFace: "Meiryo UI",
      color: "FFFFFF"
    });
  }
  
  // 下部に薄いライン
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 3.6, w: 4, h: 0.02,
    fill: { color: "FFFFFF", transparency: 50 }
  });
  
  return slide;
}
```

### 3. セクション終了・まとめスライド

ライトミント背景で要点を整理。

```javascript
function createSectionSummarySlide(pres, title, points, note) {
  let slide = pres.addSlide();
  slide.background = { color: "E8F5F0" };
  
  // タイトル
  slide.addText(title, {
    x: 0.5, y: 0.5, w: 9, h: 0.6,
    fontSize: 20, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  // まとめポイント（番号付き）
  const pointTexts = points.map((p, i) => ({
    text: `${i + 1}. ${p}`,
    options: { breakLine: true, paraSpaceBefore: 8 }
  }));
  
  slide.addText(pointTexts, {
    x: 0.5, y: 1.3, w: 9, h: 3,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "404040"
  });
  
  // 補足説明（下部）
  if (note) {
    slide.addText(note, {
      x: 0.5, y: 4.5, w: 9, h: 0.5,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "A6A6A6", italic: true
    });
  }
  
  return slide;
}
```

### 4. 目次スライド

講演全体の構成を示す。

```javascript
function createTocSlide(pres, chapters) {
  let slide = pres.addSlide();
  slide.background = { color: "FFFFFF" };
  
  // タイトル
  slide.addText("目次スライド", {
    x: 0.4, y: 0.3, w: 3, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText("講演全体の構成を示す", {
    x: 0.4, y: 0.7, w: 5, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6"
  });
  
  // 章カード（横並び）
  const cardWidth = 2.8;
  const gap = 0.3;
  const startX = 0.5;
  
  chapters.forEach((ch, i) => {
    const x = startX + i * (cardWidth + gap);
    
    // カード背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: cardWidth, h: 2.5,
      fill: { color: "F5F5F5" },
      line: { color: "E0E0E0", width: 0.5 }
    });
    
    // 章番号
    slide.addText(`第${i + 1}章`, {
      x: x + 0.15, y: 1.6, w: cardWidth - 0.3, h: 0.35,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "29BA74", bold: true
    });
    
    // 章タイトル
    slide.addText(ch.title, {
      x: x + 0.15, y: 2.0, w: cardWidth - 0.3, h: 0.4,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(ch.description || "", {
      x: x + 0.15, y: 2.5, w: cardWidth - 0.3, h: 1.3,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  return slide;
}
```

### 5. クロージングスライド

感謝と連絡先を伝える。

```javascript
function createClosingSlide(pres, message, contactInfo) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // タイトル
  slide.addText("クロージングスライド", {
    x: 0.5, y: 0.8, w: 9, h: 0.5,
    fontSize: 18, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  slide.addText("感謝と連絡先を伝える", {
    x: 0.5, y: 1.3, w: 9, h: 0.3,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // メインメッセージ（中央）
  slide.addText(message || "ご清聴ありがとうございました", {
    x: 0.5, y: 2.5, w: 9, h: 0.6,
    fontSize: 24, fontFace: "Meiryo UI",
    color: "FFFFFF", align: "center"
  });
  
  // 連絡先
  if (contactInfo) {
    slide.addText(contactInfo, {
      x: 0.5, y: 3.5, w: 9, h: 0.8,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "FFFFFF", align: "center"
    });
  }
  
  return slide;
}
```

---

## B. カラムレイアウト系

### 6. 2カラム比較（Before/After）

変化を左右で対比させるパターン。

```javascript
function createBeforeAfterSlide(pres, title, beforeData, afterData) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "2カラム比較（Before/After）");
  
  const colWidth = 4.3;
  const colY = 1.5;
  const colH = 3.5;
  
  // Before列
  slide.addText("Before", {
    x: 0.5, y: colY, w: colWidth, h: 0.4,
    fontSize: 14, fontFace: "Century Gothic",
    color: "A6A6A6", bold: true
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: colY + 0.5, w: colWidth, h: colH - 0.5,
    fill: { color: "F5F5F5" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  slide.addText(beforeData, {
    x: 0.65, y: colY + 0.65, w: colWidth - 0.3, h: colH - 0.8,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // After列
  slide.addText("After", {
    x: 5.2, y: colY, w: colWidth, h: 0.4,
    fontSize: 14, fontFace: "Century Gothic",
    color: "29BA74", bold: true
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 5.2, y: colY + 0.5, w: colWidth, h: colH - 0.5,
    fill: { color: "E8F5F0" },
    line: { color: "29BA74", width: 1 }
  });
  slide.addText(afterData, {
    x: 5.35, y: colY + 0.65, w: colWidth - 0.3, h: colH - 0.8,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  addFooter(slide);
  return slide;
}
```

### 7. 2カラム（テキスト+画像）

```javascript
function createTextImageSlide(pres, title, text, imagePath) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "2カラム（テキスト+画像）");
  
  // テキストエリア（左）
  slide.addText("テキストエリア", {
    x: 0.5, y: 1.5, w: 4.5, h: 0.35,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6"
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 1.9, w: 4.5, h: 3.0,
    fill: { color: "F5F5F5" }
  });
  slide.addText(text, {
    x: 0.65, y: 2.0, w: 4.2, h: 2.8,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 画像エリア（右）
  if (imagePath) {
    slide.addImage({
      path: imagePath,
      x: 5.3, y: 1.5, w: 4.2, h: 3.4
    });
  } else {
    // プレースホルダー
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 5.3, y: 1.5, w: 4.2, h: 3.4,
      fill: { color: "E0E0E0" }
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 7b. 2カラム（画像+テキスト）- 逆パターン

```javascript
function createImageTextSlide(pres, title, imagePath, text) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "2カラム（画像+テキスト）");
  
  // 画像エリア（左）
  if (imagePath) {
    slide.addImage({
      path: imagePath,
      x: 0.5, y: 1.5, w: 4.2, h: 3.4
    });
  } else {
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5, y: 1.5, w: 4.2, h: 3.4,
      fill: { color: "E0E0E0" }
    });
  }
  
  // テキストエリア（右）
  slide.addText("テキストエリア", {
    x: 5.0, y: 1.5, w: 4.5, h: 0.35,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6"
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 5.0, y: 1.9, w: 4.5, h: 3.0,
    fill: { color: "F5F5F5" }
  });
  slide.addText(text, {
    x: 5.15, y: 2.0, w: 4.2, h: 2.8,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  addFooter(slide);
  return slide;
}
```

### 8. 3カラム（画像+テキスト）

画像カードを横に3つ並べる。

```javascript
function create3ColumnImageTextSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "3カラム（画像+テキスト）");
  
  const colWidth = 2.9;
  const gap = 0.25;
  const startX = 0.5;
  
  items.slice(0, 3).forEach((item, i) => {
    const x = startX + i * (colWidth + gap);
    
    // アイコン/画像エリア
    slide.addShape(pres.shapes.OVAL, {
      x: x + (colWidth - 0.8) / 2, y: 1.6, w: 0.8, h: 0.8,
      fill: { color: "E8F5F0" }
    });
    
    // タイトル
    slide.addText(item.title, {
      x: x, y: 2.6, w: colWidth, h: 0.4,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "404040", bold: true, align: "center"
    });
    
    // 説明
    slide.addText(item.description || "", {
      x: x, y: 3.1, w: colWidth, h: 1.5,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040", align: "center", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 9. 3カラム（アクセントカラー付き）

色で3つの項目を区別する。

```javascript
function create3ColumnAccentSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "3カラム（アクセントカラー付き）");
  
  const colors = ["1B3928", "29BA74", "404040"];
  const colWidth = 2.9;
  const gap = 0.25;
  const startX = 0.5;
  
  items.slice(0, 3).forEach((item, i) => {
    const x = startX + i * (colWidth + gap);
    
    // カラーバー（上部）
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: colWidth, h: 0.15,
      fill: { color: colors[i] }
    });
    
    // カード背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.65, w: colWidth, h: 3.0,
      fill: { color: "F5F5F5" }
    });
    
    // タイトル
    slide.addText(item.title, {
      x: x + 0.15, y: 1.8, w: colWidth - 0.3, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: colors[i], bold: true
    });
    
    // 説明
    slide.addText(item.description || "", {
      x: x + 0.15, y: 2.3, w: colWidth - 0.3, h: 2.2,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 10. 4カラムレイアウト

4つのフェーズや選択肢を並べる。

```javascript
function create4ColumnSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "4カラムレイアウト");
  
  const colWidth = 2.15;
  const gap = 0.2;
  const startX = 0.5;
  
  items.slice(0, 4).forEach((item, i) => {
    const x = startX + i * (colWidth + gap);
    
    // ヘッダー
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: colWidth, h: 0.5,
      fill: { color: i === 0 ? "1B3928" : "F5F5F5" }
    });
    slide.addText(item.phase || `Phase ${i + 1}`, {
      x: x, y: 1.5, w: colWidth, h: 0.5,
      fontSize: 11, fontFace: "Century Gothic",
      color: i === 0 ? "FFFFFF" : "404040",
      align: "center", valign: "middle"
    });
    
    // コンテンツ
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 2.0, w: colWidth, h: 2.8,
      fill: { color: "FFFFFF" },
      line: { color: "E0E0E0", width: 0.5 }
    });
    slide.addText(item.content || "", {
      x: x + 0.1, y: 2.1, w: colWidth - 0.2, h: 2.6,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 11. 5カラム（成熟度レベル）

段階的な進化をグラデーションで表現。

```javascript
function createMaturityLevelSlide(pres, title, levels) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "5カラム（成熟度レベル）");
  
  const colWidth = 1.7;
  const gap = 0.15;
  const startX = 0.5;
  
  // グラデーション的に色を変える
  const bgColors = ["F5F5F5", "E8F5F0", "D0EBE4", "B8E0D8", "1B3928"];
  const textColors = ["404040", "404040", "404040", "404040", "FFFFFF"];
  
  levels.slice(0, 5).forEach((level, i) => {
    const x = startX + i * (colWidth + gap);
    
    // レベルボックス
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: colWidth, h: 3.2,
      fill: { color: bgColors[i] }
    });
    
    // レベル名
    slide.addText(level.name || `Level ${i + 1}`, {
      x: x, y: 1.6, w: colWidth, h: 0.4,
      fontSize: 11, fontFace: "Century Gothic",
      color: textColors[i], bold: true, align: "center"
    });
    
    // 説明
    slide.addText(level.description || "", {
      x: x + 0.1, y: 2.1, w: colWidth - 0.2, h: 2.4,
      fontSize: 9, fontFace: "Meiryo UI",
      color: textColors[i], valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 12. 2x2グリッド（画像+テキスト）

4つの要素を2行2列で整理。

```javascript
function create2x2GridSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "2x2グリッド");
  
  const cellW = 4.3;
  const cellH = 1.7;
  const gap = 0.3;
  
  const positions = [
    { x: 0.5, y: 1.4 },
    { x: 5.1, y: 1.4 },
    { x: 0.5, y: 3.3 },
    { x: 5.1, y: 3.3 }
  ];
  
  items.slice(0, 4).forEach((item, i) => {
    const pos = positions[i];
    
    // アイコン円
    slide.addShape(pres.shapes.OVAL, {
      x: pos.x, y: pos.y, w: 0.5, h: 0.5,
      fill: { color: "29BA74" }
    });
    
    // タイトル
    slide.addText(item.title, {
      x: pos.x + 0.65, y: pos.y, w: cellW - 0.8, h: 0.5,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "404040", bold: true, valign: "middle"
    });
    
    // 説明
    slide.addText(item.description || "", {
      x: pos.x + 0.65, y: pos.y + 0.55, w: cellW - 0.8, h: cellH - 0.6,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 13. 2x3グリッドレイアウト

6つの要素を2行3列で整理。

```javascript
function create2x3GridSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "2x3グリッドレイアウト");
  
  const cellW = 2.9;
  const cellH = 1.5;
  const gapX = 0.25;
  const gapY = 0.2;
  const startX = 0.5;
  
  items.slice(0, 6).forEach((item, i) => {
    const col = i % 3;
    const row = Math.floor(i / 3);
    const x = startX + col * (cellW + gapX);
    const y = 1.4 + row * (cellH + gapY);
    
    // セル背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: y, w: cellW, h: cellH,
      fill: { color: "F5F5F5" },
      line: { color: "E0E0E0", width: 0.5 }
    });
    
    // タイトル
    slide.addText(item.title, {
      x: x + 0.1, y: y + 0.1, w: cellW - 0.2, h: 0.35,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "29BA74", bold: true
    });
    
    // 説明
    slide.addText(item.description || "", {
      x: x + 0.1, y: y + 0.5, w: cellW - 0.2, h: cellH - 0.6,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

---

## C. 縦並びリスト系

### 14. 縦3つステップ

番号付きで順序を明示する。

```javascript
function createVertical3StepSlide(pres, title, steps) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "縦3つステップ");
  
  const stepH = 1.1;
  const startY = 1.4;
  
  steps.slice(0, 3).forEach((step, i) => {
    const y = startY + i * (stepH + 0.15);
    
    // 番号円
    slide.addShape(pres.shapes.OVAL, {
      x: 0.5, y: y, w: 0.45, h: 0.45,
      fill: { color: "29BA74" }
    });
    slide.addText(String(i + 1).padStart(2, "0"), {
      x: 0.5, y: y, w: 0.45, h: 0.45,
      fontSize: 12, fontFace: "Century Gothic",
      color: "FFFFFF", align: "center", valign: "middle"
    });
    
    // タイトル
    slide.addText(step.title, {
      x: 1.1, y: y, w: 8, h: 0.4,
      fontSize: 14, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(step.description || "", {
      x: 1.1, y: y + 0.45, w: 8, h: 0.6,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 15. 番号付きステップ（横型）

矢印でプロセスの流れを示す。

```javascript
function createHorizontalStepSlide(pres, title, steps) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "番号付きステップ（横型）");
  
  const stepCount = Math.min(steps.length, 4);
  const stepW = 2.0;
  const arrowW = 0.4;
  const totalW = stepCount * stepW + (stepCount - 1) * arrowW;
  const startX = (10 - totalW) / 2;
  
  steps.slice(0, 4).forEach((step, i) => {
    const x = startX + i * (stepW + arrowW);
    
    // 番号円
    slide.addShape(pres.shapes.OVAL, {
      x: x + (stepW - 0.5) / 2, y: 1.8, w: 0.5, h: 0.5,
      fill: { color: "29BA74" }
    });
    slide.addText(String(i + 1), {
      x: x + (stepW - 0.5) / 2, y: 1.8, w: 0.5, h: 0.5,
      fontSize: 14, fontFace: "Century Gothic",
      color: "FFFFFF", align: "center", valign: "middle"
    });
    
    // タイトル
    slide.addText(step.title, {
      x: x, y: 2.5, w: stepW, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", bold: true, align: "center"
    });
    
    // 説明
    slide.addText(step.description || "", {
      x: x, y: 3.0, w: stepW, h: 1.2,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040", align: "center", valign: "top"
    });
    
    // 矢印（最後以外）
    if (i < stepCount - 1) {
      slide.addText("→", {
        x: x + stepW, y: 1.9, w: arrowW, h: 0.4,
        fontSize: 16, fontFace: "Century Gothic",
        color: "A6A6A6", align: "center"
      });
    }
  });
  
  addFooter(slide);
  return slide;
}
```

### 16. タイムラインレイアウト

時系列で出来事を並べる。

```javascript
function createTimelineSlide(pres, title, events) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "タイムラインレイアウト");
  
  const lineX = 1.2;
  const startY = 1.5;
  const eventH = 0.9;
  
  // 縦ライン
  slide.addShape(pres.shapes.LINE, {
    x: lineX, y: startY, w: 0, h: events.length * eventH,
    line: { color: "E0E0E0", width: 2 }
  });
  
  events.forEach((event, i) => {
    const y = startY + i * eventH;
    
    // 年/日付
    slide.addText(event.date, {
      x: 0.3, y: y, w: 0.8, h: 0.35,
      fontSize: 10, fontFace: "Century Gothic",
      color: "29BA74", bold: true
    });
    
    // ドット
    slide.addShape(pres.shapes.OVAL, {
      x: lineX - 0.1, y: y + 0.1, w: 0.2, h: 0.2,
      fill: { color: "29BA74" }
    });
    
    // イベントバー
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 1.5, y: y, w: 7.5, h: 0.7,
      fill: { color: "E8F5F0" }
    });
    
    // イベントタイトル
    slide.addText(event.title, {
      x: 1.6, y: y + 0.05, w: 7.3, h: 0.35,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(event.description || "", {
      x: 1.6, y: y + 0.4, w: 7.3, h: 0.25,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 17. アイコン付きリスト

絵文字やアイコンで視覚的に区別。

```javascript
function createIconListSlide(pres, title, items) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "アイコン付きリスト");
  
  const itemH = 1.0;
  const startY = 1.4;
  
  items.forEach((item, i) => {
    const y = startY + i * itemH;
    
    // アイコン背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5, y: y, w: 0.5, h: 0.5,
      fill: { color: "E8F5F0" }
    });
    
    // アイコン（絵文字）
    slide.addText(item.icon || "📌", {
      x: 0.5, y: y, w: 0.5, h: 0.5,
      fontSize: 16, align: "center", valign: "middle"
    });
    
    // タイトル
    slide.addText(item.title, {
      x: 1.2, y: y, w: 8, h: 0.4,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(item.description || "", {
      x: 1.2, y: y + 0.4, w: 8, h: 0.5,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

---

## D. パネルデザイン系

### 18. 基本パネル（画像ヘッダー付き）

画像とテキストを組み合わせたカード。

```javascript
function createImageHeaderPanelSlide(pres, title, panels) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "基本パネル（画像ヘッダー付き）");
  
  const panelW = 4.3;
  const gap = 0.3;
  
  panels.slice(0, 2).forEach((panel, i) => {
    const x = 0.5 + i * (panelW + gap);
    
    // 画像エリア
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.4, w: panelW, h: 1.5,
      fill: { color: "E0E0E0" }
    });
    
    // テキストエリア
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 2.9, w: panelW, h: 2.0,
      fill: { color: "F5F5F5" }
    });
    
    // タイトル
    slide.addText(panel.title, {
      x: x + 0.15, y: 3.0, w: panelW - 0.3, h: 0.4,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(panel.description || "", {
      x: x + 0.15, y: 3.5, w: panelW - 0.3, h: 1.3,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 19. 強調パネル（左ボーダー付き）

左端のラインで重要度を示す。

```javascript
function createAccentBorderPanelSlide(pres, title, panels) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "強調パネル（左ボーダー付き）");
  
  const panelW = 4.3;
  const gap = 0.3;
  
  panels.slice(0, 2).forEach((panel, i) => {
    const x = 0.5 + i * (panelW + gap);
    
    // パネル背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: panelW, h: 3.3,
      fill: { color: "FFFFFF" },
      line: { color: "E0E0E0", width: 0.5 }
    });
    
    // 左ボーダー
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: 0.06, h: 3.3,
      fill: { color: "29BA74" }
    });
    
    // タイトル
    slide.addText(panel.title, {
      x: x + 0.2, y: 1.6, w: panelW - 0.35, h: 0.4,
      fontSize: 14, fontFace: "Meiryo UI",
      color: "404040", bold: true
    });
    
    // 説明
    slide.addText(panel.description || "", {
      x: x + 0.2, y: 2.1, w: panelW - 0.35, h: 2.6,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 20. ガラス風パネル

背景を透かして洗練された印象に。

```javascript
function createGlassPanelSlide(pres, title, panelTitle, content) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // ヘッダー
  slide.addText(title, {
    x: 0.5, y: 0.4, w: 9, h: 0.5,
    fontSize: 16, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  // サブタイトル
  slide.addText("背景を透かして洗練された印象に", {
    x: 0.5, y: 0.9, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // ガラス風パネル
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 1.0, y: 1.8, w: 8, h: 2.8,
    fill: { color: "FFFFFF", transparency: 80 }
  });
  
  // パネルタイトル
  slide.addText(panelTitle, {
    x: 1.2, y: 2.0, w: 7.6, h: 0.5,
    fontSize: 16, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  // コンテンツ
  slide.addText(content, {
    x: 1.2, y: 2.6, w: 7.6, h: 1.8,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  addFooter(slide, "FFFFFF");
  return slide;
}
```

### 21. グラデーションパネル

色の変化で目を引くパネル。

```javascript
function createGradientPanelSlide(pres, title, panels) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "グラデーションパネル");
  
  const panelW = 4.3;
  const gap = 0.3;
  const colors = [
    { bg: "1B3928", text: "FFFFFF", label: "濃いグラデーション" },
    { bg: "E8F5F0", text: "404040", label: "淡いグラデーション" }
  ];
  
  panels.slice(0, 2).forEach((panel, i) => {
    const x = 0.5 + i * (panelW + gap);
    const c = colors[i];
    
    // パネル
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.8, w: panelW, h: 2.8,
      fill: { color: c.bg }
    });
    
    // ラベル
    slide.addText(c.label, {
      x: x + 0.15, y: 1.5, w: panelW - 0.3, h: 0.3,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "A6A6A6"
    });
    
    // タイトル
    slide.addText(panel.title, {
      x: x + 0.15, y: 2.0, w: panelW - 0.3, h: 0.4,
      fontSize: 13, fontFace: "Meiryo UI",
      color: c.text, bold: true
    });
    
    // 説明
    slide.addText(panel.description || "", {
      x: x + 0.15, y: 2.5, w: panelW - 0.3, h: 2.0,
      fontSize: 11, fontFace: "Meiryo UI",
      color: c.text
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 22. カード型レイアウト（画像付き）

製品やサービスを紹介するカード。

```javascript
function createProductCardSlide(pres, title, cards) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "カード型レイアウト（画像付き）");
  
  const cardW = 2.9;
  const gap = 0.25;
  const startX = 0.5;
  
  cards.slice(0, 3).forEach((card, i) => {
    const x = startX + i * (cardW + gap);
    
    // カード背景
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.5, w: cardW, h: 3.3,
      fill: { color: "FFFFFF" },
      line: { color: "E0E0E0", width: 0.5 }
    });
    
    // アイコンエリア
    slide.addShape(pres.shapes.OVAL, {
      x: x + (cardW - 0.7) / 2, y: 1.7, w: 0.7, h: 0.7,
      fill: { color: "E8F5F0" }
    });
    
    // タイトル
    slide.addText(card.title, {
      x: x, y: 2.6, w: cardW, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", bold: true, align: "center"
    });
    
    // サブタイトル
    slide.addText(card.subtitle || "", {
      x: x, y: 3.0, w: cardW, h: 0.3,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "A6A6A6", align: "center"
    });
    
    // 説明
    slide.addText(card.description || "", {
      x: x + 0.15, y: 3.4, w: cardW - 0.3, h: 1.3,
      fontSize: 10, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  });
  
  addFooter(slide);
  return slide;
}
```

---

## E. 背景・画像系

### 23. 背景画像全画面

画像でインパクトを最大化。

```javascript
function createFullImageSlide(pres, title, subtitle, imagePath) {
  let slide = pres.addSlide();
  
  // 背景画像
  if (imagePath) {
    slide.background = { path: imagePath };
  } else {
    slide.background = { color: "1B3928" };
  }
  
  // オーバーレイ（半透明）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 5.625,
    fill: { color: "404040", transparency: 40 }
  });
  
  // タイトル
  slide.addText(title, {
    x: 0.5, y: 1.5, w: 9, h: 0.8,
    fontSize: 28, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  // サブタイトル
  slide.addText(subtitle || "", {
    x: 0.5, y: 2.4, w: 9, h: 0.5,
    fontSize: 16, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  return slide;
}
```

### 24. 背景画像右側配置

左にテキスト、右に画像を配置。

```javascript
function createSplitImageSlide(pres, title, content, imagePath) {
  let slide = pres.addSlide();
  slide.background = { color: "FFFFFF" };
  
  // 左側テキストエリア
  slide.addText(title, {
    x: 0.5, y: 0.5, w: 5.5, h: 0.6,
    fontSize: 20, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText(content, {
    x: 0.5, y: 1.3, w: 5.5, h: 3.5,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 右側画像
  if (imagePath) {
    slide.addImage({
      path: imagePath,
      x: 6.2, y: 0, w: 3.8, h: 5.625
    });
  } else {
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 6.2, y: 0, w: 3.8, h: 5.625,
      fill: { color: "E0E0E0" }
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 25. 引用スライド

印象的な言葉を引用する。

```javascript
function createQuoteSlide(pres, quote, author) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // ヘッダー
  slide.addText("引用スライド", {
    x: 0.5, y: 0.4, w: 9, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  slide.addText("印象的な言葉を引用する", {
    x: 0.5, y: 0.8, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // 引用ボックス
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 1.0, y: 2.0, w: 8, h: 1.5,
    fill: { color: "FFFFFF" }
  });
  
  // 引用文
  slide.addText(`"${quote}"`, {
    x: 1.2, y: 2.1, w: 7.6, h: 1.0,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "404040", italic: true, valign: "middle"
  });
  
  // 出典
  slide.addText(`— ${author}`, {
    x: 1.2, y: 3.2, w: 7.6, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6", align: "right"
  });
  
  addFooter(slide, "FFFFFF");
  return slide;
}
```

---

## F. 強調・特殊系

### 27. 統計強調スライド

大きな数字でインパクトを出す。

```javascript
function createStatHighlightSlide(pres, title, stats) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "統計強調スライド");
  
  const statW = 4.3;
  const gap = 0.3;
  
  stats.slice(0, 2).forEach((stat, i) => {
    const x = 0.5 + i * (statW + gap);
    const bgColor = i === 1 ? "1B3928" : "F5F5F5";
    const textColor = i === 1 ? "FFFFFF" : "000000";
    
    // ボックス
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x, y: 1.8, w: statW, h: 2.5,
      fill: { color: bgColor }
    });
    
    // ラベル
    slide.addText(stat.label, {
      x: x + 0.15, y: 1.9, w: statW - 0.3, h: 0.35,
      fontSize: 11, fontFace: "Meiryo UI",
      color: textColor
    });
    
    // 数値
    slide.addText(stat.value, {
      x: x + 0.15, y: 2.3, w: statW - 0.3, h: 1.0,
      fontSize: 48, fontFace: "Century Gothic",
      color: textColor, bold: true
    });
    
    // 単位/説明
    slide.addText(stat.unit || "", {
      x: x + 0.15, y: 3.4, w: statW - 0.3, h: 0.3,
      fontSize: 12, fontFace: "Meiryo UI",
      color: textColor
    });
  });
  
  addFooter(slide);
  return slide;
}
```

### 28. 中央配置メッセージ

シンプルに一言を伝える。

```javascript
function createCenterMessageSlide(pres, mainText, subText) {
  let slide = pres.addSlide();
  slide.background = { color: "FFFFFF" };
  
  // ヘッダー
  slide.addText("中央配置メッセージ", {
    x: 0.5, y: 0.4, w: 9, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "29BA74", bold: true, align: "center"
  });
  
  slide.addText("シンプルに一言を伝える", {
    x: 0.5, y: 0.8, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6", align: "center"
  });
  
  // メインメッセージ
  slide.addText(mainText, {
    x: 0.5, y: 2.0, w: 9, h: 1.0,
    fontSize: 28, fontFace: "Meiryo UI",
    color: "404040", align: "center", valign: "middle"
  });
  
  // サブメッセージ
  if (subText) {
    slide.addText(subText, {
      x: 0.5, y: 3.2, w: 9, h: 0.5,
      fontSize: 14, fontFace: "Century Gothic",
      color: "A6A6A6", align: "center"
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 29. Q&Aスライド

質疑応答への誘導。

```javascript
function createQASlide(pres, contactInfo) {
  let slide = pres.addSlide();
  slide.background = { color: "FFFFFF" };
  
  // タイトル
  slide.addText("Q&A", {
    x: 0.5, y: 1.2, w: 9, h: 0.8,
    fontSize: 48, fontFace: "Century Gothic",
    color: "29BA74", bold: true
  });
  
  slide.addText("ご質問をお待ちしています", {
    x: 0.5, y: 2.2, w: 9, h: 0.5,
    fontSize: 16, fontFace: "Meiryo UI",
    color: "404040"
  });
  
  // 連絡先
  if (contactInfo) {
    slide.addText(contactInfo, {
      x: 0.5, y: 3.5, w: 9, h: 1.0,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "A6A6A6"
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 30. QRコード付き紹介

書籍やサイトへ誘導する。

```javascript
function createQRCodeSlide(pres, title, description, url, qrImagePath) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "QRコード付き紹介");
  
  // QRコード
  if (qrImagePath) {
    slide.addImage({
      path: qrImagePath,
      x: 3.5, y: 1.8, w: 2, h: 2
    });
  } else {
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 3.5, y: 1.8, w: 2, h: 2,
      fill: { color: "E0E0E0" }
    });
  }
  
  // タイトル
  slide.addText(description, {
    x: 0.5, y: 4.0, w: 9, h: 0.4,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "404040", align: "center"
  });
  
  // URL
  slide.addText(url, {
    x: 0.5, y: 4.5, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Century Gothic",
    color: "29BA74", align: "center"
  });
  
  addFooter(slide);
  return slide;
}
```

### 31. 問いかけスライド

聴衆への問いを中央配置で投げかける。

```javascript
function createQuestionSlide(pres, question, note) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // ヘッダー
  slide.addText("問いかけスライド", {
    x: 0.5, y: 0.4, w: 9, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  slide.addText("聴衆への問いを中央配置で投げかける", {
    x: 0.5, y: 0.8, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // 問いかけボックス
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 1.0, y: 2.0, w: 8, h: 1.2,
    fill: { color: "29BA74" }
  });
  
  // 問いかけ文
  slide.addText(`「${question}」`, {
    x: 1.2, y: 2.1, w: 7.6, h: 1.0,
    fontSize: 18, fontFace: "Meiryo UI",
    color: "FFFFFF", align: "center", valign: "middle"
  });
  
  // 補足
  if (note) {
    slide.addText(note, {
      x: 0.5, y: 3.5, w: 9, h: 0.5,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "FFFFFF", align: "center"
    });
  }
  
  addFooter(slide, "FFFFFF");
  return slide;
}
```

### 32. 映画引用スライド

映画のセリフを引用して印象づける。

```javascript
function createMovieQuoteSlide(pres, quote1, quote2, comment, keyword) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // ヘッダー
  slide.addText("映画引用スライド", {
    x: 0.5, y: 0.4, w: 9, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  slide.addText("映画のセリフを引用して印象づける", {
    x: 0.5, y: 0.8, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // 引用ボックス
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 1.0, y: 1.5, w: 8, h: 1.8,
    fill: { color: "2A4A38" },  // 少し明るめのグリーン
    line: { color: "3A5A48", width: 1 }
  });
  
  // 引用文1
  slide.addText(quote1, {
    x: 1.2, y: 1.6, w: 7.6, h: 0.4,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "FFFFFF", italic: true
  });
  
  // 引用文2
  if (quote2) {
    slide.addText(quote2, {
      x: 1.2, y: 2.1, w: 7.6, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "FFFFFF", italic: true
    });
  }
  
  // 解説コメント
  slide.addText(comment, {
    x: 0.5, y: 3.6, w: 9, h: 0.6,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // キーワード誘導
  if (keyword) {
    slide.addText(`この「${keyword}」について考えてみましょう。`, {
      x: 0.5, y: 4.3, w: 9, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "29BA74"
    });
  }
  
  addFooter(slide, "FFFFFF");
  return slide;
}
```

### 33. インライン画像スライド

画像とテキストを並べて解説する。

```javascript
function createInlineImageSlide(pres, title, imagePath, description, bullets) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "インライン画像スライド");
  
  // 画像エリア（左）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 1.4, w: 3.5, h: 2.5,
    fill: { color: "F5F5F5" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  
  // 画像プレースホルダーテキスト
  slide.addText("画像をコンテンツ内に配置", {
    x: 0.5, y: 2.3, w: 3.5, h: 0.5,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6", align: "center"
  });
  
  // 説明テキスト（右）
  slide.addText(description, {
    x: 4.2, y: 1.4, w: 5.3, h: 1.0,
    fontSize: 13, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 箇条書き
  if (bullets && bullets.length > 0) {
    const bulletText = bullets.map(b => `• ${b}`).join("\n");
    slide.addText(bulletText, {
      x: 4.2, y: 2.6, w: 5.3, h: 2.0,
      fontSize: 11, fontFace: "Meiryo UI",
      color: "404040", valign: "top"
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 34. 統計比率スライド

数値データを視覚的に比較する。

```javascript
function createStatsRatioSlide(pres, title, stats, conclusion) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "統計比率スライド");
  
  const count = stats.length;
  const barWidth = 7.5 / count;
  const startX = 1.25;
  
  stats.forEach((stat, i) => {
    const x = startX + i * (barWidth + 0.3);
    
    // パーセンテージ（大きく）
    slide.addText(stat.value, {
      x: x, y: 1.6, w: barWidth, h: 0.8,
      fontSize: 36, fontFace: "Century Gothic",
      color: stat.color || "1B3928", bold: true, align: "center"
    });
    
    // カテゴリ名
    slide.addText(stat.label, {
      x: x, y: 2.5, w: barWidth, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", align: "center"
    });
    
    // バー（比率表現）
    const barHeight = (parseFloat(stat.value) / 100) * 1.5;
    slide.addShape(pres.shapes.RECTANGLE, {
      x: x + 0.3, y: 3.0 + (1.5 - barHeight), 
      w: barWidth - 0.6, h: barHeight,
      fill: { color: stat.color || "29BA74" }
    });
  });
  
  // 結論
  if (conclusion) {
    slide.addText(conclusion, {
      x: 0.5, y: 4.8, w: 9, h: 0.4,
      fontSize: 12, fontFace: "Meiryo UI",
      color: "404040", align: "center"
    });
  }
  
  addFooter(slide);
  return slide;
}
```

### 35. テキスト+統計パネル混合

説明文と数値を組み合わせる。

```javascript
function createTextStatsMixSlide(pres, title, statLabel, statValue, textItems) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "テキスト+統計パネル混合");
  
  // 統計パネル（左）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 1.4, w: 4, h: 3.2,
    fill: { color: "F5F5F5" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  
  slide.addText(statLabel, {
    x: 0.7, y: 1.6, w: 3.6, h: 0.4,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText(statValue, {
    x: 0.7, y: 2.2, w: 3.6, h: 1.0,
    fontSize: 48, fontFace: "Century Gothic",
    color: "29BA74", bold: true
  });
  
  slide.addText("補足説明", {
    x: 0.7, y: 3.5, w: 3.6, h: 0.8,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "A6A6A6"
  });
  
  // テキストパネル（右）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 4.7, y: 1.4, w: 4.8, h: 3.2,
    fill: { color: "FFFFFF" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  
  slide.addText("テキストラベル", {
    x: 4.9, y: 1.6, w: 4.4, h: 0.4,
    fontSize: 12, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  // テキストアイテム
  const itemsText = textItems.map(item => `• ${item}`).join("\n");
  slide.addText(itemsText, {
    x: 4.9, y: 2.1, w: 4.4, h: 2.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  addFooter(slide);
  return slide;
}
```

### 36. まとめスライド（ガラス風縦並び）

セクションの要点をガラス風パネルで整理。

```javascript
function createSummaryGlassSlide(pres, title, points) {
  let slide = pres.addSlide();
  slide.background = { color: "1B3928" };
  
  // ヘッダー
  slide.addText("まとめスライド（ガラス風縦並び）", {
    x: 0.5, y: 0.4, w: 9, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF", bold: true
  });
  
  slide.addText("セクションの要点をガラス風パネルで整理", {
    x: 0.5, y: 0.8, w: 9, h: 0.3,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "FFFFFF"
  });
  
  // ポイントパネル（縦並び）
  const panelHeight = 0.9;
  const gap = 0.15;
  const startY = 1.4;
  
  points.forEach((point, i) => {
    const y = startY + i * (panelHeight + gap);
    
    // ガラス風パネル
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5, y: y, w: 9, h: panelHeight,
      fill: { color: "2A4A38", transparency: 30 },
      line: { color: "3A5A48", width: 0.5 }
    });
    
    // 番号マーカー
    slide.addShape(pres.shapes.OVAL, {
      x: 0.7, y: y + 0.2, w: 0.5, h: 0.5,
      fill: { color: "29BA74" }
    });
    slide.addText(String(i + 1), {
      x: 0.7, y: y + 0.25, w: 0.5, h: 0.4,
      fontSize: 12, fontFace: "Century Gothic",
      color: "FFFFFF", align: "center", bold: true
    });
    
    // ポイントタイトル
    slide.addText(point.title, {
      x: 1.4, y: y + 0.15, w: 7.8, h: 0.35,
      fontSize: 13, fontFace: "Meiryo UI",
      color: "FFFFFF", bold: true
    });
    
    // ポイント説明
    if (point.description) {
      slide.addText(point.description, {
        x: 1.4, y: y + 0.5, w: 7.8, h: 0.35,
        fontSize: 10, fontFace: "Meiryo UI",
        color: "FFFFFF"
      });
    }
  });
  
  addFooter(slide, "FFFFFF");
  return slide;
}
```

### 37. シンプルリスト+補足パネル

箇条書きに補足情報を添える。

```javascript
function createListWithSupplementSlide(pres, title, listItems, supplement) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "シンプルリスト+補足パネル");
  
  // リスト部分（左）
  const bulletText = listItems.map((item, i) => {
    if (item.highlight) {
      return { text: `• ${item.text}`, options: { bold: true, color: "29BA74" } };
    }
    return { text: `• ${item.text}`, options: { breakLine: true } };
  });
  
  slide.addText(bulletText.map(b => b.text).join("\n"), {
    x: 0.5, y: 1.4, w: 5.5, h: 3.0,
    fontSize: 13, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 補足パネル（右下）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 6.2, y: 2.8, w: 3.3, h: 1.8,
    fill: { color: "F5F5F5" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  
  slide.addText(supplement.title || "補足説明", {
    x: 6.4, y: 2.95, w: 2.9, h: 0.35,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText(supplement.text, {
    x: 6.4, y: 3.4, w: 2.9, h: 1.1,
    fontSize: 10, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  addFooter(slide);
  return slide;
}
```

### 38. 対比+結論スライド

二項対立から結論を導く。

```javascript
function createComparisonConclusionSlide(pres, title, conceptA, conceptB, conclusion) {
  let slide = pres.addSlide();
  addSlideHeader(slide, title, "対比+結論スライド");
  
  const colWidth = 4.2;
  const colY = 1.4;
  const colH = 2.2;
  
  // 概念A（左）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: colY, w: colWidth, h: colH,
    fill: { color: "F5F5F5" },
    line: { color: "E0E0E0", width: 0.5 }
  });
  
  slide.addText(conceptA.title, {
    x: 0.7, y: colY + 0.15, w: colWidth - 0.4, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText(conceptA.description, {
    x: 0.7, y: colY + 0.6, w: colWidth - 0.4, h: colH - 0.8,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 概念B（右）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 5.3, y: colY, w: colWidth, h: colH,
    fill: { color: "E8F5F0" },  // ライトミント
    line: { color: "D0E8E0", width: 0.5 }
  });
  
  slide.addText(conceptB.title, {
    x: 5.5, y: colY + 0.15, w: colWidth - 0.4, h: 0.4,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "29BA74", bold: true
  });
  
  slide.addText(conceptB.description, {
    x: 5.5, y: colY + 0.6, w: colWidth - 0.4, h: colH - 0.8,
    fontSize: 11, fontFace: "Meiryo UI",
    color: "404040", valign: "top"
  });
  
  // 結論エリア（下部）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 3.9, w: 9, h: 1.0,
    fill: { color: "29BA74" }
  });
  
  slide.addText(conclusion, {
    x: 0.7, y: 4.05, w: 8.6, h: 0.7,
    fontSize: 14, fontFace: "Meiryo UI",
    color: "FFFFFF", valign: "middle"
  });
  
  addFooter(slide);
  return slide;
}
```

---

## 共通関数

### スライドヘッダー

```javascript
function addSlideHeader(slide, title, category) {
  // カテゴリラベル（左上）
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0.4, y: 0.25, w: 0.06, h: 0.35,
    fill: { color: "29BA74" }
  });
  
  // カテゴリテキスト（混在テキスト対応）
  if (category) {
    slide.addText(
      splitTextWithFonts(category, { color: "A6A6A6" }),
      { x: 0.55, y: 0.25, w: 4, h: 0.35, fontSize: 10, margin: 0 }
    );
  }
  
  // タイトル（混在テキスト対応）
  slide.addText(
    splitTextWithFonts(title, { color: "29BA74", bold: true }),
    { x: 0.5, y: 0.6, w: 9, h: 0.6, fontSize: 20 }
  );
}
```

### フッター

```javascript
function addFooter(slide, textColor = "A6A6A6") {
  // コピーライト（英数字中心なのでCentury Gothic）
  slide.addText("© Eight Hundred Inc.", {
    x: 0.5, y: 5.2, w: 3, h: 0.3,
    fontSize: 8, fontFace: "Century Gothic",
    color: textColor
  });
}
```
