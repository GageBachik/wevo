// setup for user creation
var User = require('../models/users.js');

var userController = {
	auth: function(req, res) {
		console.log(req.body);
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
	}
};

module.exports = userController;