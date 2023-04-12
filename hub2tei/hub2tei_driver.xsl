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
  
  <xsl:template match="programlisting" mode="hub2tei:dbk2tei">
    <p rend="{@role}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="programlisting/line" mode="hub2tei:dbk2tei">
    <hi>
      <xsl:apply-templates mode="#current"/>
    </hi>
  </xsl:template>
  
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
                                 info/copyright, info/pubdate" mode="meta"/>
    <!--<distributor>
      <address>
        <addrLine>
          <name type="organisation"/>
        </addrLine>
        <addrLine>
          <name type="place"/>
        </addrLine>
      </address>
    </distributor>
    <idno type="book"/>
    <date>
      <xsl:apply-templates select="/*/dbk:info/dbk:date" mode="#current"/>  
    </date>
    <pubPlace/>
    <publisher/>-->
  </xsl:template> 


  <xsl:template match="@*" mode="style-rend"/>

  <xsl:template match="@css:font-style[. = ('italic', 'oblique')]" mode="style-rend" priority="2">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'italic'"/>
  </xsl:template>

  <xsl:template match="@css:font-weight[. = ('bold', 'black', '900', '800', '700', '600', '500', '400')]"  mode="style-rend"  priority="2">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <xsl:attribute name="rend" select="'bold'"/>
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

  <xsl:template match="tei:hi[@rend = ('superscript', 'subscript')] | 
                       tei:seg[matches(@rend, 'fett|hervorgehoben|bold|italic')] | 
                       tei:seg[@*[name() = ('css:font-weight', 'css:font-style', 'css:text-decoration')]]" mode="hub2tei:tidy">
    <!--https://github.com/transcript-publishing/6246/issues/21, https://github.com/transcript-publishing/mapping-conventions/blob/main/italic/index.md -->
    <xsl:variable name="classes" as="xs:string*">
      <xsl:apply-templates select="@*" mode="style-rend"/>
    </xsl:variable>
    <xsl:variable name="rend" as="xs:string?" select="if (@rend) then replace(replace(@rend, 'fett|tsbold', 'bold', 'i'), 'hervorgehoben|tsitalic', 'italic', 'i') else ()"/>
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

  <xsl:template match="dbk:para[not(normalize-space())][not(.//*[self::dbk:inlinemediaobject|dbk:mediaobject])][not(.//dbk:anchor)]" mode="hub2tei:dbk2tei" priority="2">
    <!-- discard pagebreaks/empty paras, https://redmine.le-tex.de/issues/14550-->
  </xsl:template>

</xsl:stylesheet>
