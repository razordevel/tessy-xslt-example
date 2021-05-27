<?xml version="1.0" encoding="UTF-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2021 Lars Sadau (Razorcat GmbH) and all contributors

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

<!-- Evaluates a TESSY Details Report file and transforms the coverage and metric results to a jUnit xml report-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="filename" />
	<xsl:param name="filedir" />
	<xsl:param name="basedir" />
	<xsl:output method="xml" indent="yes"/> 
	<xsl:strip-space elements="*" />

	<xsl:template match="/report">
		<testsuite>
			<xsl:attribute name="name"><xsl:call-template name="packagename" /></xsl:attribute>
				<xsl:attribute name="timestamp" ><xsl:value-of select="/report/summary/info/@date" />T<xsl:value-of select="/report/summary/info/@time" /></xsl:attribute>
				<xsl:apply-templates select="summary/coverage" />
				<xsl:apply-templates select="summary/metrics" />
			</testsuite>
		</xsl:template>



		<xsl:template match="coverage">
	 
			<xsl:apply-templates select="./*" />
		</xsl:template>
		<xsl:template match="coverage/*">
			<testcase>
				<xsl:attribute name="name">
					<xsl:value-of select="@name" />
				</xsl:attribute>
				<xsl:attribute name="classname" ><xsl:call-template name="packagename"/>.<xsl:value-of select="/report/summary/info/@testobject_name"/></xsl:attribute>
				<xsl:apply-templates select="@success" />
				<system-out>
Total Branches: <xsl:value-of select="@total" />
Reached Branches: <xsl:value-of select="@reached" />
Percent of Reached Branches: <xsl:value-of select="@percentage" />
Success: <xsl:value-of select="@success" />
<xsl:call-template name="reportSuccessStatus"/>
				</system-out>
			</testcase>	
		</xsl:template>

		<xsl:template match="metrics">
	 
			<xsl:apply-templates />
		</xsl:template>
		<xsl:template match="metrics/result_significance">
			<xsl:call-template name="testcase">
				<xsl:with-param name="testcase_name">Result Significance</xsl:with-param>
			</xsl:call-template>
		</xsl:template>
	
	
		<xsl:template match="metrics/tc_cc_ratio">
			<xsl:call-template name="testcase">
				<xsl:with-param name="testcase_name">Ratio Test Coverage and Cyclomatic Complexity</xsl:with-param>
			</xsl:call-template>
		</xsl:template>
		<xsl:template match="metrics/cc_total">
			<xsl:call-template name="testcase">
				<xsl:with-param name="testcase_name">Cyclomatic Complexity</xsl:with-param>
			</xsl:call-template>
		</xsl:template>
		<xsl:template match="@success">
			<xsl:call-template name="successOrResult" />
		</xsl:template>
		<xsl:template match="@result">
			<xsl:call-template name="successOrResult" />
		</xsl:template>
	
		<xsl:template name="testcase">
			<xsl:param name="testcase_name" />
			<testcase>
				<xsl:attribute name="name"><xsl:value-of select="$testcase_name" /></xsl:attribute>
				<xsl:call-template name="classname"/>
				<xsl:apply-templates select="@result" />
				<system-out>
Value: <xsl:value-of select="@value" />
Result: <xsl:value-of select="@result" />
<xsl:call-template name="reportSuccessStatus"/>
				</system-out>
			</testcase>	
		</xsl:template>
			
		<xsl:template name="successOrResult">	
			<xsl:choose>
				<xsl:when test=".='ok'">
				
				</xsl:when>
				<xsl:otherwise>
					<error/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>

		<xsl:template name="reportSuccessStatus">
==<xsl:choose>
				<xsl:when test="@success='ok' or @result='ok' or @result='warning'">PASSED</xsl:when> 
				<xsl:otherwise>FAILED</xsl:otherwise>
			</xsl:choose>==
		</xsl:template>
		<xsl:template name="packagename">
<xsl:value-of select="'TestQuality.'"/><xsl:value-of select="/report/summary/info/@project_name"/>.<xsl:value-of select="/report/summary/info/@module_name"/>
		</xsl:template>
		<xsl:template name="classname">
			<xsl:attribute name="classname" ><xsl:call-template name="packagename"/>.<xsl:value-of select="/report/summary/info/@testobject_name"/></xsl:attribute>
		</xsl:template>
	</xsl:stylesheet>
