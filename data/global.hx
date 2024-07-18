//a

import funkin.game.GameOverSubstate;
import funkin.menus.PauseSubState;
import funkin.options.Options;
import lime.graphics.Image;
import flixel.FlxState;
import openfl.Lib;
import sys.FileSystem;
import haxe.io.Path;
import funkin.backend.assets.ModsFolder;
import Type;
import funkin.backend.chart.EventsData;
import flixel.FlxG;
import lime.utils.AssetLibrary;

import funkin.backend.scripting.GlobalScript;

import funkin.backend.scripting.Script;
import funkin.backend.scripting.ScriptPack;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.HScript;

import funkin.backend.system.Logs;
import funkin.backend.system.Level;

import flixel.system.scaleModes.RatioScaleMode;
import openfl.system.Capabilities;
import funkin.backend.utils.WindowUtils;

import funkin.backend.system.FunkinRatioScaleMode;
import StringTools;

import funkin.editors.ui.UIState;

importScript("LJ Arcade API/ljarcade.challenges");
// importScript("GameJolt API/API");
importScript("GameJolt API/old gamejolt");

static var queuedSubStates = [];

static var _loadedModAssetLibrary:Map<String, AssetLibrary> = [];

static var usingGameJolt = false;


static var initialized:Bool = false;
static var customPrefix = "ljarcade";

function new() {
    _initCacheSave();
    // gamejolt_init();
}

static var redirectStates:Map<FlxState, String> = [
    // MainMenuState => 'ljarcade.MainMenuState',
	// OptionsMenu => 'path',
	// FreeplayState => 'you already know it dumbass'
];

function postStateSwitch() {
    _fromFreeplay = false;
}

function gameResized(w, h) {    
    if ((FlxG.scaleMode is FunkinRatioScaleMode)) return;
    FlxG.scaleMode = new FunkinRatioScaleMode();
}

static var modGlobalScript = null;
static var _fromFreeplay:Bool = false;
static var __customArgs:Array<Dynamic> = [];

static var lastSelectedFreeplaySong:Int = null;

var goingToUIstate:Bool = false;
function preStateSwitch() {
    
    FlxG.camera.bgColor = 0xFF000000;
    trace(FlxG.game._requestedState is UIState);
    
    if (FlxG.game._requestedState is PlayState) {
        EventsData.reloadEvents();

        // reset globalscript and then we can saftely import a .. undefiend global script?? so what evor
        GlobalScript.onModSwitch(ModsFolder.currentModFolder);
        modGlobalScript = GlobalScript.scripts.importScript("data/global.hx");
        modGlobalScript.set("preStateSwitch", function() {}); // hehe
        modGlobalScript.set("postStateSwitch", function() {}); // hehe
    } else {
        window.frameRate = Options.framerate;
        if (modGlobalScript != null) {
            modGlobalScript.call("ljarcade_scriptRemoved");
            GlobalScript.onModSwitch(ModsFolder.currentModFolder);
            
            modGlobalScript = null;
        }
    }

    if (FlxG.game._requestedState is FreeplayState) {
        _fromFreeplay = true;
        FlxG.game._requestedState = new ModState("ModMainMenu");
    }
    
    var allStates = FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/data/states");
    var possibleState:Bool = true;
    if ((Type.getClass(FlxG.game._requestedState) == ModState) || (Type.getClass(FlxG.game._requestedState) == UIState)) {
        for (state in allStates) {
            state = Path.withoutExtension(state);
            var checking = FlxG.game._requestedState.lastName;
            var checkNull = (checking == null);
            if (checkNull) checking = FlxG.state.scriptName;
            trace(state + " | " + checking);
            if ((state == checking) || (state == (customPrefix+"."+checking))
            || (state == (customPrefix+".ui."+checking))) {
                possibleState = true;
                goingToUIstate = (checkNull) ? (state == checking) : (state == (customPrefix+".ui."+checking));
                trace("goingToUIstate: " + goingToUIstate);
                if (goingToUIstate && checkNull) {
                    FlxG.game._requestedState = new UIState(true, checking);
                    // basically we can tell if we are just reloading the state by this, but it could
                    // check if we are switching from UI to UI state but not sure yet.
                    // please lmk if that does this
                    return;
                }
                break;
            }
            possibleState = false;
        }
    }
    if (!possibleState) {
        trace("uh oh! Not an LJ Arcade state, get fucked!");
        FlxG.game._requestedState = new MainMenuState();
    }

    trace("GameJolt.username: " + GameJolt.username);
    trace("GameJolt.token: " + GameJolt.token);
	if (!initialized) {
		initialized = true;
        if (FlxG.save.data.GameJoltUsername != null && FlxG.save.data.GameJoltToken != null) {
            GameJolt.username = FlxG.save.data.GameJoltUsername;
            GameJolt.token = FlxG.save.data.GameJoltToken;
            usingGameJolt = true;
        }
		//FlxG.game._requestedState = new ModState('WarningState');
	} else {
        for (state in allStates) {
            var fileName = Path.withoutExtension(state);
            var split = fileName.split(".");

            if (split[0] != customPrefix) continue;
            var requestedState = Type.getClassName(Type.getClass(FlxG.game._requestedState)).split(".");

            if (requestedState[requestedState.length-1] == split[split.length-1]
            || (Type.getClass(FlxG.game._requestedState) == ModState) && (FlxG.game._requestedState.lastName == split[split.length-1])) {
				FlxG.game._requestedState = (goingToUIstate) ? new UIState(true, fileName) : new ModState(fileName);
                
                trace(FlxG.game._requestedState is UIState);
                return;
            }
        }

        // Map, prob going unused but will keep it here for the people yoinking my code ig... theifs !!
		for (redirectState in redirectStates.keys())
			if (FlxG.game._requestedState is redirectState) 
				FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
	}
}

static function openQueuedSubState(state:FlxSubState, ?priority:Bool = false) {
    if (!priority) queuedSubStates.push(state);
    else queuedSubStates.insert(state, 0);

    if (FlxG.state.subState == null && queuedSubStates[0] != null) {
        var newSubState = queuedSubStates.shift();
        FlxG.state.openSubState(newSubState);
    }
}

static function close() {
    trace(FlxG.game._requestedState);
    if (FlxG.state.subState == null) return;
    
    if (queuedSubStates[0] != null) {
        var newSubState = queuedSubStates.shift();
        FlxG.state.openSubState(newSubState);
    }
}

function destroy() { FlxG.camera.bgColor = 0xFF000000; }

/**
    Loads a song and sends player to PlayState
**/
static function loadAndPlaySong(songName:String, diff:String = "hard", opponentMode:Bool = false, coopMode:Bool = false) {
    if (diff == null) diff = "hard";
    if (opponentMode == null) opponentMode = false;
    if (coopMode == null) coopMode = false;
    PlayState.loadSong(songName, diff, opponentMode, coopMode);
    FlxG.switchState(new PlayState());
}
/**
    @param modToLoad - [String] - The folder name of the mod to load in your mods folder
    returns true on success, false if not added (because it already is) or on error
**/
static function loadModToLibrary(modToLoad:String) {
    for (mod in ModsFolder.getLoadedMods()) {
        var modSplit = mod.split("/");
        var actualMod = modSplit[modSplit.length-1];
        if (actualMod.toLowerCase() == modToLoad.toLowerCase()) return false;
    }
    var modLoaded = Paths.assetsTree.addLibrary(ModsFolder.loadModLib(ModsFolder.modsPath+modToLoad, modToLoad));
    _loadedModAssetLibrary.set(modToLoad, modLoaded);
    return true;
}

/**
    @param modToRemove - [String] - The folder name of the mod to remove from the `Paths.assetTree`
    returns true on success, false if not added (because it isn't added yet) or on error
**/
static function removeModFromLibrary(modToRemove) {
    if (!_loadedModAssetLibrary.exists(modToRemove)) return false;
    Paths.assetsTree.removeLibrary(_loadedModAssetLibrary.get(modToRemove));
    _loadedModAssetLibrary.remove(modToRemove);
    return true;
}