//a
import Type;
import Reflect;
import StringTools;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;

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

var _prevSONGdata = Json.parse(Json.stringify(PlayState.SONG));
function new() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 4:
                _addNoteType("ljarcade.Poison Note");
        }
    });
}
function _addNoteType(noteType:String) {
    PlayState.SONG.noteTypes.push(noteType);
    var scriptPath = Paths.script('data/notes/'+noteType);
    var script = Script.create(scriptPath);
    if (Assets.exists(scriptPath) && !scripts.contains(scriptPath)) {
        if (!(script is DummyScript)) {
            scripts.add(script);
            script.load();
        }
    }
}

function destroy() {
    PlayState.SONG = _prevSONGdata;
}

var song_notes:Int = 0;
var _numNotes:Int = 0;
function postCreate() {
    strumLines.forEach(function(strum) {
        if (strum.opponentSide) return;
        for (note in strum.notes) {
            if (!note.avoid) song_notes++;
        }
    });
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 1: noteChallenge(4);
            case 2: noteChallenge(2);
            case 3:
                var _notesToHit = data._challData.extra.rand_int;
                if (song_notes < _notesToHit) _notesToHit = song_notes;
                _maxProgress = _notesToHit;
            case 4: add_CustomNotes(PlayState.SONG.noteTypes.length, data._challData.extra.rand_int);
        }
    });
}

function noteChallenge(divideAmount:Int) {
    _numNotes = Std.int(song_notes / divideAmount);
    _maxProgress = _numNotes;
}

function onPlayerHit(event) {
    var _event = event;
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 1, 2, 3:
                if (challengeID == 3 && _event.rating.toLowerCase() != "sick") return;
                progress++;
                _noteChallenge_progress.cancel();
                _noteChallenge_progress.start(1, function() {
                    progress_challenge_display();
                });

        }
    });
}

var _noteChallenge_progress:FlxTimer = new FlxTimer().start(0);

function add_CustomNotes(noteType:Int, chanceToAdd:Float) {
    var _strumsToAdd = [];
    for (strum in strumLines) {
        if (strum.opponentSide) continue;
        _strumsToAdd.push(strum);
    }

    var default_timeData = { time: 0.0, id: 0, type: noteType, sLen: 0.0, };
    for (strum in _strumsToAdd) {

        var _notes = [];
        for (note in strum.notes.members) {
            var rng = FlxG.random.bool(chanceToAdd);
            if (!rng || note.isSustainNote || note.noteType != null) continue;

            var prevNote = (note.prevNote == null) ? null : note.prevNote.strumTime;
            var nextNote = (note.nextNote == null) ? null : note.nextNote.strumTime;

            var random_data = [note.noteData];
            if (prevNote != null && note.noteData == prevNote.noteData) random_data.push(prevNote.noteData);
            if (nextNote != null && note.noteData == nextNote.noteData) random_data.push(nextNote.noteData);

            default_timeData.id = FlxG.random.int(0, 3, random_data);
            default_timeData.time = note.strumTime;
            
            _notes.push(new Note(strum, default_timeData, false, 0, 0, null));
        }
        strum.notes.addNotes(_notes);
    }

}

function update(elapsed) {
    if (FlxG.keys.justPressed.K && _isChallenge) 
        complete_challenge();
}
