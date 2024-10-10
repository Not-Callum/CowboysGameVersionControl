extends Marker2D

@onready var main = GlobalReferences.main

var enemy = preload("res://Enemies/enemy.tscn") 
var revolver = load("res://Weapons/revolver.tscn")
var repeater = load("res://Weapons/repeater.tscn")
var shotgun = load("res://Weapons/Shotgun/shotgun.tscn")

func _ready() -> void:
	randomize()
	spawnEnemy()

func spawnEnemy():
	var weapon = randomise_weapon()
	var newEnemy = enemy.instantiate()
	get_parent().add_child.call_deferred(newEnemy)
	newEnemy.global_position = global_position
	newEnemy.give_weapon.call_deferred(weapon)

func randomise_weapon():
	var random = randf_range(0, 1)
	print(random)
	if random <= 0.5:
		return revolver
	elif random > 0.5 and random <= 0.75:
		return repeater
	else:
		return shotgun
#and random >= 0.8:
