<!--- get the available templates from the template folder --->
<cfset templates = getTemplates()>

<h1>Scaffold</h1>

<p>This plugin will enable Scaffolding in your application, to use it, follow the instructions below.</p>

<h2>Instructions</h2>

<ul>
	<li>Create the table in your database following Wheels's table name conventions.</li>
	<li>Insert the table name (in singular case) in the "Object name" input field.</li>
	<li>Select the type of Scaffold to perform.</li>
	<li>Click the "Generate" submit button.</li>
</ul>

<h2>Generate form</h2>

<cfif isDefined("FORM.objectToScaffold") AND isDefined("FORM.typeOfScaffold")>

	<!--- default overwrite checkbox --->
	<cfparam name="FORM.overwrite" default="0">

    <cfoutput>
    	<p><tt>#generateScaffold(FORM.objectToScaffold, FORM.typeOfScaffold, FORM.template, FORM.overwrite)#</tt></p>
    </cfoutput>
    
    <p>Create another one?</p>

</cfif>

<p><tt>Example: If your table is named "users", insert "user" in the form field below.</tt></p>

<!--- Form --->
<cfform action="#CGI.script_name & '?' & CGI.query_string#">
	<p><label for="objectToScaffold">Object name</label> <br>
	<cfinput type="text" name="objectToScaffold" required="true"  message="An Object name is required"></p>
	
	<p><label for="typeOfScaffold">MVC</label><br>
		<cfinput type="checkbox" id="modelMVC" name="typeOfScaffold" value="model" required="true" checked="true"> <label for="modelMVC">Model</label><br>
		<cfinput type="checkbox" name="typeOfScaffold" id="viewMVC" value="view" required="true" checked="true" label="View"> <label for="viewMVC">View</label><br>
		<cfinput type="checkbox" name="typeOfScaffold" id="controllerMVC" value="controller" required="true" checked="true" label="Controller">  <label for="controllerMVC">Controller</label><br>
	</p>

	<p><label for="typeOfScaffold">Tests</label><br>
		<cfinput type="checkbox" name="typeOfScaffold" id="modelTest" value="modelTest" required="true" checked="true"> <label for="modelTest">Model</label><br>
		<cfinput type="checkbox" name="typeOfScaffold" id="controllerTest" value="controllerTest" required="true" checked="true" label="Controller"> <label for="controllerTest">Controller</label><br>
	</p>
	
	<p>
	    <label for="template">Template</label> <br>
	    <cfselect name="template">
	        <cfoutput query="templates">
	            <cfif type is "DIR">
	                <option value="#name#">#name#</option>
	            </cfif>
	        </cfoutput>
    	</cfselect>
	</p>
	
	<p>
		<cfinput type="checkbox" name="overwrite" id="overwrite" value="1" checked="false"> <label for="overwrite">Overwrite Existing?</label><br>
	</p>

	<p><cfinput type="submit" name="btnSubmit" value="Generate"></p>
	
</cfform>

<a href="<cfoutput>#cgi.http_referer#</cfoutput>"><<< Go Back</a>