# papers

📚 Research papers, systems thinking, AI governance, reflective development architectures, and technical writing by Alan Szmyt.

## Papers

| Paper | Status | Description |
|-------|--------|-------------|
| [reflector](papers/reflector/README.md) | 🚧 Draft | Reflective Development Systems for Recursive AI-Augmented Software Engineering |

## Repository Structure

```
papers/
└── <paper-slug>/
    ├── paper.tex           # Main LaTeX document
    ├── references.bib      # BibTeX bibliography
    ├── README.md           # Paper overview
    ├── abstract.md         # Abstract draft
    ├── outline.md          # Section outline
    ├── notes.md            # Research notes
    ├── roadmap.md          # Paper development roadmap
    ├── sections/           # LaTeX section files
    ├── figures/            # Generated figure exports
    ├── diagrams/           # Source diagrams (Excalidraw, etc.)
    ├── assets/             # Static assets
    ├── references/         # Reference documents
    └── examples/           # Example artifacts
```

## Building Papers

```bash
# Build a specific paper
./scripts/build-paper.sh papers/reflector

# Build all papers
./scripts/build-paper.sh --all

# Watch and auto-rebuild during development
./scripts/watch-paper.sh papers/reflector
```

## Published Papers

Papers are automatically built and published to [GitHub Pages](https://egohygiene.github.io/papers/) on every push to `main`.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidelines.

## Roadmap

See [ROADMAP.md](./ROADMAP.md) for the development roadmap.
