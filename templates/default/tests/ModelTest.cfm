<cfcomponent extends="wheelsMapping.Test">
       
	<!--- setup runs before every test --->
    <cffunction name="setup">
    	<!--- save the orginal environment --->
		<cfset loc.originalApplication = Duplicate(application)>
		<!--- set transaction mode to rollback, so no records are affected --->
		<cfset application.wheels.transactionMode = "rollback">
        <!--- create an instance of our [NameSingularUppercase] --->
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").new()>
        <!--- a struct used to set valid model property values --->
        <cfset loc.validProperties = {
        	[validModelProperties]
        }>
        <!--- a struct used to set invalid model property values --->
        <cfset loc.invalidProperties = {
        	[invalidModelProperties]
        }>
    </cffunction>
    
    <!--- teardown runs after every test --->
    <cffunction name="teardown">
    	 <!--- re-instate the original application scope --->
        <cfset application = loc.originalApplication />
    </cffunction>

    <!--- assert that setup and teardown pass --->
    <cffunction name="test_setup_and_teardown">  
		<cfset assert("true")>
	</cffunction>

	<!--- assert that because the properties are set correct and meet validation, the model is valid --->
    <cffunction name="test_[NameSingularLowercase]_is_valid">
		<!--- set the properties of the model --->
		<cfset loc.[NameSingularLowercase].setProperties(loc.validProperties)>
		<cfset loc.result = loc.[NameSingularLowercase].valid()>
		<cfset assert("loc.result","loc.[NameSingularLowercase].allErrors()")>
	</cffunction>

	<!--- assert the model is invalid when no properties are set --->
	<cffunction name="test_[NameSingularLowercase]_is_not_valid">
		<cfset loc.[NameSingularLowercase].setProperties(loc.invalidProperties)>
        <cfset assert("! loc.[NameSingularLowercase].valid()")>
	</cffunction>

	<!--- assert the model creates successfully --->
	<cffunction name="test_[NameSingularLowercase]_create">
		<!--- set the properties of the model --->
		<cfset loc.[NameSingularLowercase].setProperties(loc.validProperties)>
		<cfset loc.result = loc.[NameSingularLowercase].save()>
        <cfset assert("loc.result", "loc.[NameSingularLowercase].allErrors()")>
	</cffunction>

	<!--- assert the model updates successfully --->
	<cffunction name="test_[NameSingularLowercase]_update">
		<cfset loc.[NameSingularLowercase] = model("[NameSingularLowercase]").findOne()>
		<cfset loc.[NameSingularLowercase].setProperties(loc.validProperties)>
		<cfset loc.result = loc.[NameSingularLowercase].update()>
        <cfset assert("loc.result", "loc.[NameSingularLowercase].allErrors()")>
	</cffunction>

	<!--- assert the model deletes successfully --->
	<cffunction name="test_[NameSingularLowercase]_delete">
		<cfset loc.[NameSingularLowercase] = model("[NameSingularLowercase]").findOne()>
		<cfset loc.result = loc.[NameSingularLowercase].delete()>
        <cfset assert("loc.result")>
	</cffunction>

</cfcomponent>