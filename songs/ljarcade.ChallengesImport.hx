//a
import Type;
import Reflect;
import StringTools;
import funkin.game.HudCamera;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;
import flixel.system.FlxSound;

import openfl.filters.ShaderFilter;
import lime.media.openal.AL;

importScript("LJ Arcade API/ljarcade.PlayStateChallenge");

function onSongEnd() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        if (StringTools.contains(challengeID, "songEnd_complete")) complete_challenge();
        switch(challengeID) {
            case "poison_notes_rand": complete_challenge();
            case "least_misses": if (misses <= data._challData.extra.rand_int) complete_challenge();
            case "no_misses": if (misses == 0) complete_challenge();
            case "no_sicks": if (progress == 1) complete_challenge();
            case "half_health": if (health <= (maxHealth * 0.5)) complete_challenge();
        }
    });
}

var _prevSONGdata = Json.parse(Json.stringify(PlayState.SONG));
function new() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case "poison_notes_rand": _addNoteType("ljarcade.Poison Note");
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
    FlxG.sound.soundTray.filters = [];
}

var song_notes:Int = 0;
var _numNotes:Int = 0;

var _splitCam:FlxCamera;

var _RANDOMGAY:Bool = false;

function postCreate() {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case "strum_split songEnd_complete":
                _splitCam = new HudCamera();
                _splitCam.bgColor = 0;
                _splitCam.downscroll = !camHUD.downscroll;
                FlxG.cameras.add(_splitCam, false);
            case "gay songEnd_complete": _RANDOMGAY = FlxG.random.bool(1);
            case "visually_impaired songEnd_complete":
                for (muff in [inst, vocals]) muffle(muff);
        }
    });

    strumLines.forEach(function(strum) {
        check_challenge_data(function(isGlobal, challengeID, data) {
            if (!isGlobal) return;
            if (StringTools.startsWith(challengeID, "notes_fade")) strum.onNoteUpdate.add(fadingNotes);
            switch(challengeID) {
                case "strum_split songEnd_complete":
                    var randoms = [];
                    for (i in 0...Std.int(strum.members.length / 2)) randoms.push(FlxG.random.int(0, strum.members.length - 1, randoms));
                    for (rand in randoms) {
                        if (strum.members[rand].camera != camHUD) continue;
                        strum.members[rand].camera = _splitCam;
                    }
                case "gay songEnd_complete":
                    if (!_RANDOMGAY) gay(strum);
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
            case "hit_notes":
                var _amount = data._challData.extra.divideAmount;
                if (_amount == null) _amount = 2;
                noteChallenge(_amount);
            case "hit_sicks":
                var _notesToHit = data._challData.extra.rand_int;
                if (song_notes < _notesToHit) _notesToHit = song_notes;
                _maxProgress = _notesToHit;
            case "poison_notes_rand": add_CustomNotes(PlayState.SONG.noteTypes.length, data._challData.extra.rand_int);
            case "least_misses": _maxProgress = progress = data._challData.extra.rand_int;
            case "no_misses", "no_sicks": _maxProgress = progress = 1;
        }
    });

}

function getPrideFlag() {
    var PRIDE = 0;
    var TRANS = 1;
    var PAN = 2;

    var flagChoices = [PRIDE, TRANS, PAN];

    return flagChoices[FlxG.random.int(0, flagChoices.length - 1)];
}

function onPostNoteCreation(event) {
    var note:Note = event.note;
    if (event.noteSprite == "game/notes/default") note.extra.set("ljarcade_usesDefaultNote", true);
}
function gay(strum) {
    for(note in strum.notes.members) {
        if (!note.extra.get("ljarcade_usesDefaultNote") || note.shader != null) continue;
        note.shader = new CustomShader("ljarcade.gay");
        note.shader.flag = getPrideFlag();
    }
}

function fadingNotes(event) {
    var note = event.note;
    var alphaSus = (note.isSustainNote) ? 0.6 : 1;
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case "notes_fade_in songEnd_complete":
                if ((note.strumTime - 200) - Conductor.songPosition <= 200) {
                    note.alpha = (1 - ((note.strumTime - 200) - Conductor.songPosition) / 200) * alphaSus;
                }
                else note.alpha = 0;
            case "notes_fade_out songEnd_complete":
                if ((note.strumTime - 150) - Conductor.songPosition <= 200)
                    note.alpha = (((note.strumTime - 150) - Conductor.songPosition) / 200) * alphaSus;
            // case 69: // monocolor
            //     note.colorTransform.color = 0x000000;
        }

    });
}

function getRainbowColor(hue:Float):Int {
    var r:Float;
    var g:Float;
    var b:Float;

    var i:Int = Math.floor(hue * 6);
    var f:Float = hue * 6 - i;
    var q:Float = 1 - f;
    i = i % 6;

    switch (i) {
        case 0: r = 1; g = f; b = 0;
        case 1: r = q; g = 1; b = 0;
        case 2: r = 0; g = 1; b = f;
        case 3: r = 0; g = q; b = 1;
        case 4: r = f; g = 0; b = 1;
        case 5: r = 1; g = 0; b = q;
        default: r = 0; g = 0; b = 0;
    }

    var red:Int = Math.floor(r * 255);
    var green:Int = Math.floor(g * 255);
    var blue:Int = Math.floor(b * 255);

    return (red << 16) | (green << 8) | blue;
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
            case "hit_notes", "hit_sicks":
                if (challengeID == "hit_sicks" && _event.rating.toLowerCase() != "sick") return;
                progress++;
                progress_timerDelay.cancel();
                progress_timerDelay.start(1, function() {
                    progress_challenge_display();
                });
            case "no_sicks":
                if (_event.rating.toLowerCase() != "sick") return;
                progress--;
                progress_challenge_display();
                disable_progress_display = true;
            case "half_gain songEnd_complete": if (_event.healthGain > 0) _event.healthGain /= 2;
        }
    });
}

function onPlayerMiss(event) {
    if (event.note.avoid) return;
    var _event = event;
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case "least_misses", "no_misses":
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

var _muffleData = {lowpassGain: 1, lowpassGainHF: 1};
function muffle(sound) {
    if (_soundsMap.exists(sound)) return;

    var effect = new AudioEffects(sound);
    effect.lowpassGain = _muffleData.lowpassGain;
    effect.lowpassGainHF = _muffleData.lowpassGainHF;
    effect.update(0);
    add(effect);
    _soundsMap.set(sound, effect);
}

var blurShader:CustomShader = new CustomShader("ljarcade.editorBlurFast");
var _blurData = {uBlur: 1, uBrightness: 1};
blurShader.uBlur = 0;
blurShader.uBrightness = 1;
function cameraBlur(cam:FlxCamera) {
    if (_camerasMap.exists(cam) && _camerasMap.get(cam) != null) return;
    cam.addShader(blurShader);
    _camerasMap.set(cam, 0);
}

function update(elapsed) {

    if (FlxG.keys.justPressed.K && _isChallenge) 
        complete_challenge();

    if (_RANDOMGAY) trustTheProcess(members);
}

var startMuffle:Bool = true;
function postUpdate(elapsed) {
    check_challenge_data(function(isGlobal, challengeID, data) {
        if (!isGlobal) return;
        switch(challengeID) {
            case "visually_impaired songEnd_complete":
                for (sound in FlxG.sound.list) muffle(sound);
                for (cam in FlxG.cameras.list) cameraBlur(cam);

                blurShader.entropy = FlxG.random.float(0, 1);
                
                var shaderFilter = new ShaderFilter(blurShader);
                shaderFilter.shader.data.uBlur.value[0] = blurShader.uBlur;
                shaderFilter.shader.data.uBrightness.value[0] = blurShader.uBrightness;
                shaderFilter.shader.data.entropy.value[0] = blurShader.entropy;
                FlxG.sound.soundTray.filters = [shaderFilter];
            case "strum_split songEnd_complete":
                if (_splitCam != null) _splitCam.zoom = camHUD.zoom;
        }
    });
}

function onSongStart() {
    new FlxTimer().start(0.5, function() {
        check_challenge_data(function(isGlobal, challengeID, data) {
            if (!isGlobal) return;
            switch(challengeID) {
                case "visually_impaired songEnd_complete":
                    var ease = FlxEase.quadInOut;
                    var kys = {uBlur: blurShader.uBlur};
                    FlxTween.tween(kys, {uBlur: 0.04}, Conductor.crochet * 0.001, {ease: ease,
                    onUpdate: function(tween) {
                        blurShader.uBlur = _blurData.uBlur = kys.uBlur;
                    }});
    
                    for (keys in _soundsMap.keys()) {
                        var effect = _soundsMap.get(keys);
                        if (effect == null) continue;
                        var kys = {lowpassGain: effect.lowpassGain, lowpassGainHF: effect.lowpassGainHF};
    
                        FlxTween.tween(kys, {lowpassGain: 0.999}, Conductor.crochet / 500, {ease: ease,
                        onUpdate: function(tween) {
                            effect.lowpassGain = _muffleData.lowpassGain = kys.lowpassGain;
                            effect.update(0);
                        }});
                        FlxTween.tween(kys, {lowpassGainHF: 0.0001}, Conductor.crochet / 500, {ease: ease,
                        onUpdate: function(tween) {
                            effect.lowpassGainHF = _muffleData.lowpassGainHF = kys.lowpassGainHF;
                            effect.update(0);
                        }});
                    }
            }
        });
    });
}

var gayMap:Map<Dynamic, Dynamic> = [
    new FlxSprite() => null, // hate my life
];

function trustTheProcess(cum:Array<FlxBasic>) {
    for(spr in cum) {
        if(spr == null) continue;
        // trust the process
        if(spr.members != null) {
            trustTheProcess(spr.members);
            continue;
        }
        if(spr.notes != null) {
            spr.notes.forEach(function (note) {
                if(note == null || !note.extra.get("ljarcade_usesDefaultNote")) return;
                trustTheProcess([note]);
            });
            continue;
        }
        //if(spr.notes != null) {
        //    trustTheProcess(spr.notes.members);
        //}
        if(spr.type == 2 || spr.type == 4) {
            continue;
        } else {
            if(Std.isOfType(spr, FlxSprite)) {
                if(gayMap.exists(spr)) continue;
                gayMap.set(spr, 0);
                spr.shader = new CustomShader("ljarcade.gay");
                spr.shader.flag = getPrideFlag();
            }
            continue;
        }
    }
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