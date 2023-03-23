<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tei2hub="http://transpect.io/tei2hub"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tx="http://transpect.io/xerif"
  xmlns:tei2bits="http://transpect.io/tei2bits" 
  version="1.0"
  name="customer-output">

  <p:input port="source" primary="true"/>
  <p:input port="stylesheet">
    <p:empty/>
  </p:input>
  <p:input port="parameters"/>
  <p:input port="options">
    <p:empty/>
  </p:input>
  <p:output port="result" sequence="true">
    <p:pipe port="result"  step="tei2bits"/>
  </p:output>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri"/>
  <!-- the other options are contained in the paths params -->
<!--  <p:option name="status-dir-uri" required="false" select="resolve-uri('status')"/>-->

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/tei2bits/xpl/tei2bits.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-xml-model.xpl"/>

  <p:variable name="status-dir-uri" select="/*/c:param[@name = 'status-dir-uri']/@value">
    <p:pipe port="parameters" step="customer-output"/>
  </p:variable>

  <tr:simple-progress-msg name="tei2bits-start-msg" file="tei2bits-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting TEI to BITS  conversion</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von TEI nach BITS</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>

  <tei2bits:tei2bits name="tei2bits">
    <p:documentation>Converts TEI to BITS</p:documentation>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="filename-driver" select="'tei2bits/tei2bits_driver'"/>
    <p:input port="paths">
        <p:pipe port="parameters" step="customer-output"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="customer-output"/>
    </p:input>
  </tei2bits:tei2bits>

  <tr:simple-progress-msg name="tei2bits-end-msg" file="tei2bits-end.txt" cx:depends-on="tei2bits">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Finished TEI to BITS/JATS  conversion. Starting to chunk</c:message>
          <c:message xml:lang="de">Konvertierung von TEI nach BITS/JATS beendet. Starte Chunking.</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>

  <tr:load-cascaded name="postprocess-bits-stylesheet" filename="bits2chunks/postprocess-bits-for-chunks.xsl">
    <p:input port="paths">
      <p:pipe port="parameters" step="customer-output"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="required" select="'no'"/>
  </tr:load-cascaded>

  <p:sink/>

  <p:xslt name="postprocess-bits" cx:depends-on="tei2bits">
      <p:documentation>Adds some changes to the BITS (chunk base-uris etc.)</p:documentation>
      <p:input port="source">
        <p:pipe port="result" step="tei2bits"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe port="result" step="postprocess-bits-stylesheet"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-param name="s9y1-path" select="/c:param-set/c:param[@name eq 's9y1-path']/@value">
        <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value">
         <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="out-dir-uri" select="replace(/c:param-set/c:param[@name eq 'out-dir-uri']/@value, '/(docx|idml)$', '')">
         <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
    </p:xslt>

    <tr:store-debug name="store-postprocessed-bits" pipeline-step="bits2chunks/99-postprocessed">
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
      <p:with-option name="indent" select="true()"/>
    </tr:store-debug>

    <p:xslt name="split-articles" initial-mode="export">
      <p:documentation>creates chunks from BITS</p:documentation>
      <p:input port="stylesheet">
        <p:pipe port="result" step="postprocess-bits-stylesheet"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-param name="s9y1-path" select="/c:param-set/c:param[@name eq 'file']/@value">
        <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value">
        <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="out-dir-uri" select="replace(/c:param-set/c:param[@name eq 'out-dir-uri']/@value, '/(docx|idml)$', '')">
        <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
    </p:xslt>

    <p:sink/>

  <tr:load-cascaded name="bits2klopotek-stylesheet" filename="bits2chunks/bits2klopotek.xsl">
    <p:input port="paths">
      <p:pipe port="parameters" step="customer-output"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="required" select="'no'"/>
  </tr:load-cascaded>

  <p:sink/>

   <p:xslt name="create-kloptek-xml" cx:depends-on="postprocess-bits" initial-mode="bits2klopotek">
      <p:documentation>Extracts klopotek metadata from BITS Chunks</p:documentation>
      <p:input port="source">
        <p:pipe port="result" step="postprocess-bits"/>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe port="result" step="bits2klopotek-stylesheet"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-param name="s9y1-path" select="/c:param-set/c:param[@name eq 's9y1-path']/@value">
        <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value">
         <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
      <p:with-param name="out-dir-uri" select="replace(/c:param-set/c:param[@name eq 'out-dir-uri']/@value, '/(docx|idml)$', '')">
         <p:pipe port="parameters" step="customer-output"/>
      </p:with-param>
    </p:xslt>


  <p:sink/>

  <tr:store-debug name="store-klopotek" pipeline-step="bits2chunks/klopotek-chunks">
    <p:input port="source">
      <p:pipe port="secondary" step="create-kloptek-xml"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>

  <p:sink/>

  <tr:store-debug pipeline-step="difftest/out-bits" extension="xml">
    <p:input port="source">
      <p:pipe step="postprocess-bits" port="result"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <p:for-each name="splitting-bits">
    <p:iteration-source>
      <p:pipe port="secondary" step="split-articles"/>
      <p:pipe port="secondary" step="create-kloptek-xml"/>
    </p:iteration-source>
    
    <!--      <tr:html-embed-resources fail-on-error="false" unavailable-resource-message="yes">
      <p:input port="catalog">
      <p:document href="../../../xmlcatalog/catalog.xml"/>
      </p:input>
      </tr:html-embed-resources>
    -->
    <p:choose>
      <p:when test="ends-with(base-uri(), 'html')">
        <p:delete match="@srcpath"/>
        <p:namespace-rename from="http://www.w3.org/ns/xproc-step" to=""/>
        <p:namespace-rename from="http://xmlcalabash.com/ns/extensions" to=""/>
        <p:store include-content-type="true" name="export" indent="true" omit-xml-declaration="false" method="html" version="5.0">
          <p:with-option name="href" select="base-uri()"/>
        </p:store>
      </p:when>
      <p:otherwise>
        
        <tr:prepend-xml-model name="prepend-model">
          <p:input port="models">
            <p:inline>
              <c:models>
                <c:model href="https://jats.nlm.nih.gov/extensions/bits/2.0/rng/BITS-book2.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"/>
              </c:models>
            </p:inline>
          </p:input>
        </tr:prepend-xml-model>

        <p:delete match="@srcpath"/>
        <p:namespace-rename from="http://www.w3.org/ns/xproc-step" to=""/>
        <p:namespace-rename from="http://xmlcalabash.com/ns/extensions" to=""/>
        <p:store include-content-type="true" 
                 name="export" 
                 indent="true" 
                 omit-xml-declaration="false" 
                 method="xml">
          <p:with-option name="href" select="base-uri()"/>
          <p:with-option name="doctype-system" select="'BITS-book2.dtd'"/>
          <p:with-option name="doctype-public" select="'https://jats.nlm.nih.gov/extensions/bits/2.0/BITS-book2.dtd'"/>
        </p:store>
      </p:otherwise>
    </p:choose>
  </p:for-each>

<!--  <p:sink/>-->


</p:declare-step>