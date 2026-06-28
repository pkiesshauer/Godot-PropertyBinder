@tool
extends RefCounted
class_name PropertyBinderGroup

signal dirty_changed(new_dirty: bool)

var bindings: Array[PropertyBinder]
var _obj_ref: WeakRef
var _obj: Object:
	set(v):
		pass
	get():
		if _obj_ref == null: return null
		return _obj_ref.get_ref()
var dirty: bool:
	set(v):
		pass
	get():
		for b in bindings:
			if b.dirty: return true
		return false

func _init(obj: Object = null) -> void:
	if obj != null:
		_obj_ref = weakref(obj)

func assign_obj(obj: RefCounted):
	if obj != null:
		_obj_ref = weakref(obj)
		for pb in bindings:
			pb.assign_obj(obj)
	else:
		push_error("Can't assign a null Object to PropertyBinderGroup.")

## Add a new PropertyBinder to the PropertyBinderGroup.[br]
## [b]control[/b]: The Control Node to bind the property to.[br]
## [b]object_property_name[/b]: The property of the object that will be bound to the Control.[br]
## [b]control_property_overwrite[/b]: If left blank, the standard mapping will be used if available. Overwrite to bind to a different Control property.[br]
## [b]control_signal_overwrite[/b]: If left blank, the standard mapping will be used if available. Overwrite to connect a different signal. Set to "NONE" to ignore signal binding.
func add_binding(ctrl: Node, property: String, ctrl_property_overwrite: String = "", signal_overwrite: String = ""):
	var pb: PropertyBinder = PropertyBinder.new(ctrl, property, ctrl_property_overwrite, signal_overwrite)
	if _obj_ref != null:
		var obj = _obj_ref.get_ref()
		if not _obj_is_null(obj, property):
			if _obj_has_property(obj, property):
				pb.assign_obj(_obj_ref.get_ref())
	pb.dirty_changed.connect(_on_dirty_changed)
	bindings.push_back(pb)

func refresh_ui():
	if not _obj: return
	for pb in bindings:
		if not pb._obj:
			pb.assign_obj(_obj)
		else:
			pb._refresh_ui()

func _obj_is_null(obj: Object, property: String) -> bool:
	if obj == null:
		push_error("Can't bind property '" + property + "' on null Object")
		return true
	return false

func reverse():
	for b in bindings:
		b.reverse_changes()
	if _obj:
		_obj.notify_property_list_changed()

func _obj_has_property(obj: Object, property: String) -> bool:
	var pl = obj.get_property_list()
	for p in pl:
		if p["name"] == property:
			return true
	push_error("Property %s can't be found on Object." % property)
	return false

func _on_dirty_changed(new_dirty: bool):
	if new_dirty: dirty_changed.emit(true)
	else: dirty_changed.emit(dirty)
