@tool
extends Node
class_name PropertyBinderGroupNode

@export var target: Node
@export var process_ui: bool
var _pbg: PropertyBinderGroup
var _obj: Object

func assign_obj(obj: Object):
	_obj = obj
	if _pbg:
		_pbg.assign_obj(obj)

func _ready() -> void:
	_obj = target
	setup_binder.call_deferred()

func setup_binder():
	_pbg = PropertyBinderGroup.new(_obj)
	for c in get_children():
		if c is PropertyBinderNode:
			_bind_child(c)

func _physics_process(delta: float) -> void:
	if process_ui:
		if _pbg: _pbg.refresh_ui()

func _bind_child(pbn: PropertyBinderNode):
	_pbg.add_binding(pbn.control, pbn.object_property_name)

func _get_configuration_warnings() -> PackedStringArray:
	var s: PackedStringArray
	if get_child_count() == 0:
		s.push_back("Requires PropertyBindingNode-children to function.")
	return s
