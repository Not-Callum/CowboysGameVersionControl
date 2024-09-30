extends Area2D

var nearestItem : Area2D = null
var items : Array

enum{
	hasItem,
	noItem
}

var state = noItem

func _physics_process(delta: float) -> void:
	
	if has_overlapping_areas() == true:
		
		for area in get_overlapping_areas():
			
			if area.is_in_group("item"):
				if nearestItem == null:
					nearestItem = area
				
				elif area.global_position.distance_to(self.global_position) < nearestItem.global_position.distance_to(self.global_position):
					nearestItem = area
					
				else:
					area.unhighlight()
			else:
				#could do elif if is in group pickup and then do the code to pick it up here on entry
				pass
	else:
		nearestItem = null
		var allItems = get_tree().get_nodes_in_group("item")
		for i in allItems:
			if i.has_method("unhighlight"):
				i.unhighlight()
				
	if nearestItem != null:
		nearestItem.doHighlight()
		
	if nearestItem != null and Input.is_action_just_pressed("pickup"):
		nearestItem.addToPlayer()
		nearestItem.unhighlight()
		nearestItem = null
