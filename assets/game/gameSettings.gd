extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to user settings that persists between game 
#		instances and should not be used for save-game specific data. 

################################################################################

var game_keepClawForward : bool = true;
var game_toggleHoldClaw : bool = true;
var game_roomEntryRotation : bool = true;

################################################################################	

func getFileLocation() -> String:
	return "config.txt"

################################################################################	
