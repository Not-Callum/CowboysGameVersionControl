extends Area2D
var playerNearby: bool = false
@export var ammoStored: Node2D
var weaponSpawn
@onready var player : CharacterBody2D = self.get_tree().get_first_node_in_group("Player")
@onready var highlight: Sprite2D = $Highlight

var canPickup:bool = false
signal PickedUp

func _ready() -> void:
	highlight.visible = false
	await get_tree().create_timer(2).timeout
	canPickup = true
	
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("pickup") and playerNearby == true and canPickup == true:
			#addToPlayer()
	pass
			
func addToPlayer():
	player.addWeapon(get_parent())
	#SignalHandler.cancelledAbility.emit()
	PickedUp.emit()

func _on_area_entered(area: Area2D) -> void:
	#print("Area entered")
	var layer = area.get_collision_mask()
	#print(layer)
	if layer == 2:
		#print("i touched a player")
		self.get_parent().velocity = Vector2.ZERO
		#print("true")

func _on_area_exited(area: Area2D) -> void:
	var layer = area.get_collision_mask()
	if layer == 2:
		self.get_parent().velocity = Vector2.ZERO
		
func playerIsNear():
	playerNearby = true
	#print("true")
	
func playerIsNotNear():
	playerNearby = false
	#print("false")
	
func doHighlight():
	
	if highlight.visible == false:
		#print("i am do highlight")
		highlight.visible = true
		
func unhighlight():
	
	if highlight.visible == true:
		#print("i am undo highlight")
		highlight.visible = false
