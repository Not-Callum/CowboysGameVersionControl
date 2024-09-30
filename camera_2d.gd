extends Camera2D

@export var randomStrength: float = 1.5
@export var shakeFade: float = 8.0

var rnd = RandomNumberGenerator.new()

var shake_strength: float = 0.0


	
func _ready() -> void:
	SignalHandler.doCameraShake.connect(apply_camera_shake)
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		
		offset = random_offset()

func apply_camera_shake(randomStrength, shakeFade):
	#print("shake applied")
	shake_strength = randomStrength
	
func random_offset() -> Vector2:
	return Vector2(rnd.randf_range(-shake_strength, shake_strength), rnd.randf_range(-shake_strength, shake_strength))
