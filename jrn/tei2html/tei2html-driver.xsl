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
  
  
  <xsl:import href="http://this.transpect.io/a9s/ts/tei2html/tei2html-driver.xsl"/>
  
  <xsl:template match="seriesStmt/biblScope[@unit]" mode="tei2html">
   <meta name="journal-issue" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="seriesStmt/title[@type = 'main']" mode="tei2html" priority="4">
    <meta name="journal-title" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="publicationStmt/date" mode="tei2html">
    <meta name="journal-year" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="tei:div[@type= 'article'][count(key('tei:by-corresp', concat('#', @xml:id))) gt 0] | 
                       tei:divGen[@type= 'toc'][count(key('tei:by-corresp', concat('#', @xml:id))) gt 0]" mode="epub-alternatives">
    <xsl:copy copy-namespaces="yes">
      <xsl:apply-templates select="@*" mode="#current"/>
      <header rend="chunk-meta-sec"><xsl:apply-templates select="key('tei:by-corresp', concat('#', @xml:id))" mode="meta"/></header>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*[starts-with(name(), 'css:')]
                         [(../ancestor::*[@*[name() = current()/name()]])[1][not(self::*:table | self::*:td)]
                                                                            [@*[name() = current()/name()][. = current()]]]"
     mode="epub-alternatives">
    <!--  exclude duplicate styles-->
  </xsl:template>


  <xsl:variable name="tei2html:chapterwise-footnote" as="xs:boolean" select="true()"/>

</xsl:stylesheet>