<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="load-epub-config">
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Metadata document
    </p:documentation>
  </p:input>
  
  <p:input port="stylesheet" primary="false"/>
  
  <p:input port="parameters" kind="parameter" primary="true"/>
  
  <p:output port="result" primary="true" sequence="true">
    <p:documentation>
      The patched epub-config document
    </p:documentation>
  </p:output>
  
  <p:option name="basename" select="''"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths-for-files-xml.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <tr:store-debug pipeline-step="epub/00_metadata">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <tr:paths-for-files-xml name="get-cover-path">
    <p:input port="conf">
      <p:document href="http://this.transpect.io/conf/conf.xml"/>
    </p:input>
    <p:with-option name="filenames" select="$basename">
      <p:pipe port="source" step="load-epub-config"/>
    </p:with-option>
  </tr:paths-for-files-xml>
  
  <tr:file-uri name="file-uri-from-cover-dir">
    <p:with-option name="filename" select="concat(/c:directory/@name, //c:file[1]/@name, '/../epub/cover')"/>
  </tr:file-uri>
  
  <tr:store-debug pipeline-step="epub/01a_cover-dir-listing">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] scan epub cover directory: ', /c:result/@local-href"/>
  </cx:message>
  
  <p:sink/>
  
  <tr:load-cascaded name="load-epub-config-template" 
                    filename="epub/epub-config.xml" 
                    fallback="http://this.transpect.io/a9s/common/epub/epub-config.xml">
    <p:input port="paths">
      <p:pipe port="parameters" step="load-epub-config"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
  
  <p:sink/>
  
  <p:try name="final-cover-path">
    <p:group>
      <p:output port="result"/>
      
      <p:directory-list name="cover-dir">
        <p:with-option name="path" select="/c:result/@local-href">
          <p:pipe port="result" step="file-uri-from-cover-dir"/>
        </p:with-option>
      </p:directory-list>
      
      <tr:store-debug pipeline-step="epub/01b_cover-dir-listing">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <tr:file-uri name="file-uri-from-cover-path">
        <p:with-option name="filename" select="concat(/c:directory/@xml:base, //c:file[1]/@name)"/>
      </tr:file-uri>
      
      <tr:store-debug pipeline-step="epub/02_evaluated-cover-path">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:add-attribute attribute-name="href" match="/c:request" name="create-request">
        <p:input port="source">
          <p:inline>
            <c:request method="get" detailed="true" status-only="true"/>
          </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="/c:result/@local-href">
          <p:pipe port="result" step="file-uri-from-cover-path"></p:pipe>
        </p:with-option>
      </p:add-attribute>
      
      <tr:store-debug pipeline-step="epub/03_http-request">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:http-request/>
      
      <p:sink/>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="file-uri-from-cover-path"/>
        </p:input>
      </p:identity>
      
    </p:group>
    <p:catch>
      <p:output port="result"/>
      
      <tr:file-uri name="file-uri-fallback-cover">
        <p:with-option name="filename" select="/epub-config/cover/@href">
          <p:pipe port="result" step="load-epub-config-template"/>
        </p:with-option>
      </tr:file-uri>
      
    </p:catch>
  </p:try>
  
  <tr:store-debug pipeline-step="epub/04_real-cover-path">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:xslt name="populate-epub-config-template" cx:depends-on="final-cover-path">
    <p:input port="source">
      <p:pipe port="result" step="load-epub-config-template"/>
      <p:pipe port="source" step="load-epub-config"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="load-epub-config"/>
    </p:input>
    <p:with-param name="cover-path" select="(/c:result/@local-href, /c:result/@href)[1]">
      <p:pipe port="result" step="final-cover-path"/>
    </p:with-param>
  </p:xslt>
  
  <tr:store-debug pipeline-step="epub/06_patched-epub-config">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>
