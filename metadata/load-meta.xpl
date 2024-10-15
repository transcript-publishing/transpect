<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
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
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/recursive-directory-list/xpl/recursive-directory-list.xpl"/>

  <p:variable name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value"/>
  <p:variable name="ci-test" select="if (/c:param-set/c:param[@name='out-dir-uri'][@value[contains(., 'test_after')]]) then true() else false()"/>
  <p:variable name="run-local" select="if (/*/c:param[@name = 'run-local']/@value = ('yes', 'true'))  then true() else false()"/>
  <p:variable name="local-dir" select="/c:param-set/c:param[@name='out-dir-uri']/@value">
      <!-- example: file:/data/svncompat/.jenkins/workspace/svncompat_https_subversion_le_tex_de_customers_transcript_branches_common_tex_migration/test_after/std/anth/05013 -->
  </p:variable>
  <p:variable name="code-dir" select="/c:param-set/c:param[@name='s9y4-path']/@value">
      <!-- example: file:///C:/cygwin/home/mpufe/transcript/transpect/a9s/ts/ -->
  </p:variable>


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
    <p:with-option name="filenames" select="concat(replace($basename, '^(.+_\d{5})(_.+)?$', '$1'), '.meta.xml')"/>
  </tr:paths-for-files-xml>

<!--  <tr:store-debug pipeline-step="metadata/00_paths-fo-files">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>-->


  <tr:recursive-directory-list name="meta-list">
    <p:with-option name="path" select="if ($ci-test = true())
                                       then concat(replace($local-dir, 'file:/', 'file:///'), '/meta.xml')
                                       else replace(/c:files/c:file/@name, '^(.+)/.+$', 'file:///$1')"/>
  </tr:recursive-directory-list>


  <tr:store-debug pipeline-step="metadata/01_meta-dir-content">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>
  
  <tr:recursive-directory-list name="funder-dir-listing">
    <p:with-option name="path" select="if ($run-local = true())
                                       then 'file:///C:/cygwin/home/mpufe/transcript/content/media/logos/funders/'
                                       else '/media/logos/funders/'"/>
  </tr:recursive-directory-list>
  
   <tr:store-debug pipeline-step="metadata/02a_funder-dir-content">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <tr:recursive-directory-list name="logo-dir-listing">
    <p:with-option name="path" select="concat($code-dir, '/latex-oops/logos/series/')"/>
  </tr:recursive-directory-list>
  
   <tr:store-debug pipeline-step="metadata/02b_logo-dir-content">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <tr:file-uri name="meta-file-uri" cx:depends-on="meta-list">
    <p:with-option name="filename" select="concat(/c:directory/@xml:base, 
                                                  (/c:directory/c:file[contains(@name, '.klopotek.xml')]
                                                                      [matches(@name, replace($basename, '^(.+_\d{5})(_.+)?$', '$1'))]/@name, 
                                                   /c:directory/c:file[contains(@name, '.meta.xml')]
                                                                      [matches(@name, replace($basename, '^(.+_\d{5})(_.+)?$', '$1'))]/@name)[1]
                                                  )">
     <p:pipe port="result" step="meta-list"/>
    </p:with-option>
  </tr:file-uri>


  <tr:store-debug pipeline-step="metadata/03_file-uri">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <p:choose name="ci-conf">
    <p:variable name="current-local-href" select="/c:result/@local-href">
      <p:pipe port="result" step="meta-file-uri"/>
    </p:variable>
    <p:variable name="target-dir" select="concat($local-dir, replace($current-local-href, '^.+/\d{5}(/.+)$', '$1'))"/>
    <p:when test="$ci-test = true()">
      <p:identity name="i1">
        <p:input port="source">
          <p:pipe port="result" step="meta-file-uri"/>
        </p:input>
      </p:identity>
      <p:add-attribute attribute-name="local-href" match="/c:result" name="change-path">
        <p:with-option name="attribute-value" select="$target-dir"/>
      </p:add-attribute>
    </p:when>
    <p:otherwise>
      <p:identity name="i2">
        <p:input port="source">
          <p:pipe port="result" step="meta-file-uri"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

  <tr:store-debug pipeline-step="metadata/04_path">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:try name="try-load-titlepage-meta">
    <p:group>
      <p:output port="result"/>
      <p:variable name="titlepage-meta-href" select="/c:result/@local-href"/>
      <p:variable name="titlepage-meta-dir-href" select="replace($titlepage-meta-href, '^(.+/).+?$', '$1')"/>

      <cx:message>
        <p:with-option name="message" select="'[info] load titlepage-meta: ', $titlepage-meta-href"/>
      </cx:message>

      <p:choose name="which-meta">
      
        <p:when test="/c:result/@local-href[contains(., '.meta.xml')]"> 
        <p:xpath-context><p:pipe port="result" step="meta-file-uri"></p:pipe></p:xpath-context>
          <p:documentation>meta.xml</p:documentation>

          <cxf:copy name="copy-dtd" href="../schema/PropList-1.0.dtd" fail-on-error="true"> 
            <p:with-option name="target" select="concat($titlepage-meta-dir-href, 'PropList-1.0.dtd')"/>
          </cxf:copy>
          
          <p:load name="load-titlepage-meta" dtd-validate="true" cx:depends-on="copy-dtd">
            <p:with-option name="href" select="$titlepage-meta-href"/>
          </p:load>
        </p:when>
        <p:otherwise>
          <p:load name="load-titlepage-meta-klopotek">
            <p:with-option name="href" select="$titlepage-meta-href"/>
          </p:load>
        </p:otherwise>
      </p:choose>

    </p:group>
    <p:catch>
      <p:output port="result"/>
      
      <cxf:copy href="../schema/PropList-1.0.dtd"> 
        <p:with-option name="target" select="'PropList-1.0.dtd'"/>
      </cxf:copy>
      
      <p:load name="load-fallback" href="fallback.meta.xml" dtd-validate="false"/>
      
      <cx:message>
        <p:with-option name="message" select="'[WARNING] could not load metadata... Loading metadata fallback!'"/>
      </cx:message>
      
    </p:catch>
  </p:try> 
  
  <tr:store-debug pipeline-step="metadata/04_titlepage">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:wrap-sequence wrapper="cx:documents" name="meta-wrapped-with-logo-list">
    <p:input port="source">
      <!--<p:pipe port="result" step="try-load-onix"/>-->
      <p:pipe port="result" step="try-load-titlepage-meta"/>
      <p:pipe port="result" step="funder-dir-listing"/>
      <p:pipe port="result" step="logo-dir-listing"/>
    </p:input>
  </p:wrap-sequence>
  
  <tr:store-debug pipeline-step="metadata/05_wrapped">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>
