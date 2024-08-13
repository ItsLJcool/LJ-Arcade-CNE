//a
import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;
import flixel.math.FlxRect;

import Type;
import Reflect;

importScript("LJ Arcade API/challenges");
importScript("LJ Arcade API/_challengeGameJolt");

public var _isChallenge:Bool = (_fromChallenges == null) ? false : _fromChallenges;

var _challengeCompleted:Bool = false;
function destroy() {
    if (!_challengeCompleted || paused || usingBotplay) return;
    remove_challenge(ljarcade_challenge.getChallengeID(), ljarcade_challenge.getModName());
}
public function complete_challenge() {
    _challengeCompleted = true;
}

// listing out ideas
// basically for this you can show the progress with maybe like a bar that pops up when you call this function.
public var _minProgress:Int = 0;
public var _maxProgress:Int = 1;

var _progress_value:Int = 0; // Internal use

public var progress:Int = 0;

var _doingProgress:Bool = false;
public function progress_challenge_display(?autoComplete:Bool = true) { if (autoComplete == null) autoComplete = true;
    if (_challengeCompleted || _doingProgress) return;
    if (progress >= _maxProgress) {
        if (autoComplete) complete_challenge();
    }
    _progress_value = progress;
    _doingProgress = true;

    var math = (progressBar.frameWidth * (_progress_value / _maxProgress)) - 33;
    FlxTween.tween(progressBar.clipRect, {width: math}, 0.5, {startDelay: 1, ease: FlxEase.quadInOut, onComplete: function() {
        if (
            (autoComplete && _challengeCompleted) ||
            (_progress_value >= _maxProgress)
        ) bloomaMount = 0.3;
    }});
    
    FlxTween.tween(progressBarBG, {x: FlxG.width - progressBarBG.width + 9}, 0.5, {ease: FlxEase.quadOut});
    FlxTween.tween(progressBarBG, {x: FlxG.width + progressBarBG.width + 5}, 0.5, {startDelay: 4, ease: FlxEase.quadIn});

    new FlxTimer().start(4, function() { _doingProgress = false; });
}

var _challengeData = ljarcade_challenge.getChallenge();
public function check_challenge_data(func) {
    if (!_isChallenge || !Reflect.isFunction(func)) return;

    func((_challengeData.type == "global"), _challengeData.random, _challengeData);
} 

var camChallenge:FlxCamera;

var progressBar:FlxSprite;
var progressBarBG:FlxSprite;
function postCreate() {
    doProgressBarInit();
}

var bloom:CustomShader = new CustomShader("ljarcade.bloom");
bloom.Size = 3;
function doProgressBarInit() {
    camChallenge = new FlxCamera();
    camChallenge.bgColor = 0;
    FlxG.cameras.add(camChallenge, false);
    camChallenge.addShader(bloom);

    progressBarBG = new FlxSprite().loadGraphic(Paths.image("Challenges/progressBarBG"));
    progressBarBG.cameras = [camChallenge];
    progressBarBG.setGraphicSize(Std.int(progressBarBG.width * 1.5));
    progressBarBG.updateHitbox();
    add(progressBarBG);
    progressBarBG.x = FlxG.width + progressBarBG.width + 5;
    progressBarBG.y = FlxG.height - progressBarBG.height * 1.25;
    // progressBarBG.screenCenter();

    progressBar = new FlxSprite();
    progressBar.frames = Paths.getSparrowAtlas("Challenges/progressBar");
    progressBar.animation.addByPrefix("barFillLoop", "barFillLoop0", 36, true);
    progressBar.animation.play("barFillLoop", true);
    progressBar.cameras = [camChallenge];
    progressBar.setGraphicSize(progressBarBG.width);
    progressBar.updateHitbox();
    progressBar.clipRect = new FlxRect(25, 0, 0, progressBar.height);
    progressBar.antialiasing = true;
    add(progressBar);

    progressBarBG.onDraw = function(sprite:FlxSprite) {
        sprite.draw();
        progressBar.setPosition(sprite.x + 1, sprite.y);
    };
}

var bloomaMount = 0.9; // stolen from YTP lmao // why is the 0.9 the proper value???
function update(elapsed) {
    bloomaMount = FlxMath.lerp(bloomaMount, 0.9, elapsed*0.75);
    bloom.dim = bloomaMount;

    if (FlxG.keys.justPressed.P && _isChallenge) {
        FlxG.sound.music.time += 1*1000;
        resyncVocals();
    }
}