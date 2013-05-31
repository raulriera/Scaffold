<cfcomponent extends="wheelsMapping.Test">

	<!--- see if all controllers have a corresponding functional test file --->
	<cffunction name="test_controller_functional_tests_exist">
		<!--- add files to this list if you don't want to enforce test file existence --->
		<cfset var skip = "">
		<!--- run the hasTest helper --->
		<cfset $_hasTests("controller", skip)>
	</cffunction>
	
	<!--- see if all models have a corresponding unit test file --->
	<cffunction name="test_model_unit_tests_exist">
		<cfset var skip = "">
		<cfset $_hasTests("model", skip)>
	</cffunction>

	<!--- just for DRYness --->
	<cffunction name="$_hasTests" access="private">
		<cfargument name="type" type="string" required="true">
		<cfargument name="skip" type="string" required="false" default="">

		<!--- paths to folders --->
		<cfswitch expression="#arguments.type#">
			<cfcase value="controller">
				<cfset loc.mvcFolder = ExpandPath("controllers")>
				<cfset loc.testsFolder = ExpandPath("tests/functional")>
				<!--- core files must be skipped --->
				<cfset loc.skip = "Controller.cfc,Wheels.cfc">
			</cfcase>
			<cfcase value="model">
				<cfset loc.mvcFolder = ExpandPath("models")>
				<cfset loc.testsFolder = ExpandPath("tests/unit")>
				<cfset loc.skip = "Model.cfc,Wheels.cfc">
			</cfcase>
		</cfswitch>

		<!--- also skip files passed in as an argument --->
		<cfif arguments.skip neq "">
			<cfset loc.skip = ListAppend(loc.skip, arguments.skip)>
		</cfif>
		
		<!--- get the models and tests --->
		<cfdirectory action="list" directory="#loc.mvcFolder#" filter="*.cfc" name="mvc">
		<cfdirectory action="list" directory="#loc.testsFolder#" filter="*.cfc" name="tests">

		<!--- assert there are some tests --->
		<cfset assert("tests.recordCount gt 0", "loc.testsFolder")>

		<!--- loop thru the models and check if there is corresponding unit test file --->
		<cfloop query="mvc">
			<cfif ListFindNoCase(loc.skip, mvc.name) eq 0>
				<cfset loc.testFile = ListFirst(mvc.name, ".")>
				<cfset loc.testFileName = loc.testFile & "Test.cfc">
				<cfset loc.fileHasTest = false>
				<!--- nested loop allows test files to be moved into subfolders --->
				<cfloop query="tests">
					<cfif loc.testFileName eq tests.name>
						<cfset loc.fileHasTest = true>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfset assert("loc.fileHasTest", "loc.testFileName", "mvc.name")>
			</cfif>
		</cfloop>
	</cffunction>

</cfcomponent>