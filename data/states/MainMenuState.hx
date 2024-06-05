//a
import funkin.game.PlayState;
import funkin.backend.assets.ModsFolder;
import StringTools;
import haxe.Json;
importScript('GameJolt API/gamejolt test'); // local path

function create() {
    trace("YIPEE");
}

function update(elapsed) {
    if (FlxG.keys.justPressed.O) {
        // test();
        // GameJolt.unlockTrophy(235015);
        var what = GameJolt.setSave("what", {testy: "fire emojli"});

        trace(what);
        
        what = GameJolt.getSave("what");
        trace(what);
    }
    if (FlxG.keys.justPressed.P) {
        // loadTest("Treeshot-Funkin");
    }
    
    if (FlxG.keys.justPressed.L) {
        ModsFolder.reloadMods();
    }
}

function test() {
    PlayState.loadSong("sighting", "hard", false, false);
    FlxG.switchState(new PlayState());
}

function loadTest(modToLoad:String) {
    for (mod in ModsFolder.getLoadedMods()) {
        var modSplit = mod.split("/");
        var actualMod = modSplit[modSplit.length-1];
        if (actualMod.toLowerCase() == modToLoad.toLowerCase()) return;
    }
    Paths.assetsTree.addLibrary(ModsFolder.loadModLib(ModsFolder.modsPath+modToLoad, modToLoad));
}