extends Node2D
class_name HealthComponent

var bloodSplatter = preload("res://Effects/blood_splatter.tscn")
@onready var main = get_tree().get_root().get_node("World")

@export var MAX_HEALTH := 10.0
var health: float

func _ready() -> void:
	health = MAX_HEALTH
	
	
func damage(attack: Attack):
	#print(attack.attack_damage)
	health -= attack.attack_damage
	if health > 0:
		SignalHandler.doCameraShake.emit(0.5, 8.0)
	#velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
	
	elif health <= 0:
		print("I die")
		SignalHandler.doCameraShake.emit(4.0, 7.0)
		get_parent().queue_free()
		var bloodSplatter_instance = bloodSplatter.instantiate()
		bloodSplatter_instance.global_position = global_position
		main.add_child.call_deferred(bloodSplatter_instance)
