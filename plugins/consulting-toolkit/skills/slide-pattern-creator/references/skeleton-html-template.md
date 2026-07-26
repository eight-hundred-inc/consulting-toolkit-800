# スケルトンHTML テンプレート（STEP 5 用）

SLIDE-PATTERN-{name}.html 生成時の CSS 基本構造と HTML 構成例。実装方針（グレースケール・960×540・ラベル表示等のルール）は SKILL.md STEP 5 が正。

## CSSの基本構造

    body {
      background: #E8E8E8;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 40px 20px;
      font-family: sans-serif;
    }

    .slide {
      width: 960px;
      height: 540px;
      background: #FFFFFF;
      border: 1px solid #CCCCCC;
      position: relative;
      overflow: hidden;
      margin-bottom: 8px;
    }

    .area-label {
      font-size: 11px;
      color: #999999;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      margin-bottom: 6px;
    }

    .placeholder-box {
      background: #F0F0F0;
      border: 1px dashed #CCCCCC;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #AAAAAA;
      font-size: 13px;
    }

## HTMLの構成例（image-left-text-rightの場合）

パターンの構造に応じてHTMLを生成する。以下は2カラム（左画像・右テキスト）の構成例：

    <p class="slide-label">[{name}]</p>
    <div class="slide" style="display:flex; flex-direction:column;">
      <!-- タイトルエリア（スライドマスターで定義） -->
      <div style="padding:14px 40px 12px; border-bottom:1px dashed #CCCCCC; flex-shrink:0; background:#FAFAFA;">
        <div class="area-label">Title Area — スライドマスター参照</div>
        <div style="font-size:16px; color:#CCCCCC; margin-top:4px;">スライドタイトルが入ります</div>
      </div>
      <!-- コンテンツエリア（このパターンが定義する領域） -->
      <div style="display:flex; flex:1; overflow:hidden;">
        <div style="width:50%; padding:24px 32px; display:flex; flex-direction:column; justify-content:center; border-right:1px solid #CCCCCC;">
          <div class="area-label">Image Area</div>
          <div class="placeholder-box" style="flex:1;">[IMAGE]</div>
        </div>
        <div style="width:50%; padding:24px 32px; display:flex; flex-direction:column; justify-content:center;">
          <div class="area-label">Heading (H2)</div>
          <div style="font-size:20px; font-weight:bold; color:#333; margin-bottom:12px;">見出しが入ります</div>
          <div class="area-label">Body Text</div>
          <div style="font-size:13px; color:#555; line-height:1.7; margin-bottom:12px;">本文テキストが入ります。2〜4行程度の説明文が配置されます。ここにメッセージの詳細を記述します。</div>
          <div class="area-label">Caption (optional)</div>
          <div style="font-size:11px; color:#999;">補足・注釈テキスト</div>
        </div>
      </div>
    </div>
