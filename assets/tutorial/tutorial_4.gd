extends Label

@export var startRoom : Room = null;
@export var deleteList : Array[Node] = [];

func _ready() -> void:
	visible = false;
	call_deferred("setup");
	
func setup():
	Player.instance.onPartJoin.connect(func(_part):
		visible = true;
		for node in deleteList:
			node.queue_free();
		deleteList.clear();
	);
	Player.instance.onRoomChanged.connect(func(): 
		if (startRoom == null):
			startRoom = Player.instance.room_current;
			return;
		if (Player.instance.room_current == startRoom): 
			return;
		for node in deleteList:
			node.queue_free();
		deleteList.clear();
		queue_free());
