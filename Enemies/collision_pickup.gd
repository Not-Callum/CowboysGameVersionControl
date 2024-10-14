extends Area2D

signal PickedUp

func _physics_process(delta: float) -> void:
	
	if has_overlapping_areas():
		
		for area in get_overlapping_areas():
			if area.is_in_group("Player") and area.name == "Hitbox":
				if area.get_parent().health_component.health < area.get_parent().health_component.MAX_HEALTH:
					emit_signal("PickedUp")
			else:
				pass
	else:
		pass
