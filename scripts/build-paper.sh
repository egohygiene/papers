#!/usr/bin/env bash
# build-paper.sh — Build a LaTeX paper to PDF.
#
# Usage:
#   ./scripts/build-paper.sh <paper-path|paper-slug>
#   ./scripts/build-paper.sh --all
#
# Examples:
#   ./scripts/build-paper.sh papers/reflector
#   ./scripts/build-paper.sh reflector
#   ./scripts/build-paper.sh --all
#
# Requirements:
#   - latexmk
#   - pdflatex or xelatex
#   - biber (for biblatex)

set -euo pipefail

TARGET="${1:-}"

if [[ -z "${TARGET}" ]]; then
  echo "Usage: $0 <paper-path|paper-slug|--all>" >&2
  echo "Examples: $0 papers/reflector | $0 reflector | $0 --all" >&2
  exit 1
fi

build_one() {
  local paper_dir="$1"
  local paper_tex="${paper_dir}/paper.tex"

  if [[ ! -d "${paper_dir}" ]]; then
    echo "Error: Directory '${paper_dir}' not found." >&2
    exit 1
  fi

  if [[ ! -f "${paper_tex}" ]]; then
    echo "Error: '${paper_tex}' not found." >&2
    exit 1
  fi

  echo "Building: ${paper_tex}"
  echo "Output:   ${paper_dir}/.cache/out/"

  (
    cd "${paper_dir}"

    mkdir -p ".cache/aux" ".cache/out"

    latexmk \
      -pdf \
      -interaction=nonstopmode \
      -synctex=1 \
      -file-line-error \
      -shell-escape \
      -f \
      -gg \
      -cd \
      -r ".latexmkrc" \
      "paper.tex"
  )

  echo ""
  echo "Build complete: ${paper_dir}/.cache/out/paper.pdf"
}

if [[ "${TARGET}" == "--all" ]]; then
  mapfile -t PAPER_DIRS < <(
    find "papers" -mindepth 1 -maxdepth 1 -type d -exec test -f "{}/paper.tex" \; -print | sort
  )

  if [[ "${#PAPER_DIRS[@]}" -eq 0 ]]; then
    echo "Error: No paper directories found under papers/." >&2
    exit 1
  fi

  for paper_dir in "${PAPER_DIRS[@]}"; do
    build_one "${paper_dir}"
  done
else
  PAPER_DIR="${TARGET}"

  if [[ ! -d "${PAPER_DIR}" && -d "papers/${TARGET}" ]]; then
    PAPER_DIR="papers/${TARGET}"
  fi

  build_one "${PAPER_DIR}"
fi

