PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

DELETE {
  ?s skos:narrowMatch ?o .
}
INSERT {
  ?s skos:narrower ?o .
}
WHERE {
  ?s skos:narrowMatch ?o .
}
