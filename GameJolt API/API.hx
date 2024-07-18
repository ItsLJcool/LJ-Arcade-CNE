//a
/**
	GameJolt API Ndll for CodenameEngine © 2024 by Neo & ItsLJcool is licensed under CC BY-NC-SA 4.0.
	To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
**/

import haxe.Json;
import funkin.backend.utils.NdllUtil;
import Type;

public static var GameJolt = {
	username: null, token: null,
};

function _initCacheSave() {
	if (FlxG.save.data.lj_tokens == null) FlxG.save.data.lj_tokens = 0;

	if (FlxG.save.data.lj_xp == null) FlxG.save.data.lj_xp = 0;
	if (FlxG.save.data.lj_level == null) FlxG.save.data.lj_level = 0;
	if (FlxG.save.data.lj_rank == null) FlxG.save.data.lj_rank = 0;
}

var ndllName = "gamejolt-api";
public function gamejolt_init() {
    NdllUtil.getFunction(ndllName, "set_ndll_name", 1)(ndllName); // because we love Neo (he is being lazy)
	NdllUtil.getFunction(ndllName, "gamejolt_init", 2)(Type,
	"2af137395810fabb4391a26fede73ad39a9ca69084cf103589472e0c0eb77325090638a68431fcd353a67a4e28260da3");

	// trace(fetchUser("ItsLJcool"));
	// login(GameJolt.username, GameJolt.token);
}

function parse(returnValue:String) {
	var json = Json.parse(returnValue).response;
	json.success = (json.success == "true"); // auto convert success to bool becasue we love http
	return json;
}

function parse(returnValue:String) {
	var json = Json.parse(returnValue).response;
	json.success = (json.success == "true"); // auto convert success to bool becasue we love http
	return json;
}

public function login(username:String, token:String) {
	
	var login = parse(NdllUtil.getFunction(ndllName, "gamejolt_login", 2)(username, token));
	if (!login.success) return;

	FlxG.save.data.GameJoltUsername = GameJolt.username = username;
	FlxG.save.data.GameJoltToken = GameJolt.token = token;
	
}

public function set_data(key:String, value:String, ?userData:Bool = false) {
	if (userData == null) userData = false;

    var data = parse(NdllUtil.getFunction(ndllName, "storeData_3", 3)(userData, key, value));
    if (!data.success) {
		trace("Error Trying to set data to GameJolt Servers: " + data.message);
		return;
	}

	return data;
}

public function get_data(key:String, ?userData:Bool = false) {
	if (userData == null) userData = false;

    var data = parse(NdllUtil.getFunction(ndllName, "fetchData_2", 2)(userData, key));
    if (!data.success) {
		trace("Error Trying to get data to GameJolt Servers: " + data.message);
		return;
	}

	return data;
}


public function fetchUser(username:String) {
    var data = parse(NdllUtil.getFunction(ndllName, "fetchUser", 1)(username));
	if (!data.success) return false;
	
	return data;
}