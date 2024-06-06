//a

function create() {
    
}

function update(elapsed) {
    if (FlxG.keys.justPressed.L) FlxG.switchState(new MainMenuState());
}