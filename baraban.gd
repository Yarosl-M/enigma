class_name Baraban extends Polygon2D;

@export var number : int;
var next : Baraban = null;
@onready var rotations : int = 0;


func rotate_1() -> void:
	var old = rotations;
	rotations = (rotations + 1) % 34;
	if old == 33 and next != null:
		next.rotate_1();


func _draw() -> void:
	pass
