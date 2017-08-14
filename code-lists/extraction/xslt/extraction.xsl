<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY dataset-type  "http://publications.europa.eu/resource/authority/dataset-type/">
    <!ENTITY skos          "http://www.w3.org/2004/02/skos/core#">
    <!ENTITY xsd           "http://www.w3.org/2001/XMLSchema#">
]>
<xsl:stylesheet
    xmlns:dbo="http://dbpedia.org/ontology/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:f="http://opendata.cz/xslt/functions#"
    xmlns:lang="http://id.loc.gov/vocabulary/iso639-1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:schema="http://schema.org/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:void="http://rdfs.org/ns/void#"
    exclude-result-prefixes="f"
    version="2.0">
    
    <!-- Global parameters -->
    
    <xsl:param name="domain">https://csu.opendata.cz/</xsl:param>
    <xsl:param name="ns" select="concat($domain, 'zdroj')"/>
    
    <!-- Functions -->
    
    <!-- Extract code list level from its identifier. -->
    <xsl:function name="f:extract-level" as="xsd:integer">
        <xsl:param name="identifier" as="xsd:string"/>
        <xsl:choose>
            <xsl:when test="contains($identifier, 'NUTS')">
                <xsl:value-of select="xsd:integer(replace($identifier, '^NUTS(\d+).*$', '$1'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xsd:integer(replace($identifier, '^.+(\d+)$', '$1'))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Guess if acronym indicates a code list level, i.e. ends with a number. -->
    <xsl:function name="f:is-level" as="xsd:boolean">
        <xsl:param name="acronym" as="xsd:string"/>
        <xsl:value-of select="matches($acronym, '^.+\d+$')"/>
    </xsl:function>
    
    <!-- Test if parent acronym indicates a parent level of the child acronym. --> 
    <xsl:function name="f:is-parent-level" as="xsd:boolean">
        <xsl:param name="parent-acronym" as="xsd:string"/>
        <xsl:param name="child-acronym" as="xsd:string"/>
        <xsl:value-of select="f:is-level($parent-acronym)
                              and
                              f:is-level($child-acronym)
                              and
                              (f:trim-level($parent-acronym) = f:trim-level($child-acronym))
                              and
                              (f:extract-level($parent-acronym) + 1 = f:extract-level($child-acronym))"/>
     </xsl:function>
    
    <!-- Converts camelCase $text into kebab-case. -->
    <xsl:function name="f:kebab-case" as="xsd:string">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="f:slugify(replace($text, '(\p{Ll})(\p{Lu})', '$1-$2'))"/>
    </xsl:function>
    
    <!-- Removes whitespace -->
    <xsl:function name="f:removeWhitespace" as="xsd:string">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="replace($text, '\s', '')"/>
    </xsl:function>
    
    <!-- Converts $text into URI-safe slug. -->
    <xsl:function name="f:slugify" as="xsd:anyURI">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
    </xsl:function>
    
    <!-- Trims leading and trailing whitespace -->
    <xsl:function name="f:trim" as="xsd:string">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="replace($text, '^\s+|\s+$', '')"/>
    </xsl:function>
    
    <!-- Trim code list level from its identifier. -->
    <xsl:function name="f:trim-level" as="xsd:string">
        <xsl:param name="identifier" as="xsd:string"/>
        <xsl:choose>
            <xsl:when test="contains($identifier, 'NUTS')">
                <xsl:value-of select="replace($identifier, 'NUTS\d+', 'NUTS')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($identifier, '\d+$', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Output -->
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC" />
    <xsl:strip-space elements="*"/>
    
    <!-- Templates -->
    
    <xsl:template match="/">
        <xsl:variable name="code">
            <xsl:choose>
                <xsl:when test="EXPORT/INFO/OBSAH/CISELNIK">
                    <xsl:value-of select="EXPORT/INFO/OBSAH/CISELNIK/KODCIS"/>
                </xsl:when>
                <xsl:when test="EXPORT/INFO/OBSAH/VAZBA">
                    <xsl:value-of select="string-join(EXPORT/INFO/OBSAH/VAZBA/KODCIS, '-')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="lang" select="lower-case(EXPORT/INFO/KODJAZ/text())"/>
        <xsl:variable name="type-code" select="EXPORT/INFO/TYPEXP/@kod"/>
        
        <rdf:RDF>
            <xsl:apply-templates select="EXPORT[$type-code = '1']" mode="code-list">
                <xsl:with-param name="class" select="concat($domain, 'slovník/', $code)" tunnel="yes"/>
                <xsl:with-param name="dataset" select="concat($ns, 'řízený-slovník/', $code)" tunnel="yes"/>
                <xsl:with-param name="resource-ns"
                  select="concat($ns, 'řízený-slovník/', $code, '/')"
                  tunnel="yes"/>
                <xsl:with-param name="lang" select="$lang" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="EXPORT[$type-code = '3']" mode="mapping">
                <xsl:with-param name="dataset" select="concat($ns, 'mapování/', $code)" tunnel="yes"/>
            </xsl:apply-templates>
        </rdf:RDF>
    </xsl:template>
    
    <!-- Code list templates -->
    
    <xsl:template match="EXPORT" mode="code-list">
        <xsl:param name="class" tunnel="yes"/>
        <xsl:param name="dataset" tunnel="yes"/>
        <xsl:param name="lang" tunnel="yes"/>
        
        <skos:ConceptScheme rdf:about="{$dataset}">
            <dcterms:type rdf:resource="&dataset-type;CODE_LIST"/>
            <dcterms:language rdf:resource="http://id.loc.gov/vocabulary/iso639-1/{$lang}"/>
            <xsl:apply-templates select="INFO/OBSAH/CISELNIK" mode="code-list"/>
        </skos:ConceptScheme>
        <rdfs:Class rdf:about="{$class}">
            <rdfs:subClassOf rdf:resource="&skos;Concept"/>
            <rdfs:seeAlso rdf:resource="{$dataset}"/>
        </rdfs:Class>
        <xsl:apply-templates select="DATA" mode="code-list"/>
    </xsl:template>
    
    <xsl:template match="AKRCIS" mode="code-list">
        <!-- Akronym číselníku -->
        <dbo:abbreviation><xsl:value-of select="text()"/></dbo:abbreviation>
    </xsl:template>
    
    <xsl:template match="KODCIS" mode="code-list">
        <!-- Kód číselníku -->
        <dcterms:identifier><xsl:value-of select="text()"/></dcterms:identifier>
    </xsl:template>
    
    <xsl:template match="NAZEV" mode="code-list">
        <!-- Plný název číselníku -->
        <xsl:param name="lang" tunnel="yes"/>
        <rdfs:label xml:lang="{$lang}"><xsl:value-of select="text()"/></rdfs:label>
    </xsl:template>
    
    <xsl:template match="DATA/POLOZKA" mode="code-list">
        <xsl:param name="class" tunnel="yes"/>
        <xsl:param name="dataset" tunnel="yes"/>
        <xsl:param name="resource-ns" tunnel="yes"/>
        <xsl:variable name="concept" select="concat($resource-ns, 'pojem/', CHODNOTA/text())"/>
        <skos:Concept rdf:about="{$concept}">
            <rdf:type rdf:resource="{$class}"/>
            <skos:inScheme rdf:resource="{$dataset}"/>
            <xsl:apply-templates mode="code-list"/>
            <dcterms:valid>
              <xsl:variable name="validity-key"
                select="concat(ADMPLOD/text(), '-',
                               if (ADMNEPO/text() != '9999-09-09') then ADMNEPO/text() else '')"/>
                <schema:Event rdf:about="{concat($ns, 'událost/', $validity-key)}">
                    <xsl:apply-templates mode="validity"/>
                </schema:Event>
            </dcterms:valid>
        </skos:Concept>
        <xsl:apply-templates select="ATRIBUTY" mode="attributes">
            <xsl:with-param name="concept" select="$concept" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="ADMPLOD" mode="validity">
        <!-- Počátek platnosti položky -->
        <schema:startDate rdf:datatype="&xsd;date"><xsl:value-of select="text()"/></schema:startDate>
    </xsl:template>
    
    <xsl:template match="ADMNEPO[text() != '9999-09-09']" mode="validity">
        <!-- Konec platnosti položky -->
        <schema:endDate rdf:datatype="&xsd;date"><xsl:value-of select="text()"/></schema:endDate>
    </xsl:template>
    
    <xsl:template match="ATRIBUTY" mode="attributes">
        <!-- Atribut položky číselníku -->
        <xsl:apply-templates mode="attributes"/>
    </xsl:template>
    
    <xsl:template match="ATR[not(normalize-space() = '')]" mode="attributes">
        <!-- Hodnota atributu -->
        <!-- FIXME: Abusing RDF reification vocabulary to represent arbitrary attribute-value pairs. -->
        <xsl:param name="concept" tunnel="yes"/>
        <rdf:Statement>
            <rdf:subject rdf:resource="{$concept}"/>
            <rdf:predicate><xsl:value-of select="@akronym"/></rdf:predicate>
            <rdf:object><xsl:value-of select="text()"/></rdf:object>
        </rdf:Statement>
    </xsl:template>
    
    <xsl:template match="CHODNOTA" mode="code-list">
        <!-- Kód položky číselníku (znakový) -->
        <skos:notation><xsl:value-of select="text()"/></skos:notation>
    </xsl:template>
    
    <xsl:template match="DEFINICE[not(normalize-space() = '')]" mode="code-list">
        <!-- Definice obsahu -->
        <skos:definition><xsl:value-of select="text()"/></skos:definition>
    </xsl:template>
    
    <xsl:template match="TEXT" mode="code-list">
        <!-- Plný text položky číselníku -->
        <xsl:param name="lang" tunnel="yes"/>
        <skos:prefLabel xml:lang="{$lang}"><xsl:value-of select="text()"/></skos:prefLabel>
    </xsl:template>
    
    <xsl:template match="ZKRTEXT[text() != TEXT/text()]" mode="code-list">
        <!-- Zkrácený text položky číselníku -->
        <xsl:param name="lang" tunnel="yes"/>
        <skos:altLabel xml:lang="{$lang}"><xsl:value-of select="text()"/></skos:altLabel>
    </xsl:template>
    
    <!-- Mapping templates -->
    
    <xsl:template match="EXPORT" mode="mapping">
        <xsl:param name="dataset" tunnel="yes"/>
        <xsl:variable name="source-code" select="INFO/OBSAH/VAZBA[@ref = '1']/KODCIS/text()"/>
        <xsl:variable name="target-code" select="INFO/OBSAH/VAZBA[@ref = '2']/KODCIS/text()"/>
        <xsl:variable name="source-abbreviation" select="INFO/OBSAH/VAZBA[@ref = '1']/AKRCIS/text()"/>
        <xsl:variable name="target-abbreviation" select="INFO/OBSAH/VAZBA[@ref = '2']/AKRCIS/text()"/>
        
        <xsl:variable name="link-predicate">
            <xsl:choose>
                <xsl:when test="f:is-parent-level($source-abbreviation, $target-abbreviation)">skos:narrower</xsl:when>
                <xsl:otherwise>skos:relatedMatch</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <void:Linkset rdf:about="{$dataset}">
            <dcterms:type rdf:resource="&dataset-type;MAPPING"/>
            <dcterms:identifier>
              <xsl:value-of select="concat($source-code, '-', $target-code)"/>
            </dcterms:identifier>
            <void:subjectsTarget rdf:resource="{concat($ns, 'řízený-slovník/', $source-code)}"/>
            <void:objectsTarget rdf:resource="{concat($ns, 'řízený-slovník/', $target-code)}"/>
            <void:linkPredicate rdf:resource="{replace($link-predicate, 'skos:', '&skos;')}"/>
        </void:Linkset>
        <xsl:apply-templates select="DATA" mode="mapping">
            <xsl:with-param name="source-ns" select="concat($ns, 'řízený-slovník/', $source-code, '/pojem/')"/>
            <xsl:with-param name="target-ns" select="concat($ns, 'řízený-slovník/', $target-code, '/pojem/')"/>
            <xsl:with-param name="link-predicate" select="$link-predicate"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="POLOZKA" mode="mapping">
        <xsl:param name="source-ns"/>
        <xsl:param name="target-ns"/>
        <xsl:param name="link-predicate"/>
        <rdf:Description rdf:about="{concat($source-ns, POLVAZ[@ref = '1']/CHODNOTA/text())}">
            <xsl:element name="{$link-predicate}">
              <xsl:attribute name="rdf:resource"
                select="concat($target-ns, POLVAZ[@ref = '2']/CHODNOTA/text())"/>
            </xsl:element>
        </rdf:Description>
    </xsl:template>
    
    <!-- Catch-all empty template -->
    <xsl:template match="text()|@*" mode="#all"/>
</xsl:stylesheet>