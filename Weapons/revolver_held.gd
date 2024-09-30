extends Node2D
@export var AmmoComponent: Node2D
var dropWeapon = load("res://Weapons/revolver_pickup.tscn")

func updateAmmoComponent(ammo):
	AmmoComponent.update_ammo(ammo)
	
func howMuchAmmoInGun():
	return AmmoComponent.ammo
	print("There is this much in my gun ", AmmoComponent.ammo)
	
func _ready() -> void:
	print("I have ", AmmoComponent.ammo)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		AmmoComponent.shot()
		print(AmmoComponent.ammo)
	
