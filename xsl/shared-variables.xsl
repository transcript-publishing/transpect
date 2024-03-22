<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:hub="http://transpect.io/hub"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://this.transpect.io/a9s/common/xsl/shared-variables.xsl"/>

  <xsl:variable name="tei2html:epub-type" as="xs:string" select="'3'"/>
  <xsl:variable name="tei2html:chapterwise-footnote" select="true()" as="xs:boolean"/>
  <xsl:variable name="tei2html:generate-ol-type" select="true()" as="xs:boolean"/>
  <xsl:variable name="hub:figure-caption-start-regex" as="xs:string" 
                select="if (exists(//*:figure/*:title[matches(normalize-space(.), '^(Bild|Abbildung|Abbildungen|Abb\.|Figures?|Figs?\.?)')])) 
                        then 'Bild|Abbildung|Abbildungen|Abb\.|Figures?|Figs?\.?' 
                        else '[^\p{Zs}]+'"/>

  <!-- the code below was commented since the heading2 with keyword is not used anymore -->

  <!--<xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+" 
                select="('^(berschrift1|[Hh]eading\s?1|[a-z]{1,3}headingpart|[a-z]{1,3}indexheading)',
                         '^(berschrift2|[Hh]eading\s?2|[a-z]{1,3}heading1|[a-z]{1,3}journalreviewheading|[a-z]{1,3}headingenumerated1|[a-z]{1,3}listoffigures|toctitle)$',
                         '^(berschrift3|[Hh]eading\s?3|[a-z]{1,3}heading2(keywords|orientation|exercise|summary|leadingquestions|learningoutcome|literature)?|[a-z]{1,3}headingenumerated2)$',
                         '^(berschrift4|[Hh]eading\s?4|[a-z]{1,3}heading3|[a-z]{1,3}headingenumerated3)$',
                         '^(berschrift5|[Hh]eading\s?5|[a-z]{1,3}heading4|[a-z]{1,3}headingenumerated4)$',
                         '^(berschrift6|[Hh]eading\s?6|[a-z]{1,3}heading5|[a-z]{1,3}headingenumerated5)$',
                         '^(berschrift7|[Hh]eading\s?7|[a-z]{1,3}heading6|[a-z]{1,3}headingenumerated6)$',
                         '^(berschrift8|[Hh]eading\s?8|[a-z]{1,3}heading7|[a-z]{1,3}headingenumerated7)$',
                         '^(berschrift9|[Hh]eading\s?9|[a-z]{1,3}heading8|[a-z]{1,3}headingenumerated8)$')"/>-->
  
  <xsl:variable name="split-landscape-table-with-dotablebreak-pi" select="false()" as="xs:boolean">
    <!-- As long as tables with PI orientation=landscape cannot be split automatically via the framework, they may be split via converter. 
        how the splitting is done exactly, should in most cases be adapted in customer code to make sure that the position of titles, sources etc. is according to styles 
        https://redmine.le-tex.de/issues/15409-->
  </xsl:variable>
  
  <xsl:variable name="xml2tex:split-landscape-tables" as="xs:boolean" select="$split-landscape-table-with-dotablebreak-pi"/>

  <xsl:variable name="info-meta-styles" as="xs:string"
                select="'^tsmeta'" ><!-- all meta style names, if they do not all begin with meta in your a9s, 
      concat the important ones (info-licence-style, info-doi, etc.)--></xsl:variable>
  
  <xsl:variable name="info-author-role" as="xs:string"
                select="'^tsmetacontributionauthorname$'"/>
  
  <xsl:variable name="info-author-affiliation-role" as="xs:string"
                select="'^tsmetacontributionauthoraffiliation$'"/>
  
  <xsl:variable name="info-author-email-role" as="xs:string"
                select="'^tsmetacontributionauthorcontact$'" />

  <xsl:variable name="info-doi" as="xs:string"
                select="'[a-z]{1,3}meta(chunk)?doi$'" />
  
  <xsl:variable name="info-keywords-role" as="xs:string"
                select="'^tskeywords?$'"/>

  <xsl:variable name="pi-style-regex" as="xs:string" 
                select="'^[a-z]{1,3}pi(Zchn)?$'"/>

 <xsl:variable name="hub:preserve-abstract-as-text" as="xs:boolean" select="true()">
    <!-- if set to true() abstract, keywords and alternatve-title section are preserved additionally to meta tags in info-->
  </xsl:variable>

  <xsl:variable name="css:italic-elt-name" as="xs:string?" select="'em'"/>
  <xsl:variable name="css:bold-elt-name" as="xs:string?" select="'strong'"/>
</xsl:stylesheet>