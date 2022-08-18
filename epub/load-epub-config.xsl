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
        <xsl:value-of select="($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Titel']],
                                string-join($epub-metadata//array[preceding-sibling::*[1][. eq 'Titel']]//string[normalize-space()]/replace(., '\s+', ' '), ' ')
                              )[1]"/>
      </dc:title>
      <xsl:if test="$epub-metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Kurztext']]">
        <dc:description>
          <xsl:value-of select="($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Kurztext']], 
                                 string-join($epub-metadata//array[preceding-sibling::*[1][. eq 'Kurztext']]//string[normalize-space()]/replace(., '\s+', ' '), ' ')
            )[1]"/>
        </dc:description>
      </xsl:if>
      <xsl:if test="$epub-metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. = ('Autor', 'Herausgeber')]]">
      <dc:creator>
        <xsl:value-of select="($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. = ('Autor', 'Herausgeber')]],
                              string-join($epub-metadata//array[preceding-sibling::*[1][. = ('Autor', 'Herausgeber')]]//string[normalize-space()]/replace(., '\s+', ' '), ' '))[1]"/>
      </dc:creator>
      </xsl:if>

      <dc:date>
        <xsl:value-of select="(replace(normalize-space(string-join($epub-metadata//key[. = 'Copyright']/following-sibling::*[1]/descendant-or-self::string, ' '))[normalize-space()], 
                                            '^\s*©\s+(\d{4}).+$', 
                                            '$1'), 
                                    format-date(current-date(), '[Y]')
                                   )[1]"/>
      </dc:date>
      <dc:publisher>
        <xsl:value-of select="($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Verlag']], 'transcript Verlag')[1]"/>
      </dc:publisher>

      <dc:language>
        <xsl:value-of select="($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Sprache']], 'de-DE')[1]"/>
      </dc:language>

      <xsl:if test="$epub-metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Copyright']]">
      <dc:rights>
        <xsl:value-of select="normalize-space(string-join($epub-metadata//key[. = ('Copyright')]/following-sibling::*[1][normalize-space()]/descendant-or-self::string, ' '))"/>
      </dc:rights>
      </xsl:if>
      <xsl:if test="$epub-metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Schlagworte']]">
        <xsl:for-each select="tokenize($epub-metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Schlagworte']], ';')[normalize-space()]">
          <dc:subject>
            <xsl:value-of select="."/>
          </dc:subject>
        </xsl:for-each>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>