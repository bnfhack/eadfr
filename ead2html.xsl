<?xml version="1.0" encoding="UTF-8"?>
<!--
<h1>Transformation d'EAD vers HTML (<a href="ead_html.xsl">ead_html.xsl</a>)</h1>

© 2009, 2010, 2012, 2015 <a href="#" onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'">Frédéric Glorieux</a>,
<a href="http://www.cecill.info/licences/Licence_CeCILL-C_V2-fr.html">licence CeCILL</a>



-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:ead="urn:isbn:1-931666-22-9"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:dc="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"

  exclude-result-prefixes="a dc ead rdf rdfs xlink"

  xmlns:exslt="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:saxon="http://icl.com/saxon"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="exslt str saxon date"
>
  <xsl:output indent="yes" method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
  <!-- Pour les statistiques -->
  <xsl:key name="name" match="*" use="name()"/>
  <!-- Langue pour les intitulés -->
  <xsl:param name="lang" select="'fr'"/>
  <!-- TODO, fichier de messages supplémentaires -->
  <xsl:param name="rdfs"/>
  <!-- Classe de body -->
  <xsl:param name="class">ead</xsl:param>
  <!-- Extension des fichiers source -->
  <xsl:param name="_xml">.xml</xsl:param>
  <!-- Extensions des fichiers de destination -->
  <xsl:param name="_html">.html</xsl:param>
  <!-- Préfixe des liens de destination -->
  <xsl:param name="get"/>
  <xsl:param name="xslbase">
    <xsl:call-template name="xslbase"/>
  </xsl:param>
  
  <!-- Chargement des fichiers de messages. -->
  <xsl:variable name="ead.rdfs" select="document('ead.rdfs')/*/rdf:Property"/>
  <!-- Conteneurs de liens blocs -->
  <xsl:variable name="desc.ref">  bibliography  controlaccess otherfindaid  relatedmaterial  separatedmaterial    </xsl:variable>
  <!-- Variables outil -->
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quote">"</xsl:variable>
  <!-- élément voulu en sortie -->
  <xsl:variable name="html">html</xsl:variable>
  <xsl:variable name="nav">nav</xsl:variable>
  <xsl:variable name="article">article</xsl:variable>
  <xsl:param name="el" select="$nav"/>
  <!--
<h2>Traitements de base</h2>
  -->
  <!-- Racine HTML, TODO, rendre le thème personnalisable -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$el = $nav">
        <xsl:call-template name="toc"/>
      </xsl:when>
      <xsl:when test="$el = $article">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <!-- TODO DOCTYPE html5 -->
        <html>
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <title>
              <!-- Suffisant ? -->
              <xsl:value-of select="normalize-space(//titleproper)"/>
            </title>
            <link rel="stylesheet" type="text/css" href="{$xslbase}ead.css"/>
          </head>
          <body class="{$class}">
            <div id="center">
              <aside id="aside">
                <xsl:call-template name="toc"/>
              </aside>
              <main id="main">
                <xsl:apply-templates/>
              </main>
            </div>
            <script src="{$xslbase}Tree.js">//</script>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Modèle par défaut interceptant les éléments non traités -->
  <xsl:template match="*">
    <blockquote style="margin:0 0 0 1em">
      <code style="color:red">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:for-each select="@*">
          <xsl:text> </xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
      </code>
      <xsl:apply-templates/>
      <code style="color:red">&lt;/<xsl:value-of select="name()"/>&gt;</code>
    </blockquote>
  </xsl:template>
  <!-- Éléments retenus. -->
  <xsl:template match="ead:controlaccess | ead:dsc[normalize-space(.)=''] | ead:runner | ead:eadid "/>
  <!--  Éléments traversés sans traces -->
  <xsl:template match="ead:subarea | ead:event | ead:addressline ">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Sections uniques dont le nom est identifiant -->
  <xsl:template match=" ead:ead">
   <article class="{local-name()}">
     <xsl:apply-templates/>
   </article>
  </xsl:template>
  <xsl:template match=" ead:archdesc | ead:eadheader | ead:filedesc | ead:frontmatter | ead:profiledesc | ead:publicationstmt | ead:sponsor | ead:titlestmt ">
   <div class="{local-name()}">
     <xsl:apply-templates/>
   </div>
  </xsl:template>
  <!-- Sections à identifier -->
  <xsl:template match=" ead:c | ead:c01 | ead:c02 | ead:c03 | ead:c04 | ead:c05 | ead:c06 | ead:c07 | ead:c08 | ead:c09 | ead:c10 | ead:c11 | ead:c12 ">
    <xsl:variable name="level" select="format-number(count(ancestor-or-self::*[ancestor::ead:dsc]), '00')"/>
    <section class="c c{$level}">
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </section>
  </xsl:template>
  <!-- Sections génériques -->
  <xsl:template match=" ead:dsc ">
    <div class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>
  <!-- Groupes de paragraphes avec intitulé -->
  <xsl:template match="ead:accessrestrict | ead:accruals | ead:acqinfo | ead:altformavail | ead:appraisal | ead:arrangement | ead:bioghist | a:example//ead:controlaccess | ead:custodhist | ead:descgrp | ead:editionstmt | ead:fileplan  | ead:frontmatter/ead:div | ead:index | ead:c/ead:note | ead:c01/ead:note | ead:c02/ead:note | ead:c03/ead:note | ead:c04/ead:note | ead:c05/ead:note | ead:c06/ead:note | ead:c07/ead:note | ead:c08/ead:note | ead:c09/ead:note | ead:c10/ead:note | ead:c11/ead:note | ead:c12/ead:note | ead:notestmt | ead:odd | ead:originalsloc | ead:otherfindaid | ead:phystech | ead:prefercite | ead:processinfo | ead:publicationstmt | ead:relatedmaterial | ead:revisiondesc | ead:scopecontent | ead:separatedmaterial | ead:seriesstmt | ead:userestrict">
    <xsl:param name="label">
      <xsl:choose>
        <!-- en cas de bloc imbriqué, ne pas générer de label automatiquement -->
        <xsl:when test="name() = name(..)">
          <xsl:call-template name="ead-label">
            <xsl:with-param name="id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="ead-label"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <blockquote class="{local-name()}">
      <xsl:if test="normalize-space($label) != ''">
        <span class="label">
          <xsl:copy-of select="$label"/>
        </span>
      </xsl:if>
      <xsl:apply-templates select="*[local-name() != 'head' or @althead] "/>
    </blockquote>
  </xsl:template>
  <!-- bibliographie de premier niveau -->
  <xsl:template match="ead:bibliography">
    <blockquote class="{local-name()}">
      <span class="label">
        <xsl:call-template name="ead-label"/>
      </span>
      <xsl:call-template name="bibliography"/>
     </blockquote>
  </xsl:template>
  <!-- Couper les titres de biblio de premier niveau -->
  <xsl:template match="ead:bibliography/ead:head">
    <xsl:choose>
      <xsl:when test="count(ancestor::ead:bibliography) &gt; 1">
        <xsl:call-template name="div"/>
      </xsl:when>
      <xsl:when test="@althead">
        <xsl:call-template name="div"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- biblio imbriquées -->
  <xsl:template match="ead:bibliography//ead:bibliography" name="bibliography">
    <xsl:apply-templates select="*[local-name() != 'bibref'][local-name() != 'bibliography']"/>
    <ul class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:for-each select="ead:bibref | ead:bibliography">
        <xsl:choose>
          <xsl:when test="local-name()='bibliography'">
            <li class="{local-name()}">
              <xsl:apply-templates select="."/>
            </li>
          </xsl:when>
          <xsl:otherwise>
              <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- Paragraphes avec intitulé -->
  <xsl:template match="ead:author | ead:creation | ead:descrules | ead:langusage | ead:sponsor  ">
    <blockquote class="{local-name()}">
      <span class="label">
        <xsl:call-template name="ead-label"/>
      </span>
      <p>
        <xsl:apply-templates/>
      </p>
    </blockquote>
  </xsl:template>
  <!-- Groupes de paragraphes -->
  <xsl:template match="ead:daodesc">
    <blockquote class="{local-name()}">
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <!-- Paragraphes  -->
  <xsl:template match=" ead:abstract | ead:container | ead:editionstmt/ead:edition | ead:langmaterial | ead:legalstatus | ead:origination | ead:p | ead:physloc | ead:did/ead:repository | ead:seriesstmt/ead:num | ead:publicationstmt/ead:n | ead:did/ead:unitdate | ead:did/ead:unitid ">
   <p class="{local-name()}">
     <xsl:apply-templates/>
   </p>
  </xsl:template>
  <!-- Blocs courts -->
  <xsl:template match="ead:head | ead:head01 | ead:head02 | ead:listhead | ead:publicationstmt/ead:publisher | ead:subtitle | ead:publicationstmt/ead:date | ead:change/ead:date " name="div">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Mots sans typographie spécifique -->
  <xsl:template match="ead:bibseries | ead:date | ead:dimensions | ead:edition | ead:expan | ead:extent | ead:language | ead:num | ead:physfacet | ead:publisher | ead:unitdate | ead:unitid | ead:repository" name="span">
    <span class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </span>
  </xsl:template>
  <!-- Macro access (indexation), avec mise en bloc dans certains contextes  -->
  <xsl:template match="ead:corpname | ead:famname | ead:function | ead:genreform | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subject ">
    <xsl:choose>
      <xsl:when test="contains($desc.ref, concat(' ',local-name(..),' ')) ">
        <div class="{local-name()}">
          <xsl:apply-templates select="node()|@*"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <span class="{local-name()}">
          <xsl:apply-templates select="node()|@*"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Description physique, texte libre ou structuré -->
  <xsl:template match="ead:physdesc">

      <xsl:choose>
        <xsl:when test="text()[normalize-space(.)!='']">
          <span class="label">
            <xsl:call-template name="ead-label"/>
          </span>
          <p class="physdesc">
            <xsl:apply-templates/>
          </p>
        </xsl:when>
        <!-- selon ce que décrit la documentation du schéma -->
        <xsl:when test="ead:dimensions | ead:extent | ead:genreform | ead:physfacet">
          <span class="label">
            <xsl:call-template name="ead-label"/>
          </span>
          <ul class="physdesc">
            <xsl:for-each select="*">
              <li class="{local-name()}">
                <xsl:apply-templates/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <!-- ? -->
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  <!--
<h2>Bibliographie</h2>
  -->
  <!-- Titres -->
  <xsl:template match="ead:title | ead:unittitle">
    <xsl:choose>
      <xsl:when test="contains($desc.ref, concat(' ',local-name(..),' ')) ">
        <div class="{local-name()}">
          <xsl:apply-templates select="@*"/>
          <xsl:call-template name="fix-indent"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <em class="{local-name()}">
          <xsl:apply-templates select="@*"/>
          <xsl:call-template name="fix-indent"/>
        </em>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Pour éviter certains effets désagréables d"indentation dans des inlines en textes mêlés, par exemple un titre dans une référence bibliographique
où un saut de ligne empêche de lui coller un point qui doit suivre.


<bibref>
    <persname role="author">Dessert, Daniel</persname>
    <title>
        <emph render="italic">Argent, pouvoir et société au Grand Siècle</emph>
    </title>
    <imprint>
        <geogname>Paris</geogname>
        <publisher>Fayard</publisher>
        <date type="publication" normal="1984">1984</date>
    </imprint>
</bibref>

  -->
  <xsl:template name="fix-indent">
    <xsl:for-each select="*|text()">
      <xsl:variable name="norm" select="normalize-space(.)"/>
      <xsl:choose>
        <!-- au milieu, laisser courir -->
        <xsl:when test="position() != last() and position() != 1">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- Saut de ligne au début, retenir -->
        <xsl:when test="position() = 1 and $norm =''"/>
        <!-- Saut de ligne en fin, retenir -->
        <xsl:when test="position() = last() and $norm =''"/>
        <!-- texte seul ? normaliser ? -->
        <xsl:when test="name(.) = '' and (position() = last() or position() = 1)">
          <xsl:value-of select="$norm"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="ead:linkgrp | ead:ptrgrp">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="contains($desc.ref, concat(' ',local-name(..),' ')) ">div</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
        <xsl:text>, </xsl:text>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <!-- Élément bibliographique ponctuable -->
  <xsl:template match="ead:archref | ead:bibref">
    <xsl:variable name="content">
      <xsl:choose>
        <!-- ponctuation inter balise, sortir tel quel -->
        <xsl:when test="text()[contains(., '.') or contains(., ',')]">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- ponctuation en fin d'enfants (mauvaise pratique mais semble résulter d'exports automatique de MARC, sortir tel quel -->
        <xsl:when test="*[substring(normalize-space(.), string-length(normalize-space(.))) = ',']">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- à ponctuer -->
        <xsl:otherwise>
          <xsl:for-each select="text()|*">
            <xsl:variable name="end" select="substring(normalize-space(.), string-length(normalize-space(.)))"/>
            <xsl:choose>
              <!-- du texte non vide, sortir -->
              <xsl:when test="normalize-space(.) != '' and name(.) =''">
                <xsl:apply-templates select="."/>
              </xsl:when>
              <!-- probablement saut de ligne, retenir -->
              <xsl:when test="name(.) =''"/>
              <!-- l'élément finit déjà par un point -->
              <xsl:when test="$end =',' or $end = '.' or $end = ':'">
                <xsl:apply-templates select="."/>
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:when test="position() = last()">
                <xsl:apply-templates select="."/>
                <xsl:text>.</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="."/>
                <xsl:text>. </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- En cas de lien dans un div -->
    <xsl:variable name="a">
      <xsl:choose>
        <xsl:when test="@href">
          <a class="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="$content"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- dans un bloc descriptif -->
      <xsl:when test="contains($desc.ref, concat(' ',local-name(..),' ')) ">
        <div class="{local-name()}">
          <xsl:apply-templates select="@*[local-name() != 'href']"/>
          <xsl:copy-of select="$a"/>
        </div>
      </xsl:when>
      <!-- item de liste dans une biblio -->
      <xsl:when test="local-name(..)='bibliography'">
        <li class="{local-name()}">
          <xsl:apply-templates select="@*[local-name() != 'href']"/>
          <xsl:copy-of select="$a"/>
        </li>
      </xsl:when>
      <!-- déjà emballé dans un <a>, pas la peine d'en rajouter -->
      <xsl:when test="@href">
        <xsl:copy-of select="$a"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="{local-name()}">
          <xsl:apply-templates select="@*"/>
          <xsl:copy-of select="$a"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Adresse éditoriale à ponctuer si nécessaire -->
  <xsl:template match="ead:imprint">
    <span class="imprint">
      <xsl:choose>
        <!-- ponctuation en fin d'enfants (mauvaise pratique mais semble résulter d'exports automatique de MARC -->
        <xsl:when test="*[substring(normalize-space(.), string-length(normalize-space(.))) = ',']">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- à ponctuer -->
        <xsl:when test="not(text()[normalize-space(.) != '']) and ead:geogname and ead:publisher and ead:date">
          <xsl:apply-templates select="ead:geogname/node()"/>
          <xsl:text> : </xsl:text>
          <xsl:apply-templates select="ead:publisher/node()"/>
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="ead:date/node()"/>
        </xsl:when>
        <!-- à ponctuer -->
        <xsl:when test="not(text()[normalize-space(.) != ''])">
          <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
            <xsl:choose>
              <xsl:when test="position() = last()">.</xsl:when>
              <xsl:otherwise>, </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!--

<h2>Correspondance HTML</h2>

  -->
  <!-- Même nom EAD et HTML -->
  <xsl:template match=" ead:abbr | ead:blockquote | ead:div | ead:label | ead:p | ead:table | ead:tbody | ead:tgroup | ead:thead ">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="ead:table/ead:head">
    <caption>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>
  <xsl:template match="ead:row">
    <tr>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <xsl:template match="ead:entry">
    <td>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  <!-- Pas encore d'interprétation de @colname, @colnum, @colsep, @rowsep -->
  <xsl:template match="ead:colspec">
    <colgroup>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </colgroup>
  </xsl:template>
  <xsl:template match="@align | @char | @charoff ">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="@colwidth ">
    <xsl:attribute name="width">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- Par défaut, ne pas sortir les attributs -->
  <xsl:template match="@*"/>
  <!-- Valeurs développées -->
  <xsl:template match="@expan | @abbr | @normal | @xlink:label | @xlink:title ">
    <xsl:attribute name="title">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <!-- Attributs XML standard recopiés -->
  <xsl:template match="@xml:lang | @xml:id | @xml:base ">
    <xsl:copy-of select="."/>
  </xsl:template>
  <!-- Identifiant -->
  <xsl:template match="@id">
    <xsl:attribute name="id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- Langue -->
  <xsl:template match="@langcode">
    <xsl:attribute name="lang">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- Typographie caractères -->
  <xsl:template match="ead:emph">
    <xsl:choose>
      <xsl:when test="@render='bold'">
        <b>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </b>
      </xsl:when>
      <xsl:when test="@render='italic'">
        <i>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </i>
      </xsl:when>
      <xsl:when test="@render='nonproport'">
        <tt>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </tt>
      </xsl:when>
      <xsl:when test="@render='sub'">
        <sub>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </sub>
      </xsl:when>
      <xsl:when test="@render='super'">
        <sup>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:when test="@render='underline'">
        <u>
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </u>
      </xsl:when>
      <xsl:when test="contains(@render, 'quote') ">
        <q class="{@render}">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </q>
      </xsl:when>
      <xsl:when test="@render='altrender'">
        <em class="{@altrender}">
          <xsl:apply-templates select="@id"/>
          <xsl:apply-templates/>
        </em>
      </xsl:when>
      <xsl:when test="@render='bolditalic'">
        <em class="bolditalic b">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </em>
      </xsl:when>
      <xsl:when test="@render='boldsmcaps'">
        <b class="boldsmcaps sc">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </b>
      </xsl:when>
      <xsl:when test="@render='boldunderline'">
        <b class="boldunderline u">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </b>
      </xsl:when>
      <xsl:when test="@render='smcaps'">
        <span class="smcaps">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <em class="{@render}">
          <xsl:apply-templates select="@id | @altrender"/>
          <xsl:apply-templates/>
        </em>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Saut de ligne -->
  <xsl:template match="ead:lb">
    <br/>
  </xsl:template>
  <!-- Titres -->
  <xsl:template match="ead:titleproper">
    <h1>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="../../../eadid">
        <xsl:value-of select="../../../eadid"/>
        <xsl:text> — </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  <!-- <h3>Listes</h3>
Sortir les titres, procéder les items de manière contrôlée, en tenant compte des listes
imbriquées.
  -->
  <xsl:template match="ead:eventgrp | ead:list ">
    <xsl:apply-templates select="head | listhead"/>
    <ul class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:for-each select="*[local-name() != 'head' and local-name() != 'listhead']">
        <li class="{local-name()}">
          <xsl:choose>
            <xsl:when test="contains(' eventgroup list bibliography ', concat(' ', local-name(), ' '))">
              <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <!-- liste tabulaire -->
  <xsl:template match="ead:chronlist">
    <table class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="head "/>
      <xsl:if test="ead:listhead | ead:address | ead:chronlist | ead:list | ead:note | ead:table | ead:blockquote | ead:p">
        <thead>
          <xsl:if test="ead:address | ead:chronlist | ead:list | ead:note | ead:table | ead:blockquote | ead:p">
            <tr>
              <td colspan="2">
                <xsl:apply-templates select="ead:address | ead:chronlist | ead:list | ead:note | ead:table | ead:blockquote | ead:p"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:apply-templates select="ead:listhead"/>
        </thead>
      </xsl:if>
      <tbody>
        <xsl:apply-templates select="ead:chronitem"/>
      </tbody>
    </table>
  </xsl:template>
  <xsl:template match="ead:chronlist/ead:head | ead:index/ead:head">
    <caption class="{local-name()}">
      <xsl:apply-templates select="@* | node()"/>
    </caption>
  </xsl:template>
  <xsl:template match="ead:listhead">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <xsl:template match="ead:head01 | ead:head02">
    <th class="{local-name()}">
      <xsl:apply-templates/>
    </th>
  </xsl:template>
  <!-- item de chronologie -->
  <xsl:template match="ead:chronitem">
    <tr class="{local-name()}">
      <th>
        <xsl:apply-templates select="ead:date/node()"/>
      </th>
      <td>
        <xsl:apply-templates select="ead:event/node() | ead:eventgrp"/>
      </td>
    </tr>
  </xsl:template>
  <!-- Index -->
  <xsl:template match="ead:index//ead:index">
    <div class="index">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- item d'index -->
  <xsl:template match="ead:indexentry">
    <div class="indexentry">
      <xsl:apply-templates select="ead:corpname | ead:famname | ead:geogname | ead:name | ead:occupation | ead:persname | ead:subject | ead:genreform | ead:function | ead:title | ead:namegrp"/>
      <xsl:if test="ead:ptrgrp | ead:ptr | ead:ref">
        <xsl:text> : </xsl:text>
        <xsl:apply-templates select="ead:ptrgrp | ead:ptr | ead:ref"/>
      </xsl:if>
      <xsl:apply-templates select="ead:indexentry"/>
    </div>
  </xsl:template>
  <!-- Groupe de noms dans une entrée d'index -->
  <xsl:template match="ead:namegrp">
    <xsl:for-each select="*">
      <xsl:variable name="end" select="substring(normalize-space(.), string-length(normalize-space(.)))"/>
      <xsl:apply-templates/>
      <xsl:choose>
        <!-- dernier, pris en main plus haut selon qu'il y ait ou pas pointeur -->
        <xsl:when test="position()=last()"/>
        <!-- ponctuation déjà dans les balises -->
        <xsl:when test="$end='.' or $end=';' or $end=','"/>
        <!-- il y a déjà une virgule dedans, donc point virgule -->
        <xsl:when test="contains(., ',')"> ; </xsl:when>
        <!-- séparateur virgule par défaut -->
        <xsl:otherwise>, </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!-- Liste ordonnée -->
  <xsl:template match="ead:list[@type='ordered']">
    <ol>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>
  <!-- liste de changements -->
  <xsl:template match="ead:change">
    <xsl:apply-templates select="ead:date"/>
    <ul class="{local-name()}">
      <xsl:apply-templates select="ead:item"/>
    </ul>
  </xsl:template>
  <!-- Items des listes -->
  <xsl:template match="ead:item | ead:eventgrp/ead:event ">
    <li class="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <!-- Liste de définition -->
  <xsl:template match="ead:list[ead:defitem]">
    <xsl:apply-templates select="ead:head"/>
    <dl>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="ead:listhead">
        <dt class="head01">
          <xsl:apply-templates select="ead:listhead/ead:head01/node()"/>
        </dt>
        <dd class="head02">
          <xsl:apply-templates select="ead:listhead/ead:head02/node()"/>
        </dd>
      </xsl:if>
      <xsl:apply-templates select="ead:defitem"/>
    </dl>
  </xsl:template>
  <xsl:template match="ead:defitem">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="ead:defitem/ead:label">
    <dt>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </dt>
  </xsl:template>
  <xsl:template match="ead:defitem/ead:item">
    <dd>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>
  <!-- -->
  <xsl:template match="ead:address">
    <address>
      <xsl:for-each select="*">
        <xsl:apply-templates/>
        <xsl:choose>
          <xsl:when test="position() = last()"/>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </address>
  </xsl:template>
  <!-- Titre de composant, réutilisable pour par exemple résultats de recherche -->
  <xsl:template name="h">
    <xsl:variable name="level" select="count(ancestor-or-self::ead:c|ancestor-or-self::ead:dsc)"/>
    <!-- titre hiérarchique -->
    <xsl:variable name="name">
      <xsl:text>h</xsl:text>
      <xsl:choose>
        <xsl:when test="$level &lt; 1">1</xsl:when>
        <xsl:when test="$level &gt; 4">4</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$level"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:choose>
        <xsl:when test="ead:head">
          <xsl:apply-templates select="ead:head/node()"/>
        </xsl:when>
        <!-- c/head est posé comme un archdesc/runner après split  -->
        <xsl:when test="ead:runner">
          <xsl:apply-templates select="ead:runner/node()"/>
        </xsl:when>
        <xsl:when test="ead:did/ead:head">
          <xsl:apply-templates select="ead:did/ead:head/node()"/>
        </xsl:when>
        <xsl:when test="ead:unittitle">
          <xsl:apply-templates select="ead:unittitle/node()"/>
        </xsl:when>
        <xsl:when test="ead:did/ead:unittitle">
          <xsl:apply-templates select="ead:did/ead:unittitle/node()"/>
        </xsl:when>
        <xsl:when test="ead:unitid">
          <xsl:apply-templates select="ead:unittid/node()"/>
        </xsl:when>
        <xsl:when test="ead:did/ead:unitid">
          <xsl:apply-templates select="ead:did/ead:unitid/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="ead:did/ead:unitdate">
          <xsl:text> (</xsl:text>
          <xsl:for-each select="ead:did/ead:unitdate">
              <xsl:if test="position() != 1">
                  <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="."/>
          </xsl:for-each>
          <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$text != ''">
      <xsl:element name="{$name}">
        <xsl:attribute name="class">unittitle</xsl:attribute>
        <xsl:value-of select="substring('                                                                         ', 1, 6 * ($level - 1))"/>
        <xsl:copy-of select="$text"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <!-- Cartouche de métadonnées -->
  <xsl:template match="ead:did | ead:titlepage ">
    <xsl:apply-templates select="ead:head"/>
    <!-- Enfants de type champ – valeur. -->
    <table class="did" width="100%">
      <colgroup span="1">
        <col span="1" class="label" width="20%"/>
        <col span="1" class="content"/>
      </colgroup>
        <!-- Ce serait bien de ne pas répéter les mêmes intitulés, mais avec les types et autres sortes de choses,
          ce n'est pas facile à calculer -->
      <xsl:if test="ead:unittitle">
        <tr>
          <!--
          <th>
            <xsl:call-template name="ead-label">
              <xsl:with-param name="id">unittitle</xsl:with-param>
            </xsl:call-template>
          </th>
          -->
          <td class="unittitle" colspan="2">
            <xsl:choose>
              <xsl:when test="count(ead:unittitle) &gt; 1">
                <xsl:apply-templates select="ead:unittitle"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="ead:unittitle/node()"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="ead:unitid">
        <tr>
          <th>
            <xsl:call-template name="ead-label">
              <xsl:with-param name="id">unitid</xsl:with-param>
            </xsl:call-template>
          </th>
          <td class="unitid">
            <xsl:for-each select="ead:unitid">
              <xsl:if test="position() != 1"> ; </xsl:if>
              <xsl:apply-templates/>
            </xsl:for-each>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="ead:unitdate">
        <tr>
          <th>
            <xsl:call-template name="ead-label">
              <xsl:with-param name="id">unitdate</xsl:with-param>
            </xsl:call-template>
          </th>
          <td class="unitdate">
            <xsl:for-each select="ead:unitdate">
              <xsl:if test="position() != 1"> ; </xsl:if>
              <xsl:apply-templates/>
            </xsl:for-each>
          </td>
        </tr>
      </xsl:if>
      <xsl:for-each select="ead:abstract | ../ead:scopecontent ">
        <tr>
          <th>
            <xsl:call-template name="ead-label"/>
          </th>
          <td class="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
          </td>
        </tr>
      </xsl:for-each>
      <xsl:for-each select="ead:container | ead:dao | ead:dagrp | ead:langmaterial | ead:materialspec | ead:note | ead:origination | ead:physdesc | ead:physloc | ead:repository | ../ead:custodhist | ../ead:acqinfo">
        <tr>
          <th>
            <xsl:call-template name="ead-label"/>
          </th>
          <td class="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  <xsl:template match="*[ead:did|ead:titlepage]/ead:scopecontent | *[ead:did|ead:titlepage]/ead:custodhist | *[ead:did|ead:titlepage]/ead:acqinfo"/>
  <!--
<h2>Liens</h2>
-->

  <!-- liens pouvant parraître en bloc dans certains contextes -->
  <xsl:template match="ead:extref | ead:ref | ead:title[@*[local-name()='href']] ">
    <xsl:choose>
      <xsl:when test="contains($desc.ref, concat(' ',local-name(..),' ')) ">
        <div>
          <xsl:call-template name="a"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="a"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- TODO quelque chose avec les dao group  -->
  <xsl:template match="ead:daogrp">
    <div class="daogrp">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template name="ext">
    <xsl:param name="string" select="."/>
    <xsl:choose>
      <xsl:when test="contains($string, '.')">
        <xsl:call-template name="ext">
          <xsl:with-param name="string" select="substring-after($string, '.')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="ead:arc | ead:daoloc | ead:extptr | ead:extptrloc | ead:extrefloc | ead:ptr | ead:ptrloc | ead:refloc | ead:resource " name="a">
    <xsl:variable name="href" select="@href|@xlink:href"/>
    <xsl:variable name="ext">
      <xsl:call-template name="ext">
        <xsl:with-param name="string" select="$href"/>
      </xsl:call-template>
    </xsl:variable>
    <a>
      <xsl:if test="$href != ''">
        <xsl:attribute name="href">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$ext = 'jpg' or $ext='png'">
          <xsl:attribute name="target">_blank</xsl:attribute>
          <img src="{$href}"/>
        </xsl:when>
        <xsl:when test=". = ''">
          <xsl:value-of select="@href|@xlink:href"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <xsl:template match="@target">
    <xsl:attribute name="href">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- réécriture des liens  -->
  <xsl:template match="@href | @xlink:href ">
    <xsl:variable name="path" select="substring-before(concat(substring-before(concat(., '?'), '?'), '#'), '#')"/>
    <xsl:attribute name="href">
      <xsl:choose>
        <!-- Lien externe, laisser -->
        <xsl:when test="starts-with(., 'http://')">
          <xsl:value-of select="."/>
        </xsl:when>
        <!-- Rien de voulu sur l'extension xml -->
        <xsl:when test="$_xml=''">
          <xsl:value-of select="."/>
        </xsl:when>
        <!-- Le chemin contient l'extension xml, réécrire le lien -->
        <xsl:when test="contains($path, $_xml)">
          <xsl:value-of select="$get"/>
          <xsl:value-of select="substring-before($path, $_xml)"/>
          <xsl:value-of select="$_html"/>
          <xsl:value-of select="substring-after(.,$_xml)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- Note -->
  <xsl:template match="ead:notestmt/ead:note">
    <xsl:choose>
      <xsl:when test="count(*) &gt; 1">
        <div class="note">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  <xsl:template match="note">
    <!-- Espace insécable dans le <a> -->
    <a href="#" class="note" title="{normalize-space(.)}">  </a>
    <!-- <div><xsl:apply-templates/></div> -->
  </xsl:template>

  <!-- TODO, identification des composants -->
  <xsl:template name="id">
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
<h2>Mode table des matières</h2>
  -->
  <!-- par défaut ne rien retenir et passer à travers tout -->
  <xsl:template name="toc">
    <ol class="tree">
      <xsl:apply-templates select="/*" mode="toc"/>
    </ol>
  </xsl:template>
  <xsl:template match="*" mode="toc">
    <xsl:apply-templates mode="toc"/>
  </xsl:template>
  <!-- par défaut ne rien afficher -->
  <xsl:template match="text()" mode="toc"/>
  <!-- bloc structurant hiérarchique -->
  <xsl:template match="ead:c" mode="toc">
    <xsl:variable name="tmp">
      <xsl:call-template name="h"/>
    </xsl:variable>
    <xsl:variable name="h" select="normalize-space(translate($tmp, ' ', ' '))"/>
    <xsl:if test="$h != ''">
      <li>
        <!-- S'il y a des composants enfants, rendre clicable. -->
        <xsl:if test="ead:c">
          <xsl:attribute name="class">more</xsl:attribute>
        </xsl:if>
        <a>
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:call-template name="id"/>
          </xsl:attribute>
          <xsl:variable name="title">
            <xsl:value-of select="normalize-space(ead:did/ead:unittitle)"/>
          </xsl:variable>
          <xsl:variable name="size" select="30"/>
          <xsl:if test="string-length($title) &gt; $size + 1">
            <xsl:attribute name="title">
              <xsl:value-of select="$title"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="substring($h, 1, $size)"/>
          <xsl:value-of select="substring-before( concat(substring($h, $size+1), ' '), ' ')"/>
          <xsl:if test="ead:c">
            <xsl:text> </xsl:text>
            <var>
              <xsl:text>(</xsl:text>
              <xsl:value-of select="count(.//ead:c)"/>
              <xsl:text>)</xsl:text>
            </var>
          </xsl:if>
        </a>
        <!--
        <xsl:apply-templates select="node()[name() != 'c']" mode="toc"/>
        <xsl:if test="ead:c//ead:geogname">
          <xsl:text> ... (</xsl:text>
          <xsl:value-of select="count(.//ead:geogname)"/>
          <xsl:text> lieux</xsl:text>
          <xsl:text>)</xsl:text>
        </xsl:if>
        -->
        <xsl:if test="ead:c">
          <ol>
            <xsl:apply-templates select="ead:c" mode="toc"/>
          </ol>
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>
  <!-- cote <c> -->
  <!--
  <xsl:template match="unitid" mode="toc">
    <small>[<xsl:value-of select="."/>]</small>
    <xsl:text>&#160;</xsl:text>
  </xsl:template>
  -->

  <xsl:template match="ead:geogname" mode="toc">
    <xsl:text> — </xsl:text>
    <b>
      <xsl:choose>
        <xsl:when test="@normal">
          <xsl:value-of select="normalize-space(@normal)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </b>
  </xsl:template>





<!--
<h2>Annexes</h2>
-->
  <!-- Message, intitulé court d'un élément TEI lorsque disponible -->
  <xsl:template name="ead-label">
    <xsl:param name="id" select="local-name()"/>
    <!-- tester des intitulés typés -->
    <xsl:param name="label">
      <xsl:if test="@type">
        <xsl:call-template name="ead-label">
          <xsl:with-param name="id" select="concat($id, '.', translate(@type, concat(' ',$apos), '__'))"/>
          <xsl:with-param name="label"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="ead:head/@althead">
        <xsl:value-of select="ead:head/@althead"/>
      </xsl:when>
      <xsl:when test="ead:head">
        <xsl:choose>
          <!-- mauvaise pratique de mise en forme de titre -->
          <xsl:when test="count(head/node()[normalize-space(.) != '']) = 1 and local-name(head/*)='emph'">
             <xsl:apply-templates select="head/*/node()"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:apply-templates select="head/node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$label != ''">
        <xsl:copy-of select="$label"/>
      </xsl:when>
      <xsl:when test="$id = ''"/>
      <xsl:when test="not($ead.rdfs[@xml:id = $id])"/>
      <xsl:when test="not($ead.rdfs[@xml:id = $id]/rdfs:label)"/>
      <xsl:when test="$ead.rdfs[@xml:id = $id]/rdfs:label[@xml:lang = $lang]">
        <xsl:copy-of select="$ead.rdfs[@xml:id = $id][rdfs:label[@xml:lang = $lang]][1]/rdfs:label[@xml:lang = $lang]/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$ead.rdfs[@xml:id = $id][1]/rdfs:label[1]/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- pour obtenir un chemin relatif à l'XSLT appliquée -->
  <xsl:template name="xslbase">
    <xsl:param name="path" select="/processing-instruction('xml-stylesheet')[contains(., 'xsl')]"/>
    <xsl:choose>
      <xsl:when test="contains($path, 'href=&quot;')">
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, 'href=&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '&quot;')">
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-before($path, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Absolute, do nothing -->
      <xsl:when test="starts-with($path, 'http')"/>
      <!-- cut beforer quote -->
      <xsl:when test="contains($path, '/')">
        <xsl:value-of select="substring-before($path, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- win centric -->
      <xsl:when test="contains($path, '\')">
        <xsl:value-of select="substring-before($path, '\')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


</xsl:transform>
