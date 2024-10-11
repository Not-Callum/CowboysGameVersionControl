extends CharacterBody2D

@export var SPEED = 165

signal LassoCatch(target: CharacterBody2D)

@onready var main = GlobalReferences.main
var lineDraw = preload("res://Effects/draw_line.tscn")


var airFriction = 200

func _ready() -> void:
	var linedraw_instance = lineDraw.instantiate()
	main.add_child.call_deferred(linedraw_instance)
	velocity = (Vector2.RIGHT*SPEED).rotated(rotation)
	SignalHandler.cancelledAbility.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	
	
	velocity = velocity.move_toward(Vector2.ZERO, airFriction * delta)
	if velocity == Vector2.ZERO:
		SignalHandler.lassoFailed.emit()
		queue_free()
		get_tree().call_group("Player", "giveLasso")
	
	move_and_slide()
	


	
		


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Lassoable"):
		print("caught lassoable")
		SignalHandler.lassoFailed.emit()
		print("IM HITTING")
		emit_signal("LassoCatch", area)
		queue_free()
