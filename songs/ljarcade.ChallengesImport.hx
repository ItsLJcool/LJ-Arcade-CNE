//a
import Type;
importScript("LJ Arcade API/ljarcade.PlayStateChallenge");

function onSongEnd() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 0:
                complete_challenge();
                return;
        }
    });
}

var _numNotes:Int = 0;
function postCreate() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 1: noteChallenge(4);
            case 2: noteChallenge(2);
        }
    });
}

function noteChallenge(divideAmount:Int) {
    strumLines.forEach(function(strum) {
        if (strum.opponentSide) return;
        for (note in strum.notes) {
            if (!note.avoid) _numNotes++;
        }
    });
    _numNotes = Std.int(_numNotes / divideAmount);
    _maxProgress = _numNotes;

    _noteChallenge_progress.time = 2;
    _noteChallenge_progress.active = false;
}

function onPlayerHit(event) {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 1, 2:
                progress++;
                _noteChallenge_progress.cancel();
                _noteChallenge_progress.start(1, function() {
                    progress_challenge_display();
                });
        }
    });
}

var _noteChallenge_progress:FlxTimer = new FlxTimer();

function update(elapsed) {
    if (FlxG.keys.justPressed.K && _isChallenge) 
        complete_challenge();
}
