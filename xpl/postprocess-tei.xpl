<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io" 
  version="1.0"
  name="postprocess-tei">
  <p:input port="source" primary="true">
    <p:documentation>A TEI file</p:documentation>  
  </p:input>
  <p:output port="result"/>

  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  


  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>

    <p:xslt name="select-edition-meta">
      <p:documentation>Adds some changes to the TEI (metatags mainly and deleting css-properties)</p:documentation>
      <p:input port="source">
        <p:pipe port="source" step="postprocess-tei"/>
      </p:input>
      <p:input port="stylesheet">
        <p:document href="http://this.transpect.io/a9s/ts/xsl/postprocess-tei.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>

    <tr:store-debug pipeline-step="hub2tei/postprocessed-tei" name="store-postprocessed-tei">
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>

</p:declare-step>
