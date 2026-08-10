class_name Need extends Control
@export var menu: Menu
@export var need_tab: VBoxContainer
@export var filter_edit: LineEdit
@export var scroll_container: ScrollContainer

@export var font:Font

static func order_fulfillments(fill1:Fulfillment, fill2:Fulfillment) -> bool: return float(fill1.count)/fill1.requested_count < float(fill2.count)/fill2.requested_count

var requested_counts:Dictionary[String, int]:
	get:
		return menu.inventory.requests

func filter_changed() -> void:
	custom_minimum_size.y = len(fulfillments) * line_sep + 30 + 5

func _process(_delta: float) -> void:
	queue_redraw()

var fulfillments:Array[Fulfillment]

const line_sep:float = 25
func _draw() -> void:
	var y:float = 30
	var _top_pos:Vector2 = make_canvas_position_local(scroll_container.global_position)
	for fulfillment in fulfillments:
		draw_string(font, Vector2(0, y), fulfillment.item_name)
		draw_string(font, Vector2(200, y), str(fulfillment.count))
		draw_string(font, Vector2(size.x-200, y),str(fulfillment.requested_count),HORIZONTAL_ALIGNMENT_RIGHT,200)
		y+=line_sep

var filter_regex := RegEx.new()
func _on_filter_edit_text_changed(_new_text: String="") -> void:
	var error:=filter_regex.compile(filter_edit.text,false)
	filter_edit.self_modulate = Color.RED if error != Error.OK else Color.WHITE
	var filtered_counts:Dictionary[String, int]
	if error != Error.OK:
		filtered_counts = menu.inventory.counts
	else:
		for key in menu.inventory.counts:
			if filter_regex.search(key):
				filtered_counts[key] = menu.inventory.counts[key]
	fulfillments = []
	for key in requested_counts:
		@warning_ignore("unsafe_call_argument")
		fulfillments.push_back(Fulfillment.new(key, filtered_counts.get(key,0), requested_counts[key]))
		
	fulfillments.sort_custom(order_fulfillments)
	
	filter_changed()
		
