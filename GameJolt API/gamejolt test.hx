import sys.Http;
import haxe.crypto.Md5;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.BaseCode;

import funkin.editors.ui.UIState;
import funkin.backend.system.Main;

import funkin.backend.assets.ModsFolder;

public function getGameJoltName() { return Base64.decode(Assets.getText(Paths.getPath("GameJolt API/TOKEN"))).toString(); }

public var Trophies = [
	"Too Cool" => 235015
];

public var GameJolt = {
	http: new Http(''),
	id: 901749,
	privateKey: getGameJoltName(),

	username: 'ItsLJcool',
	token: 'DxQYfX',

	get: function(endpoint:String, params:Array<{name:String, value:String}>) {
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(false);
		
		return Json.parse(GameJolt.http.responseData);
	},

	set: function(endpoint:String, params:Array<{name:String, value:String}>) {
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(true);
		
		return Json.parse(GameJolt.http.responseData);
	},

	setSave: function(key:String, save) { return GameJolt.set("data-store/set", [{name: "key", value: key}, {name: "data", value: save }]); },
	getSave: function(key:String) { return GameJolt.get("data-store", [{name: "key", value: key}]); },

	lastUnlockedTrophy: null,
	unlockTrophy: function(trophyString) {
		var id:Int = -1;
		if (Trophies.exist(trophyString)) id = Trophies.get(trophyString);
		Main.execAsync(function() {
			var trophy = GameJolt.get('trophies', [{name: 'username', value: GameJolt.username}, {name: 'user_token', value: GameJolt.token}, {name: 'trophy_id', value: id}]).response.trophies[0];
            // trace(trophy);
			if (!trophy.achieved) {
				GameJolt.set('trophies/add-achieved', [{name: 'username', value: GameJolt.username}, {name: 'user_token', value: GameJolt.token}, {name: 'trophy_id', value: id}]);
				GameJolt.lastUnlockedTrophy = trophy;
				// Play Trophy SFX (placeholder rn)
				FlxG.sound.play(Paths.sound("Notification"), 1);
			}
		});
	}
};

function new() {
	/**
		auto compile keys items to values of itself
		example: a map of ["among us" => 15] will turn into ["among us" => 15, 15 => 15]
	*/
	for (things in Trophies.keys()) { Trophies.set(Trophies.get(things)); }
}