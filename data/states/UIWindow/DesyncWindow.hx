//a
import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIUtil;
import funkin.editors.ui.UIScrollBar;

importScript("LJ Arcade API/tokens");

var desync:UIText;

function new() {
    winWidth = FlxG.width / 1.5;
    winTitle = "GameJolt Desynced!";
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ESCAPE) FlxG.state.closeSubState();
}

var interal_saves = [
    "Token" => FlxG.save.data.lj_tokens,
    "XP" => FlxG.save.data.lj_xp,
    "Rank" => FlxG.save.data.lj_rank,
];

var gj_saves = [
    "Token" => _gj_tokens,
    "XP" => _gj_xp,
    "Rank" => _gj_rank,
];

var titleHeight:Float = 32;
var desyncText:String = "It looks like your internal save's have desynced from your GameJolt save."
+"\nWhat save would you like to continue with?";
function postCreate() {
    desync = new UIText(15, 15 + titleHeight, winWidth - 15, desyncText, 20, 0xFFFFFFFF, 0xFF000000);
    desync.alignment = "center";
    add(desync);
    
    var internal_text = "Internal Save:\n";
    for (save in interal_saves.keys())
        internal_text += save + ": " + interal_saves[save]+"\n";

    internalSave = new UIButton(0, 0, internal_text, internalSave, (winWidth / 2) - 25, winHeight - 150);
    internalSave.x = 0;
    internalSave.y = winHeight - internalSave.bHeight;
    internalSave.field.size = 24;
    add(internalSave);
    
    var gj_text = "GameJolt Save:\n";
    for (save in gj_saves.keys())
        gj_text += save + ": " + gj_saves[save]+"\n";

    internalSave = new UIButton(0, 0, gj_text, gjSave, (winWidth / 2) - 25, winHeight - 150);
    internalSave.x = winWidth - internalSave.bWidth;
    internalSave.y = winHeight - internalSave.bHeight;
    internalSave.field.size = 24;
    add(internalSave);
}

function internalSave() {
    set_tokens(FlxG.save.data.lj_tokens);
    set_xp(FlxG.save.data.lj_xp);
    set_rank(FlxG.save.data.lj_rank);
    
    FlxG.state.closeSubState();
}

function gjSave() {
    set_tokens(_gj_tokens);
    set_xp(_gj_xp);
    set_rank(_gj_rank);

    FlxG.state.closeSubState();
}