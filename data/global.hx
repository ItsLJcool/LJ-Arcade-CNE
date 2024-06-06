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

static var queuedSubStates = [];


static var initialized:Bool = false;
static var customPrefix = "ljarcade";

static var redirectStates:Map<FlxState, String> = [
    // MainMenuState => 'ljarcade.MainMenuState',
	// OptionsMenu => 'path',
	// FreeplayState => 'you already know it dumbass'
];

function preStateSwitch() {
    FlxG.camera.bgColor = 0xFF000000;
    
    if (FlxG.game._requestedState is PlayState) {
        trace("PlayState opening");
        EventsData.reloadEvents();
    }
	if (!initialized) {
		initialized = true;
		//FlxG.game._requestedState = new ModState('WarningState');
	} else {
        var thing = FileSystem.readDirectory(ModsFolder.modsPath+ModsFolder.currentModFolder+"/data/states");
        for (state in thing) {
            var fileName = Path.withoutExtension(state);
            var split = fileName.split(".");
            if (split[0] != customPrefix) continue;
            var requestedState = Type.getClassName(Type.getClass(FlxG.game._requestedState)).split(".");
            
            if (requestedState[requestedState.length-1] == split[split.length-1]
            || (Type.getClass(FlxG.game._requestedState) == ModState) && (FlxG.game._requestedState.lastName == split[split.length-1])) {
				FlxG.game._requestedState = new ModState(fileName);
                return;
            }
        }
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
    if (FlxG.state.subState == null) return;
    FlxG.state.closeSubState();
}

function destroy() { FlxG.camera.bgColor = 0xFF000000; }