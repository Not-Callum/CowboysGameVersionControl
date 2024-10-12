extends Area2D



var damage = -20


func _on_area_entered(area: Area2D) -> void:
	var group = self.get_parent().get_groups()[0]
	if !area.is_in_group(group) and area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = damage
		area.damage(attack)
