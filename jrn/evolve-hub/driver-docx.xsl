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
    
  <xsl:template match="para[@role = ('tsmetadoi', 'tsmetachunkdoi')]" mode="hub:process-meta-sidebar">
    <biblioid otherclass="{if(@role eq 'tsmetadoi') then 'journal-doi' else 'chunk-doi'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>

  <xsl:template match="para[@role = 'tsmetajournaltitle']" mode="hub:process-meta-sidebar">
    <productname otherclass="journal-title">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </productname>
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

</xsl:stylesheet>