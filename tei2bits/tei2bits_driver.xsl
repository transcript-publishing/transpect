<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:tei2bits="http://transpect.io/tei2bits" 
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  xmlns:mml="MathML Namespace Declaration"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tr hub2htm saxon tei2bits tei xsl xs" 
  version="2.0">
  
  <xsl:import href="http://transpect.io/tei2bits/xsl/tei2bits.xsl"/>
  
  <xsl:variable name="css:wrap-content-with-elements-from-mappable-style-attributes" as="xs:boolean"
    select="false()"/>
  
  <xsl:variable name="metadata" as="element(*)?" select="/TEI/teiHeader/profileDesc/textClass/keywords[@rendition = 'titlepage']"/>

  <xsl:variable name="tei2bits:alt-title-regex" as="xs:string" select="'tsheadline(left|right)?$'"/>

  <xsl:template name="book-meta">
    <book-meta>
      <xsl:apply-templates select="teiHeader" mode="#current"/>
<!--      <xsl:apply-templates select="//*[local-name() = $metadata-elements-in-content]" mode="#current">
        <xsl:with-param name="in-metadata" select="true()" as="xs:boolean" tunnel="yes"/>
      </xsl:apply-templates>-->
    </book-meta>
  </xsl:template>

  <xsl:template name="sec-meta">
    <xsl:if test="byline[following-sibling::*] or abstract or keywords or argument or opener[idno] or p[@rend = 'artpagenums']">
      <sec-meta>
        <xsl:apply-templates select="byline[following-sibling::*], opener[idno], abstract, argument, keywords, p[@rend = 'artpagenums']" mode="#current"/>
      </sec-meta>
    </xsl:if>
  </xsl:template>
 
  <xsl:template name="book-part-body">
    <body>
      <xsl:apply-templates select="node() except (opener[idno], floatingText[@type = 'box'][@rend  = 'receipt'], byline, head, dateline, abstract, argument, keywords, p[matches(@rend, 'artpagenums|Grundtext_(Abstract|Keyword)')], ./div[@type = ('dedication', 'index', 'app', 'appendix', 'bibliography')], ./div[tei2bits:is-ref-list(.)], divGen[@type = ('toc', 'index')], listBibl, ./div[head[matches(@rend, 'Endnote_Endnote_U1')]])" mode="#current"/>
    </body>
  </xsl:template>

  <xsl:template name="book-part-back">
    <xsl:if test="some $elt in * satisfies $elt[self::div[@type = ('index', 'app', 'appendix', 'bibliography')] | self::divGen[@type = 'index'] | self::listBibl | self::div[tei2bits:is-ref-list(.)] | self::div[head[matches(@rend, 'Endnote_Endnote_U1')]]]">
      <back>
        <xsl:apply-templates select="*[self::div[@type = ('index', 'app', 'appendix', 'bibliography')] | self::divGen[@type = 'index'] | self::listBibl | self::div[tei2bits:is-ref-list(.)] | self::div[head[matches(@rend, 'Endnote_Endnote_U1')]]]" mode="#current"/>
      </back>
    </xsl:if>
  </xsl:template>

  <xsl:template match="seriesStmt/biblScope[@unit = 'issue'] | keywords[@rendition='titlepage']/term[@key = 'Bandnummer']" mode="tei2bits">
    <book-volume-id>
      <xsl:apply-templates select="node()" mode="#current"/>
    </book-volume-id>
  </xsl:template>

  <xsl:template match="seriesStmt/biblScope[@unit = 'consecutive-issue']" mode="tei2bits">
    <book-volume-id content-type="consecutive">
      <xsl:apply-templates select="node()" mode="#current"/>
    </book-volume-id>
  </xsl:template>

  <xsl:template match="div[tei2bits:is-ref-list(.)]" mode="tei2bits" priority="3">
    <ref-list>
      <xsl:apply-templates select="@* except @rend, node() except byline[not(following-sibling::*)]" mode="#current">
        <xsl:with-param name="dissolve-listBibl" as="xs:boolean?" tunnel="yes" select="true()"/>
      </xsl:apply-templates>
    </ref-list>
  </xsl:template>

  <xsl:template match="div[tei2bits:is-ref-list(.)]/p[matches(@rend, 'tsliterature')]" mode="tei2bits" priority="3">
    <ref>
      <xsl:apply-templates select="@*" mode="#current"/>
      <mixed-citation>
        <xsl:apply-templates select="node()" mode="#current"/>
      </mixed-citation>
    </ref>
  </xsl:template>

 <!-- <xsl:template match="abstract/p[matches(@rend, 'Grundtext_Abstract_Trans')]" mode="tei2bits">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="abstract[not(p[matches(@rend, 'Grundtext_Abstract_Trans')]) 
                                  and 
                                not(p[matches(@rend, 'Grundtext_Abstract_U1')])]/p[matches(@rend, 'Grundtext_Abstract($|_-_)')][1][node()[1][self::seg[1][matches(@rend, 'Kursiv|Italic')]]][count(node()) gt 1]" 
                mode="tei2bits" priority="3">
    <p>
      <xsl:apply-templates select="@*, node()[not(. is ../node()[1])]" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="abstract[not(p[matches(@rend, 'Grundtext_Abstract_Trans')]) 
    and 
    p[matches(@rend, 'Grundtext_Abstract_U1')]]/p[matches(@rend, 'Grundtext_Abstract($|_-_)')][1][node()[1][self::seg[1][matches(@rend, 'Kursiv|Italic')]]][count(node()) gt 1]" 
    mode="tei2bits" priority="2">
    
    <xsl:variable name="trans-title-tokens" as="element()*">
      <xsl:for-each-group select="node()" group-adjacent="exists(.[self::seg | self::hi][matches(@rend, 'Kursiv|Italic')])">
        <xsl:if test="current-grouping-key() and current-group()[1][. is ../node()[1]]"><temp><xsl:sequence select="current-group()"/></temp></xsl:if>
      </xsl:for-each-group>
      <!-\-https://redmine.le-tex.de/issues/10550-\->
      <!-\-<p rend="Grundtext_Abstract_-_en"><seg rend="typografisch_Kursiv">Composing with Structures in the 21</seg><hi rendition="superscript" rend="typografisch_Kursiv_-_Hochgestellt">st</hi><seg rend="typografisch_Kursiv" srcpath="_d33552e3742"> Century</seg> – Structural composition is indebted to an emphatic orientation towards art music. It follows the tradition of Bach, Beethoven and Schoenberg, a-\->
    </xsl:variable>
    
    <title>
      <xsl:apply-templates select="$trans-title-tokens/node()" mode="#current"/>
    </title>
    <p>
      <xsl:apply-templates select="@*, node()[not(@srcpath = $trans-title-tokens/node()/@srcpath)]" mode="#current"/>
    </p>
  </xsl:template>-->

  <xsl:template match="*[local-name() = ('trans-abstract', 'abstract')]/*:p[1][matches(., '^([\p{Zs}]*–|[\p{Zs}]+–?)')]/text()[1]" mode="clean-up">
    <xsl:value-of select="replace(., '^([\p{Zs}]*–|[\p{Zs}]+–?)\p{Zs}*', '')"/>
  </xsl:template>


  <xsl:template match="div[@type = 'section'][p[matches(@rend, 'Grundtext_Abstract')]] | 
                       /TEI/text/body/div/p[matches(@rend, 'Grundtext_Abstract|Grundtext_Keywords')] | 
                      div[@type = 'abstract'] |
                      div[@type = 'section'][every $child in * satisfies $child[self::div[@type = 'abstract']]]" mode="tei2bits" priority="3"/>


  <xsl:template match="div[@type = 'preface'][@rend = 'editorial'][not(div[@type = 'article'])]/opener[every $n in node()[normalize-space()] satisfies $n[self::idno]]/idno" mode="tei2bits">
    <book-part-id>
       <xsl:apply-templates select="@*, node()" mode="#current"/>
    </book-part-id>
  </xsl:template>

  <xsl:template match="div[@type = 'preface'][@rend = 'editorial'][not(div[@type = 'article'])]/opener[every $n in node()[normalize-space()] satisfies $n[self::idno]]/idno/@type" mode="tei2bits" priority="4">
    <xsl:attribute name="book-part-id-type" select="lower-case(.)"/>
  </xsl:template>

  <xsl:template match="publicationStmt" mode="tei2bits">
    <publisher>
      <publisher-name><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsname']) then $metadata/term[@key eq 'Verlagsname'] else 'transcript Verlag'"/></publisher-name>
      <publisher-loc><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsort']) then $metadata/term[@key eq 'Verlagsort'] else 'Bielefeld'"/></publisher-loc>
    </publisher>
    <xsl:if test="date or publisher or $metadata/term[@key = 'Copyright']">
      <xsl:variable name="copyright" select="replace($metadata/term[@key = 'Copyright']/text(), ', .+$', '')" as="xs:string?"/>
      <permissions>
        <copyright-statement><xsl:value-of select="$copyright"/></copyright-statement>
        <copyright-year><xsl:value-of select="if ($metadata/term[@key eq 'Jahr']) then $metadata/term[@key eq 'Jahr'] else replace($copyright, '^.+?(\d{4}).*$', '$1')"/></copyright-year>
        <copyright-holder><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsname']) then $metadata/term[@key eq 'Verlagsname'] else  replace($copyright, '^.+?\d{4}\p{Zs}*(.+)$', '$1')"/></copyright-holder>
        <license>
          <!--will be filled later-->
        </license>
      </permissions>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="book-part-chapters" select="/*:book/*[self::*:book-body|*:book-back]//*:book-part[not(@book-part-type = 'part')]"/>
<!--  <xsl:variable name="book-part-parts" select="/*:book/*[self::*:book-body|*:book-back]//*:book-part[@book-part-type = 'part']"/>-->

  <xsl:template match="*[local-name() = ('title-group', 'book-title-group')]
                        [parent::*[local-name() = ('book-part-meta', 'book-meta')]]" mode="clean-up" priority="3">
    <!-- move abstract title or alt title to title group -->
    <xsl:if test="..[self::*:book-part-meta] and not(..[*:book-part-id])">
      <xsl:variable name="counter" select="if (../..[@book-part-type = 'part']) 
                                          then concat('NO-DOI-', *:title)
                                          else xs:string(format-number(index-of($book-part-chapters, ../..), '000'))" as="xs:string?"/>
      <xsl:variable name="counter-with-fm" select="if (../..[self::*:front-matter-part[@book-part-type= 'title-page']]) 
                                                   then 'fm' 
                                                   else 
                                                      if (../..[self::*:front-matter-part][@book-part-type= 'toc']) 
                                                      then 'toc'
                                                      else $counter"/>
      <book-part-id book-part-id-type="doi"><xsl:value-of select="concat(/*:book/*:book-meta/*:book-id[@book-id-type ='doi'], '-', $counter-with-fm)"/></book-part-id>
      <xsl:message select="concat(/*:book/*:book-meta/*:book-id[@book-id-type ='doi'], '-', $counter)"/>
    </xsl:if>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="parent::*[local-name() = ('book-part-meta', 'book-meta')]
                                  [*:trans-abstract[*:title]
                                   or
                                   following-sibling::*:body[1]/*:sec[@sec-type = 'alternative-title'][*:p]]">
      <xsl:for-each select="../*:trans-abstract/*:title | 
                            ../following-sibling::*:body[1]/*:sec[@sec-type = 'alternative-title']/*:p">
        <xsl:element name="trans-title-group">
          <xsl:apply-templates select="../@xml:lang" mode="#current"/>
            <xsl:element name="trans-title">
              <xsl:apply-templates select="@*, node()" mode="#current"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="titleStmt" mode="tei2bits">

    <xsl:if test="$metadata/term[@key = 'DOI'][normalize-space()]">
      <book-id book-id-type="doi"><xsl:value-of select="$metadata/term[@key = 'DOI'][normalize-space()]"/></book-id>
    </xsl:if>

    <contrib-group>
      <xsl:for-each select="$metadata/term[@key = ('Autor', 'Herausgeber')][normalize-space()]">
        <contrib contrib-type="{if (.[@key = 'Autor']) then 'author' else 'editor'}"><xsl:value-of select="."/></contrib>
      </xsl:for-each>
    </contrib-group>

    <xsl:if test="title[@type = 'title'] or $metadata/term[@key = 'Titel'][normalize-space()]">
      <book-title-group>
        <book-title>
          <xsl:apply-templates select="title[@type = 'main']/@*" mode="#current"/>
          <xsl:value-of select="($metadata/term[@key = 'Titel'][normalize-space()], title[@type = 'sub'])[1]"/>
        </book-title>
        <xsl:if test="title[@type = 'sub'] or $metadata/term[@key = 'Untertitel'][normalize-space()]">
          <xsl:apply-templates select="title[@type = 'main']/@*" mode="#current"/>
          <subtitle>
            <xsl:value-of select="($metadata/term[@key = 'Untertitel'][normalize-space()], title[@type = 'sub'])[1]"/>
          </subtitle>
        </xsl:if>
        <xsl:if test="title[@type = 'issue-title'] or $metadata/term[@key = 'Reihe'][normalize-space()]">
          <subtitle content-type="issue-title">
            <xsl:apply-templates select="title[@type = 'issue-title']/@*" mode="#current"/>
            <xsl:value-of select="($metadata/term[@key = 'Reihe'][normalize-space()], title[@type = 'issue-title'])[1]"/>
          </subtitle>
        </xsl:if>
      </book-title-group>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match="*:book-part-meta/*:contrib/*:name/*:sup | *:alt-title" mode="clean-up"/>

  <xsl:template match="*:book-part[*:book-part-meta[count(*:notes) gt 1]]/*:body/*:sec/*:sec-meta | *:book-part[*:book-part-meta[count(*:notes) gt 1]]/*:body/*:sec/*:subtitle" mode="clean-up"/>
 
  <xsl:template match="anchor[not(key('link-by-anchor', concat('#',@xml:id))) and not(key('link-by-anchor', @xml:id))]" mode="tei2bits" priority="5"/>

  <xsl:template match="*:book-part/*:book-part-meta/*:contrib/*:name" mode="clean-up" exclude-result-prefixes="#all">
    <xsl:variable name="bios" select="ancestor::*:book-part[1]/descendant::*:bio" as="element()*"/>
    <xsl:variable name="corresp-bios" select="for $b in $bios return $b[some $token in tokenize(*:p[1], '\p{Zs}+') satisfies $token = current()/*:surname]" as="element()*"/>
    <xsl:variable name="corresp-bio" select="if (count($corresp-bios) gt 1) 
                                             then for $b in $corresp-bios return $b[some $token in tokenize(*:p[1], '\p{Zs}+') satisfies $token = current()/*:given-names]
                                             else $corresp-bios" as="element()*"/>
    <xsl:if test="exists($corresp-bio/*:p[matches(., 'orcid\.org')])">
      <contrib-id contrib-id-type="orcid"><xsl:sequence select="replace($corresp-bio[1]/*:p[matches(., 'orcid\.org')][1], '^(ORCID(-ID)?:\p{Zs}+)?(\P{Zs}+)\p{Zs}*$', '$3', 'i')"></xsl:sequence></contrib-id>
    </xsl:if>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="@css:font-style[. = ('italic', 'oblique')] | @css:font-weight[matches(., '^bold|[6-9]00$')]" mode="css:map-att-to-elt" as="xs:string?" priority="10"/>

  <xsl:template match="@css:*" mode="clean-up" priority="10">
    <!--discard style attributes for better readabilty. (only metadata required anyhow) -->
  </xsl:template>

  <xsl:template match="textClass" mode="tei2bits">
    <xsl:apply-templates select="node() except keywords[matches(@corresp, '^#\p{L}')]" mode="#current"/>
  </xsl:template>

  <xsl:template match="keywords[@rendition = 'chunk-meta']" mode="tei2bits">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="keywords[@rendition = ('titlepage', 'custom-meta')]" mode="tei2bits"/>

  <xsl:template match="keywords[@rendition = 'chunk-meta']/term[@key='chunk-doi']" mode="tei2bits">
    <book-part-id book-part-id-type="doi"><xsl:apply-templates select="node()" mode="#current"/></book-part-id>
  </xsl:template>

  <xsl:template match="keywords[not(@rendition = ('titlepage', 'docProps'))]/@rendition" mode="tei2bits">
    <xsl:attribute name="kwd-group-type" select="'auhor-generated'"/>
    <!-- https://redmine.le-tex.de/issues/12464 -->
  </xsl:template>

  <xsl:template match="sec/@sec-type[. = 'keywords']" mode="clean-up" priority="5">
    <!-- needed only as metadata-->
  </xsl:template>

  <xsl:template match="divGen[@type = 'toc']" mode="tei2bits" priority="2">
    <front-matter-part book-part-type="toc">
      <xsl:call-template name="named-book-part-meta"/>
      <named-book-part-body>
        <xsl:apply-templates select="@*, node() except head" mode="#current"/>
      </named-book-part-body>
    </front-matter-part>
  </xsl:template>

</xsl:stylesheet>