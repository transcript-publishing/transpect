<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:ts="http://www.transcript-verlag.de/transpect"
  xmlns:tr="http://transpect.io"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk ts tr xlink functx" 
  version="2.0">
  

  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl"/>  
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>

  <!--  Postprocess hub to add stuff that is only important for TeX creation. Like splitting tables etc.-->
  <xsl:param name="table-caption-pos" as="xs:string?"/>

  <xsl:variable name="split-landscape-table-with-dotablebreak-pi" select="true()" as="xs:boolean">
    <!-- As long as tables with PI orientation=landscape cannot be split automatically via the framework, they may be split via converter. 
        how the splitting is done exactly, should in most cases be adapted in customer code to make sure that the position of titles, sources etc. is according to styles 
        https://redmine.le-tex.de/issues/15409-->
  </xsl:variable>
  <xsl:variable name="repeat-split-table-head" select="true()" as="xs:boolean"/>

  <xsl:template match="@* | node()" mode="postprocess-hub">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[self::table|self::informaltable]
                        [@role[contains(., 'tablerotated')] or preceding-sibling::node()[1]
                                                                                       [self::processing-instruction()]
                                                                                       [some $t in tokenize(., '\s+') satisfies $t = 'orientation=landscape']
                        ]
                        [.//processing-instruction()[some $t in tokenize(., '\s+') satisfies $t = '\doTableBreak']]
                        [$split-landscape-table-with-dotablebreak-pi]" mode="postprocess-hub">
    <xsl:call-template name="split-table">
      <xsl:with-param name="table" as="element()" select="."/>
    </xsl:call-template>
    <!-- overwrite this in your adaptations to position titles/sources in first or last table fragment. 
         be aware that it splits tables also if the hub is further processed to XML/HTML.-->
  </xsl:template>


</xsl:stylesheet>
