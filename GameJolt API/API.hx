//a
/**
	GameJolt API Ndll for CodenameEngine © 2024 by Neo & ItsLJcool is licensed under CC BY-NC-SA 4.0.
	To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
**/

import funkin.backend.utils.NdllUtil;
import Type;

public static var GameJolt = {
	username: null, token: null,
};

var ndllName = "GameJolt NDLL/gamejolt-api";
public function gamejolt_init() {
	NdllUtil.getFunction(ndllName, "gamejolt_init", 2)(Type,
	"2af137395810fabb4391a26fede73ad39a9ca69084cf103589472e0c0eb77325090638a68431fcd353a67a4e28260da3");
	
	var registerThread = NdllUtil.getFunction("gamejolt-api", "registerThread", 0);
	registerThread();
	#if ALLOW_MULTITHREADING
		for (i in 0...Main.gameThreads.length) {
			Main.execAsync(registerThread);
		}
	#end

	login(GameJolt.username, GameJolt.token);
}

public function login(username:String, token:String) {
	GameJolt.username = username;
	GameJolt.token = token;
	var loginResponce = NdllUtil.getFunction(ndllName, "gamejolt_login", 2)(GameJolt.username, GameJolt.token);
	trace(loginResponce);
}