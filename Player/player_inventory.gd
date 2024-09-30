extends Node2D

var AmmoTypes : Dictionary = {"Pistol": 0, "Rifle": 0, "Shotgun": 0}

func _ready() -> void:
	var ammoSize = AmmoTypes.size()
	var ammoKeys = AmmoTypes.keys()
	for i in ammoSize:
		print(ammoKeys[i])
		var currentAmmo = int(AmmoTypes[ammoKeys[i]])
		var newAmmo = currentAmmo + 15
		AmmoTypes[ammoKeys[i]] = newAmmo
	print(AmmoTypes.values())
	
func _process(delta: float) -> void:
	pass

func update_ammo_stored(ammoType, amount):
	var currentAmmo = int(AmmoTypes[ammoType])
	var newAmmo = currentAmmo + amount
	AmmoTypes[ammoType] = newAmmo
