<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cat="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:bts="http://transpect.io/bts"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
  exclude-result-prefixes="xs c cat tr bts epub"
  version="2.0">

  <xsl:import href="../../bits2chunks/postprocess-bits-for-chunks.xsl"/>

  <xsl:template match="/*:export-root" mode="export">
    <c:result target-dir="{$catalog-resolved-target-dir}" xmlns="http://www.w3.org/ns/xproc-step"/>

    <xsl:variable name="all-bibls">
      <xsl:if test="exists(*:doi)">
        <xsl:variable name="issue-doi" select="book[1]/book-meta/book-id[@book-id-type='doi']" as="xs:string?"/>
        <xsl:element name="biblographic-information">
          <xsl:attribute name="xml:base" select="if (matches(*:doi[1][not(matches(@xml:base, 'toc|frontmatter|fm'))]/@xml:base, '-\d{6}\.bibl\.xml'))
                                                 then replace(replace(*:doi[1][not(matches(@xml:base, 'toc|frontmatter|fm'))]/@xml:base, '(-\d{4})\d{2}\.bibl\.xml', '$1.bibl.xml'), '(chunks-bibl/)', '$1issue/')
                                                 else replace(replace(*:doi[1][not(matches(@xml:base, 'toc|frontmatter|fm'))]/@xml:base, '-\d+\.bibl\.xml', '.bibl.xml'), '(chunks-bibl/)', '$1issue/')"/>
          <xsl:attribute name="name" select="if ($issue-doi[normalize-space()])
                                             then $issue-doi
                                             else replace(*:doi[not(matches(@xml:base, 'toc|frontmatter|fm'))][1]/@name, '-\d+$', '')"/>
          <xsl:sequence select="*:doi"/>
        </xsl:element>
      </xsl:if>
    </xsl:variable>
    <xsl:apply-templates select="(*:book | *:doi | *:chunk-meta), $all-bibls" mode="#current"/>
  </xsl:template>
 
</xsl:stylesheet>
