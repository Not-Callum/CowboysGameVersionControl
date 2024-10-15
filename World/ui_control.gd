extends CanvasLayer
const PISTOL_LARGE_1 = preload("res://World/UiImages/pistol_large1.png")
const RIFLE_LARGE = preload("res://World/UiImages/rifle_large.png")
const SHOTGUN_LARGE = preload("res://World/UiImages/shotgun_large.png")
const BULLET_UI = preload("res://World/UiImages/bullet_ui.png")

@onready var texture_rect: TextureRect = $Control/TextureRect
@onready var bullet_count: TextureRect = $Control/Bullet_count
@onready var health_progress: ProgressBar = $Control/Health_progress
@onready var rich_text_label: RichTextLabel = $Control/RichTextLabel



	

func change_weapon_image(weapon, max_ammo):
	if weapon == "Rifle":
		texture_rect.texture = RIFLE_LARGE
		print(max_ammo)
		print(get_stored_ammo(weapon))
	elif weapon == "Pistol":
		texture_rect.texture = PISTOL_LARGE_1
		print(max_ammo)
		print(get_stored_ammo(weapon))
	elif weapon == "Shotgun":
		texture_rect.texture = SHOTGUN_LARGE
		print(max_ammo)
		print(get_stored_ammo(weapon))
	else:
		texture_rect.texture = null
		print(max_ammo)
	
	
func update_ammo(ammo):
	if ammo != null:
		bullet_count.size.x = BULLET_UI.get_width() * ammo
	else:
		bullet_count.size.x = BULLET_UI.get_width() * 0
		
func update_player_inventory_ammo_UI(player_inven_ammo):
	if player_inven_ammo != null:
		rich_text_label.text = ("/" + str(player_inven_ammo))
	else:
		rich_text_label.text = ("")

func get_stored_ammo(weapon):
	return GlobalReferences.player.player_inventory.AmmoTypes[weapon]
	
func update_health_progress(health):
	var tween = get_tree().create_tween()
	var max_value = GlobalReferences.player.health_component.MAX_HEALTH
	var health_value = (health / max_value) * 100
	tween.tween_property(health_progress, "value", health_value, 0.2)
	#health_progress.value = health_value
