class_name Menu extends Control


@onready var inventory:= Inventory.new()
@export var name_edit: LineEdit
@export var date_edit: LineEdit

@export var have_button: Button
@export var need_button: Button
@export var progress_bar: ProgressBar
@export var spacer_2: Control

@export var debug_message: RichTextLabel
@export var settings_tab: VBoxContainer

@export var authority_edit: LineEdit
@export var check_box: CheckBox


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

@export var pull_button: Button
@export var push_button: Button

const NONCE :String = "73fghu"
const PORT := 57488
const settings_file_path:=&"user://settings.json"
const items_path:=&"user://items.json"
const requests_path:=&"user://requests.json"
const backups_folder:=&"user://backups/"

var authority:String
const auth_key:=&"authority"

var server:bool
const server_key:=&"server"

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		main_menu.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		back()

func back() -> void:
	main_menu.visible = true

const default_settings:Dictionary = {
	auth_key: "localhost",
	server_key: false,
}

var tcp_server:TCPServer
var peers:Dictionary[StreamPeerTCP, bool]

func good_print(to_print:String) -> void:
	print(to_print)
	display_debug_message_in_menu.call_deferred(to_print)

func display_debug_message_in_menu(to_print:String) -> void:
	debug_message.text = to_print
	debug_message.self_modulate = Color.WHITE
	await get_tree().create_timer(1).timeout
	var tween := get_tree().create_tween()
	tween.tween_property(debug_message, "self_modulate", Color(Color.WHITE,0), 2)

func _ready() -> void:
	var settings:FileAccess
	if not FileAccess.file_exists(settings_file_path):
		settings = FileAccess.open(settings_file_path, FileAccess.WRITE)
		if not settings: 
			good_print("encountered: " + error_string(FileAccess.get_open_error()) + " while trying to open " + settings_file_path + " for writing")
			return
		settings.store_string(JSON.stringify(default_settings,"	",false))
		settings.close()
	settings = FileAccess.open(settings_file_path, FileAccess.READ)
	if not settings: 
		good_print("encountered: " + error_string(FileAccess.get_open_error()) + " while trying to open " + settings_file_path + " for reading")
		return
	var thing:Variant = JSON.parse_string(settings.get_as_text())
	if thing is not Dictionary: return
	var settings_dict:Dictionary = thing
	if auth_key not in thing: return
	authority = settings_dict[auth_key]
	@warning_ignore("unsafe_cast")
	server = settings_dict.get(server_key, false) as bool
	settings.close()
	if FileAccess.file_exists(items_path):
		var items_file := FileAccess.open(items_path, FileAccess.READ)
		if not items_file: 
			good_print("encountered: " + error_string(FileAccess.get_open_error()) + " while trying to open " + items_path + " for reading")
			return
		inventory.load_items_from_file(items_file)
		items_file.close()
	if FileAccess.file_exists(requests_path):
		var requests_file := FileAccess.open(requests_path, FileAccess.READ)
		if not requests_file: 
			good_print("encountered: " + error_string(FileAccess.get_open_error()) + " while trying to open " + requests_path + " for reading")
			return
		inventory.load_requests_from_file(requests_file)
		requests_file.close()
	have._on_filter_edit_text_changed()
	need._on_filter_edit_text_changed()
	#have_modification_row.visible = authority == "localhost"
	#save_button.visible = authority == "localhost"
	pull_button.visible = authority != "localhost"
	push_button.visible = authority != "localhost"
	if server:
		tcp_server = TCPServer.new()
		tcp_server.listen(PORT)

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
	inventory.export_items(items)
	items.close()
	save_settings()

func save_settings() -> void:
	var settings := FileAccess.open(settings_file_path, FileAccess.WRITE)
	if not settings: 
		good_print("encountered: " + error_string(FileAccess.get_open_error()) + " while trying to open " + settings_file_path + " for writing")
		return
	settings.store_string(JSON.stringify({auth_key: authority, server_key: server},"	",false))
	settings.close()

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
	#if time < Time.get_unix_time_from_system(): return
	intone_item(time, item_name)


func _on_have_button_pressed() -> void:
	have_tab.visible = true
	have.filter_changed.call_deferred()


func _on_save_button_pressed() -> void:
	save()



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

func get_my_truth_as_bytes() -> PackedByteArray:
	return (NONCE+"|" + inventory.items_to_text() + "|" + inventory.requests_to_text()).to_ascii_buffer()

func push_wrapper() -> void:
	push()
	set.call_deferred("net_lock", false)

func push() -> void:
	var stream := StreamPeerTCP.new()
	var error:= stream.connect_to_host(authority,PORT)
	if error != Error.OK:
		good_print(error_string(error))
		return
	var time_spent:int = 0
	while time_spent < 10_000:
		OS.delay_msec(20)
		time_spent+=20
		stream.poll()
		if stream.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED:
			if stream.get_status() != StreamPeerTCP.Status.STATUS_CONNECTING: 
				good_print("connection was terminated before we could send")
				return
			continue
		stream.put_data(get_my_truth_as_bytes())
		stream.disconnect_from_host()
		good_print("pushed data")
		return
	good_print("failed to establish connection to server")

func _on_push_button_pressed() -> void:
	net_lock=true
	if executor and executor.is_started():
		executor.wait_to_finish()
	executor = Thread.new()
	executor.start(push_wrapper)

func read_in_net_data(net_data:String) -> void:
	var parts := net_data.split("|")
	inventory.import_items(parts[1])
	inventory.import_requests(parts[2])
	have._on_filter_edit_text_changed()
	need._on_filter_edit_text_changed()
	#save()

func _process(_delta: float) -> void:
	if not server: return
	while tcp_server.is_connection_available():
		var peer := tcp_server.take_connection()
		peers[peer] = true
	for peer:StreamPeerTCP in peers.keys():
		peer.poll()
		if peer.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED and peer.get_status() != StreamPeerTCP.Status.STATUS_CONNECTING:
			peers.erase(peer)
			continue
		var message_size := peer.get_available_bytes()
		if message_size != 0:
			var message_parts : = peer.get_data(message_size)
			var error :Error= message_parts[0]
			if error != Error.OK:
				good_print("trying to read a message from %s, but encountered %s" % [peer.get_connected_host(), error_string(error)])
				return
			var bytes :PackedByteArray = message_parts[1]
			var text:=bytes.get_string_from_ascii()
			if text == "?":
				var put_error := peer.put_data(get_my_truth_as_bytes())
				if put_error != Error.OK:
					good_print("trying to send %s the current truth, but encountered %s" % [peer.get_connected_host(), error_string(put_error)])
			elif text.begins_with(NONCE):
				read_in_net_data(text)
				save()
			
var net_lock:bool:
	set(val):
		net_lock = val
		for button in [push_button, pull_button, save_button, have_button, need_button] as Array[Button]:
			button.disabled = net_lock
		progress_bar.visible = net_lock
		spacer_2.visible = not net_lock
var executor:Thread

func _on_pull_button_pressed() -> void:
	net_lock=true
	if executor and executor.is_started():
		executor.wait_to_finish()
	executor = Thread.new()
	executor.start(pull_wrapper)

func pull_wrapper() -> void:
	pull()
	set.call_deferred("net_lock", false)

func pull() -> void:
	var stream := StreamPeerTCP.new()
	var connection_error := stream.connect_to_host(authority,PORT)
	if connection_error != Error.OK:
		good_print("trying to connect to %s but encountered this error %s" % [authority + ":" + str(PORT), error_string(connection_error)])
		return
	var time_spent:int = 0
	var sent:bool = false
	while time_spent < 10_000:
		OS.delay_msec(20)
		time_spent+=20
		stream.poll()
		if stream.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED and stream.get_status() != StreamPeerTCP.Status.STATUS_CONNECTING:
			good_print("streampeer connection was dropped before we got a resonse")
			return
		if stream.get_status() != StreamPeerTCP.Status.STATUS_CONNECTED: continue
		if not sent:
			var send_error:= stream.put_data("?".to_ascii_buffer())
			if send_error != Error.OK:
				good_print("trying to request data from %s but encountered this error %s" % [authority + ":" + str(PORT), error_string(send_error)])
				return
			sent = true
		var message_size := stream.get_available_bytes()
		if message_size > 0:
			var message_parts : = stream.get_data(message_size)
			var error :Error= message_parts[0]
			if error != Error.OK:
				good_print("trying to read the current truth from %s, but encountered %s" % [stream.get_connected_host(), error_string(error)])
				return
			var bytes :PackedByteArray = message_parts[1]
			good_print("pulled data")
			read_in_net_data.call_deferred(bytes.get_string_from_ascii())
			return
	good_print("timed out waiting for response")


func _on_settings_button_pressed() -> void:
	settings_tab.visible = true
	check_box.set_pressed_no_signal(server)
	authority_edit.placeholder_text = authority
	authority_edit.text = ""

func _on_check_box_toggled(toggled_on: bool) -> void:
	server = toggled_on
	if server:
		tcp_server = TCPServer.new()
		var error:= tcp_server.listen(PORT)
		if error != Error.OK:
			good_print("trying to start server, but encountered %s" % error_string(error))
			return
	pull_button.visible = not server
	push_button.visible = not server

func _on_authority_edit_text_submitted(new_text: String) -> void:
	authority = new_text
