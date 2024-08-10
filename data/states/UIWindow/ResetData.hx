//a
import funkin.editors.ui.UIState;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIUtil;
import funkin.editors.ui.UIScrollBar;
import Type;

importScript("LJ Arcade API/tokens");

var desync:UIText;

function new() {
    winWidth = FlxG.width / 1.5;
    winTitle = "Delete ALL Save Data?";
}

var titleHeight:Float = 32;
var desyncText:String = "YOU ARE ABOUT TO DELETE ALL SAVE DATA.\n"
+"This will reset your internal save, and delete your GameJolt save.\n"
+"Are you sure you want to continue?";

var closeButton:UIButton;
var deleteButton:UIButton;
function postCreate() {
    desync = new UIText(15, 15 + titleHeight, winWidth - 15, desyncText, 20, 0xFFFFFFFF, 0xFF000000);
    desync.alignment = "center";
    add(desync);
    
    deleteButton = new UIButton(0, 0, "Delete Save Data", deleteSaveData, 200, 150);
    deleteButton.x = (winWidth / 2) - (deleteButton.bWidth / 2);
    deleteButton.y = winHeight - deleteButton.bHeight - 50;
    deleteButton.field.size = 24;
    deleteButton.shouldPress = false;
    deleteButton.autoAlpha = false;
    add(deleteButton);

    deleteButton.field.alpha = 0.15;
    deleteButton.alpha = 0.15;
    FlxTween.tween(deleteButton.field, {alpha: 1}, 0.5, {startDelay: 1.5, ease: FlxEase.sineInOut, onComplete: function() {
        deleteButton.shouldPress = true;
    }});
    FlxTween.tween(deleteButton, {alpha: 1}, 0.5, {startDelay: 1.5, ease: FlxEase.sineInOut});
    
    closeButton = new UIButton(0, 0, "Close", function() {
        FlxG.state.closeSubState();
    }, 200, 150);
    closeButton.x = (winWidth / 2) - (closeButton.bWidth / 2);
    closeButton.y = winHeight - closeButton.bHeight - 50;
    closeButton.field.size = 24;
    closeButton.autoAlpha = false;
    add(closeButton);
    
    deleteButton.x -= ((closeButton.bWidth + 150) * 0.5);
    closeButton.x += ((deleteButton.bWidth + 150) * 0.5);
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ESCAPE && closeButton.shouldPress) FlxG.state.closeSubState();
}

function deleteSaveData() {
    closeButton.shouldPress = false;
    FlxTween.tween(closeButton, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut, onComplete: function() {
        remove(closeButton);
    }});
    FlxTween.tween(closeButton.field, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut});
    deleteButton.field.text = "Deleting Save Data...";
    FlxTween.tween(deleteButton, {x: (winWidth / 2) - (deleteButton.bWidth / 2)}, 1, {ease: FlxEase.sineInOut, onComplete: function() {
        _resettingData();
        FlxG.state.closeSubState();
    }});
}

function _resettingData() {
    var pog = GameJolt.getUser_KeySave();
    if (pog != null && pog.length > 0) for (data in pog.keys) GameJolt.removeUser_Save(data.key);
    _resetData();
}