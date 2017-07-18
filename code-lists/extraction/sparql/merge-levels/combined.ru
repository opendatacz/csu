PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX skos:    <http://www.w3.org/2004/02/skos/core#>
PREFIX void:    <http://rdfs.org/ns/void#>

####################
### Merge levels ###
####################

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
      [] void:linkPredicate skos:narrowMatch ;
        void:subjectsTarget ?topLevel .
      FILTER NOT EXISTS {
        [] void:objectsTarget ?topLevel ;
          void:linkPredicate skos:narrowMatch .
      }

      ?topLevel (^void:subjectsTarget/void:objectsTarget)+ ?subLevel .
      [] void:objectsTarget ?subLevel ;
        void:linkPredicate skos:narrowMatch .
    }
  }
  ?concept skos:inScheme ?subLevel .
}
;

########################################
### Remove skos:narrowMatch linksets ###
########################################

DELETE {
  ?linkset ?p ?o .
}
WHERE {
  ?linkset void:linkPredicate skos:narrowMatch ;
    ?p ?o .
}
;

#######################################
### Remove sublevel concept schemes ###
#######################################

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
;

############################
### Map skos:narrowMatch ###
############################

DELETE {
  ?s skos:narrowMatch ?o .
}
INSERT {
  ?s skos:narrower ?o .
}
WHERE {
  ?s skos:narrowMatch ?o .
}
;

############################
### Rewrite concept IRIs ###
############################

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
      FILTER (!strstarts(str(?_concept), concat("https://csu.opendata.cz/zdroj/řízený-slovník/", ?identifier)))
      ?_concept skos:notation ?notation .
      BIND (iri(concat("https://csu.opendata.cz/zdroj/řízený-slovník/",
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
;

#######################
### Mirror narrower ###
#######################

INSERT {
  ?b skos:broader ?a .
}
WHERE {
  ?a skos:narrower ?b .
}
;

########################
### Add top concepts ###
########################

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
