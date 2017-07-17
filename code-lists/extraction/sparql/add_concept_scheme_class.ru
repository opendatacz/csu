PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos:    <http://www.w3.org/2004/02/skos/core#>

INSERT {
  ?class a rdfs:Class ;
    rdfs:subClassOf skos:Concept ;
    rdfs:seeAlso ?conceptScheme .
}
WHERE {
  ?conceptScheme a skos:ConceptScheme ;
    dcterms:identifier ?identifier .
  BIND (iri(concat("https://csu.opendata.cz/slovník/", ?identifier)) AS ?class)
}
;

INSERT {
  ?concept a ?class .
}
WHERE {
  ?concept skos:inScheme/^rdfs:seeAlso ?class .
}
