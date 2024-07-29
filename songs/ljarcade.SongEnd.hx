//a

function onSongEnd() {
    trace("onSongEnd");
    switchTo_Ratings = true;
    ratings_data.lastRating = (curRating == null) ? "F" : curRating.rating;
    ratings_data.score += songScore;
    ratings_data.comboRatings = comboRatings;
}

function postCreate() {
    ratings_data.songLength = inst.length*0.001;
}

var _curComboHits:Int = 0;
function onRatingUpdate(event) {
    ratings_data.lastRating = event.rating.rating;

    if (combo % 100 == 0 && combo != 0)
        ratings_data.extraXP += 10;
}

var useBotplayLol:Bool = false;
function update(elapsed) {

    if (usingBotplay) return;

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
    onSongEnd();
}

function onPlayerHit(event) {
    if (usingBotplay) return;
    var daNote = event.note;

    usingBotplay = !(daNote.strumLine.__pressed[daNote.noteData]);
}