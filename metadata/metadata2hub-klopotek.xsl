<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  

  
  <xsl:template match="*:title | *:subtitle | *:doi | *:serial_title"  mode="klopotek-to-keyword"  priority="2">
    <keyword role="{css:map-klopotek-to-keyword(name())}">
      <xsl:apply-templates select="node()" mode="#current"/>
    </keyword>
  </xsl:template>

  <xsl:function name="css:map-klopotek-to-keyword" as="xs:string">
    <xsl:param name="role" as="xs:string"/>
    <xsl:variable name="klopotek-roles" as="map(xs:string, xs:string)"
                  select="map{ 
                              'isbn':'ISBN',
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

  <xsl:template match="*"  mode="klopotek-to-keyword" priority="-0.5"/>
  
  <xsl:variable name="lang" select="     if (//*:original_publication/*:language[matches(., 'ENGL', 'i')]) then 'E' 
                                    else if (//*:original_publication/*:language[matches(., 'SPA', 'i')]) then 'S' else ''" as="xs:string?"/>
  
  <xsl:param name="basename" as="xs:string"/>
  
  <xsl:template match="*:original_publication"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16471-->
    <keyword role="Copyright">
      <para><xsl:sequence select="*:copyright_remark/node()"/></para>
      <xsl:choose>
        <xsl:when test="../*:open_access[@open_access_yn = 'Y']">
          <!-- Open Access-->
         <para>
           <xsl:choose>
             <xsl:when test="contains($basename, '_anth_')">
               <xsl:value-of select="concat('© ', 
                                            string-join(for $ch in ../*:copyright_holders/*:copyright_holder[*:cpr_type = ('EDIT', 'HG')] 
                                                        return concat($ch/*:first_name, ' ', $ch/*:last_name), ', '),
                                            if ($lang = 'E') then ' (ed.)' else ' (Hg.)'
                                           )"/>
             </xsl:when>
             <xsl:when test="contains($basename, '_mono_')">
               <xsl:value-of select="concat('© ', 
                                            string-join(for $ch in ../*:copyright_holders/*:copyright_holder[*:cpr_type = 'VE'] 
                                                        return concat($ch/*:first_name, ' ', $ch/*:last_name), ', ')
                                           )"/>
             </xsl:when>
           </xsl:choose>
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
  
  <xsl:variable name="copyright-roles-lookup" as="map(xs:string, xs:string+)"
                  select="map{'VE':  ('Autor',          '',                  '',             ''),
                              'HG':  ('Herausgeber',    '',                  '',             ''),
                              'EDIT':('Herausgeber',    '',                  '',             ''),
                              'UMSA':('Umschlagcredit', 'Umschlagabbildung', '',             ''),
                              'LEKT':('Lektorat',       'Lektorat',          'Proofreading', ''),
                              'KORR':('Korrektorat',    'Korrektorat',       'Correction',   ''),
                              'LAYO':('Satz',           '',                  '',             ''),
                              'DRUK':('Druck',          '',                  '',             '')
                  }">
     <!--                             1: Keyname,        2: added info German, 3: English 4 Spanish (https://redmine.le-tex.de/issues/16459)-->
   </xsl:variable>
                  
                  
  <xsl:variable name="copyright-roles"  as="xs:string+" 
              select="('VE', 'HG', 'EDIT', 'UMSA', 'LEKT', 'KORR', 'LAYO', 'DRUK')"/>
  
  
  <xsl:template match="*:copyright_holders"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <xsl:variable name="lang-num" select="if ($lang = 'E') then 3 else
                                          if ($lang = 'S') then 4 else 2" as="xs:integer"/>
    <xsl:for-each-group select="*:copyright_holder" group-by="*:cpr_type">
      <xsl:if test="current-grouping-key() =  $copyright-roles">
        <xsl:variable name="current-lookup"  select="map:get($copyright-roles-lookup, current-grouping-key())" as="xs:string+"/>
        <keyword role="{$current-lookup[1]}">      
          <xsl:choose>
            <xsl:when test="count(current-group()) gt 1">
              <xsl:for-each select="current-group()">
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
      </xsl:if>
    </xsl:for-each-group>
    
    
    <xsl:if test="*:copyright_holder[*:cpr_type = ('EDIT', 'HG', 'VG')]/text[@text_type = concat('AUTBIO', $lang)][normalize-space()]">
      <keyword role="{if (*:copyright_holder[*:cpr_type  = ('EDIT', 'VG')][text[@text_type = concat('AUTBIO', $lang)][normalize-space()]]) then 'Herausgeberinformationen' else 'Autoreninformationen'}">
        
        <!--Herausgeberinformationen https://redmine.le-tex.de/issues/16479-->
        
        <xsl:choose>
          <xsl:when test="count(*:copyright_holder[*:cpr_type = ('EDIT', 'HG')]/text[@text_type = concat('AUTBIO', $lang)][normalize-space()]) gt 1">
            <xsl:for-each select="*:copyright_holder[*:cpr_type = ('EDIT', 'HG')]/text[@text_type = concat('AUTBIO', $lang)]">
              <para>
               <!-- <xsl:sequence select="concat(./../*:first_name, ' ', ./../*:last_name, ' ')"/>-->
                <xsl:sequence select="html:process-html(.)" />
              </para>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <!--<xsl:sequence select="concat(./../*:first_name, ' ', ./../*:last_name, ' ')"/>-->
            <xsl:sequence select="html:process-html(.)" />
          </xsl:otherwise>
        </xsl:choose>
      </keyword>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:function name="html:process-html" as="node()*">
    <xsl:param name="context" as="element()"/>
    
    <xsl:if test="$context[normalize-space()]">
      

    <xsl:variable name="parsed" as="document-node(element(div))" 
                  select="parse-xml('&lt;div>' || $context || '&lt;/div>')"/>


      <xsl:variable name="stripped-namespaces" as="element(dbk:div)"> 
        <xsl:apply-templates select="$parsed" mode="strip-namespaces"/>
      </xsl:variable>

  	  <xsl:variable name="structured-onix" as="node()*">
  	    <xsl:for-each-group select="$stripped-namespaces/node()[not(self::text()[matches(., '^\p{Zs}+$')])]" 
                      group-starting-with="*:br[not(preceding-sibling::node()[1][self::*:br])]">
   	    <xsl:choose>
   	      <xsl:when test="current-group()[1][not(self::*:br)]">
             <!-- first para -->
   	        <xsl:element name="p">
   	          <xsl:attribute name="class" select="'Hauptteil_Grundtext_GT'"/>
               <xsl:attribute name="style" select="'margin-top:1em; text-indent:0;'"/>
   	          <xsl:sequence  select="current-group()"/>
   	        </xsl:element>
   	      </xsl:when>
   	      <xsl:when test="current-group()[1][self::*:br] 
                           and 
                           current-group()[2][self::*:br]">
             <!-- empty line -->
   	        <xsl:element name="p">
   	          <xsl:attribute name="class" select="'Hauptteil_Grundtext_GT'"/>
               <xsl:attribute name="style" select="'margin-top:1em; text-indent:0;'"/>
   	          <xsl:sequence select="current-group()[position() gt 2]" />
   	        </xsl:element>
   	      </xsl:when>
   	      <xsl:otherwise>
             <!-- following para -->
   	        <xsl:element name="p"><!--https://redmine.le-tex.de/issues/15535-->
   	          <xsl:attribute name="class" select="'Hauptteil_Grundtext_GT'"/>
   	          <xsl:sequence select="current-group()[position() gt 1]"/>
   	        </xsl:element>
           </xsl:otherwise>
   	    </xsl:choose>
  	    </xsl:for-each-group>
  	  </xsl:variable>
      <xsl:apply-templates select="$structured-onix" mode="postprocess-html-from-onix"/>
  	</xsl:if>
  </xsl:function>
  
    
  <xsl:template match="@* | node()" mode="strip-namespaces postprocess-html-from-onix toc">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  
  <xsl:template match="*:b" mode="postprocess-html-from-onix" priority="4">
    <xsl:element name="phrase">
      <xsl:attribute name="css:font-weight" select="'bold'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:p" mode="postprocess-html-from-onix" priority="3">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*" mode="strip-namespaces" priority="2" exclude-result-prefixes="#all">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@* except @xmlns, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:serial_relation"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*:serial_relation/*:vol_no"  mode="klopotek-to-keyword"  priority="2">
    <!-- https://redmine.le-tex.de/issues/16437 -->
    <keyword role="Bandnummer">
      <xsl:value-of select="string-join((../*:vol_name/@term[normalize-space()], .), ' ')"/>
    </keyword>
  </xsl:template>
  
</xsl:stylesheet>
