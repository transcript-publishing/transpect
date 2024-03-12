<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  

  
  <xsl:template match="*:title | *:subtitle | *:doi | *:vol_no | *:serial_title"  mode="klopotek-to-keyword"  priority="2">
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
                              'catchwords':'Schlagworte',
                              'serial_title':'Reihe',
                              'vol_no':'Bandnummer'
                              }"/>
    <xsl:value-of select="map:get($klopotek-roles, $role)"/>
  </xsl:function>

  <xsl:template match="*"  mode="klopotek-to-keyword" priority="-0.5"/>


  <xsl:template match="*:copyright_holders"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->

    <xsl:for-each-group select="*:copyright_holder" group-by="*:cpr_type">
      <xsl:if test="current-grouping-key() = ('VE', 'HG', 'UMSA')">
        <keyword role="{current-group()[1]/*:cpr_type/@term}">      
          <xsl:choose>
            <xsl:when test="count(current-group()) gt 1">
              <xsl:for-each select="current-group()">
                <para>
                  <xsl:sequence select="concat(*:first_name, ' ', *:last_name)"/>
                </para>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="concat(current-group()/*:first_name, ' ', current-group()/*:last_name)"/>
            </xsl:otherwise>
          </xsl:choose>
        </keyword>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>
    
  <xsl:template match="*:copyright_holders/*:copyright_holder[*:cpr_type = 'UMSA']"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <keyword role="Umschlagabbildung">
      <xsl:apply-templates select="node()" mode="#current"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:serial_relation"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:serial_relation/*:vol_name"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <keyword role="Bandbezeichnung">
      <xsl:apply-templates select="@term" mode="#current"/>
    </keyword>
  </xsl:template>
  
</xsl:stylesheet>
