//a
import Type;
import Reflect;
import StringTools;
import funkin.game.HudCamera;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;
import flixel.system.FlxSound;
import lime.media.openal.AL;

importScript("LJ Arcade API/ljarcade.PlayStateChallenge");

function onSongEnd() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 0, 11, 12, 13: complete_challenge();
            case 5: if (misses <= data._challData.extra.rand_int) complete_challenge();
            case 6: if (misses == 0) complete_challenge();
            case 9: if (progress == 1) complete_challenge();
            case 10: if (health <= (maxHealth * 0.5)) complete_challenge();
        }
    });
}

var _prevSONGdata = Json.parse(Json.stringify(PlayState.SONG));
function new() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 4: _addNoteType("ljarcade.Poison Note");
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
    for (key in _soundsMap.keys()) key.destroy();
    for (key in _camerasMap.keys()) key.removeShader(blurShader);
    blurShader = null;
}

var song_notes:Int = 0;
var _numNotes:Int = 0;

var _splitCam:FlxCamera;
function postCreate() {
    strumLines.forEach(function(strum) {
        check_challenge_data(function(isGlobal, challengeID, data) {
            if (!isGlobal) return;
            switch(challengeID) {
                case 7, 8: strum.onNoteUpdate.add(fadingNotes);
                case 13:
                    _splitCam = new HudCamera();
                    _splitCam.bgColor = 0;
                    _splitCam.downscroll = !camHUD.downscroll;
                    FlxG.cameras.add(_splitCam, false);
                    var random1 = FlxG.random.int(0, 3);
                    var random2 = FlxG.random.int(0, 3, [random1]);
                    for (rand in [random1, random2]) strum.members[rand].cameras = [_splitCam];
            }
        });
        if (strum.opponentSide) return;
        for (note in strum.notes.members) {
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
            case 5: _maxProgress = progress = data._challData.extra.rand_int;
            case 6, 9: _maxProgress = progress = 1;
        }
    });

}

function fadingNotes(event) {
    var note = event.note;
    var alphaSus = (note.isSustainNote) ? 0.6 : 1;
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 7:
                if ((note.strumTime - 200) - Conductor.songPosition <= 200) {
                    note.alpha = (1 - ((note.strumTime - 200) - Conductor.songPosition) / 200) * alphaSus;
                }
                else note.alpha = 0;
            case 8:
                if ((note.strumTime - 150) - Conductor.songPosition <= 200)
                    note.alpha = (((note.strumTime - 150) - Conductor.songPosition) / 200) * alphaSus;
            // case 69: // monocolor
            //     note.colorTransform.color = 0x000000;
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
                progress_timerDelay.cancel();
                progress_timerDelay.start(1, function() {
                    progress_challenge_display();
                });
            case 9:
                if (_event.rating.toLowerCase() != "sick") return;
                progress--;
                progress_challenge_display();
            case 11: if (_event.healthGain > 0) _event.healthGain /= 2;
        }
    });
}

function onPlayerMiss(event) {
    if (event.note.avoid) return;
    var _event = event;
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 5, 6:
                progress--;
                progress_timerDelay.cancel();
                progress_timerDelay.start(1.5, function() {
                    progress_challenge_display(false);
                });

        }
    });
}

var progress_timerDelay:FlxTimer = new FlxTimer().start(0);

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

var _soundsMap:Map<Dynamic, Dynamic> = [
    new FlxSound() => null, // hate my life
];
var _camerasMap:Map<Dynamic, Dynamic> = [
    FlxG.camera => null, // hate my life
];
var _cumearaMap:Map<Dynamic, Dynamic> = [
    FlxG.camera => null, // hate my life
];

function muffle(sound) {
    if (_soundsMap.exists(sound)) return;

    var effect = new AudioEffects(sound);
    effect.lowpassGain = 0.999;
    effect.lowpassGainHF = 0.0001;
    effect.update(0);
    add(effect);
    _soundsMap.set(sound, effect);
}

var blurShader:CustomShader = new CustomShader("ljarcade.editorBlurFast");
blurShader.uBlur = 0.04;
blurShader.uBrightness = 1;
function cameraBlur(cam:FlxCamera) {
    if (_camerasMap.exists(cam) && _camerasMap.get(cam) != null) return;
    cam.addShader(blurShader);
    _camerasMap.set(cam, 0);
}

function update(elapsed) {

    if (FlxG.keys.justPressed.K && _isChallenge) 
        complete_challenge();

}

function postUpdate(elapsed) {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case 12:
                for (sound in FlxG.sound.list) muffle(sound);
                for (cam in FlxG.cameras.list) cameraBlur(cam);
                blurShader.entropy = FlxG.random.float(0, 1);
            case 13:
                if (_splitCam != null) _splitCam.zoom = camHUD.zoom;
        }
    });
}

class AudioEffects extends flixel.FlxBasic {
	var sound = null;

	var lowpassGain = 0.0;
	var lowpassGainHF = 0.0;

	public function new(_sound) {
		LOWPASS_GAIN = 0x0001; /*Not exactly a lowpass. Apparently it's a shelf*/
		LOWPASS_GAINHF = 0x0002;
		FILTER_TYPE = 0x8001;
		FILTER_LOWPASS = 0x0001;
		FILTER_HIGHPASS = 0x0002;
		DIRECT_FILTER = 0x20005;

		sound = _sound;
		audioFilter = null;
		audioFilter = AL.createFilter();
	}

	public override function update() {
		var handle = null;

		if(sound != null) {
			if(sound._channel != null) {
				handle = sound._channel.__source.__backend.handle;
			}
		}

		if(handle == null) {
			return;
		}

		//if(audioFilter != null) {
		//	//AL.deleteFilter(audioFilter); // turned off since i need to get something from lime external interface
		//	//audioFilter = null;
		//}

		//if(audioFilter == null) {
		//	audioFilter = AL.createFilter();
		//}
		AL.filteri(audioFilter, FILTER_TYPE, FILTER_LOWPASS);
		AL.filterf(audioFilter, LOWPASS_GAIN, lowpassGain);
		AL.filterf(audioFilter, LOWPASS_GAINHF, lowpassGainHF);
		AL.sourcei(handle, DIRECT_FILTER, audioFilter);
	}

	public function deleteFilter(buffer) {
		//NativeCFFIExt.lime_al_delete_filter(buffer);
	}

	public override function destroy() {
		if (audioFilter != null) {
			//AL.deleteFilter(audioFilter);
			audioFilter = null;
		}
	}
}