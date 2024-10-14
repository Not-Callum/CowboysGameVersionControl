extends Node2D
const pistol_ammo = preload("res://Weapons/DroppedBulletPacks/pistol_ammo_pickup.tscn")
const rifle_ammo = preload("res://Weapons/DroppedBulletPacks/rifle_ammo_pickup.tscn")
const shotgun_ammo = preload("res://Weapons/DroppedBulletPacks/shotgun_ammo_pickup.tscn")
const life_orb = preload("res://Enemies/health_orb.tscn")
@onready var main = GlobalReferences.main

func _ready() -> void:
	SignalHandler.EnemyDied.connect(handle_enemy_death)
	
func handle_enemy_death(enemyPos, ammo_type):
	spawn_life_orb(enemyPos)
	spawn_ammo_pack(ammo_type, enemyPos)
	
func spawn_ammo_pack(ammo_type, enemyPos):
	if ammo_type == "Pistol":
		var ammo_pack_instance = pistol_ammo.instantiate()
		main.add_child.call_deferred(ammo_pack_instance)
		ammo_pack_instance.global_position = enemyPos
	elif ammo_type == "Rifle":
		var ammo_pack_instance = rifle_ammo.instantiate()
		main.add_child.call_deferred(ammo_pack_instance)
		ammo_pack_instance.global_position = enemyPos
	elif ammo_type == "Shotgun":
		var ammo_pack_instance = shotgun_ammo.instantiate()
		main.add_child.call_deferred(ammo_pack_instance)
		ammo_pack_instance.global_position = enemyPos
	else:
		print("and I would've spawned an ammo pack if it wasnt for you meddling kids")
	
func spawn_life_orb(enemyPos):
	var life_orb_instance = life_orb.instantiate()
	main.add_child.call_deferred(life_orb_instance)
	life_orb_instance.global_position = enemyPos
