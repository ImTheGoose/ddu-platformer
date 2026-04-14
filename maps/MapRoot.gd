extends Node2D

class_name MapRoot 

const PREFIX :String = "[MapRoot] "

@export var terrain_tiles :TileMapLayer
@export var trap_tiles :TileMapLayer
@export var enemy_tiles :TileMapLayer
@export var collectable_tiles :TileMapLayer
@export var guide_tiles :TileMapLayer

const trap_tile_id_types :Dictionary[int, EntitySpawner.SpawnType] = {
	1 : EntitySpawner.SpawnType.TRAP_SPIKE,
	5 : EntitySpawner.SpawnType.TRAP_FIRE_PLATE,
	6 : EntitySpawner.SpawnType.TRAP_FALLING_PLATFORM,
	7 : EntitySpawner.SpawnType.TRAP_TRAMPOLINE,
	8 : EntitySpawner.SpawnType.TRAP_POWER_TRAMPOLINE,
	9 : EntitySpawner.SpawnType.TRAP_FANS,
	10 : EntitySpawner.SpawnType.TRAP_PATHFINDING_POINT,
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
	10 : EntitySpawner.SpawnType.BIG_ENEMY_PATHFINDING_POINT,
	11 : EntitySpawner.SpawnType.ENEMY_MOVING_HEAD,
	12 : EntitySpawner.SpawnType.ENEMY_SPIKED_MOVING_HEAD,
}

const collectable_tile_id_types :Dictionary[int, EntitySpawner.SpawnType] = {
	1 : EntitySpawner.SpawnType.COLLECTABLE_APPLE
}

func _enter_tree() -> void:
	if not terrain_tiles:
		print(PREFIX, "Terrain tiles not assigned to: %s" % scene_file_path.get_file())
	else:
		var shadow_tiles :TileMapLayer = terrain_tiles.duplicate()
		shadow_tiles.collision_enabled = false
		shadow_tiles.occlusion_enabled = false
		shadow_tiles.modulate = Color8(0,0,0, 50)
		shadow_tiles.z_index = -1
		add_child(shadow_tiles)
		shadow_tiles.position += Vector2(-2, 2)

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
		_spawn_tiles_from_types(trap_tiles, trap_tile_id_types)
	
	if enemy_tiles:
		_spawn_tiles_from_types(enemy_tiles, enemy_tile_id_types)
	
	if collectable_tiles:
		_spawn_tiles_from_types(collectable_tiles, collectable_tile_id_types)


func _spawn_tiles_from_types(tilemap: TileMapLayer, tile_id_collection: Dictionary[int, EntitySpawner.SpawnType], tile_modifier_collection :Dictionary[int, Array] = {}) -> void:
	for cell in tilemap.get_used_cells():
		var raw_id :int = tilemap.get_cell_alternative_tile(cell)
		var id :int = raw_id
		if not tile_id_collection.has(id): #Bit may be encoded with tranform data
			id = id & 0xFFF #Decodes id for any transform data. (Id 1 rotated 180 deg has raw_id 12289)

		if not tile_id_collection.has(id):
			var col_name :String = ""
			match tile_id_collection:
				trap_tile_id_types:
					col_name = "Traps"
				enemy_tile_id_types:
					col_name = "Enemies"
				collectable_tile_id_types:
					col_name = "Collectables"
			
			printerr("Tile missing for Id: %s with raw_id: %s for tilemap: %s in map: %s" % [id, raw_id, col_name, scene_file_path.get_file()])
			continue
	
		var has_h_flip :bool = bool(raw_id & TileSetAtlasSource.TRANSFORM_FLIP_H)
		var has_v_flip :bool = bool(raw_id & TileSetAtlasSource.TRANSFORM_FLIP_V)
		var has_transpose :bool = bool(raw_id & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
		var arr :Array[int] = []
		
		if not has_transpose:
			if has_v_flip:
				arr.append(Entity.EntityModifiers.ROTATE_180)
		else:
			if has_h_flip:
				arr.append(Entity.EntityModifiers.ROTATE_90)
			else:
				arr.append(Entity.EntityModifiers.ROTATE_270)
		
		var pos :Vector2 = tilemap.map_to_local(cell)
		var gpos :Vector2 = tilemap.to_global(pos)
		GameManager.spawn_entity.emit(gpos, tile_id_collection[id], arr)
		
	return
