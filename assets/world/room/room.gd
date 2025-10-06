extends Area2D
class_name Room;


var rect : Rect2 = Rect2(0, 0, 0, 0);
func _ready() -> void:
	for child in get_children():
		var shape := child as CollisionShape2D;
		if (shape == null): continue;
		var shapeRect := shape.shape as RectangleShape2D;
		if (shapeRect == null): continue;
		rect = shapeRect.get_rect();
		rect.position += shape.global_position;
		break;

var hasPlayer := 0.0;
func _physics_process(delta: float) -> void:
	var hasEnemies := false;
	for entity in entities:
		var contained := containsPoint(entity.global_position);
		if (contained):
			if (entity as Enemy != null):
				hasEnemies = true;
			elif (entity as Player != null):
				hasPlayer += delta;
			
		if (!contained || entity.room_current == self): 
			continue;
		
		entity.room_current = self;
		entity.onRoomChanged.emit();

	if (hasPlayer > 0.2 && !hasEnemies):
		for door in doors:
			door.queue_free();

func containsPoint(point : Vector2) -> bool:
	return rect.has_point(point);

func clampCamera(center : Vector2, camera : Camera2D, defaultZoom : float = 2.0) -> void:
	if (camera == null): return;
	camera.zoom = Vector2.ONE * defaultZoom;
	var cameraRect = get_viewport().get_visible_rect()
	cameraRect.size /= camera.zoom;
	
	# Re-zoom.
	if (rect.size.x < cameraRect.size.x || rect.size.y < cameraRect.size.y):
		var newZoom : float = max(cameraRect.size.x / rect.size.x, cameraRect.size.y / rect.size.y);
		camera.zoom *= newZoom;
		#cameraRect = camera.get_viewport_rect() / newZoom;
		cameraRect = get_viewport().get_visible_rect()
		cameraRect.size /= camera.zoom;
	
	var growSize : Vector2 = cameraRect.size * -0.5;
	var space = rect.grow_individual(growSize.x, growSize.y, growSize.x, growSize.y);
	camera.global_position.x = clamp(center.x, space.position.x, space.position.x + space.size.x);
	camera.global_position.y = clamp(center.y, space.position.y, space.position.y + space.size.y);


var entities : Array[Entity] = [];
var doors : Array[Door] = [];
func _on_body_entered(body: Node2D) -> void:
	var entity := body as Entity;
	if (entity != null): entities.push_back(entity);
	var door := body as Door;
	if (door != null && containsPoint(door.global_position)): doors.push_back(door);
	
func _on_body_exited(body: Node2D) -> void:
	var entity := body as Entity;
	if (entity != null): entities.erase(entity);
	var door := body as Door;
	if (door != null): doors.erase(door);
