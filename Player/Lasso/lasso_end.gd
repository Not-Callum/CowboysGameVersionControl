extends CharacterBody2D

signal CaughtByLasso
signal PulledByLasso
@onready var myParent = get_parent()
@onready var main = GlobalReferences.main
@onready var player : CharacterBody2D = self.get_tree().get_first_node_in_group("Player")
var lineDraw = preload("res://Effects/draw_line.tscn")


enum {
	UNTIED,
	TIED,
	PULLED,
	
}
var state = UNTIED

const LASSO_SPEED = 300
const LASSO_ACCELERATION = 400

func _ready() -> void:
	SignalHandler.cancelledAbility.connect(disconnectLasso)
	self.hide()
	#print(player)

func _physics_process(delta: float) -> void:
	match state:
		TIED:
			
			pulledByLasso()
		PULLED:
			await get_tree().create_timer(0.1).timeout
			emit_signal("PulledByLasso")
			self.remove_from_group("Lassoed")
			state = UNTIED
		UNTIED:
			pass
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Ive been hit by something")
	if area.get_parent().name == "LassoThrow":
		print("caught by lasso throw")
		#rint("Caught lasso")
		emit_signal("CaughtByLasso")
		self.show()
		self.add_to_group("Lassoed")
		var linedraw_instance = lineDraw.instantiate()
		main.add_child.call_deferred(linedraw_instance)
		state = TIED

		
func pulledByLasso():
	#rint(state)
	#rint(myParent.global_position.distance_to(player.global_position))
	if myParent.global_position.distance_to(player.global_position) >= 70:
		get_slight_pull_to_player()
	
	
func disconnectLasso():
	for node in get_tree().get_nodes_in_group("Lassoed"):
		node.remove_from_group("Lassoed")
	self.hide()
	SignalHandler.Untied.emit()
	state = UNTIED

func get_pulled_to_player():
	#print("yank received")
	
	if state == TIED:
		#rint("yanked")
		var direction = (player.global_position - myParent.global_position).normalized()
		myParent.velocity = myParent.velocity + (direction * LASSO_SPEED)
		self.hide()
		SignalHandler.Untied.emit()
		state = PULLED
		
func get_slight_pull_to_player():
	var direction = (player.global_position - myParent.global_position).normalized()
	myParent.velocity = myParent.velocity + (direction * 30)
	
