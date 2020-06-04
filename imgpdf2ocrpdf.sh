#!/bin/bash
#
# INFO: Convert PDF with scanned pages to 'OCR' PDF
#
# AUTHOR: emeric_legrand-at-yahoo.fr
#
# PACKAGES NEEDED: ghostscript tesseract-ocr tesseract-ocr-fra imagemagick-6.q16 poppler-utils xpdf
#
# USAGE: 

TMPDIR=./temp/
PDFFILE=$1
FILENAME=$(basename -- "$PDFFILE")
BASENAME="${FILENAME%.*}"
NUMBER_OF_PAGES=$(pdfinfo "${PDFFILE}" | grep Pages | sed 's/[^0-9]*//')

mkdir $TMPDIR

for i in $(seq 1 $NUMBER_OF_PAGES); do
  # Convert to PNG
  gs -sDEVICE=pngalpha       \
     -dTextAlphaBits=4       \
     -dFirstPage="${i}"      \
     -dLastPage="${i}"       \
     -o "${TMPDIR}/page-${i}.png"        \
     -r300 "${PDFFILE}"

  # Do OCR
  tesseract ${TMPDIR}/page-${i}.png ${TMPDIR}/page-${i} -l fra pdf
done

# Concatenate pages
echo "Creating final PDF document..."
pdfunite ${TMPDIR}/page-[1-$NUMBER_OF_PAGES].pdf ${BASENAME}-ocr.pdf

# Remove temp folder
echo "Removing temporary files..."
rm -r $TMPDIR

echo "End!"