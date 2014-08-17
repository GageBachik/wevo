//initial required libraries
var Promise = require("bluebird");
var request = Promise.promisifyAll(require('request'));
var toTitleCase = function(str) {
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};

function MusicSearch(artists, userId) {
	//ranked artists and tracks
	this.relatedFinished = 0;
	this.artists = artists;
	this.userId = userId;
	this.rankedArtists = {/*Artist: ranking*/};
	this.topTracks = {/*Artist: [top tracks]*/};
	this.initialArtists = [];
	this.intitialTracks = {/*Artist: [track names]*/};
	this.finalTrackList = [/*Track Name*/];
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
	this.googleRelated();
	this.pandoraRelated();
	this.spotifyRelated();
	this.lastfmRelated();
	// this.freebaseRelated();
}

MusicSearch.prototype.googleRelated = function() {
	var self = this;
	var count = 0;
	this.initialArtists.map(function(artist, index){
		var bandname = artist;

		var fetchUrl = require("fetch").fetchUrl;
		var url = "https://www.google.de/search?q=";
		bandname = bandname.replace(" ", "+");

		fetchUrl(url+bandname, {
		headers: {
			'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'
		}
		}, function(error, meta, body){
			var ret = [];
			var alts = body.toString().split('alt\\x3d\\x22');
			alts.forEach(function (alt) { var cur = alt.split("\\x22")[0]; if (cur.indexOf("(")==-1)    ret.push(cur) });
			ret.map(function(artist){
				if (toTitleCase(artist) in self.rankedArtists) {
					self.rankedArtists[toTitleCase(artist)] += 1;
				}else{
					self.rankedArtists[toTitleCase(artist)] = 0;
				}
			});
			count++
			if (count === self.initialArtists.length) {
				console.log("rankedArtists googleDone:", self.rankedArtists);
				self.relatedFinished++;
			}
			if (self.relatedFinished === 4) {
				self.getTopTracks();
			};
		});
	});
}

MusicSearch.prototype.pandoraRelated = function() {
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
			self.relatedFinished++;
			if (self.relatedFinished === 4) {
				self.getTopTracks();
			};
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
			self.relatedFinished++;
			if (self.relatedFinished === 4) {
				self.getTopTracks();
			};
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
		self.relatedFinished++;
		if (self.relatedFinished === 4) {
			self.getTopTracks();
		};
	});
}

// MusicSearch.prototype.freebaseRelated = function() {
// 	var self = this;
// 	var relatedArtisetCalls = [];
// 	this.initialArtists.map(function(artist, index){
// 		relatedArtisetCalls.push(request.getAsync('https://www.googleapis.com/freebase/v1/search?limit=7&query='+artist+'&type=%2Fmusic%2Fmusical_group&key=AIzaSyDcL_3c23SfRPdgIAaRcz-rSDmb62S1yDA'));
// 	});
// 	Promise.all(relatedArtisetCalls).then(function(results){
// 		var related = JSON.parse(results[0][0].body);
// 		console.log("related:", related);
// 		// related.similarartists.artist.map(function(artist){
// 		// 	if (toTitleCase(artist.name) in self.rankedArtists) {
// 		// 		self.rankedArtists[toTitleCase(artist.name)] += 1;
// 		// 	}else{
// 		// 		self.rankedArtists[toTitleCase(artist.name)] = 0;
// 		// 	}
// 		// });
// 		// console.log("rankedArtists freebaseDone:", self.rankedArtists);
// 	});
// }

MusicSearch.prototype.getTopTracks = function() {
	var self = this;
	var count = 0;
	var lastfmCalls = [];
	var spotifyCalls = [];
	var spotifyGetTopCalls = [];
	for (artist in this.rankedArtists){
		lastfmCalls.push(request.getAsync('http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist='+artist+'&api_key=048054556397dbbc3d4263b613e573f7&format=json&limit=5').spread(function(res, body){return body;}));
		spotifyCalls.push(request.getAsync('https://api.spotify.com/v1/search?type=artist&q='+artist).spread(function(res){return res.body;}));
	}

	Promise.all(spotifyCalls).then(function(results){
		results.map(function(result){
			var parsed = JSON.parse(result);
			spotifyGetTopCalls.push(request.getAsync('https://api.spotify.com/v1/artists/'+parsed.artists.items[0].id+'/top-tracks?country=US').spread(function(res){return res.body;}));
		});

		Promise.all(spotifyGetTopCalls).then(function(results){
			results.map(function(result){
				var parsed = JSON.parse(result);
				parsed.tracks.map(function(track, index){
					if (index < 6) {
						if (toTitleCase(track.artists[0].name) in self.topTracks) {
							if (self.topTracks[toTitleCase(track.artists[0].name)].indexOf(toTitleCase(track.name)) === -1) {
								self.topTracks[toTitleCase(track.artists[0].name)].push(toTitleCase(track.name));
							}
						}else{
							self.topTracks[toTitleCase(track.artists[0].name)] = [toTitleCase(track.name)];
						}
					}
				});
			});
			count++;
			if (count === 2) {
				console.log("self.topTracks spotify:", self.topTracks);
				self.makeFinalTrackList();
			}
		});
	})

	Promise.all(lastfmCalls).then(function(body){
		body.map(function(result){
			var parsed = JSON.parse(result);
			parsed.toptracks.track.map(function(track){
				// console.log("track:", track);
				if (toTitleCase(track.artist.name) in self.topTracks) {
					if (self.topTracks[toTitleCase(track.artist.name)].indexOf(toTitleCase(track.name)) === -1) {
						self.topTracks[toTitleCase(track.artist.name)].push(toTitleCase(track.name));
					}
				}else{
					self.topTracks[toTitleCase(track.artist.name)] = [toTitleCase(track.name)];
				}
			});
		});
		count++;
		if (count === 2) {
			console.log("self.topTracks lastfm:", self.topTracks);
			self.makeFinalTrackList();
		}
	});
}

MusicSearch.prototype.makeFinalTrackList = function() {
	var self = this;
	var totalTracks = 0;
	var lowest = Infinity;
	var previousArtist = '';

	var getTotalTracks = function(){
		for (artist in self.topTracks){
			totalTracks += self.topTracks[artist].length;
		}
	};

	var fixRankedArtists = function(){
		for (artist in self.rankedArtists){
			if (self.rankedArtists[artist] < lowest) {
				lowest = self.rankedArtists[artist];
			}
		}
		for (artist in self.rankedArtists){
			if (lowest < 1) {
				self.rankedArtists[artist] += (-lowest +1);
			}
		}

	};

	var setFirstSong = function(){
		if (Object.keys(self.intitialTracks).length > 0) {
			//possibly delete duplicate from top tracks if you have time.
			var randomTrackIndex = Math.floor((Math.random() * Object.keys(self.intitialTracks).length));
			var artist = Object.keys(self.intitialTracks).splice(randomTrackIndex, 1);
			self.finalTrackList.push(artist +' - '+ self.intitialTracks[artist]);
		}else{
			var randomArtistIndex = Math.floor((Math.random() * self.initialArtists.length));
			var artist = self.initialArtists.splice(randomArtistIndex, 1);
			var randomTrackIndex = Math.floor((Math.random() * self.topTracks[artist].length));
			self.finalTrackList.push(artist +' - '+ self.topTracks[artist].splice(randomTrackIndex, 1));
			previousArtist = artist;
			if (self.topTracks[artist].length === 0) {
				delete self.rankedArtists[artist];
			}
			totalTracks--;
		}
	};

	var setTracks = function(){
		for (var i = 0; i < totalTracks; i++) {
			var ratingSum = 0;
			var current = 0;
			var previous = 0;			
			var selection = Math.random() * 100;
			var rangedArtists = {};
			for (artist in self.rankedArtists){
				if (artist !== previousArtist){
					rangedArtists[artist] = self.rankedArtists[artist];
				}
			}
			for (artist in rangedArtists){
				ratingSum += rangedArtists[artist];
			}
			for (artist in rangedArtists){
				rangedArtists[artist] *= (100 / ratingSum);
			}
			for (artist in rangedArtists){
				current += rangedArtists[artist];
				if((previous < selection) && (selection < current)){
					var randomTrackIndex = Math.floor((Math.random() * self.topTracks[artist].length));
					self.finalTrackList.push(artist +' - '+ self.topTracks[artist].splice(randomTrackIndex, 1));
					previousArtist = artist;
					if (self.topTracks[artist].length === 0) {
						delete self.rankedArtists[artist];
					}
				}
				previous += rangedArtists[artist];
			}
		}
	};

	getTotalTracks();
	fixRankedArtists();
	setFirstSong()
	setTracks();
	// console.log("topTracks:", this.topTracks);
	// console.log("finalTrackList:", this.finalTrackList, this.finalTrackList.length);
	this.getYoutubeIds();
}

MusicSearch.prototype.getYoutubeIds = function() {
	console.log('getting youtube ids:');
	var self = this;
	request.getAsync('https://www.googleapis.com/youtube/v3/search?part=id&q=all+time+low&key=AIzaSyDaHcw5b3PPbw60RPsscYnT0qKeRfesn0s').then(function(results){
		console.log("results:", results[0].body);
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