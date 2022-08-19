<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:html="http://www.w3.org/1999/xhtml"  
  xmlns:epub="http://www.idpf.org/2007/ops"
  exclude-result-prefixes="cx xs html epub"
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/iso-lang/xsl/iso-lang.xsl"/>
  
  <xsl:param name="cover-path" as="xs:string?"/>
  
  <xsl:variable name="metadatadoc" as="document-node(element())?"
                select="collection()[2]"/>
  
  <xsl:variable name="html" as="document-node(element())?"
                select="collection()[/html:html]"/>

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- cover not available in ONIX yet -->
  <xsl:template match="/epub-config/cover">
    <cover href="{$cover-path}" svg="true"/>
  </xsl:template>
  
  <xsl:template match="/epub-config/metadata">
    <xsl:copy>
      <dc:identifier format="EPUB3">
        <xsl:value-of select="$html//html:head/html:meta[@name = 'DC.identifier']/@content"/>
      </dc:identifier>
      <dc:language>
        <xsl:value-of select="($html//html:head/html:meta[@name = 'lang']/@content, $html//html:html/@xml:lang)[1]"/>
      </dc:language>
      <xsl:for-each select="$html//html:head/html:meta[@name[starts-with(.,  'DC')][. ne 'DC.identifier']]">
        <xsl:element name="{translate(lower-case(@name), '.', ':')}">
          <xsl:value-of select="@content"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  

      <xsl:variable name="footnote-heading-title_de" select="'Anmerkungen'" />
      <xsl:variable name="footnote-heading-title_en" select="'Notes'" />
      
      <xsl:variable name="toc-heading-title_de" select="'Inhaltsverzeichnis'" />
      <xsl:variable name="toc-heading-title_en" select="'Table of Contents'" />
      
      <xsl:variable name="imprint-heading-title_de" select="'Impressum'" />
      <xsl:variable name="imprint-heading-title_en" select="'Copyright notice'" />
         
      <xsl:variable name="book-heading-title_de" select="'Über das Buch'" />
      <xsl:variable name="book-heading-title_en" select="'About the book'" />
      
      <xsl:variable name="landmarks-heading-title_de" select="'Übersicht'" />
      <xsl:variable name="landmarks-heading-title_en" select="'Overview'" />

      <xsl:variable name="motto-heading-title_de" select="'Motto'" />
      <xsl:variable name="motto-heading-title_en" select="'Epigraph'" />
      
      
      <xsl:variable name="titlepage-heading-title_de" select="'Titel'" />
      <xsl:variable name="titlepage-heading-title_en" select="'Title'" />
      
  <xsl:variable name="main-lang" select="$html/*:html/*:head/*:meta[@name eq 'lang']/@content"/>

  <xsl:template match="epub-config/types/type/@generate-heading[. = ('true', 'yes')]">
    <xsl:variable name="type" select="../@name"/>
    <xsl:variable name="target-heading" select="$html//*[@epub:type = $type]/descendant::*[local-name() = ('h1', 'h2')][1]/@title"/>
    <xsl:if test="$target-heading[normalize-space()]"><xsl:attribute name="heading" select="$target-heading"/></xsl:if>
  </xsl:template> 

  <xsl:template match="epub-config/types/type[@name = 'titlepage']/@generate-heading[. = ('true', 'yes')]" priority="3">
    <xsl:variable name="type" select="../@name"/>
    <xsl:variable name="title" select="$html//*[@epub:type = $type][1]//descendant::*[local-name() = ('h1', 'h2')][1]/@title" as="xs:string?"/>
    <xsl:attribute name="heading" select="if ($main-lang = 'en') then $titlepage-heading-title_en else $titlepage-heading-title_de" separator=" "/>
  </xsl:template> 

  <xsl:template match="epub-config/types/type[@name = 'preamble']/@generate-heading[. = ('true', 'yes')]" priority="3">
    <xsl:variable name="type" select="../@name"/>
    <xsl:variable name="title" select="$html//*[@epub:type = $type][1]//descendant::*[local-name() = ('h1', 'h2')][1]/@title" as="xs:string?"/>
    <xsl:attribute name="heading" select="if (matches($title, '\S')) 
                                          then $title 
                                          else 
                                            if ($main-lang = 'en') then $book-heading-title_en else $book-heading-title_de" separator=" "/>
  </xsl:template>
  
  <xsl:template  match="epub-config/types/type[@name = 'imprint']/@generate-heading[. = ('true', 'yes')]" priority="3">
    <xsl:variable name="type" select="../@name"/>
    <xsl:variable name="title" select="$html//*[@epub:type = $type][1]//descendant::*[local-name() = ('h1', 'h2')][1]/@title" as="xs:string?"/>
    <xsl:attribute name="heading" select="if (matches($title, '\S')) 
                                          then $title 
                                          else 
                                            if ($main-lang = 'en') then $imprint-heading-title_en else $imprint-heading-title_de" separator=" "/>
  </xsl:template> 

  <xsl:template match="epub-config/types/type[@name = 'landmarks']/@generate-heading[. = ('true', 'yes')]" priority="3">
    <xsl:attribute name="heading" select="if ($main-lang = 'en') then $landmarks-heading-title_en else $landmarks-heading-title_de" separator=" "/>
  </xsl:template> 

  <xsl:template  match="epub-config/types/type[@name = 'toc']/@generate-heading[. = ('true', 'yes')]" priority="3">
    <xsl:variable name="type" select="../@name"/>
    <xsl:variable name="title" select="$html//*[@epub:type = $type][1]//descendant::*[local-name() = ('h1', 'h2')][1]/@title" as="xs:string?"/>
    <xsl:attribute name="heading" select="if (matches($title, '\S')) 
                                          then $title 
                                          else 
                                            if ($main-lang = 'en') then $toc-heading-title_en else $toc-heading-title_de" separator=" "/>
  </xsl:template> 

</xsl:stylesheet>