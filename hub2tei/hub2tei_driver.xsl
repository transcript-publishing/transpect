<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.w3.org/1996/css"
                xmlns:dbk="http://docbook.org/ns/docbook"
                xmlns:hub="http://transpect.io/hub"
                xmlns:hub2tei="http://transpect.io/hub2tei"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:docx2hub="http://transpect.io/docx2hub"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:tr="http://transpect.io"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="dbk docx2hub html hub2tei hub xlink css xs cx tr tei"
                version="2.0" 
                xpath-default-namespace="http://docbook.org/ns/docbook">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="http://this.transpect.io/a9s/common/hub2tei/hub2tei_driver.xsl"/>

  <xsl:param name="repo-href-canonical"/>
  
  <xsl:template match="programlisting" mode="hub2tei:dbk2tei">
    <p rend="{@role}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="programlisting/line" mode="hub2tei:dbk2tei">
    <hi>
      <xsl:apply-templates mode="#current"/>
    </hi>
  </xsl:template>
  
  <xsl:function name="hub2tei:image-path"  as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="root" as="document-node()?"/>
    <!--<xsl:variable name="source-type" as="xs:string?" 
      select="$root/*[self::book or self::hub]/info/keywordset/keyword[@role eq 'source-type']"/>-->
    <xsl:choose>
      <xsl:when test="matches($path, '^https?:')">
        <xsl:sequence select="$path"/>
      </xsl:when>
      <xsl:when test="matches($path, '(/(idml|word)/(images|media)/|/out/images/)')">
        <xsl:sequence select="$path"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="image-content-repo-path" 
          select="replace($repo-href-canonical, '^(.+/\d{5}/).+$', '$1images/')" as="xs:string"/>
        <xsl:variable name="image-basename" 
          select="replace($path, '^.+/', '')" as="xs:string"/>
        <xsl:variable name="image-path" 
          select="string-join(($image-content-repo-path, $image-basename), '')" as="xs:string"/>
        <xsl:sequence select="if (not(matches($image-path, '_png\.'))) 
             then replace($image-path, '\.(tiff?|eps|ai|pdf)$', '.jpg', 'i') 
             else replace($image-path, '_png\.(tiff?|eps|ai|pdf)$', '.png', 'i')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>
