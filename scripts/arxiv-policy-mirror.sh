#!/usr/bin/env bash

# ============================================================================
# arxiv-policy-mirror.sh
#
# Mirrors the arXiv policy documentation into the repository and generates
# a reproducibility manifest for deterministic publishing workflows.
#
# Usage:
#   ./scripts/arxiv-policy-mirror.sh
#
# Repository:
#   https://github.com/egohygiene/papers
# ============================================================================

set -o errexit
set -o nounset
set -o pipefail

# ============================================================================
# Configuration
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

readonly MIRROR_SOURCE_URL="https://info.arxiv.org/help/policies/index.html"

readonly MIRROR_OUTPUT_DIRECTORY="${REPOSITORY_ROOT}/docs/arxiv/mirror/policies"

readonly MANIFEST_OUTPUT_PATH="${REPOSITORY_ROOT}/docs/arxiv/manifest.json"

readonly USER_AGENT="Mozilla/5.0"

readonly HTTRACK_DEPTH="10"

readonly HTTRACK_SCOPE_INCLUDE="+info.arxiv.org/help/policies/*"

readonly HTTRACK_SCOPE_EXCLUDE="-*"

# ============================================================================
# Logging
# ============================================================================

log_info() {
    printf "[INFO] %s\n" "$*"
}

log_error() {
    printf "[ERROR] %s\n" "$*" >&2
}

# ============================================================================
# Utilities
# ============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Dependency Verification
# ============================================================================

verify_dependencies() {
    if ! command_exists "httrack"; then
        log_error "Missing required dependency: httrack"

        printf "\n"
        printf "Install httrack using one of the following:\n"
        printf "\n"

        printf "  macOS (Homebrew)\n"
        printf "    brew install httrack\n"
        printf "\n"

        printf "  Debian / Ubuntu\n"
        printf "    sudo apt-get install httrack\n"
        printf "\n"

        printf "  Arch Linux\n"
        printf "    sudo pacman --sync httrack\n"
        printf "\n"

        exit 1
    fi

    log_info "Verified dependency: httrack"
}

# ============================================================================
# Directory Initialization
# ============================================================================

initialize_directories() {
    mkdir -p "${MIRROR_OUTPUT_DIRECTORY}"

    mkdir -p "$(dirname "${MANIFEST_OUTPUT_PATH}")"

    log_info "Initialized output directories"
}

# ============================================================================
# arXiv Policy Mirror
# ============================================================================

mirror_arxiv_policies() {
    log_info "Starting arXiv policy mirror"

    log_info "Source URL:"
    log_info "${MIRROR_SOURCE_URL}"

    log_info "Output directory:"
    log_info "${MIRROR_OUTPUT_DIRECTORY}"

    httrack \
        "${MIRROR_SOURCE_URL}" \
        --path "${MIRROR_OUTPUT_DIRECTORY}" \
        "${HTTRACK_SCOPE_INCLUDE}" \
        "${HTTRACK_SCOPE_EXCLUDE}" \
        --depth="${HTTRACK_DEPTH}" \
        --robots=0 \
        --quiet \
        "--user-agent=${USER_AGENT}"

    log_info "Completed arXiv policy mirror"
}

# ============================================================================
# Manifest Generation
# ============================================================================

generate_manifest() {
    local mirrored_at_utc_timestamp

    mirrored_at_utc_timestamp="$(
        date --utc +"%Y-%m-%dT%H:%M:%SZ"
    )"

    cat > "${MANIFEST_OUTPUT_PATH}" <<EOF
{
    "publisher": "arxiv",
    "source": "${MIRROR_SOURCE_URL}",
    "mirrored_at": "${mirrored_at_utc_timestamp}",
    "tool": "httrack",
    "depth": ${HTTRACK_DEPTH},
    "user_agent": "${USER_AGENT}",
    "scope": "info.arxiv.org/help/policies/*",
    "output_directory": "docs/arxiv/mirror/policies"
}
EOF

    log_info "Generated manifest:"
    log_info "${MANIFEST_OUTPUT_PATH}"
}

# ============================================================================
# Main
# ============================================================================

main() {
    verify_dependencies

    initialize_directories

    mirror_arxiv_policies

    generate_manifest

    log_info "arXiv policy mirroring complete"
}

main "$@"
