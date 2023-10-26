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

  <xsl:variable name="tei2bits:alt-title-regex" as="xs:string" select="'tsheadline(left|right|author)?$'"/>

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


  <xsl:template match="*:body[.//*:sec/*:ref-list]" mode="clean-up" priority="3">
    <xsl:next-match>
      <xsl:with-param name="move-refs-to-back" as="xs:boolean" select="false()" tunnel="yes"/>
    </xsl:next-match>
      <xsl:element name="back">
        <xsl:apply-templates select="(.//*:sec/*:ref-list | .//*:sec/*[preceding-sibling::*:ref-list])" mode="#current">
          <xsl:with-param name="move-refs-to-back" as="xs:boolean" select="true()" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
  </xsl:template>

  <xsl:template match="*:body/*:sec/*:ref-list | *:body/*:sec/*[preceding-sibling::*:ref-list]" mode="clean-up" priority="5">
    <xsl:param name="move-refs-to-back" as="xs:boolean" tunnel="yes"/>
    <xsl:if test="$move-refs-to-back">
      <xsl:next-match/>
    </xsl:if>
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

  <xsl:template match="keywords/term/seg | keywords/term/seg/seg" mode="tei2bits">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="publicationStmt" mode="tei2bits">
    <publisher>
      <publisher-name><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsname']) then $metadata/term[@key eq 'Verlagsname'] else 'transcript Verlag'"/></publisher-name>
      <publisher-loc><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsort']) then $metadata/term[@key eq 'Verlagsort'] else 'Bielefeld'"/></publisher-loc>
    </publisher>
    <!--<xsl:if test="date or publisher or $metadata/term[@key = 'Copyright'][normalize-space()] or $metadata/term[@key = 'Lizenz'][normalize-space()]">-->
      <xsl:variable name="copyright" select="if ($metadata/term[@key = 'Copyright'][normalize-space()]) 
                                             then $metadata/term[@key = 'Copyright']/node()[normalize-space()]
                                             else ()" as="node()*"/>
      <permissions>
        <xsl:choose>
          <xsl:when test="$copyright[normalize-space()]">
            <xsl:for-each select="$copyright/node()[normalize-space()]">
              <copyright-statement><xsl:apply-templates select="." mode="#current"/></copyright-statement>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise><copyright-statement><xsl:value-of select="concat('© ', format-date(current-date(), '[Y]'), ' transcript Verlag')"/></copyright-statement></xsl:otherwise>
        </xsl:choose>
        <!--<copyright-statement><xsl:value-of select="($copyright, concat('© ', format-date(current-date(), '[Y]'), ' transcript Verlag'))[1]"/></copyright-statement>-->
        <copyright-year><xsl:value-of select="if ($metadata/term[@key eq 'Jahr'][normalize-space()]) 
                                              then $metadata/term[@key eq 'Jahr'] 
                                              else 
                                                if ($copyright[normalize-space()]) 
                                                then (replace(string-join($copyright, ''), '^.+?(\d{4}).*$', '$1', 's')) 
                                                else format-date(current-date(), '[Y]')"/></copyright-year>
        <copyright-holder><xsl:value-of select="if ($metadata/term[@key eq 'Verlagsname'][normalize-space()]) 
                                                then $metadata/term[@key eq 'Verlagsname'] 
                                                else 
                                                  if ($copyright[normalize-space()]) 
                                                  then replace(string-join($copyright/node()[normalize-space()], ''), '^.*©\p{Zs}*(\d{4}\p{Zs}*)?(.+)$', '$2', 's') 
                                                  else 'transcript Verlag'"/>
        </copyright-holder>
        <xsl:if test="$metadata/term[@key eq 'Lizenz'][normalize-space()]">
          <license>
            <xsl:if test="$metadata/term[@key eq 'Lizenz'][normalize-space()]">
              <xsl:attribute name="license-type" select="'open-access'"/>
              <xsl:attribute name="specific-use" select="'rights-object-archive-dnb'"/>
            </xsl:if>
            <xsl:if test="$metadata/term[@key eq 'Lizenzlink'][normalize-space()]">
              <xsl:attribute name="xlink:href" select="string-join($metadata/term[@key eq 'Lizenzlink']/node()[normalize-space()], '')"></xsl:attribute>
            </xsl:if>
            <xsl:if test="$metadata/term[@key eq 'Lizenztext'][normalize-space()]">
              <xsl:for-each select="$metadata/term[@key eq 'Lizenztext']/node()[normalize-space()]">
                <license-p>
                  <xsl:apply-templates select="." mode="#current"/>
                </license-p>
              </xsl:for-each>
            </xsl:if>
          </license>
        </xsl:if>
      </permissions>
    <!--</xsl:if>-->
  </xsl:template>

  <xsl:variable name="book-part-chapters" select="/*:book/*[self::*:book-body|*:book-back]//*:book-part[not(@book-part-type = 'part')]"/>
<!--  <xsl:variable name="book-part-parts" select="/*:book/*[self::*:book-body|*:book-back]//*:book-part[@book-part-type = 'part']"/>-->

  <xsl:template match="*[local-name() = ('title-group', 'book-title-group')]
                        [parent::*[local-name() = ('book-part-meta', 'book-meta')]]" mode="clean-up" priority="3">
    <!-- move abstract title or alt title to title group -->
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

  <xsl:template match="*:front-matter-part[@book-part-type='title-page']/*:named-book-part-body |
                       *:front-matter-part[@book-part-type='toc'][empty(*:book-part-meta)]/*:named-book-part-body" mode="clean-up" priority="2">
    <book-part-meta>
      <book-part-id book-part-id-type="doi">
        <xsl:value-of select="concat(/*:book/*:book-meta/*:book-id[@book-id-type ='doi'][1], if (@book-part-type='toc') then '-toc' else '-fm')"/>
      </book-part-id>
      <xsl:call-template name="page-range"/>
      <xsl:call-template name="page-count"/>
    </book-part-meta>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="*:front-matter-part[@book-part-type='toc']/*:book-part-meta[empty(*:book-part-id[@book-part-id-type = 'doi'])]" mode="clean-up" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <book-part-id book-part-id-type="doi">
        <xsl:value-of select="concat(/*:book/*:book-meta/*:book-id[@book-id-type ='doi'][1], '-toc')"/>
      </book-part-id>
      <xsl:call-template name="page-range"/>
      <xsl:call-template name="page-count"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:book-part-meta" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:call-template name="permissions"/>
      <xsl:call-template name="page-range"/>
      <xsl:call-template name="page-count"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*:book-meta" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:call-template name="page-count"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="permissions">
    <xsl:if test="empty(*:permissions) and not(..[@book-part-type=('toc', 'fm', 'title-page')])">
      <xsl:apply-templates select="/*:book/*:book-meta/*:permissions" mode="#current"/>
    </xsl:if>
  </xsl:template> 

  <xsl:template name="page-count">
    <xsl:if test="empty(*:counts)">
      <counts>
        <page-count count=""/>
      </counts>
    </xsl:if>
  </xsl:template> 

  <xsl:template name="page-range">
    <xsl:if test="empty(*:fpage)">
      <fpage></fpage>
      <lpage></lpage>
    </xsl:if>
  </xsl:template>

  <xsl:template match="titleStmt" mode="tei2bits">

<!--    <xsl:if test="$metadata/term[@key = 'DOI'][normalize-space()]">
      <book-id book-id-type="doi"><xsl:value-of select="$metadata/term[@key = 'DOI'][normalize-space()]"/></book-id>
    </xsl:if>-->

    <contrib-group>
      <xsl:for-each select="if ($metadata/term[@key = ('Autor', 'Herausgeber')][count(seg[@type='remap-para']) gt 1])
                            then $metadata/term[@key = ('Autor', 'Herausgeber')]/seg[@type='remap-para']
                            else $metadata/term[@key = ('Autor', 'Herausgeber')][normalize-space()]">
        <contrib contrib-type="{if (.[@key = 'Autor'] or ..[@key = 'Autor']) then 'author' else 'editor'}">
          <string-name><xsl:apply-templates select="node()" mode="#current"/></string-name>
        </contrib>
      </xsl:for-each>
    </contrib-group>

    <xsl:if test="title[@type = 'title'][normalize-space()] or $metadata/term[@key = 'Titel'][normalize-space()] or ../seriesStmt[title[normalize-space()]]">
      <book-title-group>
        <book-title>
          <xsl:apply-templates select="title[@type = 'main']/@*" mode="#current"/>
          <xsl:value-of select="($metadata/term[@key = 'Titel'][normalize-space()], title[@type = 'main'], ../seriesStmt/title)[1]"/>
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

  <xsl:template match="keywords[@rendition = 'chunk-meta']/term[@key='chunk-doi']" mode="tei2bits" priority="2">
    <book-part-id book-part-id-type="doi"><xsl:apply-templates select="node()" mode="#current"/></book-part-id>
  </xsl:template>

  <xsl:template match="keywords[not(@rendition = ('titlepage', 'docProps'))]/@rendition" mode="tei2bits" priority="3">
    <title><xsl:value-of select="."/></title>
    <!--<xsl:attribute name="kwd-group-type" select="'author-generated'"/>-->
    <!-- https://redmine.le-tex.de/issues/12464 -->
  </xsl:template>

  <xsl:template match="*:sec[@sec-type = ('keywords', 'alternative-title')]" mode="clean-up" priority="7">
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

  <xsl:template match="@source-dir-uri | @kwd-group-type" mode="clean-up"/>

  <xsl:function name="tr:determine-link-type" as="attribute(ext-link-type)?">
    <xsl:param name="target" as="xs:string"/>
    <!-- https://redmine.le-tex.de/issues/12756 -->
    <xsl:variable name="type">
      <xsl:choose>
      <xsl:when test="matches($target, 'doi\.')"><xsl:value-of select="'doi'"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="'uri'"/></xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="ext-link-type" select="$type"/>
  </xsl:function>

  <xsl:template match="note/@xml:id" mode="tei2bits" priority="5">
    <!--http://www.wiki.degruyter.de/production/files/dg_xml_guidelines.xhtml#footnotes
      https://redmine.le-tex.de/issues/12757-->
    <xsl:next-match/>
    <xsl:attribute name="symbol" select="if (..[@n]) 
                                         then normalize-space(../@n) 
                                         else normalize-space(../p[1]/label[1])"/>
  </xsl:template>

  <xsl:template match="note[@type = 'endnote']/@type" mode="tei2bits" priority="3">
    <!--http://www.wiki.degruyter.de/production/files/dg_xml_guidelines.xhtml#footnotes -->
    <xsl:attribute name="fn-type" select="."/>
  </xsl:template>

  <xsl:template match="note/@n | note/p[1]/label[1]" mode="tei2bits" priority="2"/>

  <xsl:template match="table" mode="tei2bits" priority="2">
    <!-- move @id from tab to table-wrap-->
    <table-wrap>
      <xsl:apply-templates select="@xml:id" mode="#current"/>
      <xsl:attribute name="position" select="if ((every $e in * satisfies $e[self::*:thead|self::*:tbody|self::*:tfoot|self::*:colgroup])
                                                  and 
                                                  not(preceding-sibling::*[1][matches(., ':\p{Zs}*$')])) then 'float' else 'anchor'"/>
      <xsl:if test="head or note">
        <caption>
          <xsl:apply-templates select="head, note" mode="#current"/>
        </caption>
      </xsl:if>
      <table>
        <xsl:apply-templates select="@* except (@rend, @rendition, @xml:id)" mode="#current"/>
        <xsl:apply-templates select="@rendition" mode="#current"/>
        <xsl:apply-templates select="node() except (head, note, postscript)" mode="#current"/>
      </table>
      <xsl:apply-templates select="postscript" mode="#current"/>
    </table-wrap>
  </xsl:template>

  <xsl:template match="*:caption/*:title/*:label[matches(., '[:\.–]\p{Zs}*$')]/text()" priority="5" mode="clean-up">
    <!--https://redmine.le-tex.de/issues/12770-->
    <xsl:value-of select="replace(., '\p{Zs}*[:\.–]\p{Zs}*$', '')"/>
  </xsl:template> 

  <xsl:template match="*:book-part[@book-part-type='chapter']" priority="5" mode="clean-up">
    <!--https://redmine.le-tex.de/issues/12762-->
    <xsl:next-match>
    <xsl:with-param name="book-part-id" select="replace(*:book-part-meta/*:book-part-id[@book-part-id-type='doi'], '^.+/', '')" as="xs:string" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template> 

  <xsl:template match="*:fn/@id | *:fig/@id | *:table-wrap/@id | *:boxed-text/@id | *:sec/@id | *:book-part[not(@book-part-type='part')]/@id |*:ref/@id" mode="clean-up" priority="2">
    <xsl:param name="book-part-id" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="type" as="xs:string?" select="if (..[self::*:fn|self::*:fig|self::*:boxed-tex|self::*:table-wrap]) 
                                                     then substring(local-name(..), 1, 3) 
                                                     (:else if (..[self::*:boxed-tex|self::*:table-wrap]) then 'box':)
                                                     else ()" />
    <xsl:variable name="normalized-id" select="if (..[self::*:book-part[@book-part-type='chapter']]) 
                                               then () 
                                               else if (..[self::*:sec])
                                                    then string-join((for $s in ancestor-or-self::*:sec return concat('s_', xs:string(format-number((count($s/preceding-sibling::*:sec) + 1), '000')))),'_')
                                                    else format-number(xs:integer(replace(., '^\p{L}+|-', '')), '000')" as="xs:string?"/>
    <!--https://redmine.le-tex.de/issues/12762, http://www.wiki.degruyter.de/production/files/dg_variables_and_id.xhtml#ids-->
    <xsl:attribute name="{name()}" select="string-join(('b', $book-part-id, $type, $normalized-id), '_')"/>
   <!-- boxes not yet checked -->
  </xsl:template>

  <xsl:template match="*:ref[key('by-id', @xlink:href)
                                 [self::*:fn|self::*:fig|self::*:sec|self::*:boxed-tex|self::*:table-wrap|self::*:book-part[not(@book-part-type='part')]]]/@xlink:href" mode="clean-up" priority="2">
    <!--perhaps create crossref like <xref ref-type="fig"-->
    <xsl:variable name="new-target" as="attribute(id)">
      <xsl:apply-templates select="key('by-id',.)[1]/@id" mode="#current"/>
    </xsl:variable>
    <xsl:attribute name="{name()}" select="$new-target"/>
  </xsl:template> 

  <xsl:template match="*:fig/@fig-type" mode="clean-up" priority="3">
    <!--http://www.wiki.degruyter.de/production/files/dg_xml_guidelines.xhtml#images-media-files -->
    <xsl:attribute name="{name()}" select="'figure'"/>
    <!-- https://redmine.le-tex.de/issues/12771 -->
    <xsl:attribute name="position" select="if ((every $e in ../* satisfies $e[self::*:graphic])
                                                and 
                                                not(../preceding-sibling::*[1][matches(., ':\p{Zs}*$')])) then 'float' else 'anchor'"/>
  </xsl:template>

  <xsl:template match="hi[matches(@rend, 'italic|(^|\s)em($|\s)|strong|bold|underline|line-?through|superscript|subscript')]" mode="tei2bits" priority="5">
    <xsl:apply-templates select="." mode="create-style-elts"/>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'subscript')]" mode="create-style-elts" priority="7">
    <sub><xsl:next-match/></sub>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'superscript')]" mode="create-style-elts"  priority="6">
    <sup><xsl:next-match/></sup>
  </xsl:template>

  <xsl:template match="hi[tr:contains-token(@rend, ('italic', 'em'))]" mode="create-style-elts"  priority="5">
    <italic><xsl:next-match/></italic>
  </xsl:template>

  <xsl:template match="hi[tr:contains-token(@rend, ('bold', 'strong'))]" mode="create-style-elts"  priority="4">
    <bold><xsl:next-match/></bold>
  </xsl:template>

  <xsl:template match="hi[matches(@rend, 'line-?through')]" mode="create-style-elts"  priority="2">
    <strike><xsl:next-match/></strike>
  </xsl:template>

  <xsl:template match="hi[contains(@rend, 'underline')]" mode="create-style-elts"  priority="2">
    <underline><xsl:next-match/></underline>
  </xsl:template>

  <xsl:template match="hi[tr:contains-token(@rend, ('italic', 'em', 'bold', 'strong', 'underline', 'superscript', 'subscript'))]" mode="create-style-elts" priority="1">
    <xsl:apply-templates select="@* except @rend" mode="tei2bits"/>
    <xsl:if test="some $t in tokenize(@rend, '\s') satisfies $t[not(. = ('italic', 'em', 'bold', 'strong', 'underline', 'superscript','subscript', 'line-through'))]">
      <xsl:attribute name="class" select="normalize-space(replace(@rend, '(italic|em|bold|strong|underline|superscript|subscript|line-through)\s?', ''))"/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="tei2bits"/>
  </xsl:template>

 <xsl:template match="hi[tr:contains-token(@rend, ('italic', 'em', 'bold', 'strong', 'underline', 'superscript', 'subscript', 'line-through'))]/@*[name() = ('css:font-weight', 'css:font-style', 'css:text-decoration', 'css:vertical-align')]" mode="tei2bits"/>

  <xsl:function name="tr:contains-token" as="xs:boolean">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:param name="tokens" as="xs:string*"/>
    <xsl:sequence select="if ($string) then tokenize($string, '\s+') = $tokens else false()"/>
  </xsl:function>

</xsl:stylesheet>