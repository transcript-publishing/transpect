<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:ts="http://www.transcript-verlag.de/transpect"
  xmlns:idml2xml="http://transpect.io/idml2xml"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk ts idml2xml" 
  xmlns:tr="http://transpect.io"
  version="2.0">
  
  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-idml.xsl"/>  
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbncheck.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbnformat.xsl"/>

 <xsl:template match="para[@role = 'Fuzeile'] | *[not(self::css:rule)]/@idml2xml:layer" mode="hub:split-at-tab"/>
 <xsl:param name="hub:handle-several-images-per-caption" as="xs:boolean" select="true()"/>

</xsl:stylesheet>