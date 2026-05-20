#!/usr/bin/env bash
# build-paper.sh — Build LaTeX paper(s) to PDF.

set -euo pipefail

REPOSITORY_ROOT="$(git rev-parse --show-toplevel)"
PAPERS_DIRECTORY="${REPOSITORY_ROOT}/papers"

DEFAULT_PAPER="reflector"
BUILD_ALL=false
OPEN_PDF=false
TARGET="${DEFAULT_PAPER}"

usage() {
cat <<USAGE
Usage:
  ./scripts/build-paper.sh <paper-name|paper-path>
  ./scripts/build-paper.sh --all
  ./scripts/build-paper.sh <paper-name|paper-path> --open
USAGE
}

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

resolve_paper_directory() {
    local input="$1"

    if [[ -d "${input}" ]]; then
        printf '%s\n' "${input}"
        return
    fi

    if [[ -d "${PAPERS_DIRECTORY}/${input}" ]]; then
        printf '%s\n' "${PAPERS_DIRECTORY}/${input}"
        return
    fi

    if [[ -d "${REPOSITORY_ROOT}/${input}" ]]; then
        printf '%s\n' "${REPOSITORY_ROOT}/${input}"
        return
    fi

    printf '%s\n' "${PAPERS_DIRECTORY}/${input}"
}

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
            TARGET="$1"
            shift
            ;;
    esac
done

build_paper() {
    local target="$1"
    local paper_directory

    paper_directory="$(resolve_paper_directory "${target}")"

    local paper_file="${paper_directory}/paper.tex"
    local latexmkrc_file="${paper_directory}/.latexmkrc"
    local output_directory="${paper_directory}/.cache/out"
    local output_pdf="${output_directory}/paper.pdf"

    if [[ ! -d "${paper_directory}" ]]; then
        echo "Error: Directory '${paper_directory}' not found." >&2
        exit 1
    fi

    if [[ ! -f "${paper_file}" ]]; then
        echo "Error: Missing paper.tex at '${paper_file}'." >&2
        exit 1
    fi

    if [[ ! -f "${latexmkrc_file}" ]]; then
        echo "Error: Missing .latexmkrc at '${latexmkrc_file}'." >&2
        exit 1
    fi

    echo "Building: ${paper_file}"
    echo "Output:   ${output_directory}/"

    (
        cd "${paper_directory}"

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

    if [[ ! -f "${output_pdf}" ]]; then
        echo "Error: Expected PDF not found at '${output_pdf}'." >&2
        exit 1
    fi

    echo "Build complete: ${output_pdf}"

    if [[ "${OPEN_PDF}" == "true" ]]; then
        open_pdf "${output_pdf}"
    fi
}

if [[ "${BUILD_ALL}" == "true" ]]; then
    mapfile -t PAPER_DIRECTORIES < <(
        find "${PAPERS_DIRECTORY}" -mindepth 1 -maxdepth 1 -type d | sort
    )

    for directory in "${PAPER_DIRECTORIES[@]}"; do
        if [[ -f "${directory}/paper.tex" ]]; then
            build_paper "${directory}"
        fi
    done
else
    build_paper "${TARGET}"
fi
