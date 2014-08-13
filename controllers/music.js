var musicController = {
	musicSearch: function(req, res) {
		var userId = req.params.userId;
		var artists = req.body["artists[]"];
		console.log("Posted to musicSearch with userId:" + userId, "and artists list: " + artists);
		
		res.send({lol: 'it worked'});
	}
};

module.exports = musicController;