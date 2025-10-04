extends OptionMenuBase;

func _ready() -> void:	
	super();

	addCategory("Game Paused");
	addButton("Resume", func(): onMenuExit.emit());
	addButton("Settings", func(): onMenuEnter.emit("SettingsMenu"));
	if (GameState.inDebugMode):
		addButton("Debug", func(): onMenuEnter.emit("DebugMenu"));

	addButton("Exit to Menu", func(): GameState.exitToMenu());
