#!/bin/bash
# 
# Downloads XML distributions of code lists by the Czech Statistical Office.
# The code lists are saved in the directory where this script is invoked.
# It prints a CSV with data on the file transfers. 

set -e

die () {
  echo >&2 "$@"
  exit 1
}

# Test if curl is installed.
command -v curl >/dev/null 2>&1 || die "Missing curl. Please install it."

ENDPOINT="https://nkod.opendata.cz/sparql"
QUERY=$(cat <<-END
PREFIX dcat:     <http://www.w3.org/ns/dcat#>
PREFIX dcterms:  <http://purl.org/dc/terms/>

SELECT DISTINCT ?url
WHERE {
  [] a dcat:Dataset ;
    dcterms:publisher <https://linked.opendata.cz/zdroj/ekonomický-subjekt/00025593> ;
    dcat:keyword "číselník"@cs ;
    dcat:distribution ?distribution .
  ?distribution dcterms:format <http://publications.europa.eu/resource/authority/file-type/XML> ;
    dcat:downloadURL ?url .
}
ORDER BY ?url
END)

echo "url_effective,filename_effective,http_code,time_starttransfer"

curl -s -H "Accept:text/csv" --data-urlencode "query=$QUERY" $ENDPOINT |
  tail -n+2 |
  xargs -n 1 curl -s -JO -w "%{url_effective},%{filename_effective},%{http_code},%{time_starttransfer}\n"
