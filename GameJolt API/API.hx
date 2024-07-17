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

var ndllName = "gamejolt-api";

var asyncStack:Array<Array<Dynamic>> = []; // [[name, args, result]]

var async_call = NdllUtil.getFunction(ndllName, "async_ndll_call", 2);
public function gamejolt_init() {
	
    NdllUtil.getFunction(ndllName, "set_ndll_name", 1)(ndllName); // because we love Neo (he is being lazy)
	NdllUtil.getFunction(ndllName, "gamejolt_init", 2)(Type,
	"2af137395810fabb4391a26fede73ad39a9ca69084cf103589472e0c0eb77325090638a68431fcd353a67a4e28260da3");
	
	var registerThread = NdllUtil.getFunction(ndllName, "registerThread", 0);
	registerThread();
	#if ALLOW_MULTITHREADING
		for (i in 0...Main.gameThreads.length) {
			Main.execAsync(registerThread);
		}
	#end

	NdllUtil.getFunction(ndllName, "set_async_stack", 1)(asyncStack);

	login(GameJolt.username, GameJolt.token);
}

public function login(username:String, token:String) {
	GameJolt.username = username;
	GameJolt.token = token;
	
	Main.execAsync(async_call("gamejolt_login", [GameJolt.username, GameJolt.token]));
}

function update(elapsed) {
	while(asyncStack.length > 0) {
	    // or asyncStack.pop() if you dont really care about the order.
	    // Tho we recommend using the shift, or else certain results might take longer to process.
		var arr = asyncStack.shift();
		var func = arr[0];
	    var args = arr[1];
		var result = arr[2];
	    // process the result
		trace(func, args, result);
	}
}