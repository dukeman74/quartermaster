class_name Inventory extends Node

var items:Array[Item]
var counts:Dictionary[String, int]
var requests:Dictionary[String, int]

func import_items(file:FileAccess) -> void:
	items = []
	counts = {}
	var imported:Variant = JSON.parse_string(file.get_as_text())
	if imported is not Array: return
	for thing:Variant in imported:
		if thing is not Dictionary: continue
		var dict :Dictionary = thing
		if len(dict) != 1: return
		for key:Variant in dict.keys():
			if key is not String: continue
			var key_string:String = key
			key_string = key_string.to_lower()
			var value:Variant = thing[key_string]
			if value is not float: continue
			var float_time:float = value
			var time:int = int(float_time)
			items.append(Item.new(key_string, time))
			counts[key_string] = counts.get(key_string, 0) + 1
	items.sort_custom(func(a:Item, b:Item) -> bool: return a.expiry_time < b.expiry_time)
	
func export_items(file:FileAccess) -> void:
	file.store_string(JSON.stringify(items,"	",false))

func import_requests(file:FileAccess) -> void:
	requests = {}
	var imported:Variant = JSON.parse_string(file.get_as_text())
	if imported is not Dictionary: return
	var dict :Dictionary = imported
	for key:Variant in dict.keys():
		if key is not String: continue
		var key_string:String = key
		key_string = key_string.to_lower()
		var value:Variant = dict[key_string]
		if value is not float: continue
		var float_count:float = value
		var count:int = int(float_count)
		requests[key_string] = count

func export_requests(file:FileAccess) -> void:
	file.store_string(JSON.stringify(requests,"	",false))
