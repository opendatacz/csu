PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

DELETE {
  ?concept skos:prefLabel ?_label .
}
INSERT {
  ?concept skos:prefLabel ?label .
}
WHERE {
  ?concept skos:prefLabel ?_label .
  BIND (strlang(lcase(str(?_label)), "cs") AS ?label)
}
