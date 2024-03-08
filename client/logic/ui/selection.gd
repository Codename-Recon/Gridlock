class_name Selection
extends Sprite2D

signal selection_changed(terrain: Terrain)

var _last_mouse_terrain: Terrain

@onready var _cursor: Cursor = $"../Cursor"

func _process(delta: float) -> void:
	if get_tree().has_group("terrain") and get_tree().get_nodes_in_group("terrain").size() > 0:
		var temp_terrain: Terrain = get_tree().get_nodes_in_group("terrain")[0]
		if temp_terrain.get_terrain_by_position(_cursor.get_tile_position()):
			var terrain: Terrain =  temp_terrain.get_terrain_by_position(_cursor.get_tile_position())
			# only update when mouse terrain has changed
			if terrain and _last_mouse_terrain != terrain:
				var tween: Tween = create_tween()
				tween.tween_property(self, "position", terrain.position, 0.05)
				selection_changed.emit(terrain)
			_last_mouse_terrain = terrain
