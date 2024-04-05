<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:calstable="http://docs.oasis-open.org/ns/oasis-exchange/table" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:functx="http://www.functx.com"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xhtml"
  version="2.0">
  
  <!-- helper transformations that are used for rendering purposes
       and not affect the xml output -->
  
  <xsl:import href="../../common/xml2tex/helpers.xsl"/>
   <!-- overridden to include client specific table split variables -->
  
  <xsl:import href="../xsl/shared-variables.xsl"/>

  

</xsl:stylesheet>