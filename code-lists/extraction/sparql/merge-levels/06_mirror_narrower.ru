PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT {
  ?b skos:broader ?a .
}
WHERE {
  ?a skos:narrower ?b .
}
