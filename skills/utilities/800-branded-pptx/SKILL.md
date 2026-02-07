---
name: 800-branded-pptx
description: エイトハンドレッド（800）社のブランドデザインに沿ったPowerPointプレゼンテーションを作成するスキル。「800風のスライドを作成」「エイトハンドレッドのデザインでプレゼンを作って」「800社のテンプレートでPPTX作成」などのリクエスト時に使用。ダークグリーン(#1B3928)をメインカラーとし、Meiryo UIフォント、クリーンでミニマルなレイアウトを特徴とする。
---

# 800 Branded PowerPoint Skill

エイトハンドレッド社のブランドガイドラインに沿ったPowerPointを作成する。

## デザイン詳細

詳細なカラーパレット、フォント設定、レイアウトパターンは [design-guide.md](references/design-guide.md) を参照。

レイアウトパターンの実装コードは [layout-patterns.md](references/layout-patterns.md) を参照。

視覚的な参照用画像は [assets/pattern-images/](assets/pattern-images/) フォルダを参照。

## 基本構成

pptxgenjsを使用してPowerPointを生成する。

```javascript
const pptxgen = require("pptxgenjs");
let pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';
pres.author = 'Eight Hundred Inc.';
```

## カラーパレット（クイックリファレンス）

| 用途 | カラー | HEX |
|------|--------|-----|
| プライマリ（ティール） | メインアクセント、ボタン、強調 | `29BA74` |
| ダークグリーン | タイトル・セクション開始の背景のみ | `1B3928` |
| ダーク | タイトル、本文テキスト | `404040` |
| グレー | サブテキスト、キャプション | `A6A6A6` |
| ライト | 背景 | `FFFFFF` |
| ライトグレー | 境界線、区切り | `E0E0E0` |

## フォント設定

```javascript
const FONT_CONFIG = {
  japanese: "Meiryo UI",     // 日本語フォント
  english: "Century Gothic", // 英数字フォント
  titleSize: 24,      // スライドタイトル
  headingSize: 18,    // セクション見出し  
  bodySize: 14,       // 本文
  captionSize: 10     // キャプション
};
```

**フォント使い分け（同一テキストブロック内）**:
- 日本語部分: `Meiryo UI`
- 英数字部分: `Century Gothic`
- 混在テキストは配列形式で分割して指定

### 混在テキストの実装例

```javascript
// 悪い例（単一フォント）
slide.addText("AI導入で売上30%向上", {
  fontFace: "Meiryo UI", ...
});

// 良い例（フォント使い分け）
slide.addText([
  { text: "AI", options: { fontFace: "Century Gothic" } },
  { text: "導入で売上", options: { fontFace: "Meiryo UI" } },
  { text: "30%", options: { fontFace: "Century Gothic" } },
  { text: "向上", options: { fontFace: "Meiryo UI" } }
], {
  x: 0.5, y: 1.0, w: 9, h: 0.5,
  fontSize: 24, color: "404040"
});
```

### テキスト分割ヘルパー関数

```javascript
// 日本語と英数字を自動分割してフォントを適用
function splitTextWithFonts(text, baseOptions = {}) {
  const segments = [];
  // 英数字（半角）: Century Gothic、それ以外: Meiryo UI
  const regex = /([A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)|([^A-Za-z0-9%$€¥£@#&*+\-=.,!?:;'"()\[\]{}\/\\<>]+)/g;
  let match;
  
  while ((match = regex.exec(text)) !== null) {
    if (match[1]) {
      // 英数字部分
      segments.push({
        text: match[1],
        options: { ...baseOptions, fontFace: "Century Gothic" }
      });
    } else if (match[2]) {
      // 日本語部分
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
  splitTextWithFonts("2024年Q3の売上はYoY比+25%増加", { bold: false }),
  { x: 0.5, y: 1.0, w: 9, h: 0.5, fontSize: 14, color: "404040" }
);
// → "2024" (Century Gothic) + "年" (Meiryo UI) + "Q3" (Century Gothic) + "の売上は" (Meiryo UI) + ...
```

## スライドタイプ一覧

全38種類のレイアウトパターンを提供。詳細なコード例は [layout-patterns.md](references/layout-patterns.md) を参照。

### A. タイトル・セクション系
| # | パターン | 用途 | 背景 |
|---|----------|------|------|
| 1 | タイトルスライド | プレゼン開始 | ダークグリーン |
| 2 | セクション開始スライド | 新章の始まり | ダークグリーン |
| 3 | セクション終了・まとめ | 章の要点整理 | ライトミント |
| 4 | 目次スライド | 講演全体の構成 | 白 |
| 5 | クロージングスライド | 感謝と連絡先 | ダークグリーン |

### B. カラムレイアウト系
| # | パターン | 用途 |
|---|----------|------|
| 6 | 2カラム比較（Before/After） | 変化の対比 |
| 7 | 2カラム（テキスト+画像） | テキスト左、画像右 |
| 7b | 2カラム（画像+テキスト） | 画像左、テキスト右 |
| 8 | 3カラム（画像+テキスト） | 3つの画像カード |
| 9 | 3カラム（アクセントカラー付き） | 色で3項目を区別 |
| 10 | 4カラムレイアウト | 4フェーズ/選択肢 |
| 11 | 5カラム（成熟度レベル） | 段階的進化 |
| 12 | 2x2グリッド | 4要素を2行2列 |
| 13 | 2x3グリッド | 6要素を2行3列 |

### C. 縦並びリスト系
| # | パターン | 用途 |
|---|----------|------|
| 14 | 縦3つステップ | 番号付き順序 |
| 15 | 番号付きステップ（横型） | 矢印でプロセス流れ |
| 16 | タイムラインレイアウト | 時系列イベント |
| 17 | アイコン付きリスト | 視覚的区別 |

### D. パネルデザイン系
| # | パターン | 用途 |
|---|----------|------|
| 18 | 基本パネル（画像ヘッダー付き） | 画像+テキストカード |
| 19 | 強調パネル（左ボーダー付き） | 重要度表示 |
| 20 | ガラス風パネル | 洗練された印象 |
| 21 | グラデーションパネル | 目を引くパネル |
| 22 | カード型レイアウト（画像付き） | 製品/サービス紹介 |

### E. 背景・画像系
| # | パターン | 用途 |
|---|----------|------|
| 23 | 背景画像全画面 | インパクト最大化 |
| 24 | 背景画像右側配置 | 左テキスト、右画像 |
| 25 | 引用スライド | 印象的な言葉 |
| 26 | 複数画像・分割背景 | 画像横並び |

### F. 強調・特殊系
| # | パターン | 用途 |
|---|----------|------|
| 27 | 統計強調スライド | 大きな数字 |
| 28 | 中央配置メッセージ | シンプルな一言 |
| 29 | Q&Aスライド | 質疑応答誘導 |

### G. 応用パターン系
| # | パターン | 用途 |
|---|----------|------|
| 30 | QRコード付き紹介 | サイト/書籍誘導 |
| 31 | 問いかけスライド | 聴衆への問い |
| 32 | 映画引用スライド | セリフ引用 |
| 33 | インライン画像スライド | 画像+解説 |
| 34 | 統計比率スライド | データ視覚比較 |
| 35 | テキスト+統計パネル混合 | 説明文+数値 |
| 36 | まとめスライド（ガラス風縦並び） | 要点整理 |
| 37 | シンプルリスト+補足パネル | 箇条書き+補足 |
| 38 | 対比+結論スライド | 二項対立→結論 |

---

## 基本テンプレートコード

### タイトルスライド（ダーク背景）

```javascript
let titleSlide = pres.addSlide();
titleSlide.background = { color: "1B3928" };

// メインタイトル
titleSlide.addText("プレゼンテーションタイトル", {
  x: 0.5, y: 2.0, w: 9, h: 1.5,
  fontSize: 32, fontFace: "Meiryo UI",
  color: "FFFFFF", bold: false
});

// サブタイトル
titleSlide.addText("サブタイトル", {
  x: 0.5, y: 3.5, w: 9, h: 0.5,
  fontSize: 18, fontFace: "Meiryo UI",
  color: "FFFFFF"
});

// 会社ロゴエリア（左下）
titleSlide.addText("≠800", {
  x: 0.5, y: 4.8, w: 2, h: 0.5,
  fontSize: 16, fontFace: "Century Gothic",
  color: "FFFFFF"
});
```

### コンテンツスライド（標準）

```javascript
let contentSlide = pres.addSlide();
contentSlide.background = { color: "FFFFFF" };

// セクションヘッダー（左上にティールのアクセントバー）
contentSlide.addShape(pres.shapes.RECTANGLE, {
  x: 0.4, y: 0.25, w: 0.06, h: 0.35,
  fill: { color: "29BA74" }
});

// セクションラベル
contentSlide.addText("セクション名", {
  x: 0.55, y: 0.25, w: 3, h: 0.35,
  fontSize: 10, fontFace: "Meiryo UI",
  color: "A6A6A6", margin: 0
});

// スライドタイトル
contentSlide.addText("スライドタイトル", {
  x: 0.5, y: 0.6, w: 9, h: 0.6,
  fontSize: 24, fontFace: "Meiryo UI",
  color: "404040", bold: false
});

// キーメッセージ（タイトル直下・完全な文章・句点必須）
contentSlide.addText(
  splitTextWithFonts("このスライドで伝えたい主張を完全な文章で記載する。"),
  { x: 0.5, y: 1.2, w: 9, h: 0.4, fontSize: 12, color: "404040" }
);

// 本文エリア
contentSlide.addText("本文コンテンツをここに配置", {
  x: 0.5, y: 1.7, w: 9, h: 3.2,
  fontSize: 14, fontFace: "Meiryo UI",
  color: "404040", valign: "top"
});

// ページ番号
addFooter(contentSlide, "© Eight Hundred Inc.", slideNumber);
```

## フッター関数

```javascript
function addFooter(slide, copyright, pageNum = null) {
  // コピーライト（左下）
  slide.addText(copyright, {
    x: 0.5, y: 5.2, w: 3, h: 0.3,
    fontSize: 8, fontFace: "Meiryo UI",
    color: "A6A6A6"
  });
  
  // ページ番号（右下）
  if (pageNum) {
    slide.addText(String(pageNum), {
      x: 9.2, y: 5.2, w: 0.5, h: 0.3,
      fontSize: 8, fontFace: "Meiryo UI",
      color: "A6A6A6", align: "right"
    });
  }
}
```

## キーメッセージの配置

各コンテンツスライドには、タイトル直下にキーメッセージを配置する。

### 位置・スタイル

| 要素 | 値 |
|------|-----|
| 位置 | x: 0.5, y: 1.2（タイトル直下） |
| サイズ | w: 9, h: 0.4 |
| フォントサイズ | 12pt |
| フォント色 | `404040`（通常テキスト色） |

### 文章ルール

- **体言止め禁止**: 完全な文章として記述する
- **句点必須**: 文末には必ず「。」をつける

| NG（体言止め） | OK（完備な文章） |
|---------------|-----------------|
| AI導入による業務効率化 | AI導入により業務効率が向上する。 |
| 売上30%増加の要因分析 | 売上が30%増加した要因を分析する。 |
| 次期戦略の方向性 | 次期戦略の方向性を提示する。 |

### 実装例

```javascript
// スライドタイトル
contentSlide.addText("スライドタイトル", {
  x: 0.5, y: 0.6, w: 9, h: 0.6,
  fontSize: 24, fontFace: "Meiryo UI",
  color: "404040", bold: false
});

// キーメッセージ（タイトル直下）
contentSlide.addText(
  splitTextWithFonts("このスライドで伝えたい主張を完全な文章で記載する。"),
  { x: 0.5, y: 1.2, w: 9, h: 0.4, fontSize: 12, color: "404040" }
);

// 本文エリア（キーメッセージの下）
contentSlide.addText("本文コンテンツをここに配置", {
  x: 0.5, y: 1.7, w: 9, h: 3.2,
  fontSize: 14, fontFace: "Meiryo UI",
  color: "404040", valign: "top"
});
```

---

## 重要なスタイルルール

1. **色の指定**: HEXコードに`#`を付けない（`"29BA74"` ✓ / `"#29BA74"` ✗）
2. **フォント（混在テキスト）**: 同一テキスト内でも英数字は`Century Gothic`、日本語は`Meiryo UI`を使用。`splitTextWithFonts()`関数で自動分割
3. **余白**: スライド端から最低0.5インチ確保
4. **テキスト配置**: 本文は左寄せ、タイトルのみ中央可
5. **アクセントバー**: ティール(#29BA74)の細いバー(w: 0.06)をセクションヘッダーの左に配置
6. **背景**: コンテンツスライドは白(#FFFFFF)、タイトル/セクション開始スライドのみダークグリーン(#1B3928)
7. **プライマリカラー**: ティール(#29BA74)をボタン、強調、アクセントに使用
8. **テキスト色**: 本文は#404040、サブテキストは#A6A6A6
