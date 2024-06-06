//a

var fade:FlxSprite;
var cam:FlxCamera;
function create() {
    cam = new FlxCamera();
    cam.bgColor = 0;
    FlxG.cameras.add(cam, false);
    
    fade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x80000000);
    fade.screenCenter();
    fade.alpha = 0.0001;
    add(fade);

    intro();
}

function update(elapsed) {
    if (FlxG.keys.justPressed.F4) _close();
}

function _close() {
    FlxTween.tween(fade, {alpha: 0}, 1, {ease: FlxEase.quadInOut, onComplete: close});
}

function intro() {
    FlxTween.tween(fade, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
}

function add(object) {
    object.cameras = [cam];
    this.add(object);
}