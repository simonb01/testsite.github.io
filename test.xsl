<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ex="http://exslt.org/dates-and-times" 
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="ex exsl">

<!--
 Global date variables
-->
 <xsl:variable name="date" select="ex:date-time()"/>
 <xsl:variable name="year" select="substring(substring-before($date,'T'),0,5)"/>
 <xsl:variable name="month" select="substring(substring-before($date,'T'),6,2)"/>
 <xsl:variable name="day" select="substring(substring-before($date,'T'),9,2)"/>
 <xsl:variable name="date_string" select="concat($day,'-',$month,'-',$year)"/>
 
 <xsl:variable name="filesize_total_adj">
	 <xsl:call-template name="Adjust_Filesize">
		<xsl:with-param name="size" select="sum(Objects/Object/Property[@Name='Length'])"/>
	 </xsl:call-template>
 </xsl:variable>
 
<!--
Full file list including book name
-->
 <xsl:variable name="full_list">
	 <xsl:for-each select="/Objects/Object">
		 <xsl:variable name="path" select="Property[@Name='DirectoryName']"/>
         <xsl:variable name="path_start" select="substring($path,1,15)"/>
         <xsl:variable name="path_end" select="substring-after($path, $path_start)"/>
         <xsl:variable name="book_path">
		    <xsl:choose>
			   <xsl:when test="contains($path_end,'\')"><xsl:value-of select="substring-before($path_end,'\')"/></xsl:when>
			   <xsl:otherwise><xsl:value-of select="$path_end"/></xsl:otherwise>
		   </xsl:choose>
		 </xsl:variable>			 
			 <properties>
				<name><xsl:value-of select="Property[@Name='Name']"/></name>
				<size><xsl:value-of select="Property[@Name='Length']"/></size>
				<path><xsl:value-of select="Property[@Name='DirectoryName']"/></path>
				<accesstime><xsl:value-of select="Property[@Name='LastAccessTime']"/></accesstime>
				<book><xsl:value-of select="concat($path_start, $book_path)"/></book>
			 </properties>		 
     </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="properties" select="exsl:node-set($full_list)/properties" />
 
<!--
 File list sorted by filesize displaying top 3 values
-->
 <xsl:variable name="filename_sorted_by_size">
	 <xsl:for-each select="/Objects/Object">
		 <xsl:sort select="Property[@Name='Length']" order="descending" data-type="number"/>
		 <xsl:if test="position() &lt;= 3">
			 <property>
				<name><xsl:value-of select="Property[@Name='Name']"/></name>
			 </property>
		 </xsl:if>
     </xsl:for-each>
 </xsl:variable>

<xsl:template match="/">

 <html>
	<head>
		<title>My Summary File Report</title>
		<link rel="shortcut icon" type="image/x-icon" href="./default16.png" />
	</head>
	 
 <body>

 <img src="http://wall2born.com/data/out/687/image-47006591-cool-hd-desktop-wallpaper.jpg" alt="picture of car"/>
 
 <h1><span style="color:red;font-weight:bold">File Details</span></h1>
 
 <ul>
	<li><a href="#summary">Summary Data</a></li>
	<li><a href="#listing">File Listing</a></li>
 </ul>
 
 <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" >
	 <rect x="10" y="10" width="100" 
	       height="200" fill="blue" stroke="black"/>  
 </svg>
 
 <svg xmlns="http://www.w3.org/2000/svg" width="100px" height="100px" viewBox="0 0 100 100">     
	<circle cx="30" cy="30" r="20" 
	    fill="green" stroke="none"/>
 </svg>
 
 <h2>Generated for: <xsl:value-of select="$date_string"/></h2>
 <h2>Number of files: <xsl:value-of select="count(Objects/Object)"/></h2>
 <h2>Total File Size: <xsl:value-of select="$filesize_total_adj"/></h2> 

 <p>The three largest files are:</p>
 
 <ol>
 <xsl:for-each select="exsl:node-set($filename_sorted_by_size)/property">
 <xsl:sort select="name" order="ascending" data-type="text"/>
	  
	 <li><xsl:value-of select="name"/></li>
 
 </xsl:for-each>
 </ol>

<p></p>

<!--
 <table border='1'>
	     <tr bgcolor="#DEB887" align="left">
			 <th>Book</th>
			 <th>Count</th>
		 </tr>
<xsl:apply-templates select="exsl:node-set($full_list)/properties">
	<xsl:sort select="path" order="ascending" data-type="text"/>
 </xsl:apply-templates>

</table>
-->

<h3><span style="color:blue;text-decoration:underline">Summary data by book:</span></h3>

<!--
<table border="1">
	<xsl:for-each select="$properties[generate-id(.)=generate-id(key('filepath_key', book)[1])]">
		<xsl:for-each select="key('filepath_key', book)">
		<tr>
            <xsl:if test="position() = 1">
              <td valign="center" bgcolor="#999999">
                <xsl:attribute name="rowspan">
                  <xsl:value-of select="count(key('filepath_key', book))"/>
                </xsl:attribute>
                <b>
                  <xsl:text>Book Name: </xsl:text><xsl:value-of select="book"/>
                </b>
              </td>
            </xsl:if>
            <td>
				<xsl:value-of select="sum(key('filepath_key', book)/size)"/>
            </td>
            </tr>
            </xsl:for-each>
      </xsl:for-each>
    </table>
-->
 
<table border="1" cellpadding="5" id="summary">
	 <tr bgcolor="#0080ff" align="left">
		<th>Book</th>
		<th>Total Filesize</th>
		<th>No Files</th>
	</tr>
	
	 <xsl:for-each select="$properties">
		 <xsl:sort select="sum($properties[(book=current()/book)]/size)" order="descending" data-type="number"/>

	<xsl:variable name="bookGroup" select="$properties[(book=current()/book)]" />
	<xsl:if test="generate-id()=generate-id($bookGroup[1])">
		<tr>
			<td width="230">
                <xsl:value-of select="book"/>
            </td>
            <td>
            <xsl:call-template name="Adjust_Filesize">
				<xsl:with-param name="size" select="sum($bookGroup/size)"/>
			</xsl:call-template>
            </td>
            <td>
                <xsl:value-of select="count($bookGroup/name)"/>
            </td>
        </tr>
    </xsl:if>
    </xsl:for-each>
    <tr>
		<th align='center'>Total:</th>
		<th align='left' colspan="2"><xsl:value-of select="$filesize_total_adj"/></th>
    </tr>
</table>
	 
<p></p>
  
 <table border='1' id="listing">
 <tr bgcolor="#DEB887" align="left">
	<th>Filename</th>
	<th>Folder</th>
	<th>Last Access Time</th>
	<th>Filesize</th>
	<th>Book</th>
 </tr>

 <xsl:for-each select="$properties">
 <xsl:sort select="book" order="ascending" data-type="text"/>

 <tr>
	<td><xsl:value-of select="name"/></td>
	<td><xsl:value-of select="path"/></td> 
	<td><xsl:value-of select="accesstime"/></td>
	<td>
		<xsl:attribute name="style">
			<xsl:choose>
				<xsl:when test="size div 1024 div 1024 > 10">
					<xsl:text>background: yellow; color: black;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>background: white;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="Adjust_Filesize">
			<xsl:with-param name="size" select="size"/>
		</xsl:call-template>
    </td>
	<td><xsl:value-of select="book"/></td>
 </tr>

 </xsl:for-each>

 </table>
 
 </body>
 </html>
</xsl:template>

<!--
 <xsl:template match="properties[generate-id(.)=generate-id(key('filepath_key',book)[1])]">>
	<xsl:for-each select="key('filepath_key', book)">
		 <tr>
			 <td><xsl:value-of select="book"/></td>
			 <td><xsl:value-of select="count(name)"/></td>
		 </tr>
	</xsl:for-each>
 </xsl:template>
-->

 <xsl:template name="Adjust_Filesize">
	 <xsl:param name="size"/>
	 <xsl:variable name="filesize_adj">
			<xsl:choose>
				<xsl:when test="$size &lt; 1024"><xsl:value-of select="format-number($size,'#.##')"/> bytes</xsl:when>
				<xsl:when test="$size &gt;= 1024 and $size &lt; 1024*1024"><xsl:value-of select="format-number($size div 1024,'#.##')"/> Kb</xsl:when>
				<xsl:when test="$size &gt;= 1024 * 1024 and $size &lt; 1024*1024*1024"><xsl:value-of select="format-number($size div 1024 div 1024,'#.##')"/> Mb</xsl:when>
				<xsl:otherwise><xsl:value-of select="format-number($size div 1024 div 1024 div 1024,'#.##')"/> Gb</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
        <xsl:value-of select="$filesize_adj"/>
 </xsl:template>
	 
</xsl:stylesheet> 
