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
  
  <xsl:import href="http://transpect.io/hub2tei/xsl/hub2tei.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/common/hub2tei/hub2tei_driver.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/cals2htmltable/xsl/cals2htmltables.xsl"/>
  
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
  
</xsl:stylesheet>
