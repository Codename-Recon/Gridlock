extends GameButton

@export var uri_to_go: String


func _pressed() -> void:
	super._pressed()
	var error: Error = OS.shell_open(uri_to_go)
	if error:
		printerr("Error(%d) opening the link '%s' " % [error, uri_to_go])
