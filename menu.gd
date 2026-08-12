class_name Menu extends Control


@onready var inventory:= Inventory.new()
@export var name_edit: LineEdit
@export var date_edit: LineEdit

@export var name_name_edit: LineEdit
@export var number_edit: LineEdit

@export var intone_2_indicator: ColorRect
@export var need: Need
@export var need_tab: VBoxContainer


@export var intone_indicator: ColorRect
@export var have: Have
@export var main_menu: VBoxContainer
@export var have_tab: VBoxContainer
@export var have_modification_row: HBoxContainer
@export var save_button: Button
@export var sync_button: Button


const settings_file_path:=&"user://settings.json"
const items_path:=&"user://items.json"
const requests_path:=&"user://requests.json"
const backups_folder:=&"user://backups/"

var authority:String
const auth_key:=&"authority"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		main_menu.visible = true

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
	have._on_filter_edit_text_changed()
	need._on_filter_edit_text_changed()
	have_modification_row.visible = authority == "localhost"
	save_button.visible = authority == "localhost"
	sync_button.visible = authority != "localhost"

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

func get_item_name(edit:LineEdit) -> String:
	var current := edit.text.to_lower()
	return current

func _on_week_button_pressed() -> void:
	future_item(Have.day * 7)

func _on_month_button_pressed() -> void:
	future_item(Have.month)

func _on_year_button_pressed() -> void:
	future_item(Have.year)

func future_item(future_amount:int) -> void:
	var item_name := get_item_name(name_edit)
	if item_name == "": return
	intone_item(int(Time.get_unix_time_from_system()) + future_amount, item_name)

func flash_indicator(indicator:ColorRect) -> void:
	if indicator_tween: indicator_tween.kill()
	indicator_tween = get_tree().create_tween()
	indicator.color = Color(indicator.color, 1)
	indicator_tween.tween_property(indicator, "color", Color(indicator.color, 0), 1)

@onready var indicator_tween :Tween
func intone_item(time:int, item_name:String) -> void:
	flash_indicator(intone_indicator)
	var new_item:= Item.new(item_name, time)
	var list_position := inventory.items.bsearch_custom(new_item,func(item1:Item, item2:Item) -> bool: return item1.expiry_time<item2.expiry_time)
	inventory.items.insert(list_position, new_item)
	inventory.counts[new_item.name] = inventory.counts.get(new_item.name, 0) + 1
	have._on_filter_edit_text_changed()

const month_to_month:Dictionary[String, int] = {
	"jan": 1,
	"feb": 2,
	"mar": 3,
	"apr": 4,
	"may": 5,
	"jun": 6,
	"jul": 7,
	"aug": 8,
	"sep": 9,
	"oct": 10,
	"nov": 11,
	"dec": 12,
}

func _on_text_submitted(_new_text: String) -> void:
	var item_name := get_item_name(name_edit)
	if item_name == "": return
	var date_string :String = date_edit.text
	var parts:= date_string.split(" ")
	var month:int
	if parts[0] not in month_to_month: 
		if not parts[0].is_valid_int(): return
		month = int(parts[0])
	else:
		month = month_to_month[parts[0]]
	var year:= int(parts[2])
	if len(parts[2]) == 2:
		year += 2000
	var time_dict := {"month": month, "day": int(parts[1]), "year":year, "hour":23, "minute":59, "second":59}
	var time := Time.get_unix_time_from_datetime_dict(time_dict)
	if time < Time.get_unix_time_from_system(): return
	intone_item(time, item_name)


func _on_have_button_pressed() -> void:
	have_tab.visible = true
	have.filter_changed.call_deferred()


func _on_save_button_pressed() -> void:
	var items_file := FileAccess.open(items_path, FileAccess.WRITE)
	inventory.export_items(items_file)
	items_file.close()
	var requests_file := FileAccess.open(requests_path, FileAccess.WRITE)
	inventory.export_requests(requests_file)
	requests_file.close()


func _on_sync_button_pressed() -> void:
	pass # Replace with function body.


func _on_need_submitted(_new_text: String) -> void:
	var item_name := get_item_name(name_name_edit)
	if item_name == "": return
	var requested_number_text:String = number_edit.text
	if not requested_number_text.is_valid_int(): return
	var request:int = int(requested_number_text)
	if request < 1: return
	flash_indicator(intone_2_indicator)
	inventory.requests[item_name] = request
	need._on_filter_edit_text_changed()
	


func _on_need_button_pressed() -> void:
	need_tab.visible = true
	need.filter_changed.call_deferred()
