//a
import openfl.geom.ColorTransform;
import flixel.math.FlxMath;

var poisonNotesHit:Int = 0;

function onNoteCreation(event) {
    if (event.noteType != 'ljarcade.Poison Note') return;
    var note:Note = event.note;
    
    event.noteSprite = "game/notes/PHANTOMNOTE_assets";
    note.avoid = true;
    note.earlyPressWindow = 0.1;
    note.latePressWindow = 0.2;
}

function postUpdate() {
    if (health > 0.1) health -= 0.0002 * poisonNotesHit;
}

function onPlayerMiss(event) {
    if (event.noteType != 'ljarcade.Poison Note') return;
    event.cancel();
}

function onPlayerHit(event) {
    if (event.noteType != 'ljarcade.Poison Note') return;
    event.misses = true;
    event.countAsCombo = event.countScore = event.showRating = false;
    event.healthGain = 0;
    poisonNotesHit++;
	new FlxTimer().start(10, function(tmr:FlxTimer) { poisonNotesHit -= 1; });
}