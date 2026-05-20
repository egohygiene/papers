# PAPER TITLE

**[Brief one-line description]**

## Status

🚧 **Draft** — Scaffold complete, sections in progress.

## Abstract

> TODO: Add abstract here.

## Directory Structure

```
PAPER-SLUG/
├── paper.tex               # Main LaTeX document
├── references.bib          # Bibliography
├── README.md               # This file
├── abstract.md             # Abstract draft (plain text)
├── outline.md              # Section outline
├── notes.md                # Research notes
├── roadmap.md              # Paper development roadmap
├── sections/               # LaTeX section files
├── figures/                # Generated figure exports (PDF, PNG)
├── diagrams/               # Source diagrams (Excalidraw)
├── assets/                 # Static assets
├── references/             # Reference documents
├── examples/               # Example artifacts
└── .cache/
    ├── aux/                # LaTeX auxiliary files
    └── out/                # Build output (paper.pdf)
```

## Building

```bash
# From repository root
./scripts/build-paper.sh papers/PAPER-SLUG
```
