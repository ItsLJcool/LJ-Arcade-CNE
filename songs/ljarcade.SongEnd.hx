//a

function onSongEnd() {
    trace("onSongEnd");
    switchTo_Ratings = true;
    _lastRating = curRating.rating;
}

function onRatingUpdate(event) {
    _lastRating = event.rating.rating;
}

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