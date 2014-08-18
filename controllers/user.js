// setup for user creation
var User = require('../models/users.js');
var Promise = require("bluebird");
var request = Promise.promisifyAll(require('request'));

var userController = {
	auth: function(req, res) {
		// console.log(req.body);
		User.findOneOrCreate({username: req.body.username, password: req.body.password}, {
			username: req.body.username, 
			password: req.body.password
		}, function(err, user){
			if (err) { 
				res.send(err);
			}else{
				res.send({name: user._id});
			}
		});
	},
	getNextTen: function(req, res){
		var youtubeIdCalls = [];

		var sendNextTenIds = function(trackList){
			trackList.map(function(trackName){
				youtubeIdCalls.push(request.getAsync('https://www.googleapis.com/youtube/v3/search?part=id&maxResults=1&q='+trackName+'&type=video&videoEmbeddable=true&key=AIzaSyDcL_3c23SfRPdgIAaRcz-rSDmb62S1yDA').spread(function(res, body){return JSON.parse(body).items[0].id.videoId;}));
			});

			Promise.all(youtubeIdCalls).then(function(videoIds){
				console.log("videoIds:", videoIds);
				res.send({videoIds: videoIds});

			});
		}

		User.findOne({_id: req.body.userId}, function (err, user) {
			var nextTen = user.currentPlaylist.splice(0,10);
			sendNextTenIds(nextTen);
			user.currentPlaylist = user.currentPlaylist;
		    user.save(function (err) {
		        if(err) {
		            console.error('ERROR!');
		        }
		    });
		});
	}
};

module.exports = userController;