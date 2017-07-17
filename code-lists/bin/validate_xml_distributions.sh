#!/bin/bash
#
# Print file names of code lists in XML that have invalid syntax.
# Usage: ./validate_xml_distributions.sh directory

set -e

die () {
  echo >&2 "$@"
  exit 1
}

# Test if xmllint is installed.
command -v xmllint >/dev/null 2>&1 || die "Missing xmllint. Please install it."

for codelist in ${1%/}/*.xml; do
  xmllint --noout $codelist 2>/dev/null || basename $codelist
done
