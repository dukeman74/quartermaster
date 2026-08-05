class_name Request extends Resource

@export var item_name:String
@export var count:int

func _init(name_in:String, count_in:int) -> void:
	item_name = name_in
	count = count_in
