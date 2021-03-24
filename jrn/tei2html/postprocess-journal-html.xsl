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
  

  <xsl:param name="s9y1-path" as="xs:string"/>
  <xsl:param name="out-dir-uri" as="xs:string"/>
  
  <xsl:param name="cat:missing-next-catalogs-warning" as="xs:string" select="'no'"/>

  <xsl:variable name="catalog-resolved-target-dir" as="xs:string" 
    select="concat(tr:resolve-uri-by-catalog($out-dir-uri, doc('http://this.transpect.io/xmlcatalog/catalog.xml')), '/')"/>
  <xsl:variable name="local-dir-issue" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/' else 'html/issue/'"/>  
  <xsl:variable name="local-dir-article" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/' else 'html/article/'"/>  

  <xsl:template match="@* | node()" mode="#default export">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@srcpath" mode="#default"/>

  <xsl:template match="/" mode="#default">
    <xsl:variable name="head" select="/*/*:head" as="element(*)"/>
    <xsl:variable name="articles" as="element(*)*">
      <xsl:for-each select="/*:html/*:body/(*[@epub:type= ('titlepage', 'toc')] | descendant::*:div[contains(@class, 'article')])">
        <article><xsl:sequence select="."></xsl:sequence></article>
      </xsl:for-each>
    </xsl:variable>
    <export-root>
      <xsl:element name="html" >
        <xsl:copy-of select="/*/@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-issue, replace(/*/*:head/*:meta[@name = 'doi']/@content, '^.+?/', ''), '.html')"/>
        <xsl:apply-templates select="/*/node()" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="head" select="$head" as="element(*)?" tunnel="yes"/>
      </xsl:apply-templates>
    </export-root>
  </xsl:template>

  <xsl:template match="*:div[@epub:type = ('imprint', 'loi', 'lot')] | *:section[@id = 'halftitle'] | *:div[contains(@class, 'book-review')] " mode="#default" priority="7">
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$in-issue">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:header[@class = 'article-meta-sec']" mode="#default"/>
  
  <xsl:template match="*:head" mode="#default">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="meta-elements" as="element()*">
      <xsl:if test="$context">
        <xsl:apply-templates select="$context/descendant::*:header[@class = 'article-meta-sec'][1]/*" mode="generate-article-meta-tags"/>
      </xsl:if>
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <meta charset="utf-8"/>
      <xsl:apply-templates select="node()[not(self::*:meta[@name = $meta-elements/@name])], $meta-elements" mode="#current">
        <xsl:sort select="name()" />
        <xsl:sort select="(@name, @href)[1]" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:header[@class = 'article-meta-sec']/*:ul[@class = 'article-metadata']" mode="generate-article-meta-tags">
    <xsl:for-each select="*:li">
      <meta name="{./@class}" content="{./text()}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:header[@class = 'article-meta-sec']/*:ul[@class = 'article-keywords']" mode="generate-article-meta-tags">
    <meta name="keywords" content="{string-join(*:li, '; ')}"/>
  </xsl:template>

  <xsl:template match="*:header[@class = 'article-meta-sec']/*:div[@class = 'article-abstract']" mode="generate-article-meta-tags">
    <meta name="abstract" content="{text()}"/>
  </xsl:template>


  <xsl:template match="*:head/*:link/@href" mode="#default">
    <!-- https://redmine.le-tex.de/issues/9545#note-8 -->
    <!-- <link type="text/css" rel="stylesheet" href="/assets/css/styles.css" />
         <link href="file:///C:/cygwin/home/mpufe/transcript/trunk/a9s/common/css/stylesheet.css" type="text/css" rel="stylesheet"/>
      -->
    <xsl:attribute name="{name()}" select="replace(., '^.+/a9s/', 'assets/css/')"/>
    <!-- schwierig. da müsste ja alles in ein Stylefile-->
  </xsl:template>

  <xsl:variable name="short-isbn" select="replace(replace(/*/@xml:base, '^.+/.+?(\d+).+$', '$1'), '^[0]', '')"/>

  <xsl:template match="*:img/@src" mode="#default">
    <!-- https://redmine.le-tex.de/issues/9545#note-8 -->
    <!-- <img alt="{{ts_figure_caption}}" src="/{{kurz-isbn}}/images/{{image}}" />
         <img alt="" src="http://transpect.io/content-repo/ts/jrn/inge/00002/images/ts_jrn_inge_00002_image2.jpg"/>
      -->
    <xsl:attribute name="{name()}" select="concat('/', $short-isbn, '/images/', replace(., '^.+/', ''))"/>
    <!-- schwierig. da müsste ja alles in ein Stylefile-->
  </xsl:template>

  <xsl:template match="*:head/*:title" mode="#default">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:choose>  
        <xsl:when test="$context">
            <xsl:value-of select="$context/descendant::*:header[@class = 'article-meta-sec']/*:ul[@class = 'article-metadata']/*:li[@class = 'chunk-doi'][1]/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/*/*:head/*:meta[@name = 'DC.title']/@content"/>
        </xsl:otherwise> 
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:article" mode="#default">
    <xsl:param name="head" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="descendant::*:header[@class = 'article-meta-sec'][*:ul[@class = 'article-metadata']/*:li[@class = 'chunk-doi']]">
          <xsl:value-of select="replace(descendant::*:header[@class = 'article-meta-sec']/*:ul[@class = 'article-metadata']/*:li[@class = 'chunk-doi'][1], '^.+?/', '')"/>
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
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-article, $uri, '.html')"/>
      <xsl:with-param name="id" as="xs:string" select="(*/@id, generate-id())[1]"/>
      <xsl:with-param name="head" select="$head-with-title" as="element(*)?" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="@xml:base" mode="export"/>
  
  <xsl:template name="html:create-chunk">
    <xsl:param name="nodes" as="element(*)+"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="head" as="element(*)?" tunnel="yes"/>
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

  <xsl:template match="/*:export-root" mode="export">
    <c:result target-dir="{$catalog-resolved-target-dir}" xmlns="http://www.w3.org/ns/xproc-step"/>
    <xsl:apply-templates select="*:html" mode="#current"/>
  </xsl:template>

  <xsl:template match="*:html" mode="export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template>
 

</xsl:stylesheet>
