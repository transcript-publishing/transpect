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

  <xsl:template match="/*[self::*:html]" mode="#default">
    <xsl:variable name="head" select="/*/*:head" as="element(*)"/>
    <xsl:variable name="articles" as="element(*)*">
      <xsl:for-each select="/*:html/*:body/(*[@epub:type= ('titlepage', 'toc')] | descendant::*:div[contains(@class, 'article')])">
        <article>
          <xsl:sequence select="tr:get-part-title(.), 
                                  ., 
                                  ./following-sibling::*[1][self::*:div[@class = 'notes']]"/>
        </article>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable select="if (/*/*:head/*:meta[@name = 'doi'][@content]) 
                          then replace(/*/*:head/*:meta[@name = 'doi']/@content, '^.+/', '')
                          else 
                             if (descendant::*[self::*:header[@class = 'chunk-meta-sec']][*:ul/*:li[@class = 'chunk-doi'][matches(., '-[\d]{3}$')]])
                             then replace((descendant::*[self::*:header[@class = 'chunk-meta-sec']]/*:ul/*:li[@class = 'chunk-doi'])[1], '^.+/(.+)-[\d]{3}$', '$1')
                             else $basename" name="filename" as="xs:string" />
    <export-root>
      <xsl:element name="html" >
        <xsl:copy-of select="/*/@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-issue, $filename, '.html')"/>
        <xsl:apply-templates select="/*/node()" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="head" select="$head" as="element(*)?" tunnel="yes"/>
      </xsl:apply-templates>
    </export-root>
  </xsl:template>

  <xsl:template match="*:article" mode="#default">
    <xsl:param name="head" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="descendant::*:header[@class = 'chunk-meta-sec'][*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi']]">
          <xsl:value-of select="replace(descendant::*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^.+/', '')"/>
        </xsl:when>
        <xsl:when test="@epub:type='titlepage'">
          <xsl:value-of select="replace(//*:header[@class = 'chunk-meta-sec'][1]/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^(.+/.+-)(\d{2})\d+$', '$1frontmatter$2')"/>
        </xsl:when>
        <xsl:when test="@epub:type='toc'">
          <xsl:value-of select="replace(//*:header[@class = 'chunk-meta-sec'][1]/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^(.+/.+-)(\d{2})\d+$', '$1toc$2')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="(*/@id, generate-id())[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="head-with-title" as="element(*)?">
      <xsl:apply-templates select="$head" mode="#current">
        <xsl:with-param name="context" select="." as="element(*)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="html:create-chunk">
      <xsl:with-param name="nodes" as="element(*)+" select="*"/>
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $uri, '.html')"/>
      <xsl:with-param name="id" as="xs:string" select="(*/@id, generate-id())[1]"/>
      <xsl:with-param name="head" select="$head-with-title" as="element(*)?" tunnel="yes"/>
      <xsl:with-param name="doi" as="xs:string?" select="replace(descendant::*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^.*/(10\.\d+/.+)$', '$1')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="html:create-chunk">
    <xsl:param name="nodes" as="element(*)+"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="head" as="element(*)?" tunnel="yes"/>
    <xsl:param name="doi" as="xs:string?"/>
    <xsl:element name="html" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="xml:base" select="$uri"/>
      <!-- CSS -->
      <xsl:sequence select="$head" />
      <xsl:element name="body" namespace="http://www.w3.org/1999/xhtml">
        <xsl:element name="article" namespace="http://www.w3.org/1999/xhtml">
<!--          <xsl:attribute name="class" select="'article'"/>-->
          <xsl:apply-templates select="$nodes" mode="#current"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
