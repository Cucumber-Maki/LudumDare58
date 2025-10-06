extends RigidBody2D
class_name Entity

signal onRoomChanged();
signal onHit(damage : float)
signal onHitShape(damage : float, shape : CollisionShape2D)
signal onDeath()

var room_current : Room = null;
