extends Line2D

@onready var player : CharacterBody2D = self.get_tree().get_first_node_in_group("Player")
@onready var target = self.get_tree().get_first_node_in_group("Lassoed")
@onready var lassoJoint = self.get_tree().get_first_node_in_group("LassoJoint")


func _ready():
	if target != null:
		target = target
	elif lassoJoint != null:
		target = lassoJoint
	add_point(Vector2())
	add_point(target.global_position - player.global_position)
	update_position()
	SignalHandler.Untied.connect(queue_free)
	SignalHandler.lassoFailed.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	if target != null:
		update_position()
	else:
		clear_points()

func update_position() -> void:
	global_position = player.global_position
	set_point_position(1, target.global_position - player.global_position)
	
