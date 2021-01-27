<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei2html="http://transpect.io/tei2html"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://this.transpect.io/a9s/common/xsl/shared-variables.xsl"/>

  <xsl:variable name="tei2html:epub-type" as="xs:string" select="'3'"/>
  <xsl:variable name="tei2html:chapterwise-footnote" select="true()" as="xs:boolean"/>


</xsl:stylesheet>