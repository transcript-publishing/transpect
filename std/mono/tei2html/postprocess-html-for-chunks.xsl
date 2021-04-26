<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:epub="http://www.idpf.org/2007/ops"
  exclude-result-prefixes="xs c cat html tr"
  version="2.0">
  
<!--  <xsl:import href="http://transpect.io/xslt-util/hex/xsl/hex.xsl"/>-->
  <xsl:import href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/ts/tei2html/postprocess-html-for-chunks.xsl"/>  

  <xsl:template match="/" mode="#default">
    <xsl:variable name="head" select="/*/*:head" as="element(*)"/>
    <xsl:variable name="articles" as="element(*)*">
      <xsl:for-each select="/*:html/*:body/(*[@epub:type= ('titlepage', 'toc')] | descendant::*:div[contains(@class, 'article')])">
        <article><xsl:sequence select="."></xsl:sequence></article>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable select="if (*:head/*:meta[@name = 'doi'][@content]) 
                          then replace(/*/*:head/*:meta[@name = 'doi']/@content, '^.+/', '')
                          else 
                             if (descendant::*[self::*:header[@class = 'chunk-meta-sec']][*:ul/*:li[@class = 'chunk-doi']])
                             then replace((descendant::*[self::*:header[@class = 'chunk-meta-sec']]/*:ul/*:li[@class = 'chunk-doi'])[1], '^.+/(.+)-.+$', '$1')
                             else 'no-chunk-doi-for-main-doc'" name="filename" as="xs:string" />
    <export-root>
      <xsl:element name="html" >
        <xsl:copy-of select="/*/@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $filename, '.html')"/>
        <xsl:apply-templates select="/*/node()" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="head" select="$head" as="element(*)?" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:call-template name="create-bib-elt">
        <xsl:with-param name="nodes" select="node()"/>
        <xsl:with-param name="id" select="$filename"/>
        <xsl:with-param name="uri" select="$uri"/>
      </xsl:call-template>
      <!--<xsl:if test=".//*[self::*:div[@role = ('doc-bibliography')]]">
        <xsl:element name="doi" namespace="">
          <xsl:attribute name="xml:base" select="replace($uri, 'html', 'xml')"/>
          <xsl:attribute name="id" select="$filename"/>
          <xsl:apply-templates select=".//*[self::*:div[@role = ('doc-bibliography')]]" mode="bib-chunks"/>
        </xsl:element>
      </xsl:if>-->
    </export-root>
  </xsl:template>

</xsl:stylesheet>
