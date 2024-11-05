extends Node2D;

const LETTER := preload("res://panel_container.tscn");

const MAPPINGS : Array[Dictionary] = [
	{
		0: 11,
		1: 0,
		2: 31,
		3: 27,
		4: 2,
		5: 25,
		6: 9,
		7: 22,
		8: 16,
		9: 7,
		10: 24,
		11: 29,
		12: 26,
		13: 21,
		14: 20,
		15: 3,
		16: 18,
		17: 14,
		18: 28,
		19: 19,
		20: 4,
		21: 12,
		22: 17,
		23: 32,
		24: 13,
		25: 33,
		26: 1,
		27: 10,
		28: 23,
		29: 30,
		30: 5,
		31: 6,
		32: 15,
		33: 8,
	},
	{
		0: 2,
		1: 9,
		2: 13,
		3: 14,
		4: 31,
		5: 4,
		6: 21,
		7: 18,
		8: 15,
		9: 33,
		10: 0,
		11: 5,
		12: 8,
		13: 29,
		14: 6,
		15: 27,
		16: 11,
		17: 10,
		18: 7,
		19: 30,
		20: 1,
		21: 23,
		22: 26,
		23: 24,
		24: 3,
		25: 25,
		26: 20,
		27: 19,
		28: 32,
		29: 16,
		30: 28,
		31: 22,
		32: 12,
		33: 17,
	},
	{
		0: 23,
		1: 14,
		2: 8,
		3: 18,
		4: 10,
		5: 25,
		6: 30,
		7: 26,
		8: 13,
		9: 9,
		10: 2,
		11: 28,
		12: 7,
		13: 4,
		14: 19,
		15: 27,
		16: 0,
		17: 11,
		18: 32,
		19: 3,
		20: 24,
		21: 12,
		22: 6,
		23: 20,
		24: 1,
		25: 29,
		26: 17,
		27: 33,
		28: 22,
		29: 5,
		30: 31,
		31: 15,
		32: 16,
		33: 21,
	},
];
# sorry they're not in order bc i was making that with python lol
const REFLECTOR_MAPPINGS := {
	0: 16,
	1: 19,
	2: 33,
	3: 21,
	4: 13,
	5: 29,
	6: 17,
	7: 9,
	8: 20,
	9: 7,
	10: 11,
	11: 10,
	12: 32,
	13: 4,
	14: 28,
	15: 22,
	16: 0,
	17: 6,
	18: 25,
	19: 1,
	20: 8,
	21: 3,
	22: 15,
	23: 26,
	24: 27,
	25: 18,
	26: 23,
	27: 24,
	28: 14,
	29: 5,
	30: 31,
	31: 30,
	32: 12,
	33: 2,
};
const ROTOR_SIZE = 34;

var rotors : Array[Dictionary] = MAPPINGS.duplicate(true);
# reflector stays in place

static var rotor_pos := [0, 0, 0];

var rotation_count := [0, 0, 0];

@onready var input_text : LineEdit = $InputText;

@onready var containers : Array[VBoxContainer] = [
	$Rotor1In,
	$Rotor1Out,
	$Rotor2In,
	$Rotor2Out,
	$Rotor3In,
	$Rotor3Out,
	$Reflector,
];

func _ready() -> void:
	var grid := $GridContainer;
	for i in rotors.size():
		if rotor_pos[i] != 0:
			for j in rotor_pos[i]:
				rotate_rotor(j); # couldn't be bothered with other stuff
		# 2i is the input rotor
		# 2i + 1 is the output rotor
		for j in rotors[i].size():
			var in_letter := LETTER.instantiate() as PanelContainer;
			in_letter.get_node("Label").text = (Globals.ALPHABET[j]
					if Globals.ALPHABET[j] != ' ' else '_');
			containers[2 * i].add_child(in_letter);
			var out_letter := LETTER.instantiate() as PanelContainer;
			out_letter.get_node("Label").text = (Globals.ALPHABET[j]
					if Globals.ALPHABET[j] != ' ' else '_');
			out_letter.modulate = Color.RED;
			containers[2 * i + 1].add_child(out_letter);
	for i in REFLECTOR_MAPPINGS.size():
		var letter := LETTER.instantiate() as PanelContainer;
		letter.get_node("Label").text = (Globals.ALPHABET[i]
					if Globals.ALPHABET[i] != ' ' else '_');
		# reflector
		containers[6].add_child(letter);
		letter.modulate = Color.YELLOW;
	queue_redraw();


# shift letters in i-th rotor
func shift_letters(i: int) -> void:
	var in_rotor := containers[2 * i];
	var out_rotor := containers[2 * i + 1];
	var in_letter := in_rotor.get_children()[0];
	var out_letter := out_rotor.get_children()[0];
	in_rotor.remove_child(in_letter);
	in_rotor.add_child(in_letter);
	out_rotor.remove_child(out_letter);
	out_rotor.add_child(out_letter);


func rotate_rotor(i: int) -> void:
	var old_mapping : Dictionary = rotors[i].duplicate();
	for j in range(0, ROTOR_SIZE - 1):
		rotors[i][j] = old_mapping[j + 1];
	rotors[i][ROTOR_SIZE - 1] = old_mapping[0];
	shift_letters(i);


# actually the rotor should rotate *before* the input signal
func rotate_rotors() -> void:
	rotate_rotor(0);
	rotation_count[0] += 1;
	if rotation_count[0] == ROTOR_SIZE:
		# rotate the second rotor
		rotation_count[0] = 0;
		rotate_rotor(1);
		rotation_count[1] +=1;
		if rotation_count[1] == ROTOR_SIZE:
			# rotate the third rotor (super rare)
			rotation_count[1] = 0;
			rotate_rotor(2);
			rotation_count[2] += 1;
			if rotation_count[2] == ROTOR_SIZE:
				# full rotation of the third rotor, do nothing else
				rotation_count[2] = 0;


func trigger(char: String) -> void:
	var tf_char := char;
	var tf_idx := Globals.ALPHABET.find(char);
	if tf_idx == -1:
		return;
	rotate_rotors();
	for i in 3:
		tf_idx = rotors[i][tf_idx];
	tf_idx = REFLECTOR_MAPPINGS[tf_idx];
	for i in 3: # 0 to 2, can't be bothered with reverse ranges
		tf_idx = rotors[2 - i].find_key(tf_idx);
	tf_char = Globals.ALPHABET[tf_idx];
	$OutputLabel.text += tf_char;
	queue_redraw();


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return;
	var last_char := new_text[-1];
	if not last_char.to_upper() in Globals.ALPHABET:
		input_text.text = input_text.text.erase(input_text.text.length() - 1);
		input_text.caret_column = 999;
	else:
		trigger(last_char.to_upper());


func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene();


func _draw() -> void:
	var reflector_temp := REFLECTOR_MAPPINGS.duplicate();
	# pop pairs of letters from the reflector cloned dict and join them
	# their X position depends only on the key though
	while (not reflector_temp.is_empty()):
		var key : int = reflector_temp[reflector_temp.keys()[0]];
		var val : int = reflector_temp[key];
		draw_polyline([
			containers[6].position + Vector2(25, 12.5 + 25 * key),
			containers[6].position + Vector2(50 + 15 * key, 12.5 + 25 * key),
			containers[6].position + Vector2(50 + 15 * key, 12.5 + 25 * val),
			containers[6].position + Vector2(25, 12.5 + 25 * val)
		], Color.CORAL, 3.0);
		reflector_temp.erase(key);
		reflector_temp.erase(val);
	
	for i in rotors.size():
		for j in rotors[i].size():
			draw_line(
				containers[2 * i].position + Vector2(25, 12.5 + 25 * j),
				containers[2 * i + 1].position + Vector2(0, 12.5 + 25 * (
					rotors[i][j]
				)),
				Color(Color.YELLOW, 0.5), 2);
