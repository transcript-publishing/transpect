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
  
  <xsl:template match="blockquote[para[matches(@role, '^[a-z]{2,3}ded(ication)?$')]]
                      |para[matches(@role, '^[a-z]{2,3}ded(ication)?$')][not(parent::blockquote)]" mode="custom-1">
    <dedication>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dedication>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{2,3}codeblock[a-z0-9]+$')]" mode="custom-1">
    <programlisting role="{@role}">
      <line>
        <xsl:apply-templates mode="#current"/>
      </line>
    </programlisting>
  </xsl:template>
  
</xsl:stylesheet>