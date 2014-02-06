<cfcomponent output="false" mixin="controller" environment="design,development">

	<cffunction name="init">
		<cfset this.version = "1.0,1.0.1,1.0.2,1.1,1.1.4,1.1.5">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="generateScaffold" access="public" returnType="string" hint="Creates a Model a Controller and the Views for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object to scaffold">
		<cfargument name="type" type="string" required="true" default="everything" hint="Type of generation to execute, values are: everything, controller, model">
		<cfargument name="template" type="string" required="true" default="default" hint="The template to use for generating the scaffolds.">
		<cfargument name="overwrite" type="boolean" required="true" default="0" hint="Whether to overwrite existing files.">

		<cfset var loc = {}>
		
		<!--- Setup the information for the user --->
		<cfset loc.message = "">
		
		<!--- Check if there is a table for the object --->
		<cfset model(arguments.name)>
		
		<!--- Check which type of scaffold to execute --->
		<cfif ListFindNoCase(arguments.type, "view") gt 0>
		    <!--- Create the views --->
			<cfset loc.message = loc.message & $generateViews(arguments.name, arguments.template, arguments.overwrite) & "<br/>">
		</cfif>
		<cfif ListFindNoCase(arguments.type, "model") gt 0>
			<!--- Create the model --->
		    <cfset loc.message = loc.message & $generateModel(arguments.name, arguments.template, arguments.overwrite) & "<br/>">
		</cfif>
		<cfif ListFindNoCase(arguments.type, "controller") gt 0>
		    <!--- Create the controller --->
		    <cfset loc.message = loc.message & $generateController(arguments.name, arguments.template, arguments.overwrite) & "<br/>">
	    </cfif>
	    <cfif ListFindNoCase(arguments.type, "modelTest") gt 0>
	    	<!--- Create the model unit test --->
	    	<cfset loc.message = loc.message & $generateModelTest(arguments.name, arguments.template, arguments.overwrite) & "<br/>">
	    </cfif>
	    <cfif ListFindNoCase(arguments.type, "controllerTest") gt 0>
	    	<!--- Create the controller functional test --->
	    	<cfset loc.message = loc.message & $generateControllerTest(arguments.name, arguments.template, arguments.overwrite) & "<br/>">
	    </cfif>
	    <cfif (ListFindNoCase(arguments.type, "modelTest") gt 0 OR ListFindNoCase(arguments.type, "controllerTest") gt 0) AND NOT DirectoryExists(ExpandPath("tests/models")) AND NOT DirectoryExists(ExpandPath("tests/controllers"))>
	    	<!--- Copy the HasTests helper..  because it's helpful (on folder creation) --->
	    	<cfset loc.message = loc.message & $copyHasTests(arguments.template) & "<br/>">
	    </cfif>
		<cfif (ListFindNoCase(arguments.type, "modelTest") gt 0 OR ListFindNoCase(arguments.type, "controllerTest") gt 0) AND NOT FileExists(ExpandPath("tests/helpers.cfm"))>
	    	<!--- Copy the helpers.cfm --->
	    	<cfset loc.message = loc.message & $copyHelpers(arguments.template) & "<br/>">
	    </cfif>
		<cfreturn loc.message>	    
	</cffunction>
	
	<cffunction name="$checkIfFileExists" access="public" returntype="boolean" hint="Checks if the desired object is already created" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the file to search for">
	    <cfargument name="type" type="string" required="true" hint="Type of file to look for (Model, View, Controller)">
		<cfargument name="overwrite" type="boolean" required="true" hint="Whether to overwrite existing files.">

	    <cfset var loc = {}>
	 	
	    <!--- Expand the target folder --->
	    <cfswitch expression="#arguments.type#">
	    	<cfcase value="Model">
	    		<cfset loc.targetFolderPath = expandPath("models/")>
	        </cfcase>
	        <cfcase value="View">
	    		<cfset loc.targetFolderPath = expandPath("views/" & LCase(pluralize(arguments.name)))>
	        </cfcase>
	        <cfcase value="Controller">
	        	<cfset loc.targetFolderPath = expandPath("controllers/")>
	        </cfcase>
	        <cfcase value="ModelTest">
	    		<cfset loc.targetFolderPath = expandPath("tests/models/")>
	        </cfcase>
	        <cfcase value="ControllerTest">
	    		<cfset loc.targetFolderPath = expandPath("tests/controllers/")>
	        </cfcase>
	    </cfswitch>
	    
	    <!--- Find the names of all the files in the targeted folder --->
	    <cfdirectory name="loc.files" action="list" directory="#loc.targetFolderPath#" type="file">
	    
	    <!--- Check if the desired file is already in the targeted folder, or whether to overwrite --->
		<cfif arguments.overwrite>
			<cfset loc.wasFound = false>
		<cfelseif arguments.type IS "Model" AND ListFindNoCase(ValueList(loc.files.name), "#arguments.name#.cfc") GT 0>
			<cfset loc.wasFound = true>
		<cfelseif arguments.type IS "View" AND DirectoryExists(loc.targetFolderPath)>	
			<cfset loc.wasFound = true>
		<cfelseif arguments.type IS "Controller" AND ListFindNoCase(ValueList(loc.files.name), "#pluralize(arguments.name)#.cfc") GT 0>
			<cfset loc.wasFound = true>
		<cfelseif arguments.type IS "ModelTest" AND ListFindNoCase(ValueList(loc.files.name), "#arguments.name#Test.cfc") GT 0>
			<cfset loc.wasFound = true>
		<cfelseif arguments.type IS "ControllerTest" AND ListFindNoCase(ValueList(loc.files.name), "#pluralize(arguments.name)#Test.cfc") GT 0>
			<cfset loc.wasFound = true>
	    <cfelse>
	    	<cfset loc.wasFound = false>
		</cfif>
	    
	    <cfreturn loc.wasFound>
	</cffunction>
	
	<cffunction name="$moveFileToFolder" access="public" returntype="void" hint="Checks if the desired Model is already created" output="false">
		<cfargument name="name" type="string" required="true" hint="Name to set the file when moved">
	    <cfargument name="type" type="string" required="true" hint="Type of file to move for (Model, View, Controller)">
	    <cfargument name="template" type="string" required="true" default="default">
	     
	    <cfset var loc = {}>
	    
	    <!--- Expand the destination folder and read the file move over --->
	    <cfswitch expression="#arguments.type#">
	    	<cfcase value="Model">
	            
				<!--- Expand the from and destination folders --->
	    		<cfset loc.fromFolderPath = expandPath("plugins/scaffold/templates/#arguments.template#")>
				<cfset loc.destinationFolderPath = expandPath("models")>
	            
	            <!--- Read the template file --->
                <cffile action="read" file="#loc.fromFolderPath#/model.cfm" variable="loc.file">

	            <!--- Replace the placeholders with real data to the user 
	    		<cfset loc.file = $replacePlaceHolders(loc.file, arguments.name)> --->
	            
	            <!--- Write the file in the corresponding folder --->
	            <cffile action="write" file="#loc.destinationFolderPath#/#capitalize(arguments.name)#.cfc" output="#loc.file#" mode="777">

	        </cfcase>
	        
	        <cfcase value="View">
	        	
	            <!--- Expand the from and destination folders --->
	    		<cfset loc.fromFolderPath = expandPath("plugins/scaffold/templates/#arguments.template#/views")>
	            <cfset loc.destinationFolderPath = expandPath("views/" & LCase(pluralize(arguments.name)))>
	            
	            <!--- Create the directory to store the views in --->
	            <cfif NOT DirectoryExists(loc.destinationFolderPath)>
	            	<cfdirectory action="create" directory="#loc.destinationFolderPath#" mode="777">
	            </cfif>
	            
	            <!--- list the files in the template views folder --->
	            <cfdirectory action="list" directory="#loc.fromFolderPath#" name="loc.templateViewFiles">

	            <!--- Generate the forms and listing for the views --->
	            <cfset loc.entryForm = $generateEntryFormFromModel(arguments.name)>
	            <cfset loc.editForm = $generateEditFormFromModel(arguments.name)>
	            <cfset loc.indexListing = $generateListingViewFromModel(arguments.name)>
	            <cfset loc.showListing = $generateShowViewFromModel(arguments.name)>
	            <cfset loc.formFields = $generateFormFieldsFromModel(arguments.name)>

	            <cfloop query="loc.templateViewFiles">
	            	<cffile action="read" file="#loc.templateViewFiles.directory#/#loc.templateViewFiles.name#" variable="loc.viewFile">
	            	<!--- Replace the placeholders --->
	            	<cfset loc.viewFile = $replacePlaceHolders(loc.viewFile, arguments.name)>
	            	<cfset loc.viewFile = ReplaceNoCase(loc.viewFile, "[ENTRYFORM]", loc.entryForm)>
	            	<cfset loc.viewFile = ReplaceNoCase(loc.viewFile, "[EDITFORM]", loc.editForm)>
	            	<cfset loc.viewFile = ReplaceNoCase(loc.viewFile, "[SHOWLISTINGCOLUMNS]", loc.showListing)>
	            	<cfset loc.viewFile = ReplaceNoCase(loc.viewFile, "[INDEXLISTINGCOLUMNS]", loc.indexListing)>
	            	<cfset loc.viewFile = ReplaceNoCase(loc.viewFile, "[FORMFIELDS]", loc.formFields)>

	            	<!--- Write the file in the corresponding folder --->
	            	<cffile action="write" file="#loc.destinationFolderPath#/#loc.templateViewFiles.name#" output="#loc.viewFile#" mode="777"> 
	            </cfloop>

	        </cfcase>
	        
	        <cfcase value="Controller">
	        	<!--- Expand the from and destination folders --->
	    		<cfset loc.fromFolderPath = expandPath("plugins/scaffold/templates/#arguments.template#")>
	            <cfset loc.destinationFolderPath = expandPath("controllers")>
	            
	            <!--- Read the template file --->
	            <cffile action="read" file="#loc.fromFolderPath#/controller.cfm" variable="loc.file">
	            
				<!--- Replace the placeholders with real data to the user --->
	    		<cfset loc.file = $replacePlaceHolders(loc.file, arguments.name)>
	            
	            <!--- Write the file in the corresponding folder --->
	            <cffile action="write" file="#loc.destinationFolderPath#/#capitalize(pluralize(arguments.name))#.cfc" output="#loc.file#" mode="777"> 
	        </cfcase>
	        
	        <cfcase value="ModelTest">
	            
	    		<!--- Check for a custom model test file --->
	    		<cfset loc.sourceFilePath = ExpandPath("plugins/scaffold/templates/#arguments.template#/tests/modelTest.cfm")>

	    		<!--- if I can't find a custom model test, use the default --->
	    		<cfif not FileExists(loc.sourceFilePath)>
	    			<cfset loc.sourceFilePath = ExpandPath("plugins/scaffold/templates/default/tests/modelTest.cfm")>	
	    		</cfif>
				<cfset loc.destinationFolderPath = ExpandPath("tests/models")>
				<cfset loc.destinationFilePath = loc.destinationFolderPath & "\#capitalize(arguments.name)#Test.cfc"> 
	            
	       		<!--- read the unit test template --->
	       		<cffile action="read" file="#loc.sourceFilePath#" variable="loc.file">

	       		<!--- Replace the placeholders with real data to the user --->
	            <cfset loc.file = $replacePlaceHolders(loc.file, arguments.name)>
	            
	       		<!--- Create the directory to store the test in --->
	       		<cfif NOT directoryExists(loc.destinationFolderPath)>
	       			<cfdirectory action="create" directory="#loc.destinationFolderPath#" mode="777">
	       		</cfif>

	       		<!--- Write the file in the corresponding folder --->
	       		<cffile action="write" file="#loc.destinationFilePath#" output="#loc.file#" mode="777"> 

	        </cfcase>

	        <cfcase value="ControllerTest">

	        	<!--- Check for a custom model test file --->
	    		<cfset loc.sourceFilePath = ExpandPath("plugins/scaffold/templates/#arguments.template#/tests/controllerTest.cfm")>
	    		<!--- if I can't find a custom model test, use the default --->
	    		<cfif not FileExists(loc.sourceFilePath)>
	    			<cfset loc.sourceFilePath = expandPath("plugins/scaffold/templates/default/tests/controllerTest.cfm")>
	    		</cfif>
				<cfset loc.destinationFolderPath = expandPath("tests/controllers")>
				<cfset loc.destinationFilePath = loc.destinationFolderPath & "\#capitalize(pluralize(arguments.name))#Test.cfc"> 
	            
	       		<!--- read the unit test template --->
	       		<cffile action="read" file="#loc.sourceFilePath#" variable="loc.file">

	       		<!--- Replace the placeholders with real data to the user --->
	            <cfset loc.file = $replacePlaceHolders(loc.file, arguments.name)>
	            
	       		<!--- Create the directory to store the test in --->
	       		<cfif NOT directoryExists(loc.destinationFolderPath)>
	       			<cfdirectory action="create" directory="#loc.destinationFolderPath#" mode="777">
	       		</cfif>

	       		<!--- Write the file in the corresponding folder --->
	       		<cffile action="write" file="#loc.destinationFilePath#" output="#loc.file#" mode="777"> 

	        </cfcase>

	        <cfdefaultcase>
	        	<!--- Display a nice Wheels error? --->
	        </cfdefaultcase>
	    </cfswitch>
	    
	</cffunction>
	
	<cffunction name="$replacePlaceHolders" access="public" returntype="string" hint="Replaces the placeholders in the templates" output="false">
		<cfargument name="content" type="string" required="true" hint="The content where the placeholders are located for replacing">
	    <cfargument name="value" type="string" required="true" hint="The value to replace the placeholders with">
	    
	    <cfset var loc = {}>
	    
	    <!--- Find all occurences of [NamePluralLowercaseDeHumanized] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(arguments.content, "[NamePluralLowercaseDeHumanized]", LCase($replaceUppercaseWithDash(pluralize(arguments.value))), "All")>
	    <!--- Find all occurences of [NamePluralLowercase] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[NamePluralUppercase]", capitalize(pluralize(arguments.value)), "All")>
	    <!--- Find all occurences of [NamePluralLowercase] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[NamePluralLowercase]", LCase(pluralize(arguments.value)), "All")>
	    <!--- Find all occurences of [NameSingularUppercase] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[NameSingularUppercase]", capitalize(arguments.value), "All")>
	    <!--- Find all occurences of [NameSingularLowercase] and replace it--->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[NameSingularLowercase]", LCase(arguments.value), "All")>
	    <!--- Find all occurences of [PrimaryKey] and replace it with the actual primary key(s) --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[PrimaryKey]", model(LCase(arguments.value)).primaryKey(), "All")>
	    <!--- Find all occurences of [validModelProperties] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[validModelProperties]", $generateValidModelProperties(arguments.value))>
	    <!--- Find all occurences of [invalidModelProperties] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[invalidModelProperties]", $generateInvalidModelProperties(arguments.value))>
	    <!--- Find all occurences of [formFields] and replace it --->
	    <cfset loc.replacedContent = ReplaceNoCase(loc.replacedContent, "[formFields]", $generateFormFieldsFromModel(arguments.value))>

	    <cfreturn loc.replacedContent>
	    
	</cffunction>
	
	<cffunction name="$generateEntryFormFromModel" access="public" returnType="string" hint="Generates an entry form from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the form for">
		
		<cfset var loc = {}>
		
		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>

		<cfprocessingdirective suppressWhiteSpace="true">
		<cfsavecontent variable="loc.form">
			
			<cfoutput>
			[errorMessagesFor("<cfoutput>#loc.nameInSingularLowercase#</cfoutput>")]
	
			[startFormTag(action="create")]
		
				[includePartial("fields")]

				[submitTag()]
				
			[endFormTag()]
			</cfoutput>
		</cfsavecontent>
		</cfprocessingdirective>
		
		<!--- Replace the brackets with number signs --->
		<cfset loc.form = Replace(loc.form, "[", "##", "All")>
		<cfset loc.form = Replace(loc.form, "]", "##", "All")>
		
		<cfreturn loc.form>
	</cffunction>
	
	<cffunction name="$generateEditFormFromModel" access="public" returnType="string" hint="Generates an edit form from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the form for">
		
		<cfset var loc = {}>
		
		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		
		<cfprocessingdirective suppressWhiteSpace="true">
		<cfsavecontent variable="loc.form">
			<cfoutput>
			[errorMessagesFor("<cfoutput>#loc.nameInSingularLowercase#</cfoutput>")]
	
			[startFormTag(action="update", key=params.key)]
		
				[includePartial("fields")]
				
				[submitTag()]
				
			[endFormTag()]
			</cfoutput>
		</cfsavecontent>
		</cfprocessingdirective>
		
		<!--- Replace the brackets with number signs --->
		<cfset loc.form = Replace(loc.form, "[", "##", "All")>
		<cfset loc.form = Replace(loc.form, "]", "##", "All")>
		
		<cfreturn loc.form>
	</cffunction>
	
	<cffunction name="$generateFormFieldsFromModel" access="public" returnType="string" hint="Generates form fields from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the fields for">
		
		<cfset var loc = {}>
		
		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		
		<!--- Introspect the table to find the column names and types --->		
		<cfset loc.columns = model(loc.nameInSingularLowercase).$classData()>
		<cfset loc.columnsInOrder = loc.columns.columnList>
		
		<cfset loc.fields = ""> 
		<cfloop list="#loc.columnsInOrder#" index="loc.property">
			<cfif ListFindNoCase(model(loc.nameInSingularLowercase).primaryKey(), loc.columns.properties[loc.property].COLUMN) IS 0 AND loc.columns.properties[loc.property].COLUMN IS NOT "createdAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "updatedAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "deletedAt">
				<cfset loc.fields = ListAppend(loc.fields, "[#$generateFormField(loc.nameInSingularLowercase, loc.columns.properties[loc.property])#]", "|")>
			</cfif>										
		</cfloop>

		<!--- Replace the pipes with crlf --->
		<cfset loc.fields = Replace(loc.fields, "|", Chr(13) & Chr(10), "All")>

		<!--- Replace the brackets with number signs --->
		<cfset loc.fields = Replace(loc.fields, "[", "##", "All")>
		<cfset loc.fields = Replace(loc.fields, "]", "##", "All")>

		<cfreturn loc.fields>
	</cffunction>

	<cffunction name="$generateFormField" access="public" returnType="string" hint="Generates a form field using Wheel's view helpers" output="false">
		<cfargument name="objectName" type="string" required="true" hint="Name of the object which holds the property">
		<cfargument name="columnObject" type="struct" required="true" hint="Struct of the database column">
		
		<cfset var loc = {}>

		<cfswitch expression="#arguments.columnObject.TYPE#">
			<cfcase value="cf_sql_bit,cf_sql_tinyint" delimiters=",">
				<!--- Return a checkbox --->
				<cfset loc.fieldTag = "checkBox(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfcase>

			<cfcase value="cf_sql_longvarchar">
				<!--- Return a textarea --->
				<cfset loc.fieldTag = "textArea(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfcase>

			<cfcase value="cf_sql_date">
				<!--- Return a calendar --->
				<cfset loc.fieldTag = "dateSelect(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfcase>

			<cfcase value="cf_sql_time">
				<!--- Return a time picker --->
				<cfset loc.fieldTag = "timeSelect(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfcase>

			<cfcase value="cf_sql_timestamp">
				<!--- Return a calendar and time picker --->
				<cfset loc.fieldTag = "dateTimeSelect(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', dateOrder='year,month,day', monthDisplay='abbreviations', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfcase>

			<cfdefaultcase>
				<!--- Return a text if everything fails --->
				<cfset loc.fieldTag = "textField(objectName='#arguments.objectName#', property='#arguments.columnObject.COLUMN#', label='#humanize(arguments.columnObject.COLUMN)#')">
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn loc.fieldTag>
	</cffunction>
	
	<cffunction name="$generateListingViewFromModel" access="public" returnType="string" hint="Generates a listing View from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the listing for">
		
		<cfset var loc = {}>
		
		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		<cfset loc.nameInPluralLowercase = LCase(pluralize(arguments.name))>
		<cfset loc.nameInPluralUppercase = capitalize(pluralize(arguments.name))>
		
		<!--- Introspect the table to find the column names --->
		<cfset loc.columns = model(loc.nameInSingularLowercase).$classData().columnList>
		
		<cfprocessingdirective suppressWhiteSpace="true">
		<cfsavecontent variable="loc.form">
			<cfoutput>
				<cfloop list="#loc.columns#" index="loc.column">
					[cfcol header="#humanize(loc.column)#" text="###loc.column###" /]
				</cfloop>
			</cfoutput>
		</cfsavecontent>
		</cfprocessingdirective>
		
		<!--- Replace the brackets with ColdFusion tag brackets --->
		<cfset loc.form = Replace(loc.form, "[", "<", "All")>
		<cfset loc.form = Replace(loc.form, "]", ">", "All")>
		
		<cfreturn loc.form>
	</cffunction>
	
	<cffunction name="$generateShowViewFromModel" access="public" returnType="string" hint="Generates a show View from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the show for">
		
		<cfset var loc = {}>
		
		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		<cfset loc.nameInPluralLowercase = LCase(pluralize(arguments.name))>
		<cfset loc.nameInPluralUppercase = capitalize(pluralize(arguments.name))>
		
		<!--- Introspect the table to find the column names --->
		<cfset loc.columns = model(loc.nameInSingularLowercase).$classData().columnList>
		
		<cfprocessingdirective suppressWhiteSpace="true">
		<cfsavecontent variable="loc.form">
			<cfoutput>
				<cfloop list="#loc.columns#" index="loc.column">
					<p><span>#humanize(loc.column)#</span> <br />
						###loc.nameInSingularLowercase & "." & loc.column###</p>
				</cfloop>
			</cfoutput>
		</cfsavecontent>
		</cfprocessingdirective>
		
		<!--- Replace the brackets with ColdFusion tag brackets --->
		<cfset loc.form = Replace(loc.form, "[", "<", "All")>
		<cfset loc.form = Replace(loc.form, "]", ">", "All")>
		
		<cfreturn loc.form>
	</cffunction>
	
	<cffunction name="$generateModel" access="public" returnType="string" hint="Creates a Model for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		<cfargument name="template" type="string" required="true" default="default">
		<cfargument name="overwrite" type="boolean" required="true" default="0">

		<cfset var loc = {}>
		
		<!--- Check that the file has not been already created --->
		<cfif $checkIfFileExists(arguments.name, "Model", arguments.overwrite)>
		    <cfset loc.message = "File 'models/#capitalize(arguments.name)#.cfc' already exists so skipped.">
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "Model", arguments.template)>
		    <cfset loc.message = "File 'models/#capitalize(arguments.name)#.cfc' created.">
		</cfif>
		
		<cfreturn loc.message>
	</cffunction>
	
	<cffunction name="$generateViews" access="public" returnType="string" hint="Creates the 'index,show,new and edit' Views for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		<cfargument name="template" type="string" required="true" default="default">
		<cfargument name="overwrite" type="boolean" required="true" default="0">
		    
		<cfset var loc = {}>
		
		<!--- Check that the folder to store the views has not been already created --->
		<cfif $checkIfFileExists(arguments.name, "View", arguments.overwrite)>
		    <cfset loc.message = "Folder 'views/#LCase(pluralize(arguments.name))#/' already exists so skipped.">  
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "View", arguments.template)>
			<cfset loc.message = "Folder 'views/#LCase(pluralize(arguments.name))#/' and view files created.">		
		</cfif>
		
		<cfreturn loc.message>
	</cffunction>
	
	<cffunction name="$generateController" access="public" returnType="string" hint="Creates a Controller for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		<cfargument name="template" type="string" required="true" default="default">
		<cfargument name="overwrite" type="boolean" required="true" default="0">
		    
		<cfset var loc = {}>
		
		<!--- Check that the file has not been already created --->
		<cfif $checkIfFileExists(arguments.name, "Controller", arguments.overwrite)>
		    <cfset loc.message = "File 'controllers/#capitalize(pluralize(arguments.name))#.cfc' already exists so skipped.">
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "Controller", arguments.template)>
		    <cfset loc.message = "File 'controllers/#capitalize(pluralize(arguments.name))#.cfc' created.">
		</cfif>
		
		<cfreturn loc.message>
	</cffunction>
	
	<cffunction name="$generateModelTest" access="public" returnType="string" hint="Creates Model unit tests for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		<cfargument name="template" type="string" required="true" default="default">
		<cfargument name="overwrite" type="boolean" required="true" default="0">

		<cfset var loc = {}>
		
		<cfset loc.file = "tests/models/#capitalize(arguments.name)#Test.cfc">

		<!--- Check that the file has not been already created --->
		<cfif $checkIfFileExists(arguments.name, "ModelTest", arguments.overwrite)>
		    <cfset loc.message = "File '#loc.file#' already exists so skipped.">
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "ModelTest", arguments.template)>
		    <cfset loc.message = "File '#loc.file#' created.">
		</cfif>
		
		<cfreturn loc.message>
	</cffunction>

	<cffunction name="$generateControllerTest" access="public" returnType="string" hint="Creates controller functional tests for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		<cfargument name="template" type="string" required="true" default="default">
		<cfargument name="overwrite" type="boolean" required="true" default="0">

		<cfset var loc = {}>
		
		<cfset loc.file = "tests/controllers/#capitalize(pluralize(arguments.name))#Test.cfc">

		<!--- Check that the file has not been already created --->
		<cfif $checkIfFileExists(arguments.name, "ControllerTest", arguments.overwrite)>
		    <cfset loc.message = "File '#loc.file#' already exists so skipped.">
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "ControllerTest", arguments.template)>
		    <cfset loc.message = "File '#loc.file#' created.">
		</cfif>

		<cfreturn loc.message>
	</cffunction>

	<cffunction name="$generateValidModelProperties" access="public" returnType="string" hint="Generates a string of invalid name/value pairs from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the form for">
		
		<cfset var loc = {}>
		
		<!--- helpers --->
		<cfset loc.delim = "," & chr(13) & chr(10) & repeatString(chr(9), 3)>

		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		<cfset loc.nameInPluralLowercase = LCase(pluralize(arguments.name))>
		<cfset loc.nameInPluralUppercase = capitalize(pluralize(arguments.name))>
		
		<!--- Introspect the table to find the column names and types --->		
		<cfset loc.columns = model(loc.nameInSingularLowercase).$classData()>
		<cfset loc.columnsInOrder = loc.columns.columnList>

		<!--- define return value --->
		<cfset loc.properties = "">
		
		<cfloop list="#loc.columnsInOrder#" index="loc.property">

			<cfif ListFindNoCase(model(loc.nameInSingularLowercase).primaryKey(), loc.columns.properties[loc.property].COLUMN) IS 0 AND loc.columns.properties[loc.property].COLUMN IS NOT "createdAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "updatedAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "deletedAt">
				
				<cfswitch expression="#loc.columns.properties[loc.property].TYPE#">
					<cfcase value="cf_sql_bit,cf_sql_tinyint,cf_sql_integer,cf_sql_bigint,cf_sql_smallint" delimiters=",">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#=1", "|")>
					</cfcase>

					<cfcase value="cf_sql_date,cf_sql_time,cf_sql_timestamp">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#=createDateTime(2000,1,1,0,0,0)", "|")>
					</cfcase>

					<cfcase value="cf_sql_decimal,cf_sql_double,cf_sql_float,cf_sql_money,cf_sql_money4,cf_sql_numeric">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#=1.00", "|")>
					</cfcase>

					<cfdefaultcase>
						<!--- Return a string if everything fails --->
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#='#Left(loc.property & "_string",loc.columns.properties[loc.property].SIZE)#'", "|")>
					</cfdefaultcase>
				</cfswitch>

			</cfif>
		</cfloop>
		
		<cfset loc.properties = Replace(loc.properties, "|", loc.delim ,"all")>

		<cfreturn loc.properties>
	</cffunction>

	<!--- TODO: refactor this.. its almost a duplicate of $generateValidModelProperties, the only diff is the values that get written in the switch/case --->
	<cffunction name="$generateInvalidModelProperties" access="public" returnType="string" hint="Generates a string of invalid name/value pairs from a Model by reading the table schema" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the model to generator the form for">
		
		<cfset var loc = {}>
		
		<!--- helpers --->
		<cfset loc.delim = "," & chr(13) & chr(10) & repeatString(chr(9), 3)>

		<!--- Define the name of the object returned from the controller --->
		<cfset loc.nameInSingularLowercase = LCase(arguments.name)>
		<cfset loc.nameInPluralLowercase = LCase(pluralize(arguments.name))>
		<cfset loc.nameInPluralUppercase = capitalize(pluralize(arguments.name))>
		
		<!--- Introspect the table to find the column names and types --->		
		<cfset loc.columns = model(loc.nameInSingularLowercase).$classData()>
		<cfset loc.columnsInOrder = loc.columns.columnList>

		<!--- define return value --->
		<cfset loc.properties = "">
		
		<cfloop list="#loc.columnsInOrder#" index="loc.property">

			<cfif ListFindNoCase(model(loc.nameInSingularLowercase).primaryKey(), loc.columns.properties[loc.property].COLUMN) IS 0 AND loc.columns.properties[loc.property].COLUMN IS NOT "createdAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "updatedAt" AND loc.columns.properties[loc.property].COLUMN IS NOT "deletedAt">
				
				<cfswitch expression="#loc.columns.properties[loc.property].TYPE#">
					<cfcase value="cf_sql_bit,cf_sql_tinyint,cf_sql_integer,cf_sql_bigint,cf_sql_smallint" delimiters=",">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#='abcd'", "|")>
					</cfcase>

					<cfcase value="cf_sql_date,cf_sql_time,cf_sql_timestamp">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#='efgh'", "|")>
					</cfcase>

					<cfcase value="cf_sql_decimal,cf_sql_double,cf_sql_float,cf_sql_money,cf_sql_money4,cf_sql_numeric">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#='hijk'", "|")>
					</cfcase>
					
					<cfcase value="cf_sql_longvarchar">
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#=''", "|")>
					</cfcase>
					
					<cfdefaultcase>
						<!--- Return a string if everything fails --->
						<cfset loc.properties = listAppend(loc.properties, "#loc.property#='#RepeatString("x", loc.columns.properties[loc.property].SIZE + 1)#'", "|")>
					</cfdefaultcase>
				</cfswitch>

			</cfif>
		</cfloop>
		
		<cfset loc.properties = Replace(loc.properties, "|", loc.delim ,"all")>

		<cfreturn loc.properties>
	</cffunction>

	<cffunction name="$copyHasTests" access="public" returnType="string" hint="Copies the HasTests.cfc" output="false">
	    <cfargument name="template" type="string" required="true" default="default">

	    <cfset var loc = {}>

    	<!--- Check for a custom hasTests helper file --->
		<cfset loc.sourcePath = ExpandPath("plugins/scaffold/templates/#arguments.template#/tests/HasTests.cfm")>
		<!--- if I can't find a custom helper, use the default --->
		<cfif not FileExists(loc.sourcePath)>
			<cfset loc.sourcePath = expandPath("plugins/scaffold/templates/default/tests/HasTests.cfm")>
		</cfif>
    	<cfset loc.destinationPath = ExpandPath("tests/HasTests.cfc")>
    	
    	<cfif FileExists(loc.destinationPath)>
    		<cfset loc.message = "File '#tests/HasTests.cfc#' already exists so skipped.">
    	<cfelse>
    		<cffile action="copy" source="#loc.sourcePath#" destination="#loc.destinationPath#" mode="777">
    		<cfset loc.message = "File 'tests/HasTests.cfc' created.<br/>">
    	</cfif>
    	
		<cfreturn loc.message>
	</cffunction>

	<cffunction name="$copyHelpers" access="public" returnType="string" hint="Copies the helpers.cfm" output="false">
	    <cfargument name="template" type="string" required="true" default="default">

	    <cfset var loc = {}>

	    <!--- Check for a custom helper file --->
		<cfset loc.sourcePath = ExpandPath("plugins/scaffold/templates/#arguments.template#/tests/helpers.cfm")>
		<!--- if I can't find a custom helper, use the default --->
		<cfif not FileExists(loc.sourcePath)>
			<cfset loc.sourcePath = expandPath("plugins/scaffold/templates/default/tests/helpers.cfm")>
		</cfif>
    	<cfset loc.destinationPath = ExpandPath("tests/helpers.cfm")>
    	
    	<cfif FileExists(loc.destinationPath)>
    		<cfset loc.message = "File 'tests/helpers.cfm' already exists so skipped.">
    	<cfelse>
    		<cffile action="copy" source="#loc.sourcePath#" destination="#loc.destinationPath#" mode="777">
    		<cfset loc.message = "File 'tests/helpers.cfm' created.<br/>">
    	</cfif>
    	
		<cfreturn loc.message>
	</cffunction>

	<cffunction name="$generateRoutes" access="public" returnType="string" hint="Creates all the routes for the name of the argument passed" output="false">
		<cfargument name="name" type="string" required="true" hint="Name of the object">
		
		<cfset var loc = {}>
		
		<!--- Check that the file has not been already created 
		<cfif $checkIfFileExists(arguments.name, "Controller")>
		    <cfset loc.message = "File 'controllers/#capitalize(pluralize(arguments.name))#.cfc' already exists so skipped.">
		<cfelse>
			<cfset $moveFileToFolder(arguments.name, "Controller")>
		    <cfset loc.message = "File 'controllers/#capitalize(arguments.name)#.cfc' created.">
		</cfif>--->
		
		<cfreturn loc.message>
	</cffunction>
	
	<cffunction name="$replaceUppercaseWithDash" access="public" returnType="string" hint="Adds a dash before every upper case letter">
		<cfargument name="text" type="string" required="true">
		
		<cfset var loc = {}>
		<cfset loc.returnValue = REReplace(arguments.text, "([[:upper:]])", "-\1", "all")>
		
		<cfreturn loc.returnValue>
	</cffunction>
	
	<cffunction name="getTemplates" access="public" output="false" hint="Gets a list of the available templates from the template folder to make a select list.">
	   
	    <cfset var loc = {}>
	    <cfset loc.templateFolderPath = ExpandPath("plugins/scaffold/templates")>
	            
	    <cfdirectory action="list" directory="#loc.templateFolderPath#" name="loc.templateList" sort="name DESC">
	            
	    <cfreturn loc.templateList>
	</cffunction>
	
</cfcomponent>