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
  <xsl:variable name="local-dir-chunk" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/' else 'chunks/'"/>  

  <xsl:template match="@* | node()" mode="#default export">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@srcpath" mode="#default"/>

  <xsl:template match="/" mode="#default">
    <xsl:variable name="head" select="/*/*:head" as="element(*)"/>
    <xsl:variable name="articles" as="element(*)*">
      <xsl:for-each select="/*:html/*:body/(*[@epub:type= ('titlepage', 'toc')] | descendant::*:div[contains(@class, 'chapter')])">
        <article><xsl:sequence select="., ./following-sibling::*[1][self::*:div[@class = 'notes']]"></xsl:sequence></article>
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
    </export-root>
  </xsl:template>

  <xsl:template match="*:div[@epub:type = ('imprint', 'loi', 'lot')] | *:section[@id = 'halftitle'] | *:div[contains(@class, 'book-review')] " mode="#default" priority="7">
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$in-issue">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']" mode="#default"/>
  
  <xsl:template match="*:head" mode="#default">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="meta-elements" as="element()*">
      <xsl:if test="$context">
        <xsl:apply-templates select="$context/descendant::*:header[@class = 'chunk-meta-sec'][1]/*" mode="generate-chunk-meta-tags"/>
      </xsl:if>
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <meta charset="utf-8"/>
      <xsl:apply-templates select="node()[not(self::*:meta[@name = $meta-elements/@name]) and not(self::*:link)], *:link[1], $meta-elements" mode="#current">
        <xsl:sort select="name()" />
        <xsl:sort select="(@name, @href)[1]" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']" mode="generate-chunk-meta-tags">
    <xsl:for-each select="*:li">
      <meta name="{./@class}" content="{./text()}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-keywords']" mode="generate-chunk-meta-tags">
    <meta name="keywords" content="{string-join(*:li, '; ')}"/>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:div[@class = 'chunk-abstract']" mode="generate-chunk-meta-tags">
    <meta name="abstract" content="{text()}"/>
  </xsl:template>
 
  <xsl:template match="*:head/*:link[1]/@href" mode="#default">
    <!-- https://redmine.le-tex.de/issues/9545#note-8 -->
    <xsl:attribute name="{name()}" select="'/assets/css/styles.css'"/>
  </xsl:template>

  <xsl:variable name="short-isbn" select="replace(replace(/*/@xml:base, '^.+/.+?(\d+).+$', '$1'), '^[0]', '')"/>

  <xsl:template match="*:img/@src" mode="#default">
    <!-- https://redmine.le-tex.de/issues/9545#note-8 -->
    <!-- <img alt="{{ts_figure_caption}}" src="/{{kurz-isbn}}/images/{{image}}" />
      <img alt="" src="http://transpect.io/content-repo/ts/jrn/inge/00002/images/ts_jrn_zig_00002_image2.jpg"/>
    -->
    <xsl:attribute name="{name()}" select="concat('/', $short-isbn, '/images/', replace(., '^.+/', ''))"/>
    <xsl:if test="not(../@alt) and ../../*:p[@class = 'tsfigurecaption']">
      <xsl:attribute name="alt" select="string-join(../../*:p[@class = 'tsfigurecaption'], '')"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:img/@alt[. = '']" mode="#default">
    <!-- https://redmine.le-tex.de/issues/9545#note-8 -->
    <!-- <img alt="{{ts_figure_caption}}" src="/{{kurz-isbn}}/images/{{image}}" />
    -->
      <xsl:attribute name="alt" select="string-join(../../*:p[@class = 'tsfigurecaption']//text(), '')"/>
  </xsl:template>

  <xsl:template match="*:head/*:title" mode="#default">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:choose>  
        <xsl:when test="$context">
            <xsl:value-of select="$context/descendant::*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1]/text()"/>
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
        <xsl:when test="descendant::*:header[@class = 'chunk-meta-sec'][*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi']]">
          <xsl:value-of select="replace(descendant::*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^.+/', '')"/>
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
        <!--        <xsl:element name="chapter" namespace="http://www.w3.org/1999/xhtml">-->
        <!--          <xsl:attribute name="class" select="'article'"/>-->
        <xsl:apply-templates select="$nodes" mode="#current"/>
        <!--</xsl:element>-->
      </xsl:element>
    </xsl:element>
    <xsl:call-template name="create-bib-elt">
      <xsl:with-param name="nodes" select="$nodes"/>
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="create-bib-elt">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="id" as="xs:string?"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:if test="$nodes[.//*[self::*:div[@role = ('doc-bibliography')]]]">
      <xsl:element name="doi" namespace="">
        <xsl:attribute name="xml:base" select="replace($uri, 'html', 'xml')"/>
        <xsl:attribute name="name" select="$id"/>
        <xsl:apply-templates select="$nodes//*[self::*:div[@role = ('doc-bibliography')]]" mode="bib-chunks"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:div[@role = 'doc-bibliography']" mode="bib-chunks">
    <xsl:apply-templates select="*:p" mode="#current"/>
  </xsl:template>

  <xsl:template match="*:div[@role = 'doc-bibliography']//*:p" mode="bib-chunks">
    <xsl:element name="bibl" namespace=""><xsl:apply-templates select="node()" mode="#current"/></xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="bib-chunks">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="/*:export-root" mode="export">
    <c:result target-dir="{$catalog-resolved-target-dir}" xmlns="http://www.w3.org/ns/xproc-step"/>
    <xsl:apply-templates select="*:html | *:doi" mode="#current"/>
  </xsl:template>

  <xsl:template match="*:html" mode="export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*:doi" mode="export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template> 

</xsl:stylesheet>
