<?xml version="1.0" encoding="UTF-8"?>
<!--
Documentation of the EAD Relax-NG schema with EAD examples
EAD examples are transformed to HTML
-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
   
  exclude-result-prefixes="rng a"  
>
  <!-- keep this order of import because of a catch all template -->
  <xsl:import href="ead2html.xsl"/>
  <!-- absolute link to the RNG transformation
  <xsl:import href="http://svn.code.sf.net/p/obvil/code/rngdoc/rng2frame.xsl"/>
  -->
  <xsl:import href="../rngdoc/rng2frame.xsl"/>
  <!-- add ead.css -->
  <xsl:param name="css">http://svn.code.sf.net/p/obvil/code/eadfr/ead.css</xsl:param>

  <!-- Global examples  -->
  <xsl:template match="a:example[not(ancestor::a:documentation)]">
    <div class="xml example">
      <xsl:apply-templates mode="xml2html"/>
    </div>
    <div class="ead exhtml">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:transform>
