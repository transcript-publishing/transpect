<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:html="http://www.w3.org/1999/xhtml"  
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:tr="http://transpect.io" exclude-result-prefixes="xs c epub"
  version="2.0">
  
<!--  <xsl:variable name="epub-config" as="document-node(element(epub-config))?" select="collection()[1]"/>-->
  <xsl:variable name="metadata" as="document-node(element())?" select="collection()[//*:plist]"/>
  
  <xsl:variable name="htmlinput" as="document-node(element(html:html))*">
    <xsl:sequence select="collection()[/html:html]"/>
  </xsl:variable>
  
  <xsl:param name="debug-dir-uri" as="xs:string?"/>
  <xsl:param name="s9y1" as="xs:string?"/>
  <xsl:param name="s9y2" as="xs:string?"/>
  <xsl:param name="s9y3" as="xs:string?"/>
  <xsl:param name="s9y4" as="xs:string?"/>
  <xsl:param name="s9y5" as="xs:string?"/>
  <xsl:param name="s9y6" as="xs:string?"/>
  <xsl:param name="s9y7" as="xs:string?"/>
  <xsl:param name="s9y8" as="xs:string?"/>
  <xsl:param name="s9y9" as="xs:string?"/>
  <xsl:param name="s9y1-path" as="xs:string?"/>
  <xsl:param name="s9y2-path" as="xs:string?"/>
  <xsl:param name="s9y3-path" as="xs:string?"/>
  <xsl:param name="s9y4-path" as="xs:string?"/>
  <xsl:param name="s9y5-path" as="xs:string?"/>
  <xsl:param name="s9y6-path" as="xs:string?"/>
  <xsl:param name="s9y7-path" as="xs:string?"/>
  <xsl:param name="s9y8-path" as="xs:string?"/>
  <xsl:param name="s9y9-path" as="xs:string?"/>
  <xsl:param name="s9y1-role" as="xs:string?"/>
  <xsl:param name="s9y2-role" as="xs:string?"/>
  <xsl:param name="s9y3-role" as="xs:string?"/>
  <xsl:param name="s9y4-role" as="xs:string?"/>
  <xsl:param name="s9y5-role" as="xs:string?"/>
  <xsl:param name="s9y6-role" as="xs:string?"/>
  <xsl:param name="s9y7-role" as="xs:string?"/>
  <xsl:param name="s9y8-role" as="xs:string?"/>
  <xsl:param name="s9y9-role" as="xs:string?"/>
  
  <xsl:param name="toc-levels" as="xs:string?"/>
  <xsl:param name="epub-version" as="xs:string"/>

  <xsl:variable name="items" as="xs:string*" 
    select="($s9y1, $s9y2, $s9y3, $s9y4, $s9y5, $s9y6, $s9y7, $s9y8, $s9y9)"/>
  <xsl:variable name="paths" as="xs:string*" 
    select="($s9y1-path, $s9y2-path, $s9y3-path, $s9y4-path, $s9y5-path, $s9y6-path, $s9y7-path, $s9y8-path, $s9y9-path)"/>
  <xsl:variable name="roles" as="xs:string*" 
    select="($s9y1-role, $s9y2-role, $s9y3-role, $s9y4-role, $s9y5-role, $s9y6-role, $s9y7-role, $s9y8-role, $s9y9-role)"/>
  <xsl:variable name="work-path" as="xs:string?" select="$paths[position() = index-of($roles, 'work')]"/>
  <xsl:variable name="series" as="xs:string?" select="$items[position() = index-of($roles, 'production-line')]"/>
  <xsl:variable name="work" as="xs:string?" select="$items[position() = index-of($roles, 'work')]"/>
	<xsl:variable name="publisher-path" as="xs:string?" select="$paths[position() = index-of($roles, 'publisher')]"/>
  
  <xsl:param name="qa-run" select="'false'"/>
  <!-- internal conversion for QA purposes, will render some errors -->
  <xsl:variable name="is-qa-run" as="xs:boolean" select="$qa-run = 'true'"/>

  <!-- currently not in use: --> 
  <xsl:variable name="no-dedicated-info" as="xs:boolean" select="false()"/>

  <xsl:key name="by-id" match="*[@id | @xml:id]" use="@id | @xml:id"/>
  <xsl:key name="target-by-href" match="*[@id | @xml:id]" use="@id | @xml:id"/>
  
  <xsl:variable name="restructured-body-parts" select="$htmlinput[1]/html:html/html:body/*[@epub:type = 'imprint'], 
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'titlepage'],
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'halftitlepage'],
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'dedication'],
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'toc']" as="element(*)*"/>
  <xsl:variable name="language" as="xs:string?" select="(
                                                         $htmlinput[1]/html:html/@lang, $metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Sprache']],
                                                         'de'
                                                         )[1]"/>
  
  
  <xsl:template name="main">
    <html>
      <head>
        <xsl:call-template name="htmltitle"/>
        <xsl:apply-templates select="$metadata//*:dict" mode="meta"/>
        <xsl:apply-templates
          select="$htmlinput[1]/html:html/html:head/node() except ($htmlinput[1]/html:html/html:head/html:title, $htmlinput[1]/html:html/html:head/html:meta[@name = 'lang'])"/>
      </head>
      <!-- will be generated: -->
      <xsl:call-template name="body">
        <xsl:with-param name="_work-lang" as="xs:string" select="$language" tunnel="yes"/>
      </xsl:call-template>
    </html>
  </xsl:template>


  <xsl:template match="/" mode="meta">
    <xsl:apply-templates select="*//*:dict" mode="#current"/>
  </xsl:template>
<!--
  <key>ePUB-ISBN</key>-->
  
  <xsl:template match="*:dict" mode="meta">
    <meta name="DC.creator" content="{normalize-space(string-join($metadata//key[. = ('Autor', 'Herausgeber')]/following-sibling::*[1][normalize-space()]/descendant-or-self::string, ' '))}"/>
    <meta name="DC.title" content="{normalize-space(string-join($metadata//key[. = ('Titel')]/following-sibling::*[1][normalize-space()]/descendant-or-self::string, ' '))}"/>
    <meta name="DC.identifier" content="{(normalize-space(string-join($metadata//key[. = ('ePUB-ISBN')]/following-sibling::*[1][normalize-space()]/descendant-or-self::string, ' '))[normalize-space()],
                                          $htmlinput[1]/html:html/html:head/html:meta[@name='doi']/@content
                                          )[1]}"/>
    <meta name="DC.publisher" content="{(normalize-space(string-join($metadata//key[. = ('Verlagsname')]/following-sibling::*[1]/descendant-or-self::string, ' '))[normalize-space()], 'transcript Verlag')[1]}"/>
    <xsl:if test="$metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Kurztext']]">
      <meta name="DC.description" content="{normalize-space(string-join($metadata//key[. = ('Kurztext')]/following-sibling::*[1]/descendant-or-self::string, ' '))}"/>
    </xsl:if>
    <xsl:variable name="copyright" select="normalize-space(string-join($metadata//key[. = 'Copyright']/following-sibling::*[1]/descendant-or-self::string, ' '))"/>
    <meta name="DC.date">
      <xsl:attribute name="content" select="if (matches($copyright, '^\s*©\s*\d{4}')) then replace($copyright, '^\s*©\s*(\d{4}).+$', '$1') else format-date(current-date(), '[Y]')"/>
    </meta>
    <xsl:if test="$metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Copyright']]">
       <meta name="DC.rights" content="{$copyright}"/>
    </xsl:if>
    <xsl:if test="$metadata//*[self::array|self::string][normalize-space()][preceding-sibling::*[1][. eq 'Schlagworte']]">
      <xsl:for-each select="tokenize($metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Schlagworte']], ';')[normalize-space()]">
        <meta name="DC.subject" content="{.}"/>
      </xsl:for-each>
    </xsl:if>
    <meta name="lang" content="{$htmlinput[1]/html:html/@lang}"/>
  </xsl:template>
  
   
  <xsl:template match="*[@href][starts-with(@href, '#')]
                               [not(key('target-by-href', replace(@href, '^#', ''), $htmlinput))]" priority="2">
    <!-- discard links without target in sample html -->
    <xsl:choose>
      <xsl:when test="ancestor::nav or ancestor::*[@epub:type = ('toc', 'landmarks', 'page-list')]">
        <a class="no-link">
          <xsl:apply-templates mode="#current"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="cover">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <div id="epub-cover-image-container" epub:type="cover">
      <xsl:if test="$_content">
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="'cover'"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not($_content) and not($epub-version eq 'EPUB3')">
        <h2 class="blind" title="{if ($_work-lang[starts-with(., 'en')]) then $cover-heading-title_en else $cover-heading-title_de}"/>
      </xsl:if>
      <img src="" alt="Cover"/>
    </div>
  </xsl:template>
  
  <xsl:template name="title-page">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'titlepage']">
      <section class="title" xmlns:epub="http://www.idpf.org/2007/ops" epub:type="titlepage">
        <xsl:copy-of select="$restructured-body-parts[@epub:type = 'titlepage']/@*" copy-namespaces="no"/>
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      <xsl:if test="not($_content) and not($epub-version eq 'EPUB3')">
        <h2 class="blind" title="{if ($_work-lang[starts-with(., 'en')]) then $titlepage-heading-title_en else $titlepage-heading-title_de}"/>
      </xsl:if>
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'titlepage']/node()"/>
    </section>
    </xsl:if>
  </xsl:template>

  <xsl:template name="halftitle-page">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'halftitlepage']">
      <section class="title" xmlns:epub="http://www.idpf.org/2007/ops" epub:type="halftitlepage">
        <xsl:copy-of select="$restructured-body-parts[@epub:type = 'halftitlepage']/@*" copy-namespaces="no"/>
<!--        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      <xsl:if test="not($_content)">
        <h3 class="blind" title="{if ($_work-lang[starts-with(., 'en')]) then $book-heading-title_en else $book-heading-title_de}"/>
      </xsl:if>-->
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'halftitlepage']/node()"/>
    </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="impress">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'imprint']">
    <section>
      <xsl:copy-of select="$restructured-body-parts[@epub:type = 'imprint']/@*" copy-namespaces="no"/>
        <xsl:attribute name="id" select="'imprint'"/>
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
<!--      <xsl:if test="not($_content)">
        <h1 class="blind" title="{if ($_work-lang[starts-with(., 'en')]) then $imprint-heading-title_en else $imprint-heading-title_de}"/>
      </xsl:if>-->
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'imprint']/node()"/>
    </section>
    </xsl:if>
  </xsl:template>
  
  
  
  <xsl:template name="about-author">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:bio']">
      <section class="{$restructured-body-parts[@epub:type = 'tr:bio']/@class}" epub:type="tr:bio" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:bio'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Vita_U')] or local-name() = ('h1', 'h2')]) ">
         <xsl:call-template name="_heading">
           <xsl:with-param name="content" select="$_content"/>
           <xsl:with-param name="class" select="$_content/@class"/>
           <xsl:with-param name="prelim" select="$no-dedicated-info"/>
         </xsl:call-template>
       </xsl:if>
       <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:bio']/node()"/>
      </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="about-book">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:about-the-book']">
      <section class="{$restructured-body-parts[@epub:type = 'tr:about-the-book']/@class}" epub:type="tr:about-the-book" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:about-the-book'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Buch_U')] or local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:about-the-book']/node()"/>
      </section>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="about-series">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:additional-info']">
      <section class="{$restructured-body-parts[@epub:type = 'tr:additional-info']/@class}" epub:type="tr:additional-info" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:additional-info'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Reihe_U')] or local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:additional-info']/node()"/>
      </section>
    </xsl:if>
  </xsl:template>
 
  <xsl:template name="dedication">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'dedication']"/>
  </xsl:template>
  
  <xsl:template name="motto">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'epigraph']">
      <div class="{$restructured-body-parts[@epub:type = 'epigraph']/@class}" epub:type="epigraph" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'epigraph'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($_content) and 
                      not($restructured-body-parts[@epub:type = 'epigraph'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) and 
                      not($epub-version eq 'EPUB3')">
          <h1 title="{if ($_work-lang[starts-with(., 'en')]) then $motto-heading-title_en else $motto-heading-title_de}"/>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'epigraph']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="frontispiece">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@class = 'frontispiz preface']">
      <div class="frontispiz preface">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@class = 'frontispiz preface'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($_content) and 
                      not($restructured-body-parts[@class = 'frontispiz preface'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')])  and 
                      not($epub-version eq 'EPUB3')">
          <h1 title="{if ($_work-lang[starts-with(., 'en')]) then $frontispiece-heading-title_en else $frontispiece-heading-title_de}"/>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@class = 'frontispiz preface']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- title of the html document-->
  <xsl:template name="htmltitle" as="element(html:title)">
    <title>
      <xsl:value-of select="(($metadata//string[normalize-space()][preceding-sibling::*[1][. eq 'Titel']],
                                string-join($metadata//array[preceding-sibling::*[1][. eq 'Titel']]//string[normalize-space()]/replace(., '\s+', ' '), ' ')
                              )[1][normalize-space()], $htmlinput[1]/html:html/html:head/html:title)[1]"/>
    </title>
  </xsl:template>

  <xsl:template match="html:meta[@name = 'source-basename']">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="name" select="'identifier'"/>
      <xsl:attribute name="content" select="replace(@content, '^(UV_)?(\d+)(_\d+)?_.*$', '$1$2$3')"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="htmlinput-body">
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/node() 
                                   except ($htmlinput[1]/html:html/html:body/*:nav, 
                                 $restructured-body-parts)"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/*:nav" mode="discard-toc"/>
  </xsl:template>

  <!-- merge-info is a mode that, while processing a meta-titles/webtitle element, pulls in information
       from the meta-roles and meta-persons tables -->
  <xsl:template match="* | @*" mode="merge-info title-page default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
 
  <xsl:template name="toc">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = ('toc')]">
      <xsl:element name="{$restructured-body-parts[@epub:type = ('toc')]/name()}">
        <xsl:copy-of select="$restructured-body-parts[@epub:type = ('toc')]/@*"/>
        <!--      <div class="toc" id="toc" xmlns:epub="http://www.idpf.org/2007/ops" epub:type="toc">-->
        <xsl:choose>
          <xsl:when test="matches($_content, '\S') and not($restructured-body-parts[@epub:type = ('toc')]/*[local-name() = ('h1', 'h2', 'h3')])">
            <xsl:call-template name="_heading">
              <xsl:with-param name="content" select="$_content"/>
              <xsl:with-param name="class" select="'toc'"/>
              <xsl:with-param name="prelim" select="$no-dedicated-info"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not($_content) and 
                          not($restructured-body-parts[@epub:type = ('toc')]/*[local-name() = ('h1', 'h2', 'h3')]) and 
                          not($epub-version eq 'EPUB3')">
              <h1 class="Frontmatter_Ueberschriften_U1_Frontmatter"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $toc-heading-title_en else $toc-heading-title_de"/></h1>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'toc']/node()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

<!--  <xsl:template match="*[@epub:type = 'toc']/*:ol[1]">
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <!-\- https://redmine.le-tex.de/issues/8951-\->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <li class="toc-preface"><a href="#epub-cover-image-container"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $cover-heading-title_en else $cover-heading-title_de"/></a></li>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'halftitlepage']"><li class="toc-preface"><a href="#halftitle"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $book-heading-title_en  else $book-heading-title_de"/></a></li></xsl:if>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'titlepage']"><li class="toc-preface"><a href="#title-page"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $titlepage-heading-title_en else $titlepage-heading-title_de"/></a></li></xsl:if>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'imprint']"><li class="toc-preface"><a href="#imprint"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $imprint-heading-title_en else $imprint-heading-title_de"/></a></li></xsl:if>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'toc']"><li class="toc-preface"><a href="#tei2html_rendered_toc"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $toc-heading-title_en else $toc-heading-title_de"/></a></li></xsl:if>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'lot']"><li class="toc-preface"><a href="#lot"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $lot-heading-title_en else $lot-heading-title_de"/></a></li></xsl:if>
      <xsl:if test="/*:html/*:body/*[@epub:type = 'loi']"><li class="toc-preface"><a href="#loi"><xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $loi-heading-title_en else $loi-heading-title_de"/></a></li></xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>-->

  <!-- Footnotes -->
  <xsl:template match="*:div[@class = 'notes']">
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
   <!-- <xsl:element name="{concat('h', $footnote-heading-level)}">
      <xsl:attribute name="id" select="'footnotes'"/>
      <xsl:attribute name="title" select="if ($_work-lang[starts-with(., 'en')]) then $footnote-heading-title_en else $footnote-heading-title_de"/>
    </xsl:element>-->
    <!-- https://redmine.le-tex.de/issues/8785 render level dynamically in tei2html -->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="backmatter">
    <xsl:param name="_content"/>
    <xsl:if test="$htmlinput//@epub:type = ('footnote', 'rearnote')">
    <!--  <div class="back">
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      </div> -->
      <xsl:apply-templates select="$htmlinput//*[@epub:type = ('footnote', 'rearnote')]"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*:div[@epub:type = 'lot']/*:h2" priority="2">
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <xsl:element name="h3">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="id" select="'lot'"/>
      <xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $lot-heading-title_en else $lot-heading-title_de"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:div[@epub:type = 'loi']/*:h2" priority="2">
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <xsl:element name="h3">
      <xsl:apply-templates select="@*" mode="#current"/>
       <xsl:attribute name="id" select="'loi'"/>      
      <xsl:value-of select="if ($_work-lang[starts-with(., 'en')]) then $loi-heading-title_en else $loi-heading-title_de"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
  <xsl:template match="html:p[matches(@class, 'toc')]" mode="discard-toc"/>
  <xsl:template match="*:nav" mode="discard-toc"/>
  
  <xsl:template name="_heading">
    <xsl:param name="content" as="node()*"/>
    <xsl:param name="class" as="xs:string?"/>
    <xsl:param name="prelim" as="xs:boolean"/>
    <xsl:apply-templates select="$content[matches(*[1]/local-name(), '^h\d')] except @class">
      <xsl:with-param name="class"
                      select="string-join(($class, 
                                           if ($prelim) then 'prelim' else '', 
                                           if ($content/@class) then $content/@class else ''), 
                                          ' ')"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="info_body | impress">
    <xsl:choose>
      <xsl:when test="*:p">
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="noindent">
          <xsl:apply-templates mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="tr:index-of" as="xs:integer*">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="node" as="node()?"/>
    <xsl:sequence select="index-of(for $n in $nodes return generate-id($n), generate-id($node))"/>
  </xsl:function>

  <xsl:template match="*:br/@clear" mode="#all"/>

  <xsl:template match="@* | *">
    <xsl:param name="class" as="xs:string?"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$class">
        <xsl:attribute name="class" select="string-join((@class, $class), ' ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*" mode="extract-percentage">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="node()" mode="extract-percentage">
    <xsl:param name="split-para" as="element(*)?" tunnel="yes"/>
    <xsl:if test="not($split-para) or . &lt;&lt; $split-para">
      <!-- empty elements are invalid sometimes-->
      <xsl:if test="not(tr:is-split-para-first-descendant(., $split-para))">
        <xsl:copy>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
      </xsl:if>
    </xsl:if>
  </xsl:template>
	
  <xsl:function name="tr:is-split-para-first-descendant" as="xs:boolean">
    <xsl:param name="elt" as="node()?"/>
    <xsl:param name="split-para" as="element(*)?"/>
    <xsl:variable name="first-node" select="$elt/node()[1]"/>
    <xsl:choose>
      <xsl:when test="$first-node is $split-para">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$first-node &lt;&lt; $split-para">
        <xsl:sequence select="tr:is-split-para-first-descendant($first-node, $split-para)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="html:head" mode="extract-percentage">
    <xsl:param name="percentage" as="xs:double" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <meta name="sample-percentage" content="{$percentage}"/>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="tr:auto-extract-length" as="xs:double">
    <xsl:param name="text-length" as="xs:integer"/>
    <xsl:variable name="offset" select="$text-length + 1e5" as="xs:double"/>
    <xsl:variable name="factor" select="4e-6 * $offset" as="xs:double"/>
    <xsl:variable name="exp" select="$factor * $factor * $factor * $factor" as="xs:double"/>
    <xsl:variable name="result" select="5 + 20 div (1 + $exp)" as="xs:double"/>
    <xsl:sequence select="$result" />
  </xsl:function>
  

  <xsl:template match="html:body" mode="extract-percentage">
    <xsl:param name="percentage" as="xs:double" tunnel="yes"/>
    <xsl:variable name="cutoff-length" as="xs:double" select="0.01 * $percentage * string-length(.)"/>
    <xsl:variable name="split-para" select="(.//html:p[tr:start-pos(., current()) le $cutoff-length])[last()]" as="element(html:p)?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*" mode="#current">
        <xsl:with-param name="split-para" select="$split-para" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tr:start-pos" as="xs:double">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:param name="ancestor" as="element(*)"/>
    <xsl:sequence select="sum(for $t in $ancestor//text()[. &lt;&lt; $elt] return string-length($t))"/>
  </xsl:function>
  
</xsl:stylesheet>
