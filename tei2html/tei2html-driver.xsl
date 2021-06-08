<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css" 
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
  
  <xsl:variable name="divify-sections" select="'no'"/>
  
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
        <!--<xsl:apply-templates select="teiHeader/encodingDesc/css:rules" mode="#current"/>-->
      </head>
      <body>
        <xsl:call-template name="half-title"/>
        <xsl:call-template name="frontispiece"/><!-- series page not needed, yet -->
        <xsl:call-template name="full-title"/>
        <xsl:call-template name="imprint"/>
        <xsl:call-template name="toc"/>
        <xsl:call-template name="lof"/>
        <xsl:call-template name="lot"/>
        <xsl:call-template name="html-body"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="half-title">
    <section class="halftitle title-page" epub:type="halftitlepage" id="halftitle">
      <xsl:apply-templates select="$metadata[@key = ('Kurztext', 'Autoreninformationen', 'Widmung')]" mode="#current"/>
    </section>
  </xsl:template>
  
  <xsl:template name="frontispiece">
    <section class="{local-name()} title-page" epub:type="seriespage">
      <xsl:apply-templates select="$metadata[@key = ('Reihe', 'Bandnummmer')], $metadata[@key = 'Reihenlogo']" mode="#current"/>
    </section>
  </xsl:template>
  
  <xsl:template name="full-title">
    <section class="fulltitle title-page" epub:type="titlepage" id="title-page">
      <xsl:apply-templates select="$metadata[@key = ('Autor', 'Titel', 'Untertitel')]" mode="#current"/>
      <div class="logo">
        <img src="http://this.transpect.io/a9s/ts/logos/transcript_rgb.png" alt="Transcript Verlag"/>
      </div>
    </section>
  </xsl:template>
  
  <xsl:template name="imprint">
    <section class="title-page imprint" epub:type="imprint">
      <xsl:apply-templates select="$metadata[@key = ('Qualifikationsnachweis', 
                                                     'Gutachter', 
                                                     'Dank', 
                                                     'Fordertext', 
                                                     'Forderlogos', 
                                                     'Bibliografische_Information', 
                                                     'Copyright', 
                                                     'Lizenzlogo', 
                                                     'Lizenz', 
                                                     'Lizenzlink', 
                                                     'Lizenztext', 
                                                     'Umschlaggestaltung', 
                                                     'Umschlagcredit', 
                                                     'Lektorat', 
                                                     'Korrektorat', 
                                                     'Satz', 
                                                     'Konvertierung', 
                                                     'Print-ISBN', 
                                                     'PDF-ISBN', 
                                                     'ePUB-ISBN')]" mode="#current"/>
    </section>
  </xsl:template>
  
  <!-- default handler for metadata terms -->
  
  <xsl:template match="term[@key]" mode="tei2html" priority="-1">
    <p class="{lower-case(translate(@key, ' ', '-'))}">
      <xsl:apply-templates mode="#current"/>
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
      <a href="{.}">
        <xsl:apply-templates mode="#current"/>
      </a>
    </p>
  </xsl:template>

  <xsl:template match="term[@key = 'Lizenzlogo']" mode="tei2html">
    <xsl:if test="matches(., '\S')">
    <!-- file:///X:/Ablagen/Titeleien/Reihenlogos/TIT_cc_by_nc_nd_logo.EPS → http://this.transpect.io/a9s/ts/logos/cc/by-nc-nd.png-->
    <div class="{lower-case(translate(@key, ' ', '-'))}">
       <img alt="Lizenzlogo Creative Commons" src="{replace(translate(., '_', '-'), '^.+/TIT-cc-(.+)-logo\.(eps|EPS)', 'http://this.transpect.io/a9s/ts/logos/cc/$1.png')}"/>
    </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term[@key = 'Reihenlogo']" mode="tei2html">
    <xsl:if test="matches(., '\S')">
    <!-- file:///X:/Ablagen/Titeleien/Reihenlogos/REIHENLOGO_KUL_ZIG.EPS → http://this.transpect.io/a9s/ts/logos/series/REIHENLOGO_KUL_ZIG.png-->
    <div class="{lower-case(translate(@key, ' ', '-'))}">
       <img alt="Reihenlogo" src="{replace(., '^.+/(.+)\.(eps|EPS)', 'http://this.transpect.io/a9s/ts/logos/series/$1.png')}"/>
    </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term[@key eq 'Forderlogos']" mode="tei2html">
    <xsl:if test="matches(., '\S')">

    <div class="{lower-case(translate(@key, ' ', '-'))}">
       <xsl:for-each select="tokenize(normalize-space(.), '\s+', 'm')"><img alt="Förderlogo" src="{replace(., '^.+/(.+)\.(eps|EPS)', concat($s9y1-path, '$1.png'))}"/></xsl:for-each>
    </div>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="meta-roles" as="element()">
    <meta-role>
      <meta-role de="Umschlaggestaltung" en="Cover design"/>
      <meta-role de="Korrektorat" en="Proofreading"/>
      <meta-role de="Lektorat" en="Editing"/>
      <meta-role de="Konvertierung" en="Conversion"/>
      <meta-role de="Satz" en="Typesetting"/>
      <meta-role de="Gutachter" en="Appraiser"/>
    </meta-role>
  </xsl:variable>

  <xsl:template match="term[@key = ('Umschlaggestaltung', 'Korrektorat', 'Lektorat', 'Konvertierung', 'Satz')]" mode="tei2html">
    <xsl:if test="matches(., '\S')">
      <p class="{lower-case(translate(@key, ' ', '-'))}">
        <span class="meta-role"><xsl:value-of select="concat(if (/*/@xml:lang='en') then $meta-roles/*:meta-role[@de = current()/@key]/@en else @key, ': ')"/></span>
        <xsl:apply-templates mode="#current"/>
      </p>
    </xsl:if>
  </xsl:template>
 
  <xsl:template match="term[@key eq 'Umschlagcredit']" mode="tei2html">
    <xsl:if test="matches(., '\S')">
      <p class="{lower-case(translate(@key, ' ', '-'))}">
        <span class="meta-role"><xsl:value-of select="if (/@xml:lang='en') then 'Umschlagabbildung: ' else 'Cover image: '"/></span>
        <xsl:apply-templates mode="#current"/>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template name="toc">
    <nav class="toc" epub:type="toc" id="toc">
      <xsl:call-template name="generate-toc-headline"/>
      <xsl:apply-templates select="/TEI/text/front/divGen[@type = 'toc']/*:header[@rend = 'chunk-meta-sec']" mode="tei2html"/>
      <xsl:call-template name="generate-toc-body">
        <xsl:with-param name="toc_level" select="$toc-depth"/>
      </xsl:call-template>
    </nav>
  </xsl:template>
  
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
  </xsl:template>
  
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
  
  <xsl:template match="html:p[preceding-sibling::*[1][self::html:p[not(matches(@class, 'heading-author'))]]]
                             [not(matches(@class, 'footnote|literature'))]" mode="clean-up">
    <p class="{if(@class) then concat(@class, ' indent') else 'indent'}">
      <xsl:apply-templates select="@* except @class, node()" mode="#current"/>
    </p>
  </xsl:template>
  
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
    <xsl:variable name="author" select="preceding-sibling::byline/persName" as="element(persName)*"/>
    <xsl:variable name="subtitle" select="preceding-sibling::head[@type eq 'sub']" as="element(head)?"/>    
    <xsl:element name="{if ($heading-level) then concat('h', $heading-level) else 'p'}">
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="class"
        select="if (parent::div[@type] or parent::divGen[@type]) 
                then (parent::div, parent::divGen)[1]/@type
                else local-name()"/>
      <xsl:attribute name="title" select="tei2html:heading-title(.)"/>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:apply-templates select="$subtitle" mode="heading-content"/>
    </xsl:element>
    <xsl:apply-templates select="$author" mode="heading-content"/>
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
        <!--<xsl:when test="$elt/ancestor::div1"/>
        <xsl:when test="$elt/ancestor::div2"/>-->
        <xsl:when
          test="
            $elt/parent::div/@type = ('part', 'appendix', 'imprint', 'acknowledgements', 'dedication', 'glossary', 'preface') or
            $elt/parent::divGen/@type = ('index', 'toc') or
            $elt/parent::listBibl">
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
        <xsl:when test="$elt/parent::div/@rend = ('abstract', 'keywords', 'alternative-title')">
          <xsl:sequence
            select="
              if ($elt/ancestor::div/@type = ('chapter', 'article')) then
                5
              else
                4"
          />
        </xsl:when>
        <xsl:when test="$elt/parent::div[@type = ('section')][not(@rend = ('abstract', 'keywords', 'alternative-title'))]">
          <xsl:sequence select="count($elt/ancestor::div[@type eq 'section']) + 3"/>
        </xsl:when>
        <xsl:when test="$elt/parent::div/@type = ('bibliography')">
          <xsl:sequence
            select="
              if ($elt/ancestor::div/@type = ('chapter', 'article')) then
                5
              else
                4"
          />
        </xsl:when>
        <xsl:when test="$elt/parent::*[matches(local-name(.), '^div\d')]">
          <xsl:sequence select="count($elt/ancestor::*[matches(local-name(.), '^div')])"/>
        </xsl:when>
        <xsl:when test="$elt/parent::argument">
         <xsl:sequence
            select="
              if ($elt/ancestor::div/@type = ('chapter', 'article')) then
                5
              else
                4"
          />
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
    <br/>
    <span class="heading-subtitle">
      <xsl:apply-templates mode="tei2html"/>
    </span>
  </xsl:template>
  
  <xsl:template match="byline/persName
                      |head[@type eq 'sub']" mode="tei2html"/>
  
  
  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))][not(parent::*[self::figure | self::table | self::lg])]" 
                mode="toc" priority="3">
    <xsl:variable name="author" select="preceding-sibling::byline/persName" as="element(persName)*"/>
    <xsl:variable name="subtitle" select="preceding-sibling::head[@type eq 'sub']" as="element(head)?"/>
    <xsl:element name="{if(matches($tei2html:epub-type, '3')) then 'li' else 'p'}">
      <xsl:attribute name="class" select="concat('toc', tei2html:heading-level(.))"/>
      <xsl:apply-templates select="$author" mode="#current"/>
      <a href="#{(@xml:id, generate-id())[1]}">
        <xsl:if test="label">
          <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
          <xsl:apply-templates select="label" mode="label-sep"/>
        </xsl:if>
        <xsl:apply-templates select="node() except label" mode="strip-indexterms-etc">
          <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$subtitle" mode="#current"/>
      </a>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="byline/persName" mode="toc">
    <span class="toc-author">
      <xsl:value-of select="."/>
    </span>
    <br/>
  </xsl:template>
  
  <xsl:template match="head[@type eq 'sub']" mode="toc">
    <br/>
    <span class="toc-subtitle">
      <xsl:apply-templates mode="tei2html"/>
    </span>
  </xsl:template>
  
  <xsl:template name="footnote-heading">
    <p>
      <xsl:attribute name="class" select="'notes-headline'"/>
      <xsl:value-of select="(//p[@rend eq 'tsendnotesheading'],
        /TEI[@xml:lang eq 'de']/'Endnoten',
        'Endnotes')[1]"/>
    </p>
    <!-- https://redmine.le-tex.de/issues/8785 -->    
  </xsl:template>
  
  <xsl:template match="p[@rend eq 'tsendnotesheading']" mode="tei2html"/>  

  <xsl:template match="*:head//*:lb" mode="strip-indexterms-etc">
    <xsl:choose>
      <xsl:when
        test="
        preceding-sibling::node()[1]/(self::text()) and matches(preceding-sibling::node()[1], '\s$') or
        following-sibling::node()[1]/(self::text()) and matches(following-sibling::node()[1], '^\s')"/>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="p[matches(@rend, '^tscodeblock[a-z0-9]+$')]" mode="tei2html">
    <pre>
      <xsl:apply-templates mode="#current"/>
    </pre>
  </xsl:template>
  
  <xsl:template match="p[matches(@rend, '^tscodeblock')]/hi" mode="tei2html">
    <code class="{replace(parent::p/@rend, '^tscodeblock', '')}">
      <xsl:apply-templates mode="#current"/>
    </code>
  </xsl:template>

  <xsl:template match="*:img[contains(../@class, 'fig')][../*:p[*:span[@class='hub:caption-text']]]/@alt[.= '']" mode="clean-up">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="../../*:p[*:span[@class='hub:caption-text']]/*:span[@class='hub:caption-text']" mode="strip-indexterms-etc"/>
    </xsl:attribute>
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

  <xsl:template match="*:keywords[@rendition='Keywords']" mode="meta">
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

  <xsl:template match="seriesStmt/idno[@rend= 'tsmetadoi']" mode="tei2html">
    <meta name="doi" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="byline/affiliation | byline/email | byline/ref" mode="tei2html"/>

  <xsl:template match="html:i[html:i] | html:b[html:b] | html:i[html:p] | html:b[html:p]" mode="clean-up">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="figure[count(head) gt 1]/head[not(normalize-space())]" mode="epub-alternatives"/>
  
</xsl:stylesheet>