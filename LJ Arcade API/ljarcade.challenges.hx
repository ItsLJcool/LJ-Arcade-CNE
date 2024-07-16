//a
public static function new_challenge(name:String, ?diff:Int = 0) {
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
        obj.diff = diff;
        return obj;
    };

    return obj;
}

// higher = more chance for Specific | Lower = more Global
// 100% means no Global Challenges, 0% means all Speicific Songs
public static var randomPercentDiff:Float = 50.0;

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