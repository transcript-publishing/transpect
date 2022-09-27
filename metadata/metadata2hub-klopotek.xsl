<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  

  
  <xsl:template match="*:title | *:subtitle | *:doi"  mode="klopotek-to-keyword"  priority="2">
    <keyword role="{css:map-klopotek-to-keyword(name())}">
      <xsl:apply-templates select="node()" mode="#current"/>
    </keyword>
  </xsl:template>

  <xsl:function name="css:map-klopotek-to-keyword" as="xs:string">
    <xsl:param name="role" as="xs:string"/>
    <xsl:variable name="klopotek-roles" as="map(xs:string, xs:string)"
                  select="map{ 
                              'isbn':'ISBN',
                              'doi':'DOI',
                              'language':'Sprache',
                              'shorttitle':'Kurztitel',    
                              'title':'Titel',
                              'subtitle':'Untertitel',
                              'catchwords':'Schlagworte'
                              }"/>
    <xsl:value-of select="map:get($klopotek-roles, $role)"/>
  </xsl:function>

  <xsl:template match="*"  mode="klopotek-to-keyword" priority="-0.5"/>


</xsl:stylesheet>
