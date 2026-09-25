# スケルトンHTML テンプレート（STEP 5 用）

SLIDE-PATTERN-{name}.html 生成時の CSS 基本構造と HTML 構成例。実装方針（グレースケール・960×540・ラベル表示等のルール）は SKILL.md STEP 5 が正。

**書き方は PPTX 変換セーフに揃える**（プレビューは下流が採寸・参照する見本のため）。マーカー・番号は行のテキストノードに直接書き（`::before` で描かない）、1 行を複数要素に分けず、境界は `border` で引く。角丸を使うカードは 1 要素・4 隅同一半径にとどめ（部分丸め＋重ね合わせは不可）、表を含む場合は罫線をセル間で統一する。詳細は html-artifact スキルの `references/pptx-safe.md`。

**あわせて禁じ手 15 を全項目守る**（正本：`${CLAUDE_PLUGIN_ROOT}/skills/_shared/kinjite-15.md`、適用細則は SKILL.md STEP 5）。スケルトン特有の落とし穴は次の 5 つ：

- 幅調整の `<br>` / `&nbsp;` / 全角スペースを使わない（禁じ手②）。ダミーテキストの折り返しは要素幅に任せる
- 並列ゾーンは `flex:1`（または grid の `1fr`）で等分し、**塗りも枠も無いゾーンも同じ幅・同じパディング**にする（禁じ手⑪）。下の構成例で左右とも `width:50%` ＋ 同じ `padding` にしているのはこのため
- ゾーン分割に `position:absolute`＋px の微調整を使わない（禁じ手⑫）。flex / grid で組む
- 並列要素の `font-size` を揃え、入り切らないときはダミーの文字数を減らす（禁じ手⑥）。11px 未満にしない。英数字は半角・カタカナは全角で統一
- `line-height` は 1.7 以上、項目間に余白を取る（禁じ手⑧）。`animation` / `transition` は使わない（禁じ手⑭）

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

## 行頭マーカー・番号付き行の書き方（PPTX 変換セーフ）

マーカーや番号は `::before` ではなく行のテキストとして書き、行を包む要素が本文のテキストノードを直接持つようにする。字下げは `text-indent` の負値＋同量の `padding-left` で吸収する（`margin-left` は箱ごとずれ、罫線・背景が本文左端からずれる）。行ごとのアンダーラインは付けない（pptx で行ごとに線シェイプ化して揃わない）。

    <!-- 箇条書き（マーカーは行のテキストの一部） -->
    <ul style="list-style:none;">
      <li style="font-size:13px; color:#555; line-height:1.7; padding-left:1em; text-indent:-1em;">● 箇条書きの項目が入ります</li>
      <li style="font-size:13px; color:#555; line-height:1.7; padding-left:1em; text-indent:-1em;">● 箇条書きの項目が入ります</li>
    </ul>

    <!-- 番号付き見出し行（番号だけ書式を変えたい場合も同じテキストノード内に置く） -->
    <div style="font-size:15px; font-weight:bold; color:#333;"><span style="color:#888; margin-right:10px;">01</span>見出しが入ります</div>

    <!-- ゾーン間の矢印は、結ぶ2ゾーンの間に1本ずつ独立して置く（オーバーレイで1枚にまとめない） -->
    <div style="width:8%; display:flex; align-items:center; justify-content:center; color:#AAAAAA; font-size:18px;">→</div>

## カード・表の書き方（面は直角／PPTX 変換セーフ）

**面（カード・パネル・帯・バー）は角丸を使わず直角にする**（`border-radius:0`）。とくに **2 色構成（塗りヘッダー帯＋本文）のカードで角丸は使わない**：pptx では上 2 角／下 2 角だけ丸める専用シェイプへ分割され、継ぎ目に線が入る・重ねた 2 枚がずれる。円形（`border-radius:50%`）とピル形のチップ／バッジだけが例外。

    <!-- OK：面は直角。2色構成（帯＋本文）も直角なら継ぎ目が割れない -->
    <div style="background:#FFFFFF; border:1px solid #CCCCCC; border-radius:0; padding:0;">
      <div style="background:#333333; color:#FFFFFF; padding:8px 12px;">ヘッダー帯</div>
      <div style="padding:16px;">カードの内容</div>
    </div>

    <!-- NG：カードを角丸にする（border-radius:8px）／ヘッダー部だけ丸める（border-radius:8px 8px 0 0） -->

**マトリクス（2x2・N×M）はセル（面）の集合として組む**（禁じ手⑬）。罫線を引いた領域に絶対配置テキストを載せる書き方をしない——pptx では線シェイプ群とテキストボックス群に分解され、セルの対応関係が失われる。`<table>` の `<td>` か、grid のセル `<div>` を並べる。

表は罫線をセル間で統一する。強調はセルの `background-color` で表現し、罫線の色・太さ・実線/点線をセルごとに変えない（変えるほど pptx で図形が増える）。

    <table style="border-collapse:collapse; width:100%;">
      <tr>
        <td style="border:1px solid #CCCCCC; padding:8px;">通常セル</td>
        <td style="border:1px solid #CCCCCC; padding:8px; background:#F0F0F0;">強調セル（背景色で表現）</td>
      </tr>
    </table>
