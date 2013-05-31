<cfoutput>
	<cfif flashKeyExists("success")>
	    <div class="success"> 
			#flash("success")#
	    </div>
	</cfif>
	<cfif flashKeyExists("error")>
	    <div class="error"> 
	        #flash("error")#
	    </div>
	</cfif>
</cfoutput>
