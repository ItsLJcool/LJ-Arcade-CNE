//a

/**
    Internal Variables, changable so that mods can have even more difficulty levels if
**/
var _minDiff:Int = 1;
var _maxDiff:Int = 3; // changable in the future
public function new_challenge(name:String, ?diff:Int = 1) {
    if (diff == null) diff = 1;
    // because classes are unstable until rev+428-55
    var obj = {
        name: name,
        diff: diff
    };

    // functions
    obj.setName = function(name:String) {
        if (name == null) return obj;
        obj.name = name;
        return obj;
    };
    obj.setDiff = function(diff:Int) {
        if (diff == null) return obj;

        if (diff < _minDiff) diff = _minDiff;
        else if (diff > _maxDiff) diff = _maxDiff;

        obj.diff = diff;
        return obj;
    };

    obj.setDiff(obj.diff); // force update within bounds

    return obj;
}

// higher = more chance for Global | Lower = more Specific
public static var global_amount_percent:Float = 50.0;

public static var global_Challenges:Map<Int, Dynamic> = [
    0 => new_challenge("placeholder"),
];

/**
    Data format:
    [
        "song_name" => [
            0 => new_challenge();
        ]
    ]

    Its a map in a map basically
**/
public static var songSpecific_Challenges:Map<String, Map<Int, Dynamic>> = [
    //
];

var replace_strings:Array<String> = [
    "${song_name}", 
];

function get_random_global(songName:String, ?exclude:Array<Int>) {
    if (exclude == null) exclude = [];
    var _length = 0;
    for (key in global_Challenges.keys()) _length++;
    var _random = FlxG.random.int(0, _length, exclude);
    var challenge = global_Challenges[_random];

    for (_replace in replace_strings) {
        challenge = switch(_replace) {
            case replace_strings[0]: StringTools.replace(challenge, _replace, songName);
            default: challenge;
        };
    }

    return {challenge: challenge, _random: _random};

}

function get_random_songSpecific(songName:String, ?exclude:Array<Int>) {
    if (exclude == null) exclude = [];
    var _length = 0;
    for (key in songSpecific_Challenges.keys()) _length++;
    var _random = FlxG.random.int(0, _length, exclude);
    var challenge = songSpecific_Challenges[songName][_random];

    for (_replace in replace_strings)
        challenge = StringTools.replace(challenge, _replace, songName);

    return {challenge: challenge, _random: _random};
}