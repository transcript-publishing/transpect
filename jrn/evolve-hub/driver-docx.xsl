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
  exclude-result-prefixes="xs hub dbk ts xlink functx" 
  version="2.0">
  
  <xsl:import href="../../evolve-hub/driver-docx.xsl"/>  

  <xsl:template match="/hub/info/keywordset[@role = 'titlepage']" mode="hub:split-at-tab">
    <!-- map meta table to keywords -->
    <xsl:variable name="meta-table" as="element(informaltable)*" select="/hub/informaltable[some $p in descendant::para satisfies $p[@role = 'tsmetajournal']]"/>
    <xsl:choose>
      <xsl:when test="exists($meta-table)">
        <keywordset role="titlepage">
          <xsl:apply-templates select="$meta-table//row" mode="meta-to-keyword"/>
        </keywordset>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="row" mode="meta-to-keyword">   
    <keyword role="{css:compatible-name(normalize-space(string-join(entry[1]/node())))}">
      <xsl:apply-templates select="entry[2]/node()" mode="hub:split-at-tab"/>
    </keyword>
  </xsl:template>

  <xsl:function name="css:compatible-name" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(  
                                  replace(
                                          replace(
                                                  normalize-unicode($input, 'NFKD'), 
                                                  '\p{Mn}', 
                                                  ''
                                                  ), 
                                          '[^-_a-z0-9]', 
                                          '_', 
                                          'i'
                                          ),
                                  '^(\I)',
                                  '_$1'
                                  )"/>
  </xsl:function>

  <xsl:template match="para[@role = 'tsmetajournal']//@*[not(name() = ('css:font-weight', 'css:font-style', 'css:text-decoration'))]" priority="5" mode="hub:split-at-tab"/>

  <xsl:template match="row[entry[1][matches(para[@role = 'tsmetajournal'], 'Copyright|Bibliografische\s+Information')]]/entry[2]/phrase[@css:font-weight = 'bold']" priority="5" mode="hub:split-at-tab">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="/hub/informaltable[some $p in descendant::para satisfies $p[@role = 'tsmetajournal']]" mode="hub:split-at-tab"/>

  <xsl:template match="para[@role = ('tsmetadoi', 'tsmetachunkdoi')]" mode="hub:process-meta-sidebar">
    <biblioid class="doi" otherclass="{if(@role eq 'tsmetadoi') then 'journal-doi' else 'chunk-doi'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>

  <xsl:template match="para[@role = 'tsmetajournaltitle']" mode="hub:process-meta-sidebar">
    <productname otherclass="journal-title">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </productname>
  </xsl:template>

  <xsl:template match="para[@role = 'tsmetajournalyear']" mode="hub:process-meta-sidebar">
    <date otherclass="journal-year">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </date>
  </xsl:template>
  
  <xsl:template match="para[@role = 'tsmetajournalissue']" mode="hub:process-meta-sidebar">
    <issuenum>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </issuenum>
  </xsl:template>

  <xsl:template match="para[matches(@role, $hub:keywords-role-regex)]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="process-meta" tunnel="yes" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$process-meta">
        <xsl:variable name="lang" select="key('natives', @role)" as="element(css:rule)?"/>
        <xsl:variable name="text" select="string-join(descendant::text(), '')" as="xs:string?"/>
        <xsl:variable name="without-heading" select="replace($text, '^(Schlüssel(wörter|begriffe)|Key\s?words|Mots[ -]clés):[\p{Zs}*]?', '', 'i')" as="xs:string?"/>
        <xsl:variable name="single-keywords" select="tokenize($without-heading, ';')" as="xs:string*"/>
        <xsl:for-each select="$single-keywords">
          <xsl:element name="keyword">
            <xsl:if test="$lang[@xml:lang]">
              <xsl:attribute name="xml:lang" select="$lang/@xml:lang"/>
            </xsl:if>
            <xsl:value-of select="if (. eq $single-keywords[last()]) then replace(normalize-space(.), '\.$', '') else normalize-space(.)"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
    <!--<biblioid class="doi"><xsl:value-of select="if (exists(/hub//biblioset[@role='chunk-metadata']/biblioid[@role= 'tsmetadoi']))
                                                then (/hub//biblioset[@role='chunk-metadata'][biblioid[@role= 'tsmetadoi']])[1]/biblioid[@role= 'tsmetadoi']
                                                else concat('10.14361/', replace($basename, '^.+\d(\d{4}).*$', '97838394$1'), tr:check-isbn($temp-isbn, 13))"/>
   </biblioid>
    <biblioid class="isbn"><xsl:value-of select="tr:format-isbn(concat(replace($basename, '^.+\d(\d{4}).*$', '97838394$1'), tr:check-isbn($temp-isbn, 13)))"/></biblioid>-->
    <xsl:if test="not(biblioid[@class='doi'])">  
      <biblioid class="doi" otherclass="temp">
        <xsl:choose>
          <xsl:when test="$meta-doi[matches(., '\S')] or exists(/hub//biblioset[@role='chunk-metadata']/biblioid[@role= 'tsmetadoi'])">
            <xsl:value-of select="((/hub//biblioset[@role='chunk-metadata'][biblioid[@role= 'tsmetadoi']])[1]/biblioid[@role= 'tsmetadoi'][normalize-space()], $meta-doi)[1]"/>
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

  <xsl:template name="create-chunk-DOI">
    <xsl:param name="context" as="element(*)?" tunnel="yes"/>
    <xsl:variable name="ancestor" select="ancestor-or-self::*[not(self::biblioset | self::info)][1]"/>
    <xsl:variable name="counter" select="if ($ancestor[self::part]) 
                                          then concat('NO-DOI-', $ancestor/info/title)
                                          else xs:string(format-number(index-of($book-part-chapters, $ancestor), '00'))" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($context) or $context[self::info]">
        <!-- create whole biblioset if it doesn’t exist-->
        <biblioset role="chunk-metadata">
          <biblioid role="tsmetachunkdoi" otherclass="chunk-doi" srcpath="{generate-id()}">
           <xsl:value-of select="concat(if ($ancestor[self::part]) 
                                        then concat(/*/info/biblioid[@class= 'isbn'], '/')
                                        else replace(replace(replace(/*/info/biblioid[@class= 'doi'], '\.issue-(\d)$', '0$1'), '\.issue-(\d)$', '$1'), '\.', '-'), $counter)"/>
          </biblioid>
        </biblioset>
      </xsl:when>
      <xsl:otherwise>
        <!-- if biblioset exists but not chunk DOI, it is inserted-->
        <biblioid role="tsmetachunkdoi" otherclass="chunk-doi" srcpath="{generate-id()}">
          <xsl:value-of select="concat(/*/info/biblioid[@class= 'doi'], $counter)"/>
        </biblioid>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="biblioid[@class='doi'][@otherclass='temp']" mode="custom-2"/>

<!-- to do: tei2bits. fm und toc bei ZS 10.14361/dak-2021-toc01 statt zig.2020.11.issue-1-toc-->
<!-- Parts haben keine IDs -> DOIS falsch, bzw. werden sie nicht richtig zugeordnet. -->
</xsl:stylesheet>