//a

for (modLib in _loadedModAssetLibrary) {
    if (!modLib.exists("assets/data/states/PlayState.hx", "TEXT")) continue;
    importScript("data/states/PlayState");
}