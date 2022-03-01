<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:hub="http://transpect.io/hub"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://this.transpect.io/a9s/common/xsl/shared-variables.xsl"/>

  <xsl:variable name="tei2html:epub-type" as="xs:string" select="'3'"/>
  <xsl:variable name="tei2html:chapterwise-footnote" select="true()" as="xs:boolean"/>

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+" 
                select="('^(berschrift1|[Hh]eading\s?1|[a-z]{1,3}headingpart|[a-z]{1,3}indexheading)',
                         '^(berschrift2|[Hh]eading\s?2|[a-z]{1,3}heading1|[a-z]{1,3}journalreviewheading|[a-z]{1,3}headingenumerated1|[a-z]{1,3}listoffigures|toctitle)$',
                         '^(berschrift3|[Hh]eading\s?3|[a-z]{1,3}heading2(keywords|orientation|exercise|summary|leadingquestions|learningoutcome)?|[a-z]{1,3}headingenumerated2)$',
                         '^(berschrift4|[Hh]eading\s?4|[a-z]{1,3}heading3|[a-z]{1,3}headingenumerated3)$',
                         '^(berschrift5|[Hh]eading\s?5|[a-z]{1,3}heading4|[a-z]{1,3}headingenumerated4)$',
                         '^(berschrift6|[Hh]eading\s?6|[a-z]{1,3}heading5|[a-z]{1,3}headingenumerated5)$',
                         '^(berschrift7|[Hh]eading\s?7|[a-z]{1,3}heading6|[a-z]{1,3}headingenumerated6)$',
                         '^(berschrift8|[Hh]eading\s?8|[a-z]{1,3}heading7|[a-z]{1,3}headingenumerated7)$',
                         '^(berschrift9|[Hh]eading\s?9|[a-z]{1,3}heading8|[a-z]{1,3}headingenumerated8)$')"/>

</xsl:stylesheet>