extends CharacterBody2D

enum {
	OnGround,
	Pickedup
}
@onready var lasso_end: Area2D = $LassoEnd/Area2D
@onready var lasso_endnode: CharacterBody2D = $LassoEnd
@onready var main = GlobalReferences.main


@onready var shotgun: Sprite2D = $Shotgun

@onready var hand: Sprite2D = $Hand

@onready var ammunition_component: Node2D = $AmmunitionComponent

@onready var pickup: Area2D = $Pickup



var shootSpeed = 0.45
var bulletDirection = Vector2(1,0)
var FRICITON = 300
var bullet = preload("res://Weapons/bullet.tscn")
@export var bulletSpeed : float
var states
var shootable = true
var lassoed = false
var pellets : int = 6
var group_name : String
@export var weapon_reload_speed = 0.6
@export var weapon_damage : float
@export var random_spread : float

func _ready() -> void:
	states = OnGround

func _physics_process(delta: float) -> void:
	#print(states)
	match states:
		OnGround:
			hand.visible = false
			shotgun.frame = 0
			shotgun.scale = Vector2(0.5, 0.5)
			pickup.monitorable = true
			pickup.monitoring = true
			pickup.add_to_group("item")
			lasso_end.monitoring = true
			lasso_end.monitorable = true
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
			move_and_slide()
		Pickedup:
			if lasso_endnode.is_in_group("Lassoed"):
				SignalHandler.cancelledAbility.emit()
			hand.visible = true
			shotgun.frame = 1
			shotgun.scale = Vector2(1, 1)
			pickup.monitorable = false
			pickup.monitoring = false
			pickup.remove_from_group("item")
			pickup.unhighlight()
			lasso_end.monitoring = false
			lasso_end.monitorable = false
			velocity = Vector2.ZERO
			
			
func pickedUp():
	#print("states changed to pickup")
	states = Pickedup
	
func droppedWeapon():
	#print("states changed to onground")
	states = OnGround

func get_bullet_type():
	print(get_meta("AmmoType"))
	return get_meta("AmmoType")
	
func reload(ammo):
	ammunition_component.reload(ammo)


	
func shoot():
	if shootable == true and ammunition_component.ammo >= 1:
		shootable = false
		$ShootSpeedTimer.start(shootSpeed)
		ammunition_component.shot()
		for i in pellets:
			var bulletInstance = bullet.instantiate()
			main.add_child.call_deferred(bulletInstance)
			bulletInstance.add_to_group(group_name)
			bulletInstance.global_position = $Marker2D.global_position
			bulletInstance.global_rotation = $Marker2D.global_rotation + randf_range(-random_spread, random_spread)
			bulletInstance.speed = bulletSpeed + randf_range(-50, 25)
			bulletInstance.damage = weapon_damage
			bulletInstance.knockback = 4.0
		
		


func _on_shoot_speed_timer_timeout() -> void:
	shootable = true
	
