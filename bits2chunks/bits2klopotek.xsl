<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs c cat tr"
  version="2.0">
  

  <xsl:param name="out-dir-uri" as="xs:string"/>

  <xsl:import href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
  <!--  https://redmine.le-tex.de/issues/12579 -->

  <xsl:template match="@* | *" mode="bits2klopotek" priority="-0.25"/>
  
  <xsl:template match="text()" mode="bits2klopotek">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:variable name="catalog-resolved-target-dir" as="xs:string" 
    select="concat(tr:resolve-uri-by-catalog($out-dir-uri, doc('http://this.transpect.io/xmlcatalog/catalog.xml')), '/')"/>

  <xsl:template match="/*" mode="bits2klopotek">
    <c:result target-dir="{$catalog-resolved-target-dir}" xmlns="http://www.w3.org/ns/xproc-step"/>
    <xsl:result-document href="{replace(book[1]/@xml:base, '\.bits', '.klopotek')}">
      <Components>
        <xsl:apply-templates select="book/body/book-part[@book-part-type='book-toc-page-order']/body/*" mode="#current"/>
      </Components>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="book-part" mode="bits2klopotek">
    <Component>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <ExtRef></ExtRef>
      <xsl:apply-templates select="book-part-meta/title-group/title/@xml:lang" mode="#current"/>
      <Language><xsl:value-of select="book-part-meta/title-group/title/@xml:lang"/></Language> 
    </Component>
  </xsl:template>
  
  <xsl:template match="book-part/@book-part-type" mode="bits2klopotek">
    <xsl:attribute name="ComponentType" select="."/>
  </xsl:template>
  
  <xsl:template match="book-part-meta | title-group" mode="bits2klopotek">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="title-group/title" mode="bits2klopotek">
    <Title><xsl:apply-templates select="node()" mode="#current"/></Title>
  </xsl:template>
  
  <xsl:template match="title-group/subtitle" mode="bits2klopotek">
    <SubTitle><xsl:apply-templates select="node()" mode="#current"/></SubTitle>
  </xsl:template>
  
  <xsl:template match="book-part-id" mode="bits2klopotek">
    <DOI><xsl:apply-templates select="node()" mode="#current"/></DOI>
  </xsl:template>
  
</xsl:stylesheet>
