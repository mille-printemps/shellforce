# coding : utf-8

require 'rubygems'
require 'json'
require 'nokogiri'
require 'shellforce/config'
require 'shellforce/util'
include ShellForce::Util    

module ShellForce
  module Command

    def xsl
      @xsl ||= Nokogiri::XSLT(XSLT)
    end
    
    def pp(headers, body)
      format = headers["content-type"][0]
      if format.match("json")
        display JSON.pretty_generate(JSON.parse(body))
      elsif format.match("xml")
        display xsl.apply_to(Nokogiri(body)).to_s
      else
        display body
      end
      return headers, body
    end

    XSLT = <<-XSLT
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="UTF-8"/>
    <xsl:param name="indent-increment" select="'  '"/>

    <xsl:template name="newline">
        <xsl:text disable-output-escaping="yes">
        </xsl:text>
    </xsl:template>

    <xsl:template match="comment() | processing-instruction()">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
        <xsl:copy />
    </xsl:template>

    <xsl:template match="text()">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="text()[normalize-space(.)='']"/>

    <xsl:template match="*">
        <xsl:param name="indent" select="''"/>
        <xsl:call-template name="newline"/>
        <xsl:value-of select="$indent"/>
            <xsl:choose>
                <xsl:when test="count(child::*) > 0">
                <xsl:copy>
                 <xsl:copy-of select="@*"/>
                 <xsl:apply-templates select="*|text()">
                  <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
                 </xsl:apply-templates>
                 <xsl:call-template name="newline"/>
                 <xsl:value-of select="$indent"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
XSLT
    
  end
end



