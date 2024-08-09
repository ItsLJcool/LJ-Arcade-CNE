//a
importScript("LJ Arcade API/ljarcade.PlayStateChallenge");
static var _isChallenge:Bool = (_fromChallenges == null) ? false : _fromChallenges;
function onSongEnd() {
    var challenge = ljarcade_challenge.getChallenge();
    trace(challenge);
    if (challenge.type != "global") return;
    switch(challenge.random) {
        case 0:
            complete_challenge();
            return;
    }
}

function create() {
    var challenge = ljarcade_challenge.getChallenge();
    trace(challenge);
}

function update(elapsed) {
    if (FlxG.keys.justPressed.K) 
        complete_challenge();
}
