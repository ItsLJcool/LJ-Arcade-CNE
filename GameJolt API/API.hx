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
    
    NdllUtil.getFunction(ndllName, "gamejolt_login", 2)(GameJolt.username, GameJolt.token);
    
    var result = NdllUtil.getFunction(ndllName, "openSession_0", 0)();
    trace(result);
    
    var result = NdllUtil.getFunction(ndllName, "closeSession_0", 0)();
    trace(result);
}