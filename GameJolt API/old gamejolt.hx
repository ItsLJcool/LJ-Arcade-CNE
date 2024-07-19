/**
	OUTDATED!! LOOK IN THE GAMEJOLT API FOLDER
**/

import sys.Http;
import haxe.crypto.Md5;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.BaseCode;

import funkin.editors.ui.UIState;
import funkin.backend.system.Main;

import funkin.backend.assets.ModsFolder;

public function _initCacheSave() {
	if (FlxG.save.data.lj_tokens == null) FlxG.save.data.lj_tokens = 0;

	if (FlxG.save.data.lj_xp == null) FlxG.save.data.lj_xp = 0;
	if (FlxG.save.data.lj_level == null) FlxG.save.data.lj_level = 0;
	if (FlxG.save.data.lj_rank == null) FlxG.save.data.lj_rank = 0;
}

public function getGameJoltName() { return Base64.decode(Assets.getText(Paths.getPath("GameJolt API/TOKEN"))).toString(); }

public static var GameJolt = {
	http: new Http(''),
	id: 901749,
	privateKey: getGameJoltName(),

	username: '',
	token: '', // dont try shit lmao, this is being refreshed when i make source public. Losor!!

	auth: function(username:String, token:String) {
		var params = [{name: "username", value: username}, {name: "user_token", value: token}];
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + "users/auth" + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(false);
		
		var returnMessage = Json.parse(GameJolt.http.responseData);
		if (returnMessage.response.success == "true") {
			FlxG.save.data.GameJoltUsername = username;
			FlxG.save.data.GameJoltToken = token;
		}
		return returnMessage;
	},

	set: function(endpoint:String, params:Array<{name:String, value:String}>) {
		if (!usingGameJolt) return { message: "Not logged into gamejolt", success: false };

		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(true);

		var _data = Json.parse(GameJolt.http.responseData);
		_data.response.success = (_data.response.success == "true");

		return _data.response;
	},

	/**
		@param endpoint [String] - The API Endpoint you are trying to fetch, example: `users`
		@param params `{name:String, value:String}` - Data you are sending for the API to recieve. Example: `{name: "username", value: "ItsLJcool"}`
	**/
	get: function(endpoint:String, params:Array<{name:String, value:String}>) {
		if (!usingGameJolt) return { message: "Not logged into gamejolt", success: false };
		
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(false);

		var _data = Json.parse(GameJolt.http.responseData);
		_data.response.success = (_data.response.success == "true");
		
		return _data.response;
	},

	setUser: function(endpoint:String, params:Array<{name:String, value:String}>) {
		params.push({name: "username", value: GameJolt.username });
		params.push({name: "user_token", value: GameJolt.token });
		return GameJolt.set(endpoint, params);
	},

	getUser: function(endpoint:String, params:Array<{name:String, value:String}>) {
		params.push({name: "username", value: GameJolt.username });
		params.push({name: "user_token", value: GameJolt.token });
		return GameJolt.get(endpoint, params);
	},

	set_Save: function(key:String, save) { return GameJolt.set("data-store/set", [{name: "key", value: key}, {name: "data", value: save }]); },
	setUser_Save: function(key:String, save) {
		return GameJolt.setUser("data-store/set", [
			{name: "key", value: key}, {name: "data", value: save },
		]);
	},
	get_Save: function(key:String) { return GameJolt.get("data-store", [{name: "key", value: key}]); },
	getUser_Save: function(key:String) {
		return GameJolt.getUser("data-store", [
			{name: "key", value: key},
		]);
	},

	lastUnlockedTrophy: null,
	unlockTrophy: function(trophyId) {
		if (!usingGameJolt) return { message: "Not logged into gamejolt", success: false };

		var id:Int = trophyId;
		var trophy = GameJolt.getUser('trophies', [{name: 'trophy_id', value: id}]).trophies[0];
		trace(trophy);
		if (!trophy.achieved) {
			GameJolt.setUser('trophies/add-achieved', [{name: 'trophy_id', value: id}]);
			GameJolt.lastUnlockedTrophy = trophy;
			// Play Trophy SFX (placeholder rn)
			FlxG.sound.play(Paths.sound("Notification"), 1);
		}
		// Main.execAsync(function() {
		// });
	}
};