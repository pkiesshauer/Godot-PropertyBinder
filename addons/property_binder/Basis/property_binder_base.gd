@tool
extends RefCounted
class_name PropertyBinder

# bool
# int
# float
# string

signal dirty_changed(dirty: bool)

const map: MappingLibrary = preload("res://addons/property_binder/Mapping/Map.tres")

var _obj_ref: WeakRef
var _ctrl_ref: WeakRef
var _property_name: String
var _property_type: Variant.Type = TYPE_NIL
var _ui_property_name: String
var _ui_property_type: Variant.Type
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
var _updating: bool
var dirty: bool:
	set(v):
		pass
	get():
		if _object_exists():
			if _obj.get(_property_name) == _original_value:
				return false
		return true

## Create a new PropertyBinder.[br]
## [b]control[/b]: The Control Node to bind the property to.[br]
## [b]object_property_name[/b]: The property of the object that will be bound to the Control.[br]
## [b]control_property_overwrite[/b]: If left blank, the standard mapping will be used if available. Overwrite to bind to a different Control property.[br]
## [b]control_signal_overwrite[/b]: If left blank, the standard mapping will be used if available. Overwrite to connect a different signal. Set to "NONE" to ignore signal binding.
func _init(control: Node, object_property_name: String, control_property_overwrite: String = "", control_signal_overwrite: String = "") -> void:
	_ctrl_ref = weakref(control)
	_property_name = object_property_name
	_ui_property_name = control_property_overwrite
	_signal_name = control_signal_overwrite

## Assign an object to the PropertyBinder.[br]
## The bound property will be synced between the Object and the Control.
func assign_obj(object: Object):
	_clean_old_obj()
	_obj_ref = weakref(object)
	if not _object_exists(): return
	_obj.property_list_changed.connect(_on_object_changed)
	_original_value = _obj.get(_property_name)
	_set_object_property_type()
	_connect_ctrl()
	_refresh_ui()

## Revert all changes made to the value of the property since the object was assigned with assign_obj().
func reverse_changes():
	if _object_exists():
		_obj.set(_property_name, _original_value)

func _clean_old_obj():
	if _obj == null: return
	if _obj.property_list_changed.is_connected(_on_object_changed):
		_obj.property_list_changed.disconnect(_on_object_changed)

func _set_object_property_type():
	if not _object_exists(): return
	var properties = _obj.get_property_list()
	for p in properties:
		if p["name"] == _property_name:
			_property_type = p["type"]

func _connect_ctrl():
	var control_name: String = _get_control_class_name()
	if control_name == "":
		push_error("Control class name could not be found.")
		return
	if control_name == "HSlider":
		print("Slider")
	if _ui_property_name == "":
		_ui_property_name = map.get_control_property_name(_property_type, control_name)
	if _signal_name == "":
		_signal_name = map.get_control_signal_name(_property_type, control_name)
	if _ui_property_name != "":
		_set_ui_property_type()
	else:
		push_error("No control property name found for %s." % control_name)
	_connect_signal()

func _set_ui_property_type():
	if not _ctrl_exists(): return
	var properties = _ctrl.get_property_list()
	for p in properties:
		if p["name"] == _ui_property_name:
			_ui_property_type = p["type"]

func _connect_signal():
	if _signal_name == "NONE": return
	if _signal_name == "":
		push_warning("Signalname is empty for PropertyBinding on %s." % _get_control_class_name())
	if not _ctrl_exists(): return
	if _ctrl.has_signal(_signal_name):
		if not _ctrl.is_connected(_signal_name, _on_ui_changed):
			_ctrl.connect(_signal_name, _on_ui_changed)
	else:
		push_warning("Signal %s not found on %s." % [_signal_name, _get_control_class_name()])

func _get_control_class_name() -> String:
	var control_name: String
	var script: Script
	if _ctrl_exists():
		script = _ctrl.get_script()
	if script != null:
		control_name = script.get_global_name()
	if control_name == "":
		control_name = _ctrl.get_class()
	return control_name

func _refresh_ui():
	if _updating: return
	if not _object_exists(): return
	if not _ctrl_exists(): return
	_updating = true
	var value: Variant = _obj.get(_property_name)
	_ctrl.set(_ui_property_name, type_convert(value, _ui_property_type))
	_updating = false

func _on_ui_changed(value):
	if _updating:
		return
	_updating = true
	if _object_exists():
		_obj.set(_property_name, type_convert(value, _property_type))
		_obj.notify_property_list_changed()
	dirty_changed.emit(dirty)
	_updating = false

func _on_object_changed():
	_refresh_ui()

func _object_exists() -> bool:
	if _obj:
		return true
	push_error("Bound Object has been removed.")
	return false

func _ctrl_exists() -> bool:
	if _ctrl:
		return true
	push_error("Bound Control has been removed.")
	return false
