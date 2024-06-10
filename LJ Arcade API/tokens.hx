//a
import Type;
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
public var levels = {
    _data: {
        version: 1,
    },
    xp: 0,
    level: 0,
    tokens: 0,
};

public function GameJoltToSave(gamejoltSave) {
    if (gamejoltSave.response.success == "false" || gamejoltSave.response.success == false) return gamejoltSave; // fuckin hell
    
    gamejoltSave.response.data = Json.parse(gamejoltSave.response.data);
    
    return gamejoltSave.response;
}

public function initTokens() {
    // var test = GameJolt.set("data-store/remove", [{name: "key", value: "levelSave"},
    // {name: "username", value: GameJolt.username}, {name: "user_token", value: GameJolt.token }]);
    // trace(test);
    
    var currentSave = GameJoltToSave(GameJolt.getUserSave("levelSave"));
    trace(currentSave);

    if (currentSave.success == "true") {
        if (currentSave.data._data.version != levels._data.version) {
            var reset = false;
            
            for (ver in versionResets) {
                
                if (ver > currentSave.data._data.version) continue;
                reset = true;
                break;
            }
            if (!reset) return;
        } else {
            return;
        }
    }
    GameJolt.setUserSave("levelSave", Json.stringify(levels));
}

public function updateSave(key:String, value:Dynamic) {
    var currentSave = GameJoltToSave(GameJolt.getUserSave("levelSave"));
    Reflect.setField(currentSave.data, key, value);
    GameJolt.setUserSave("levelSave", Json.stringify(currentSave.data));
}