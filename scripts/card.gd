extends Node2D
class_name Card

signal card_played(card_id)

var card_id: int
var original_position: Vector2
var dragging := false

@onready var label: Label = $Label
@onready var card_image: Sprite2D = $CardImage
@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.input_event.connect(_on_area_input)

func _on_area_input(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			original_position = global_position
			z_index = 100
		else:
			dragging = false
			z_index = 0
			_check_drop()

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()

func setup(_card_id: int) -> void:
	card_id = _card_id
	var data = CardDatabase.get_card(card_id)
	label.text = data.get("name", "???")
	if data.get("sprite", "") != "":
		card_image.texture = load(data["sprite"])

func _check_drop() -> void:
	var overlapping = area.get_overlapping_areas()
	for other_area in overlapping:
		if other_area.is_in_group("play_area"):
			emit_signal("card_played", card_id)
			return
			
	# Se não soltou em cima de nenhuma area do jogo ela volta pra m
	global_position = original_position
