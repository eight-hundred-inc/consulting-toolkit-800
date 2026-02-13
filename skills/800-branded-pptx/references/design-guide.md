# 800 Brand Design Guide

> **カラー定数の定義元**: すべてのカラー・フォント定数は [consulting-deck-boilerplate.js](consulting-deck-boilerplate.js) の `C`, `SUB`, `FONT` が唯一の定義元（Single Source of Truth）。本ファイルは仕様の説明のみを行い、HEX値の重複定義はしない。

---

## カラーパレット概要

### メインカラー（`C` オブジェクト）

| トークン | 用途 |
|---------|------|
| `C.navy` | タイトル・セクション・クロージングの背景。コンテンツスライドのタイトル色 |
| `C.navyLight` | ダーク背景スライドのボトムストライプ |
| `C.accent` | メインアクセント。左アクセントバー、上部ライン、ボタン、強調 |
| `C.contentBg` | コンテンツスライド背景（白） |
| `C.text` | 本文テキスト |
| `C.muted` | サブテキスト、キャプション、フッター |
| `C.lightGray` | ボーダー、区切り線 |
| `C.tableBg` | テーブル交互行背景（薄ミント） |
| `C.tableHead` | テーブルヘッダー背景 |

### サブカラー（`SUB` オブジェクト）

3カラム、2x2グリッド、4象限フレームワーク等で項目を色分けする際に使う。

| トークン | 色名 | 用途例 |
|---------|------|--------|
| `SUB.primary` | ティール | 1番目の項目、メインカテゴリ |
| `SUB.secondary` | ブルー | 2番目の項目、対比カテゴリ |
| `SUB.tertiary` | イエローグリーン | 3番目の項目、補助カテゴリ |
| `SUB.quaternary` | ローズ | 4番目の項目、警告・注意カテゴリ |

**注意**: `SUB.tertiary` は明るい色のため、白背景上のテキスト色には使わない。左アクセントバー、バッジ背景、区切り線など面積の小さい装飾要素に使う。テキストは常に `C.text` または `C.navy` を使う。

### 背景色の使い分け

| 背景 | 用途 |
|------|------|
| `C.navy` | タイトル、セクション開始、クロージング |
| `C.contentBg` | 標準コンテンツスライド |

---

## タイポグラフィ

### フォント（`FONT` オブジェクト）

| 用途 | フォント |
|------|---------|
| 見出し・本文（日本語） | `FONT.head` / `FONT.body`（= Meiryo UI） |
| ロゴ「800」・数値・英文 | Century Gothic |
| 混在テキスト | `splitTextWithFonts()` で自動分割 |

### フォントサイズ階層

| 要素 | サイズ | ウェイト |
|------|--------|----------|
| タイトルスライドのメインタイトル | 36-40pt | Bold |
| コンテンツスライドのタイトル | 20-22pt | Bold |
| 見出し | 14-16pt | Bold |
| 本文 | 11-13pt | Regular |
| キャプション / 注釈 | 10-11pt | Regular / Italic |
| フッター | 8pt | Regular |

---

## レイアウトグリッド

| 項目 | 値 |
|------|-----|
| アスペクト比 | 16:9（10" × 5.625"） |
| 左右マージン | 0.5" |
| 上マージン | 0.25"（ヘッダー部分） |
| 下マージン | 0.4"（フッター領域） |
| 有効幅 | 9" |
| 有効高さ | 約5" |

---

## スライド骨格仕様

### セクション区切りスライド

| 要素 | 位置・仕様 |
|------|-----------|
| 背景 | `C.navy` |
| 上部アクセントライン | y=0, h=0.03, `C.accent` |
| セクション番号 | y=1.4, 16pt, `C.accent`, bold |
| タイトル | y=1.95, 36pt, 白, bold |
| サブタイトル | y=3.2, 14pt, `C.muted` |
| ロゴ「800」 | y=4.8, Century Gothic 14pt, `C.muted` |
| ボトムストライプ | y=5.425, h=0.2, `C.navyLight` |
| → ヘルパー | `addSectionSlide(sectionNum, title, subtitle?)` |

### コンテンツスライド

| 要素 | 位置・仕様 |
|------|-----------|
| 背景 | `C.contentBg` |
| 上部ナビバー | y=0, h=0.04, `C.navy` |
| スライドタイトル | x=0.7, y=0.3, 22pt, `C.navy`, bold |
| セパレーター | x=0.7, y=0.9, h=0.015, `C.lightGray` |
| コンテンツエリア | y=1.0〜5.0 |
| フッター | y=5.2, `© Eight Hundred Inc.`, 8pt, `C.muted` |
| → ヘルパー | `addContentSlide(title)` |

### タイトルスライド

| 要素 | 位置・仕様 |
|------|-----------|
| 背景 | `C.navy` |
| 上部アクセントライン | y=0, h=0.035, `C.accent` |
| メインタイトル | y=1.3, 40pt, 白, bold |
| サブタイトル | y=2.7, 15pt, `C.muted` |
| 区切り線 | y=3.85, w=1.2, h=0.025, `C.accent` |
| 補足情報 | y=4.1, 13pt, `C.muted` |
| ロゴ「800」 | y=4.8, Century Gothic 16pt, 白 |
| ボトムストライプ | y=5.425, h=0.2, `C.navyLight` |
| → ヘルパー | `addTitleSlide(mainTitle, subtitle?, extraInfo?)` |

### クロージングスライド

タイトルスライドと同構造。→ `addClosingSlide(heading?, message?)`

---

## アイコン使用ガイドライン

react-icons（Fa系）→ React SSR → SVG → sharp → PNG base64。

ヘルパー: `iconToBase64Png(IconComponent, color, size?)`、`renderIconSvg(IconComponent, color, size?)` — いずれも boilerplate.js に定義済み。
