extends RefCounted
class_name NumberFix

func fix() -> void:
	for prop: Dictionary in get_property_list():
		if prop['type'] == TYPE_INT:
			var name: String = prop['name']
			var value: float = get(name)
			set(name, int(str(value)))
		if prop['type'] == TYPE_ARRAY and prop['hint_string'] == "int":
			print(prop)
			var name: String = prop['name']
			var value: Array = get(name)
			for i: int in value.size():
				value[i] = int(str(value[i]))
