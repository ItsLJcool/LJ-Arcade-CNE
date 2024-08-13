//a
import funkin.backend.chart.Chart;
import flixel.math.FlxMath;
import Reflect;

importScript("GameJolt API/old gamejolt");

/**
    Internal Variables, changable so that mods can have even more difficulty levels if
**/
var _minDiff:Int = 1;
var _maxDiff:Int = 3; // changable in the future

var _maxHours:Int = 48;
var _minHours:Int = 1;
var _defualtHours:Int = 24;
public function new_challenge(name:String, ?diff:Int = 1, ?time_hours:Int = 0) {
    if (diff == null) diff = _minDiff;
    if (time_hours == null) time_hours = _defualtHours;
    // because classes are unstable until rev+428-55
    var obj = {
        _songName: null, // internal use
        name: name,
        diff: diff,
        time_hours: time_hours,
        extra: {},
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
    obj.setTimeLimit = function(time_hours:Int) {
        if (time_hours == null) {
            obj.time_hours = _defualtHours;
            return obj;
        }

        if (time_hours < _minHours) time_hours = _minHours;
        else if (time_hours > _maxHours) time_hours = _maxHours;

        obj.time_hours = time_hours;
        return obj;
    };
    obj.setSongName = function(songName:String) {
        if (songName == null) return obj;
        obj._songName = StringTools.replace(songName.toLowerCase(), " ", "-");
        return obj;
    };
    obj.setExtra = function(name:String, value:Dynamic) {
        if (value == null || name == null) return obj;
        Reflect.setField(obj.extra, name, value);
        return obj;
    };

    obj.__itself = function() {
        return new_challenge(obj.name, obj.diff, obj.time_hours);
    };

    // force update within bounds
    obj.setDiff(diff);
    obj.setName(name);
    obj.setTimeLimit(time_hours);

    return obj;
}

// higher = more chance for Global | Lower = more Specific
public static var global_amount_percent:Float = 50.0;

var global_Challenges:Array<Dynamic> = [
    /*  0 */ new_challenge("Beat ${song_name}"),
    /*  1 */ new_challenge("Hit 1/4th of all notes in ${song_name}"),
    /*  2 */ new_challenge("Hit Half of all notes in ${song_name}"),
    /*  3 */ new_challenge("Hit a minimum of ${rand_int(50, 100)} sicks in ${song_name}"),
    /*  4 */ new_challenge("Beat ${song_name} with ${rand_int(20, 25)}% chance of Posion Notes of spawning", 2),
    /*  5 */ new_challenge("Beat ${song_name} within ${rand_int(5, 20)} misses"),
    /*  6 */ new_challenge("Beat ${song_name} without ANY misses", 2),
    /*  7 */ new_challenge("Beat ${song_name} whilst the notes fade IN", 2),
    /*  8 */ new_challenge("Beat ${song_name} whilst the notes fade OUT", 2),
    /*  9 */ new_challenge("Beat ${song_name} without hitting a SINGLE Sick!", 3),
    /* 10 */ new_challenge("Beat ${song_name} without going past HALF health", 2),
    
    /* 11 */ new_challenge("Beat ${song_name} whilst gaining HALF of all notes health value", 2),
    /* 12 */ new_challenge("Beat ${song_name} with muffled audio AND visually impaired", 2),
    /* 13 */ new_challenge("Beat ${song_name} with strumlines split on Downscroll / Upscroll", 3),
];
/**
    ItsLJcool: % chance Dad notes can go to your strumline
    Frakits: you can also add mirrored mode which flips the strum order and makes it a pain to play

    Neo: Beat ${song_name} in dodge mode ( https://discord.com/channels/860561967383445535/1051235299419766854/1272868717453377547 )

    ItsLJcool: @Frakits#0234 what if you are given the notes in a list order and you have to memorize the measure of the notes before playing it 💀
**/
public function add_global_challenge(chall:Dynamic) {
    if (chall.length > 0)
        for (_chall in chall) global_Challenges.push(_chall);
    else 
        global_Challenges.push(chall);
}

/**
    Data format:
    [   // the `meta.name`, not `meta.displayName`
        "song_name" => [
            new_challenge();
        ]
    ]

    Its a map that contains the random challenges for each song
**/
var songSpecific_Challenges:Map<String, Array<Dynamic>> = [];
public function add_songSpecific_challenge(chall:Dynamic, song:String) {
    songSpecific_Challenges[song].push(chall);
}

var replace_strings:Array<String> = [
    "${song_name}", "${rand_int(", "${rand_float("
];

// TODO: Make it so a setting can toggle difficulty Challenges to be a specific difficulty array.
// So for example: if you want the easiest difficulty, its usually the first index of the array.
// so harder difficulties are the next index, and so on.

// for now it will use the hardest difficulty for that song (array.length-1 OR if it contains "hard" in the array)
function get_random_global(meta, ?exclude:Array<Int>) {
    if (exclude == null) exclude = [];

    var _random = FlxG.random.int(0, global_Challenges.length-1, exclude);
    var challenge = global_Challenges[_random].__itself();

    return set_challenge_data(challenge, meta, _random, "global");
}

function get_random_songSpecific(meta, ?exclude:Array<Int>) {
    if (meta == null) return null;
    if (exclude == null) exclude = [];
    
    var random_songChallenge = songSpecific_Challenges[meta.song];
    var _random = FlxG.random.int(0, random_songChallenge.length-1, exclude);
    var challenge = random_songChallenge[_random].__itself();

    return set_challenge_data(challenge, meta, _random, "songSpecific");
}

function set_challenge_data(challenge:Dynamic, meta:Dynamic, _random:Int, ?_type:String = "global") {
    if (_type == null) _type = "global";
    for (_replace in replace_strings) {
        if (!StringTools.contains(challenge.name, _replace)) continue;
        switch(_replace) {
            case replace_strings[0]:
                challenge.name = StringTools.replace(challenge.name, _replace, (meta.displayName == null) ? meta.name : meta.displayName);
            case replace_strings[1], replace_strings[2]:
                var getChars = challenge.name.split(_replace)[1];
                var min = getChars.split(",")[0];
                var max = StringTools.replace(getChars.split(",")[1], ")}", "");
                max = StringTools.replace(max, " ", "");

                var funcRandom = (replace_strings[2] == _replace) ? FlxG.random.float : FlxG.random.int;
                var random = funcRandom(Std.parseInt(min), Std.parseInt(max));
                random = FlxMath.roundDecimal(random, 2);
                challenge.setExtra("rand_int", random);

                challenge.name = StringTools.replace(challenge.name, (_replace+(getChars.split("}")[0]+"}")), Std.string(random));
        };
    }

    challenge.setSongName(meta.name);

    return {
        _challData: challenge,
        random: _random,
        type: _type,
        songName: meta.name,
    };
}

public function get_randomChallenge(meta, ?exclude:Array<Int>) {
    var _length:Int = 0;
    for (_key in songSpecific_Challenges.keys()) _length++;
    var percentReal = (_length == 0) ? 100 : global_amount_percent;
    return (FlxG.random.bool(percentReal)) ? get_random_global(meta, exclude) : get_random_songSpecific(meta, exclude);
}
var defualt_challenge:Dynamic = {
    isChallenge: false,
    getChallenge: function() { return null; },
    getChallengeID: function() { return null; },
    getModName: function() { return null; }
};
defualt_challenge.__reset = (itself) -> { itself = Reflect.copy(defualt_challenge); }
public static var ljarcade_challenge = Reflect.copy(defualt_challenge);