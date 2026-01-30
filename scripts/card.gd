extends Control
class_name Card

var card_id: int
var original_position: Vector2
var dragging := false

@onready var image: TextureRect = $TextureRect
@onready var label: Label = $Label

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			original_position = global_position
			z_index = 100
		else:
			dragging = false
			z_index = 0
			_check_drop()

	elif event is InputEventMouseMotion and dragging:
		global_position += event.relative
		
func setup(_card_id: int) -> void:
	card_id = _card_id
	var data = CardDatabase.get_card(card_id)
	
	label.text = data.name
	image.texture = load(data.sprite)
	
func _check_drop() -> void:
	var play_area = get_tree().get_first_node_in_group("play_area")

	if play_area == null:
		# não achou área de jogo (volta)
		global_position = original_position
		return

	if play_area.get_global_rect().has_point(get_global_mouse_position()):
		emit_signal("card_played", card_id)
		queue_free()
	else:
		# drop inválido (volta pra posição original)
		global_position = original_position
