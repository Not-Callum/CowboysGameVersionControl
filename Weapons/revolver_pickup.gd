extends CharacterBody2D


enum{
	YANKED,
	DEFAULT
}

const FRICITON = 300
@onready var main = get_tree().get_root().get_node("World")
@export var AmmoComponent: Node2D
var lineDraw = preload("res://Effects/draw_line.tscn")
var myWeapon = preload("res://Weapons/revolver_held.tscn")
var state = DEFAULT
var touchPlayer : bool = false


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	match state:
		YANKED:
			yanked_state()
		DEFAULT:
			pass
	velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
	move_and_slide()

func yanked_state():
	await get_tree().create_timer(0.5).timeout
	
	state = DEFAULT

func _on_lasso_end_pulled_by_lasso() -> void:
	state = YANKED

func updateAmmoInDrop(ammo):
	#print("I am updating to ", ammo)
	AmmoComponent.update_ammo(ammo)
	#print(AmmoComponent.ammo)
	
func howMuchAmmo():
	return AmmoComponent.ammo

	
