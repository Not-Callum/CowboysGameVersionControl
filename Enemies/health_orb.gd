extends CharacterBody2D

@onready var collision_pickup: Area2D = $CollisionPickup

var health_added = 35


func _ready() -> void:
	collision_pickup.PickedUp.connect(give_health_to_player)

func give_health_to_player():
	SignalHandler.healthPickedUp.emit(health_added)
	queue_free.call_deferred()
