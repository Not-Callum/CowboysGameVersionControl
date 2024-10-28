extends Marker2D

@onready var main = GlobalReferences.main

var current_enemy
var firstspawn = 0
var enemy = preload("res://Enemies/enemy.tscn") 
var revolver = load("res://Weapons/revolver.tscn")
var repeater = load("res://Weapons/repeater.tscn")
var shotgun = load("res://Weapons/Shotgun/shotgun.tscn")



func _ready() -> void:
	self.add_to_group("EnemySpawnPoints")
	
	randomize()
	
func _physics_process(delta: float) -> void:
	if current_enemy == null and firstspawn == 0:
		SignalHandler.SpawnPointAvailable.emit(0.1)
		firstspawn += 1

func spawnEnemy():
	if current_enemy == null:
		var weapon = randomise_weapon()
		var newEnemy = enemy.instantiate()
		get_parent().add_child.call_deferred(newEnemy)
		newEnemy.global_position = global_position
		newEnemy.give_weapon.call_deferred(weapon)
		current_enemy = newEnemy
	else:
		pass

func randomise_weapon():
	var random = randf_range(0, 1)
	print(random)
	if random <= 0.6:
		return revolver
	elif random > 0.6 and random <= 0.85:
		return repeater
	else:
		return shotgun
