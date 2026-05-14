#!/usr/bin/env bash
# build-paper.sh — Build a LaTeX paper to PDF.
#
# Usage:
#   ./scripts/build-paper.sh <paper-path>
#
# Example:
#   ./scripts/build-paper.sh papers/reflector
#
# Requirements:
#   - latexmk
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

echo "Building: ${PAPER_TEX}"
echo "Output:   ${BUILD_DIR}/"

latexmk \
  -pdf \
  -bibtex \
  -outdir="${BUILD_DIR}" \
  -interaction=nonstopmode \
  -file-line-error \
  "${PAPER_TEX}"

echo ""
echo "Build complete: ${BUILD_DIR}/paper.pdf"

