extends GridContainer

@onready var terrain_name: Label = %Terrain
@onready var terrain_icon: TextureRect = %TerrainIcon
@onready var defence_label: Label = %DefLabel
@onready var capture_icon: TextureRect = %CapIcon
@onready var capture_label: Label = %CapLabel
@onready var unit_name: Label = %Unit
@onready var unit_icon: TextureRect = %UnitIcon
@onready var hp_label: Label = %HPLabel
@onready var ammo_icon: TextureRect = %AmmoIcon
@onready var ammo_label: Label = %AmmoLabel
@onready var fuel_label: Label = %FuelLabel


func _ready() -> void:
	pass # Replace with function body.
	

func _update(terrain: Terrain) -> void:
	if not terrain:
		terrain_name.visible = false
		return
	terrain_name.visible = true
	terrain_name.text = tr(terrain.id)
	defence_label.text = str(terrain.values.defense)
	terrain_icon.texture = terrain.sprite.texture
	if terrain.values.can_capture:
		capture_icon.visible = true
		capture_label.visible = true
		var terrain_stats: TerrainStats = terrain.stats
		capture_label.text = str(terrain_stats.capture_health / 10.0)
		terrain_icon.material = terrain.sprite.material
		(terrain_icon.material as ShaderMaterial).set_shader_parameter("shifting", terrain.color)
	else:
		capture_icon.visible = false
		capture_label.visible = false
		terrain_icon.material = null
	var unit: Unit = terrain.get_unit()
	if unit:
		unit_icon.visible = true
		unit_icon.texture = unit.get_texture()
		unit_icon.material = unit.get_shader_material()
		(unit_icon.material as ShaderMaterial).set_shader_parameter("shifting", unit.color)
		unit_name.visible = true
		unit_name.text = unit.id
		var unit_stats: UnitStats = unit.stats
		hp_label.text = str(unit_stats.health / 10.0)
		if unit_stats.ammo > -1:
			ammo_icon.visible = true
			ammo_label.visible = true
			ammo_label.text = str(unit_stats.ammo)
		else:
			ammo_icon.visible = false
			ammo_label.visible = false
		fuel_label.text = str(unit_stats.fuel)
	else:
		unit_icon.visible = false
		unit_name.visible = false
