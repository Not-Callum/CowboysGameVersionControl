extends Node2D



func _ready() -> void:
	$Player.Yanked.connect(send_yank_to_lassoed)
	#$Enemy.Untied.connect($Player.giveLasso)
	
	
func send_yank_to_lassoed():
	if get_tree().get_nodes_in_group("Lassoed"):
		for lassoedEnemy in get_tree().get_nodes_in_group("Lassoed"):
			lassoedEnemy.get_pulled_to_player()
			$Player.giveLasso
			
