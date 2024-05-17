<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="main" 
  type="tx:main">
  
  <p:documentation>
    Converts docx to tei and an HTML report
  </p:documentation>
  
  <p:input port="params" primary="true"/>
  
  <p:input port="schema" primary="false">
    <p:document href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"/>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="remove-srcpaths"/>
  </p:output>
    
  <p:output port="htmlreport" primary="false">
    <p:pipe port="result" step="htmlreport"/>
  </p:output>

  <p:serialization port="result" omit-xml-declaration="false"/>
  <p:serialization port="htmlreport" method="xhtml"/>
  
  <p:option name="file" required="true"/>
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:option name="toc-depth" select="3">
    <p:documentation>
      Depth of Table of Contents
    </p:documentation>
  </p:option>

  <p:option name="run-local" select="'no'">
    <p:documentation>
      Fix image paths to match local output directory.
    </p:documentation>
  </p:option>
  
  <p:option name="file-ext" select="'docx'"/>

  <p:option name="create-idml" required="false" select="'no'"/>
  <p:option name="idml-target-uri"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/hub2tei/xpl/hub2tei.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/check-styles.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-xml-model.xpl"/>
  <p:import href="http://transpect.io/hub2html/xpl/hub2html.xpl"/>  

  <p:import href="../../common/xpl/get-paths.xpl"/>
  <p:import href="../../common/xpl/copy-images.xpl"/>
  <p:import href="../../common//xpl/evolve-hub.xpl"/>
  <p:import href="../../common/xpl/htmlreport.xpl"/>
  <p:import href="../../common/xpl/insert-meta.xpl"/>
  <p:import href="../../common/xpl/load-meta.xpl"/>
  <p:import href="../../common/xpl/validate.xpl"/>


  <tr:resolve-params name="resolve-params"/>
  
  <p:in-scope-names name="expand-options-as-params"/>
  
  <p:insert match="/c:param-set" position="last-child" name="consolidate-params">
    <p:input port="source">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:input port="insertion" select="//c:param">
      <p:pipe port="result" step="expand-options-as-params"/>
    </p:input>
  </p:insert>
  
  <p:sink/>
  
  <tr:file-uri name="normalize-filename">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <tx:get-paths name="get-paths">
    <p:input port="params">
      <p:pipe port="result" step="consolidate-params"/>
    </p:input>
    <p:with-option name="file" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:get-paths>
  
  <tx:load-meta name="load-meta-wrapper">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:load-meta>
  
  <!--<p:sink/>-->
  
  <docx2hub:convert name="docx2hub" mml-space-handling="xml-space" srcpaths="yes" cx:depends-on="load-meta-wrapper">
    <p:with-option name="docx" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="mathtype2mml" select="'yes'"/>
    <p:with-option name="mml-version" select="'4-core'"/>
    <p:with-option name="remove-biblioentry-paragraphs" select="'no'"/>
  </docx2hub:convert>
  
  <tr:check-styles name="check-styles">
    <p:input port="parameters">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="cssa" select="'styles/cssa.xml'"/>
    <p:with-option name="differentiate-by-style" select="'true'"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:check-styles>     
  
  <tx:insert-meta name="insert-meta">
    <p:input port="meta">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:insert-meta>

  <tx:evolve-hub name="evolve-hub-dyn">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:evolve-hub>
  
  <tx:copy-images name="copy-images-and-patch-filerefs">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:copy-images>

  <p:sink/>
  
  <p:choose name="hub2tei">
    <p:when test="$file-ext = 'docx'">
      <p:output port="result" primary="true">
        <p:pipe port="result" step="gen-tei"/>
      </p:output>
      <hub2tei:hub2tei name="gen-tei">
        <p:input port="source">
          <p:pipe port="result" step="copy-images-and-patch-filerefs"/> 
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </hub2tei:hub2tei>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>   
      <p:xslt name="added-sourcepath">
        <p:input port="source">
          <p:pipe port="result" step="copy-images-and-patch-filerefs"/> 
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet version="2.0">
              <xsl:template match="*:p | *:td | *:seg | *:head | *:label | *:gloss | *:bibl | *:biblFull | *:biblStruct
                | *:listBibl//*" priority="2">
                <xsl:copy copy-namespaces="no">
                  <xsl:apply-templates select="@*"/>
                  <xsl:if test="not(@srcpath)">
                    <xsl:attribute name="srcpath" select="concat('tei_', generate-id(.))"/>
                  </xsl:if>
                  <xsl:apply-templates select="node()"/>
                </xsl:copy>
              </xsl:template>
              <xsl:template match="@* | node()">
                <xsl:copy copy-namespaces="no">
                  <xsl:apply-templates select="@*, node()"/>
                </xsl:copy>
              </xsl:template>
            </xsl:stylesheet>
          </p:inline>
        </p:input>
      </p:xslt>      
    </p:otherwise>
  </p:choose>
  
  <tr:prepend-xml-model name="prepend-model">
    <p:input port="models">
      <p:inline>
        <c:models>
          <c:model href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"
            type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"/>
        </c:models>
      </p:inline>
    </p:input>
  </tr:prepend-xml-model>

  <p:delete match="@srcpath" name="remove-srcpaths"/>
  
  <p:sink/>

  <tr:store-debug name="store-tei" pipeline-step="difftest/out-tei">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:with-option name="active" select="'yes'"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
  <p:sink/>

  <tx:validate name="validate">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="hub">
      <p:pipe port="result" step="copy-images-and-patch-filerefs"/>
    </p:input>
    <p:input port="schema">
      <p:pipe port="schema" step="main"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="epub-file-uri">
      <p:inline>
        <c:result os-path="bogo"/>
      </p:inline>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:validate>
  
  <p:sink/>
  
  <hub2htm:convert name="hub2html">
     <p:input port="source">
      <p:pipe port="result" step="docx2hub"/>
    </p:input>
     <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="other-params">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub2htm:convert>

  <p:sink/>

  <tx:htmlreport name="htmlreport">
    <p:input port="source">
      <p:pipe port="result" step="hub2html"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="reports">
      <p:pipe port="report" step="docx2hub"/>
      <p:pipe port="report" step="check-styles"/>
      <p:pipe port="report" step="evolve-hub-dyn"/>
      <p:pipe port="reports" step="validate"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:htmlreport>
  
  <p:sink/>

</p:declare-step>
