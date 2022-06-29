<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:bts="http://transpect.io/bts"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
  exclude-result-prefixes="xs c cat tr bts epub"
  version="2.0">

  <xsl:import href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
  <xsl:import href="../../../bits2chunks/postprocess-bits-for-chunks.xsl"/>

  
  <xsl:template match="/*[self::*:book]" mode="#default" exclude-result-prefixes="c">
    <xsl:variable name="meta" select="*:book-meta" as="element(*)"/>
    <xsl:variable name="articles" as="element(*)*">
      <xsl:for-each select="(*:front-matter/*:front-matter-part | *:book-body//*:book-part[@book-part-type=('chapter', 'article')] | *:book-back//*:book-part)">
        <article>
          <xsl:sequence select="."></xsl:sequence>
        </article>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable select="if (*:book-meta/*:book-id[@book-id-type= 'doi'][normalize-space()]) 
                          then replace(*:book-meta/*:book-id[@book-id-type= 'doi'][normalize-space()], '^.+/', '')
                          else 
                             if (descendant::*[self::*:header[@class = 'chunk-meta-sec']][*:ul/*:li[@class = 'chunk-doi'][matches(., '-0*\d+$')]])
                             then replace((descendant::*[self::*:header[@class = 'chunk-meta-sec']]/*:ul/*:li[@class = 'chunk-doi'])[1], '^.+/(.+)-.+$', '$1')
                             else $basename" name="filename" as="xs:string" />
    <xsl:variable select="concat($filename, '/')" name="title-directory" as="xs:string" />
    <export-root>
      <!-- every book element with an xml:base will be exported there -->
      <!-- original BITS output-->
      <xsl:copy>
        <xsl:copy-of select="@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $title-directory, $filename, '.xml')"/>
        <!-- https://redmine.le-tex.de/issues/12650 move bits here-->
        <xsl:sequence select="node()"/>
      </xsl:copy>
      <!-- complete issue referencing book-parts only-->
      <book xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
        <xsl:copy-of select="/*/@xml:lang" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $title-directory, $title-directory, $filename, '.xml')"/>
<!--        <xsl:attribute name="dtd-version" select="'3.0'"/>-->
        <xsl:apply-templates select="book-meta" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
        <body>
          <book-part book-part-type="book-toc-page-order">
            <body>
              <xsl:apply-templates select="$articles/node()" mode="#current">
                <xsl:with-param name="book-atts" select="@*" as="attribute(*)*" tunnel="yes"/>
                <xsl:with-param name="meta" select="$meta" as="element(*)?" tunnel="yes"/>
                <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
                <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
                <xsl:with-param name="title-directory" select="$title-directory" as="xs:string" tunnel="yes"/>
              </xsl:apply-templates>
            </body>
          </book-part>
        </body>
      </book>
      <!-- single book-parts as temporary articles -->
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="book-atts" select="@*" as="attribute(*)*" tunnel="yes"/>
        <xsl:with-param name="meta" select="$meta" as="element(*)?" tunnel="yes"/>
        <xsl:with-param name="in-issue" select="false()" as="xs:boolean" tunnel="yes"/>
        <xsl:with-param name="title-directory" select="$title-directory" as="xs:string" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:call-template name="create-bib-elt">
      <xsl:with-param name="nodes" select="node()"/>
      <xsl:with-param name="doi" select="$filename"/>
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-chunk,  $title-directory, $filename, '.xml')"/>
      <xsl:with-param name="issue" select="true()"/>
    </xsl:call-template>
    </export-root>
  </xsl:template>

 <xsl:template name="bts:create-chunk">
    <xsl:param name="nodes" as="element(*)+"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
    <xsl:param name="doi" as="xs:string?" tunnel="yes"/>
    <!-- do not create bib chunk -->
    <book xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
<!--      <xsl:attribute name="dtd-version" select="'3.0'"/>-->
      <xsl:attribute name="xml:base" select="$uri"/>
      <xsl:sequence select="$book-atts[not(local-name() = ('base')(:, 'dtd-version'):))], $meta"/>
      <body>
        <xsl:apply-templates select="$nodes" mode="#current" />
      </body>
    </book>
    <xsl:call-template name="create-meta-elt">
      <xsl:with-param name="nodes" select="$nodes"/>
      <xsl:with-param name="uri" select="$uri"/>
      <xsl:with-param name="meta" select="$meta" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>

 
</xsl:stylesheet>
