class_name TerrainDetector
extends Area2D



signal terrain_entered(terrain_type)

const bitmask: int = 255

enum TerrainType {
	WALL = 1
}

var current_tilemap: TileMap
