@tool
extends Resource
class_name MappingLibrary

@export var map: Array[PropertyMap]

func get_control_property_name(type: Variant.Type, control_name: String) -> String:
	var p: PropertyMap = get_property_map(type)
	if p == null: return ""
	for c in p.control_map:
		if c.control_type == control_name:
			return c.control_property
	return ""

func get_control_signal_name(type: Variant.Type, control_name: String) -> String:
	var p: PropertyMap = get_property_map(type)
	if p == null: return ""
	for c in p.control_map:
		if c.control_type == control_name:
			return c.control_signal
	return ""

func get_property_map(type: Variant.Type) -> PropertyMap:
	for p in map:
		if p.property_type == type:
			return p
	return null
