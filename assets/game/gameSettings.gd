extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to user settings that persists between game 
#		instances and should not be used for save-game specific data. 

################################################################################

var game_keepClawForward : bool = true;
var game_toggleHoldClaw : bool = false;

var volume_master : float = 0.1;
var volume_effect : float = 0.5;
var volume_music : float = 0.5;

################################################################################	

func getFileLocation() -> String:
	return "config.txt"

################################################################################	
