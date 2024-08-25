//Modchart template for the GPU modchart framework
import StringTools;

//import the script first
importScript("data/scripts/modchartManager.hx");
function postCreate() {
    for(e in [healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt]) e.visible = false;
    camGame.visible = false;
    // setup your own modifiers and events
    setupModifiers();
    setupEvents();

    //then initialize the modchart to generate the shaders
    initModchart();
}
function postUpdate() {
    camZooming = false;
}

function setupModifiers() {
	createModifier("speed", 1, "
		curPos *= speed_value;
	", -1, -1, 1.0);
    
	for (i in 0...strumLines.members.length) {
        var strum = strumLines.members[i];
        strum.forEach(function(strm) {
            createModifier("_"+i+"x"+strm.ID, 0, "
                x += _"+i+"x"+strm.ID+"_value;
            ", i, strm.ID);
    
            createModifier("_"+i+"y"+strm.ID, 0, "
                y += _"+i+"y"+strm.ID+"_value;
            ", i, strm.ID);
    
            createModifier("_"+i+"z"+strm.ID, 0, "
                z += _"+i+"z"+strm.ID+"_value;
            ", i, strm.ID);
    
            createModifier("_"+i+"a"+strm.ID, 1, "
                a -= 1.0 - _"+i+"a"+strm.ID+"_value;
            ", i, strm.ID);
            
            // Makes a uniform without any code associated with it on create.
            createModifier("_"+strm.ID+"strumRotateXP"+(i), 0.0, "", i, strm.ID, 0.0, false);
            createModifier("_"+strm.ID+"strumRotateYP"+(i), 0.0, "", i, strm.ID, 0.0, false);
            createModifier("_"+strm.ID+"strumRotateZP"+(i), 0.0, "", i, strm.ID, 0.0, false);

            createModifier("strumRotateP"+(i), 1.0, "
                float newPos = 4.0 + (strumID - 0.0) * ((-4.0 - 4.0) / (4.0 - 0.0));
                float distance = (112.0 * newPos * 0.5) - (112.0 * 0.5);
                x += distance;
                vec4 p = rotation3d(vec3(1.0, 0.0, 0.0), _"+strm.ID+"strumRotateXP"+(i)+"_value * rad) * 
                rotation3d(vec3(0.0, 1.0, 0.0), _"+strm.ID+"strumRotateYP"+(i)+"_value * rad) * rotation3d(vec3(0.0, 0.0, 1.0), _"+strm.ID+"strumRotateZP"+(i)+"_value * rad) * vec4(distance, 0.0, 0.0, 1.0);

                x -= p.x;
                y -= p.y;
                z -= p.z;

                angleX += _"+strm.ID+"strumRotateXP"+(i)+"_value;
                angleY += _"+strm.ID+"strumRotateYP"+(i)+"_value;
                angleZ += _"+strm.ID+"strumRotateZP"+(i)+"_value;
            ", i, strm.ID);

        });
        createModifier("other_"+i+"x", 0, "", i, -1, 0, false);
        createModifier("_"+i+"x", 0, "
            x += (_"+i+"x"+"_value) + (other_"+i+"x"+"_value);
        ", i, -1, 0);

        createModifier("other_"+i+"y", 0, "", i, -1, 0, false);
        createModifier("_"+i+"y", 0, "
            y += (_"+i+"y"+"_value) + (other_"+i+"y"+"_value);
        ", i, -1, 0);
        
        createModifier("other_"+i+"z", 0, "", i, -1, 0, false);
        createModifier("_"+i+"z", 0, "
            z += (_"+i+"z"+"_value) + (other_"+i+"z"+"_value);
        ", i, -1, 0);
        
        createModifier("_"+i+"a", 1, "
            a -= 1.0 - _"+i+"a"+"_value;
        ", i, -1, 1);

        // Makes a uniform without any code associated with it on create.
        createModifier("strumLineRotateXP"+(i), 0.0, "", i, -1, 0.0, false);
        createModifier("other_strumLineRotateXP"+(i), 0.0, "", i, -1, 0.0, false);

        createModifier("strumLineRotateYP"+(i), 0.0, "", i, -1, 0.0, false);
        createModifier("other_strumLineRotateYP"+(i), 0.0, "", i, -1, 0.0, false);

        createModifier("strumLineRotateZP"+(i), 0.0, "", i, -1, 0.0, false);
        createModifier("other_strumLineRotateZP"+(i), 0.0, "", i, -1, 0.0, false);

        var funny = "
            float newPos = 4.0 + (strumID - 0.0) * ((-4.0 - 4.0) / (4.0 - 0.0));
            float distance = (112.0 * newPos * 0.5) - (112.0 * 0.5);
            x += distance;
            vec4 p = rotation3d(vec3(1.0, 0.0, 0.0), strumLineRotateXP"+(i)+"_value * rad) * 
            rotation3d(vec3(0.0, 1.0, 0.0), strumLineRotateYP"+(i)+"_value * rad) * rotation3d(vec3(0.0, 0.0, 1.0), strumLineRotateZP"+(i)+"_value * rad) * vec4(distance, 0.0, 0.0, 1.0);

            x -= p.x;
            y -= p.y;
            z -= p.z;

            angleX += strumLineRotateXP"+(i)+"_value;
            angleY += strumLineRotateYP"+(i)+"_value;
            angleZ += strumLineRotateZP"+(i)+"_value;
        ";
        createModifier("strumLineRotateP"+(i), 1.0, funny, i);
        funny = StringTools.replace(funny, "strumLineRotateXP"+(i), "other_strumLineRotateXP"+(i));
        funny = StringTools.replace(funny, "strumLineRotateYP"+(i), "other_strumLineRotateYP"+(i));
        funny = StringTools.replace(funny, "strumLineRotateZP"+(i), "other_strumLineRotateZP"+(i));
        createModifier("other_strumLineRotateP"+(i), 1.0, funny, i);
    
        createModifier("strumLineNotITG_P"+(i), 75, "
            if (curPos < 0.0)
                z += sin((curPos+songPosition)*0.005) * strumLineNotITG_P"+(i)+"_value;
        ", i);

        createModifier("centerX"+i, 0.0, "", i, -1, 0.0, false);
        createModifier("centerY"+i, 0.0, "", i, -1, 0.0, false);
        
        createModifier("radius"+i, 150.0, "", i, -1, 150.0, false);

        createModifier("angle"+i, 90.0, "", i, -1, 0.0, false);
        createModifier("circleRadius"+i, 0.0, "
            // Convert angle to radians
            float radians = (PI * angle"+(i)+"_value) / 180.0;

            // Update sprite's position to circle around the center point
            x += (centerX"+(i)+"_value + cos(radians) * radius"+(i)+"_value) * circleRadius"+(i)+"_value;
            y += (centerY"+(i)+"_value + sin(radians) * radius"+(i)+"_value) * circleRadius"+(i)+"_value;
        ", i);

        createModifier("bouncyStrum"+i, 0.0, "
            // Bounce cycle duration in milliseconds (e.g., 2 seconds per cycle)
            float bounceDuration = 450.0;
            float normalizedTime = mod(songPosition, bounceDuration) / bounceDuration;

            // Variables for bounce effect
            float yPosition = 0.0; // The current y position of the strumline
            float bounceHeight = 50.0; // The height the strumline will bounce

            // Inline calculations for easing functions
            float circOut = sqrt(1.0 - pow(normalizedTime - 1.0, 2.0)); // Approximation of easeCircOut
            float sineIn = 1.0 - cos((normalizedTime * PI) / 2.0); // Approximation of easeSineIn

            yPosition += bounceHeight * circOut;
            yPosition -= bounceHeight * sineIn;
            // yPosition += 150.0;

            // Update the y position
            y += yPosition * bouncyStrum"+i+"_value;
        ", i, -1);
	} 

    createModifier("beat_mult", 0.02, "", -1, -1, 0.02, false);
    createModifier("beat", 0.0, "
        float fAccelTime = 0.7;
        float fTotalTime = 0.8;
        float fBeat = curBeat + fAccelTime;

        if (fBeat >= 0.0 && curPos < 0.0)
        {
            float evenBeat = mod(floor(fBeat), 2.0);

            fBeat -= floor(fBeat);
            fBeat += 1.0;
            fBeat -= floor(fBeat);

            if (fBeat < fTotalTime)
            {
                float fAmount = 0.0;
                if( fBeat < fAccelTime )
                {
                    fAmount = 0.0 + (fBeat - 0.0) * ((1.0 - 0.0) / (fAccelTime - 0.0));
                    fAmount *= fAmount;
                }
                else
                {
                    fAmount = 1.0 + (fBeat - fAccelTime) * ((0.0 - 1.0) / (fTotalTime - fAccelTime));
                    fAmount = 1.0 - (1.0 - fAmount) * (1.0 - fAmount);
                }

                if (evenBeat != 0.0)
                    fAmount *= -1.0;

                x += 20.0 * fAmount * sin((curPos * beat_mult_value) + (PI * 0.5)) * beat_value;
            }
        }
    ");
}
function get_middleX(idx:Int) {
    var mid = FlxG.width/2 - (Note.swagWidth * (strumLines.members[idx].members.length+2))/2;
    if (idx == 1) mid = -(mid + 32);
    return mid;
}
function setupEvents() {
    set_moveStrum({
        time: -introLength,
        strumLineID: 0,
        z: 950,
        y: 700,
        x: get_middleX(0),
        a: 0,
    });
    set_moveStrum({
        time: -introLength,
        strumLineID: 1,
        a: 0,
    });

    ease_moveStrum({
        time: 0,
        dur: 12,
        ease: "quadOut",
        strumLineID: 0,
        z: 0,
        y: 0,
        a: 1,
    });
    set_moveStrum({
        time: 12,
        x: get_middleX(1),
        strumLineID: 1,
    });
    ease_moveStrum({
        time: 13,
        dur: 2,
        ease: "quadOut",
        strumLineID: 0,
        a: 0.5,
    });
    ease_moveStrum({
        time: 13,
        dur: 2,
        ease: "quadOut",
        strumLineID: 1,
        a: 1,
    });

    for (i in 0...2) {
        ease_moveStrum({
            time: 15,
            dur: 1,
            ease: "quadOut",
            strumLineID: i,
            angleY: (i == 0) ? 25 : 0,
        });
        ease_moveStrum({
            time: 16,
            dur: 1,
            ease: "quadOut",
            strumLineID: i,
            x: 0,
            angleY: (i == 0) ? -(360+35) : 0,
        });
        ease_moveStrum({
            time: 17,
            dur: 0.5,
            ease: "quadInOut",
            strumLineID: i,
            angleY: (i == 0) ? -(360) : 0,
            a: 1,
        });
        set_moveStrum({
            time: 18,
            strumLineID: i,
            angleY: (i == 0) ? -360 : 360,
        });
        
        set(64, "0.0, strumLineNotITG_P"+i);
        ease_moveStrum({
            time: 63,
            dur: 2,
            ease: "circInOut",
            strumLineID: i,
            angleY: (i == 0) ? -15 : 15,
            y: -50,
        });

        ease_moveStrum({
            time: 92,
            dur: 3.5,
            ease: "quadIn",
            strumLineID: i,
            a: 0,
        });

        set_moveStrum({
            time: 96,
            strumLineID: i,
            y: 0,
            x: (i == 0) ? -FlxG.width : FlxG.width,
            angleY: 0,
        });

        ease_moveStrum({
            time: 97,
            dur: 4,
            ease: "quadOut",
            strumLineID: i,
            a: 1,
        });
        
    }
    
    ease_moveStrum({
        time: 98,
        dur: 2,
        ease: "circOut",
        strumLineID: 0,
        x: get_middleX(0),
    });

    set(100, "
        1.0, bouncyStrum0_value;
        1.0, bouncyStrum1_value;
    ");
    
    ease_moveStrum({
        time: 104,
        dur: 0.5,
        ease: "circOut",
        strumLineID: 0,
        x: 150,
        y: -100,
    });

    ease_moveStrum({
        time: 105,
        dur: 0.5,
        ease: "circOut",
        strumLineID: 0,
        x: 450,
        y: -25,
    });

    ease_moveStrum({
        time: 105.5,
        dur: 0.5,
        ease: "circOut",
        strumLineID: 0,
        x: -150,
        y: -25,
    });

    ease_moveStrum({
        time: 106,
        dur: 0.5,
        ease: "circOut",
        strumLineID: 0,
        x: 100,
        y: -100,
    });

    ease_moveStrum({
        time: 106.5,
        dur: 0.5,
        ease: "circOut",
        strumLineID: 0,
        x: 550,
        y: -400,
    });

    ease_moveStrum({
        time: 107,
        dur: 1,
        ease: "circOut",
        strumLineID: 0,
        x: 0,
        y: 0,
    });
    
    ease_moveStrum({
        time: 107,
        dur: 1,
        ease: "circOut",
        strumLineID: 1,
        x: 0,
    });
    
    set(32, "2.0, beat");
    set(64, "0.0, beat");
    set(132, "
        1.0, bouncyStrum0,
        1.0, bouncyStrum1
    ");
    set(132, "
        1.0, bouncyStrum0,
        1.0, bouncyStrum1
    ");
    ease(196, 1, "quadInOut", "
        0.0, bouncyStrum0,
        0.0, bouncyStrum1,
    ");
}

var _beatAngle:Bool = false;
function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 132, 204: _beatAngle = !_beatAngle;
        case 288: _strumMoveOnHit = false;
    }
    if (!_beatAngle) return;
    var intense = 5;
    if (curBeat % 2 == 1) intense = -intense;
    for (i in 0...strumLines.members.length) {
        intense = -intense;
        tweenModifierValue("other_strumLineRotateXP"+i, intense, 0.05, FlxEase.quadInOut);
        tweenModifierValue("other_strumLineRotateYP"+i, intense, 0.05, FlxEase.quadInOut);
        new FlxTimer().start(0.05, function(timer) {
            tweenModifierValue("other_strumLineRotateXP"+i, 0, 0.25, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateYP"+i, 0, 0.25, FlxEase.quadInOut);
        });
    }
}

function onStrumCreation(event) event.cancelAnimation();

function toggle_strumMoveOnHit(_value:Bool) _strumMoveOnHit = !_strumMoveOnHit;

var _noteHitTimer:Array<FlxTimer> = [];
var _strumMoveOnHit:Bool = false;
function onNoteHit(event) {
    if (!_strumMoveOnHit) return;
    var strumIdx = strumLines.members.indexOf(event.note.strumLine);
    var intense = 15;
    switch(event.note.noteData % 4) {
        case 0:
            tweenModifierValue("other_"+strumIdx+"x", -intense, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateXP"+strumIdx, -intense*0.5, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateYP"+strumIdx, -intense*0.5, 0.05, FlxEase.quadInOut);
        case 1:
            tweenModifierValue("other_"+strumIdx+"y", -intense, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateXP"+strumIdx, -intense*0.5, 0.05, FlxEase.quadInOut);
        case 2: 
            tweenModifierValue("other_"+strumIdx+"y", intense, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateXP"+strumIdx, intense*0.5, 0.05, FlxEase.quadInOut);
        case 3:
            tweenModifierValue("other_"+strumIdx+"x", intense, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateXP"+strumIdx, intense*0.5, 0.05, FlxEase.quadInOut);
            tweenModifierValue("other_strumLineRotateYP"+strumIdx, intense*0.5, 0.05, FlxEase.quadInOut);
    }
    if (_noteHitTimer[strumIdx] == null) _noteHitTimer[strumIdx] = new FlxTimer().start(0);
    var timer = _noteHitTimer[strumIdx];
    timer.cancel();
    timer.start(0.1, function(timer) {
        tweenModifierValue("other_"+strumIdx+"x", 0, 0.5, FlxEase.quadOut);
        tweenModifierValue("other_"+strumIdx+"y", 0, 0.5, FlxEase.quadOut);
        tweenModifierValue("other_strumLineRotateXP"+strumIdx, 0, 0.5, FlxEase.quadOut);
        tweenModifierValue("other_strumLineRotateYP"+strumIdx, 0, 0.5, FlxEase.quadOut);
    });
}

function ease_moveStrumNote(_data:Dynamic) {
    var data = "";
    if (_data.x != null) data += _data.x+", _"+_data.strumLineID+"x"+_data.strumID+",";
    if (_data.y != null) data += _data.y+", _"+_data.strumLineID+"y"+_data.strumID+",";
    if (_data.z != null) data += _data.z+", _"+_data.strumLineID+"z"+_data.strumID+",";
    if (_data.a != null) data += _data.a+", _"+_data.strumLineID+"a"+_data.strumID+",";
    if (_data.angleX != null) data += _data.angleX+", _"+_data.strumID+"strumRotateXP"+_data.strumLineID+",";
    if (_data.angleY != null) data += _data.angleY+", _"+_data.strumID+"strumRotateYP"+_data.strumLineID+",";
    if (_data.angleZ != null) data += _data.angleZ+", _"+_data.strumID+"strumRotateZP"+_data.strumLineID+",";
    if (data == "") return;
    ease(_data.time, _data.dur, _data.ease, data);
}

function set_moveStrumNote(_data:Dynamic) {
    var data = "";
    if (_data.x != null) data += _data.x+", _"+_data.strumLineID+"x"+_data.strumID+",";
    if (_data.y != null) data += _data.y+", _"+_data.strumLineID+"y"+_data.strumID+",";
    if (_data.z != null) data += _data.z+", _"+_data.strumLineID+"z"+_data.strumID+",";
    if (_data.a != null) data += _data.a+", _"+_data.strumLineID+"a"+_data.strumID+",";
    if (_data.angleX != null) data += _data.angleX+", _"+_data.strumID+"strumRotateXP"+_data.strumLineID+",";
    if (_data.angleY != null) data += _data.angleY+", _"+_data.strumID+"strumRotateYP"+_data.strumLineID+",";
    if (_data.angleZ != null) data += _data.angleZ+", _"+_data.strumID+"strumRotateZP"+_data.strumLineID+",";
    if (data == "") return;
    set(_data.time, data);
}

function ease_moveStrum(_data:Dynamic) {
    var data = "";
    if (_data.x != null) data += _data.x+", _"+_data.strumLineID+"x,";
    if (_data.y != null) data += _data.y+", _"+_data.strumLineID+"y,";
    if (_data.z != null) data += _data.z+", _"+_data.strumLineID+"z,";
    if (_data.a != null) data += _data.a+", _"+_data.strumLineID+"a,";
    if (_data.angleX != null) data += _data.angleX+", strumLineRotateXP"+_data.strumLineID+",";
    if (_data.angleY != null) data += _data.angleY+", strumLineRotateYP"+_data.strumLineID+",";
    if (_data.angleZ != null) data += _data.angleZ+", strumLineRotateZP"+_data.strumLineID+",";
    if (data == "") return;
    ease(_data.time, _data.dur, _data.ease, data);
}

function set_moveStrum(_data:Dynamic) {
    var data = "";
    if (_data.x != null) data += _data.x+", _"+_data.strumLineID+"x,";
    if (_data.y != null) data += _data.y+", _"+_data.strumLineID+"y,";
    if (_data.z != null) data += _data.z+", _"+_data.strumLineID+"z,";
    if (_data.a != null) data += _data.a+", _"+_data.strumLineID+"a,";
    if (_data.angleX != null) data += _data.angleX+", strumLineRotateXP"+_data.strumLineID+",";
    if (_data.angleY != null) data += _data.angleY+", strumLineRotateYP"+_data.strumLineID+",";
    if (_data.angleZ != null) data += _data.angleZ+", strumLineRotateZP"+_data.strumLineID+",";
    if (data == "") return;
    set(_data.time, data);
}

introLength = 0.0001; // basically instant start countdown
function onCountdown(event) {
    event.cancel();
}