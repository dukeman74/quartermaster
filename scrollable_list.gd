class_name ScrollableList extends Control

@export var menu: Menu
@export var filter_edit: LineEdit
@export var scroll_container: ScrollContainer
@export var font:Font

const line_sep:int = 25
const line_visual_offset:int = 8
const line_offset:int = 60

var filter_regex := RegEx.new()

func get_row(pos:float) -> int:
	return floor((pos-line_offset-line_visual_offset + line_sep)/line_sep)

func x_over_x(pos:float) -> bool:
	return pos>size.x-40 and pos<size.x-20

func get_list_length() -> int:
	return 10

func _process(_delta: float) -> void:
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event :InputEventMouseButton = event
		if not mouse_event.button_index == MOUSE_BUTTON_LEFT: return
		if not mouse_event.pressed: return
		if not x_over_x(mouse_event.position.x): return
		var mouse_row:int = get_row(mouse_event.position.y)
		if get_list_length() <= mouse_row: return
		delete_row(mouse_row)

func draw_x(y:float, extra:bool) -> void:
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
		if index < 0 or index >= get_list_length(): continue
		draw_item_index(index, index == mouse_row)

func draw_item_index(index:int, extra:bool = false) -> void:
	var y := index*line_sep+line_offset
	draw_line(Vector2(0,y+line_visual_offset), Vector2(size.x,y+line_visual_offset),Color(Color.WHITE,.1))
	if extra:
		draw_rect(Rect2(0,y+line_visual_offset,size.x,-line_sep),Color(Color.WHITE,.1))
	draw_text(y, index)
	draw_x(y, extra)

@warning_ignore("unused_parameter")
func draw_text(y:float, index:int) -> void:
	pass

@warning_ignore("unused_parameter")
func delete_row(row:int) -> void:
	pass

func filter_changed() -> void:
	var needed_size:= get_list_length() * line_sep + line_offset
	if needed_size >= scroll_container.size.y/2:
		@warning_ignore("narrowing_conversion")
		needed_size += scroll_container.size.y/2
	custom_minimum_size.y =  needed_size
