<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  

  <xsl:import href="licenses.xsl"/>

  <xsl:param name="basename" as="xs:string"/>
  <xsl:variable name="lang" select="     if (//*:product_export/(*:product[*:edition_type = 'EBP'], *:product)[1]/*:language[@seq_no='1'][matches(., 'ENGL', 'i')]) then 'E' 
                                    else if (//*:product_export/(*:product[*:edition_type = 'EBP'], *:product)[1]/*:language[@seq_no='1'][matches(., 'SPA', 'i')]) then 'S' else ''" as="xs:string?">
    <!-- https://redmine.le-tex.de/issues/16459#note-7, https://redmine.le-tex.de/issues/17587 -->
  </xsl:variable>
  <xsl:variable name="open-access" as="xs:boolean" select="exists(//*:product_export/(*:product[*:edition_type = 'EBP'], *:product)[1]/*:open_access[@open_access_yn = 'Y'])"/>
    
  <xsl:template match="*"  mode="klopotek-to-keyword" priority="-0.5"/>
  
  <xsl:template match="*:doi"  mode="klopotek-to-keyword"  priority="2">
    <keyword role="{css:map-klopotek-to-keyword(name())}">
      <xsl:value-of select="if (not(contains(., 'http'))) then concat('https://doi.org/',.) else ."/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:title | *:subtitle | *:serial_title"  mode="klopotek-to-keyword"  priority="2">
    <keyword role="{css:map-klopotek-to-keyword(name())}">
      <xsl:apply-templates select="node()" mode="#current"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:open_access"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="all-products" as="element()+" tunnel="yes"/>
    <!-- https://redmine.le-tex.de/issues/16949-->
    <xsl:if test="$open-access">
      <xsl:variable name="license-type" select="string-join(tokenize(($all-products[not(*:edition_type = ('EBE', 'PBK'))][*:open_access/@open_access_yn='Y'])[1]/*:open_access/*:cc_license_type/@term, '\P{Lu}')[not(. = 'CC')], '-')"/>
        <xsl:message select="'### license: ', $license-type"/>
      <keyword role="Lizenz">
        <xsl:value-of select="$license-type" />
      </keyword>
      <xsl:apply-templates select="$license-texts/*:License[@id = $license-type]" mode="#current">
        <xsl:with-param name="license-lang" 
                      select=" if (//*:product_export/*:product/*:language[@seq_no='1'][matches(., 'ENGL', 'i')]) then 'en' 
                          else if (//*:product_export/*:product/*:language[@seq_no='1'][matches(., 'SPA', 'i')]) then 'es' else 'de'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*:License"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16949-->
    <xsl:apply-templates select="*:Image | *:Link | *:Texts" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:License/*:Texts"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="license-lang" tunnel="yes" as="xs:string"/>
    <!-- https://redmine.le-tex.de/issues/16949-->
    <keyword role="Lizenztext">
      <xsl:apply-templates select="*:Text[@lang = $license-lang]" mode="#current"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:License/*:Texts/*:Text"  mode="klopotek-to-keyword"  priority="2">
    <xsl:choose>
      <xsl:when test="*:br"><!-- single paras from br -->   
        <xsl:for-each-group select="node()[.]" group-ending-with="self::*:br">
          <para><xsl:apply-templates select="current-group()" mode="#current"/></para>
        </xsl:for-each-group>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*:License/*:Texts/*:Text/text()"  mode="klopotek-to-keyword"  priority="2">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="*:License/*:Image"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="license-lang" tunnel="yes" as="xs:string"/>
    <!-- https://redmine.le-tex.de/issues/16949-->
    <keyword role="Lizenzlogo">
      <xsl:value-of select="@url"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:License/*:Link"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="license-lang" tunnel="yes" as="xs:string"/>
    <!-- https://redmine.le-tex.de/issues/16949-->
    <keyword role="Lizenzlink">
      <xsl:value-of select="@url"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:isbn[normalize-space()]"  mode="klopotek-to-keyword"  priority="3">
    <xsl:param name="already-added-static" as="xs:boolean?"/>
    <xsl:param name="all-products" as="element()*" tunnel="yes"/>
    <xsl:param name="main-product-type" as="xs:string" tunnel="yes"/>
    <xsl:message select="'### main-product: ', $main-product-type"/>
    <!-- if not EBP, process doi of EBP--> 
    <xsl:if test="not($main-product-type = 'EBP') and not($already-added-static) and not(//*:product_export/*:product[*:edition_type = $main-product-type][*:doi])" >
      <xsl:apply-templates select="$all-products//*:doi[../*:edition_type = 'EBP']" mode="#current"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="../*:edition_type[.=('PBK', 'HC')]">
        <keyword role="Print-ISBN">
          <xsl:value-of select="concat('Print-ISBN: ', .)"/>
        </keyword>
      </xsl:when>
      <xsl:when test="../*:edition_type[.='EBP']">
         <!-- create Cover from Print ISBN -->
        <keyword role="Cover"><xsl:value-of select="concat(translate(., '-', ''), '.jpg')"/></keyword>
        <keyword role="PDF-ISBN">
          <xsl:value-of select="concat('PDF-ISBN: ', .)"/>
        </keyword>
      </xsl:when>
      <xsl:when test="../*:edition_type[.='EBE']">
        <keyword role="ePUB-ISBN">
          <xsl:value-of select="concat('ePUB-ISBN: ', .)"/>
        </keyword>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="../*:parallel_versions/*:ref/*:isbn" mode="#current">
      <xsl:with-param name="already-added-static" select="true()" as="xs:boolean"/>
    </xsl:apply-templates>
   <xsl:if test="not($already-added-static)"><xsl:call-template name="add-static-keywords"/></xsl:if>
  </xsl:template>
  
  <xsl:template match="*:memo|*:content"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="all-products" as="element()*" tunnel="yes"/>
    <xsl:param name="processed-main-edition" select="false()" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="main-product-type" as="xs:string" tunnel="yes"/>
    <!-- https://redmine.le-tex.de/issues/17443-->
    <xsl:apply-templates select="*:text[@term]" mode="#current"/>
    <xsl:if test="not($main-product-type = 'EBP') and not($processed-main-edition)" >
      <xsl:apply-templates select="$all-products[not(*:edition_type = $main-product-type)]//(*:memo|*:content)" mode="#current">
        <xsl:with-param name="processed-main-edition" select="true()" as="xs:boolean" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
 
    <xsl:template name="add-static-keywords">
      <!--https://redmine.le-tex.de/issues/16798, https://redmine.le-tex.de/issues/16800-->
      <keyword role="Papier">
        <xsl:value-of select="if ($lang = 'E') 
                                                   then 'Printed on permanent acid-free text paper.'
                                                   else 'Gedruckt auf alterungsbeständigem Papier mit chlorfrei gebleichtem Zellstoff.'"/>
      </keyword>
      <keyword role="Bibliografische_Information">
        <xsl:choose>  
          <xsl:when test="$lang = 'E'">
            <para>Bibliographic information published by the Deutsche Nationalbibliothek</para>
            <para>The Deutsche Nationalbibliothek lists this publication in the Deutsche Nationalbibliografie; detailed bibliographic data are available in the Internet at <link xlink:href="https://dnb.dnb.de">https://dnb.dnb.de</link></para>
          </xsl:when>
          <xsl:otherwise>
            <para>Bibliografische Information der Deutschen Nationalbibliothek</para>
            <para>Die Deutsche Nationalbibliothek verzeichnet diese Publikation in der Deutschen Nationalbibliografie; detaillierte bibliografische Daten sind im Internet über <link xlink:href="https://dnb.dnb.de/">https://dnb.dnb.de/</link> abrufbar.</para>
          </xsl:otherwise>
        </xsl:choose>
      </keyword>
    </xsl:template>

  <xsl:function name="css:map-klopotek-to-keyword" as="xs:string">
    <xsl:param name="role" as="xs:string"/>
    <xsl:variable name="klopotek-roles" as="map(xs:string, xs:string)"
                  select="map{ 
                              'doi':'DOI',
                              'language':'Sprache',
                              'shorttitle':'Kurztitel',    
                              'title':'Titel',
                              'subtitle':'Untertitel',
                              'catchwords':'Schlagworte',
                              'serial_title':'Reihe'
                              }"/>
    <xsl:value-of select="map:get($klopotek-roles, $role)"/>
  </xsl:function>


  
  <xsl:template match="*:original_publication"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16471-->
    <keyword role="Copyright">
      <para><xsl:sequence select="*:copyright_remark/node()"/></para>
      <xsl:choose>
        <xsl:when test="$open-access">
          <!-- Open Access-->
         <para>
           <xsl:call-template name="join-copyright-statement">
              <xsl:with-param name="context" select="../*:copyright_holders" tunnel="yes" as="element()"/>
           </xsl:call-template>
         </para>
        </xsl:when>
        <xsl:otherwise><!--default not OA-->
          <xsl:choose>
            <xsl:when test="$lang = 'E'">
              <para>All rights reserved. No part of this book may be reprinted or reproduced or utilized in any form or by any electronic, mechanical, or other means, now known or hereafter invented, including photocopying and recording, or in any information storage or retrieval system, without permission in writing from the publisher.</para>
            </xsl:when>
            <xsl:otherwise>
              <para>Alle Rechte vorbehalten. Die Verwertung der Texte und Bilder ist ohne Zustimmung des Verlages urheberrechtswidrig und strafbar. Das gilt auch für Vervielfältigungen, Übersetzungen, Mikroverfilmungen und für die Verarbeitung mit elektronischen Systemen.</para>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </keyword>
  </xsl:template>
  
  <xsl:template name="join-copyright-statement">
    <xsl:param name="context" tunnel="yes" as="element()"/>
    <xsl:choose>
      <xsl:when test="contains($basename, '_anth_')">
        <xsl:value-of select="concat('© ', 
                                    string-join(for $ch in $context/*:copyright_holder[*:cpr_type = 'HG'] 
                                                return concat($ch/*:first_name, ' ', $ch/*:last_name), ', '),
                                    if ($lang = 'E') then ' (ed.)' else ' (Hg.)'
          )"/>
      </xsl:when>
      <xsl:when test="contains($basename, '_mono_')">
        <xsl:value-of select="concat('© ', 
                                      string-join(for $ch in $context/*:copyright_holder[*:cpr_type = 'VE'] 
                                                  return concat($ch/*:first_name, ' ', $ch/*:last_name), ', ')
                                      )"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:variable name="copyright-roles-lookup" as="map(xs:string, xs:string+)"
                  select="map{'VE':  ('Autor',          '',                  '',             ''),
                              'HG':  ('Herausgeber',    '',                  '',             ''),
                              'UMSA':('Umschlagcredit', 'Umschlagabbildung', 'Cover illustration', 'Ilustración de portada'),
                              'LEKT':('Lektorat',       'Lektorat',          'Proofreading', 'Revisión'),
                              'KORR':('Korrektorat',    'Korrektorat',       'Correction',   'Corrección'),
                              'LAYO':('Satz',           'Satz',              'Typesetting',  'Composición tipográfica'),
                              'DRUK':('Druck',          'Druck',             'Printing',     'Imprenta'),
                              'OAEN':('Fordertext_OA',  'Open-Access-Ausgabe mit freundlicher Förderung von',   '',     ''),
                              'SPONSOR':('Fordertext_Series',  'Förderung der Reihe von',             '',     ''),
                              'ENAB':('Fordertext',     'Die Publikation entstand mit freundlicher Förderung von',    '',     ''),
                              'PENA':('Fordertext_Print',     'Print-Ausgabe mit freundlicher Förderung von',   '',     '')
                  }">
     <!--                             1: Keyname,        2: added info German, 3: English 4 Spanish (https://redmine.le-tex.de/issues/16459)-->
   </xsl:variable>
                  
                  
  <xsl:variable name="copyright-roles"  as="xs:string+" 
              select="('VE', 'HG', 'UMSA', 'LEKT', 'KORR', 'LAYO', 'DRUK')"/>

  <xsl:template match="*:copyright_holders | *:funders"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="all-products" as="element()+" tunnel="yes"/>
    <xsl:param name="main-product-type" as="xs:string" tunnel="yes"/>
    <xsl:param name="logo-listing" as="element(c:directory)?" tunnel="yes"/>
    <!-- https://redmine.le-tex.de/issues/16437, https://redmine.le-tex.de/issues/17515 -->
    <xsl:variable name="lang-num" select="if ($lang = 'E') then 3 else
                                          if ($lang = 'S') then 4 else 2" as="xs:integer"/>
   
    <xsl:if test="../*:edition_type[. = 'EBP']  or count($all-products) = 1">  
      <xsl:for-each-group select="*:copyright_holder|*:funder" group-by="*:cpr_type">
         
          <xsl:variable name="type" select="current-grouping-key()"/>
          <xsl:variable name="cg" as="element()*">
             <xsl:perform-sort select="current-group()" >
               <xsl:sort select="*:cpr_type/@seq_no" order="ascending" data-type="number"/>
             </xsl:perform-sort> 
          </xsl:variable>
          <xsl:variable name="current-lookup"  select="map:get($copyright-roles-lookup, $type)" as="xs:string+"/>
          <xsl:choose>
            <xsl:when test="$type[. =  $copyright-roles] 
                            and
                            (not($type = 'UMSA') or empty($all-products//*:memo/*:text[@term = 'Umschlagabb./Copyright Vermerk']))">
              <keyword role="{$current-lookup[1]}">      
                <xsl:choose>
                  <xsl:when test="count($cg) gt 1">
                    <xsl:for-each select="$cg">
                      <para>
                        <xsl:sequence select="string-join(
                                                          ($current-lookup[$lang-num][normalize-space()], 
                                                           string-join((*:first_name[normalize-space()], *:last_name[normalize-space()]), ' ')
                                                          ), 
                                                          ': '
                                                          )"/>
                      </para>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                        <xsl:sequence select="string-join(
                                                          ($current-lookup[$lang-num][normalize-space()], 
                                                           string-join((*:first_name[normalize-space()], *:last_name[normalize-space()]), ' ')
                                                          ), 
                                                          ': '
                                                          )"/>
                  </xsl:otherwise>
                </xsl:choose>
              </keyword>
            </xsl:when>
             <xsl:when test="$type =  ('OAEN', 'SPONSOR', 'ENAB', 'PENA')">
               <!-- Sponsoring/funding-->
               
               <!-- pretext --> 
               <keyword role="{$current-lookup[1]}">
                 <xsl:value-of select="string-join((($cg[1]/*:pretext[normalize-space()]/replace(text(), ':$', ''), $current-lookup[$lang-num][normalize-space()])[1], ' '), ':')"/>
               </keyword>
              <xsl:for-each select="$cg">
                <xsl:variable name="current-copyright" select="."/>
                <!-- funder name-->
                <keyword role="Fordername"><xsl:value-of select="string-join(
                                                          ( 
                                                           string-join((*:first_name[normalize-space()], *:last_name[normalize-space()]), ' ')
                                                          ), 
                                                          ': '
                                                          )"/></keyword>
                <!-- funding-logo -->
                <!-- add language to logo for searching, fallback is english and german (= no suffix) https://redmine.le-tex.de/issues/17501 -->
               <xsl:if test="some $l in $logo-listing/c:file satisfies $l[starts-with(@name, $current-copyright/@unique_person_id)]">
                 <xsl:variable name="lang-codes" select="( replace(concat('_', lower-case(//*:product_export/(*:product[*:edition_type = 'EBP'], *:product)[1]/*:language[@seq_no='1']), '$'), '_ger\$', '^\\d+-[^_]+\$'),
                                                          '_engl$', 
                                                          '^\d+-[^_]+$')" as="xs:string+"/>
    
                 <xsl:variable name="logo-filenames" as="document-node()">
                   <xsl:document>
                     <xsl:for-each select="$lang-codes">
                       <xsl:sequence select="$logo-listing/c:file[starts-with(@name, $current-copyright/@unique_person_id)][matches(@name, current())]"/>
                     </xsl:for-each>
                   </xsl:document>
                 </xsl:variable>
                 <!--<xsl:message select="'-\-\-', string-join(@unique_person_id, ''), $lang, '//', string-join($logo-listing//c:file[starts-with(@name, current()/@unique_person_id)]/@name), '##', $logo-filenames "/>-->
                 <keyword role="Forderlogos"><xsl:value-of select="$logo-filenames/*[1]/@name"/></keyword>
               </xsl:if>
              </xsl:for-each>   
          </xsl:when>
          </xsl:choose>
        </xsl:for-each-group>
    
        <xsl:if test="*:copyright_holder[*:cpr_type = ('HG', 'VE')]/text[@text_type = concat('AUTBIO', $lang)][normalize-space()]">
          <keyword role="{if (*:copyright_holder[*:cpr_type  = 'HG'][text[@text_type = concat('AUTBIO', $lang)][normalize-space()]]) then 'Herausgeberinformationen' else 'Autoreninformationen'}">
            
            <!--Herausgeberinformationen https://redmine.le-tex.de/issues/16479-->
            
            <xsl:choose>
              <xsl:when test="count(*:copyright_holder[*:cpr_type = ('HG', 'VE')]/text[@text_type = concat('AUTBIO', $lang)][normalize-space()]) gt 1">
                <xsl:for-each select="*:copyright_holder[*:cpr_type = ('HG', 'VE')]/text[@text_type = concat('AUTBIO', $lang)]">
                  <para>
                   <!-- <xsl:sequence select="concat(./../*:first_name, ' ', ./../*:last_name, ' ')"/>-->
                    <xsl:sequence select="html:process-html(., false())" />
                  </para>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <!--<xsl:sequence select="concat(./../*:first_name, ' ', ./../*:last_name, ' ')"/>-->
                <xsl:sequence select="html:process-html(*:copyright_holder[*:cpr_type = ('HG', 'VE')]/text[@text_type = concat('AUTBIO', $lang)], false())" />
              </xsl:otherwise>
            </xsl:choose>
          </keyword>
        </xsl:if>
    </xsl:if>
    <!-- when print product: also apply epb-->
    <xsl:if test="../*:edition_type[. = $main-product-type][not(.  = 'EBP')] and self::*:copyright_holders">
       <xsl:apply-templates select="$all-products[*:edition_type =  'EBP']/(*:copyright_holders|*:funders)" mode="#current"/>
    </xsl:if>
    <xsl:if test="../*:edition_type[. = $main-product-type] and not(exists(..[*:original_publication])) and self::*:copyright_holders">
      <!--https://redmine.le-tex.de/issues/17513-->
      <keyword role="Copyright">
        <xsl:call-template name="join-copyright-statement">
          <xsl:with-param name="context" select="if ($all-products[*:edition_type =  'EBP']/*:copyright_holders) then $all-products[*:edition_type =  'EBP']/*:copyright_holders else ." tunnel="yes" as="element()"/>
        </xsl:call-template>
      </keyword>
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="html:process-html" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="preserve-paras" as="xs:boolean"/>
    
    <xsl:if test="$context[normalize-space()]">
      
      <xsl:variable name="parsed" as="document-node(element(div))" 
        select="parse-xml('&lt;div>' || $context || '&lt;/div>')"/>
      
      <xsl:variable name="postprocessed" as="node()*">
        <xsl:apply-templates select="$parsed/*:div/node()" mode="postprocess-html">
          <xsl:with-param name="preserve-paras" select="$preserve-paras" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:apply-templates select="$postprocessed" mode="strip-namespaces"/>
    </xsl:if>
  </xsl:function>
  
    
  <xsl:template match="@* | node()" mode="strip-namespaces postprocess-html" priority="-0.25">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
<!--  <xsl:template match="*" mode="strip-namespaces" priority="2">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@* except @xmlns, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>-->
  
  <xsl:template match="*:b|*:strong" mode="postprocess-html" priority="4">
    <xsl:element name="phrase">
      <xsl:attribute name="css:font-weight" select="'bold'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:p" mode="postprocess-html" priority="3">
    <xsl:param name="preserve-paras" as="xs:boolean?" tunnel="yes" select="false()"/>
    <xsl:choose>
      <xsl:when test="not($preserve-paras)">
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="para">
          <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="strip-namespaces" priority="2" exclude-result-prefixes="#all">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@* except @xmlns, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:serial_relation"  mode="klopotek-to-keyword"  priority="2">
    <xsl:param name="all-products" as="element()+" tunnel="yes"/>
    <xsl:param name="main-product-type" as="xs:string" tunnel="yes"/>
    <xsl:param name="main-product-processed" as="xs:boolean?" select="false()" tunnel="yes"/>
    <!-- https://redmine.le-tex.de/issues/16437, https://redmine.le-tex.de/issues/17519 -->
    <xsl:apply-templates select="node()" mode="#current"/>
    <!-- will vol_number etc. be in every edition?-->
<!--     <xsl:if test="not($main-product-type = 'EBP') and not($main-product-processed)" >
      <xsl:apply-templates select="$all-products//*:serial_relation/*:vol_no" mode="#current">
        <xsl:with-param name="main-product-processed" select="true()" as="xs:boolean"/>
      </xsl:apply-templates>
    </xsl:if>-->
  </xsl:template>
  
  <xsl:template match="*:serial_relation/*:identifiers"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437, https://redmine.le-tex.de/issues/17519 -->
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:serial_relation/*:vol_no"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <keyword role="Bandnummer">
      <xsl:value-of select="string-join((../*:vol_name/@term[normalize-space()], .), ' ')"/>
    </keyword>
  </xsl:template>
  
   <xsl:template match="*:serial_relation/*:issn"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17519 -->
    <keyword role="BiblISSN">
      <xsl:value-of select="if ($lang = '') then concat('Buchreihen-ISSN: ', .) else concat('ISSN of series: ', .)"/>
    </keyword>
  </xsl:template>
  
     <xsl:template match="*:serial_relation/*:identifiers/*:identifier[@type='EISSN']"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17519 -->
    <keyword role="BibleISSN">
      <xsl:value-of select="if ($lang = '') then concat('Buchreihen-eISSN: ', .) else concat('eISSN of series: ', .)"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term = 'Fördertext (Impressum)'][normalize-space()]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437. might be obsolete with https://redmine.le-tex.de/issues/17515 -->
    <keyword role="Fordertext">
      <xsl:value-of select="."/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term = 'Mitwirkende Ergänzung (Impressum)'][normalize-space()]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17617 -->
    <keyword role="Mitwirkung">
      <xsl:value-of select="."/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term = 'Thesis-Pflichteintrag (Impressum)'][normalize-space()]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <keyword role="Qualifikationsnachweis">
      <xsl:value-of select="."/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term = 'Umschlagabb./Copyright Vermerk'][normalize-space()]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17617. Higher prio than in copyright-holders -->
    <keyword role="Umschlagcredit">
      <xsl:value-of select="."/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term = 'Editorial'][normalize-space()][$lang = ''] | 
                       *:text[@term = 'Editorial Übersetzung'][normalize-space()][not($lang = '')]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17450,
         https://redmine.le-tex.de/issues/17511 (localization)-->
    <keyword role="Editorial">
      <xsl:sequence select="html:process-html(., true())" />
    </keyword>
  </xsl:template>
  
  <xsl:template match="*:text[@term][@text_type = 'REIHG'][normalize-space()][$lang = ''] |
                       *:text[@term][@text_type = 'REIHGU'][normalize-space()][not($lang = '')]"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17450 -->
    <keyword role="Reihenherausgeber">
      <xsl:sequence select="html:process-html(., true())" />
    </keyword>
  </xsl:template>

  <xsl:template match="*:serial"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/17443-->
    <xsl:apply-templates select="*:memo | *:content" mode="#current"/>
  </xsl:template>
  
<!-- https://redmine.le-tex.de/issues/17419
    
  <edition_type term="E-Book - PDF">EBP</edition_type> -> OpenAccess 
  <edition_type term="Softcover">PBK</edition_type> -> Druck
  <edition_type term="E-Book - ePub">EBE</edition_type>
  <edition_type term="E-Book - Enhanced Html">EBEH</edition_type>-->
  
</xsl:stylesheet>
