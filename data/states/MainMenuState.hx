//a

function update(elapsed) {
    if (FlxG.keys.justPressed.L) FlxG.switchState(new ModState("ModMainMenu"));
    if (FlxG.keys.justPressed.P) FlxG.switchState(new ModState("GameJolt Login"));
}