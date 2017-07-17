PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX void: <http://rdfs.org/ns/void#>

DELETE {
  ?conceptScheme ?p ?o .
}
WHERE {
  [] void:linkPredicate skos:narrowMatch ;
    void:objectsTarget ?conceptScheme .
  ?conceptScheme ?p ?o .
}
