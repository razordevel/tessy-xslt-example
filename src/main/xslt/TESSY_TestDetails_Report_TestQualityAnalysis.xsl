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

<!-- Evaluates a TESSY Details Report file and transform them to jUnit xml -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="filename" />
	<xsl:param name="filedir" />
	<xsl:param name="basedir" />
	<xsl:output method="xml" indent="yes"/> 
	<xsl:strip-space elements="*" />

	<xsl:template match="/report">
		<html lang="en">
			<head>
				<meta charset="utf-8"/>
				<title><xsl:call-template name="packagename" /></title>
				<style>
					td.failed { 
					background-color: red;
					}
					td.passed { 
					background-color: lightgreen;
					}
				</style>
			</head>
			<script>
				function triggerReload() {
				location.reload();
				}
			</script>
			<body onload="window.setTimeout(triggerReload,1000)">
				<table border="1" cellpadding="3">
					<tbody>
						<tr>
							<td>Teststeps</td>
							<td><xsl:value-of select="/report/summary/statistic/@total" /></td>
						</tr>
						<tr>
							<td>Date</td>
							<td><xsl:value-of select="/report/summary/info/@date" /></td>
						</tr>
						<tr>
							<td>Time</td>
							<td><xsl:value-of select="/report/summary/info/@time" /></td>
						</tr>
						<xsl:apply-templates select="summary/coverage" />
						<xsl:apply-templates select="summary/metrics" />
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>



	<xsl:template match="coverage">
	 
		<xsl:apply-templates select="./*" />
	</xsl:template>
	<xsl:template match="coverage/*">
		<tr><th colspan="2"><xsl:value-of select="@name" /></th></tr>
		<tr>
			<td>Total Branches</td><td><xsl:value-of select="@total" /></td>
		</tr>
		<tr>
			<td>Reached Branches</td><td><xsl:value-of select="@reached" /></td>
		</tr>
		<tr>
			<td>Percent of Reached Branches</td><td><xsl:value-of select="@percentage" /></td>
		</tr>
		<tr>
			<td>Status</td><td><xsl:apply-templates select="@success" /></td>
		</tr>
	
	</xsl:template>

	<xsl:template match="metrics">
	 
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="metrics/result_significance">
		<tr><th colspan="2">Result Significance</th></tr>
		<xsl:call-template name="status" />
	</xsl:template>
	<xsl:template match="metrics/tc_cc_ratio">
		<tr><th colspan="2">Ratio Test Coverage and Cyclomatic Complexity</th></tr>
		<xsl:call-template name="value" />
		<xsl:call-template name="status" />
	</xsl:template>
	<xsl:template match="metrics/cc_total">
		<tr><th colspan="2">Cyclomatic Complexity</th></tr>
		<xsl:call-template name="value" />
		<xsl:call-template name="status" />
	</xsl:template>
	<xsl:template match="@success">
		<xsl:call-template name="successOrResult" />
	</xsl:template>
	<xsl:template match="@result">
		<xsl:call-template name="successOrResult" />
	</xsl:template>
	<xsl:template name="value">	
		<tr>
			<td>Value</td><td><xsl:apply-templates select="@value" /></td>
		</tr>
	</xsl:template>
	<xsl:template name="status">	
		<tr>
			<td>Status</td><td><xsl:apply-templates select="@result" /></td>
		</tr>
	</xsl:template>
	<xsl:template name="successOrResult">	
		<xsl:choose>
			<xsl:when test=".='ok'">
				<xsl:attribute name="class" >passed</xsl:attribute>
				Passed
			</xsl:when> 
			<xsl:otherwise>
				Failed
				<xsl:attribute name="class" >failed</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template name="packagename">
		<xsl:value-of select="/report/summary/info/@project_name"/> <xsl:value-of select="/report/summary/info/@module_name"/>
	</xsl:template>
</xsl:stylesheet>
