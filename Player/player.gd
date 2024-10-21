extends CharacterBody2D
class_name Player

@onready var main = GlobalReferences.main

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var weapon_held: Marker2D = $Hand
@onready var hitbox: Area2D = $Hitbox
@onready var player_inventory: Node2D = $PlayerInventory
@onready var lasso_timer: Timer = $LassoTimer
@onready var health_component: HealthComponent = $HealthComponent

signal LassoThrown
signal Yanked()

enum{
	MOVE,
	DODGE,
	DEAD,
}

var DODGE_SPEED = 100
var MAX_SPEED = 50
var ACCELERATION = 400
var FRICITON = 400
var LASSOEQUIPPED = true
var LASSOCOOLDOWN = true
var lasso = preload("res://Interactions/lasso_throw.tscn")
var dodge_vector = Vector2.RIGHT

var weapon_to_drop
var weapon_to_spawn
var hasWeapon : bool
var canShoot : bool
var state = MOVE
var my_ammo_type
var reload_speed : float

signal weapon_changed
signal ammo_in_weapon

func _ready() -> void:
	canShoot = false
	hasWeapon = false
	player_sprite.frame = 0
	SignalHandler.Untied.connect(giveLasso)
	SignalHandler.healthPickedUp.connect(add_health)
	SignalHandler.ammoPickedUp.connect(add_ammo)
	health_component.hit.connect(health_changed)

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
		DODGE:
			dodge_state(delta)
			if Input.is_action_just_pressed("cancel"):
				state = MOVE
		DEAD:
			get_tree().paused = true
	
	var mouse_position = get_global_mouse_position()
	if state == MOVE:
		weapon_held.look_at(mouse_position)
	move_and_slide()
		
func _process(delta: float) -> void:
	if weapon_held.get_child_count() == 0:
		hasWeapon = false
	elif weapon_held.get_child_count() >= 1:
		hasWeapon = true
	
func move_state(delta):
	hitbox.monitoring = true
	hitbox.monitorable = true
	#print(hasWeapon)
	var mouse_rotation = global_position.angle_to_point(get_global_mouse_position())
	var input_vector = Vector2.ZERO
	trackMouse(mouse_rotation)
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	
	if input_vector != Vector2.ZERO:
		dodge_vector = input_vector
		animation_player.play("move")
			
	else:
		animation_player.play("RESET")
		velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
	
	
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("ability") and LASSOCOOLDOWN and LASSOEQUIPPED:
		throwLasso()
		emit_signal("LassoThrown")
	elif Input.is_action_just_released("ability") and LASSOEQUIPPED == false:
		emit_signal("Yanked")
		LASSOCOOLDOWN = false
		lasso_timer.start(1.2)
	elif Input.is_action_just_pressed("cancel") and LASSOEQUIPPED == false:
		SignalHandler.cancelledAbility.emit()
	if Input.is_action_just_pressed("shoot"):
		if hasWeapon == true and canShoot == true:
			shoot_weapon()
	if Input.is_action_just_pressed("throwWeapon"):
		throwWeapon()
	if Input.is_action_just_pressed("dodge"):
		state = DODGE
	if Input.is_action_just_released("reload") and hasWeapon == true and canShoot == true:
		var weapon = weapon_held.get_child(0)
		if weapon.ammunition_component.ammo < weapon.ammunition_component.MAX_AMMO:
			print("reloading")
			reload_weapon()
			print("reloaded")
		
func dodge_state(delta):
	canShoot = false
	velocity = dodge_vector * DODGE_SPEED
	player_sprite.frame = 2
	hitbox.monitoring = false
	hitbox.monitorable = false
	await get_tree().create_timer(0.5).timeout
	state = MOVE
	canShoot = true
	
func health_changed():
	var health = health_component.health
	SignalHandler.player_health_changed.emit(health)
		
	
func trackMouse(mouse_rotation):
	if mouse_rotation >= -2.4 and mouse_rotation <= -0.7:
		player_sprite.frame = 1
		weapon_held.y_sort_enabled = true
		weapon_held.z_index = -1
	else:
		player_sprite.frame = 0
		weapon_held.y_sort_enabled = false
		weapon_held.z_index = 1
		if mouse_rotation >= 1.6 or mouse_rotation < -2.4:
			
			player_sprite.flip_h = true
		elif mouse_rotation < 1.6 and mouse_rotation > -0.7:
			
			player_sprite.flip_h = false
	
	if mouse_rotation <= -1.57 or mouse_rotation >= 1.6:
		weapon_held.scale.y = -1
	else:
		weapon_held.scale.y = 1

func throwLasso():
	LASSOEQUIPPED = false
	MAX_SPEED = MAX_SPEED * 0.75
	DODGE_SPEED = DODGE_SPEED * 0.8
	var lasso_instance = lasso.instantiate()
	lasso_instance.rotation = weapon_held.rotation
	lasso_instance.global_position = weapon_held.global_position
	lasso_instance.velocity += self.velocity
	main.add_child.call_deferred(lasso_instance)
	
	
func giveLasso():
	await get_tree().create_timer(0.5).timeout
	print("give lasso")
	LASSOEQUIPPED = true
	MAX_SPEED = 50
	DODGE_SPEED = 100
	
func throwWeapon():
	if hasWeapon == true:
		var currentWeapon = weapon_held.get_child(0)
		currentWeapon.droppedWeapon()
		currentWeapon.reparent(main, false)
		currentWeapon.rotation = 0
		currentWeapon.global_position = weapon_held.global_position
		hasWeapon = false
		canShoot = false
		weapon_changed.emit(null, null)
		send_ammo_in_weapon()
		player_inventory.get_ammo_stored(null)
		#print("There was ", currentWeapon.howMuchAmmoInGun(), " in my gun")
		
func reload_weapon():
	canShoot = false
	print("Reloading!...")
	var weapon = weapon_held.get_child(0)
	await get_tree().create_timer(reload_speed).timeout
	if int(player_inventory.AmmoTypes[my_ammo_type]) >= (weapon.ammunition_component.MAX_AMMO - weapon.ammunition_component.ammo) and (weapon.ammunition_component.MAX_AMMO > weapon.ammunition_component.ammo):
		var updated_ammo = weapon.ammunition_component.MAX_AMMO - weapon.ammunition_component.ammo
		player_inventory.update_ammo_stored(my_ammo_type, -updated_ammo)
		await weapon.reload(updated_ammo)
		canShoot = true
		send_ammo_in_weapon()
		print("amount of ammo left , ", int(player_inventory.AmmoTypes[my_ammo_type]))
	elif (weapon.ammunition_component.MAX_AMMO > weapon.ammunition_component.ammo) and int(player_inventory.AmmoTypes[my_ammo_type]) > 0:
		var updated_ammo = int(player_inventory.AmmoTypes[my_ammo_type])
		player_inventory.update_ammo_stored(my_ammo_type, -updated_ammo)
		await weapon.reload(updated_ammo)
		send_ammo_in_weapon()
		canShoot = true
	player_inventory.get_ammo_stored(my_ammo_type)

func shoot_weapon():
	var weapon = weapon_held.get_child(0)
	if weapon.ammunition_component.ammo > 0:
		weapon.shoot()
	elif weapon.ammunition_component.ammo == 0 and hasWeapon == true and canShoot == true:
		if weapon.ammunition_component.ammo < weapon.ammunition_component.MAX_AMMO:
			print("reloading")
			reload_weapon()
			print("reloaded")
		
	send_ammo_in_weapon()
		
func add_health(added_health):
	health_component.heal(added_health)
	
func add_ammo(ammo_type, ammoAmount):
	player_inventory.update_ammo_stored(ammo_type, ammoAmount)
	if ammo_type == my_ammo_type:
		player_inventory.get_ammo_stored(my_ammo_type)
	
func addWeapon(weapon):
	
	if weapon_held.get_child_count() == 0:
		
		#main.remove_child(weapon)
		weapon.reparent(weapon_held, false)
		weapon.global_position = weapon_held.global_position
		weapon.global_rotation = weapon_held.global_rotation
		weapon.pickedUp()
		weapon.group_name = "Player"
		hasWeapon = true
		canShoot = true
		my_ammo_type = weapon.get_bullet_type()
		var max_ammo = weapon.ammunition_component.MAX_AMMO
		weapon_changed.emit(my_ammo_type, max_ammo)
		send_ammo_in_weapon()
		player_inventory.get_ammo_stored(my_ammo_type)
		reload_speed = weapon.weapon_reload_speed
	elif weapon_held.get_child_count() == 1:
		
		throwWeapon()
		weapon.reparent(weapon_held, false)
		weapon.global_position = weapon_held.global_position
		weapon.global_rotation = weapon_held.global_rotation
		weapon.pickedUp()
		weapon.group_name = "Player"
		hasWeapon = true
		canShoot = true
		my_ammo_type = weapon.get_bullet_type()
		var max_ammo = weapon.ammunition_component.MAX_AMMO
		weapon_changed.emit(my_ammo_type, max_ammo)
		send_ammo_in_weapon()
		player_inventory.get_ammo_stored(my_ammo_type)

func die():
	state = DEAD

func _on_lasso_timer_timeout() -> void:
	print("lasso ready")
	LASSOCOOLDOWN = true
	
func send_ammo_in_weapon():
	if weapon_held.get_child_count() > 0:
		var weapon = weapon_held.get_child(0)
		var ammo_amount_in_weapon = weapon.ammunition_component.ammo
		ammo_in_weapon.emit(ammo_amount_in_weapon)
	else:
		ammo_in_weapon.emit(null)
