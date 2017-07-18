PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX void: <http://rdfs.org/ns/void#>

DELETE {
  ?conceptScheme ?p ?o .
  ?class ?classP ?classO .
  ?concept a ?class .
}
WHERE {
  [] void:linkPredicate skos:narrowMatch ;
    void:objectsTarget ?conceptScheme .
  ?conceptScheme ?p ?o .
  ?class rdfs:seeAlso ?conceptScheme ;
    ?classP ?classO .
  ?concept a ?class .
}
