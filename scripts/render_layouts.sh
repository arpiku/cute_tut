#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${EXECUTABLE:-./main}"
PDLATEX="${PDLATEX:-pdflatex}"

if [ ! -x "${EXECUTABLE}" ]; then
  echo "error: executable '${EXECUTABLE}' not found or not executable" >&2
  exit 1
fi

# Run the demo executable to generate the .tex files in the current directory.
"${EXECUTABLE}"

shopt -s nullglob
tex_files=(*.tex)

if [ ${#tex_files[@]} -eq 0 ]; then
  echo "error: no .tex files were generated" >&2
  exit 1
fi

for tex_file in "${tex_files[@]}"; do
  echo "Compiling ${tex_file} -> ${tex_file%.tex}.pdf"
  "${PDLATEX}" -interaction=nonstopmode -halt-on-error "${tex_file}"
done

# Remove common LaTeX build artifacts, but keep the .tex and .pdf files.
rm -f -- *.aux *.log *.out *.fls *.fdb_latexmk *.toc *.synctex.gz

echo "Done. PDFs were generated in the current directory."
