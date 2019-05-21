<cfoutput>
	<cfscript>
		if ( Len($.event('sendHTTPLog')) ) {
			var entry = {
				property1: "this is the value for property 1",
				property2: "this is the value for property 2",
				array1: [1,2,3,4,5,6]
			};

			var httpService = new http();
			httpService.setURL('http://logstash:8080');
			httpService.setMethod('POST');
			httpService.addParam(type='header', name='Content-Type', value='application/json');
			httpService.addParam(type='header', name='Accept', value='application/json');
			httpService.addParam(type='body', value=serializeJSON(entry));
			var r = httpService.send().getPrefix();
		}
	</cfscript>

	<!DOCTYPE html>
	<html lang="en"<cfif $.hasFETools()> class="mura-edit-mode"</cfif>>
		<cfinclude template="inc/html_head.cfm" />
		<body id="#$.getTopID()#" class="depth-#$.content('depth')# #$.createCSSHook($.content('menuTitle'))#">
			<cfinclude template="inc/navbar.cfm" />
			<div class="template py-5">
				<div class="container">
					<cfinclude template="inc/breadcrumb.cfm" />
					<div class="row">
						<aside class="col-md-12 col-lg-4 col-xl-3 sidebar">
							#$.dspObjects(1)#
						</aside><!-- /.span -->
						<section class="col-md-12 col-lg-8 col-xl-9 content">
							<cfset pageTitle = $.content('type') neq 'Page' ? $.content('title') : ''>
							#$.dspBody(
								body=$.content('body')
								, pageTitle=pageTitle
								, crumbList=false
								, showMetaImage=false
							)#
							
							<h1>Let's test out Logstash!</h1>
							<div><a href="/?sendHTTPLog=1">Send log via HTTP to logstash:8080</a></div>
							<cfif Len($.event('sendHTTPLog'))>
								<h3>Log sent</h3>
								<p>Check out your Elastic Search instance to see if you have a new log in the index "myhttpindex-{todaysDate}"</p>
								Get all indices: <a href="http://localhost:9200/_cat/indices?v" target="_blank">http://localhost:9200/_cat/indices?v</a>
							</cfif>

							#$.dspObjects(2)#
						</section>
					</div><!--- /.row --->
				</div><!--- /.container --->
			</div>
			<cfinclude template="inc/footer.cfm" />
			<cfinclude template="inc/html_foot.cfm" />
		</body>
	</html>
</cfoutput>
