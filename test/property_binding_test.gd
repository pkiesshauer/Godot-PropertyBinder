extends Control

@export var check_1: CheckBox
@export var check_2: CheckBox
@export var line_edit_1: LineEdit
@export var line_edit_2: LineEdit
@export var property_binder_group_node: PropertyBinderGroupNode


var test_data1: TestData
var test_data2: TestData
var pb1: PropertyBinder
var pb2: PropertyBinder
var pb1text: PropertyBinder
var pb2text: PropertyBinder

var pbg: PropertyBinderGroup

func _ready() -> void:
	test_data1 = new_test_data()
	test_data2 = new_test_data()
	setup1()
	setup2()

func setup2():
	property_binder_group_node.assign_obj(test_data1)

func setup1():
	pbg = PropertyBinderGroup.new(test_data1)
	pbg.add_binding(check_1, "check")
	pbg.add_binding(check_2, "check")
	pbg.add_binding(line_edit_1, "text")
	pbg.add_binding(line_edit_2, "text")

func setup():
	pb1 = PropertyBinder.new(check_1, "check")
	pb2 = PropertyBinder.new(check_2, "check")
	pb1text = PropertyBinder.new(line_edit_1, "text")
	pb2text = PropertyBinder.new(line_edit_2, "text")
	
	pb1.assign_obj(test_data1)
	pb2.assign_obj(test_data1)
	pb1text.assign_obj(test_data1)
	pb2text.assign_obj(test_data1)

func new_test_data() -> TestData:
	var td: TestData = TestData.new()
	td.check = true
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
