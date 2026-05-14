#!/usr/bin/env bash
# watch-paper.sh — Watch a LaTeX paper directory and rebuild on changes.
#
# Usage:
#   ./scripts/watch-paper.sh <paper-path>
#
# Example:
#   ./scripts/watch-paper.sh papers/reflector
#
# Requirements:
#   - latexmk (with -pvc flag for continuous preview)
#   - pdflatex or xelatex
#   - biber (for biblatex)

set -euo pipefail

PAPER_DIR="${1:-}"

if [[ -z "${PAPER_DIR}" ]]; then
  echo "Usage: $0 <paper-path>" >&2
  echo "Example: $0 papers/reflector" >&2
  exit 1
fi

if [[ ! -d "${PAPER_DIR}" ]]; then
  echo "Error: Directory '${PAPER_DIR}' not found." >&2
  exit 1
fi

PAPER_TEX="${PAPER_DIR}/paper.tex"

if [[ ! -f "${PAPER_TEX}" ]]; then
  echo "Error: '${PAPER_TEX}' not found." >&2
  exit 1
fi

BUILD_DIR="${PAPER_DIR}/build"
mkdir -p "${BUILD_DIR}"

echo "Watching: ${PAPER_DIR}/"
echo "Output:   ${BUILD_DIR}/"
echo "Press Ctrl+C to stop."
echo ""

latexmk \
  -pdf \
  -bibtex \
  -outdir="${BUILD_DIR}" \
  -interaction=nonstopmode \
  -file-line-error \
  -pvc \
  "${PAPER_TEX}"
