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
	if attack.attack_damage > 0:
		health -= attack.attack_damage
		var direction = global_position - attack.attack_position
		myParent.velocity = myParent.velocity + (direction * attack.knockback_force)
		if health > 0:
			SignalHandler.doCameraShake.emit(0.5, 8.0)
			emit_signal("hit")
		elif health <= 0:
			health = 0
			SignalHandler.doCameraShake.emit(4.0, 7.0)
			emit_signal("hit")
			if !myParent.is_in_group("Player"):
				get_parent().queue_free()
				var bloodSplatter_instance = bloodSplatter.instantiate()
				bloodSplatter_instance.global_position = global_position
				main.add_child.call_deferred(bloodSplatter_instance)
			else:
				myParent.visible = false
				myParent.die()
	elif attack.attack_damage < 0:
		health -= attack.attack_damage
		
		if health > MAX_HEALTH:
			health = MAX_HEALTH
			emit_signal("hit")
		else:
			emit_signal("hit")
	
	#velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
	
	
