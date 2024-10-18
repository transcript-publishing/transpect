<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  version="2.0" exclude-result-prefixes="#all">
  
  <xsl:variable name="license-texts" as="element(Licenses)">
    <Licenses>
      <License id="BY-NC-ND">
        <Image url="by-nc-nd.eu.eps" />
        <Link url="https://creativecommons.org/licenses/by-nc-nd/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 (BY-NC-ND) which means that the text may be used for non-commercial purposes, provided credit is given to the author. For details go to https://creativecommons.org/licenses/by-nc-nd/4.0/<br/>
            To create an adaptation, translation, or derivative of the original work and for commercial use, further permission is required and can be obtained by contacting rights@transcript-publishing.com<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.</Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 Lizenz (BY-NC-ND). Diese Lizenz erlaubt die private Nutzung, gestattet aber keine Bearbeitung und keine kommerzielle Nutzung. Weitere Informationen finden Sie unter https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de<br/>
            Um Genehmigungen für Adaptionen, Übersetzungen, Derivate oder Wiederverwendung zu kommerziellen Zwecken einzuholen, wenden Sie sich bitte an rights@transcript-publishing.com<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY-NC-ND.</Text>
        </Texts>
      </License>
      <License id="BY-NC-SA">
        <Image url="by-nc-sa.eu.eps" />
        <Link url="https://creativecommons.org/licenses/by-nc-sa/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (BY-NC-SA) license, which means that the text may be shared and redistributed, provided credit is given to the author for non-commercial purposes only.<br/>
            Permission to use the text for commercial purposes can be obtained by contacting rights@transcript-publishing.com<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution-NonCommercial-ShareAlike 4.0 Lizenz (BY-NC-SA). Diese Lizenz erlaubt unter Voraussetzung der Namensnennung des Urhebers die Bearbeitung, Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium zu nicht-kommerziellen Zwecken, sofern der neu entstandene Text unter derselben Lizenz wie das Original verbreitet wird. (Lizenz-Text: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de)<br/>
            Um Genehmigungen für die Wiederverwendung zu kommerziellen Zwecken einzuholen, wenden Sie sich bitte an rights@transcript-verlag.de<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.</Text>
          <Text lang="es">Spanish text for BY-NC-SA.</Text>
        </Texts>
      </License>
      <License id="BY-NC">
        <Image url="by-nc.eu.eps" />
        <Link url="https://creativecommons.org/licenses/by-nc/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution-Non Commercial 4.0 (BY-NC) license, which means that the text may be may be remixed, build upon and be distributed, provided credit is given to the author, but may not be used for commercial purposes. For details go to: https://creativecommons.org/licenses/by-nc/4.0/<br/>
            Permission to use the text for commercial purposes can be obtained by contacting rights@transcript-publishing.com<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution-Non-Commercial 4.0 Lizenz (BY-NC). Diese Lizenz erlaubt unter Voraussetzung der Namensnennung des Urhebers die Bearbeitung, Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium ausschliesslich für nicht-kommerzielle Zwecke. (Lizenztext: https://creativecommons.org/licenses/by-nc/4.0/deed.de)<br/>
            Um Genehmigungen für die Wiederverwendung zu kommerziellen Zwecken einzuholen, wenden Sie sich bitte an rights@transcript-publishing.com<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY-NC.</Text>
        </Texts>
      </License>
      <License id="BY-ND">
        <Image url="by-nd.eps" />
        <Link url="https://creativecommons.org/licenses/by-nd/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution-NoDerivatives 4.0 (BY-ND) license, which means that the text may be shared and redistributed, provided credit is given to the author, but may not be remixed, transformed or build upon. For details go to https://creativecommons.org/licenses/by-nd/4.0/<br/>
            To create an adaptation, translation, or derivative of the original work, further permission is required and can be obtained by contacting rights@transcript-publishing.com<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution-NoDerivatives 4.0 Lizenz (BY-ND). Diese Lizenz erlaubt unter Voraussetzung der Namensnennung des Urhebers die Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium für beliebige Zwecke, auch kommerziell, gestattet aber keine Bearbeitung. (Lizenztext: https://creativecommons.org/licenses/by-nd/4.0/deed.de)<br/>
            Um Genehmigungen für Adaptionen, Übersetzungen oder Derivate einzuholen, wenden Sie sich bitte an rights@transcript-publishing.com<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY-ND.</Text>
        </Texts>
      </License>
      <License id="BY-SA">
        <Image url="by-sa.eps" />
        <Link url="https://creativecommons.org/licenses/by-sa/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 (BY-SA) which means that the text may be remixed, build upon and be distributed, provided credit is given to the author and that copies or adaptations of the work are released under the same or similar license.<br/>
            https://creativecommons.org/licenses/by-sa/4.0/<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution-ShareAlike 4.0 Lizenz (BY-SA). Diese Lizenz erlaubt unter Voraussetzung der Namensnennung des Urhebers die Bearbeitung, Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium für beliebige Zwecke, auch kommerziell, sofern der neu entstandene Text unter derselben Lizenz wie das Original verbreitet wird.<br/>
            https://creativecommons.org/licenses/by-sa/4.0/<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY-SA.</Text>
        </Texts>
      </License>
      <License id="BY">
        <Image url="by.eps" />
        <Link url="https://creativecommons.org/licenses/by/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons Attribution 4.0 (BY) license, which means that the text may be remixed, transformed and built upon and be copied and redistributed in any medium or format even commercially, provided credit is given to the author.<br/>
            https://creativecommons.org/licenses/by/4.0/<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons Attribution 4.0 Lizenz (BY). Diese Lizenz erlaubt unter Voraussetzung der Namensnennung des Urhebers die Bearbeitung, Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium für beliebige Zwecke, auch kommerziell. (Lizenztext: https://creativecommons.org/licenses/by/4.0/deed.de)<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY.</Text>
        </Texts>
      </License>
    </Licenses>
  </xsl:variable>
  
</xsl:stylesheet>