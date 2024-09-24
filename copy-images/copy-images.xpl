<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="copy-images">
  
  <p:documentation>
    This step is used to copy the images into the output directory 
    and patch the XML filerefs accordingly. 
  </p:documentation>
  
  <p:input port="source" primary="true"/>
  <p:input port="stylesheet"/>
  <p:input port="parameters"/>
  <p:input port="options"/>
  <p:output port="result">
    <p:pipe port="result" step="single-image-scope"/>
  </p:output>
  
  <p:option name="resolution-treshold-px" select="50000000"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri"/>
  <p:option name="fail-on-error" select="'false'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/calabash-extensions/image-props-extension/image-identify-declaration.xpl"/>
  <p:import href="../../../calabash/extensions/transpect/image-transform-extension/image-transform-declaration.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/imagemagick/xpl/imagemagick.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/recursive-directory-list/xpl/recursive-directory-list.xpl"/>
  
  <p:variable name="xml-basename" 
              select="/dbk:hub/dbk:info/dbk:keywordset[@role eq 'hub']/dbk:keyword[@role eq 'source-basename']"/>
  <p:variable name="outdir" 
              select="replace(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'hub']/dbk:keyword[@role eq 'source-dir-uri'], 
                              '^(.+/).+?\.docx.tmp/', '$1')"/>
  <p:variable name="format" select="'jpg'"/>
  <p:variable name="covername" 
              select="(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'titlepage']/dbk:keyword[@role eq 'Cover'][normalize-space()]/text(), 
                      'fallback-cover.jpg')[1]"/>
  
  
  <p:variable name="covername" 
              select="(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'titlepage']/dbk:keyword[@role eq 'Cover'][normalize-space()]/text(), 
                      'fallback-cover.jpg')[1]"/>
  
  
  <tr:store-debug name="debug-before-copy-images" pipeline-step="copy-images/02_before">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
  <p:viewport match="dbk:imagedata[@fileref]" name="single-image-scope">
    
    <cx:message name="msg">
      <p:with-option name="message" select="'[info] ', dbk:imagedata[@fileref]/@fileref, ' => ', $outdir"/>
    </cx:message>
    
    <p:choose name="file-uri">
      <p:when test="matches(dbk:imagedata/@fileref, '^https?://')">
        <p:output port="result"/>
        
        <tr:file-uri name="download-file" fetch-http="true">
          <p:with-option name="filename" select="dbk:imagedata/@fileref"/>
          <p:with-option name="tmpdir" select="concat($outdir, replace(dbk:imagedata/@fileref, '^.+/(.+?)$', '$1'))"/>
        </tr:file-uri>
        
      </p:when>
      <p:otherwise>
        <p:output port="result"/>
        
        <tr:file-uri name="regular-file-uri">
          <p:with-option name="filename" select="dbk:imagedata/@fileref"/>
        </tr:file-uri>
        
      </p:otherwise>
    </p:choose>

    <p:try name="try-imagemagick">
      <p:group>
        <p:variable name="image-href" select="/c:result/@local-href"/>
      
        <!-- check resolution -->
        
        <tr:image-identify name="identify">
          <p:with-option name="href" select="$image-href"/>
        </tr:image-identify>
        
        <p:choose>
          <p:variable name="width" select="replace(/c:results/c:result[@name eq 'width']/@value, 'px$', '')">
            <p:pipe port="report" step="identify"/>
          </p:variable>
          <p:variable name="height" select="replace(/c:results/c:result[@name eq 'height']/@value, 'px$', '')">
            <p:pipe port="report" step="identify"/>
          </p:variable>
          <p:when test="$width * $height &gt; $resolution-treshold-px">
            
            <tr:image-transform name="image-transform">
              <p:with-option name="href" select="$image-href"/>
              <p:with-option name="resize" select="'5000x'"/>
            </tr:image-transform>
            
            <p:store cx:decode="true">
              <p:with-option name="href" select="$image-href"/>
              <p:with-option name="media-type" select="/c:data/@content-type"/>
              <p:input port="source">
                <p:pipe step="image-transform" port="result"/>
              </p:input>
            </p:store>
            
          </p:when>
          <p:otherwise>
            <p:sink/>
          </p:otherwise>
        </p:choose>
        
        <p:identity name="identity-file-uri">
          <p:input port="source">
            <p:pipe port="result" step="file-uri"/>
          </p:input>
        </p:identity>
        
        <tr:imagemagick name="convert-image">
          <p:with-option name="href" select="/c:result/@local-href"/>
          <p:with-option name="outdir" select="$outdir"/>
          <p:with-option name="format" select="$format"/>
          <p:with-option name="imagemagick-options" select="'-colorspace rgb -background white -flatten'"/>
          <p:with-option name="debug" select="$debug"/>
          <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
          <p:with-option name="fail-on-error" select="$fail-on-error"/>   
        </tr:imagemagick>
        
        <p:group>
          <p:variable name="output-path" 
                      select="concat($outdir,
			             '/',
			             $xml-basename,
				     '_',
                                     replace(/c:result/@local-href, '^.+/(.+?)\.[a-z]+$', '$1', 'i'),
                                     '.', 
                                     $format)"/>
    	    <!-- davomat replaces some uncommon characters due to encoding issues -->
    	    <p:variable name="output-path-normalized" select="translate($output-path, '&#x2010;', '-')"/> 
          
          <cx:message>
            <p:with-option name="message" select="concat('[info] move: ', /c:result/@os-path, ' => ', $output-path)"/>
          </cx:message>
          
          <cxf:move cx:depends-on="convert-image" name="move">
            <p:with-option name="href" select="/c:result/@os-path"/>
            <p:with-option name="target" select="$output-path-normalized"/>
            <p:with-option name="fail-on-error" select="$fail-on-error"/>
          </cxf:move>
          
          <p:string-replace match="dbk:imagedata/@fileref" name="replace">
            <p:input port="source">
              <p:pipe port="current" step="single-image-scope"/>
            </p:input>
            <p:with-option name="replace" select="concat('''', $output-path-normalized ,'''')">
              <p:pipe port="result" step="convert-image"/> 
            </p:with-option>
          </p:string-replace>
          
        </p:group>

      </p:group>
      <p:catch>
        
        <p:add-attribute match="dbk:imagedata" attribute-name="c:report" attribute-value="image-conversion-failed" name="add-report-attribute">
          <p:input port="source">
            <p:pipe port="current" step="single-image-scope"/>
          </p:input>
        </p:add-attribute>
        
      </p:catch>
    </p:try>
    
  </p:viewport>  
  
  <tr:store-debug name="debug-after-copy-images" pipeline-step="copy-images/04_copy-images">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
<p:sink/>

 <p:try name="directory-list">
    <p:documentation>In this step a recursive listing of all files in the images directory is done. 
      Those are copied to temp directory afterwards.
    </p:documentation>
    <p:group>
      <p:output port="result">
        <p:pipe port="result" step="image-list"/>
      </p:output>
      <tr:recursive-directory-list name="image-list">
        <p:with-option name="path" select="'/media/cover/trans_full/pdf/'">
          <p:pipe port="parameters" step="copy-images"/>
        </p:with-option>
      </tr:recursive-directory-list>
      <tr:store-debug pipeline-step="copy-images/directory-list-content">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      <p:sink/>
    </p:group>
    <p:catch>
      <p:output port="result">
        <p:pipe port="result" step="directory-failure"/>
      </p:output>
      <p:identity name="directory-failure">
        <p:input port="source">
          <p:inline><c:directory name=""/></p:inline>
        </p:input>
      </p:identity>
<!--      <tr:store-debug pipeline-step="copy-images/directory-list-content">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>-->
      <p:sink/>
    </p:catch>
  </p:try>
  <cx:message name="msg07">
    <p:with-option name="message" select="'####### Copying Cover from media directory: ', $covername"/>
  </cx:message>
  
  <p:viewport match="c:directory[@name = 'pdf']" name="copy-images-from-content-repo" cx:depends-on="msg07">
     <p:variable  name="outdir-print" 
                select="if (/*/c:param[@name = 'run-local']/@value = ('yes', 'true')) 
                        then concat($outdir, '/tex/temp')
                        else concat($outdir, '/temp')">
      <p:pipe port="parameters" step="copy-images"/>
    </p:variable>
    <p:variable  name="file-prefix" 
                select="if (/*/c:param[@name = 'run-local']/@value = ('yes', 'true')) 
                        then 'file:/'
                        else ''">
      <p:pipe port="parameters" step="copy-images"/>
   </p:variable>
   <p:variable name="epub-cover-path" 
                select="concat(replace(/c:param-set/c:param[@name eq 's9y1-path']/@value, 'file:///', 'file:/'), 'epub/')">
      <p:pipe port="parameters" step="copy-images"/>
   </p:variable>
<!--         <p:variable  name="covername" 
                select="(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'titlepage']/dbk:keyword[@role eq 'Cover'][normalize-space()]/text(), 'nocover.jpg')[1]">
      <p:pipe port="source" step="copy-images"/>
    </p:variable>-->
    
    
    <p:variable name="epub-cover-path" 
                select="concat(replace(/c:param-set/c:param[@name eq 's9y1-path']/@value, 'file:///', 'file:/'), 'epub/')">
      <p:pipe port="parameters" step="copy-images"/>
   </p:variable>
<!--         <p:variable  name="covername" 
                select="(/dbk:hub/dbk:info/dbk:keywordset[@role eq 'titlepage']/dbk:keyword[@role eq 'Cover'][normalize-space()]/text(), 'nocover.jpg')[1]">
      <p:pipe port="source" step="copy-images"/>
    </p:variable>-->
    
    
    <p:try name="copy-versioned-images">
      
      <p:group>
        <p:output port="result">
          <p:empty/>
        </p:output>
        
        <tr:file-uri name="file-uri2">
          <p:with-option name="filename" select="replace(
                                                          concat(
                                                                  c:directory[@name = 'pdf']/@xml:base, 
                                                                  c:directory[@name = 'pdf']/c:file[@name = $covername]/@name
                                                                 ), 
                                                          'file:///', 
                                                          'file:/'
                                                          )"/>
        </tr:file-uri>
        
       <tr:store-debug pipeline-step="copy-images/cover-file-uri">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
        
        <cx:message name="copy-from-svn-msg2">
          <p:with-option name="message" select="'[info] copy: ', concat($file-prefix, /c:result/@os-path), ' => ', concat($file-prefix, $outdir-print, '/cover/', /c:result/@lastpath-os), ' and ' 
            concat($epub-cover-path, /c:result/@lastpath-os')">
            <p:pipe port="result" step="file-uri2"/>
          </p:with-option>
        </cx:message>
    
        <p:sink/>
        
        <cxf:copy name="copy-files">
          <p:with-option name="href" select="concat($file-prefix, /c:result/@os-path)">
            <p:pipe port="result" step="file-uri2"/>
          </p:with-option>
          <p:with-option name="target" 
            select="concat($outdir-print, '/cover/', /c:result/@lastpath-os)">
            <p:pipe port="result" step="file-uri2">
              <p:documentation>add a Cover directory to prevent image from being deleted in temp directory by Makefile</p:documentation>
            </p:pipe>
            
          </p:with-option>
          <p:with-option name="fail-on-error" select="$fail-on-error"/>
        </cxf:copy>
        
      <!-- copy epub cover -->
        <cxf:copy name="copy-epub-files">
          <p:with-option name="href" select="concat($file-prefix, /c:result/@os-path)">
            <p:pipe port="result" step="file-uri2"/>
          </p:with-option>
          <p:with-option name="target" 
            select="concat($epub-cover-path, /c:result/@lastpath-os')">
            <p:pipe port="result" step="file-uri2"/>
          </p:with-option>
          <p:with-option name="fail-on-error" select="$fail-on-error"/>
        </cxf:copy>
        
      </p:group>
      <p:catch>
        <p:output port="result">
          <p:empty/>
        </p:output>
        <cx:message name="msg7">
          <p:with-option name="message" select="'[error] Image copying from working copy failed for: ', c:directory[@name = 'pdf']/c:file[@name = $covername]/@name">
            <p:pipe port="current" step="copy-images-from-content-repo"/>
          </p:with-option>
        </cx:message>
        <p:sink/>
      </p:catch>
    </p:try>
  </p:viewport>
 
   <p:sink/>
</p:declare-step>
