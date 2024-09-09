<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.w3.org/1996/css"
                xmlns:dbk="http://docbook.org/ns/docbook"
                xmlns:hub="http://transpect.io/hub"
                xmlns:hub2tei="http://transpect.io/hub2tei"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:docx2hub="http://transpect.io/docx2hub"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:tr="http://transpect.io"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="dbk docx2hub html hub2tei hub xlink css xs cx tr tei"
                version="2.0" 
                xpath-default-namespace="http://docbook.org/ns/docbook">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="http://this.transpect.io/a9s/common/hub2tei/hub2tei_driver.xsl"/>

  <xsl:param name="repo-href-canonical"/>
  
  <xsl:function name="hub2tei:image-path"  as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="root" as="document-node()?"/>

    <!--<xsl:variable name="source-type" as="xs:string?" 
      select="$root/*[self::book or self::hub]/info/keywordset/keyword[@role eq 'source-type']"/>-->
    <xsl:choose>
      <xsl:when test="matches($path, '^https?:')">
        <xsl:sequence select="$path"/>
      </xsl:when>
      <xsl:when test="matches($path, '(/(idml|word)/(images|media)/|/out/images/|\.docx/out)')">
        <xsl:sequence select="$path"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="image-content-repo-path" 
          select="replace($repo-href-canonical, '^(.+/\d{5}/).+$', '$1images/')" as="xs:string"/>
        <xsl:variable name="image-basename" 
          select="replace($path, '^.+/', '')" as="xs:string"/>
        <xsl:variable name="image-path" 
          select="string-join(($image-content-repo-path, $image-basename), '')" as="xs:string"/>
        <xsl:sequence select="if (not(matches($image-path, '_png\.'))) 
             then replace($image-path, '\.(tiff?|eps|ai|pdf)$', '.jpg', 'i') 
             else replace($image-path, '_png\.(tiff?|eps|ai|pdf)$', '.png', 'i')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <xsl:template name="publication-stm">
    <xsl:if test="not(info/publisher)">
      <publisher>transcript</publisher>
      <pubPlace>Bielefeld</pubPlace>
    </xsl:if>
    <xsl:apply-templates select="info/publisher,
                                 info/legalnotice,
                                 info/copyright, (info/pubdate | /hub/info/keywordset[@role = 'titlepage']/keyword[@role='Copyright'][normalize-space()])" mode="meta"/>
  </xsl:template> 

  <xsl:template match="/hub/info/keywordset[@role = 'titlepage']/keyword[@role='Copyright']" mode="meta">
    <!-- https://redmine.le-tex.de/issues/15141-->
    <date>
      <xsl:value-of select="replace(node()[normalize-space()][matches(., '(19|20)\d{2}')][1], '^.+((19|20)\d{2}).+$', '$1')"/>  
    </date>
  </xsl:template>

  <xsl:template match="@*" mode="style-rend"/>

  <xsl:template match="@css:font-style[. = ('italic', 'oblique')]" mode="style-rend" priority="2">
    <!--https://github.com/transcript-publishing/mapping-conventions/blob/main/italic/index.md, before: https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'em'"/>
  </xsl:template>

  <xsl:template match="@css:font-weight[. = ('bold', 'black', '900', '800', '700', '600', '500', '400')]"  mode="style-rend"  priority="2">
    <!--https://github.com/transcript-publishing/mapping-conventions/blob/main/bold/index.md, before: https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'strong'"/>
  </xsl:template>

  <xsl:template match="@css:text-decorationt[. = ('underline')]"  mode="style-rend"  priority="2">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'underline'"/>
    <!-- TODO Auch, wenn in ZF -->
  </xsl:template>

  <xsl:template match="@css:text-decorationt[. = ('strike-through')]"  mode="style-rend"  priority="2">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'strike-through'"/>
    <!-- TODO Auch, wenn in ZF? -->
  </xsl:template>

  <xsl:template match="phrase[starts-with(@role, 'tsemph')]" mode="hub2tei:dbk2tei" priority="4"> 
    <emph>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </emph>
  </xsl:template>

  <xsl:template match="tei:hi[@rend = ('superscript', 'subscript')] | 
                       tei:seg[matches(@rend, 'fett|hervorgehoben|bold|italic')] | 
                       tei:seg[@*[name() = ('css:font-weight', 'css:font-style', 'css:text-decoration')]]" mode="hub2tei:tidy">
    <!--https://github.com/transcript-publishing/6246/issues/21, https://github.com/transcript-publishing/mapping-conventions/blob/main/italic/index.md -->
    <xsl:variable name="classes" as="xs:string*">
      <xsl:apply-templates select="@*" mode="style-rend"/>
    </xsl:variable>
    <xsl:variable name="rend" as="xs:string?" select="if (@rend) then replace(replace(@rend, 'fett|tsbold', 'strong', 'i'), 'hervorgehoben|tsitalic', 'em', 'i') else ()"/>
    <xsl:choose>
      <xsl:when test="   self::tei:hi 
                      or self::tei:seg[matches(@rend, 'fett|hervorgehoben|bold|italic')]
                      or string-join($classes, '')[normalize-space()]">
        <hi>
          <xsl:attribute name="rend" select="string-join(distinct-values(($rend, $classes)), ' ')"/>
          <xsl:apply-templates select="@* except @rend, node()" mode="#current"/>
        </hi>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dbk:caption/dbk:para[@role =  'tsfiguresource']" mode="hub2tei:dbk2tei" priority="2">
    <bibl type="copyright"><!--https://redmine.le-tex.de/issues/14481-->
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibl>
  </xsl:template>

  <xsl:template match="tei:textClass[tei:keywords[@rendition='titlepage'][tei:term[@key='THEMA'][normalize-space()]]]" mode="hub2tei:tidy" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <!-- https://redmine.le-tex.de/issues/15108 -->
      <xsl:for-each select="tei:keywords[@rendition='titlepage']/tei:term[@key='THEMA'][normalize-space()]/node()">
        <xsl:element name="classCode">
          <xsl:attribute name="scheme" select="'https://ns.editeur.org/thema/en'"/>
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:copy-of select="//*:keywords[not(parent::*[self::*:textClass])]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:textClass/tei:keywords[@rendition='titlepage']/tei:term[@key='THEMA'][normalize-space()]" mode="hub2tei:tidy" priority="2"/>

  <xsl:template match="dbk:para[not(normalize-space())]
                               [not(.//*[self::dbk:inlinemediaobject|self::dbk:mediaobject])][not(.//dbk:anchor)]" mode="hub2tei:dbk2tei" priority="2">
    <!-- discard pagebreaks/empty paras, https://redmine.le-tex.de/issues/14550-->
  </xsl:template>

  <xsl:template match="dbk:para[preceding-sibling::*[1][matches(@role, 'lineskip')]]" mode="cals2html-table" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each select="1 to xs:integer(replace(preceding-sibling::*[1]/@role, 'tslineskip', ''))">
        <xsl:element name="br" namespace="http://docbook.org/ns/docbook">
          <xsl:attribute name="rend" select="'keep'"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:div[tei:div[following-sibling::tei:p]]" mode="hub2tei:tidy">
    <!-- no floating p elements are allowed after divs. therefore group them an surround them by a virtual div, 
      https://redmine.le-tex.de/issues/17198 -->
    <xsl:copy copy-namespaces="no">
     <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-starting-with="node()[not(self::tei:div|self::text()[matches(., '^\p{Zs}+$')])]
                                                                     [preceding-sibling::node()[1][self::tei:div]]">
        <xsl:choose>
          <xsl:when test="current-group()[last()][self::tei:div]">
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:element name="div">
             <xsl:attribute name="type" select="'virtual'"/>
             <xsl:apply-templates select="current-group()" mode="#current"/>
           </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="title-stm">
    <xsl:if test="not(info/title)">
      <title/>
    </xsl:if>
    <xsl:apply-templates select="info/title,
                                 info/subtitle,
                                 info/author, 
                                 info/keywordset[@role='titlepage']/keyword[@role = ('Korrektorat', 'Lektorat', 'Satz', 'Ubersetzer', 'Umschlagcredit')]" mode="meta"/>
  </xsl:template>
  
  <xsl:template name="source-desc">
    <!--  https://redmine.le-tex.de/issues/17362-->
    <xsl:variable name="qualification" select="/hub/info/keywordset[@role='titlepage']/keyword[@role = ('Qualifikationsnachweis')]"/>
    <xsl:variable name="examiner" select="/hub/info/keywordset[@role='titlepage']/keyword[@role = ('Gutachter')]"/>
    <xsl:choose>
      <xsl:when test="$qualification[normalize-space()] or $examiner[normalize-space()]">
        <bibl>
          <xsl:apply-templates select="/hub/info/keywordset[@role='titlepage']/keyword[@role = ('Qualifikationsnachweis', 'Gutachter')]" mode="meta"/>
        </bibl>
      </xsl:when>
      <xsl:otherwise>
        <p/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="/hub/info/keywordset[@role='titlepage']/keyword[@role = ('Qualifikationsnachweis')]" mode="meta">
    <!-- https://redmine.le-tex.de/issues/17426-->
    <title>
      <xsl:value-of select="if (*:para) then string-join(*:para/text(), ' ')  else ."/>
    </title>
  </xsl:template>
  
  <xsl:template match="/hub/info/keywordset[@role='titlepage']/keyword[@role = ('Gutachter', 'Korrektorat', 'Lektorat', 'Satz', 'Ubersetzer', 'Umschlagcredit')]
                                                                       [normalize-space()]" mode="meta">
    <!-- https://redmine.le-tex.de/issues/17426-->
    <xsl:variable name="role">
      <xsl:choose>
        <xsl:when test="@role = 'Gutachter'"><xsl:value-of select="'examiner'"/></xsl:when>
        <xsl:when test="@role = 'Korrektorat'"><xsl:value-of select="'correction'"/></xsl:when>
        <xsl:when test="@role = 'Lektorat'"><xsl:value-of select="'proofreading'"/></xsl:when>
        <xsl:when test="@role = 'Satz'"><xsl:value-of select="'technical editor'"/></xsl:when>
        <xsl:when test="@role = 'Ubersetzer'"><xsl:value-of select="'translator'"/></xsl:when>
        <xsl:when test="@role = 'Umschlagcredit'"><xsl:value-of select="'cover illustration'"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <editor role="{$role}"><xsl:value-of select="if (*:para) then string-join(*:para/text(), ' ')  else ."/></editor>
  </xsl:template>
  
</xsl:stylesheet>
