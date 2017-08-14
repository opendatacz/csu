PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX void: <http://rdfs.org/ns/void#>

DELETE {
  ?concept skos:inScheme ?subLevel .
}
INSERT {
  ?concept skos:inScheme ?topLevel .
}
WHERE {
  {
    SELECT ?topLevel ?subLevel
    WHERE {
      [] void:linkPredicate skos:narrower ;
        void:subjectsTarget ?topLevel .
      FILTER NOT EXISTS {
        [] void:objectsTarget ?topLevel ;
          void:linkPredicate skos:narrower .
      }

      ?topLevel (^void:subjectsTarget/void:objectsTarget)+ ?subLevel .
      [] void:objectsTarget ?subLevel ;
        void:linkPredicate skos:narrower .
    }
  }
  ?concept skos:inScheme ?subLevel .
}
