//a
import Type;

import StringTools;
// REDO THE GAMEJOLT API CODE TO WORK WITH NEW API
importScript("GameJolt API/old gamejolt");
/**
    This just runs when the LJ Arcade Mod Launches, to ensure it's initalized, and to do some updates for saving ig
**/
public var xpMaxLevels = [
    0 => 100,
    1 => 300,
    2 => 450,
    3 => 650,
    4 => 900,
    5 => 1500,
    6 => 1750,
    7 => Math.POSITIVE_INFINITY, // max becomesx Pos inf
];

public var rating_XP = [
    "S++" => 150,
    "S" => 100,
    "A" => 75,
    "B" => 50,
    "C" => 20,
    "D" => 15,
    "E" => 5,
    "F" => 1,
];

public function get_rankText(forceRank:Dynamic = null) {
    var _maxRank:Int = -1;
    for (key in xpMaxLevels.keys()) _maxRank++;

    var rank = (forceRank == null) ? get_rank() : Std.string(forceRank);
    var _rankText:String = "Rank: "+rank;
    if (Std.parseInt(rank) == _maxRank) _rankText += " (Max Rank)";
    return _rankText;
}

public function update_xp(xpGained:Int) {
    if (xpGained < 0) xpGained = 0;
    var _maxRank:Int = -1;
    
    var rank = get_rank();
    var xp = get_xp();

    var __rankAdd:Int = 0;
    var __newXP:Int = (xp + xpGained);
    

    for (key in xpMaxLevels.keys()) {
        _maxRank++;
        if (key < rank) continue;
        if ((xp + xpGained) >= xpMaxLevels[key]) __rankAdd++;
    }
    rank += __rankAdd;
    __newXP -= xpMaxLevels[(rank-1)];

    if (__rankAdd > 0) {
        set_rank(rank);
        set_xp(__newXP);
    }

    return {newXP: __newXP, rankAdd: __rankAdd, rankedUp: (__rankAdd > 0)};
}

// returns true if desynced, false if not, so no need to take action.
public function check_desync() {
    _initCacheSave();
    var tokens = get_tokens(false);
    var xp = get_xp(false);
    var rank = get_rank(false);

    if (FlxG.save.data.lj_tokens != tokens) return true;
    if (FlxG.save.data.lj_xp != xp) return true;
    if (FlxG.save.data.lj_rank != rank) return true;

    return false;
}

public function token_rating(rating:String) {
    if (rating == null) return -1;

    switch(rating.toLowerCase()) {
        case "s++": return 15;
        case "s": return 10;
        case "a": return 8;
        case "b": return 5;
        case "c": return 2;
        case "d": return 1;
        case "e": return 0;
        default: return -1;
    }
}

public function token_songLength(lengthSeconds:Int) {
    if (lengthSeconds < 50) return 0;
    var lengthMinutes:Float = lengthSeconds / 60.0;
    
    // Define constants for growth
    var k:Float = 5.0; // Adjust this constant for desired scaling
    var n:Float = 0.5; // Adjust this constant for desired growth rate

    // Exponential decay for t < 2 minutes
    if (lengthMinutes < 2.0)
        return Math.floor(10.0 * Math.exp(-(2.0 - lengthMinutes)));
    else
        // Exponential growth for t >= 2 minutes
        return Math.floor(10.0 + k * Math.pow(lengthMinutes - 2.0, n));
}

public function _resetData() {
    trace("resetting data");
    
    FlxG.save.data.lj_tokens = 0;
    GameJolt.setUser_Save("tokens", 0);
    
    FlxG.save.data.lj_xp = 0;
    GameJolt.setUser_Save("xp", 0);
    
    FlxG.save.data.lj_rank = 0;
    GameJolt.setUser_Save("rank", 0);

    trace("data reset");
}

// --- Tokens ---
public static var _gj_tokens:Int = 0;
public function get_tokens(?cache:Bool = true) { if (cache == null) cache = true;
    if (cache || !usingGameJolt) return FlxG.save.data.lj_tokens;
    
    var data = GameJolt.getUser_Save("tokens");
    if (!data.success) return get_tokens(true);
    _gj_tokens = Std.int(data.data);
    return _gj_tokens;
}
public function set_tokens(value:Int, ?forceCache:Bool = false) { if (forceCache == null) forceCache = false;
    if (value < 0) value = 0; // force to be positive for now, no reason to be negative.
    value = Std.int(value);
    if (forceCache || !usingGameJolt) {
        FlxG.save.data.lj_tokens = Std.int(value); // force int in case.. ig?
        return FlxG.save.data.lj_tokens;
    }

    // Not recursive, because we force the cache to be updated, so it returns without actually recursing.
    set_tokens(value, true); // update internal save before sending to gamejolt in case it like dies lmao

    var data = GameJolt.setUser_Save("tokens", value);
    return get_tokens();
}

// --- XP ---
public static var _gj_xp:Int = 0;
public function get_xp(?cache:Bool = true) { if (cache == null) cache = true;
    if (cache || !usingGameJolt) return FlxG.save.data.lj_xp;
    
    var data = GameJolt.getUser_Save("xp");
    if (!data.success) return get_xp(true);
    _gj_xp = Std.int(data.data);
    return _gj_xp;
}
public function set_xp(value:Int, ?forceCache:Bool = false) { if (forceCache == null) forceCache = false;
    if (value < 0) value = 0;
    value = Std.int(value);
    if (forceCache || !usingGameJolt) {
        FlxG.save.data.lj_xp = Std.int(value); // in case.. ig?
        return FlxG.save.data.lj_xp;
    }

    // Not recursive, because we force the cache to be updated, so it returns without actually recursing.
    set_xp(value, true); // update internal save before sending to gamejolt in case it like dies lmao

    var data = GameJolt.setUser_Save("xp", value);

    return get_xp();
}

// --- Level / Rank ---
public static var _gj_rank:Int = 0;
public function get_rank(?cache:Bool = true) { if (cache == null) cache = true;
    if (cache || !usingGameJolt) return FlxG.save.data.lj_rank;
    
    var data = GameJolt.getUser_Save("rank"); 
    if (!data.success) return get_rank(true);
    _gj_rank = Std.int(data.data);
    return _gj_rank;
}
public function set_rank(value:Int, ?forceCache:Bool = false) { if (forceCache == null) forceCache = false;
    if (value < 0) value = 0;
    value = Std.int(value);
    if (forceCache || !usingGameJolt) {
        FlxG.save.data.lj_rank = Std.int(value); // in case.. ig?
        return FlxG.save.data.lj_rank;
    }

    // Not recursive, because we force the cache to be updated, so it returns without actually recursing.
    set_rank(value, true); // update internal save before sending to gamejolt in case it like dies lmao

    var data = GameJolt.setUser_Save("rank", value);
    return get_rank();
}