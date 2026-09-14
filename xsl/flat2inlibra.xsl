<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
<!--  <xsl:key name="elt-by-corresp" match="*[@corresp]" use="@corresp"/>-->
  <!-- this stylesheets postprocesses the result of the docx2hub conversion for the use at a inlibra platform. see https://redmine.le-tex.de/issues/20646 -->
  <xsl:key name="tr:find-list" use="listitem[1]/para[1]/@srcpath" 
           match="orderedlist[not(ancestor::*[self::orderedlist|self::itemizedlist])]|itemizedlist[not(ancestor::*[self::orderedlist|self::itemizedlist])]"/>
  
  <xsl:variable name="didactic-para-roles" select="('tsaddattention', 'tsadddefinition', 'tsaddexample', 'tsaddexcursus', 
                                                    'tsaddlearningoutcomes', 'tsaddliteraturetip', 'tsaddnote', 'tsaddorientation', 
                                                    'tsaddsummary', 'tsaddtask', 'tsaddtip', 'tsaddtopics')" as="xs:string+">
    <!-- those paras will be merged by <br/> -->
  </xsl:variable>
  
  <xsl:variable name="evolved" select="collection()[/hub[info/keywordset[@role='hub']/keyword[@role='hierarchized'] = 'true']]" as="document-node()">
    <!-- used to copy the lists, -->
  </xsl:variable>
  
  <xsl:template match="@*|node()|processing-instruction()" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/hub">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, info" mode="#current"/>
      <xsl:for-each-group select="node() except info" group-adjacent="tr:is-didactic-para(.)">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">      
            <xsl:element name="para">
              <xsl:apply-templates select="current-group()[1]/@*, current-group()[1]/node()" mode="#current"/>
              <xsl:for-each select="current-group()[position() gt 1]">
                <xsl:if test=".[self::para]"><br/></xsl:if>
                <xsl:apply-templates select="node()" mode="#current"/>
              </xsl:for-each>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="tr:is-didactic-para" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="$node[self::para[@role = $didactic-para-roles]]
                           [not(phrase[@role = 'hub:identifier'])] 
                           [following-sibling::*[1][self::para][@role = $node/@role] or 
                           preceding-sibling::*[1][self::para][@role = $node/@role]]">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$node/(self::text() | self::processing-instruction()) 
                     and
                     (
                       $node/preceding-sibling::*[1]/self::para[@role = $didactic-para-roles][not(phrase[@role = 'hub:identifier'])] 
                       and 
                       $node/following-sibling::*[1]/self::para[@role = $node/preceding-sibling::*[1]/@role][not(phrase[@role = 'hub:identifier'])] 
                     )">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="para[@role = $didactic-para-roles]
                           [phrase[@role = 'hub:identifier']]">
    <!--<xsl:choose>-->
      <xsl:if test="key('tr:find-list', @srcpath, $evolved)[self::orderedlist|self::itemizedlist]">
       <xsl:copy copy-namespaces="no"> 
         <xsl:apply-templates select="@*" mode="#current"/>
         <xsl:copy-of select="key('tr:find-list', @srcpath, $evolved)[self::orderedlist|self::itemizedlist]"/>
       </xsl:copy>
      </xsl:if>
     <!-- <xsl:otherwise>
        <xsl:comment select="serialize(.)"/>
      </xsl:otherwise>-->
    <!--</xsl:choose>-->
  </xsl:template>
  
</xsl:stylesheet>