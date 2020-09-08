<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:ts="http://www.transcript-verlag.de/transpect"
  version="1.0"
  name="load-meta">
  
  <p:documentation>
    In contrast to the common load-meta step, this step loads 
    onix (extension: onix.xml) for EPUB and a specific metadata 
    file (extension: meta.xml) for the generation of the print 
    title pages.
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Expects a paths document
    </p:documentation>
  </p:input>
  
  <p:input port="stylesheet" primary="false"/>
  
  <p:input port="parameters" kind="parameter" primary="true"/>
  
  <p:output port="result" primary="true" sequence="true">
    <p:documentation>
      The metadata file or empty
    </p:documentation>
  </p:output>
  
  <p:output port="titlepage-meta" primary="false" sequence="true">
    <p:documentation>
      The metadata files or empty
    </p:documentation>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths-for-files-xml.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>


  <p:variable name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value"/>

  <!-- Determine paths for ONIX document in content repository. 
       It is expected that ONIX file has the same repo-href-local as the source file. -->
  
  <!-- commented: https://redmine.le-tex.de/issues/8899 -->
  <!-- use only one metadata format -->
  <!--
  
  <tr:paths-for-files-xml name="get-onix-path">
    <p:input port="conf">
      <p:document href="http://this.transpect.io/conf/conf.xml"/>
    </p:input>
    <p:with-option name="filenames" select="concat($basename, '.onix.xml')"/>
  </tr:paths-for-files-xml>
  
  <tr:store-debug pipeline-step="metadata/02_path">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:try name="try-load-onix">
    <p:group>
      <p:output port="result"/>
      <p:variable name="onix-href" select="/c:files/c:file/@name">
        <p:pipe port="result" step="get-onix-path"/>
      </p:variable>
      
      <cx:message>
        <p:with-option name="message" select="'[info] load onix: ', $onix-href"/>
      </cx:message>
      
      <p:load name="load-onix">
        <p:with-option name="href" select="$onix-href"/>
      </p:load>
      
    </p:group>
    <p:catch>
      <p:output port="result"/>
      
      <p:load name="load-fallback" href="fallback.onix.xml"/>
      
    </p:catch>
  </p:try>
  
  <tr:store-debug pipeline-step="metadata/04_onix">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  -->
  
  <tr:paths-for-files-xml name="get-titlepage-meta-path">
    <p:input port="conf">
      <p:document href="http://this.transpect.io/conf/conf.xml"/>
    </p:input>
    <p:with-option name="filenames" select="concat($basename, '.meta.xml')"/>
  </tr:paths-for-files-xml>
  
  <p:try name="try-load-titlepage-meta">
    <p:group>
      <p:output port="result"/>
      <p:variable name="titlepage-meta-href" select="/c:files/c:file/@name">
        <p:pipe port="result" step="get-titlepage-meta-path"/>
      </p:variable>
      
      <cx:message>
        <p:with-option name="message" select="'[info] load titlepage-meta: ', $titlepage-meta-href"/>
      </cx:message>
      
      <p:load name="load-titlepage-meta" dtd-validate="false">
        <p:with-option name="href" select="$titlepage-meta-href"/>
      </p:load>
      
    </p:group>
    <p:catch>
      <p:output port="result"/>
      
      <p:load name="load-fallback" href="fallback.meta.xml" dtd-validate="false"/>
      
    </p:catch>
  </p:try> 
  
  <tr:store-debug pipeline-step="metadata/04_titlepage">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:wrap-sequence wrapper="cx:documents">
    <p:input port="source">
      <!--<p:pipe port="result" step="try-load-onix"/>-->
      <p:pipe port="result" step="try-load-titlepage-meta"/>
    </p:input>
  </p:wrap-sequence>
  
</p:declare-step>
