extends Node2D

class_name MapRoot 

const PREFIX :String = "[MapRoot] "

@export var terrain_tiles :TileMapLayer
@export var trap_tiles :TileMapLayer
@export var enemy_tiles :TileMapLayer
@export var collectable_tiles :TileMapLayer
@export var guide_tiles :TileMapLayer

const trap_tile_id_modifiers :Dictionary[int, Array] = {
	2 : [Entity.EntityModifiers.ROTATE_180],
	3 : [Entity.EntityModifiers.ROTATE_90],
	4 : [Entity.EntityModifiers.ROTATE_270],
}

const trap_tile_id_types :Dictionary[int, EntitySpawner.SpawnType] = {
	1 : EntitySpawner.SpawnType.TRAP_SPIKE,
	2 : EntitySpawner.SpawnType.TRAP_SPIKE,
	3 : EntitySpawner.SpawnType.TRAP_SPIKE,
	4 : EntitySpawner.SpawnType.TRAP_SPIKE,
	5 : EntitySpawner.SpawnType.TRAP_FIRE_PLATE,
	6 : EntitySpawner.SpawnType.TRAP_FALLING_PLATFORM,
	7 : EntitySpawner.SpawnType.TRAP_TRAMPOLINE,
	8 : EntitySpawner.SpawnType.TRAP_POWER_TRAMPOLINE,
}

const enemy_tile_id_types :Dictionary[int, EntitySpawner.SpawnType] = {
	1 : EntitySpawner.SpawnType.ENEMY_PATHFINDING_POINT,
	2 : EntitySpawner.SpawnType.ENEMY_MUSHROOM,
	4 : EntitySpawner.SpawnType.ENEMY_TRUNK,
	5 : EntitySpawner.SpawnType.ENEMY_PLANT,
	6 : EntitySpawner.SpawnType.ENEMY_BIRD,
	7 : EntitySpawner.SpawnType.ENEMY_GHOST,
	8 : EntitySpawner.SpawnType.ENEMY_ROCKS_BIG,
	9 : EntitySpawner.SpawnType.ENEMY_FAT_BIRD,
}

const collectable_tile_id_types :Dictionary[int, EntitySpawner.SpawnType] = {
	1 : EntitySpawner.SpawnType.COLLECTABLE_APPLE
}

func _enter_tree() -> void:
	if not terrain_tiles:
		print(PREFIX, "Terrain tiles not assigned to: %s" % scene_file_path.get_file())

	if trap_tiles:
		trap_tiles.enabled = false
	else:
		print(PREFIX, "Trap tiles not assigned to: %s" % scene_file_path.get_file())
		
	if enemy_tiles:
		enemy_tiles.enabled = false
	else:
		print(PREFIX, "Enemy tiles not assigned to: %s" % scene_file_path.get_file())
		
	if collectable_tiles:
		collectable_tiles.enabled = false
	else:
		print(PREFIX, "Collectable tiles not assigned to: %s" % scene_file_path.get_file())
		
	if guide_tiles:
		guide_tiles.enabled = false
	else:
		print(PREFIX, "GUIDE tiles not assigned to: %s" % scene_file_path.get_file())

func _ready() -> void:
	if trap_tiles:
		_spawn_tiles_from_types(trap_tiles, trap_tile_id_types, trap_tile_id_modifiers)
	
	if enemy_tiles:
		_spawn_tiles_from_types(enemy_tiles, enemy_tile_id_types)
	
	if collectable_tiles:
		_spawn_tiles_from_types(collectable_tiles, collectable_tile_id_types)


func _spawn_tiles_from_types(tilemap: TileMapLayer, tile_id_collection: Dictionary[int, EntitySpawner.SpawnType], tile_modifier_collection :Dictionary[int, Array] = {}) -> void:
	for id: int in tile_id_collection.keys():
		var tiles :Array[Vector2i] = tilemap.get_used_cells_by_id(-1, Vector2i(-1,-1), id)
		for tile:Vector2i in tiles:
			var pos :Vector2 = tilemap.map_to_local(tile)
			var gpos :Vector2 = tilemap.to_global(pos)
			var arr :Array[int] = []
			arr.assign(tile_modifier_collection.get(id, []))
			GameManager.spawn_entity.emit(gpos, tile_id_collection[id], arr)
	return
