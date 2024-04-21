extends GridContainer

var _types: GlobalTypes = Types

@onready var terrainName: Label = %Terrain
@onready var terrainIcon: TextureRect = %TerrainIcon

@onready var defenceLabel: Label = %DefLabel

@onready var captureIcon: TextureRect = %CapIcon
@onready var captureLabel: Label = %CapLabel

@onready var unitName: Label = %Unit
@onready var hpLabel: Label = %HPLabel
@onready var ammoIcon: TextureRect = %AmmoIcon
@onready var ammoLabel: Label = %AmmoLabel
@onready var fuelLabel: Label = %FuelLabel

func _ready() -> void:
	pass # Replace with function body.

#func _process(delta):
#	pass

func _update(terrain: Terrain) -> void:
	if terrain == null:
		terrainName.visible = false
		return
	terrainName.visible = true
	var terrainType: Dictionary = _types.terrains[terrain.id]
	terrainName.text = terrainType["name"]
	defenceLabel.text = str(terrainType["defense"])
	terrainIcon.texture = (terrain.get_node("Sprite2D") as Sprite2D).texture
	if terrainType["can_capture"]:
		captureIcon.visible = true
		captureLabel.visible = true
		var stats: TerrainStats = terrain.get_node("TerrainStats")
		captureLabel.text = str(stats.capture_health / 10.0)
		terrainIcon.material = (terrain.get_node("Sprite2D") as Sprite2D).material
		#print(terrain.color)
		#print(terrainIcon.material)
		(terrainIcon.material as ShaderMaterial).set_shader_parameter("shifting", terrain.color)
	else:
		captureIcon.visible = false
		captureLabel.visible = false
		terrainIcon.material = null
	var unit: Unit = terrain.get_unit()
	if unit:
		unitName.visible = true
		unitName.text = unit.id
		var unitStats: UnitStats = unit.stats
		hpLabel.text = str(unitStats.health / 10.0)
		if unitStats.ammo > -1:
			ammoIcon.visible = true
			ammoLabel.visible = true
			ammoLabel.text = str(unitStats.ammo)
		else:
			ammoIcon.visible = false
			ammoLabel.visible = false
		fuelLabel.text = str(unitStats.fuel)
	else:
		unitName.visible = false
