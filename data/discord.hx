//a
import funkin.backend.utils.DiscordUtil;
import StringTools;

function onPlayStateUpdate() {
    var songName:String = (PlayState.SONG.meta.displayName != null) ? PlayState.SONG.meta.displayName : PlayState.SONG.meta.name;
    
    if (_fromChallenges) PlayState.instance.detailsText = "Challenges: " + songName;

	DiscordUtil.changeSongPresence(
		"LJ Arcade - " + PlayState.instance.detailsText,
		(PlayState.instance.paused ? "Paused - " : "") + songName + " (" + PlayState.difficulty + ")",
		PlayState.instance.inst,
		PlayState.instance.getIconRPC()
	);
}