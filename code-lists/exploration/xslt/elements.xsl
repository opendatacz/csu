<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY xsd     "http://www.w3.org/2001/XMLSchema#">
]>
<xsl:stylesheet
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:local="http://localhost/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xsd"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC" />
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/EXPORT">
        <void:Dataset>
            <dcterms:identifier>
                <xsl:value-of select="string-join(INFO/OBSAH/*/KODCIS/text(), '-')"/>
            </dcterms:identifier>
            <dcterms:type xml:lang="cs">
                <xsl:value-of select="INFO/TYPEXP/text()"/>
            </dcterms:type>
            <local:isEmpty rdf:datatype="&xsd;boolean">
                <xsl:value-of select="not(boolean(DATA/*))"/>
            </local:isEmpty>
            <local:hasAttributes rdf:datatype="&xsd;boolean">
                <xsl:value-of select="boolean(DATA/POLOZKA/ATRIBUTY[not(normalize-space()='')])"/>
            </local:hasAttributes>
            <xsl:for-each-group select="//*[not(normalize-space()='')]" group-by="name()">
                <void:propertyPartition>
                    <rdf:Description>
                        <void:property><xsl:value-of select="current-grouping-key()"/></void:property>
                        <void:triples rdf:datatype="&xsd;integer">
                          <xsl:value-of select="count(current-group())"/>
                        </void:triples>
                    </rdf:Description>
                </void:propertyPartition>
            </xsl:for-each-group>
            <xsl:for-each-group select="DATA/POLOZKA/ATRIBUTY/ATR[not(normalize-space()='')]" group-by="@akronym">
                <void:propertyPartition>
                    <rdf:Description>
                      <void:property>
                        <xsl:value-of select="concat('ATR-', current-grouping-key())"/>
                      </void:property>
                      <void:triples rdf:datatype="&xsd;integer">
                        <xsl:value-of select="count(current-group())"/>
                      </void:triples>
                    </rdf:Description>
                </void:propertyPartition>
            </xsl:for-each-group>
        </void:Dataset>
    </xsl:template>
</xsl:stylesheet>
