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
  
  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl"/>  
  
  <xsl:template match="/*" mode="custom-2">
    <xsl:variable name="out-dir" as="element(keyword)"
                  select="/hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'archive-dir-uri']"/>
    <xsl:variable name="basename" as="element(keyword)" 
                  select="/hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-basename']"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:result-document href="{concat($out-dir, '/', $basename, '.bib.txt')}" 
                         method="text" media-type="text/plain" encoding="UTF-8">
      <xsl:value-of select="string-join(//bibliomixed, '&#xa;')"/>
    </xsl:result-document>
  </xsl:template>
    
</xsl:stylesheet>