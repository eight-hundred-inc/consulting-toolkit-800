---
name: docx-to-markdown-with-references
description: Word文書（.docx）をMarkdownに変換し、参考文献を整理するスキル。「Wordをマークダウンに変換して」「docxをmdに変換して参考文献を整理して」「Word文書の参考文献を統合して」「レポートをMarkdownに変換して」などのリクエスト時に使用。pandoc（またはpython-docxフォールバック）による変換と、重複URL統合・番号再割当て・参考文献リスト生成・文書構造整形を行う。
---

# Word to Markdown with Reference Consolidation

Word文書をMarkdownに変換し、参考文献を整理するスキル。

## 処理フロー

```
処理フロー
├── Step 1: Word → Markdown変換
│   ├── pandoc（推奨）
│   └── python-docx（フォールバック）
├── Step 2: 参考文献の整理・番号再割当て
│   ├── URL重複の統合
│   ├── 番号の再割当て
│   └── 本文中の参照番号更新
└── Step 3: 文書構造の整形（オプション）
    ├── セクション分離
    ├── 改行挿入
    └── 箇条書き整形
```

---

## Step 1: Word → Markdown変換

### 方法A: pandoc（推奨）

```bash
pandoc -f docx -t markdown --wrap=none -o output.md input.docx
```

**オプション**:
- `--wrap=none`: 行の自動折り返しを無効化
- `--extract-media=./media`: 画像を抽出

### 方法B: python-docx（pandocがない場合のフォールバック）

```python
from docx import Document
import re

def convert_docx_to_markdown(input_path, output_path):
    doc = Document(input_path)
    lines = []
    
    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            continue
        
        style_name = para.style.name if para.style else ""
        
        # 見出しレベルの判定
        if "Heading 1" in style_name or style_name == "見出し 1":
            lines.append(f"# {text}")
        elif "Heading 2" in style_name or style_name == "見出し 2":
            lines.append(f"## {text}")
        elif "Heading 3" in style_name or style_name == "見出し 3":
            lines.append(f"### {text}")
        elif "Heading 4" in style_name or style_name == "見出し 4":
            lines.append(f"#### {text}")
        else:
            lines.append(text)
    
    # テーブル処理
    for table in doc.tables:
        table_lines = []
        for i, row in enumerate(table.rows):
            cells = [cell.text.strip().replace('\n', ' ') for cell in row.cells]
            table_lines.append("| " + " | ".join(cells) + " |")
            if i == 0:
                table_lines.append("|" + "|".join(["---" for _ in cells]) + "|")
        lines.append("\n" + "\n".join(table_lines) + "\n")
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))

# 依存関係: pip install python-docx
```

---

## Step 2: 参考文献の整理・番号再割当て

同じURLが異なる番号で参照されている場合、番号を統合して再割当てする。

```python
import re

def consolidate_references(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 参考文献セクションを分離
    ref_marker = "\n---\n\n## 参考文献"
    if ref_marker in content:
        main_text, ref_section = content.split(ref_marker)
    else:
        # 参考文献セクションがない場合は本文のみ
        main_text = content
        ref_section = ""
    
    # 現在の参照番号とURLのマッピングを抽出
    old_refs = {}
    for match in re.finditer(r'\[(\d+)\] (https?://[^\s]+)', ref_section):
        num = int(match.group(1))
        url = match.group(2).strip()
        old_refs[num] = url
    
    # URLごとに番号をグループ化
    url_to_old_nums = {}
    for num, url in old_refs.items():
        if url not in url_to_old_nums:
            url_to_old_nums[url] = []
        url_to_old_nums[url].append(num)
    
    # 本文中の出現順でURLに新番号を割り当て
    url_to_new_num = {}
    old_to_new = {}
    new_num = 1
    
    all_refs_in_text = re.findall(r'\[(\d+)\]', main_text)
    seen_urls = []
    for ref_str in all_refs_in_text:
        ref_num = int(ref_str)
        if ref_num in old_refs:
            url = old_refs[ref_num]
            if url not in seen_urls:
                seen_urls.append(url)
    
    # 出現順に新番号を割り当て
    for url in seen_urls:
        url_to_new_num[url] = new_num
        for old_num in url_to_old_nums[url]:
            old_to_new[old_num] = new_num
        new_num += 1
    
    # 本文中の参照番号を置換（大きい番号から置換して誤置換を防ぐ）
    new_main_text = main_text
    for old_num in sorted(old_to_new.keys(), reverse=True):
        new_main_text = re.sub(r'\[' + str(old_num) + r'\]', f'[#{old_num}#]', new_main_text)
    
    for old_num, new_n in old_to_new.items():
        new_main_text = new_main_text.replace(f'[#{old_num}#]', f'[{new_n}]')
    
    # 連続する同じ参照番号をマージ（例: [1][1] → [1]）
    new_main_text = re.sub(r'\[(\d+)\]\s*\[\1\]', r'[\1]', new_main_text)
    
    # 新しい参考文献セクションを作成
    new_refs = []
    for url in seen_urls:
        num = url_to_new_num[url]
        new_refs.append(f"[{num}] {url}")
    
    new_ref_section = ref_marker + "\n\n" + "\n\n".join(new_refs)
    
    # 最終出力
    final_content = new_main_text + new_ref_section
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_content)
    
    return len(old_refs), len(seen_urls)  # 集約前後の件数
```

---

## Step 3: 文書構造の整形（オプション）

調査レポート形式の文書向けに、可読性を向上させる整形処理。

```python
import re

def format_document_structure(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 参考文献セクションを分離（整形対象外）
    ref_marker = "\n---\n\n## 参考文献"
    if ref_marker in content:
        main_text, ref_section = content.split(ref_marker)
        ref_section = ref_marker + ref_section
    else:
        main_text = content
        ref_section = ""
    
    # 「主張:」「根拠:」を独立セクション化
    main_text = re.sub(r'\n(主張: )', r'\n\n**主張**\n\n', main_text)
    main_text = re.sub(r'^(主張: )', r'**主張**\n\n', main_text)
    main_text = re.sub(r'\n(根拠: )', r'\n\n**根拠**\n\n', main_text)
    main_text = re.sub(r'^(根拠: )', r'**根拠**\n\n', main_text)
    
    # 箇条書き項目を改行で分離し、項目名を太字に
    # パターン: 「 - 項目名: 内容」→「\n\n- **項目名**: 内容」
    main_text = re.sub(r' - ([^:]+): ', r'\n\n- **\1**: ', main_text)
    
    # 太字でない箇条書き項目も太字に統一
    main_text = re.sub(r'\n- ([^*\n]+): ', r'\n- **\1**: ', main_text)
    
    # 小論点・大論点の見出し前に空行を追加
    main_text = re.sub(r'([^\n])\n(小論点)', r'\1\n\n\2', main_text)
    main_text = re.sub(r'([^\n])\n(### 小論点)', r'\1\n\n### 小論点', main_text)
    main_text = re.sub(r'([^\n])\n(## 大論点)', r'\1\n\n## 大論点', main_text)
    
    final_content = main_text + ref_section
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_content)
```

---

## 統合処理の使用例

```python
import subprocess
import os

def convert_docx_to_markdown_full(input_docx, output_md, format_structure=True):
    """
    Word文書をMarkdownに変換し、参考文献を整理する統合処理
    
    Args:
        input_docx: 入力docxファイルパス
        output_md: 出力mdファイルパス
        format_structure: 文書構造の整形を行うか（デフォルト: True）
    """
    temp_md = output_md.replace('.md', '_temp.md')
    
    # Step 1: Word → Markdown変換
    try:
        # pandocを試行
        result = subprocess.run(
            ['pandoc', '-f', 'docx', '-t', 'markdown', '--wrap=none', '-o', temp_md, input_docx],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            raise Exception("pandoc failed")
        print("pandocで変換完了")
    except:
        # python-docxにフォールバック
        print("pandocが利用できません。python-docxで変換します。")
        convert_docx_to_markdown(input_docx, temp_md)  # 上記の関数を使用
    
    # Step 2: 参考文献の整理
    before, after = consolidate_references(temp_md, temp_md)
    print(f"参考文献集約: {before}件 → {after}件")
    
    # Step 3: 文書構造の整形（オプション）
    if format_structure:
        format_document_structure(temp_md, output_md)
        print("文書構造を整形しました")
    else:
        os.rename(temp_md, output_md)
    
    # 一時ファイル削除
    if os.path.exists(temp_md) and temp_md != output_md:
        os.remove(temp_md)
    
    print(f"変換完了: {output_md}")
```

---

## 出力形式

**本文中の参照**: `[1]`, `[2]` 等のシンプルな番号形式（同一URLは同じ番号）

**文書構造**:
```markdown
## 大論点①：タイトル

**主張**

主張の内容...[1]

**根拠**

- **項目名1**: 説明文...[1]

- **項目名2**: 説明文...[2]
```

**参考文献セクション**:
```markdown
---

## 参考文献

[1] https://example.com/article1

[2] https://example.com/article2
```

---

## 注意事項

- pandocがインストールされていない場合は `pip install python-docx` が必要
- 入力ファイルはUTF-8エンコーディングを想定
- 参考文献パターンが `[N] URL` 形式でない場合は正規表現を調整
- Step 3の文書構造整形は調査レポート形式を想定（必要に応じてスキップ可能）
