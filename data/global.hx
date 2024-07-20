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
import funkin.backend.system.Main;
import funkin.backend.system.MainState;
import funkin.menus.TitleState;
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

public static var _forceMainMenu:Bool = false;

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

static var lastSelectedFreeplaySong:Int = 0;

static var lastSelectedMainMenu:Int = 0;

var goingToUIstate:Bool = false;

public static var switchTo_Ratings:Bool = false;
public static var inRatings:Bool = false;

public static var _extraXP:Int = 0;

public static var _lastRating:String = null;
public static var _songLength:Int = -1;

public static var usingBotplay:Bool = false;
function preStateSwitch() {

    if (inRatings) {
        inRatings = false;
        _lastRating = null;
        _extraXP = 0;
        _songLength = -1;
        FlxG.game._requestedState = new ModState("ljarcade.ModMainMenu");
        return;
    }
    
    FlxG.camera.bgColor = 0xFF000000;
    
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

        if (switchTo_Ratings) {
            switchTo_Ratings = false;
            inRatings = true;
            FlxG.game._requestedState = new ModState("Ratings/FreeplayRatings");
        }
    }

    if (FlxG.game._requestedState is FreeplayState) {
        _fromFreeplay = true;
        if (inRatings) inRatings = false;
        FlxG.game._requestedState = new ModState("ModMainMenu");
    }
    
    if ((FlxG.game._requestedState is TitleState) && _forceMainMenu) {
        _forceMainMenu = false;
        FlxG.game._requestedState = new MainMenuState();
    }
    
    var allStates = FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/data/states");
    var possibleState:Bool = true;
    if ((Type.getClass(FlxG.game._requestedState) == ModState) || (Type.getClass(FlxG.game._requestedState) == UIState)) {
        var checking = FlxG.game._requestedState.lastName;
        var checkNull = (checking == null);
        if (checkNull) checking = FlxG.state.scriptName;
        var checkSplit = checking.split("/");
        if (checkSplit.length > 0) {
            checking = checkSplit.pop();
            allStates = FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/data/states/"+checkSplit.join("/"));
        }
        for (state in allStates) {
            state = Path.withoutExtension(state);
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
        FlxG.game._requestedState = new ModState("ModMainMenu");
    }

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
    trace("closing- bruh");
    if (FlxG.state.subState == null) return;
    
    if (queuedSubStates[0] != null) {
        var newSubState = queuedSubStates.shift();
        FlxG.state.openSubState(newSubState);
    } else {
        FlxG.state.closeSubState();
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
    trace("modToLoad: " + modToLoad);
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

static function removeModFromLibrary(modToRemove:String) {
    trace("modToRemove: " + modToRemove);
    if (!_loadedModAssetLibrary.exists(modToRemove)) return false;
    var mod = _loadedModAssetLibrary.get(modToRemove);
    var removed = Paths.assetsTree.removeLibrary(mod);
    mod.unload();
    
    // _debug_Mods(); // for debugging
    
    _loadedModAssetLibrary.remove(modToRemove);
    return true;
}

import funkin.backend.assets.IModsAssetLibrary;
import funkin.backend.assets.ScriptedAssetLibrary;
function _debug_Mods() {
    for (_mod in Paths.assetsTree.libraries) {
		var l = _mod;
		if (l is AssetLibrary) {
            if (l.__proxy != null) l = l.__proxy;
		}
        
		if (l is ScriptedAssetLibrary)
			trace(Type.getClassName(Type.getClass(l))+' - '+l.scriptName+' ('+l.modName+' | '+l.libName+' | '+l.prefix+')');
		else if (l is IModsAssetLibrary)
			trace(Type.getClassName(Type.getClass(l))+' - '+l.modName+' - '+l.libName+' ('+l.prefix+')');
		else
			trace(Std.string(l));
    }
    
    trace(Paths.assetsTree.libraries);
}