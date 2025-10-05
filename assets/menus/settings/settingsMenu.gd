extends OptionMenuBase;

func getTargetSaveable() -> GameSaveableBase:
	return GameSettings;

func _ready() -> void:	
	super();

	addCategory("Settings");

	addTab("Game");
	addCategory("Claw");
	addOption(OptionType.CheckBox, "Keep Claw Foward", "game_keepClawForward");
	addOption(OptionType.CheckBox, "Hold Claw (Instead of Toggle)", "game_toggleHoldClaw");

	addTab("Audio");
	addCategory("Volume");
	addOption(OptionType.Slider, "Master Volume", "volume_master", { "min_value": 0.0, "max_value": 1.0, "step": 0.025 });
	addOption(OptionType.Slider, "Effect Volume", "volume_effect", { "min_value": 0.0, "max_value": 1.0, "step": 0.025 });
	addOption(OptionType.Slider, "Music Volume", "volume_music", { "min_value": 0.0, "max_value": 1.0, "step": 0.025 });
	
	endTab();
	addButton("Save & Exit", func(): onMenuExit.emit());
