extends Node2D
@onready var control: CanvasLayer = $UiControl





func _ready() -> void:
	$Player.Yanked.connect(send_yank_to_lassoed)
	#$Enemy.Untied.connect($Player.giveLasso)
	SignalHandler.player_health_changed.connect(health_change)
	
	control.change_weapon_image.call_deferred(null, null)
	$Player.weapon_changed.connect(change_weapon_on_UI)	
	$Player.ammo_in_weapon.connect(ammo_change_on_UI)
	$Player/PlayerInventory.player_inventory_ammo_changed.connect(player_inventory_ammo_changed)

	
func send_yank_to_lassoed():
	if get_tree().get_nodes_in_group("Lassoed"):
		for lassoedEnemy in get_tree().get_nodes_in_group("Lassoed"):
			lassoedEnemy.get_pulled_to_player()
			$Player.giveLasso
			
func health_change(health):
	control.update_health_progress(health)
	
func player_inventory_ammo_changed(player_inventory_ammo):
	if player_inventory_ammo != null:
		control.update_player_inventory_ammo_UI(player_inventory_ammo)
	else:
		control.update_player_inventory_ammo_UI(null)
	
func ammo_change_on_UI(ammo):
	control.update_ammo(ammo)

func change_weapon_on_UI(weapon, max_ammo):
	control.change_weapon_image.call_deferred(weapon, max_ammo)
	
