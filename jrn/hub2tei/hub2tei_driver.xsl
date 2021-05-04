<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.w3.org/1996/css"
                xmlns:dbk="http://docbook.org/ns/docbook"
                xmlns:hub="http://transpect.io/hub"
                xmlns:hub2tei="http://transpect.io/hub2tei"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:docx2hub="http://transpect.io/docx2hub"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:tr="http://transpect.io"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="dbk docx2hub html hub2tei hub xlink css xs cx tr tei"
                version="2.0" 
                xpath-default-namespace="http://docbook.org/ns/docbook">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="http://this.transpect.io/a9s/ts/hub2tei/hub2tei_driver.xsl"/>

  <xsl:template match="*:chapter" mode="hub2tei:dbk2tei" priority="2">
    <xsl:param name="exclude" tunnel="yes" as="element(*)*"/>
    <xsl:if test="not(some $e in $exclude satisfies (. is $e))">
      <xsl:variable name="type" select="if (dbk:info[1]/dbk:title[matches(@role, '[a-z]{1,3}journalreviewheading')]) then 'book-review' else 'article'"/>
      <div type="{$type}">
        <xsl:if test="(./dbk:title[1]/@role or ./dbk:info[1]/@role)">
          <xsl:attribute name="rend" select="(./dbk:title[1]/@role, ./dbk:info[1]/@role)[1]"/>
        </xsl:if>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
