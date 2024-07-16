//a

importScript("GameJolt API/API");

function create() {
    gamejolt_init();
}

function update() {
    if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());
}