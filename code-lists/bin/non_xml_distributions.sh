#!/bin/bash
#
# Print file names of code lists in XML that have lack the EXPORT element
# Usage: ./non_xml_distributions.sh directory

set -e

die () {
  echo >&2 "$@"
  exit 1
}

# Test if xmllint is installed.
command -v xmllint >/dev/null 2>&1 || die "Missing xmllint. Please install it."

for codelist in ${1%/}/*; do
  xmllint --xpath "/EXPORT" $codelist > /dev/null 2>&1 || basename $codelist;
done
