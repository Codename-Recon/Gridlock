extends Menu

var _multiplayer: GlobalMultiplayer = Multiplayer

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	if visible:
		await _multiplayer.nakama_log_out()
