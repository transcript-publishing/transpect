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
  

  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbncheck.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/isbn/xsl/isbnformat.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl"/>  
  <xsl:import href="http://this.transpect.io/a9s/ts/xsl/shared-variables.xsl"/>

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

  <xsl:template match="para[matches(@role, $hub:figure-copyright-statement-role-regex)]
                           [not(..[self::caption])]" mode="hub:figure-captions">
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
  
  <xsl:template match="caption[preceding-sibling::*[1][self::figure]] | *[self::para[@role = 'tsdedication'] or self::css:rule/@name = 'tsdedication' ]/@css:text-align" mode="custom-1"/>

  <xsl:template match="*[self::table | self::informaltable]/@css:padding-left | *[self::table | self::informaltable]/@css:padding-right | *[self::table | self::informaltable]/@css:width" mode="hub:clean-hub"/>
  
  <xsl:template match="/hub/info/css:rules" mode="custom-1">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:variable name="temp-isbn" as="xs:string?" select="replace($basename, '^.+\d(\d{4}).*$', '97838394$10')"/>
    <xsl:variable name="meta-doi" as="xs:string?" select="if (/hub/info/keywordset/keyword[@role = 'DOI'][normalize-space()]) 
      then replace(string-join(/hub/info/keywordset/keyword[@role = 'DOI']), '^.*doi\.org/', '') 
      else ()"/>
    <!--  <xsl:message select="'temp-isbn: ', $temp-isbn, ' calc isbn: ', tr:check-isbn($temp-isbn, 13), 'ges: ', concat('10.14361/', replace($basename, '^.+\d(\d{4}).*$', '97838394$1'), tr:check-isbn($temp-isbn, 13))"/>-->
    <!-- https://redmine.le-tex.de/issues/12499 add doi for chunking later (for calculate chunk DOIs) -->
    <xsl:if test="not(biblioid[@class='doi'])">
      <biblioid class="doi">
        <xsl:choose>
          <xsl:when test="$meta-doi[matches(., '\S')]">
            <xsl:value-of select="$meta-doi"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('10.14361/', replace($basename, '^.+\d(\d{4}).*$', '97838394$1'), tr:check-isbn($temp-isbn, 13))"/>
          </xsl:otherwise>
        </xsl:choose>
      </biblioid>
    </xsl:if>
    <xsl:if test="not(biblioid[@class='isbn'])">
      <biblioid class="isbn">
        <xsl:choose>
          <xsl:when test="/hub/info/keywordset/keyword[@role = 'PDF-ISBN'][matches(., '\S')]">
            <xsl:value-of select="replace(string-join(/hub/info/keywordset/keyword[@role = 'PDF-ISBN']), '^PDF-ISBN\s+', '')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="tr:format-isbn(concat(replace($basename, '^.+\d(\d{4}).*$', '97838394$1'), tr:check-isbn($temp-isbn, 13)))"/>
          </xsl:otherwise>
        </xsl:choose>
      </biblioid>
    </xsl:if>
  </xsl:template>

  <xsl:template match="bibliography[preceding-sibling::*[1][self::bridgehead]]" mode="custom-2" priority="3">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <info>
        <title>
          <xsl:copy-of select="preceding-sibling::*[1][self::bridgehead]/@*,
                               preceding-sibling::*[1][self::bridgehead]/node()"/>
        </title>
        <xsl:if test="..[self::hub]"><xsl:call-template name="create-chunk-DOI"/></xsl:if>
      </info>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>


<!--  <xsl:template match="bibliography/info" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:if test="../..[self::hub]">
        <xsl:call-template name="create-chunk-DOI">
          <xsl:with-param name="context" as="element(*)" select="." tunnel="yes"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:copy>
  </xsl:template>-->

  <xsl:template match="  chapter/info[not(biblioset[@role='chunk-metadata'])] 
                       | part/info[not(biblioset[@role='chunk-metadata'])] 
                       | /*/*[self::appendix|self::bibliography]/info[not(biblioset[@role='chunk-metadata'])]" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:call-template name="create-chunk-DOI">
        <xsl:with-param name="context" as="element(*)" select="." tunnel="yes"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="biblioset[@role='chunk-metadata'][empty(biblioid[@role='tsmetachunkdoi'])]" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:call-template name="create-chunk-DOI">
        <xsl:with-param name="context" as="element(*)" select="." tunnel="yes"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="book-part-chapters" select="/*/part/*[exists(info) or self::bibliography] |
                                                  /*/*[self::chapter|self::bibliography|self::appendix|self::colophon|self::preface|
                                                       self::glossary|self::article|self::acknowledgements]"/>

  <xsl:template name="create-chunk-DOI">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="ancestor" select="ancestor-or-self::*[self::bibliography | self::part| self::chapter | self::appendix | self::colophon | 
                                                              self::preface | self::glossary|self::article|self::acknowledgements][1]"/>
    <xsl:variable name="counter" select="if ($ancestor[self::part]) 
                                          then concat('NO-DOI-', $ancestor/info/title)
                                          else xs:string(format-number(index-of($book-part-chapters, $ancestor), '000'))" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($context) or $context[self::info]">
        <!-- create whole biblioset if it doesn’t exist-->
        <biblioset role="chunk-metadata">
          <biblioid role="tsmetachunkdoi" otherclass="chunk-doi" srcpath="{generate-id()}">
           <xsl:value-of select="if ($ancestor[self::part]) 
                                        then concat(/*/info/biblioid[@class= 'isbn'], '/', $counter) 
                                        else concat(/*/info/biblioid[@class= 'doi'], '-', $counter)"/>
          </biblioid>
        </biblioset>
      </xsl:when>
      <xsl:otherwise>
        <!-- if biblioset exists but not chunk DOI, it is inserted-->
        <biblioid role="tsmetachunkdoi" otherclass="chunk-doi" srcpath="{generate-id()}">
          <xsl:value-of select="concat(/*/info/biblioid[@class= 'doi'], '-', $counter)"/>
        </biblioid>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="part" mode="hub:ids">
    <xsl:copy>
      <xsl:apply-templates select="." mode="hub:ids-atts"/>
      <xsl:apply-templates select="@* except @xml:id | node()" mode="#current"/>
    </xsl:copy>
   <!-- add id to part to allow DOIs  -->
  </xsl:template>
  
  <xsl:template match="part" mode="hub:ids-atts">
    <xsl:attribute name="xml:id" 
      select="concat(
                'Part', 
                string(
                  count( 
                    ( //part ) [. &lt;&lt; current()]
                  ) 
                  + 1 
                )
              )"/>
  </xsl:template>

  <xsl:template match="/hub[@xml:lang = 'en']/info/keywordset[@role = 'titlepage']/keyword//text()" mode="custom-2">
    <!-- replace quotation marks in title pages in english titles, https://redmine.le-tex.de/issues/13838 -->
    <xsl:sequence select="translate(., '»«›‹',  '“”ʻʼ')"/>
  </xsl:template>

  <xsl:template match="footnote/para/phrase[@role = 'hub:identifier']/phrase" mode="custom-2">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="para[matches(@role, '^ts(two|one)column$')]" mode="hub:split-at-tab">
    <xsl:processing-instruction name="{$pi-xml-name}" select="concat(replace(@role, '^ts', '\\'), ' ')"/>
  </xsl:template>

  <xsl:template match="annotation" mode="hub:dissolve-sidebars-without-purpose">
    <!-- https://redmine.le-tex.de/issues/13166 -->
  </xsl:template>

  <xsl:template match="para[matches(@role, $info-doi)]" mode="hub:process-meta-sidebar">
    <biblioid otherclass="{if(@role eq 'tsmetadoi') then 'book-doi' else 'chunk-doi'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>

  <xsl:template match="*[sidebar[@role = 'chunk-metadata']]" mode="hub:process-meta-sidebar" priority="5">
    <xsl:copy>
      <xsl:apply-templates select="@*, (title | titleabbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]])" mode="#current"/>
      <xsl:apply-templates select="sidebar[@role = 'chunk-metadata']" mode="#current"/>
      <xsl:apply-templates select="node() except (title | titleabbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]] | sidebar[@role = 'chunk-metadata'])" mode="#current"/>
    </xsl:copy>
  </xsl:template>

 <!-- pull meta infos after headings -->
  <xsl:template match="para[matches(@role, '^(tsheading|toctitle)')][preceding-sibling::*[1][@role = 'chunk-metadata']]" mode="hub:reorder-marginal-notes">
    <xsl:next-match/>
    <xsl:apply-templates select="preceding-sibling::*[1][@role = 'chunk-metadata']" mode="#current">
      <xsl:with-param name="process-meta-section" tunnel="yes" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'chunk-metadata']" mode="hub:reorder-marginal-notes">
    <xsl:param name="process-meta-section" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="$process-meta-section or preceding-sibling::*[1][@role = ('tsheadlineleft', 'tsheadlineright', 'tsheading1', 'tsheading2', 'tsauthor')]">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="para[matches(@role, '^tsauthor$')]" mode="hub:process-meta-sidebar">
    <author>
      <personname>
        <othername>  
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:value-of select="normalize-space(.)"/>
        </othername>
      </personname>
    </author>
  </xsl:template>

</xsl:stylesheet>
