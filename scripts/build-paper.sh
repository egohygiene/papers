#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# reflector paper build script
###############################################################################

REPOSITORY_ROOT="$(git rev-parse --show-toplevel)"

PAPERS_DIRECTORY="${REPOSITORY_ROOT}/papers"

DEFAULT_PAPER="reflector"

BUILD_ALL=false

OPEN_PDF=false

PAPER_NAME="${DEFAULT_PAPER}"

###############################################################################
# usage
###############################################################################

usage() {
cat <<EOF
Usage:

  ./scripts/build-paper.sh <paper-name>

Examples:

  ./scripts/build-paper.sh reflector

  ./scripts/build-paper.sh --all

  ./scripts/build-paper.sh reflector --open

EOF
}

###############################################################################
# open pdf helper
###############################################################################

open_pdf() {
    local pdf_file="$1"

    if [[ ! -f "${pdf_file}" ]]; then
        return
    fi

    case "${OSTYPE}" in
        darwin*)
            open "${pdf_file}"
            ;;
        linux*)
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "${pdf_file}"
            fi
            ;;
        msys*|cygwin*|win32*)
            start "${pdf_file}"
            ;;
    esac
}

###############################################################################
# parse arguments
###############################################################################

if [[ $# -eq 0 ]]; then
    PAPER_NAME="${DEFAULT_PAPER}"
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            BUILD_ALL=true
            shift
            ;;
        --open)
            OPEN_PDF=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            PAPER_NAME="$1"
            shift
            ;;
    esac
done

###############################################################################
# build single paper
###############################################################################

build_paper() {
    local paper_name="$1"

    local paper_directory="${PAPERS_DIRECTORY}/${paper_name}"

    local paper_file="${paper_directory}/paper.tex"

    local latexmkrc_file="${paper_directory}/.latexmkrc"

    local output_directory="${paper_directory}/.cache/out"

    local auxiliary_directory="${paper_directory}/.cache/aux"

    local output_pdf="${output_directory}/paper.pdf"

    if [[ ! -d "${paper_directory}" ]]; then
        echo ""
        echo "[ERROR] Paper does not exist:"
        echo "        ${paper_name}"
        echo ""
        exit 1
    fi

    if [[ ! -f "${paper_file}" ]]; then
        echo ""
        echo "[ERROR] Missing paper.tex:"
        echo "        ${paper_file}"
        echo ""
        exit 1
    fi

    if [[ ! -f "${latexmkrc_file}" ]]; then
        echo ""
        echo "[ERROR] Missing .latexmkrc:"
        echo "        ${latexmkrc_file}"
        echo ""
        exit 1
    fi

    echo ""
    echo "========================================="
    echo "Building paper"
    echo "========================================="
    echo "Paper      : ${paper_name}"
    echo "Source     : ${paper_file}"
    echo "Output Dir : ${output_directory}"
    echo "Aux Dir    : ${auxiliary_directory}"
    echo "Rc File    : ${latexmkrc_file}"
    echo "========================================="
    echo ""

    cd "${paper_directory}"

    latexmk \
        -pdf \
        -interaction=nonstopmode \
        -synctex=1 \
        -file-line-error \
        -shell-escape \
        -f \
        -gg \
        -r ".latexmkrc" \
        "paper.tex"

    echo ""
    echo "========================================="
    echo "Build complete"
    echo "========================================="
    echo ""

    if [[ -f "${output_pdf}" ]]; then
        echo "PDF generated:"
        echo "  ${output_pdf}"
        echo ""
    else
        echo "[ERROR] Expected PDF not found:"
        echo "  ${output_pdf}"
        echo ""
        exit 1
    fi

    if [[ "${OPEN_PDF}" == "true" ]]; then
        open_pdf "${output_pdf}"
    fi
}

###############################################################################
# build all papers
###############################################################################

if [[ "${BUILD_ALL}" == "true" ]]; then

    mapfile -t PAPER_DIRECTORIES < <(
        find "${PAPERS_DIRECTORY}" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            | sort
    )

    for directory in "${PAPER_DIRECTORIES[@]}"; do
        build_paper "$(basename "${directory}")"
    done

else
    build_paper "${PAPER_NAME}"

fi
