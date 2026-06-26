@tool
extends RefCounted
class_name PropertyBinderOld

signal dirty_changed(dirty: bool)

var _obj_ref: WeakRef
var _ctrl_ref: WeakRef
var _property_name: String
var _property_type: Variant.Type = TYPE_NIL
var _ui_property_name: String
var original_value
var updating: bool
var dirty: bool:
	set(v):
		pass
	get():
		var obj = _obj_ref.get_ref()
		if obj:
			if obj.get(_property_name) == original_value:
				return false
		return true


func _init(obj: RefCounted, property: String, ctrl: Node) -> void:
	_obj_ref = weakref(obj)
	original_value = obj.get(property)
	_ctrl_ref = weakref(ctrl)
	_property_name = property
	obj.property_list_changed.connect(_on_object_changed)
	var properties = obj.get_property_list()
	for p in properties:
		if p["name"] == _property_name:
			_property_type = p["type"]
			if ctrl is SpinBox:
				ctrl.value_changed.connect(_on_ui_changed)
				_ui_property_name = "value"
			elif ctrl is LineEdit:
				ctrl.text_changed.connect(_on_ui_changed)
				_ui_property_name = "text"
			elif ctrl is TextEdit:
				ctrl.text_changed.connect(_on_textedit_changed)
				_ui_property_name = "text"
			elif ctrl is Label:
				_ui_property_name = "text"
			elif ctrl is CheckBox:
				ctrl.toggled.connect(_on_ui_changed)
				_ui_property_name = "button_pressed"
	
	if _ui_property_name != "":
		_refresh_ui()

func _refresh_ui():
	if updating: return
	var obj = _obj_ref.get_ref()
	var ui = _ctrl_ref.get_ref()
	if not obj:
		printerr("Bound Object has been removed.")
		return
	if not ui:
		printerr("Bound Control has been removed.")
		return
	updating = true
	ui.set(_ui_property_name, obj.get(_property_name))
	updating = false

func reverse_changes():
	var obj = _obj_ref.get_ref()
	if obj:
		obj.set(_property_name, original_value)

func _on_ui_changed(value):
	if updating:
		return
	updating = true
	var obj = _obj_ref.get_ref()
	if obj:
		obj.set(_property_name, value)
		obj.notify_property_list_changed()
	dirty_changed.emit(dirty)
	updating = false

func _on_textedit_changed():
	var ui = _ctrl_ref.get_ref()
	if not ui:
		printerr("Bound Control has been removed.")
		return
	_on_ui_changed(ui.text)



func _on_object_changed():
	_refresh_ui()
