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
  
  <xsl:template match="abstract" mode="tei2html"/>
  
</xsl:stylesheet>