class_name Have extends Control
@export var menu: Menu
@export var have_tab: VBoxContainer
@export var filter_edit: LineEdit
@export var scroll_container: ScrollContainer

@export var font:Font

func get_row(pos:float) -> int:
	return floor((pos-line_offset-line_visual_offset + line_sep)/line_sep)

func x_over_x(pos:float) -> bool:
	return pos>size.x-40 and pos<size.x-20

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event :InputEventMouseButton = event
		if not mouse_event.button_index == MOUSE_BUTTON_LEFT: return
		if not mouse_event.pressed: return
		if not x_over_x(mouse_event.position.x): return
		var mouse_row:int = get_row(mouse_event.position.y)
		if len(items) <= mouse_row: return
		var true_index:int = menu.inventory.items.find(items[mouse_row])
		menu.inventory.items.pop_at(true_index)
		items.pop_at(mouse_row)
		filter_changed()
		

func filter_changed() -> void:
	var needed_size:= len(items) * line_sep + line_offset
	if needed_size >= scroll_container.size.y/2:
		@warning_ignore("narrowing_conversion")
		needed_size += scroll_container.size.y/2
	custom_minimum_size.y =  needed_size

func _process(_delta: float) -> void:
	queue_redraw()

var items:Array[Item]
const minute:int = 60
const hour:int = minute*60
const day:int = hour*24
const month:int = day*30
const year:int = month*12
func happy_time(expiry:int) -> String:
	var delta_t := expiry - Time.get_unix_time_from_system()
	if delta_t < 0: return "Expired"
	if delta_t < 1: return "0"
	if delta_t > year:
		@warning_ignore("integer_division")
		var years := int(delta_t) / year
		return ">%d years" % years
	if delta_t > month:
		@warning_ignore("integer_division")
		var months := int(delta_t) / month
		return ">%d months" % months
	if delta_t > day:
		@warning_ignore("integer_division")
		var days := int(delta_t) / day
		return ">%d days" % days
	@warning_ignore("integer_division")
	var hours:int = int(delta_t)/hour
	@warning_ignore("integer_division")
	var minutes:int = int(delta_t)/minute
	var second:int = posmod(int(delta_t), minute)
	return "%02d:%02d:%02d" % [hours, minutes, second]

const line_sep:int = 25
const line_visual_offset:int = 8
const line_offset:int = 60
func draw_item_index(item:Item, index:int, extra:bool = false) -> void:
	var y := index*line_sep+line_offset
	draw_line(Vector2(0,y+line_visual_offset), Vector2(size.x,y+line_visual_offset),Color(Color.WHITE,.1))
	if extra:
		draw_rect(Rect2(0,y+line_visual_offset,size.x,-line_sep),Color(Color.WHITE,.1))
	draw_string(font, Vector2(0, y),item.name)
	draw_string(font, Vector2(size.x-200, y),happy_time(item.expiry_time),HORIZONTAL_ALIGNMENT_RIGHT,140)
	var color := Color.WHITE
	if extra and x_over_x(get_local_mouse_position().x):
		color = Color.RED
	draw_string(font, Vector2(size.x-200, y),"X",HORIZONTAL_ALIGNMENT_RIGHT,180, 16, color)

func _draw() -> void:
	var top_pos:Vector2 = make_canvas_position_local(scroll_container.global_position)
	@warning_ignore("integer_division")
	var mouse_row:int= get_row(get_local_mouse_position().y)
	@warning_ignore("narrowing_conversion")
	var rows_to_display:int = scroll_container.size.y/line_sep + 2
	for index in rows_to_display:
		index += int(top_pos.y/line_sep) - 2
		if index < 0 or index >= len(items): continue
		var item:=items[index]
		draw_item_index(item, index, index == mouse_row)

var filter_regex := RegEx.new()
func _on_filter_edit_text_changed(_new_text: String="") -> void:
	var error:=filter_regex.compile(filter_edit.text,false)
	filter_edit.self_modulate = Color.RED if error != Error.OK else Color.WHITE
	if error != Error.OK:
		items = menu.inventory.items
		filter_changed()
		return
	items = []
	for item in menu.inventory.items:
		if filter_regex.search(item.name):
			items.append(item)
	filter_changed()
		
