//a
import flixel.group.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxTextBorderStyle;
import flixel.FlxSprite;
import Date;
import Type;
import funkin.backend.chart.Chart;
import haxe.Json;

importScript("LJ Arcade API/challenges");
importScript("LJ Arcade API/_challengeGameJolt");

var challengeShit:FlxTypedSpriteGroup;
var challengeItemGroup = new FlxTypedSpriteGroup();
var challengeBG:FlxSprite;
var slider:FlxSprite;
var challengesName:FlxSprite;

var maxChallenges:Int = max_challenges;

var _challenges:Array<Dynamic> = [];
function new() {
    // __resetChallengeSave(modName);
    _initChallengeSave(modName);
}
function menuShit() {

    challengeShit = new FlxTypedSpriteGroup();
    add(challengeShit);
    
    challengeBG = new FlxSprite().loadGraphic(Paths.image("Challenges/bg"));
    challengeBG.scale.set(0.9, 0.9);
    challengeBG.updateHitbox();
    challengeShit.add(challengeBG);

    challengeItemGroup = new FlxTypedSpriteGroup();
    challengeShit.add(challengeItemGroup);

    var all_challenges = get_all_challenges(modName);
    var _dateNow = Date.now().getTime();
    for (idx in 0...all_challenges.length) {
        var data = all_challenges[idx];
        var needs_newChallengeData = (data.challenge_data.__init == null) ? false : !(data.challenge_data.__init);
        if (needs_newChallengeData) continue;
        for (song in songs) {
            if (song.name.toLowerCase() != data.challenge_data.songName.toLowerCase()) continue;
            _pickedChallenges[idx] = songs.indexOf(song);
            break;
        }
    }
    for (idx in 0...all_challenges.length) {
        var data = all_challenges[idx];
        var needs_newChallengeData = (data.challenge_data.__init == null) ? false : !(data.challenge_data.__init);
        update_challengeData((idx+1), _dateNow, needs_newChallengeData);
    }

    challengesName = new FlxSprite().loadGraphic(Paths.image("Challenges/name"));
    challengesName.scale.set(0.9, 0.9);
    challengesName.updateHitbox();
    challengesName.x = challengeBG.x + challengeBG.width * 0.5 - challengesName.width * 0.5 + 25;
    challengesName.y = challengeBG.y + challengesName.height * 0.5 - 25;
    challengeShit.add(challengesName);

    slider = new FlxSprite().loadGraphic(Paths.image("Challenges/slider"));
    slider.scale.set(0.9, 0.9);
    slider.updateHitbox();
    slider.x = challengeBG.x - slider.width * 0.5 + 15;
    slider.y = challengeBG.y + challengeBG.height * 0.5 - slider.height * 0.5 + 65;
    challengeShit.add(slider);
    
    challengeShit.x = FlxG.width + challengeShit.width + 5;
    challengeBG.y += 75;

    if (currentState == 2) beginMenuAnimation();
}

var _pickedChallenges:Array<Int> = [];
function update_challengeData(id:Int, dateNow:Int, new_challenge:Bool = false) {
    var idx = (id-1);
    var randomMetaSong = null;
    var challengeData = null;
    if (new_challenge) {
        if (_pickedChallenges.length == maxChallenges) _pickedChallenges = [];
        var rndm = FlxG.random.int(0, songs.length-1, _pickedChallenges);
        _pickedChallenges[idx] = rndm;
        randomMetaSong = songs[rndm];
        // todo: difficulty showcase
        challengeData = get_randomChallenge(randomMetaSong, []);

        _challenges[idx] = {
            chall: challengeData,
            meta: randomMetaSong,
        };
        set_newChallenge(id, dateNow);
    } else {
        challengeData = get_challenge(id, modName).challenge_data;
        randomMetaSong = Chart.loadChartMeta(challengeData.songName, "normal", true);
        _challenges[idx] = {
            chall: challengeData,
            meta: randomMetaSong,
        };
    }
    // better than just deleting and redoing the whole thing, could cause people with SHIT pcs to die
    var __challenge = challengeItemGroup.members[idx];
    if (__challenge != null) {
        var bgSprite = __challenge.members[0];
        var text = __challenge.members[1];
        var timeSpr = __challenge.members[2];
        var icon = __challenge.members[3];
        var playSpr = __challenge.members[4];
        
        icon.setIcon(randomMetaSong.icon);
        icon.scale.set(0.75, 0.75);
        icon.updateHitbox();
        if (randomMetaSong.icon == "face" || !Assets.exists(Paths.image("icons/"+randomMetaSong.icon))) {
            icon.offset.x = 20;
            icon.offset.y -= 2;
        }
        
        text.text = challengeData._challData.name;
        
        text.x = icon.x + icon.width + 5;
        text.y = bgSprite.y + bgSprite.height * 0.5 - text.height * 0.5;
        text.updateHitbox();
        return;
    }
    
    var _challenge = new FlxTypedSpriteGroup();
    challengeItemGroup.insert(idx, _challenge);

    var bgSprite = new FlxSprite().loadGraphic(Paths.image("Challenges/button"));
    bgSprite.scale.set(0.9, 0.9);
    bgSprite.updateHitbox();
    bgSprite.ID = 1;
    _challenge.add(bgSprite);

    var text = new FlxText(0, 0, 0, challengeData._challData.name);
    text.setFormat(text.font, 24, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
    text.borderSize = 2;
    text.shadowOffset.x = 1;
    text.shadowOffset.y = 1.5;
    text.ID = 1;
    _challenge.add(text);

    // TODO: showcase how long the challenge has until it dies
    var timeSpr = new FlxSprite().loadGraphic(Paths.image("Challenges/clockIcon"));
    timeSpr.setGraphicSize(Std.int(timeSpr.width * 0.1));
    timeSpr.updateHitbox();
    timeSpr.ID = 2;
    _challenge.add(timeSpr);
    timeSpr.x += 25;
    timeSpr.y = bgSprite.y + bgSprite.height * 0.5 - timeSpr.height * 0.5;

    var icon = new HealthIcon(randomMetaSong.icon);
    icon.x += 50; icon.y += 25;
    icon.scale.set(0.75, 0.75);
    icon.updateHitbox();
    icon.ID = 1;
    if (randomMetaSong.icon == "face" || !Assets.exists(Paths.image("icons/"+randomMetaSong.icon))) {
        icon.offset.x = 20;
        icon.offset.y -= 2;
    }
    _challenge.add(icon);

    var playSpr = new FlxSprite().loadGraphic(Paths.image("Challenges/play"));
    playSpr.scale.set(0.65, 0.65);
    playSpr.updateHitbox();
    playSpr.x = bgSprite.x + bgSprite.width - playSpr.width;
    playSpr.y = bgSprite.y + bgSprite.height - playSpr.height;
    playSpr.y -= 5;
    playSpr.ID = -idx;
    playSpr.alpha = 0.5;
    _challenge.add(playSpr);

    text.fieldWidth = bgSprite.width - icon.x - icon.width - playSpr.width;
    text.x = icon.x + icon.width + 5;
    text.y = bgSprite.y + bgSprite.height * 0.5 - text.height * 0.5;
    text.updateHitbox();

    _challenge.x = challengeBG.x + challengeBG.width - _challenge.width;
    _challenge.y = (challengeBG.y + 150) + (_challenge.height + 15) * (idx);
}

function update(elapsed) {
    if (challengeMenu) {
        updateChallenges(elapsed);
    }
    else if (slider.alpha != 1) slider.alpha = FlxMath.lerp(slider.alpha, 1, elapsed*10);

    if (FlxG.keys.justPressed.I) {
        var _dateNow = Date.now().getTime();
        for (i in 0...maxChallenges) {
            update_challengeData((i+1), _dateNow, true);
        }
    }
}

function updateChallenges(elapsed) {
    if (FlxG.mouse.overlaps(slider)) {
        slider.alpha = FlxMath.lerp(slider.alpha, 0.65, elapsed*10);
        if (FlxG.mouse.justReleased) toMainMenu();
    } else slider.alpha = FlxMath.lerp(slider.alpha, 1, elapsed*10);

    challengeShit.forEach(function(challengeGroup) {
        if (!(challengeGroup is FlxTypedSpriteGroup)) return;
        challengeGroup.forEach(function(challenge) {
            challenge.forEach(function(spr) {
                if (spr.ID > 0 || selectedChallenge) return;
                spr.alpha = FlxMath.lerp(spr.alpha, (challengeSel == -spr.ID) ? 1 : 0.5, elapsed*10);
                if (FlxG.mouse.overlaps(spr)) {
                    challengeSel = -spr.ID;
                    changeChallengeSel(0);
                    if (FlxG.mouse.justReleased) onSelectChallenge();
                }
            }); });
    });
}

var challengeSel:Int = 0;
function changeChallengeSel(hur:Int = 0) {
    if (selectedChallenge) return;
    challengeSel += hur;
    if (challengeSel >= _challenges.length) challengeSel = 0;
    if (challengeSel < 0) challengeSel = _challenges.length-1;
}

var selectedChallenge:Bool = false;
function onSelectChallenge() {
    if (selectedChallenge) return;
    usingBotplay = false;
    selectedChallenge = true;
    var challenge = _challenges[challengeSel];
    ljarcade_challenge.isChallenge = true;
    ljarcade_challenge.getChallenge = function() {
        return challenge.chall;
    };
    ljarcade_challenge.getChallengeID = function() {
        return (challengeSel+1);
    };
    ljarcade_challenge.getModName = function() {
        return modName;
    };
    
    var meta = challenge.meta;
    var containsHard = false;
    for (diff in meta.difficulties) if (diff.toLowerCase() == "hard") { containsHard = true; break; }
    var diff = (containsHard) ? "hard" : meta.difficulties[meta.difficulties.length-1];
    _fromChallenges = true;
    loadAndPlaySong(meta.name, diff);
}

public var challengeMenu:Bool = false;
function beginMenuAnimation() {
    if (selectableNames[curSel].toLowerCase() != "challenges" && currentState != 2) return;

    var time = (currentState == 2) ? 0.001 : 1.75;
    var start = (currentState == 2) ? 0 : 0.5;
    FlxTween.tween(challengeShit, {x: FlxG.width - challengeBG.width}, time, {startDelay: start, ease: FlxEase.sineOut,
    onComplete: function() { challengeMenu = true; }});
}

function toMainMenu() {
    if (!challengeMenu) return;
    challengeMenu = false;
    if (selectableNames[curSel].toLowerCase() != "challenges" && currentState != 2) return;
    FlxTween.tween(challengeShit, {x: FlxG.width + challengeBG.width + 5}, 0.75, {ease: FlxEase.sineIn,
    onComplete: function() {
        menuTween();
    }});
}

// 1, 2, 3. index+1 basically
function set_newChallenge(id:Int, dateNow:Int) {
    if (_challenges == null || _challenges.length == 0) return false;
    var data = _challenges[(id-1)];
    var _futureData = get_future_date(dateNow, data.chall._challData.time_hours);
    
    var stringed = Json.stringify(data.chall);
    var noFunctions = Json.parse(stringed);
    set_challenge(id, modName, _futureData, noFunctions);
    return true;
}