class_name Item extends RefCounted

var name:String
var expiry_time:int

func _init(name_in:String, expires_at:int) -> void:
	name = name_in
	expiry_time = expires_at
