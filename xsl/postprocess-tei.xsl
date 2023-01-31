<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:key name="elt-by-corresp" match="*[@corresp]" use="@corresp"/>  

  <xsl:template match="@*|node()|processing-instruction()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="TEI">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/></xsl:copy>
  </xsl:template>

  <xsl:variable name="meta" select="/TEI/teiHeader/profileDesc/textClass/keywords[@rendition='titlepage']"/>
  
  <xsl:template match="/*/@xml:base | /*/@source-dir-uri  | @rend">
    <!--https://github.com/transcript-publishing/6246/issues/5-->
    <!--https://github.com/transcript-publishing/6246/issues/6-->
    <!--https://github.com/transcript-publishing/6246/issues/11-->
  </xsl:template>

  <xsl:template match="encodingDesc | divGen[@type = 'toc']">
    <!--https://github.com/transcript-publishing/6246/issues/3-->
    <!--https://github.com/transcript-publishing/6246/issues/9-->
  </xsl:template>

  <xsl:template match="textClass">
    <!--https://github.com/transcript-publishing/6246/issues/8-->
    <xsl:if test="$meta/term[@key = 'Schlagworte'][normalize-space()]">
      <xsl:copy copy-namespaces="no">
        <keywords>
          <xsl:for-each select="tokenize($meta/term[@key = 'Schlagworte'], ';')">
            <term>
              <xsl:value-of select="."/>
            </term>
          </xsl:for-each>
        </keywords>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@css:*">
    <!--https://github.com/transcript-publishing/6246/issues/10-->
  </xsl:template>

  <xsl:template match="seg[@css:font-style = ('italic', 'oblique')]">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <hi rend='italic'>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
    <!-- TODO Auch, wenn in ZF!-->
  </xsl:template>

  <xsl:template match="seg[@css:font-weight = ('bold', '900', '800', '700', '600', '500', '400')] | seg[matches(@rend, 'fett|hervorgehoben')]">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <hi rend='bold'>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
    <!-- TODO Auch, wenn in ZF!-->
  </xsl:template>


  <xsl:template match="seg[@css:text-decorationt = ('underline')]">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <hi rend='underline'>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
    <!-- TODO Auch, wenn in ZF -->
  </xsl:template>

  <xsl:template match="seg[@css:text-decorationt = ('strike-through')]">
    <!--https://github.com/transcript-publishing/6246/issues/21-->
    <hi rend='strike-through'>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
    <!-- TODO Auch, wenn in ZF? -->
  </xsl:template>



  <xsl:template match="*[key('elt-by-corresp', concat('#', @xml:id))
                               [self::keywords[@rendition='chunk-meta']/term[@key = 'chunk-doi'][normalize-space()]]
                           ]">
    <!-- add opener for DOI -->
    <xsl:variable name="elt" select="." as="element(*)"/>  
     <xsl:copy copy-namespaces="no">
       <xsl:for-each-group select="node()" 
              group-starting-with="*[preceding-sibling::node()[1][self::head]]
                                    [not(self::head)]">
        <xsl:choose>
          <xsl:when test="current-group()[last()][not(self::head)]">
            <opener>
              <idno type="DOI">
                <xsl:value-of select="key('elt-by-corresp', concat('#', $elt/@xml:id))/term[@key = 'chunk-doi']"/>
              </idno>
            </opener>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
        
      </xsl:for-each-group>
    </xsl:copy>

    <!-- group and put opener with doi after headings and authors -->
    <!--https://github.com/transcript-publishing/6246/issues/20-->
  </xsl:template>

  <xsl:template match="titlePage">
    <!-- TODO map title page elements -->
    <!--https://github.com/transcript-publishing/6246/commit/cbbe8d86f6fc7da4400ecf7dd89688499b420574-->
    <xsl:copy copy-namespaces="no">
      <docTitle>
        <titlePart type="main"><xsl:value-of select="$meta/term[@key = 'Titel']"/></titlePart>
        <xsl:if test="$meta/term[@key = 'Untertitel'][normalize-space()]">
          <titlePart type="sub"><xsl:value-of select="$meta/term[@key = 'Untertitel']"/></titlePart>
        </xsl:if>
        <xsl:if test="$meta/term[@key = 'Cover'][normalize-space()]">
          <figure>
              <!-- reference Cover as jpg on titlePage -->
              <!-- https://github.com/transcript-publishing/6246/issues/18-->
            <graphic url="{replace($meta/term[@key = 'Cover'], '\.eps', '.jpg', 'i')}"/>
          </figure>
        </xsl:if>
      </docTitle>
      <docImprint/>
    </xsl:copy>
    <div type="dedication">            
      <xsl:for-each select="$meta/term[@key = 'Widmung'][normalize-space()]/node()">
        <p><xsl:value-of select="."/></p>
      </xsl:for-each>
    </div>
  </xsl:template>


  <xsl:template match="titleStmt">
    <!-- https://github.com/transcript-publishing/6246/issues/19, 
         https://github.com/transcript-publishing/6246/commit/7cddc715d61b2d12493088067908ada4d0d4a755-->

    <!-- Title -->
    <xsl:copy copy-namespaces="no">
      <title type="full">
        <title type="main">
          <xsl:value-of select="$meta/term[@key = 'Titel']"/>
        </title>
        <xsl:if test="$meta/term[@key = 'Untertitel'][normalize-space()]">
          <title type="sub"><xsl:value-of select="$meta/term[@key = 'Untertitel']"/></title>
        </xsl:if>
      </title>
    <editor role="proofreading"><xsl:value-of select="$meta/term[@key = 'Korrektorat']"/></editor>
    <editor role="cover design"><xsl:value-of select="replace($meta/term[@key = 'Umschlaggestaltung'], '^.+:\p{Zs}*', '')"/></editor>

   <!-- contributors -->
    <xsl:if test="$meta/term[@key = 'Herausgeber'][normalize-space()]">
      <editor><xsl:value-of select="$meta/term[@key = 'Herausgeber']"/></editor>
    </xsl:if>
    <xsl:if test="$meta/term[@key = 'Autor'][normalize-space()]">
      <author><xsl:value-of select="$meta/term[@key = 'Autor']"/></author>
    </xsl:if>

   <!-- funding -->
      <xsl:for-each select="$meta/term[@key = 'Fordertext'][normalize-space()]/node()[normalize-space()]">
        <funder><xsl:value-of select="."/></funder>
      </xsl:for-each>

    </xsl:copy>
  </xsl:template>

  <xsl:template match="publicationStmt">
    <!-- https://github.com/transcript-publishing/6246/issues/19, 
         https://github.com/transcript-publishing/6246/commit/7cddc715d61b2d12493088067908ada4d0d4a755-->

    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="publisher, pubPlace" mode="#current"/>

        <xsl:if test="$meta/term[@key = ('Lizenz', 'Copyright')][normalize-space()]">
          <availability>
            <xsl:if test="$meta/term[@key = 'Lizenz'][contains(., 'BY')]">
              <xsl:attribute name="status" select="'free'"/>
            </xsl:if>
            <xsl:for-each select="$meta/term[@key = 'Copyright'][normalize-space()]/node()">
              <p><xsl:value-of select="."/></p>
            </xsl:for-each>
            <xsl:if test="some $m in $meta/term[@key = ('Lizenzlink', 'Lizenztext')] satisfies $m[normalize-space()]">
              <p>        
                <xsl:if test="$meta/term[@key = 'Lizenzlink'][normalize-space()]">
                  <ref n="license" target="{normalize-space($meta/term[@key = 'Lizenzlink'])}">
                    <xsl:if test="$meta/term[@key = 'Lizenzlogo'][normalize-space()]">
                      <figure rend="border-width:0;">
                        <figDesc>Creative Commons License</figDesc>
                        <graphic url="{concat('https://licensebuttons.net/l/', replace($meta/term[@key = 'Lizenzlogo'], '\.\p{L}+$', ''), '/4.0/80x15.png')}" />
                      </figure>
                    </xsl:if>
                  </ref>
                </xsl:if>
                <xsl:for-each select="$meta/term[@key = 'Lizenztext'][normalize-space()]/node()">
                  <lb/><xsl:value-of select="."/>
                </xsl:for-each>
              </p>
            </xsl:if>
          </availability>
        </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="seriesStmt">
    <!--https://github.com/transcript-publishing/6246/commit/6b53c4f0a8de375d57a232f693d838bd7b23b10f-->
    <xsl:copy copy-namespaces="no">
      <xsl:if test="$meta/term[@key = 'Reihe'][normalize-space()]">
        <title type="main"><xsl:value-of select="$meta/term[@key = 'Reihe']"/></title>
      </xsl:if>
      <xsl:if test="$meta/term[@key = 'Bandnummer'][normalize-space()]">
        <biblScope unit="volume"><xsl:value-of select="replace($meta/term[@key = 'Bandnummer'], '^[^\d]+\s', '')"/></biblScope>
      </xsl:if>
      <xsl:if test="$meta/term[@key = 'BiblISSN'][normalize-space()]">
        <idno type="ISSN"><xsl:value-of select="replace($meta/term[@key = 'BiblISSN'], '^.+:\s*', '')"/></idno>
      </xsl:if>
      <xsl:apply-templates select="idno" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="idno/@type">
    <xsl:attribute name="{name()}" select="upper-case(.)"></xsl:attribute>
  </xsl:template>

  <xsl:template match="graphic/@url">
    <xsl:attribute name="{name()}" select="replace(., '^.+/', 'images/')"></xsl:attribute>
  </xsl:template>


</xsl:stylesheet>