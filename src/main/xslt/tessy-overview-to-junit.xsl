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
	<xsl:param name="filename"/>
	<xsl:param name="filedir"/>
	<xsl:param name="basedir"/>
	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>
	<!--
    Jenkins interprets . as separator in a Java method path.
    This means the last point separates the test method from the test class.
    The second last point separates the classname from the package name.
  -->
	<xsl:template match="report">
		<testsuites>
			<xsl:attribute name="tests">
				<xsl:value-of select="statistic/@total"/>
			</xsl:attribute>
			<xsl:attribute name="failures">
				<xsl:value-of select="statistic/@notok"/>
			</xsl:attribute>
			<xsl:attribute name="skipped">
				<xsl:value-of select="statistic/@notexecuted"/>
			</xsl:attribute>
			<xsl:attribute name="timestamp"><xsl:value-of select="info/@date"/>T<xsl:value-of select="info/@time"/></xsl:attribute>
			<xsl:apply-templates select="tessyobject"/>
		</testsuites>
	</xsl:template>
	<xsl:template match="tessyobject[@type='project']">
		<xsl:element name="testsuite">
			<xsl:call-template name="simple_name"/>
			<xsl:call-template name="statistics_attributes"/>
			<xsl:apply-templates select="tessyobject"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="tessyobject[@type='test_collection']">
		<xsl:apply-templates select="tessyobject">
			<xsl:with-param name="parentsName" select="@name"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="tessyobject[@type='module']">
		<xsl:param name="parentsName"/>
		<xsl:element name="testsuite">
			<xsl:attribute name="name">
				<xsl:value-of select="concat($parentsName,'.', @name)"/>
			</xsl:attribute>
			<xsl:call-template name="statistics_attributes"/>
			<xsl:apply-templates select="tessyobject"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="tessyobject[@type='folder']">
		<xsl:param name="parentsName"/>
		<xsl:apply-templates select="tessyobject">
			<xsl:with-param name="parentsName" select="concat($parentsName,'.', @name)"/>
		</xsl:apply-templates>
	</xsl:template> 
	<xsl:template match="tessyobject[@type='testobject']">
		<xsl:element name="testcase">
			<xsl:call-template name="simple_name"/>
			<xsl:call-template name="statistics_attributes"/>
			<xsl:apply-templates select="testcase_statistics"/>
			<xsl:call-template name="attachments"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="simple_name">
		<xsl:attribute name="name">
			<xsl:value-of select="@name"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template name="statistics_attributes">
		<xsl:attribute name="tests"><xsl:value-of select="testcase_statistics/@total"/></xsl:attribute>
		<xsl:attribute name="failures"><xsl:value-of select="testcase_statistics/@notok"/></xsl:attribute>
		<xsl:attribute name="skipped"><xsl:value-of select="testcase_statistics/@notexecuted"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="tessyobject[@type='testobject']/testcase_statistics[@success='notok']">
		<failure/>
	</xsl:template>
	<xsl:template match="tessyobject[@type='testobject']/testcase_statistics[@success='notexecuted']">
		<skipped/>
	</xsl:template>
	<xsl:template name="attachments">
		<xsl:if test="$filename!=''">
			<xsl:choose>
				<xsl:when test="$filedir!=''">
					<system-out>
            [[ATTACHMENT|<xsl:value-of select="concat($filedir, '/', $filename)" />]]
            [[ATTACHMENT|<xsl:value-of select="concat($filedir, '/',substring-before($filename,'.xml'))" />.pdf]]
					</system-out>
				</xsl:when>
				<xsl:otherwise>
					<system-out>
           [[ATTACHMENT|<xsl:value-of select="$filename" />]]
           [[ATTACHMENT|<xsl:value-of select="substring-before($filename,'.xml')" />.pdf]]
					</system-out>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
