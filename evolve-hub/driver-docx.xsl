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
  
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl"/>  
  

  <xsl:template match="/" mode="custom-2">
    <xsl:variable name="out-dir" as="element(keyword)"
                  select="hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'archive-dir-uri']"/>
    <xsl:variable name="basename" as="element(keyword)" 
                  select="hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-basename']"/>
    <xsl:copy>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
    <xsl:if test="//bibliomixed[node()]">
      <xsl:result-document href="{concat($out-dir, '/', $basename, '.bib.txt')}" 
                           method="text" media-type="text/plain" encoding="UTF-8">
        <xsl:value-of select="string-join(//bibliomixed, '&#xa;')"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="para[matches(@role, $hub:figure-copyright-statement-role-regex)]" mode="hub:figure-captions">
    <caption>
      <xsl:copy>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:copy>
    </caption>
  </xsl:template>

  <xsl:template match="figure[following-sibling::*[1][self::caption]]" mode="custom-1">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <caption>
          <xsl:apply-templates select="following-sibling::*[1][self::caption]/node()" mode="#current"/>  
      </caption>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="caption[preceding-sibling::*[1][self::figure]]" mode="custom-1"/>

  <xsl:template match="para[matches(@role, 'tsmedia')]//text()[matches(., $hyphen-regex)]" mode="custom-2">
    <!--https://redmine.le-tex.de/issues/10237#change-52626-->
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="link[@xlink:href][not(matches(@xlink:href, $regex-for-url-to-link-recognition))]" mode="hub:clean-hub">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>


</xsl:stylesheet>