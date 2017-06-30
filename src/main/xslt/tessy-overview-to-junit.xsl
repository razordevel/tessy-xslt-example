<?xml version="1.0" encoding="UTF-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2015 Lars Sadau (Carneios GmbH) and all contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->

<!-- Evaluates a TESSY Details Report file and transform them to jUnit xml -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="filename" />
  <xsl:param name="filedir" />
  <xsl:param name="basedir" />
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*" />

  <xsl:attribute-set name="testcase_statistics">
    <xsl:attribute name="tests" ><xsl:value-of select="testcase_statistics/@total" /></xsl:attribute>
    <xsl:attribute name="failures" ><xsl:value-of select="testcase_statistics/@notok" /></xsl:attribute>
    <xsl:attribute name="skipped" ><xsl:value-of select="testcase_statistics/@notexecuted" /></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="name_simple">
    <xsl:attribute name="name" ><xsl:value-of select="@name" /></xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="name_concat_last2">
    <xsl:attribute name="name" ><xsl:value-of select="concat(../@name,'/',@name)" /></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="name_concat_last3">
    <xsl:attribute name="name" ><xsl:value-of select="concat(../../@name,'/',../@name,'/',@name)" /></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="name_concat_last4">
    <xsl:attribute name="name" ><xsl:value-of select="concat(../../@name,'/',../../@name,'/',../@name,'/',@name)" /></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="name_concat_last5">
    <xsl:attribute name="name" ><xsl:value-of select="concat(../../@name,'/',../../@name,'/',../../@name,'/',../@name,'/',@name)" /></xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="report">
    <testsuites>
      <xsl:attribute name="tests" ><xsl:value-of select="statistic/@total" /></xsl:attribute>
      <xsl:attribute name="failures" ><xsl:value-of select="statistic/@notok" /></xsl:attribute>
      <xsl:attribute name="skipped" ><xsl:value-of select="statistic/@notexecuted" /></xsl:attribute>
      <xsl:attribute name="timestamp" ><xsl:value-of select="info/@date" />T<xsl:value-of select="info/@time" /></xsl:attribute>
      <xsl:apply-templates  select="tessyobject"/>
   </testsuites>
  </xsl:template>

  <xsl:template match="tessyobject[@type='project']">
    <xsl:element name="testsuite" use-attribute-sets="name_simple testcase_statistics">
      <xsl:apply-templates select="tessyobject"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="tessyobject[@type='test_collection']/tessyobject[@type='module']">
    <xsl:element name="testsuite" use-attribute-sets="name_concat_last2 testcase_statistics">
      <xsl:apply-templates select="tessyobject"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tessyobject[@type='test_collection']/tessyobject[@type='folder']/tessyobject[@type='module']">
    <xsl:element name="testsuite" use-attribute-sets="name_concat_last3 testcase_statistics">
      <xsl:apply-templates select="tessyobject"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tessyobject[@type='test_collection']/tessyobject[@type='folder']/tessyobject[@type='folder']/tessyobject[@type='module']">
    <xsl:element name="testsuite" use-attribute-sets="name_concat_last4 testcase_statistics">
      <xsl:apply-templates select="tessyobject"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="tessyobject[@type='testobject']">
    <xsl:element name="testcase" use-attribute-sets="name_simple testcase_statistics">
      <xsl:apply-templates select="testcase_statistics"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tessyobject[@type='testobject']/testcase_statistics[@success='notok']">
    <failure>
    </failure>
  </xsl:template>

</xsl:stylesheet>
