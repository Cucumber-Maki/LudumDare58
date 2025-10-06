extends Label

@export var deleteList : Array[Node] = [];
var startRoom : Room = null;

func _ready() -> void:
	visible = false;
	call_deferred("setup");
	
func setup():
	Player.instance.onPartJoin.connect(func(_part):
		visible = true;
		for node in deleteList:
			node.queue_free();
	);
	Player.instance.onRoomChanged.connect(func(): 
		if (startRoom == null):
			startRoom = Player.instance.room_current;
			return;
		if (Player.instance.room_current == startRoom): 
			return;
		queue_free());
