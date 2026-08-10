class_name Fulfillment extends Resource

@export var item_name:String
@export var count:int
@export var requested_count:int

func _init(name_in:String, count_in:int, requested_count_in:int) -> void:
	item_name = name_in
	count = count_in
	requested_count = requested_count_in
