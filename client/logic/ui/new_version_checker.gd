extends Node

@export var OWNER: String = "Codename-Recon"
@export var REPO: String = "Codename-Recon"
@export var current_version_label: Label

@onready
var messages: GlobalMessages = $"/root/Messages"

class Version:
	var major: int
	var minor: int
	var patch: int
	var valid: bool = false
	
	static var VERSION_REGEX : RegEx = RegEx.create_from_string("v(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)")
	
	func _init(data: String)->void:
		var found: RegExMatch = VERSION_REGEX.search(data)
		if found:
			var _major : String = found.get_string("major")
			var _minor : String = found.get_string("minor")
			var _patch : String = found.get_string("patch")
			if _major.is_valid_int():
				self.major = int(_major)
			else:
				return;
			if _minor.is_valid_int():
				self.minor = int(_minor)
			else:
				return;
			if _patch.is_valid_int():
				self.patch = int(_patch)
			else:
				return;
			self.valid = true
				
	func compare(other: Version)->int:
		if major > other.major:
			return -1
		elif major < other.major:
			return 1
		elif minor > other.minor:
			return -1
		elif minor < other.minor:
			return 1
		elif patch> other.patch:
			return -1
		elif patch<other.patch:
			return 1
		else:
			return 0
			
	func _to_string() -> String:
		return "v%d.%d.%d" % [major, minor, patch]

func _ready() -> void:
	var request : HTTPRequest = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)
	request.request("https://api.github.com/repos/"+OWNER+"/"+REPO+"/releases")

func _filter_release(release: Dictionary)->bool:
	var tag_name: String = release.get('tag_name', '')
	var draft: bool = release.get('draft', false)
	var prerelease: bool = release.get('prerelease', false)
	
	var found : RegExMatch = Version.VERSION_REGEX.search(tag_name)
	return found != null && not draft && not prerelease
	

func _on_request_completed(result:int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var release_list : Array = JSON.parse_string(body.get_string_from_utf8())
	var valid_releases : Array = release_list.filter(_filter_release)
	if valid_releases.size()>0:
		var last_release : Dictionary = valid_releases[0]
		compare_with_current(last_release, current_version_label.text)

func load_release_data(release_data: Dictionary, version: Version) -> void:
	var notification_title : String = tr("Version {version} available!", "Notification title for a new version").format({version=release_data.get("tag_name")})
	var open: ButtonToUri = ButtonToUri.new()
	open.text = tr("Open", "Open notification in the browser")
	
	var details: Button = Button.new()
	details.text = tr("More details", "Open details of the notification")
	
	var notification : NotificationPanel = messages.spawn_notification(notification_title, [open, details], 0)
	
	open.uri_to_go = release_data.get("html_url")
	
	# Not sure about if we should or not close the notification
	open.pressed.connect(func () -> void: notification.close())
	details.pressed.connect(func ()->void: notification.close(); open_version_summary(release_data))
	
	#new_version.show()
	# print(release_data)
	#version_label.text = release_data.get("tag_name")
	#body_text.text = release_data.get("body", "No description in the last version")
	#markdown_text.markdown_text = release_data.get("body", "This release doesn't contain any description")
	#open_release.uri_to_go = release_data.get("html_url")
func open_version_summary(release_data: Dictionary) -> void :
	var title : String =  release_data.get("tag_name")
	var markdown_content : String = release_data.get("body", "No description in the last version")
	var button : ButtonToUri = ButtonToUri.new()
	button.text = tr("Open release", "Open release in the browser")
	button.uri_to_go = release_data.get("html_url")
	messages.spawn_markdown(title, markdown_content, button)


func compare_with_current(release_data: Dictionary, current: String) -> void:
	var curr_ver : Version = Version.new(current)
	var release_string: String = release_data.get('tag_name', '')
	var release: Version = Version.new(release_string)
	if curr_ver.valid and release.valid:
		if curr_ver.compare(release)>0:
			load_release_data(release_data, release)
