class_name Menu extends Control


@onready var inventory:= Inventory.new()

const settings_file_path:=&"user://settings.json"
const items_path:=&"user://items.json"
const requests_path:=&"user://requests.json"
const backups_folder:=&"user://backups/"

var authority:String
const auth_key:=&"authority"

const default_settings:Dictionary = {
	auth_key: "localhost"
}

func _ready() -> void:
	var settings:FileAccess
	if not FileAccess.file_exists(settings_file_path):
		settings = FileAccess.open(settings_file_path, FileAccess.WRITE)
		if not settings: 
			print("encountered: ", error_string(FileAccess.get_open_error()), " while trying to open ", settings_file_path, " for writing")
			return
		settings.store_string(JSON.stringify(default_settings,"	",false))
		settings.close()
	settings = FileAccess.open(settings_file_path, FileAccess.READ)
	if not settings: 
		print("encountered: ", error_string(FileAccess.get_open_error()), " while trying to open ", settings_file_path, " for reading")
		return
	var thing:Variant = JSON.parse_string(settings.get_as_text())
	if thing is not Dictionary: return
	if auth_key not in thing: return
	authority = thing[auth_key]
	settings.close()
	if FileAccess.file_exists(items_path):
		var items_file := FileAccess.open(items_path, FileAccess.READ)
		if not items_file: 
			print("encountered: ", error_string(FileAccess.get_open_error()), " while trying to open ", items_path, " for reading")
			return
		inventory.import_items(items_file)
		items_file.close()
	if FileAccess.file_exists(requests_path):
		var requests_file := FileAccess.open(requests_path, FileAccess.READ)
		if not requests_file: 
			print("encountered: ", error_string(FileAccess.get_open_error()), " while trying to open ", requests_path, " for reading")
			return
		inventory.import_requests(requests_file)
		requests_file.close()
	var items := inventory.items
	items.append(Item.new("bongo", Time.get_unix_time_from_system() + 100))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	items.append(Item.new("bongo", 781907))
	items.append(Item.new("bgongo", 7819027))
	items.append(Item.new("shmgongo", 78127))
	$TabContainer/HaveTab/ScrollContainer/Have.items = inventory.items
	$TabContainer/HaveTab/ScrollContainer/Have.filter_changed()

func save() -> void:
	if not DirAccess.dir_exists_absolute(backups_folder):
		DirAccess.make_dir_absolute(backups_folder)
	if FileAccess.file_exists(requests_path):
		DirAccess.rename_absolute(requests_path, backups_folder + "requests")
	if FileAccess.file_exists(items_path):
		DirAccess.rename_absolute(items_path, backups_folder + "items")
	var requests:= FileAccess.open(requests_path,FileAccess.WRITE)
	inventory.export_requests(requests)
	requests.close()
	var items:= FileAccess.open(items_path,FileAccess.WRITE)
	inventory.export_requests(items)
	items.close()

	
