
for (modLib in _loadedModAssetLibrary) {
    if (!modLib.exists("assets/data/states/OptionsMenu.hx", "TEXT")) continue;
    importScript("data/states/OptionsMenu");
}