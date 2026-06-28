extends Sprite2D
class_name TestSprite
@onready var label: Label = $Label

var speed: int = 100
var posx: int
var vel: int

func _ready() -> void:
	vel = speed

func _physics_process(delta: float) -> void:
	if position.x > 1000: vel = -speed
	if position.x < 500: vel = speed
	position.x += vel * delta
	posx = global_position.x
