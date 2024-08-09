import Reflect;
import Date;
importScript("GameJolt API/old gamejolt");

//a

public static var max_challenges:Int = 3;

var default_challenge_data = {
    __init: false,
    name: "placeholder",
    diff: 1,
    time_hours: 24,
    type: "global",
};

var default_challenge_save = {
    time: -1,
    challenge_data: Reflect.copy(default_challenge_data),
};

public function _initChallengeSave(_modName:String, ?useCache:Bool = false) { if (useCache == null) useCache = false;
    for (i in 0...max_challenges) {
        var challenge = challengeString((i+1), _modName);
        var pog = Reflect.getProperty(FlxG.save.data, challenge, _modName);
        if (pog != null) continue;
        var gj_challenge = get_challenge((i+1), _modName, useCache);
        if (gj_challenge == null) 
            Reflect.setProperty(FlxG.save.data, challenge, Reflect.copy(default_challenge_save));
        else {
            Reflect.setProperty(FlxG.save.data, challenge, gj_challenge);
        }
        pog = Reflect.getProperty(FlxG.save.data, challenge, _modName);
    }
    FlxG.save.flush();
}
 
public function __resetChallengeSave(_modName:String) {
    for (i in 0...max_challenges) remove_challenge((i+1), _modName);
    _initChallengeSave(_modName);
}

public function get_all_challenges(modName:String, ?forceCache:Bool = true) { if (forceCache == null) forceCache = true;
    var challenges = [];
    
    for (i in 0...max_challenges)
        challenges.push(get_challenge((i+1), modName, forceCache));

    return challenges;
}

function challengeString(id:Int, _modName:String) return _modName+"_challenge"+id;
function _gj_challengeString(id:Int, append:String, _modName:String) return _modName+"_challenge"+id+"_"+append;

public function remove_challenge(id:Int, _modName:String) {
    if (id > max_challenges || id <= 0) return null;
    var challenge = challengeString(id, _modName);
    Reflect.setProperty(FlxG.save.data, challenge, null);
    GameJolt.removeUser_Save(_gj_challengeString(id, _modName, "data.name"));
    GameJolt.removeUser_Save(_gj_challengeString(id, _modName, "data.diff"));
    GameJolt.removeUser_Save(_gj_challengeString(id, _modName, "time"));
}

public function get_challenge(id:Int, _modName:String, ?cache:Bool = true) { if (cache == null) cache = true;
    if (id > max_challenges || id <= 0) return null;
    if (cache || !usingGameJolt) return Reflect.getProperty(FlxG.save.data, challengeString(id, _modName));
    
    var data = {
        name: GameJolt.getUser_Save(_gj_challengeString(id, _modName, "data.name")).data,
        diff: GameJolt.getUser_Save(_gj_challengeString(id, _modName, "data.diff")).data,
    };
    
    var time = GameJolt.getUser_Save(_gj_challengeString(id, _modName, "time"));
    if (time.success) return {time: time.data, challenge_data: data};
    else return get_challenge(id, _modName, true);
}

public function set_challenge(id:Int, _modName:String, time, data, ?forceCache:Bool = false) { if (forceCache == null) forceCache = false;
    if (id > max_challenges || id <= 0) return null;
    if (forceCache || !usingGameJolt) {
        var _chal = challengeString(id, _modName);
        var challengeSave = Reflect.getProperty(FlxG.save.data, _chal);
        challengeSave.time = time;
        challengeSave.challenge_data = data;
        challengeSave.__init = true;
        var save = Reflect.setProperty(FlxG.save.data, _chal, challengeSave);
        FlxG.save.flush();
        return save;
    }

    // Not recursive, because we force the cache to be updated, so it returns without actually recursing.
    set_challenge(id, _modName, time, data, true); // update internal save before sending to gamejolt in case it like dies lmao

    GameJolt.setUser_Save(_gj_challengeString(id, _modName, "time"), time);

    GameJolt.setUser_Save(_gj_challengeString(id, _modName, "data.name"), data.name);
    GameJolt.setUser_Save(_gj_challengeString(id, _modName, "data.diff"), data.diff);
    return get_challenge(id, _modName);
}

public function get_future_date(time:Int, hoursAdd:Int = 24) {
    return time + (60 * 60 * hoursAdd * 1000);
}