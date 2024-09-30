extends Node2D

@export var MAX_AMMO : int = 6

var ammo: int 

func _ready() -> void:
	ammo = MAX_AMMO
	
func reload(ammo_to_reload):
	ammo += ammo_to_reload
	
func update_ammo(newAmmo):
	print("the ammo component is updating to ", newAmmo)
	ammo = newAmmo
	
func shot():
	if ammo > 0:
		ammo -= 1
		
	else:
		print("Must reload")
		
