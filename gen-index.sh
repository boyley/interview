#!/usr/bin/env bash
# =============================================================================
# gen-index.sh — 生成 interview 面试库总目录索引 INDEX.md
# 汇总所有文档的 # / ## 标题，便于 Ctrl+F 搜标题定位。
# 用法：在 interview/ 目录下执行  bash gen-index.sh
# 新增/改动文档后重跑即可刷新。
# =============================================================================
cd "$(dirname "$0")" || exit 1
OUT=INDEX.md

gen_module() {
  dir="$1"; title="$2"
  count=$(find "$dir" -name "*.md" ! -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 0 ] && return
  echo "## $title"
  echo ""
  find "$dir" -name "*.md" ! -name "README.md" 2>/dev/null | sort | while IFS= read -r f; do
    rel="${f#./}"
    echo "### 📄 [$rel]($rel)"
    command grep -E "^#{1,2}[[:space:]]" "$f" | while IFS= read -r line; do
      hashes="${line%% *}"
      text="${line#* }"
      if [ "${#hashes}" -eq 1 ]; then
        echo "- **${text}**"
      else
        echo "  - ${text}"
      fi
    done
    echo ""
  done
}

{
  echo "# 📇 面试库总目录（可搜索索引）"
  echo ""
  echo "> 用法：**Ctrl/Cmd + F 搜任意标题关键词**（如缓存击穿、分布式事务、接口慢、雪花算法），即可定位到所在文件。"
  echo "> 本文件由 \`gen-index.sh\` 自动汇总所有文档标题（# 与 ##）。新增/改动文档后重跑该脚本刷新。"
  echo ""
  gen_module "./01-cheatsheet"     "01 · 八股速答 Cheatsheet"
  gen_module "./02-coding"         "02 · 手撕代码 Coding"
  gen_module "./03-system-design"  "03 · 系统设计 System Design"
  gen_module "./04-project-hr"     "04 · 项目 & HR"
  gen_module "./05-ai"             "05 · AI 应用（程序员视角）"
  gen_module "./06-web3"           "06 · Web3 / 区块链（程序员视角）"
} > "$OUT"

echo "✅ 已生成 $OUT（$(wc -l < "$OUT" | tr -d ' ') 行，$(command grep -cE '^### 📄' "$OUT") 个文件）"
