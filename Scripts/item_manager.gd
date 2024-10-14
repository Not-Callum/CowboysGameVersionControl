extends Node2D

var life_orb = preload("res://Enemies/health_orb.tscn")
@onready var main = GlobalReferences.main

func _ready() -> void:
	SignalHandler.EnemyDied.connect(handle_enemy_death)
	
func handle_enemy_death(enemyPos, ammo_type):
	spawn_life_orb(enemyPos)
	spawn_ammo_pack(ammo_type)
	
func spawn_ammo_pack(ammo_type):
	print(ammo_type)
	print("and I would've spawned an ammo pack if it wasnt for you meddling kids")
	
func spawn_life_orb(enemyPos):
	var life_orb_instance = life_orb.instantiate()
	main.add_child.call_deferred(life_orb_instance)
	life_orb_instance.global_position = enemyPos
