<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://transpect.io/cascade/xsl/paths.xsl"/>
  
  <xsl:strip-space elements="*"/>
  
  <!-- these values are to be overwritten by the pipeline -->
  
  <xsl:param name="work-regex" select="doc('../params.xml')/c:param-set/c:param[@name eq 'work-regex']/@value" as="xs:string"/>
  <xsl:param name="series-regex" select="doc('../params.xml')/c:param-set/c:param[@name eq 'series-regex']/@value" as="xs:string"/>
  <xsl:param name="type-regex" select="doc('../params.xml')/c:param-set/c:param[@name eq 'type-regex']/@value" as="xs:string"/>
  <xsl:param name="publisher-regex" select="doc('../params.xml')/c:param-set/c:param[@name eq 'publisher-regex']/@value" as="xs:string"/>
  <xsl:param name="cascade-paths-regex" as="xs:string"
            select="concat('^(',
                           $publisher-regex,
                           ')_(',
                           $series-regex,
                           ')_(',
                           $type-regex,
                           ')_(',
                           $work-regex,
                           ')(_.*)?$'
                           )"/>
  
  <xsl:function name="tr:parse-file-name" as="attribute(*)*">
    <xsl:param name="filename" as="xs:string?"/>
    <xsl:variable name="basename" select="tr:basename($filename)" as="xs:string"/>
    <xsl:variable name="ext" select="tr:ext($filename)" as="xs:string"/>
    <xsl:attribute name="ext" select="$ext"/>
    <xsl:attribute name="base" select="$basename"/>
    <xsl:message select="'[info] basename: ', $basename"/>
    <xsl:message select="'[info] regex: ', $cascade-paths-regex"/>
    <xsl:message select="'[info] matches: ', matches($basename, $cascade-paths-regex)"/>
    <xsl:analyze-string select="$basename" regex="{$cascade-paths-regex}" flags="i">
      <xsl:matching-substring>
        <xsl:message select="'[info] publisher: ', regex-group(1)"/>
        <xsl:message select="'[info] series: ',    regex-group(2)"/>
        <xsl:message select="'[info] type: ',      regex-group(3)"/>
        <xsl:message select="'[info] work: ',      regex-group(4)"/>
        <xsl:attribute name="publisher" select="regex-group(1)"/>
        <xsl:attribute name="series"    select="regex-group(2)"/>
        <xsl:attribute name="type"      select="regex-group(3)"/>
        <xsl:attribute name="work"      select="regex-group(4)"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
	<xsl:message select="'[WARNING] paths regex did not match!'"/>
	<xsl:message select="'[info] work: ',      regex-group(4)"/>
        <xsl:attribute name="work"      select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>

  <xsl:template match="@ext[. = ('cover.png', 'cover.jpg')]" mode="tr:ext-to-target-subdir">
    <xsl:sequence select="'epub/cover'"/>
  </xsl:template>
  
</xsl:stylesheet>
