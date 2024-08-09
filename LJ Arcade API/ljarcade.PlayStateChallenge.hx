//a
import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;

importScript("LJ Arcade API/challenges");
importScript("LJ Arcade API/_challengeGameJolt");

var _challengeCompleted:Bool = false;
function destroy() {
    if (!_challengeCompleted || paused) return;
    remove_challenge(ljarcade_challenge.getChallengeID(), ljarcade_challenge.getModName());
}
public function complete_challenge() {
    _challengeCompleted = true;
}

// listing out ideas
// basically for this you can show the progress with maybe like a bar that pops up when you call this function.
public var _minProgress:Int = 0;
public var _maxProgress:Int = 1;
var _progressData = {
    progress: 0,
};

public var progress:Int = 0;

public function progress_challenge_display() {
    if (_progressData.progress >= _maxProgress) return;
    FlxTween.tween(progressBar, {x: FlxG.width - progressBar.width}, 0.5, {ease: FlxEase.backOut});
    FlxTween.tween(_progressData, {progress: progress}, 0.5, {startDelay: 1, ease: FlxEase.quadInOut});
    FlxTween.tween(progressBar, {x: FlxG.width + progressBar.width + 5}, 0.5, {startDelay: 4, ease: FlxEase.backIn});
}

var camChallenge:FlxCamera;

var progressBar:FlxBar;
function postCreate() {
    camChallenge = new FlxCamera();
    camChallenge.bgColor = 0;
    FlxG.cameras.add(camChallenge, false);

    progressBar = new FlxBar(0,0, FlxBarFillDirection.LEFT_TO_RIGHT, 250, 25, _progressData,
    'progress', _minProgress, _maxProgress);
    progressBar.cameras = [camChallenge];
    progressBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
    progressBar.updateBar();
    add(progressBar);
    progressBar.x = FlxG.width + progressBar.width + 5;
    progressBar.y = FlxG.height * 0.5 - progressBar.height * 0.5;
}