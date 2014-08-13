var mongoose = require('mongoose');
var findOneOrCreate = require('mongoose-find-one-or-create');
var Schema = mongoose.Schema;

var UserSchema = new Schema({
	username: {
		type: String,
		unique: true
	},
	password: {
		type: String
	},
	currentPlaylist: {
		type: Array,
		default: []
	}
});

UserSchema.plugin(findOneOrCreate);

var User = mongoose.model('User', UserSchema);

module.exports = User;