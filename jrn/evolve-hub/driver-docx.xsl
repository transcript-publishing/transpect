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
  exclude-result-prefixes="xs hub dbk ts xlink functx" 
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


 <!-- group meta infos for same structure as in IDML-->
 <xsl:template match="*[*[starts-with(@role, 'tsmeta') and @role != 'tsmetakeywords']]" mode="hub:meta-infos-to-sidebar">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-adjacent="exists(self::para[starts-with(@role, 'tsmeta') and @role != 'tsmetakeywords'])">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <sidebar role="article-metadata">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </sidebar>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

 <!-- pull meta infos after headings -->
  <xsl:template match="para[matches(@role, '^(tsheading|toctitle)')][preceding-sibling::*[1][@role = 'article-metadata']]" mode="hub:reorder-marginal-notes">
    <xsl:next-match/>
    <xsl:apply-templates select="preceding-sibling::*[1][@role = 'article-metadata']" mode="#current">
      <xsl:with-param name="process-meta-section" tunnel="yes" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'article-metadata']" mode="hub:reorder-marginal-notes">
    <xsl:param name="process-meta-section" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="$process-meta-section">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

 <!-- meta infos to biblioset -->
  <xsl:template match="sidebar[@role = 'article-metadata']" mode="hub:process-meta-sidebar">
    <biblioset role="article-metadata">
      <xsl:apply-templates select="*" mode="#current"/>
    </biblioset>
  </xsl:template>

 <!-- sort metadata in chapter  -->
  <xsl:template match="*[sidebar[@role = 'article-metadata']]" mode="hub:process-meta-sidebar" priority="5">
    <xsl:copy>
      <xsl:apply-templates select="@*, (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]])" mode="#current"/>
      <xsl:apply-templates select="sidebar[@role = 'article-metadata']" mode="#current"/>
      <xsl:apply-templates select="node() except (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]] | sidebar[@role = 'article-metadata'])" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[@role = ('tsmetadoi', 'tsmetachunkdoi')]" mode="hub:process-meta-sidebar">
    <biblioid otherclass="{if(@role eq 'tsmetadoi') then 'journal-doi' else 'article-doi'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="para[@role eq 'tsmetacontributionorcid']" mode="hub:process-meta-sidebar">
    <uri otherclass="orcid">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </uri>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournaltitle']" mode="hub:process-meta-sidebar">
    <productname otherclass="journal-title">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </productname>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionlicence']" mode="hub:process-meta-sidebar">
    <legalnotice otherclass="{if(matches(., '&#xa9;')) then 'copyright' else 'license'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:copy>
        <xsl:value-of select="normalize-space(.)"/>        
      </xsl:copy>
    </legalnotice>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournalyear']" mode="hub:process-meta-sidebar">
    <date otherclass="journal-year">
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
  
  <xsl:template match="para[@role = 'tsmetacontributionauthoraffiliation']" mode="hub:process-meta-sidebar">
    <orgname otherclass="affiliation">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </orgname>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetacontributionauthorcontact']" mode="hub:process-meta-sidebar">
    <email>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </email>
  </xsl:template>

  <xsl:template match="section[@role = 'abstract']" mode="hub:process-meta-sidebar">
    <abstract>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(title)">
        <xsl:apply-templates select="para[matches(@role, '[a-z]{1,3}abstract')][1]/node()[1][self::phrase]" mode="#current">
          <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="false()"/>
      </xsl:apply-templates>
    </abstract>
  </xsl:template>

  <xsl:template match="section[@role = ('abstract', 'keywords')][not(title)]/para[matches(@role, '[a-z]{1,3}(abstract|metakeywords)')][1]/node()[1][self::phrase]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="phrase-to-title" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$phrase-to-title" >
      <title>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:value-of select="normalize-space(replace(., ':\p{Zs}?$', ''))"/>
      </title>
    </xsl:if>
  </xsl:template>

  <xsl:template match="section[@role = ('abstract', 'keywords')][not(title)]/para[matches(@role, '[a-z]{1,3}(abstract|metakeywords)')][1][node()[1][self::phrase]]/node()[2][self::text()]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:value-of select="replace(., '^[\p{Zs}]+', '')"/>
  </xsl:template>

  <xsl:template match="para[@role[matches(., '[a-z]{1,3}metacontributionyear')]]" mode="hub:process-meta-sidebar">
    <pubdate>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </pubdate>
  </xsl:template>

  <xsl:template match="section[@role = 'keywords']" mode="hub:process-meta-sidebar">
      <keywordset role="{if (title) 
                        then normalize-space(title) 
                        else replace(descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)][1], '^(Schlüssel(wörter|begriffe)|Key\s?words|Mots[-]clés):.+$', '$1')}">
        <xsl:apply-templates select="descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)]" mode="#current">
          <xsl:with-param name="process-meta" tunnel="yes" as="xs:boolean?" select="true()"/>
        </xsl:apply-templates>
      </keywordset>
      <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(title)">
        <xsl:apply-templates select="para[matches(@role, '[a-z]{1,3}metakeywords')][1]/node()[1][self::phrase]" mode="#current">
          <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="false()"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="biblioset//@role" mode="hub:twipsify-lengths hub:expand-css-properties" priority="3">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'article-metadata']/para[not(node())]" mode="hub:process-meta-sidebar" priority="3"/>

  <xsl:template match="para[matches(@role, $hub:article-keywords-role-regex)]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="process-meta" tunnel="yes" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$process-meta">
        <xsl:variable name="lang" select="key('natives', @role)" as="element(css:rule)?"/>
        <xsl:variable name="text" select="string-join(descendant::text(), '')" as="xs:string?"/>
        <xsl:variable name="without-heading" select="replace($text, '^(Schlüssel(wörter|begriffe)|Key\s?words|Mots[ -]clés):[\p{Zs}*]?', '', 'i')" as="xs:string?"/>
        <xsl:variable name="single-keywords" select="tokenize($without-heading, '[,]')" as="xs:string*"/>
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

  <xsl:template match="*[para[matches(@role, '[a-z]{1,3}(abstract|metakeywords)')]]" mode="hub:repair-hierarchy" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="exists(.[self::para][@role[matches(., '[a-z]{1,3}(abstract(keywordsheading)?|metakeywords)')]])">
        <xsl:variable name="all-abstract-and-keyword-para" as="element(*)*" select="current-group()"/>
        <xsl:for-each-group select="current-group()" group-starting-with="para[@role[matches(., '[a-z]{1,3}abstractkeywordsheading')] 
                                                                            or 
                                                                            (@role[matches(., '[a-z]{1,3}(abstracts|metakeywords)$')] 
                                                                              and not($all-abstract-and-keyword-para[@role[matches(., '[a-z]{1,3}abstractkeywordsheading')]]) 
                                                                              and (. is $all-abstract-and-keyword-para[@role = current()/@role][1])
                                                                            )]">
          <xsl:choose>
            <xsl:when test="current-group()[self::para[@role[matches(., '[a-z]{1,3}metakeywords')]]]">
              <section role="keywords">
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </section>
            </xsl:when>
            <xsl:when test="current-group()[self::para[@role[matches(., '[a-z]{1,3}abstracts$')]]]">
              <section role="abstract">
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </section>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para[matches(@role, '[a-z]{1,3}abstractkeywordsheading')]" mode="hub:repair-hierarchy" priority="2">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="/hub/info" mode="custom-2" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      
      <xsl:if test="/hub/part[1]/info/title">
        <xsl:element name="title"><xsl:value-of select="normalize-space(/hub/part[1]/info/title[1])"/>
        </xsl:element>
      </xsl:if>
      <xsl:for-each select="/hub/descendant::biblioset[1]/(issuenum | volumenum | biblioid[@role = 'tsmetadoi'] | productname | pubdate)">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="current()/@* except @srcpath" mode="#current"/>
          <xsl:value-of select="normalize-space(current())"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="info/author" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <affiliation>
        <xsl:copy-of select="parent::info/biblioset/orgname"/>
      </affiliation>
      <xsl:copy-of select="parent::info/biblioset/email,
                           parent::info/biblioset/uri"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="info/biblioset/email
                      |info/biblioset/orgname
                      |info/biblioset/uri" mode="custom-2"/>

<!-- TO DO: license → licence-->

  <xsl:template match="hub/section[matches(@role, $hub:toc-heading)]" 
                mode="hub:postprocess-hierarchy">
    <toc xml:id="toc">
      <xsl:apply-templates select="@*, title, sidebar[@role = 'article-metadata']" mode="#current"/>
    </toc>
  </xsl:template>

</xsl:stylesheet>