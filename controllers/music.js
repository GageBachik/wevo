//initial required libraries
var Promise = require("bluebird");
var request = Promise.promisifyAll(require('request'));
var toTitleCase = function(str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};

function MusicSearch(artists, userId) {
	//ranked artists and tracks
	this.artists = artists;
	this.userId = userId;
	this.rankedArtists = {/*Artist: ranking*/};
	this.initialArtists = [];
	this.intitialTracks = {/*Artist: [track names]*/};
}

MusicSearch.prototype.parseItems = function() {
	var self = this;
	var itemsArray = this.artists;
	if (!(itemsArray instanceof Array)) {
		var itemsArray = [itemsArray];
	}

	itemsArray.map(function(item, i, arr){
		arr[i] = arr[i].split('and').join('&');
		// arr[i] = arr[i].split('.').join('');
		// console.log('replaced: ', arr[i]);
	});

	itemsArray.map(function(item, index){
		var separated = item.split(' - ');
		var artist = separated.shift();
		var trackOrType = separated.pop();
		artist = toTitleCase(artist);
		if(artist in self.rankedArtists){
			self.rankedArtists[artist] += 1;
		}else{
			self.initialArtists.push(artist);
			self.rankedArtists[artist] = 1;
		}
		if (trackOrType.search('Artist') === -1) {
			self.intitialTracks[artist] = trackOrType;
		}
		//console.log("count:", count);
	});
	console.log(this.rankedArtists, this.intitialTracks);
}

MusicSearch.prototype.findRelatedArtists = function(){
	this.pandorasRelated();
	this.spotifyRelated();
	this.lastfmRelated();
	this.freebaseRelated();
}

MusicSearch.prototype.pandorasRelated = function() {
	var self = this;
	var relatedArtisetCalls = [];
	this.initialArtists.map(function(artist, index){
		var defaultUrl = 'http://www.pandora.com/json/music/artist/';
		var nameFixed = artist.split('&').join('and');
		nameFixed = nameFixed.split(' ').join('-');
		var fixedUrl = defaultUrl + nameFixed + '?explicit=false';
		// console.log("fixedUrl:", fixedUrl);
		relatedArtisetCalls.push(request.getAsync(fixedUrl));
	});
	Promise.all(relatedArtisetCalls).spread(function() {
		[].map.call(arguments, function(res){
			// console.log("res:", res);
			var results = JSON.parse(res[0].body);
			var similar = results.artistExplorer.similar;
			similar.map(function(artist){
				if (toTitleCase(artist['@name']) in self.rankedArtists) {
					self.rankedArtists[toTitleCase(artist['@name'])] += 1;
				}else{
					self.rankedArtists[toTitleCase(artist['@name'])] = 0;
				}
			});
			console.log("rankedArtists pandoraDone:", self.rankedArtists);
		});
	}).catch(function(err) {
		console.error(err);
	});
}

MusicSearch.prototype.spotifyRelated = function() {
	var self = this;
	var artistIdCalls = [];
	this.initialArtists.map(function(artist, index){
		var nameFixed = artist.split('&').join('and');
		nameFixed = nameFixed.split(' ').join('-');
		var spotUrl = 'https://api.spotify.com/v1/search';
		var appendString = '?type=artist&q=' + nameFixed;
		var fixedUrl = spotUrl + appendString;
		artistIdCalls.push(request.getAsync(fixedUrl));
	});
	Promise.all(artistIdCalls).then(function(results){
		var relatedArtisetCalls = [];
		results.map(function(result){
			var artistObj = JSON.parse(result[0].body);
			relatedArtisetCalls.push(request.getAsync('https://api.spotify.com/v1/artists/' + artistObj.artists.items[0].id + '/related-artists'));
		});
		Promise.all(relatedArtisetCalls).then(function(results){
			results.map(function(result){
				var relatedArtists = JSON.parse(result[0].body);
				// console.log("relatedArtists:", relatedArtists);
				relatedArtists.artists.map(function(artist){
					// console.log(artist.name);
					//why dont these have quotes
					if (toTitleCase(artist.name) in self.rankedArtists) {
						self.rankedArtists[toTitleCase(artist.name)] += 1;
					}else{
						self.rankedArtists[toTitleCase(artist.name)] = 0;
					}
				});
			});
			console.log("rankedArtists spotifyDone:", self.rankedArtists);
		});
	});
}

MusicSearch.prototype.lastfmRelated = function() {
	var self = this;
	var relatedArtisetCalls = [];
	this.initialArtists.map(function(artist, index){
		relatedArtisetCalls.push(request.getAsync('http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist='+artist+'&api_key=048054556397dbbc3d4263b613e573f7&limit=20&format=json'));
	});
	Promise.all(relatedArtisetCalls).then(function(results){
		var related = JSON.parse(results[0][0].body);
		related.similarartists.artist.map(function(artist){
			if (toTitleCase(artist.name) in self.rankedArtists) {
				self.rankedArtists[toTitleCase(artist.name)] += 1;
			}else{
				self.rankedArtists[toTitleCase(artist.name)] = 0;
			}
		});
		console.log("rankedArtists lastfmDone:", self.rankedArtists);
	});
}

MusicSearch.prototype.freebaseRelated = function() {
	var self = this;
	var relatedArtisetCalls = [];
	this.initialArtists.map(function(artist, index){
		relatedArtisetCalls.push(request.getAsync('https://www.googleapis.com/freebase/v1/search?limit=7&query='+artist+'&type=%2Fmusic%2Fmusical_group&key=AIzaSyDcL_3c23SfRPdgIAaRcz-rSDmb62S1yDA'));
	});
	Promise.all(relatedArtisetCalls).then(function(results){
		var related = JSON.parse(results[0][0].body);
		console.log("related:", related);
		// related.similarartists.artist.map(function(artist){
		// 	if (toTitleCase(artist.name) in self.rankedArtists) {
		// 		self.rankedArtists[toTitleCase(artist.name)] += 1;
		// 	}else{
		// 		self.rankedArtists[toTitleCase(artist.name)] = 0;
		// 	}
		// });
		// console.log("rankedArtists freebaseDone:", self.rankedArtists);
	});
}

var musicController = {
	search: function(req, res) {
		var userId = req.params.userId;
		var artists = req.body["artists[]"];
		console.log("req.body:", req.body);
		console.log("Posted to musicSearch with userId:" + userId, "and artists list: " + artists);
		var currentSearch = new MusicSearch(artists, userId);
		currentSearch.parseItems();
		currentSearch.findRelatedArtists();
		res.send({lol: 'it worked'});
	}
};

module.exports = musicController;