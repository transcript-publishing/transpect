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
      <xsl:for-each select="/*:html/*:body/(*[@epub:type= ('titlepage', 'toc')] | descendant::*:div[@epub:type= ('chapter')])">
        <article><xsl:sequence select="tr:get-part-title(.), ., ./following-sibling::*[1][self::*:div[@class = 'notes']]"></xsl:sequence></article>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="whole-doi" select="if (*:head/*:meta[@name = 'doi'][@content]) 
                          then /*/*:head/*:meta[@name = 'doi']/@content
                          else 
                             if (descendant::*[self::*:header[@class = 'chunk-meta-sec']][*:ul/*:li[@class = 'chunk-doi']])
                             then (descendant::*[self::*:header[@class = 'chunk-meta-sec']]/*:ul/*:li[@class = 'chunk-doi'])[1]
                             else $basename" as="xs:string" />

    <xsl:variable name="filename" select="replace($whole-doi, '^.+/([^-]+)(-.+)?$', '$1')" as="xs:string" />
    <export-root>
      <xsl:element name="html" >
        <xsl:copy-of select="/*/@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-issue, $filename, '.html')"/>
        <xsl:apply-templates select="/*/node()" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
      <xsl:call-template name="create-bib-elt">
        <xsl:with-param name="nodes" select="node()"/>
        <xsl:with-param name="doi" select="$whole-doi"/>
        <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-issue, $filename, '.html')"/>
      </xsl:call-template>
    <xsl:call-template name="create-meta-elt">
      <xsl:with-param name="nodes" select="node()"/>
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-issue, $filename, '.html')"/>
    </xsl:call-template>
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="head" select="$head" as="element(*)?" tunnel="yes"/>
      </xsl:apply-templates>
    </export-root>
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
          <xsl:call-template name="add-modal-container">
            <xsl:with-param name="nodes" as="node()*" select="$nodes"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <xsl:call-template name="create-meta-elt">
      <xsl:with-param name="nodes" select="$nodes"/>
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="tr:determine-meta-chunk-authors" as="element(*)*">
    <xsl:param name="tei-meta" as="element()?"/>
    <xsl:param name="book-part" as="node()*"/>
    <xsl:for-each select="tokenize($tei-meta/*:term[@key = 'Autor'], '([;,] |[au]nd )')">
      <xsl:element name="contrib"  namespace="">
        <xsl:value-of select="normalize-space(replace(., '\s*\(.+?\)', ''))"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:function>

</xsl:stylesheet>
