extends CharacterBody2D
class_name Enemy

signal Untied



var lineDraw = preload("res://Effects/draw_line.tscn")

const FRICITON = 300

@export var target: Node2D = null
@onready var player_search_area: Area2D = $PlayerSearchArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var soft_collision: Area2D = $SoftCollision
@onready var break_free_timer: Timer = $BreakFreeTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var hand: Marker2D = $Hand


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var lasso_end: CharacterBody2D = $LassoEnd
@onready var main = GlobalReferences.main
@export var hitbox: Area2D

var spawnPoint
var SPEED = 40
var last_position = null
var random_distance_offset = randi_range(-10, 10)
var held_weapon

var canShoot : bool = false

enum {
	IDLE,
	MOVE,
	SEEKING,
	PERSUE,
	TIED,
	YANKED,
	STUNNED
}

var state = MOVE

func _ready() -> void:
	randomize()
	spawnPoint = global_position
	var enemy = Enemy.new()
	add_to_group("Enemy")
	#lasso_end.hide()
	lasso_end.CaughtByLasso.connect(just_caught_by_lasso)
	health_component.hit.connect(got_shot)
	

func _physics_process(delta: float) -> void:
	
	if player_search_area.get_overlapping_bodies() and state != YANKED and state != TIED and state != STUNNED:
		var bodies = player_search_area.get_overlapping_bodies()
		for i in bodies:
			if i.is_in_group("Player"):
				state = PERSUE
				target = i
	
	match state:
		IDLE:
			idle_state(delta)
		MOVE:
			move_state(delta)
			
		SEEKING:
			seeking_state(delta)
		PERSUE:
			persue_state(delta)
		TIED:
			tied_state(delta)
			
		
		YANKED:
			yanked_state(delta)
		STUNNED:
			
			stunned_state(delta)
			
	if velocity != Vector2.ZERO:
		animation_player.play("move")
	else:
		animation_player.play("RESET")
	
	if soft_collision.is_colliding():
		
		velocity += soft_collision.get_push_vector() * delta * 400
	
	enemy_look_at_player()
	velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
	if velocity.x < 0:
		sprite_2d.flip_h = true
	elif velocity.x > 0:
		sprite_2d.flip_h = false
	move_and_slide()

func idle_state(delta):
	if global_position.distance_to(spawnPoint) >= 10:
		nav_agent.target_position = spawnPoint
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * SPEED
		hand.look_at(next_path_position)
		check_hand_scale(next_path_position)
	elif target != null:
		state = SEEKING
	else:
		velocity = Vector2.ZERO
		
	if held_weapon.ammunition_component.ammo < held_weapon.ammunition_component.MAX_AMMO:
			reload()

func move_state(delta):
	pass
	
func seeking_state(delta):
	if nav_agent.is_navigation_finished():
		last_position = null
	if last_position != null:
		target = null
		nav_agent.target_position = last_position
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * SPEED
	else:
		target = null
		velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
		await get_tree().create_timer(5).timeout
		state = IDLE
	

func persue_state(delta):
	
	if target:
		seeking_setup()
	if nav_agent.is_navigation_finished():
		return
	if global_position.distance_to(target.global_position) > 55 + random_distance_offset:
	
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * SPEED
	elif global_position.distance_to(target.global_position) <= 35 + random_distance_offset:
		var direction = -(target.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * SPEED, 400)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
		
	
	
func seeking_setup():
	await get_tree().physics_frame
	nav_agent.target_position = target.global_position

func just_caught_by_lasso():
	state = TIED
	break_free_timer.start(randi_range(4,12))
	
func got_shot():
	
	state = STUNNED

func tied_state(delta):
	pass
	
	
func yanked_state(delta):
	
	var collision_info = get_last_slide_collision()
	
	if collision_info:
		var collider = collision_info.get_collider()
		var tile_layer := 0
		var tilemap = collider as TileMap
		var tile_collider_rid := collision_info.get_collider_rid()
		var tile_coords := tilemap.get_coords_for_body_rid(tile_collider_rid)
		var tile_data := tilemap.get_cell_tile_data(tile_layer, tile_coords)
		var is_wall = tile_data.get_custom_data("Terrain")
		if is_wall == 1:
		
			
			if hitbox:
				var attack = Attack.new()
				attack.attack_damage = 150.0
				
				hitbox.damage(attack)
				state = STUNNED
				
	await get_tree().create_timer(0.4).timeout
	state = IDLE
	
func stunned_state(delta):
	await get_tree().create_timer(0.3).timeout
	target = get_tree().get_first_node_in_group("Player")
	state = PERSUE


func _on_lasso_end_pulled_by_lasso() -> void:
	
	state = YANKED
	
	


#func _on_player_search_area_body_entered(body: Node2D) -> void:
	#
	#if body.is_in_group("Player") and state != YANKED and state != TIED:
		#target = body
		#seeking_setup()
		#state = PERSUE


func _on_player_search_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and state != YANKED and state != TIED:
		last_position = body.global_position
		state = SEEKING


func _on_break_free_timer_timeout() -> void:
	if state == TIED:
		SignalHandler.cancelledAbility.emit()
		state = IDLE

func enemy_look_at_player():
	
	if target != null:
		var target_velocity = target.velocity
		var distance_to_player = global_position.distance_to(target.global_position)
		var final_aim_point = target.global_position + target_velocity * (distance_to_player/held_weapon.bulletSpeed)
		hand.rotation = get_angle_to(final_aim_point) + deg_to_rad(target_velocity.x * 0.15)
		check_hand_scale(target.global_position)
		if held_weapon.shootable == true and held_weapon.ammunition_component.ammo > 0 and state != TIED and state != STUNNED and state != YANKED:
			if global_position.distance_to(target.global_position) <= 120 and canShoot == true:
				shoot()
		elif held_weapon.ammunition_component.ammo == 0:
			reload()
	elif last_position != null:
		hand.look_at(last_position)
		check_hand_scale(last_position)
	else:
		pass
		
	
func check_hand_scale(object_position):
	var body_to_player_angle = get_angle_to(object_position)
	
	if body_to_player_angle <= 1.53 and body_to_player_angle >= -1.62:
		hand.scale.y = 1
	else:
		hand.scale.y = -1
	if body_to_player_angle <= -0.7 and body_to_player_angle >= -2.5:
		sprite_2d.frame = 1
		hand.y_sort_enabled = true
		hand.z_index = -1
	else:
		sprite_2d.frame = 0
		hand.y_sort_enabled = false
		hand.z_index = 1

func give_weapon(weapon):
	if weapon == null:
		print_debug("No Weapon To Give")
	else:
		var weaponInstance = weapon.instantiate()
		hand.add_child.call_deferred(weaponInstance)
		weaponInstance.pickedUp.call_deferred()
		weaponInstance.bulletSpeed = weaponInstance.bulletSpeed / 2
		weaponInstance.random_spread = weaponInstance.random_spread * 2
		weaponInstance.shootSpeed = 1
		weaponInstance.weapon_damage = weaponInstance.weapon_damage * 0.5
		weaponInstance.group_name = "Enemy"
		held_weapon = weaponInstance
		canShoot = true
		
		
func shoot():
	held_weapon.shoot()
	
func reload():
	canShoot = false
	await held_weapon.reload(held_weapon.ammunition_component.MAX_AMMO)
	canShoot = true
