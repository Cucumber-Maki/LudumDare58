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

func _physics_process(_delta: float) -> void:
	if (m_player == null): return;
	if (containsPoint(m_player.global_position)):
		if (m_player.room_current == self): return;
		m_player.room_current = self;
		m_player.roomChanged.emit(self);

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


var m_player : Player = null;
func _on_body_entered(body: Node2D) -> void:
	var player := body as Player;
	if (player == null): return;
	m_player = player;
func _on_body_exited(body: Node2D) -> void:
	var player := body as Player;
	if (player == null || m_player != player): return;
	m_player = null;
