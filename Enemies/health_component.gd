extends Node2D
class_name HealthComponent

var bloodSplatter = preload("res://Effects/blood_splatter.tscn")
@onready var myParent = get_parent()
@onready var main = get_tree().get_root().get_node("World")
signal hit
@export var MAX_HEALTH := 10.0
var health: float
var making_sure_I_only_die_once = 0

func _ready() -> void:
	health = MAX_HEALTH
	
func heal(add_health):
	if health < MAX_HEALTH:
		health += add_health
		if health > MAX_HEALTH:
			health = MAX_HEALTH
	SignalHandler.player_health_changed.emit(health)
	
	
func damage(attack: Attack):
	#print(attack.attack_damage)
	if attack.attack_damage > 0:
		health -= attack.attack_damage
		if myParent.is_in_group("Player"):
			SignalHandler.player_health_changed.emit(health)
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
				#print("my parent is not a player!")
				death_because_it_keeps_doing_it_more_than_once()
				myParent.queue_free.call_deferred()
				var bloodSplatter_instance = bloodSplatter.instantiate()
				bloodSplatter_instance.global_position = global_position
				main.add_child.call_deferred(bloodSplatter_instance)
			else:
				SignalHandler.player_health_changed.emit(health)
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
	
func death_because_it_keeps_doing_it_more_than_once():
	
	if making_sure_I_only_die_once < 1:
		SignalHandler.EnemyDied.emit(self.global_position, myParent.die())
		making_sure_I_only_die_once += 1
