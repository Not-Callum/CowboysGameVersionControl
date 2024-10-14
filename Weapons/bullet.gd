extends Area2D


@export var speed = 600
@export var damage = 35.0
@export var knockback = 12.5



func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	#if self.has_overlapping_bodies():
		#var bodies = get_overlapping_bodies()
		#for i in get_overlapping_bodies():
			#if i is TileMap:
				#var current_tilemap = i
				#var body_rid = i.get_rid()
				#var collided_coords = current_tilemap.get_coords_for_body_rid(body_rid)
				#for index in current_tilemap.get_layers_count():
					#var tiledata = current_tilemap.get_cell_tile_data(index, collided_coords)
					#var terrain_mask = tiledata.get_custom_data_by_layer_id(0)
					#if terrain_mask:
						#print(terrain_mask)
	
	
func _on_area_entered(area: Area2D) -> void:
	var groups = get_groups()
	if area.has_method("damage") and !area.is_in_group(groups[0]):
		var attack = Attack.new()
		attack.attack_damage = damage
		attack.knockback_force = knockback
		attack.attack_position = global_position
		
		area.damage(attack)
		queue_free()
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
