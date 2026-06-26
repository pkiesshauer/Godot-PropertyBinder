extends RefCounted
class_name PropertyBinder

# bool
# int
# float
# string

signal dirty_changed(dirty: bool)

const map: MappingLibrary = preload("res://addons/property_binder/Basis/Mapping/Map.tres")

var _obj_ref: WeakRef
var _ctrl_ref: WeakRef
var _property_name: String
var _property_type: Variant.Type = TYPE_NIL
var _ui_property_name: String
var _original_value: Variant
var _signal_name: String
var _obj: Object:
	set(v):
		pass
	get():
		if _obj_ref == null: return null
		return _obj_ref.get_ref()
var _ctrl: Control:
	set(v):
		pass
	get():
		if _ctrl_ref == null: return null
		return _ctrl_ref.get_ref()
var updating: bool
var dirty: bool:
	set(v):
		pass
	get():
		var obj = _obj_ref.get_ref()
		if obj:
			if obj.get(_property_name) == _original_value:
				return false
		return true

func _init(ctrl: Node, obj_property_name: String) -> void:
	_ctrl_ref = weakref(ctrl)
	_property_name = obj_property_name

func assign_obj(obj: Object):
	if _obj_ref != null:
		_clean_old_obj()
	_obj_ref = weakref(obj)
	obj.property_list_changed.connect(_on_object_changed)
	_original_value = obj.get(_property_name)
	_find_property_type()
	_connect_ctrl()

func _clean_old_obj():
	var obj: Object = _obj
	if obj == null: return
	if obj.property_list_changed.is_connected(_on_object_changed):
		obj.property_list_changed.disconnect(_on_object_changed)


func reverse_changes():
	if _obj:
		_obj.set(_property_name, _original_value)

func _find_property_type():
	var obj: Object = _obj
	if obj == null: return
	var properties = obj.get_property_list()
	for p in properties:
		if p["name"] == _property_name:
			_property_type = p["type"]

func _connect_ctrl():
	var control_name: String = _get_control_class_name()
	if control_name != "":
		_ui_property_name = map.get_control_property_name(_property_type, control_name)
		_signal_name = map.get_control_signal_name(_property_type, control_name)
		if _ui_property_name != "":
			_refresh_ui()
		else:
			printerr("No control property name found.")
		if _signal_name != "":
			_connect_signal()
		else:
			printerr("No control signal found.")
	else:
		printerr("Control class name could not be found.")

func _connect_signal():
	var ctrl: Control = _ctrl
	if ctrl == null:
		printerr("Bound Control has been removed.")
		return
	if ctrl.has_signal(_signal_name):
		if not ctrl.is_connected(_signal_name, _on_ui_changed):
			ctrl.connect(_signal_name, _on_ui_changed)
	else:
		printerr("Signal %s not found on %s." % [_signal_name, _get_control_class_name()])

func _get_control_class_name() -> String:
	var control_name: String
	var ctrl: Control = _ctrl
	var script: Script
	if ctrl != null:
		script = ctrl.get_script()
	if script != null:
		control_name = script.get_global_name()
	if control_name == "":
		control_name = ctrl.get_class()
	return control_name

func _refresh_ui():
	if updating: return
	var obj = _obj
	var ctrl = _ctrl
	if not obj:
		printerr("Bound Object has been removed.")
		return
	if not ctrl:
		printerr("Bound Control has been removed.")
		return
	updating = true
	var value: Variant = obj.get(_property_name)
	ctrl.set(_ui_property_name, value)
	updating = false

func _on_ui_changed(value):
	if updating:
		return
	updating = true
	var obj = _obj
	if obj:
		obj.set(_property_name, value)
		obj.notify_property_list_changed()
	dirty_changed.emit(dirty)
	updating = false

func _on_textedit_changed():
	var ctrl = _ctrl
	if not ctrl:
		printerr("Bound Control has been removed.")
		return
	_on_ui_changed(ctrl.text)

func _on_object_changed():
	_refresh_ui()

func int_to_string(value: int) -> String:
	return str(value)
