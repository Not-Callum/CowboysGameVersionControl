extends CharacterBody2D
@onready var collision_pickup: Area2D = $CollisionPickup

var ammo_to_pickup
var ammotype

func _ready() -> void:
	randomize()
	ammotype = get_meta("AmmoType")
	
	collision_pickup.PickedUp.connect(give_ammo_to_player)
	
func give_ammo_to_player():
	ammo_to_pickup = randi_range(3, 10)
	SignalHandler.ammoPickedUp.emit(ammotype, ammo_to_pickup)
	queue_free.call_deferred()
