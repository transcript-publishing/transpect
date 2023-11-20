<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:csstmp="http://transpect.io/csstmp"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="css hub2htm xs tei2html tei html tr"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:output method="xhtml" indent="yes" doctype-public="" doctype-system=""/>
  
  <xsl:import href="http://this.transpect.io/a9s/common/tei2html/tei2html-driver.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>
  
  <xsl:param name="toc-depth" select="3" as="xs:integer"/>
  <xsl:param name="verbose" select="'no'"/>

  <xsl:param name="basename" as="xs:string"/>
  <xsl:param name="generate-note-link-title" select="true()" as="xs:boolean"/>
  <xsl:param name="also-consider-rule-atts" select="false()" as="xs:boolean"/>
  <xsl:param name="s9y1-path-canonical"/>
  
  <xsl:variable name="divify-sections" select="'no'"/>
  <xsl:variable name="xhtml-version " select="'5'"/>

  <xsl:variable name="metadata" as="element(term)*"
                select="/TEI/teiHeader/profileDesc/textClass/keywords[@rendition eq 'titlepage']/term" />
  
  <xsl:template match="/TEI" mode="tei2html">
    <html>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="epub:prefix" select="'tr: http://transpect.io'"/>
      <head>
        <xsl:call-template name="stylesheet-links"/>
        <title>
          <xsl:apply-templates select="$metadata[@key = 'Titel']//text()" mode="#current"/>
        </title>
        <xsl:call-template name="meta"/>
<!--        <xsl:apply-templates select="teiHeader/encodingDesc/css:rules" mode="hub2htm:css"/>-->
      </head>
      <body>
        <xsl:call-template name="half-title"/>
        <!--<xsl:call-template name="frontispiece"/>--><!-- series page not needed, yet -->
        <xsl:call-template name="full-title"/>
        <xsl:call-template name="imprint"/>
        <xsl:call-template name="dedication"/>
        <xsl:call-template name="toc"/>
        <xsl:if test="not(//head[matches(@rend, $list-of-figures-regex)])"><xsl:call-template name="lof"/></xsl:if>
        <xsl:if test="not(//head[matches(@rend, $list-of-tables-regex)])"><xsl:call-template name="lot"/></xsl:if>
        <xsl:call-template name="html-body"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="css:rule[not(@layout-type = ('table', 'cell'))]" mode="hub2htm:css"/>

  <xsl:template match="css:rule" mode="hub2htm:css">
    <!-- Add table to selector -->
    <xsl:variable name="css-selector" select="if (@layout-type = ('cell', 'table')) then replace(@name, '_-_', '.') else @name"/>
    <xsl:variable name="css-atts" as="attribute(*)*">
      <!-- This mode enables selective property filtering in your overriding template -->
      <xsl:apply-templates select="@* except @csstmp:*" mode="hub2htm:css-style-defs"/>
    </xsl:variable>
    <xsl:variable name="eltname" as="xs:string?" select="if (@layout-type = 'table') then 'table' else 'td'"/>
    <xsl:variable name="css-properties" select="string-join(
      for $i in $css-atts return concat($i/local-name(), ':', $i)
      , ';&#xa;  ')"/>
    <xsl:variable name="compound-selector-name" as="xs:string" select="if ($eltname = 'td') then concat('&#xa;', $eltname, '.', $css-selector, ', th.', $css-selector) else concat('&#xa;', $eltname, '.', $css-selector)"/>
    <xsl:if test="exists($css-atts)">
      <xsl:value-of select="concat($compound-selector-name, ' {&#xa;  ', $css-properties, '&#xa;}&#xa;')"></xsl:value-of>  
    </xsl:if>
  </xsl:template> 
  
  <xsl:template name="half-title">
    <section class="halftitle title-page" epub:type="halftitlepage" id="halftitle">
      <!-- https://redmine.le-tex.de/issues/14982 -->
      <xsl:apply-templates select="$metadata[@key = ('Widmung')]" mode="#current"/>
        <xsl:choose>
        <xsl:when test="contains($basename, '_mono_')">
          <xsl:apply-templates select="$metadata[@key = ('Autoreninformationen')],
                                       $metadata[@key = ('Kurztext')]" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$metadata[@key = ('Editorial')][matches(., '\S')]">
            <h4>Editorial</h4>
            <xsl:apply-templates select="$metadata[@key = ('Editorial')]" mode="#current"/>
          </xsl:if>
          <br/>
          <xsl:apply-templates select="$metadata[@key = ('Herausgeberinformationen')]" mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </section>
  </xsl:template>

  <xsl:template match="html:section[@epub:type=('halftitlepage', 'titlepage', 'imprint')][not(matches(., '\S'))]" mode="clean-up" priority="2"/>

  <xsl:template name="dedication">
    <xsl:if test="/TEI/text/front/div[@type = 'dedication']">
    <section class="dedication" epub:type="dedication" role="doc-dedication">
      <xsl:apply-templates select="/TEI/text/front/div[@type = 'dedication']/p" mode="#current"/>
    </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="frontispiece">
    <section class="{local-name()} title-page" epub:type="seriespage"/>
  </xsl:template>
  
  <xsl:template name="full-title">
    <section class="fulltitle title-page" epub:type="titlepage" id="title-page">
      <xsl:apply-templates select="$metadata[@key = 'Autor'], 
                                   $metadata[@key = 'Herausgeber'],
                                   $metadata[@key = 'Titel'],
                                   $metadata[@key = 'Untertitel']" mode="#current"/>
      <div class="logo">
        <img src="http://this.transpect.io/a9s/ts/logos/transcript_rgb.png" alt="Transcript Verlag"/>
      </div>
    </section>
  </xsl:template>
  
  <xsl:template name="imprint">
    <section class="title-page imprint" epub:type="imprint">
      <xsl:apply-templates select="$metadata[@key = 'Qualifikationsnachweis'], 
                                   $metadata[@key = 'Gutachter'], 
                                   $metadata[@key = 'Dank'], 
                                   $metadata[@key = 'Fordertext'], 
                                   $metadata[@key = 'Forderlogos'], 
                                   $metadata[@key = 'Bibliografische_Information'],
                                   $metadata[@key = 'Lizenzlogo'],
                                   $metadata[@key = 'Lizenzlink'],
                                   $metadata[@key = 'Lizenztext'],
                                   $metadata[@key = 'Copyright'],
                                   $metadata[@key = 'Umschlaggestaltung'],
                                   $metadata[@key = 'Umschlagcredit'], 
                                   $metadata[@key = 'Lektorat'],
                                   $metadata[@key = 'Korrektorat'],
                                   $metadata[@key = 'Satz'],
                                   $metadata[@key = 'DOI'],
                                  (: $metadata[@key = 'Konvertierung'],:)
                                   $metadata[@key = 'Print-ISBN'],
                                   $metadata[@key = 'PDF-ISBN'],
                                   $metadata[@key = 'ePUB-ISBN'],
                                   $metadata[@key = 'BiblISSN'],
                                   $metadata[@key = 'BibleISSN']" mode="#current"/>
    </section>
  </xsl:template>
  
  <!-- default handler for metadata terms -->
  
  <xsl:template match="term[@key]" mode="tei2html" priority="-1">
    <p class="{lower-case(translate(@key, ' ', '-'))}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="term[@key]/seg[@type='remap-para']" mode="tei2html" priority="-1">
    <xsl:apply-templates mode="#current"/>
    <xsl:if test="following-sibling::*[1][self::seg[@type='remap-para']]">
      <br/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term[@key eq 'Forderlogos'][normalize-space()]" mode="tei2html">
    <xsl:for-each select="text()[normalize-space()] | seg[normalize-space()]/text()">
      <img src="{concat($s9y1-path-canonical, 'images/', replace(normalize-space(.), '\.eps', '.jpg', 'i'))}" alt="Funding Logo {replace(normalize-space(.), '\.eps', '.jpg', 'i')}" class="funding logo"/>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="term[@key eq 'Herausgeber'][normalize-space()]" mode="tei2html">
     <p class="{lower-case(translate(@key, ' ', '-'))}">
     <xsl:value-of select="concat(
                                  string-join(node()[normalize-space()], ', '),
                                  if (/*/@xml:lang = 'en') then ' (Ed.)' else ' (Hg.)'
                            )"/>
    </p>
  </xsl:template>

  <xsl:template match="term[@key eq 'Lizenzlogo'][normalize-space()]" mode="tei2html">
     <p class="{lower-case(translate(@key, ' ', '-'))}">
      <img src="{concat('http://this.transpect.io/a9s/ts/logos/cc/', replace(., '\.eps', '.png', 'i'))}" alt="Logo {normalize-space(../term[@key eq 'Lizenz'])}" class="cc logo"/>
    </p>
  </xsl:template>

  <!-- title-page -->
  
  <xsl:template match="term[@key eq 'Titel']" mode="tei2html">
    <h1 class="{lower-case(translate(@key, ' ', '-'))}">
      <xsl:apply-templates mode="#current"/>
    </h1>
  </xsl:template>
  
  <xsl:template match="term[@key eq 'Untertitel']" mode="tei2html">
    <h2 class="{lower-case(translate(@key, ' ', '-'))}">
      <xsl:apply-templates mode="#current"/>
    </h2>
  </xsl:template>
  
  <xsl:template match="term[@key eq 'Lizenzlink']" mode="tei2html">
    <p class="{lower-case(translate(@key, ' ', '-'))}">
      <xsl:choose>
        <xsl:when test="ref">
          <xsl:apply-templates mode="#current"/>
        </xsl:when>
        <xsl:otherwise>    
          <a href="{.}">
            <xsl:apply-templates mode="#current"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>
  
  <xsl:template name="toc">
    <nav class="toc" epub:type="toc" id="tei2html_rendered_toc">
      <xsl:call-template name="generate-toc-headline"/>
      <xsl:apply-templates select="/TEI/text/front/divGen[@type = 'toc']/*:header[@rend = 'chunk-meta-sec']" mode="tei2html"/>
      <xsl:call-template name="generate-toc-body">
        <xsl:with-param name="toc_level" select="$toc-depth + 1"/>
      </xsl:call-template>
    </nav>
  </xsl:template>
<!--  
  <xsl:template name="landmarks">
    <nav class="landmarks" epub:type="landmarks" id="landmarks">
      <ol>
        <li>
          <a epub:type="cover" href="#epub-cover-image-container">Cover</a>
        </li>
        <li>
          <a epub:type="titlepage" href="#title-page">
            <xsl:call-template name="generate-toc-headline-text"/>
          </a>
        </li>
        <li>
          <a epub:type="toc" href="#toc">
            <xsl:call-template name="generate-toc-headline-text"/>
          </a>
        </li>
        <li>
          <a epub:type="bodymatter" href="{text/body/div[1]/@xml:id}">
            <xsl:value-of select="     if(@xml:lang eq 'de') then 'Beginn'
                                  else if(@xml:lang eq 'en') then 'Beginning'
                                  else if(@xml:lang eq 'fr') then 'Début du livre'
                                  else if(@xml:lang eq 'es') then 'Comienzo'
                                  else ()"/>
          </a>
        </li>
      </ol>
    </nav>
  </xsl:template>-->
  
  <xsl:template name="generate-toc-headline">
    <h3 class="toc-title">
      <xsl:call-template name="generate-toc-headline-text"/>
    </h3>
  </xsl:template>
  
  <xsl:template name="generate-toc-headline-text">
    <xsl:value-of select="     if(@xml:lang eq 'de') then 'Inhalt'
                          else if(@xml:lang eq 'en') then 'Table of Contents'
                          else if(@xml:lang eq 'fr') then 'Table des matières'
                          else if(@xml:lang eq 'es') then 'Contenido'
                          else ()"/>
  </xsl:template>

  <xsl:template match="/TEI/text/body" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="idno" mode="tei2html">
    <p class="{@rend}">
      <xsl:value-of select="     if(@rend eq 'isbn') then 'Print ISBN: ' 
                            else if(@rend eq 'eisbn') then 'EPUB-ISBN: '
                            else ()"/>
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="front" mode="tei2html"/>
  
  <xsl:template match="author" mode="tei2html">
    <p class="author">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="title" mode="tei2html">
    <xsl:element name="{if (@type eq 'subtitle') then 'h2' else 'h1'}">
      <xsl:attribute name="class" select="@type"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="licence" mode="tei2html">
    <xsl:variable name="license-url" select="@target" as="xs:string"/>
    <xsl:variable name="license-code" as="xs:string"
                  select="replace($license-url, 
                                  '^http://creativecommons\.org/licenses/(by-nc-nd)/3\.0/$',
                                  '$1')" />
    <xsl:variable name="license-image" as="xs:string"
                  select="concat('http://this.transpect.io/a9s/ts/logos/cc/', $license-code, '.png')"/>
    
    <xsl:if test="unparsed-text-available($license-image)">
      <xsl:message select="$license-image"></xsl:message>
    </xsl:if>
    <div class="license">
      <p class="license-image">
        <img src="{$license-image}" alt="Creative Commons License {upper-case($license-code)}"/>
      </p>
      <p class="licence-text">
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </p>
      <p class="licence-link">
        Weitere Informationen finden Sie unter 
        <a class="license-href" href="{$license-url}"><xsl:value-of select="$license-url"/></a>.
      </p>
    </div>
  </xsl:template>
  
  <!-- indent attribute -->
  
<!--  <xsl:template match="html:p[preceding-sibling::*[1][self::html:p[not(matches(@class, 'heading-author'))]]]
                             [not(matches(@class, 'footnote|literature'))]
                             [not(parent::html:div[matches(@class, 'tsbox')])]" mode="clean-up">
    <p class="{if(@class) then concat(@class, ' indent') else 'indent'}">
      <xsl:apply-templates select="@* except @class, node()" mode="#current"/>
    </p>
  </xsl:template>-->
  
  <!-- remove overrides to avoid that CSS stylesheet instructions have no effect -->
  
  <xsl:template name="css:remaining-atts">
    <xsl:param name="remaining-atts" as="attribute(*)*"/>
    <xsl:variable name="atts" as="attribute(*)*">
      <xsl:apply-templates select="$remaining-atts[not(namespace-uri() = 'http://www.w3.org/1996/css')]" mode="#current"/>
    </xsl:variable>
    <xsl:variable name="css-atts" as="attribute(*)*">
      <xsl:apply-templates select="$remaining-atts[namespace-uri() = 'http://www.w3.org/1996/css']" mode="hub2htm:css-style-overrides"/>
    </xsl:variable>
    <xsl:if test="exists($css-atts) and not($css-atts = (
                                            @css:line-height,
                                            @css:margin-top,
                                            @css:margin-left,
                                            @css:margin-bottom,
                                            @css:margin-right,
                                            @css:font-family,
                                            @css:font-size,
                                            @css:color)
                                            )">
      <xsl:attribute name="style"
                     select="string-join(
                                         for $a in $css-atts[not(starts-with(name(), 'pseudo'))] 
                                         return concat(local-name($a), ': ', $a),
                                         '; '
                                         )" />
    </xsl:if>
    <xsl:sequence select="$atts"/>
  </xsl:template>
  
  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))]
                           [not(ancestor::*[self::figure or self::table or self::floatingText or self::lg or self::spGrp])]"
                mode="tei2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:variable name="author" select="preceding-sibling::byline[not(@rend = 'override')]/persName" as="element(persName)*"/>
    <xsl:variable name="subtitle" select="following-sibling::head[@type eq 'sub'], preceding-sibling::head[@type eq 'sub']" as="element(head)*"/>    
    <xsl:element name="{if ($heading-level) then concat('h', $heading-level) else 'p'}">
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="title" select="tei2html:heading-title(.)"/>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:apply-templates select="$subtitle" mode="heading-content"/>
    </xsl:element>
    <xsl:apply-templates select="$author" mode="heading-content"/>
  </xsl:template>
  
  
  <xsl:template match="graphic[exists((desc,../figDesc, ../desc)/ref)]" mode="epub-alternatives">
    <!--    https://redmine.le-tex.de/issues/14053-->
    <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:copy select="((desc,../figDesc, ../desc)/ref)[1]/@target"/>
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="desc/ref | figDesc/ref | *[self::desc|self::figDesc][every $n in node() satisfies $n[self::ref]]" mode="epub-alternatives"/>
  
  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))]
                           [not(ancestor::*[self::figure or self::table or self::floatingText or self::lg or self::spGrp])]" mode="class-att">
    <xsl:attribute name="class" select="if (parent::div[@type] or parent::divGen[@type]) 
                                        then (parent::div, parent::divGen)[1]/@type
                                        else @rend"/>
  </xsl:template>

  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))][matches(@rend, 'tsmeta(keyword|abstract)s?heading|tsheadword')]" 
                priority="3" mode="class-att">
    <xsl:attribute name="class" select="@rend"/>
  </xsl:template>

  <xsl:template match="head/label" mode="tei2html" priority="3">
    <xsl:next-match/>
    <xsl:if test="following-sibling::node()[1][self::seg[@type='tab'] or self::text()[matches(., '\P{Zs}')]]">
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:function name="tei2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:variable name="level" as="xs:integer?">
      <xsl:choose>
        <xsl:when test="$elt/ancestor::table"/>
        <xsl:when test="$elt/ancestor::lg"/>
        <xsl:when test="$elt/ancestor::spGrp"/>
        <xsl:when test="$elt/ancestor::figure"/>
        <xsl:when test="$elt/ancestor::floatingText"/>
        <xsl:when test="$elt/parent::div/@type = ('part', 'appendix', 'imprint', 'acknowledgements', 'dedication', 'glossary', 'preface') or
                       $elt/parent::divGen/@type = ('index', 'toc')(: or
                       $elt/parent::listBibl:)">
          <xsl:sequence select="3"/>
        </xsl:when>
        <xsl:when test="$elt/parent::div/@type = ('chapter', 'article')">
          <xsl:sequence
            select="
              if ($elt/ancestor::div/@type = 'part') then
                4
              else
                3"
          />
        </xsl:when>
        <xsl:when test="$elt/parent::listBibl[not(parent::div[@type = 'bibliography'])]">
          <xsl:sequence select="if ($elt/ancestor::div/@type = 'part') 
                                then count($elt/ancestor::*[self::div[@type eq 'section'] | self::listBibl]) + 4
                                else count($elt/ancestor::*[self::div[@type eq 'section'] | self::listBibl]) + 3"/>
        </xsl:when>
        <xsl:when test="$elt/parent::div[@type = ('section')] or $elt/parent::argument">
          <xsl:choose>
            <xsl:when test="$elt/parent::argument">
              <xsl:sequence select="if ($elt/ancestor::div/@type = ('part')) 
                                    then 5
                                    else 4"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="count($elt/ancestor::div[@type = ('part', 'chapter', 'article', 'section')]) + 2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$elt/parent::div/@type = 'bibliography' 
                        or 
                        $elt/parent::listBibl[parent::div[@type = 'bibliography']]">
          <xsl:sequence select="if ($elt/ancestor::*[self::div[@type = ('chapter', 'article')]]) 
                                then 3 + count($elt/ancestor::*[self::div[@type = ('part', 'chapter',  'article', 'section')]])
                                else 3 + count($elt/ancestor::*[self::div[@type = 'part']])"/>

        </xsl:when>
        <xsl:when test="$elt/parent::*[matches(local-name(.), '^div\d')]">
          <xsl:sequence select="count($elt/ancestor::*[matches(local-name(.), '^div')])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="custom" as="xs:integer?">
            <xsl:apply-templates select="$elt" mode="tei2html_heading-level"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$custom">
              <xsl:sequence select="$custom"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>(tei2html) No heading level for <xsl:copy-of select="$elt/.."
                /></xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence
      select="
        if ($level castable as xs:integer)
        then
          if (xs:integer($level) gt 6)
          then
            6
          else
            $level
        else
          $level"
    />
  </xsl:function>

  <xsl:template match="byline/persName" mode="heading-content">
    <p class="heading-author">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>
  
  <xsl:template match="head[@type eq 'sub']" mode="heading-content">
    <xsl:text> </xsl:text>
    <br/>
    <span class="heading-subtitle">
      <xsl:apply-templates mode="tei2html"/>
    </span>
  </xsl:template>
  
  <xsl:template match="byline/persName
                      |head[@type eq 'sub']" mode="tei2html"/>
  
  
  <xsl:template match="head[matches(@rend, $tei2html:no-toc-style-regex)]" mode="toc" priority="5"/>

  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))][not(parent::*[self::figure | self::table | self::lg])]" 
                mode="toc" priority="3">
    <xsl:variable name="author" select="preceding-sibling::byline/persName" as="element(persName)*"/>
    <xsl:variable name="subtitle" select="following-sibling::head[@type eq 'sub'], preceding-sibling::head[@type eq 'sub']" as="element(head)*"/>
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:element name="{if(matches($tei2html:epub-type, '3')) then 'li' else 'p'}">
      <xsl:attribute name="class" select="concat('toc', $heading-level)"/>
      <a href="#{(@xml:id, generate-id())[1]}">
       
        <xsl:variable name="toc-heading-content">
          <xsl:if test="label">
            <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
            <xsl:apply-templates select="label" mode="label-sep"/>
          </xsl:if>
          <xsl:apply-templates select="node() except label" mode="strip-indexterms-etc">
            <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains(@rend, 'tsheading1')">
            <!-- https://redmine.le-tex.de/issues/14980 -->
            <span class="article-title">
              <xsl:sequence select="$toc-heading-content"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$toc-heading-content"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$subtitle, $author" mode="#current">
          <xsl:with-param name="in-toc" as="xs:boolean" select="true()" tunnel="yes"/>
        </xsl:apply-templates>
      </a>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="byline/persName" mode="toc">
    <br/>
    <span class="toc-author">
      <xsl:apply-templates select="node()" mode="tei2html"/>
    </span>
  </xsl:template>
  
  <xsl:template match="head[@type eq 'sub']" mode="toc">
    <br/>
    <span class="toc-subtitle">
      <xsl:apply-templates mode="tei2html"/>
    </span>
  </xsl:template>
  
  <xsl:template name="footnote-heading">
    <xsl:variable name="level" select="if (self::div[@type = ('chapter', 'article', 'appendix', 'preface')][not(..[@type = 'appendix'])]) 
                                      then (tei2html:heading-level(head[@type = 'main'][1])) 
                                      else 2" />
    <xsl:element name="h{$level + 1}">
      <xsl:attribute name="class" select="'notes-headline'"/>
      <xsl:value-of select="(//p[@rend eq 'tsendnotesheading'],
        /TEI[@xml:lang eq 'de']/'Endnoten',
        'Endnotes')[1]"/>
    </xsl:element>
  
    <!-- https://redmine.le-tex.de/issues/8785; https://redmine.le-tex.de/issues/13460 -->    
  </xsl:template>

  <xsl:template match="p[@rend eq 'tsendnotesheading']" mode="tei2html"/>  

  <xsl:template match="*:lb" mode="strip-indexterms-etc tei2html">
    <!-- https://redmine.le-tex.de/issues/12371 -->
    <xsl:choose>
      <xsl:when test="ancestor::epigraph[@rend='motto']">
      <!-- https://github.com/transcript-publishing/mapping-conventions/blob/main/motto/index.md#ts_motto-->
        <br/>
      </xsl:when>
      <xsl:when
        test="
        preceding-sibling::node() and matches(preceding-sibling::node()[1], '\s$') or
        following-sibling::node() and matches(following-sibling::node()[1], '^\s')"/>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*:head//*:lb" mode="tei2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$in-toc">
        <xsl:apply-templates select="." mode="strip-indexterms-etc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="p[matches(@rend, '^tscodeblock[a-z0-9]+$')]" mode="tei2html">
    <pre>
      <xsl:apply-templates mode="#current"/>
    </pre>
  </xsl:template>
  
  <xsl:template match="p[matches(@rend, '^tscodeblock[a-z0-9]+$')]/hi" mode="tei2html">
    <code class="{replace(parent::p/@rend, '^tscodeblock', '')}">
      <xsl:apply-templates mode="#current"/>
    </code>
  </xsl:template>
  
  <xsl:template match="*:img[contains(../@class, 'fig')][../*:p[*:span[@class='hub:caption-text']]]/@alt[.= '']" mode="clean-up">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="../../*:p[*:span[@class='hub:caption-text']]/*:span[@class='hub:caption-text']" mode="strip-indexterms-etc"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="*:blockquote//*:p[matches(@class,'tsquotation|tsverse|tsdialogue')]/@class | 
                       *:blockquote/@class[. = 'tsquotation']" mode="clean-up">
    <!--https://redmine.le-tex.de/issues/11749, https://redmine.le-tex.de/issues/13605-->
  </xsl:template>

  <xsl:template match="abstract" mode="tei2html"/>

  <xsl:template match="*:header/abstract" mode="tei2html" priority="2">
    <div class="chunk-abstract">
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:key name="tei:by-corresp" match="*[@corresp]" use="@corresp"/>

  <xsl:template match="tei:div[@type= 'chapter'][count(key('tei:by-corresp', concat('#', @xml:id))) gt 0] | 
                       tei:divGen[@type= 'toc'][count(key('tei:by-corresp', concat('#', @xml:id))) gt 0]" mode="epub-alternatives">
    <xsl:copy copy-namespaces="yes">
      <xsl:apply-templates select="@*" mode="#current"/>
      <header rend="chunk-meta-sec"><xsl:apply-templates select="key('tei:by-corresp', concat('#', @xml:id))" mode="meta"/></header>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:keywords[contains(@rendition,'Keywords')]" mode="meta">
    <ul rend="chunk-keywords">
      <xsl:for-each select="*:term">
        <li><xsl:value-of select="."/></li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="*:keywords[@rendition='chunk-meta']" mode="meta">
    <ul rend="chunk-metadata">
      <xsl:for-each select="*:term">
        <li rend="{./@key}"><xsl:value-of select="./text()"/></li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="*:abstract" mode="meta">
    <xsl:copy copy-namespaces="yes">
      <xsl:attribute name="rend" select="'chunk-abstract'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="meta">
    <!-- warum matcht langUsage nicht? -->
    <xsl:apply-templates select="teiHeader/profileDesc/langUsage, teiHeader/fileDesc/seriesStmt, teiHeader/fileDesc/publicationStmt/date" mode="#current"/>
  </xsl:template>

  <xsl:template match="seriesStmt" mode="tei2html">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="seriesStmt/idno[@rend= 'tsmetadoi' or @type='doi']" mode="tei2html" priority="3">
    <meta name="doi" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="seriesStmt/*" mode="tei2html" priority="2"/>

  <xsl:template match="byline/affiliation | byline/email | byline/ref | byline/idno | byline[@rend='override']" mode="tei2html"/>
  
  <xsl:template match="tei:p[matches(@rend, 'tsquotation')][descendant::tei:lb]" mode="epub-alternatives">
    <!-- https://redmine.le-tex.de/issues/12371-->
    <xsl:variable name="context" select="."/>
    <xsl:for-each-group select="node()" group-starting-with="tei:lb">
      <p xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="$context/@*, current-group()[not(self::tei:lb)]" mode="#current"/>
      </p>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="html:figure[html:p]" mode="clean-up">
    <!-- https://redmine.le-tex.de/issues/13415 -->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, *:img" mode="#current"/>
      <figcaption>
        <xsl:apply-templates select="node()[not(self::*:img)]" mode="#current"/>
      </figcaption>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="(table|figure)/head//*[self::seg[starts-with(@rend, 'hub:')]|self::label]" mode="tei2html" priority="5">
    <!-- https://redmine.le-tex.de/issues/13415 -->
    <xsl:apply-templates select="node()" mode="#current"/>
    <!-- https://redmine.le-tex.de/issues/15425-->
      <xsl:apply-templates select="." mode="label-sep"/>
    <xsl:if test=".[self::seg[@rend='hub:caption-number'] 
                    or 
                    self::label[not(..[self::seg[@rend='hub:caption-number']])]]
                   [following-sibling::node()[1][not(matches(., '^\p{Zs}'))]]">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="(table|figure)/head/*[self::seg[starts-with(@rend, 'hub:')]|self::label]" mode="label-sep">
    <xsl:text>:</xsl:text>
  </xsl:template>

  <xsl:template match="html:figure/html:p" mode="clean-up">
    <!-- https://redmine.le-tex.de/issues/13415 -->
    <xsl:element name="p">
      <xsl:attribute name="class" select="if (@class = 'tsfiguresource') then 'fig-source' else 'fig-title'"/>
      <xsl:apply-templates select="@* except @class, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@xml:lang" mode="clean-up">
    <!--https://redmine.le-tex.de/issues/13609-->
  </xsl:template>

  
  <xsl:template name="lof" match="*[head[matches(@rend, $list-of-figures-regex)]]" mode="tei2html" priority="5">
    <xsl:if test="//figure[normalize-space(head)]">
      <xsl:variable name="list-type" as="xs:string" 
                  select="if (some $fig in //figure[normalize-space(head)] satisfies $fig/head/*[self::label|self::seg[@rend = ('hub:caption-number', 'hub:identifier')]
                                                                                                                         [normalize-space()]]) then 'dl' else 'ul'"/>
      <div epub:type="loi" class="lox loi">
        <xsl:choose>
          <xsl:when test="head">
            <xsl:apply-templates select="head" mode="#current"/>
          </xsl:when>
          <xsl:otherwise><h3>List of Figures</h3></xsl:otherwise>
        </xsl:choose>
        <xsl:element name="{$list-type}">
          <xsl:apply-templates select="//figure[normalize-space(head)]" mode="lox">
            <xsl:with-param name="list-type" select="$list-type" as="xs:string" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:element>
      </div>
    </xsl:if>
  </xsl:template>

   <xsl:template name="lot" match="*[head[matches(@rend, $list-of-tables-regex)]]" mode="tei2html" priority="5">
    <xsl:if test="//table[normalize-space(head)]">
      <xsl:variable name="list-type" as="xs:string" 
                  select="if (some $tab in //table[normalize-space(head)] satisfies $tab/head/*[self::label|self::seg[@rend = ('hub:caption-number', 'hub:identifier')]
                                                                                                                        [normalize-space()]]) then 'dl' else 'ul'"/>
      <div epub:type="lot" class="lox lot">
        <xsl:choose>
          <xsl:when test="head">
            <xsl:apply-templates select="head" mode="#current"/>
          </xsl:when>
          <xsl:otherwise><h3>List of Tables</h3></xsl:otherwise>
        </xsl:choose>
        <xsl:element name="{$list-type}">
          <xsl:apply-templates select="//table[head[normalize-space()]]" mode="lox">
            <xsl:with-param name="list-type" select="$list-type" as="xs:string" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:element>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="figure | table" mode="lox">
    <xsl:param name="list-type" as="xs:string" tunnel="yes"/>
    <xsl:choose><xsl:when test="$list-type = 'dl'">
      <xsl:variable name="label" as="node()*">
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type), head])[1]/*[self::label|self::seg[@rend = ('hub:caption-number', 'hub:identifier')]]" mode="strip-indexterms-etc"/>
      </xsl:variable>
      <dt>
        <xsl:sequence select="if (string-join($label, '')[normalize-space()]) then $label else '→'"/>
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type), head])[1]/*[self::label|self::seg[@rend = ('hub:caption-number', 'hub:identifier')]]" mode="label-sep"/>
      </dt>
      <dd>
        <a href="#{@xml:id}">
          <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type), head])[1]/node()[not(self::label|self::seg[@rend = ('hub:caption-number', 'hub:identifier')])]" mode="strip-indexterms-etc"/>
        </a>
      </dd>
    </xsl:when>
      <xsl:otherwise>
        <li>
          <a href="#{@xml:id}">
            <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type), head])[1]/node()" mode="strip-indexterms-etc"/>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="html:div[contains(@class, 'lox')]/html:dl/html:dd/html:a/descendant::text()[1]" mode="clean-up">
    <!-- clean text of tabs etc. -->
    <xsl:value-of select="replace(., '^\p{Zs}+', '')"/>
  </xsl:template>

  <xsl:template match="argument[@rend = ('abstract', 'keywords', 'alternative-title')]" mode="tei2html">
    <!-- dissolve, https://redmine.le-tex.de/issues/13842 -->
    <xsl:apply-templates select="node()"  mode="#current"/>
  </xsl:template>

  <xsl:template match="hi[matches(@rend, 'italic|em|bold|strong|underline|superscript|subscript')]" mode="tei2html" priority="5">
    <xsl:apply-templates select="." mode="create-style-elts"/>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'subscript')]" mode="create-style-elts" priority="6">
    <sub><xsl:next-match/></sub>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'superscript')]" mode="create-style-elts"  priority="5">
    <sup><xsl:next-match/></sup>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'italic')] | hi[contains(@rend, 'em')]" mode="create-style-elts"  priority="4">
    <em><xsl:next-match/></em>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'bold')] | hi[contains(@rend, 'strong')]" mode="create-style-elts"  priority="3">
    <strong><xsl:next-match/></strong>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'underline')]" mode="create-style-elts"  priority="2">
    <u><xsl:next-match/></u>
  </xsl:template>

  <xsl:template match="hi[matches(@rend, 'italic|em|bold|strong|underline|superscript|subscript')]" mode="create-style-elts" priority="1">
    <xsl:apply-templates select="@* except @rend" mode="tei2html"/>
    <xsl:if test="some $t in tokenize(@rend, '\s') satisfies $t[not(. = ('italic', 'em', 'bold', 'strong', 'underline', 'superscript','subscript'))]">
      <xsl:attribute name="class" select="normalize-space(replace(@rend, '(italic|em|bold|strong|underline|superscript|subscript)\s?', ''))"/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="tei2html"/>
  </xsl:template>
<!--
  <xsl:template match="hi[@rend = 'bold']" mode="tei2html" priority="5">
    <b>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </b>
  </xsl:template>-->

  <xsl:template match="hi[matches(@rend, 'italic|em|bold|strong|underline|superscript|subscript')]/@*[name() = ('css:font-weight', 'css:font-style', 'css:text-decoration', 'css:vertical-align')]" mode="tei2html"/>

  <xsl:template match="epigraph | div[@type = 'motto']" mode="tei2html" priority="3">
    <!-- https://redmine.le-tex.de/issues/15339 -->
    <xsl:choose>
      <xsl:when test="parent::*[self::div[@type = 'motto']]">
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <blockquote class="epigraph">
          <xsl:apply-templates select="node()" mode="#current"/>
        </blockquote>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="p[matches(@rend, 'tsmottosource')]" mode="tei2html" priority="3">
    <cite>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </cite>
  </xsl:template>


</xsl:stylesheet>
