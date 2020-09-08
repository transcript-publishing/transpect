<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="adobe:ns:meta/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  version="2.0">
  
  <xsl:variable name="meta"       select="collection()[2]/x:xmpmeta/rdf:RDF/rdf:Description[dc:*][1]" as="element(rdf:Description)?"/>
  <xsl:variable name="title"      select="$meta/dc:title[@rdf:typeof eq 'headline'][1]" as="element(dc:title)?"/>
  <xsl:variable name="subtitle"   select="$meta/dc:title[@rdf:typeof eq 'alternativeHeadline'][1]" as="element(dc:title)?"/>
  <xsl:variable name="authors"    select="$meta/dc:creator[@rdf:typeof eq 'author'][1]" as="element(dc:creator)?"/>
  <xsl:variable name="editors"    select="$meta/dc:creator[@rdf:typeof eq 'editor'][1]" as="element(dc:creator)?"/>
  <xsl:variable name="about-book" as="element(dc:description)?"
                                  select="$meta/dc:description[@rdf:about eq 'https://schema.org/Book' and @rdf:typeof eq 'description'][1]" />
  <xsl:variable name="abstract" as="element(dc:description)?"
                select="$meta/dc:description[@rdf:about eq 'https://schema.org/Book' and @rdf:typeof eq 'abstract'][1]"/>
  <xsl:variable name="keywords"   select="$meta/dc:subject[1]" as="element(dc:subject)?"/>
  <xsl:variable name="copyright"  select="$meta/dc:rights[1]" as="element(dc:rights)?"/>
  <xsl:variable name="license"    select="$meta/dc:description[@rdf:typeof eq 'license'][1]" as="element(dc:description)?"/>
  <xsl:variable name="volume"     select="$meta/dc:description[@rdf:typeof eq 'bookEdition']//rdf:li[1]" as="element(rdf:li)?"/>
  <xsl:variable name="volume-no"  select="$meta/dc:description[@rdf:typeof eq 'bookEdition']//rdf:li[2]" as="element(rdf:li)?"/>
  <xsl:variable name="funder"     select="$meta/dc:description[@rdf:typeof eq 'funder'][1]" as="element(dc:description)?"/>
  <xsl:variable name="isbns"      select="$meta/dc:identifier[1]" as="element(dc:identifier)*"/>
  <xsl:variable name="contribs"   select="$meta/dc:contributor[1]" as="element(dc:contributor)*"/>
  
  <xsl:template match="@*|*|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/hub/info">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <title>
        <xsl:apply-templates select="$title"/>
      </title>
      <xsl:if test="$subtitle">
        <subtitle>
          <xsl:apply-templates select="$subtitle"/>
        </subtitle>
      </xsl:if>
      <xsl:for-each select="$authors/rdf:Seq">
        <author>
          <personname>
            <othername>
              <xsl:apply-templates select="rdf:li[1]"/>
            </othername>
          </personname>
          <xsl:if test="rdf:li[2]">
            <personblurb>
              <xsl:apply-templates select="rdf:li[2]"/>
            </personblurb>  
          </xsl:if>
        </author>
      </xsl:for-each>
      <xsl:for-each select="$editors//rdf:li">
        <editor>
          <personname>
            <othername>
              <xsl:apply-templates select="."/>
            </othername>
          </personname>
        </editor>
      </xsl:for-each>
      <abstract role="about-book">
        <xsl:for-each select="$about-book//rdf:li">
          <para>
            <xsl:apply-templates select="."/>  
          </para>  
        </xsl:for-each>
      </abstract>
      <keywordset role="subjects">
        <xsl:for-each select="$keywords//rdf:li">
          <keyword>
            <xsl:apply-templates/>
          </keyword>
        </xsl:for-each>
      </keywordset>
      <copyright>
        <year>
          <xsl:value-of select="($copyright/rdf:Seq/rdf:li[1], format-date(current-date(), '[Y]'))[1]"/>
        </year>
        <holder>
          <xsl:value-of select="($copyright/rdf:Seq/rdf:li[2], 'transcript Verlag, Bielefeld')[1]"/>
        </holder>
      </copyright>
      <legalnotice role="license">
        <para>
          <xsl:apply-templates select="$license"/>
        </para>
      </legalnotice>
      <xsl:if test="$volume">
        <edition>
          <xsl:apply-templates select="$volume"/>
        </edition>
      </xsl:if>
      <xsl:if test="$volume-no">
        <volumenum>
          <xsl:apply-templates select="$volume-no"/>
        </volumenum>
      </xsl:if>
      <xsl:if test="$funder">
        <othercredit>
          <orgname>
            <xsl:apply-templates select="$funder"/>
          </orgname>
        </othercredit>
      </xsl:if>
      <xsl:for-each select="$isbns">
        <biblioid role="{@rdf:typeof}">
          <xsl:value-of select="normalize-space(.)"/>
        </biblioid>
      </xsl:for-each>
      <xsl:for-each select="$contribs">
        <collab role="{@rdf:typeof}">
          <orgname>
            <xsl:value-of select="normalize-space(.)"/>
          </orgname>
        </collab>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="rdf:li|rdf:Seq|rdf:Bag|rdf:Alt|dc:*">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>
