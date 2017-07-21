PREFIX skos:   <http://www.w3.org/2004/02/skos/core#>

DELETE {
  ?source skos:definition ?definition .
}
INSERT {
  ?source skos:prefLabel ?label .
}
WHERE {
  ?source skos:definition ?definition .
  BIND (strlang(strafter(str(?definition), "Oficiální zkrácený název: "), "cs") AS ?label)
}
