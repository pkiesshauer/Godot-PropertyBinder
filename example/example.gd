extends Control




var test_data1: TestData
var test_data2: TestData

# for setup1
var pb1_check: PropertyBinder
var pb1_text: PropertyBinder
var pb1_spin: PropertyBinder
var pb1_progress: PropertyBinder
var pb1_slider: PropertyBinder

@export var check_1: CheckBox
@export var line_edit_1: LineEdit
@export var spin_box_1: SpinBox
@export var progress_bar_1: ProgressBar
@export var h_slider_1: HSlider

# for setup2
var pbg: PropertyBinderGroup
@export var check_2: CheckBox
@export var line_edit_2: LineEdit
@export var spin_box_2: SpinBox
@export var progress_bar_2: ProgressBar
@export var h_slider_2: HSlider


# for setup3
@export var property_binder_group_node: PropertyBinderGroupNode


func _ready() -> void:
	test_data1 = new_test_data()
	test_data2 = new_test_data()
	setup1()
	setup2()
	setup3()

## This is an example of how to use PropertyBinders without a PropertyBinderGroup.
func setup1():
	pb1_check = PropertyBinder.new(check_1, "check")
	pb1_text = PropertyBinder.new(line_edit_1, "text")
	pb1_spin = PropertyBinder.new(spin_box_1, "integer")
	pb1_progress = PropertyBinder.new(progress_bar_1, "number")
	pb1_slider = PropertyBinder.new(h_slider_1, "number", "value", "value_changed")
	
	pb1_check.assign_obj(test_data1)
	pb1_text.assign_obj(test_data1)
	pb1_spin.assign_obj(test_data1)
	pb1_progress.assign_obj(test_data1)
	pb1_slider.assign_obj(test_data1)

## This is an example of how to use PropertyBinderGroup.
func setup2():
	pbg = PropertyBinderGroup.new(test_data1)
	pbg.add_binding(check_2, "check")
	pbg.add_binding(line_edit_2, "text")
	pbg.add_binding(spin_box_2, "integer")
	pbg.add_binding(progress_bar_2, "number")
	pbg.add_binding(h_slider_2, "number")

# Alternatively, the object can be assigned after adding the bindings:
#func setup2():
	#pbg = PropertyBinderGroup.new()
	#pbg.add_binding(check_1, "check")
	#pbg.add_binding(check_2, "check")
	#pbg.add_binding(line_edit_1, "text")
	#pbg.add_binding(line_edit_2, "text")
	#pbg.assign_obj(test_data1)


## This is an example of how to use PropertyBinderGroupNode.
## Please look at the node tree to see how the nodes are configured.
func setup3():
	property_binder_group_node.assign_obj(test_data1)

func new_test_data() -> TestData:
	var td: TestData = TestData.new()
	td.check = true
	td.integer = randi_range(0, 100)
	td.number = randf_range(0, 100)
	td.text = "Test" + random_letters(5)
	return td

func random_letters(count: int) -> String:
	var s: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var text: String
	for i in count:
		text += s[randi() % s.length()]
	return text


func _on_button_pressed() -> void:
	pbg.assign_obj(test_data1)
	property_binder_group_node.assign_obj(test_data1)


func _on_button_2_pressed() -> void:
	pbg.assign_obj(test_data2)
	property_binder_group_node.assign_obj(test_data2)
