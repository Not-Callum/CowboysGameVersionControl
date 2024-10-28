extends Node2D

var enemy_spawn_tokens : int = randi_range(5,20)

func _ready() -> void:
	SignalHandler.SpawnPointAvailable.connect(handle_enemy_spawning)
		

func handle_enemy_spawning(time):
	await get_tree().create_timer(time).timeout
	if enemy_spawn_tokens > 0:
		var enemySpawnPoints = get_tree().get_nodes_in_group("EnemySpawnPoints")
		if enemySpawnPoints:
			for spawnPoint in enemySpawnPoints:
				if spawnPoint.current_enemy == null:
					spawnPoint.spawnEnemy()
					enemy_spawn_tokens -= 1
					print(enemy_spawn_tokens)
