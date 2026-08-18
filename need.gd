class_name Need extends ScrollableList

static func order_fulfillments(fill1:Fulfillment, fill2:Fulfillment) -> bool: return float(fill1.count)/fill1.requested_count < float(fill2.count)/fill2.requested_count

var requested_counts:Dictionary[String, int]:
	get:
		return menu.inventory.requests

func delete_row(row:int) -> void:
	var fulfillment:= fulfillments[row]
	requested_counts.erase(fulfillment.item_name)
	fulfillments.pop_at(row)
	filter_changed()

func get_list_length() -> int:
	return len(fulfillments)

var fulfillments:Array[Fulfillment]

func draw_text(y:float, index:int) -> void:
	var fulfillment:=fulfillments[index]
	var filled:=fulfillment.count/float(fulfillment.requested_count)
	var color:=Color.GREEN
	if filled >= 1: color = Color.AQUA
	draw_rect(Rect2(0,y+line_visual_offset,size.x*filled,-line_sep),Color(color,.1))
	draw_string(font, Vector2(0, y), fulfillment.item_name)
	draw_string(font, Vector2(size.x-500, y), str(fulfillment.count))
	draw_string(font, Vector2(size.x-300, y),str(fulfillment.requested_count),HORIZONTAL_ALIGNMENT_RIGHT,200)


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
		if not filter_regex.search(key): continue
		@warning_ignore("unsafe_call_argument")
		fulfillments.push_back(Fulfillment.new(key, filtered_counts.get(key,0), requested_counts[key]))
		
	fulfillments.sort_custom(order_fulfillments)
	
	filter_changed()
		
