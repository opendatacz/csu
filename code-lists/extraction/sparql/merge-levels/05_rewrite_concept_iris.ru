PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX skos:    <http://www.w3.org/2004/02/skos/core#>

DELETE {
  ?_concept ?outP ?outO .
  ?inS ?inP ?_concept .
}
INSERT {
  ?concept ?outP ?outO .
  ?inS ?inP ?concept .
}
WHERE {
  {
    SELECT DISTINCT ?_concept ?concept
    WHERE {
      ?_concept skos:inScheme/dcterms:identifier ?identifier .
      FILTER (!strstarts(str(?_concept), concat("https://csu.opendata.cz/zdroj/", ?identifier)))
      ?_concept skos:notation ?notation .
      BIND (iri(concat("https://csu.opendata.cz/zdroj/",
                      ?identifier,
                      "/pojem/",
                      encode_for_uri(?notation)
                      )) AS ?concept)
    }
  }
  ?_concept ?outP ?outO .
  OPTIONAL {
    ?inS ?inP ?_concept .
  }
}
