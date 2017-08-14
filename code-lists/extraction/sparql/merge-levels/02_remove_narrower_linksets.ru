PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX void: <http://rdfs.org/ns/void#>

DELETE {
  ?linkset ?p ?o .
}
WHERE {
  ?linkset void:linkPredicate skos:narrower ;
    ?p ?o .
}
