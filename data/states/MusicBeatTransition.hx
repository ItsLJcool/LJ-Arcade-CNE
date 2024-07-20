// import haxe.macro.Context;
// import Type;
// import flixel.text.FlxTextBorderStyle;
if (_loadedModAssetLibrary != null) {
for (modLib in _loadedModAssetLibrary) {
    if (!modLib.exists("assets/data/states/MusicBeatTransition.hx", "TEXT")) continue;
    importScript("data/states/MusicBeatTransition");
}
}

// // ENABLE IF YOU WANNA SEE A BIT OF DEBUGGING SHITS :) //
// var debug:Bool = true;
// var postBS:Bool = true;
// function create() {
// 	if (debug)
// 		trace("[Transition ran] "
// 			+ Type.getClassName(Type.getClass(FlxG.state))
// 			+ " -> "
// 			+ ((Type.getClassName(Type.getClass(newState)) == null) ? "N/A (out)" : Type.getClassName(Type.getClass(newState))));
// }

// function onDestroy() {
// 	// make tweens destroy here, just in case
// }

// // pre-state change
// // use transitionToNewState() to change state and trigger transitionOut
// function transitionIn() {
// 	transitionToNewState();
// }

// // post-state change
// function transitionOut() {

// }

// function update(elapsed) {
// 	if (postBS) {
// 		postBS = false;

// 		// get rid of original transition :)
// 		members[0].visible = false;
// 		transitionTween.cancel();

// 		transitionCamera.scroll.set();
// 		transitionCamera.flipY = false;
// 		transitionCamera.flashSprite.scaleX = 1.05;
// 		transitionCamera.flashSprite.scaleY = 1.05;

// 		// do the proper transition
// 		properTransition();
// 	}

// 	nextFrameSkip = false; // force off
// }

// // this technically is "postCreate" (but it's a fake and a fraud)
// // postCreate never gets run, so we fake it
// function properTransition() {
// 	// add anything here to transition

// 	if (newState != null) {
// 		transitionIn();
// 	} else {
// 		transitionOut();
// 	}
// }

// // Transitions to new state.
// function transitionToNewState() {
// 	FlxG.game._requestedState = newState;
// 	FlxG.game.switchState();
// }