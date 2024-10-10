extends Node2D
class_name HealthComponent

var bloodSplatter = preload("res://Effects/blood_splatter.tscn")
@onready var myParent = get_parent()
@onready var main = get_tree().get_root().get_node("World")
signal hit
@export var MAX_HEALTH := 10.0
var health: float

func _ready() -> void:
	health = MAX_HEALTH
	
	
func damage(attack: Attack):
	#print(attack.attack_damage)
	health -= attack.attack_damage
	var direction = global_position - attack.attack_position
	myParent.velocity = myParent.velocity + (direction * attack.knockback_force)
	emit_signal("hit")
	if health > 0:
		SignalHandler.doCameraShake.emit(0.5, 8.0)
	#velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
	
	elif health <= 0:
		SignalHandler.doCameraShake.emit(4.0, 7.0)
		if !myParent.is_in_group("Player"):
			get_parent().queue_free()
			var bloodSplatter_instance = bloodSplatter.instantiate()
			bloodSplatter_instance.global_position = global_position
			main.add_child.call_deferred(bloodSplatter_instance)
		else:
			myParent.visible = false
			myParent.die()
