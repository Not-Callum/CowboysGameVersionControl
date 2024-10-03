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

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var lasso_end: CharacterBody2D = $LassoEnd
@onready var main = GlobalReferences.main
@export var hitbox: Area2D

var spawnPoint
var SPEED = 40
var last_position = null
var random_distance_offset = randi_range(-10, 10)
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
		print("I am colliding softly")
		velocity += soft_collision.get_push_vector() * delta * 400
	
	velocity = velocity.move_toward(Vector2.ZERO, FRICITON * delta)
	move_and_slide()

func idle_state(delta):
	if global_position.distance_to(spawnPoint) >= 10:
		nav_agent.target_position = spawnPoint
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * SPEED
	elif target != null:
		state = SEEKING
	else:
		velocity = Vector2.ZERO

func move_state(delta):
	pass
	
func seeking_state(delta):
	if nav_agent.is_navigation_finished():
		last_position = null
	if last_position != null:
		nav_agent.target_position = last_position
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * SPEED
	else:
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
	
	if velocity.x < 0:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
	
	
		
	
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
	#print(velocity.length())
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
			#print("hit wall")
			
			if hitbox:
				var attack = Attack.new()
				attack.attack_damage = 150.0
				#print(attack.attack_damage)
				hitbox.damage(attack)
				state = STUNNED
				
	await get_tree().create_timer(0.4).timeout
	state = IDLE
	
func stunned_state(delta):
	print(state)
	await get_tree().create_timer(0.3).timeout
	target = get_tree().get_first_node_in_group("Player")
	state = PERSUE


func _on_lasso_end_pulled_by_lasso() -> void:
	
	state = YANKED
	
	


#func _on_player_search_area_body_entered(body: Node2D) -> void:
	#
	#if body.is_in_group("Player") and state != YANKED and state != TIED:
		#print("body is player")
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
