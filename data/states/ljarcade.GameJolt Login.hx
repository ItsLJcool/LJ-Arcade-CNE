//a
importScript("Temp GameJolt API/gamejolt test");
importScript("LJ Arcade API/LoadImageURL");

var userIcon:FlxSprite;
function create() {
    FlxG.camera.bgColor = 0xFF808080;
    var killme = GameJolt.get("users", [{name: "username", value: GameJolt.username}]);
    trace(killme.response.users[0].avatar_url);
    urlImage(killme.response.users[0].avatar_url, function(bitmap) {
        userIcon = new FlxSprite().loadGraphic(bitmap);
        userIcon.screenCenter();
        add(userIcon);
    });
}

function update(elapsed) {
    if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());
}
// { response => 
// { users =>
// [{ developer_name => ItsLJcool,
//     last_logged_in_timestamp => 1717967151, 
//     last_logged_in => 15 minutes ago, 
//     avatar_url => https://m.gjcdn.net/user-avatar/60/5874107-2dvg9hnh-v4.webp, 
//     status => Active, 
//     type => Developer, 
//     id => 5874107, 
//     signed_up_timestamp => 1630799253, 
//     developer_website => , 
//     username => ItsLJcool, 
//     signed_up => 2 years ago, 
//     developer_description => I am 15, I want to become a game maker :gj/innocent: }], 
//     success => true } 
// }