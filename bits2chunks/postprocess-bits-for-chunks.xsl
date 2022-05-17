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
  exclude-result-prefixes="xs c cat tr"
  version="2.0">

  <xsl:import href="http://transpect.io/xslt-util/xslt-based-catalog-resolver/xsl/resolve-uri-by-catalog.xsl"/>
  
  <xsl:param name="s9y1-path" as="xs:string"/>
  <xsl:param name="basename" as="xs:string"/>
  <xsl:param name="out-dir-uri" as="xs:string"/>
  
  <xsl:param name="cat:missing-next-catalogs-warning" as="xs:string" select="'no'"/>

  <xsl:variable name="catalog-resolved-target-dir" as="xs:string" 
    select="concat(tr:resolve-uri-by-catalog($out-dir-uri, doc('http://this.transpect.io/xmlcatalog/catalog.xml')), '/')"/>
  <xsl:variable name="local-dir-chunk" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/chunks-atypon/' else 'chunks-atypon/'"/>  
  <xsl:variable name="local-dir-issue" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/chunks-atypon/issue/' else 'chunks-atypon/issue/'"/>
  <xsl:variable name="local-dir-bits" as="xs:string" select="if (contains($catalog-resolved-target-dir, 'davomat')) then '/chunks-atypon/bits/' else 'chunks-atypon/bits/'"/>
 
  <xsl:template match="@* | node()" mode="#default export create-column-titles">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@srcpath" mode="#default"/>
  <xsl:key name="elt-by-uri" match="*" use="@xml:base"/>

  <xsl:template match="/*[self::*:book]" mode="#default">
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
    </export-root>
  </xsl:template>

  <xsl:template match="kwd-group[@kwd-group-type = ('docProps', 'http://www.le-tex.de/resource/schema/hub/1.1/hub.rng', 'title-page', 'titlepage')] |
                       custom-meta-group" mode="#default" priority="7"/>

  <xsl:template match="break" mode="#default" priority="5">
    <xsl:if test="matches(preceding-sibling::node()[1], '\P{Zs}$') and matches(following-sibling::node()[1], '^\P{Zs}')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="book-part[@book-part-type = ('imprint', 'loi', 'lot')]" mode="#default" priority="7">
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$in-issue">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="front-matter-part[@book-part-type='title-page']" mode="#default" priority="3">
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="new-doi" select="replace(book-part-meta/book-part-id, '^.+/(.+)-.+$', '$1-fm')"/>
     <book-part book-part-type="frontmatter">
      <xsl:if test="not($in-issue)"><xsl:attribute name="id" select="concat('b_', $new-doi)"/></xsl:if>
      <!--  <xsl:if test="not($in-issue)"><xsl:attribute name="book-part-number" select="'1'"/></xsl:if>-->
      <book-part-meta>
        <xsl:apply-templates select="book-part-meta/book-part-id" mode="#current"/>
        <!-- <book-part-id pub-id-type="doi"><xsl:value-of select="concat($meta/book-id[@book-id-type='doi'], '-fm')"/></book-part-id>-->
        <title-group>
          <title xml:lang="{$book-atts[name() = 'xml:lang']}"><xsl:value-of select="'Frontmatter'"/></title>
        </title-group>
        <xsl:apply-templates select="book-part-meta/(fpage|lpage)" mode="#current"/>
        <permissions>
          <copyright-statement>© <xsl:value-of select="format-date(current-date(), '[Y]')"/> transcript Verlag</copyright-statement>
          <copyright-year><xsl:value-of select="format-date(current-date(), '[Y]')"/></copyright-year>
          <copyright-holder>transcript Verlag</copyright-holder>
          <ali:free_to_read/>
        </permissions>
        <!-- <xsl:if test="$in-issue"><alternate-form xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$new-doi}.xml" alternate-form-type="xml"/></xsl:if>-->
        <!--<alternate-form xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$new-doi}.pdf" alternate-form-type="pdf"/>-->
        <xsl:apply-templates select="book-part-meta/counts" mode="#current"/>
      </book-part-meta>
			<xsl:if test="not($in-issue)"><body/></xsl:if>
    </book-part>
  </xsl:template>

  <xsl:template match="front-matter-part[@book-part-type='toc']" mode="#default" priority="3">
    <xsl:param name="doi" as="xs:string?" tunnel="yes"/>
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="new-doi" select="($doi, replace(book-part-meta/book-part-id, '^.+/(.+)-.+$', '$1-toc'))[1]"/>
    <book-part book-part-type="contents" id="{concat('b_', $new-doi)}" >
      <xsl:if test="not($in-issue)"><xsl:attribute name="id" select="concat('b_', $new-doi)"/></xsl:if>
      <!-- <xsl:if test="$in-issue"><xsl:attribute name="book-part-number" select="'2'"/></xsl:if>-->
      <book-part-meta>
       <!-- <book-part-id pub-id-type="doi"><xsl:value-of select="replace($doi, '-.+$', '-toc')"/></book-part-id>-->
        <xsl:apply-templates select="book-part-meta/book-part-id" mode="#current"/>
        <title-group>
          <title xml:lang="{$book-atts[name() = 'xml:lang']}"><xsl:value-of select="if ($book-atts[name() = 'xml:lang'][contains(., 'de')]) then 'Inhalt' else 'Content'"/></title>
        </title-group>
        <xsl:apply-templates select="book-part-meta/(fpage|lpage)" mode="#current"/>
        <permissions>
          <copyright-statement>© <xsl:value-of select="format-date(current-date(), '[Y]')"/> transcript Verlag</copyright-statement>
          <copyright-year><xsl:value-of select="format-date(current-date(), '[Y]')"/></copyright-year>
          <copyright-holder>transcript Verlag</copyright-holder>
          <ali:free_to_read/>
        </permissions>
        <!--  <xsl:if test="$in-issue"><alternate-form xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$new-doi}.xml" alternate-form-type="xml"/></xsl:if>
        <alternate-form xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$new-doi}.pdf" alternate-form-type="pdf"/>-->
        <xsl:apply-templates select="book-part-meta/counts" mode="#current"/>
      </book-part-meta>
			<xsl:if test="not($in-issue)"><body/></xsl:if>
    </book-part>
  </xsl:template>


  <!-- TODO: permission handling--> 

  <xsl:template match="title-group/title" mode="#default" priority="3">
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="$book-atts[name() = 'xml:lang'], @*, node()" mode="#current"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="body" mode="#default" priority="3">
   <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
  <!-- empty body in chunks. no body in issue file parts-->
    <xsl:if test="not($in-issue)">
      <xsl:copy copy-namespaces="no"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']" mode="#default"/>
  
  <xsl:template match="*:head" mode="#default">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="meta-elements" as="element()*">
      <xsl:if test="$context">
        <xsl:apply-templates select="$context/descendant::*:header[@class = 'chunk-meta-sec'][1]/*, $context/descendant::*:p[@class = 'tsmetaalternativeheadline'][1]" mode="generate-chunk-meta-tags"/>
      </xsl:if>
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <meta charset="utf-8"/>
      <xsl:apply-templates select="node()[not(self::*:meta[@name = $meta-elements/@name]) and not(self::*:link)], *:link[1], $meta-elements" mode="#current">
        <xsl:with-param name="context" select="$context" tunnel="yes"/>
        <xsl:sort select="name()" />
        <xsl:sort select="(@name, @href)[1]" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

 
  <xsl:variable name="short-isbn" select="replace(replace(/*/@xml:base, '^.+/.+?(\d+).+$', '$1'), '^[0]', '')"/>
 
  <xsl:template match="*:article" mode="#default">
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
    <xsl:param name="title-directory" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="temp-doi" select="(descendant::*:book-part-id[@book-part-id-type = 'doi'])[1]"/>
    <xsl:variable name="uri" select="if (matches($temp-doi, '\d')) 
                                     then replace($temp-doi, '^.+/', '') 
                                     else concat($meta/*:book-id[@book-id-type='doi'], '-', generate-id(.))"/>
    <xsl:variable name="head-with-title" as="element(*)?">
      <xsl:apply-templates select="$meta" mode="#current">
        <xsl:with-param name="context" select="." as="element(*)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="bts:create-chunk">
      <xsl:with-param name="nodes" as="element(*)+" select="*"/>
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $title-directory, $uri, '/', $uri, '.xml')"/>
      <xsl:with-param name="id" as="xs:string" select="(*/@id, generate-id())[1]"/>
      <xsl:with-param name="book-atts" select="$book-atts" as="attribute(*)*" tunnel="yes"/>
      <xsl:with-param name="meta" select="$head-with-title" as="element(*)?" tunnel="yes"/>
      <xsl:with-param name="doi" as="xs:string?" select="$temp-doi" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@xml:base" mode="export"/>
  
  <xsl:template name="bts:create-chunk">
    <xsl:param name="nodes" as="element(*)+"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="book-atts" as="attribute(*)*" tunnel="yes"/>
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
    <xsl:param name="doi" as="xs:string?" tunnel="yes"/>
    <book xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
<!--      <xsl:attribute name="dtd-version" select="'3.0'"/>-->
      <xsl:attribute name="xml:base" select="$uri"/>
      <xsl:sequence select="$book-atts[not(local-name() = ('base')(:, 'dtd-version'):))], $meta"/>
      <body>
        <xsl:apply-templates select="$nodes" mode="#current" />
      </body>
    </book>
  </xsl:template>

  <xsl:function name="tr:determine-meta-chunk-authors" as="element(*)*">
    <xsl:param name="tei-meta" as="element()?"/>
    <xsl:param name="book-part-nodes" as="node()*"/>
    <xsl:for-each select="tokenize($book-part-nodes/*:p[@content-type = 'heading-author'], '([,;] |[au]nd )')">
      <xsl:element name="contrib"  namespace="">
        <xsl:value-of select="normalize-space(replace(., '\s*\(.+?\)', ''))"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:function>


  <xsl:template match="/*:export-root" mode="export">
    <c:result target-dir="{$catalog-resolved-target-dir}" xmlns="http://www.w3.org/ns/xproc-step"/>
    <xsl:apply-templates select="*:book" mode="#current"/>
  </xsl:template>

  <xsl:template match="*:book" mode="export">
    <xsl:result-document href="{@xml:base}">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
