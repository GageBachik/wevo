var express = require('express');
var bodyParser = require('body-parser');
var indexController = require('./controllers/index.js');
var userController = require('./controllers/user.js');
var musicController = require('./controllers/music.js');

var app = express();
app.set('view engine', 'jade');
app.set('views', __dirname + '/views');
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: false}));

var mongoose = require('mongoose');
mongoose.connect('mongodb://gbachik:freedom347@ds055689.mongolab.com:55689/wevo');

app.get('/', indexController.index);

//signin or create

app.post('/auth', userController.auth);

//start music search

app.post('/music/:userId', musicController.musicSearch);

var port = process.env.PORT || 1337;
var server = app.listen(port, function() {
	console.log('Express server listening on port ' + server.address().port);
});
