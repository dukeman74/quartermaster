class_name Have extends ScrollableList


func delete_row(row:int) -> void:
	var true_index:int = menu.inventory.items.find(items[row])
	menu.inventory.items.pop_at(true_index)
	menu.inventory.counts[items.pop_at(row).name] -= 1
	filter_changed()

func get_list_length() -> int:
	return len(items)

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

func draw_text(y:float, index:int) -> void:
	var item:=items[index]
	draw_string(font, Vector2(0, y),item.name)
	draw_string(font, Vector2(size.x-200, y),happy_time(item.expiry_time),HORIZONTAL_ALIGNMENT_RIGHT,140)


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
		
