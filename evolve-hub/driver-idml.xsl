<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:ts="http://www.transcript-verlag.de/transpect"
  xmlns:idml2xml="http://transpect.io/idml2xml"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk ts idml2xml" 
  xmlns:tr="http://transpect.io"
  version="2.0">
  
  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-idml.xsl"/>  
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbncheck.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbnformat.xsl"/>

 <xsl:template match="para[@role = 'Fuzeile'] | *[not(self::css:rule)]/@idml2xml:layer" mode="hub:split-at-tab"/>
 <xsl:param name="hub:handle-several-images-per-caption" as="xs:boolean" select="true()"/>

 <!-- next 3 templates were rafactred to transcript and are no longer in common/evolve-hub. therefore the are copied here-->
 <!-- pull meta infos after headings -->
  <xsl:template match="para[matches(@role, '^(tsheading|toctitle)')][preceding-sibling::*[1][@role = 'chunk-metadata']]" mode="hub:reorder-marginal-notes">
    <xsl:next-match/>
    <xsl:apply-templates select="preceding-sibling::*[1][@role = 'chunk-metadata']" mode="#current">
      <xsl:with-param name="process-meta-section" tunnel="yes" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'chunk-metadata']" mode="hub:reorder-marginal-notes">
    <xsl:param name="process-meta-section" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="$process-meta-section or preceding-sibling::*[1][@role = ('tsheadlineleft', 'tsheadlineright', 'tsheading1', 'tsheading2', 'tsauthor')]">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="para[matches(@role, 'tsauthor')]" mode="hub:process-meta-sidebar">
    <author>
      <personname>
        <othername>  
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:value-of select="normalize-space(.)"/>
        </othername>
      </personname>
    </author>
  </xsl:template>  

</xsl:stylesheet>