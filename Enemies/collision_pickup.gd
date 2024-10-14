extends Area2D

signal PickedUp

func _physics_process(delta: float) -> void:
	
	if has_overlapping_areas():
		
		for area in get_overlapping_areas():
			if area.is_in_group("Player") and area.name == "Hitbox":
				emit_signal("PickedUp")
			else:
				pass
	else:
		pass
