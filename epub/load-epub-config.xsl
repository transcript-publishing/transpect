<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="cx xs"
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/iso-lang/xsl/iso-lang.xsl"/>
  
  <xsl:param name="cover-path" as="xs:string?"/>
  
  <xsl:variable name="epub-metadata" as="document-node(element(cx:documents))?"
                select="collection()[2]"/>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- cover not available in ONIX yet -->
  <xsl:template match="/epub-config/cover">
    <cover href="{$cover-path}" svg="true"/>
  </xsl:template>
  
  <xsl:template match="/epub-config/metadata">
    <xsl:copy>
      <dc:identifier format="EPUB3">
        <xsl:value-of select="$epub-metadata//string[preceding-sibling::*[1][. eq 'ePUB-ISBN']]"/>
      </dc:identifier>
      <dc:title>
        <xsl:value-of select="$epub-metadata//string[preceding-sibling::*[1][. eq 'Titel']]"/>
      </dc:title>
      <dc:description>
        <xsl:value-of select="(string-join($epub-metadata//array[preceding-sibling::*[1][. eq 'Autoreninformationen']]//string/replace(., '\s+', ' '), ' '),
                               $epub-metadata//string[preceding-sibling::*[1][. eq 'Autoreninformationen']]
                              )[1]"/>
      </dc:description>
      <dc:creator>
        <xsl:value-of select="$epub-metadata//string[preceding-sibling::*[1][. eq 'Autor']]"/>
      </dc:creator>
      <dc:publisher>
        <xsl:value-of select="$epub-metadata//string[preceding-sibling::*[1][. eq 'Verlag']]"/>
      </dc:publisher>
      <dc:language>
        <xsl:value-of select="($epub-metadata//string[preceding-sibling::*[1][. eq 'Sprache']], 'de-DE')"/>
      </dc:language>
      <dc:rights>
        <xsl:value-of select="$epub-metadata//string[preceding-sibling::*[1][. eq 'Copyright']]"/>
      </dc:rights>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>