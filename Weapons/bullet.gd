extends Area2D


@export var speed = 600
@export var damage = 35.0
@export var knockback = 12.5



func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
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


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body_rid.is_valid() == true:
		queue_free()
