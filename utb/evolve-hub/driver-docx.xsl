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
  
  <xsl:import href="http://this.transpect.io/a9s/ts/evolve-hub/driver-docx.xsl"/>

  
  <xsl:template match="para[matches(@role, 'tsnumberof(tasks|units)|tsdoembed(link|h5p)')]" 
                mode="hub:split-at-tab" priority="5">
    <!--https://redmine.le-tex.de/issues/18626#note-2-->
  </xsl:template>
  
  <!--<xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+" 
                select="('^(berschrift1|[Hh]eading\s?1|[a-z]{1,3}headingpart)|[a-z]{1,3}(front|back)matter1$',
                         concat('^(berschrift2|[Hh]eading\s?2|[a-z]{1,3}heading1|[a-z]{1,3}(front|back)matter2|[a-z]{1,3}(journalreviewheading|heading1review)|[a-z]{1,3}headingenumerated1|toctitle',
                                '|', replace($appendix-heading-role-regex, '^\^', ''),
                                '|', concat(replace($index-heading-regex, '^\^', ''), '(\p{L}+)?'(:allow different index types declared in heading:)),
                                '|', replace($list-of-figures-regex, '^\^(.+)\$$', '$1'),
                                '|', replace($list-of-tables-regex, '^\^(.+)\$$', '$1'),
                                '|', replace($acknowledgements-role-regex, '^\^(.+)\$$', '$1'),
                                ')(', $suffixes-regex, ')?$'
                                ),
                         concat('^(berschrift3|[Hh]eading\s?3|[a-z]{1,3}heading2|[a-z]{1,3}headingenumerated2|[a-z]{1,3}(front|back)matter3)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift4|[Hh]eading\s?4|[a-z]{1,3}heading3|[a-z]{1,3}headingenumerated3|[a-z]{1,3}(front|back)matter4)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift5|[Hh]eading\s?5|[a-z]{1,3}heading4|[a-z]{1,3}add[a-z]+heading|[a-z]{1,3}headingenumerated4|[a-z]{1,3}(front|back)matter5)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift6|[Hh]eading\s?6|[a-z]{1,3}heading5|[a-z]{1,3}headingenumerated5|[a-z]{1,3}(front|back)matter6)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift7|[Hh]eading\s?7|[a-z]{1,3}heading6|[a-z]{1,3}headingenumerated6|[a-z]{1,3}(front|back)matter7)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift8|[Hh]eading\s?8|[a-z]{1,3}heading7|[a-z]{1,3}headingenumerated7|[a-z]{1,3}(front|back)matter8)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift9|[Hh]eading\s?9|[a-z]{1,3}heading8|[a-z]{1,3}headingenumerated8|[a-z]{1,3}(front|back)matter9)(', $suffixes-regex, ')?$')
                         )"/>-->
  
  
  <xsl:template match="*[para[matches(@role, '^tsadd')]]"  mode="hub:group-add-elements" xmlns="http://docbook.org/ns/docbook">
    <xsl:param name="wrapper-element-name" select="name()" as="xs:string" tunnel="no"/>
    <xsl:element name="{$wrapper-element-name}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*|processing-instruction()" 
                          group-adjacent="self::para[matches(@role, '^tsadd')] 
                                          or
                                          self::processing-instruction()[preceding-sibling::*[1][self::para[matches(@role, '^tsadd')]] 
                                                                         and
                                                                         following-sibling::*[1][self::para[matches(@role, '^tsadd')]]]">

          <xsl:choose>
            <xsl:when test="current-grouping-key()">
              <xsl:for-each-group select="current-group()" 
                                  group-starting-with=".[self::para[matches(@role, '^tsadd.+heading')]]">
                <!-- splitted in different ts add block, starting with 'headings' -->
                <xsl:element name="section">
                  <xsl:attribute name="role" select="replace(current-group()[1]/@role, 'heading', '')"/>
                    <title>
                      <xsl:apply-templates select="current-group()[1]/(@*,node())" mode="#current"/>
                    </title>
                  <xsl:apply-templates select="current-group()[position() gt 1]" mode="#current"/>
                </xsl:element>
              </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>
