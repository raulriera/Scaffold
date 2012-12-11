<cfcomponent extends="wheelsMapping.Test">

    <!---
    # SETUP & TEARDOWN
    --->

    <!--- setup runs before every test --->
    <cffunction name="setup">
        <!--- save the orginal environment --->
        <cfset loc.originalApplication = Duplicate(application)>
        <!--- set transaction mode to rollback, so no records are affected --->
        <cfset application.wheels.transactionMode = "rollback">
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

    <!---
    # INDEX
    --->

    <cffunction name="test_index_displays_[NameSingularLowercase]_listing">
        <!--- setup some params for the tests --->
        <cfset loc.params = {controller="[NamePluralUppercase]", action="index"}>
        <!--- create an instance of the controller --->
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <!--- process the action of the controller --->
        <cfset loc.controller.$processAction()>
        <!--- get copy of the code the view generated --->
        <cfset loc.response = loc.controller.response()>
        <!--- make sure this string is displayed  --->
        <cfset loc.string = '<h1>Listing [NamePluralUppercase]</h1>'>
        <cfset assert('loc.response contains loc.string')>
        <!--- check additional strings --->

    </cffunction>

    <!---
    # SHOW
    --->

    <cffunction name="test_show_displays_[NameSingularLowercase]">
        <!--- find a [NameSingularLowercase] object --->
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").findOne()>
        <!--- define the key param --->
        <cfset loc.params = {controller="[NamePluralUppercase]", action="show", key=loc.[NameSingularLowercase].key()}>
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.response = loc.controller.response()>
        <cfset loc.string = '<h1>Showing [NameSingularUppercase]</h1>'>
        <cfset assert('loc.response contains loc.string')>
        <!--- check additional strings --->

    </cffunction>

    <cffunction name="test_show_redirects_to_index_if_a_[NameSingularLowercase]_is_not_found">
        <!--- provide a key that doesn't exist --->
        <cfset loc.params = {controller="[NamePluralUppercase]", action="show", key=-1}>
        <cfset loc.controller = controller(name="[NamePluralUppercase]", params=loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.redirect = loc.controller.$getRedirect()>
        <cfset assert('StructKeyExists(loc.redirect, "$args")')>
        <cfset assert('loc.redirect.$args.action eq "index"')>
    </cffunction>

    <!---
    # NEW
    --->

    <cffunction name="test_new_displays_[NameSingularLowercase]_form">
        <cfset loc.params = {controller="[NamePluralUppercase]", action="new"}>
        <!--- create a new [NameSingularLowercase] object for the form --->
        <cfset loc.params.[NameSingularLowercase] = model("[NameSingularUppercase]").new()>
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.response = loc.controller.response()>
        <cfset loc.string = '<h1>Create a New [NameSingularUppercase]</h1>'>
        <cfset assert('loc.response contains loc.string')>
        <!--- check additional strings --->

    </cffunction>

    <!---
    # EDIT
    --->

    <cffunction name="test_edit_displays_[NameSingularLowercase]_form">
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").findOne()>
        <cfset loc.params = {controller="[NamePluralUppercase]", action="edit", key=loc.[NameSingularLowercase].key()}>
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.response = loc.controller.response()>
        <cfset loc.string = '<h1>Editing [NameSingularUppercase]</h1>'>
        <cfset assert('loc.response contains loc.string')>
        <!--- check additional strings --->

    </cffunction>

    <cffunction name="test_edit_redirects_to_index_if_a_[NameSingularLowercase]_is_not_found">
        <cfset loc.params = {controller="[NamePluralUppercase]", action="edit", key=-1}>
        <cfset loc.controller = controller(name="[NamePluralUppercase]", params=loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.redirect = loc.controller.$getRedirect()>
        <cfset assert('StructKeyExists(loc.redirect, "$args")')>
        <cfset assert('loc.redirect.$args.action eq "index"')>
    </cffunction>

    <!---
    # CREATE
    --->

    <cffunction name="test_create_redirects_to_index_after_a_[NameSingularLowercase]_is_created">
        <cfset loc.params = {controller="[NamePluralUppercase]", action="create"}>
        <!--- set valid properties for creating a [NameSingularLowercase] --->
        <cfset loc.params.[NameSingularLowercase] = loc.validProperties>
        <cfset loc.controller = controller(name="[NamePluralUppercase]", params=loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.redirect = loc.controller.$getRedirect()>
        <cfset assert('StructKeyExists(loc.redirect, "$args")')>
        <cfset assert('loc.redirect.$args.action eq "index"')>
    </cffunction>

    <cffunction name="test_create_errors_display_when_[NameSingularLowercase]_is_invalid">
        <cfset loc.params = {controller="[NamePluralUppercase]", action="create"}>
        <!--- set invalid properties for creating a [NameSingularLowercase] --->
        <cfset loc.params.[NameSingularLowercase] = loc.invalidProperties>
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.response = loc.controller.response()>
        <cfset loc.message = 'There was an error creating the [NameSingularLowercase]'>
        <cfset assert('loc.response contains loc.message')>
    </cffunction>

    <!---
    # UPDATE
    --->

    <cffunction name="test_update_redirects_to_index_after_a_[NameSingularLowercase]_is_updated">
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").findOne()>
        <cfset loc.params = {controller="[NamePluralUppercase]", action="update", key=loc.[NameSingularLowercase].key()}>
        <cfset loc.params.[NameSingularLowercase] = loc.[NameSingularLowercase].properties()>
        <cfset loc.controller = controller(name="[NamePluralUppercase]", params=loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.redirect = loc.controller.$getRedirect()>
        <cfset assert('StructKeyExists(loc.redirect, "$args")')>
        <cfset assert('loc.redirect.$args.action eq "index"')>
    </cffunction>

    <cffunction name="test_update_errors_display_when_[NameSingularLowercase]_is_invalid">
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").findOne()>
        <cfset loc.params = {controller="[NamePluralUppercase]", action="update", key=loc.[NameSingularLowercase].key()}>
        <cfset loc.params.[NameSingularLowercase] = loc.invalidProperties>
        <cfset loc.controller = controller("[NamePluralUppercase]", loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.response = loc.controller.response()>
        <cfset loc.message = 'There was an error updating the [NameSingularLowercase]'>
        <cfset assert('loc.response contains loc.message')>
    </cffunction>

    <!---
    # DELETE
    --->

    <cffunction name="test_delete_redirects_to_index_after_a_[NameSingularLowercase]_is_deleted">
        <cfset loc.[NameSingularLowercase] = model("[NameSingularUppercase]").findOne()>
        <cfset loc.params = {controller="[NamePluralUppercase]", action="delete", key=loc.[NameSingularLowercase].key()}>
        <cfset loc.controller = controller(name="[NamePluralUppercase]", params=loc.params)>
        <cfset loc.controller.$processAction()>
        <cfset loc.redirect = loc.controller.$getRedirect()>
        <cfset assert('StructKeyExists(loc.redirect, "$args")')>
        <cfset assert('loc.redirect.$args.action eq "index"')>
    </cffunction>

</cfcomponent>