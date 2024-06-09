//a
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
public var levels = {
    _data: {
        version: 1,
        remap: ["xp" => "xp"] // temp test ig
    },
    xp: 50,
    level: 0,
};
public function initTokens() {
    
}

// function levelUp() {

// }