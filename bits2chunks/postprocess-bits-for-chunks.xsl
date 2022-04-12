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
  
<!--  <xsl:import href="http://transpect.io/xslt-util/hex/xsl/hex.xsl"/>-->
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
    <xsl:variable select="if (*:head/*:meta[@name = 'doi'][@content]) 
                          then replace(/*/*:head/*:meta[@name = 'doi']/@content, '^.+/', '')
                          else 
                             if (descendant::*[self::*:header[@class = 'chunk-meta-sec']][*:ul/*:li[@class = 'chunk-doi'][matches(., '-0*\d+$')]])
                             then replace((descendant::*[self::*:header[@class = 'chunk-meta-sec']]/*:ul/*:li[@class = 'chunk-doi'])[1], '^.+/(.+)-.+$', '$1')
                             else $basename" name="filename" as="xs:string" />
    <export-root>
      <!-- every book element with an xml:base will be exported there -->
      <!-- original BITS output-->
      <xsl:copy>
        <xsl:copy-of select="@*" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-bits, $filename, '.bits.xml')"/>
        <xsl:sequence select="node()"/>
      </xsl:copy>
      <!-- complete issue referencinf book-parts only-->
      <book dtd-version="3.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
        <xsl:copy-of select="/*/@xml:lang" copy-namespaces="no"/>
        <xsl:attribute name="xml:base" select="concat($catalog-resolved-target-dir, $local-dir-issue, $filename, '.all.jats.xml')"/>
        <xsl:apply-templates select="book-meta" mode="#current">
            <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
        <body>
          <book-part book-part-type="book-toc-page-order">
            <body>
              <xsl:apply-templates select="$articles/node()" mode="#current">
                <xsl:with-param name="meta" select="$meta" as="element(*)?" tunnel="yes"/>
                <xsl:with-param name="in-issue" select="true()" as="xs:boolean" tunnel="yes"/>
              </xsl:apply-templates>
            </body>
          </book-part>
        </body>
      </book>
      <!-- single book-parts as temporary articles -->
      <xsl:apply-templates select="$articles" mode="#current">
        <xsl:with-param name="meta" select="$meta" as="element(*)?" tunnel="yes"/>
        <xsl:with-param name="in-issue" select="false()" as="xs:boolean" tunnel="yes"/>
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

  <xsl:template match="front-matter-part[@book-part-type='toc']" mode="#default" priority="7">
    <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$in-issue">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="front-matter-part[@book-part-type='toc']" mode="#default" priority="3">
    <xsl:param name="doi" as="xs:string?"/>
    <book-part book-part-type="contents" id="{concat('b_', ($doi))}" book-part-number="2">
      <xsl:apply-templates select="@*, node()" mode="#current"/> 
    </book-part>
  </xsl:template>

  <xsl:template match="front-matter-part" mode="#default" priority="3">
    <xsl:param name="doi" as="xs:string?"/>
    <book-part book-part-type="" id="{concat('b_', ($doi))}" book-part-number="2">
      <xsl:apply-templates select="@*" mode="#current"/> 
    </book-part>
  </xsl:template>

  <xsl:template match="body" mode="#default" priority="3">
   <xsl:param name="in-issue" as="xs:boolean?" tunnel="yes"/>
  <!-- empty body in chunks. no body in issue file parts-->
    <xsl:if test="not($in-issue)">
      <xsl:copy copy-namespaces="no"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:html[not(contains(@xml:base, '/issue'))]//*:nav/*:ol//*:li/*:a/@href" mode="export" priority="7">
    <!-- toc link to chunks https://redmine.le-tex.de/issues/10166#note-5 -->
    <xsl:attribute name="href" select="concat(replace((//*:export-root/*:html[not(contains(@xml:base, '/issue'))][descendant::*/@id = substring-after(current(), '#')]/@xml:base)[1], '^.+/', ''), .)"/>
  </xsl:template>

  <xsl:template match="*:html[not(contains(@xml:base, '/issue'))]//*:nav/*:ol//*:li" mode="export" priority="7">
    <xsl:if test="substring-after(*:a/@href, '#') = //*:export-root/*:html[not(contains(@xml:base, '/issue'))]/descendant::*/@id">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:html//*:nav/*:ol//*:li[matches(*:a/@href, '^#(epub-cover-image-container|halftitle|title-page|imprint|toc)$')]" mode="#default" priority="7"/>

  <xsl:template match="*:html//*:nav//*:ol" mode="export" priority="5">
    <xsl:element name="ul">
     <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(ancestor::*:ol)"><xsl:attribute name="class" select="'toc-list'"/></xsl:if>
     <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!--<xsl:template match="*[self::*:td | self::*:tr]/@style" mode="#default" priority="7">
    <!-\- https://redmine.le-tex.de/issues/11058 discard default atts -\->
    <xsl:variable name="regex" as="xs:string" select="'(border-(top|right|bottom|left)-width: 1px(; )?)|(border-(top|right|bottom|left)-style: solid(; )?)|(border-(top|right|bottom|left)-color: #000000(; )?)'"/>
    <xsl:variable name="stripped-cell-atts">
      <xsl:analyze-string select="." regex="{$regex}">
        <xsl:matching-substring/>
        <xsl:non-matching-substring><xsl:sequence select="."/></xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:if test="some $s in $stripped-cell-atts satisfies $s[normalize-space()]"><xsl:attribute name="{name()}" select="string-join($stripped-cell-atts)"></xsl:attribute></xsl:if>
  </xsl:template>-->

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

  <xsl:template match="*:p[@class = 'tsmetaalternativeheadline']" mode="generate-chunk-meta-tags">
    <meta name="alternative-headline" content="{normalize-space(string-join(node()))}"/>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']" mode="generate-chunk-meta-tags">
    <xsl:for-each select="*:li">
      <meta name="{./@class}" content="{if (@class = '') then replace(./text(), '^http://doi.org/', '') else ./text()}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-keywords']" mode="generate-chunk-meta-tags">
    <meta name="keywords" content="{string-join(*:li, '; ')}"/>
  </xsl:template>

  <xsl:template match="*:header[@class = 'chunk-meta-sec']/*:div[@class = 'chunk-abstract']" mode="generate-chunk-meta-tags">
    <meta name="abstract" content="{text()}"/>
  </xsl:template>

  <xsl:template match="*:head/*:meta[@name = 'DC.title']" mode="#default">
    <xsl:param name="context" as="element(*)*" tunnel="yes"/>
      <meta name="{@name}" content="{if ($context/descendant::*:header[@class = 'chunk-meta-sec'])
                                     then $context/descendant::*[local-name() = ('h2', 'h3')][1]/@title
                                     else @content}"/>
  </xsl:template>

  <xsl:template match="*:head/*:meta[@name = 'DC.identifier']" mode="#default">
    <xsl:param name="context" as="element(*)*" tunnel="yes"/>
      <meta name="{@name}" content="{if ($context/descendant::*:header[@class = 'chunk-meta-sec'][*:ul/*:li[@class ='chunk-doi']])
                                     then replace($context/descendant::*:header[@class = 'chunk-meta-sec']/*:ul/*:li[@class ='chunk-doi'], 'https?://doi.org/', '')
                                     else @content}"/>
  </xsl:template>

  <xsl:template match="*:head/*:meta[@name = 'DC.creator']" mode="#default">
    <xsl:param name="context" as="element(*)*" tunnel="yes"/>
      <meta name="{@name}" content="{if (@content[normalize-space()])
                                     then @conten
                                     else 
                                        if (/*/*:body/*:section[@epub:type ='titlepage'][*:p[@class='autor']]) 
                                        then /*/*:body/*:section[@epub:type ='titlepage'][*:p[@class='autor']]
                                        else $context/descendant::*:p[@class = 'heading-author'][1]}"/>
  </xsl:template>

 
  <xsl:variable name="short-isbn" select="replace(replace(/*/@xml:base, '^.+/.+?(\d+).+$', '$1'), '^[0]', '')"/>


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
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
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
      <xsl:apply-templates select="$meta" mode="#current">
        <xsl:with-param name="context" select="." as="element(*)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="bts:create-chunk">
      <xsl:with-param name="nodes" as="element(*)+" select="*"/>
      <xsl:with-param name="uri" select="concat($catalog-resolved-target-dir, $local-dir-chunk, $uri, '.jats.xml')"/>
      <xsl:with-param name="id" as="xs:string" select="(*/@id, generate-id())[1]"/>
      <xsl:with-param name="meta" select="$head-with-title" as="element(*)?" tunnel="yes"/>
      <xsl:with-param name="doi" as="xs:string?" select="replace(descendant::*:header[@class = 'chunk-meta-sec']/*:ul[@class = 'chunk-metadata']/*:li[@class = 'chunk-doi'][1], '^.*/(10\.\d+/.+)$', '$1')"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="@xml:base" mode="export"/>
  
  <xsl:template name="bts:create-chunk">
    <xsl:param name="nodes" as="element(*)+"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="meta" as="element(*)?" tunnel="yes"/>
    <xsl:param name="doi" as="xs:string?"/>
    <book dtd-version="3.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
      <xsl:attribute name="xml:base" select="$uri"/>
      <xsl:sequence select="$meta"/>
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