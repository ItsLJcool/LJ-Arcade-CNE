//a

function onSongEnd() {
    switchTo_Ratings = true;
    ratings_data.difficulty = PlayState.instance.difficulty;

    ratings_data.comboRatings = (comboRatings == null || comboRatings.length == 0) ? [
        new ComboRating(0, "F", 0xFFFF4444),
        new ComboRating(0.5, "E", 0xFFFF8844),
        new ComboRating(0.7, "D", 0xFFFFAA44),
        new ComboRating(0.8, "C", 0xFFFFFF44),
        new ComboRating(0.85, "B", 0xFFAAFF44),
        new ComboRating(0.9, "A", 0xFF88FF44),
        new ComboRating(0.95, "S", 0xFF44FFFF),
        new ComboRating(1, "S++", 0xFF44FFFF)
    ] : comboRatings;

    _notesRatingHit.set("misses", (misses == null) ? 0 : misses);

    if (ratings_data.songsData == null) ratings_data.songsData = [];
    ratings_data.songsData.push({
        songScore: (songScore == null) ? 0 : songScore,
        lastRating: (curRating == null) ? "F" : curRating.rating,
        accuracy: (accuracy == null) ? 0 : accuracy,
        instLength: _instLength,
        storyPlaylist: (PlayState.instance.storyPlaylist == null) ? [] : PlayState.instance.storyPlaylist,
        isStoryMode: (PlayState.instance.isStoryMode == null) ? false : PlayState.instance.isStoryMode,
        deathCounter: (PlayState.instance.deathCounter == null) ? 0 : PlayState.instance.deathCounter,
        scrollSpeed: _initalScrollSpeed,
        notes_rating_hit: _notesRatingHit,
    });
}

var _notesRatingHit:Map<String, Int> = [
    "sick" => 0,
    "good" => 0,
    "bad" => 0,
    "shit" => 0,
    "misses" => 0,
];

var _initalScrollSpeed:Float = 0;
var _instLength:Float = 0;
function postCreate() {
    _instLength = inst.length*0.001; // into seconds
    _initalScrollSpeed = scrollSpeed;
}

var _curComboHits:Int = 0;
function onRatingUpdate(event) {
    if (ratings_data.extraXP == null) ratings_data.extraXP = 0;
    if (combo % 100 == 0 && combo != 0)
        ratings_data.extraXP += 10; // congrats! You earn extra XP.
}

var useBotplayLol:Bool = false;
function update(elapsed) {

    if (FlxG.keys.justPressed.L) onSongEnd();

    if (usingBotplay) return;
    
    // if (canAccessDebugMenus || !validScore) usingBotplay = true; // for testing rn, disabled the `canAccessDebugMenus` check
    if (!validScore) usingBotplay = true; // like setting cheating to true ig

    var cpuStrums:Int = 0;
    var playerStrums:Int = 0;
    for (strum in strumLines.members) {
        if (!strum.cpu) playerStrums++;
        else cpuStrums++;
    }

    if (cpuStrums == strumLines.members.length) usingBotplay = true;
}

function new() {
    usingBotplay = false;
}

function onPlayerHit(event) {
    if (usingBotplay) return;
    var daNote = event.note;
    usingBotplay = !(daNote.strumLine.__pressed[daNote.noteData]);

    var _rating:String = event.rating.toLowerCase();
    
    if (!_notesRatingHit.exists(_rating)) _notesRatingHit.set(_rating, 1);
    _notesRatingHit.set(_rating, _notesRatingHit.get(_rating) + 1);
}