//a

public static var botplay:Bool = false;

var _allowedGitaroo:Bool = allowGitaroo;
function update(elapsed) {
    if (FlxG.keys.justPressed.B) {
        botplay = !botplay;
        canDie = !botplay;
        if (_allowedGitaroo) allowGitaroo = !botplay;
    }
    playerStrums.forEach((strum) -> { strum.cpu = botplay; });
}

function postCreate() {
    strumLines.forEach(function(strum) {
        if (strum.cpu) return;
        strum.onNoteUpdate.add(updateNote);
    });
}

function onInputUpdate(event) {
    if (botplay) event.cancel();
}

function updateNote(event) {
    if (!botplay) return;

    var daNote:Note = event.note;

    if (!daNote.avoid && !daNote.wasGoodHit && daNote.strumTime < Conductor.songPosition) {
        PlayState.instance.goodNoteHit(daNote.strumLine, daNote);
        // pauseGame();
    }
}