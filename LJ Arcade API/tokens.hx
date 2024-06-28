//a
import Type;

import StringTools;
importScript("Temp GameJolt API/gamejolt test");
/**
    This just runs when the LJ Arcade Mod Launches, to ensure it's initalized, and to do some updates for saving ig
**/
public var xpMaxLevels = [
    0 => 100,
    1 => 250,
    2 => 400,
    3 => 650,
];

/**
    Structure for Level Saving
**/
var versionResets = [];  // input version number and if someone has a lesser version and updates, reset the data


var noKeyFound = "No item with that key could be found.";
var _maxFailSafe:Int = 5;

public function initTokens() {
    trace(get_xp());
    trace(get_level());
}

var _xpFailSafe:Int = 0;
/**
    Anything Lower than 0 will result in the code saying it failed to get the XP level.
**/
public function get_xp() {
    var gjData = GameJolt.getUserSave("xp").response;
    
    if (gjData.success == "false") {
        if (gjData.message.toLowerCase() == noKeyFound.toLowerCase()) {
            GameJolt.setUserSave("xp", 0);
            _xpFailSafe++;
            return (_xpFailSafe > _maxFailSafe) ? -1 : get_xp();
        } else {
            _xpFailSafe = 0;
            return -1;
        }
    }
    _xpFailSafe = 0;
    return gjData.data;
}

var _levelFailSafe:Int = 0;
public function get_level() {
    var gjData = GameJolt.getUserSave("level").response;
    
    if (gjData.success == "false") {
        if (gjData.message.toLowerCase() == noKeyFound.toLowerCase()) {
            GameJolt.setUserSave("level", 1);
            _levelFailSafe++;
            return (_levelFailSafe > _maxFailSafe) ? -1 : get_level();
        } else {
            _levelFailSafe = 0;
            return -1;
        }
    }
    _levelFailSafe = 0;
    return gjData.data;
}