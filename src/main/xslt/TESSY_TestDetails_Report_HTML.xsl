<?xml version="1.0" encoding="UTF-8"?>

<!-- Copyright 2014 Razorcat Development GmbH -->
<!-- Renders a TESSY report as a test details report in HTML -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    method="xml" version="1.0" indent="yes" media-type="text/xhtml" />

  <!-- Company logo shown in report header: for end user customization -->
  <xsl:param name="your_company_logo_URL" select="'https://www.razorcat.com/files/theme/razorcat/images/logo2.png'" />
  <!-- Company CSS: for end user customization -->
  <xsl:param name="your_company_CSS_URL" select="'../xslt/TESSY_TestDetails_Report.css'" />

  <xsl:template match="/report">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>
          Test Details Report --
          <xsl:value-of select="@testobject_name" />
        </title>
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href"><xsl:value-of select="$your_company_CSS_URL" /></xsl:attribute>
        </link>
      </head>
      <body>
        <xsl:apply-templates select="summary|usercode|testobject/testcase" />
      </body>
    </html>
  </xsl:template>

  <!-- -->
  <xsl:template match="report/summary">
    <!-- report header with company logo -->
    <div class="report_header">
      <xsl:attribute name="class">
            <xsl:choose>
             <xsl:when test="statistic/@notok=0">
                    <xsl:value-of select="'report_header'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'report_header failed_grad'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
      <table class="fullWidth">
        <tr>
          <td>TEST DETAILS REPORT</td>
          <td>
            <xsl:value-of select="info/@date" />
            <xsl:value-of select="', '" />
            <xsl:value-of select="info/@time" />
            <xsl:value-of select="' (TESSY v '" />
            <xsl:value-of select="/report/@tessy_version" />
            <xsl:value-of select="')'" />
          </td>
          <td rowspan="2" style="text-align:right">
            <img id="company_logo">
              <xsl:attribute name="src"><xsl:value-of select="$your_company_logo_URL" /></xsl:attribute>
            </img>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <var>
              <xsl:value-of select="info/@testobject_name" />
            </var>
          </td>
        </tr>
      </table>
      <hr />
    </div>

    <xsl:apply-templates select="info|statistic|properties" />
  </xsl:template>

  <!-- project/module/test object... -->
  <xsl:template match="report/summary/info">
    <table id="info" class="superCol_1 fullWidth">
      <tr>
        <td>Project</td>
        <td>
          <xsl:value-of select="@project_name" />
        </td>
      </tr>
      <tr>
        <td>Module</td>
        <td>
          <xsl:value-of select="@module_name" />
        </td>
      </tr>
      <tr>
        <td>Test Object</td>
        <td>
          <xsl:value-of select="@testobject_name" />
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- statistics... -->
  <xsl:template match="report/summary/statistic">
    <h2 id="statistics">Statistics</h2>
    <table class="statistics superCol_1">
      <tr>
        <td>Total Testcases</td>
        <td>
          <xsl:value-of select="@total" />
        </td>
      </tr>
      <tr>
        <td>Successful</td>
        <td>
          <xsl:value-of select="@ok" />
        </td>
      </tr>
      <tr>
        <td>Failed</td>
        <td>
          <xsl:choose>
            <xsl:when test="@notok=0">
              <xsl:value-of select="@notok" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@notok" />
              <span class="hide failed" tabindex="0" >[hide]</span>
              <span class="show failed" tabindex="0">[show]</span>
              <div class="failed_nav">
                <xsl:apply-templates select="/report/testobject/testcase/teststep"
                  mode="navi" />
              </div>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
      <tr>
        <td>Not Executed</td>
        <td>
          <xsl:value-of select="@notexecuted" />
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- failed testcases navigation -->
  <xsl:template match="/report/testobject/testcase/teststep" mode="navi">
    <xsl:if test="@success!='ok'">
      <xsl:variable name="ts_id" select="@id" />
      <a href="#tc_{$ts_id}">
        <xsl:value-of select="@id" />
        <xsl:value-of select="' '" />
      </a>
    </xsl:if>
  </xsl:template>

  <!-- module properties... -->
  <xsl:template match="report/summary/properties">
    <h2 id="module_properties">Module Properties</h2>
    <table class="module_properties superCol_1">
      <tr class="bgBlue2">
        <td>Project Root Directory</td>
        <td>
          <xsl:value-of select="@project_root" />
        </td>
      </tr>
      <tr>
        <td>Configuration File</td>
        <td>
          <xsl:value-of select="@config" />
        </td>
      </tr>
      <tr>
        <td>Target Environment</td>
        <td>
          <xsl:value-of select="@environment" />
        </td>
      </tr>
      <tr>
        <td>Kind of Test</td>
        <td>
          <xsl:value-of select="@kind_of_test" />
        </td>
      </tr>
      <tr>
        <td>Linker Options</td>
        <td>
          <!-- fehlen im XML
            <xsl:value-of select="@" />
          -->
        </td>
      </tr>
      <tr>
        <td>Source File(s)</td>
        <td />
      </tr>
      <xsl:for-each select="source">
        <tr>
          <td>File</td>
          <td>
            <a target="_blank" type="text/plain">
              <xsl:attribute name="href"><xsl:value-of select="'file:///'" />
                  <xsl:value-of select="@file" />
              </xsl:attribute>
              <xsl:value-of select="@file" />
            </a>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!-- global usercode defs -->
  <xsl:template match="report/usercode">
    <h2 id="gl_usercode">Usercode</h2>
    <h3 class="bgBlue2 noMarginTop">Declarations</h3>
    <pre>
      <xsl:value-of select="declarations/@body" />
    </pre>
    <h3 class="bgBlue2 noMarginTop">Definitions</h3>
    <pre>
      <xsl:value-of select="definitions/@body" />
    </pre>
  </xsl:template>

  <!-- testcases -->
  <xsl:template match="report/testobject/testcase">
    <xsl:variable name="tc_id" select="@id" />

    <h2 id="tc_{$tc_id}" class="bgBlue1">
      Test Case
      <xsl:value-of select="@id" />
    </h2>
    <xsl:apply-templates select="prologs_epilogs/prolog" />
    <xsl:apply-templates select="prologs_epilogs/epilog" />
    <xsl:apply-templates select="teststep" />
  </xsl:template>

  <!-- teststeps -->
  <xsl:template match="report/testobject/testcase/teststep">
    <xsl:variable name="ts_id" select="@id" />

    <h3 id="tc_{$ts_id}" class="ts bgBlue1">
      Test Step
      <xsl:value-of select="@id" />
      (Repeat Count=
      <xsl:value-of select="@repeat_count" />
      )
    </h3>
    <xsl:apply-templates select="prologs_epilogs/prolog" />
    <xsl:apply-templates select="prologs_epilogs/epilog" />
    <xsl:apply-templates select="inputs" />
    <xsl:apply-templates select="results" />
  </xsl:template>

  <!-- code prolog -->
  <xsl:template match="prologs_epilogs/prolog">
    <span class="prolog">Prolog</span>
    <pre>
      <xsl:value-of select="@text" />
    </pre>
  </xsl:template>

  <!-- code epilog -->
  <xsl:template match="prologs_epilogs/epilog">
    <span class="epilog">Epilog</span>
    <pre>
      <xsl:value-of select="@text" />
    </pre>
  </xsl:template>

  <!-- inputs -->
  <xsl:template match="teststep/inputs">
    <table class="ts fullWidth">
      <thead class="bgBlue2">
        <tr>
          <th>Name</th>
          <th>Input Value</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="input">
          <tr>
            <td>
              <code>
                <xsl:value-of select="@name" />
              </code>
            </td>
            <td>
              <code>
                <xsl:value-of select="@value" />
              </code>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <!-- inputs -->
  <xsl:template match="teststep/results">
    <table class="ts fullWidth">
      <thead class="bgBlue2">
        <tr>
          <th>Name</th>
          <th>Actual Value</th>
          <th>Expected Value</th>
          <th>Result</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="result">
          <tr>
            <td>
              <code>
                <xsl:value-of select="@name" />
              </code>
            </td>
            <xsl:choose>
              <xsl:when test="@success='ok'">
                <td>
                  <code>
                    <xsl:value-of select="@actual_value" />
                  </code>
                </td>
              </xsl:when>
              <xsl:otherwise>
                <td class="failed">
                  <code>
                    <xsl:value-of select="@actual_value" />
                  </code>
                </td>
              </xsl:otherwise>
            </xsl:choose>
            <td>
              <code>
                <xsl:value-of select="@expected_value" />
              </code>
            </td>
            <td>
              <code>
                <xsl:value-of select="@success" />
              </code>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>
</xsl:stylesheet>