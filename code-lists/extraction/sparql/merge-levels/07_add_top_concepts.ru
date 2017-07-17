PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

INSERT {
  ?conceptScheme skos:hasTopConcept ?topConcept .
  ?topConcept skos:topConceptOf ?conceptScheme .
}
WHERE {
  ?topConcept skos:inScheme ?conceptScheme .
  FILTER NOT EXISTS {
    ?topConcept skos:broader [] .
  }
}
