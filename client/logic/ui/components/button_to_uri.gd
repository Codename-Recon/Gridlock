extends GameButton

@export var uri: String

func _pressed() -> void:
	super._pressed()
	var error : Error = OS.shell_open(uri)
	if error:
		printerr("Error(%d) opening the link '%s' " % [error, uri])
