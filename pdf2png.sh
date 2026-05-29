#!/usr/bin/env bash
#
# pdf2png.sh — Convert all PDFs in a directory to high-resolution PNGs.
#
# Usage:
#   ./pdf2png.sh [DIRECTORY] [DPI]
#
#   DIRECTORY  Folder containing .pdf files. Defaults to current directory.
#   DPI        Output resolution. Defaults to 600.
#
# Output:
#   For a single-page PDF "report.pdf"  -> report.png
#   For a multi-page PDF "report.pdf"   -> report-1.png, report-2.png, ...
#
# Requires: pdftoppm (from poppler-utils).

set -euo pipefail

DIR="${1:-.}"
DPI="${2:-600}"

# Check dependency
if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "Error: pdftoppm not found. Install it with: sudo pacman -S poppler-utils" >&2
  exit 1
fi

# Check directory
if [[ ! -d "$DIR" ]]; then
  echo "Error: '$DIR' is not a directory." >&2
  exit 1
fi

shopt -s nullglob
pdfs=("$DIR"/*.pdf "$DIR"/*.PDF)

if [[ ${#pdfs[@]} -eq 0 ]]; then
  echo "No PDF files found in '$DIR'."
  exit 0
fi

for pdf in "${pdfs[@]}"; do
  base="${pdf%.*}"          # strip .pdf / .PDF extension, keep full path
  name="$(basename "$base")"
  echo "Converting: $name.pdf (at ${DPI} DPI)"

  # Count pages to decide on naming.
  pages="$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/ {print $2}')"

  if [[ "${pages:-0}" -eq 1 ]]; then
    # Single page: produce exactly "<name>.png" with no page suffix.
    pdftoppm -png -r "$DPI" -singlefile "$pdf" "$base"
  else
    # Multi-page: "<name>-1.png", "<name>-2.png", ...
    pdftoppm -png -r "$DPI" "$pdf" "$base"
  fi
done

echo "Done."
