
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave('Message', function(request, response) {
	request.object.fetch({
		success: function(message){

			var query = new Parse.Query(Parse.User);
			query.containedIn('objectId', message.get('recipients'));
			Parse.Push.send({
				where: query,
				data : {
					alert: 'Message from ' + message.get('senderName'),
					badge: 'Increment',
					p: 'm',
					fu: message.get('senderName'),
				},
			});
		}
	});
});
''