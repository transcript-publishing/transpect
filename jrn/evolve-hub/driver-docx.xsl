<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:ts="http://www.transcript-verlag.de/transpect"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk ts" 
  version="2.0">
  
  <xsl:import href="../../evolve-hub/driver-docx.xsl"/>  
    
 <xsl:template match="/" mode="custom-2">
    <xsl:variable name="out-dir" as="element(keyword)"
                  select="hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'archive-dir-uri']"/>
    <xsl:variable name="basename" as="element(keyword)" 
                  select="hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-basename']"/>
    <xsl:copy>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'article-metadata']" mode="hub:process-meta-sidebar">
    <biblioset role="article-metadata">
      <xsl:apply-templates select="*" mode="#current"/>
    </biblioset>
  </xsl:template>

  <xsl:template match="*[sidebar[@role = 'article-metadata']]" mode="hub:process-meta-sidebar" priority="5">
    <xsl:copy>
      <xsl:apply-templates select="@*, (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]])" mode="#current"/>
      <xsl:apply-templates select="sidebar[@role = 'article-metadata']" mode="#current"/>
      <xsl:call-template name="hub:abstract"/>
      <xsl:call-template name="hub:keywords">
        <xsl:with-param name="process-meta" select="true()" as="xs:boolean" tunnel="yes"/>
      </xsl:call-template>
      <xsl:apply-templates select="node() except (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]] | sidebar[@role = 'article-metadata'])" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetadoi']" mode="hub:process-meta-sidebar">
    <biblioid class="doi" otherclass="journal">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournaltitle']" mode="hub:process-meta-sidebar">
    <productname>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </productname>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournalyear']" mode="hub:process-meta-sidebar">
    <date>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </date>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournalissue']" mode="hub:process-meta-sidebar">
    <issuenum>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </issuenum>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetachunkdoi']" mode="hub:process-meta-sidebar">
    <biblioid class="doi" otherclass="article">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionauthoraffiliation']" mode="hub:process-meta-sidebar">
    <orgname>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/></orgname>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionauthorcontact']" mode="hub:process-meta-sidebar">
    <address>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </address>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionorcid']" mode="hub:process-meta-sidebar">
    <biblioid class="doi" otherclass="orcid">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionlicense']" mode="hub:process-meta-sidebar">
    <legalnotice>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </legalnotice>
  </xsl:template>


  <xsl:template match="section[@role = 'tsabstractkeywordsheading'][title[matches(., 'Abstract')]]" mode="hub:process-meta-sidebar">
    <xsl:param name="process-meta" tunnel="yes" as="xs:boolean?"/>
    
    <xsl:choose>
      <xsl:when test="$process-meta">
        <abstract>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </abstract>
      </xsl:when>
      <xsl:otherwise>
        <section role="abstract">
          <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
        </section>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="section[@role = 'tsabstractkeywordsheading'][title[matches(., 'Keywords')]]/@role" mode="hub:process-meta-sidebar">
    <xsl:attribute name="role" select="'keywords'"/>
  </xsl:template>

  <xsl:template match="para[@role = 'tsmetacontributionyear']" mode="hub:process-meta-sidebar">
    <pubdate>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </pubdate>
  </xsl:template>

  <xsl:template name="hub:abstract">
    <xsl:apply-templates select="section[@role = 'tsabstractkeywordsheading'][title[matches(., 'Abstract')]]" mode="#current">
      <xsl:with-param name="process-meta" tunnel="yes" as="xs:boolean?" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="hub:keywords">
    <xsl:if test="descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)]">
      <keywordset>
        <xsl:apply-templates select="descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)]" mode="#current">
          <xsl:with-param name="process-meta" tunnel="yes" as="xs:boolean?" select="true()"/>
        </xsl:apply-templates>
      </keywordset>
    </xsl:if>
  </xsl:template>

  <xsl:template match="biblioset//@role" mode="hub:twipsify-lengths hub:expand-css-properties" priority="3">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'article-metadata']/para[not(node())]" mode="hub:process-meta-sidebar"/>

  <xsl:template match="para[matches(@role, $hub:article-keywords-role-regex)]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="process-meta" tunnel="yes" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$process-meta">
        <xsl:variable name="lang" select="key('natives', @role)" as="element(css:rule)?"/>
        <xsl:variable name="text" select="string-join(descendant::text(), '')" as="xs:string?"/>
        <xsl:variable name="single-keywords" select="tokenize($text, '[,]')" as="xs:string*"/>
        <xsl:for-each select="$single-keywords">
          <xsl:element name="keyword">
            <xsl:if test="$lang[@xml:lang]">
              <xsl:attribute name="xml:lang" select="$lang/@xml:lang"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>