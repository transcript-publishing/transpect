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
            This work is licensed under the Creative Commons License BY-NC-ND 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de">https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY-NC-ND 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de">https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de</Link>.<br/>
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
            This work is licensed under the Creative Commons License BY-NC-SA 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by-nc-sa/4.0/">https://creativecommons.org/licenses/by-nc-sa/4.0/</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY-NC-SA 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by-nc-sa/4.0/">https://creativecommons.org/licenses/by-nc-sa/4.0/</Link>.<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY-NC-SA.</Text>
        </Texts>
      </License>
      <License id="BY-NC">
        <Image url="by-nc.eu.eps" />
        <Link url="https://creativecommons.org/licenses/by-nc/4.0/" />
        <Texts>
          <Text lang="en">
            This work is licensed under the Creative Commons License BY-NC 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by-nc/4.0/">https://creativecommons.org/licenses/by-nc/4.0/</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY-NC 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by-nc/4.0/">https://creativecommons.org/licenses/by-nc/4.0/</Link>.<br/>
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
            This work is licensed under the Creative Commons License BY-ND 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by-nd/4.0/">https://creativecommons.org/licenses/by-nd/4.0/</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY-ND 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by-nd/4.0/">https://creativecommons.org/licenses/by-nd/4.0/</Link>.<br/>
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
            This work is licensed under the Creative Commons License BY-SA 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by-sa/4.0/">https://creativecommons.org/licenses/by-sa/4.0/</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY-SA 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by-sa/4.0/">https://creativecommons.org/licenses/by-sa/4.0/</Link>.<br/>
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
            This work is licensed under the Creative Commons License BY 4.0. For the full license terms, please visit the URL <Link url="https://creativecommons.org/licenses/by/4.0/">https://creativecommons.org/licenses/by/4.0/</Link>.<br/>
            Creative Commons license terms for re-use do not apply to any content (such as graphs, figures, photos, excerpts, etc.) not original to the Open Access publication and further permission may be required from the rights holder. The obligation to research and clear permission lies solely with the party re-using the material.
          </Text>
          <Text lang="de">
            Dieses Werk ist unter der Creative-Commons-Lizenz BY 4.0 lizenziert. Für die ausformulierten Lizenzbedingungen besuchen Sie bitte die URL <Link url="https://creativecommons.org/licenses/by/4.0/">https://creativecommons.org/licenses/by/4.0/</Link>.<br/>
            Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.
          </Text>
          <Text lang="es">Spanish text for BY.</Text>
        </Texts>
      </License>
      <License id="CC0">
        <Image url="cc0.eu.png" />
        <Link url="https://creativecommons.org/publicdomain/zero/1.0/deed.de" />
        <Texts>
          <Text lang="de">
            Dieses Werk ist lizenziert unter der Creative Commons 1.0 Universal Lizenz (CC0 1.0). Diese Lizenz erlaubt die freie Bearbeitung, Vervielfältigung und Verbreitung des Materials in jedem Format oder Medium für beliebige Zwecke, auch kommerziell, ohne jegliche Einschränkung.
          </Text>
        </Texts>
      </License>
    </Licenses>
  </xsl:variable>
  
</xsl:stylesheet>