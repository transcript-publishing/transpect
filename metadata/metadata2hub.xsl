<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  
  <xsl:import href="http://this.transpect.io/a9s/common/metadata/metadata2hub.xsl"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="plist">
    <keywordset role="titlepage">
      <xsl:apply-templates select="array/dict/key"/>
    </keywordset>
  </xsl:template>
  
  <xsl:template match="key">
    <keyword role="{css:compatible-name(.)}">
      <xsl:apply-templates select="following-sibling::*[1][self::string or self::array]"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="array">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="string">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="array/string" priority="2">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>
  
  <xsl:template match="b">
    <phrase css:font-weight="bold">
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>
  
  <xsl:template match="i">
    <phrase css:font-style="italic">
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>
  
  <!-- https://redmine.le-tex.de/issues/13098 -->
  
  <xsl:template match="array[preceding-sibling::*[1][self::key][. eq 'Bibliografische Information']]/string[1]" priority="5"/>
    
  <xsl:template match="string[preceding-sibling::*[1][self::key][. eq 'Copyright']]/b" priority="5">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:function name="css:compatible-name" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(  
                                  replace(
                                          replace(
                                                  normalize-unicode($input, 'NFKD'), 
                                                  '\p{Mn}', 
                                                  ''
                                                  ), 
                                          '[^-_a-z0-9]', 
                                          '_', 
                                          'i'
                                          ),
                                  '^(\I)',
                                  '_$1'
                                  )"/>
  </xsl:function>
  
</xsl:stylesheet>
