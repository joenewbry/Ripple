
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

// makes sure all installations point to current user
// Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
// 	Parse.Cloud.useMasterKey();
// 	if (request.user) {
// 		alert('user set')
// 		// TODO, when changing iOS app to use const strings change sting to user
// 		request.object.set('user', request.user);

// 	} else {
// 		alert('user unset');
// 		// TODO, when changing iOS app to use const strings change sting to user
// 		request.object.unset('user');
// 	}
// 	response.success();
// });

// make sure that push notification is sent out after message is saved
Parse.Cloud.afterSave('Message', function(request, response) {
	request.object.fetch({
		success: function(message){

			var query = new Parse.Query(Parse.Installation);
			query.containedIn('user', message.get('recipients'));

			alert('Participants are' + message.get('recipients'));
			//alert('Parse Installation Users are')

			Parse.Push.send({
				where: query,
				data : {
					alert: message.get('message'),
					badge: 'Increment',
					p: 'm',
					pid: message.id,
					fu: message.get('senderName'),
					fuid: message.get('senderUserId'),

				},
			});
		}
	});
});
''