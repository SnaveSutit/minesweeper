extends Node2D

signal on_reveal(tile)
signal on_flag(tile)

const TILE_TEX = preload ("res://sprites/tile.tres")
const BOMB_TEX = preload ("res://sprites/tile_bomb.tres")
const FLAG_TEX = preload ("res://sprites/tile_flag.tres")
const INCORRECT_FLAG_TEX = preload ("res://sprites/tile_incorrect_flag.tres")
const REVEALED_TEX = preload ("res://sprites/tile_revealed.tres")

@export var animationDuration = 0.25

@export var isBomb = false:
	set(value):
		isBomb = value
		_on_texture_update()
@export var isFlag = false:
	set(value):
		isFlag = value
		_on_texture_update()
@export var isRevealed = false:
	set(value):
		isRevealed = value
		_on_texture_update()

@onready var sprite: Sprite2D = $TileSprite
@onready var spriteSize: Vector2 = sprite.texture.get_size()
@onready var bombCountLabel: Label = $BombCountLabel

var bombs = 0:
	set(value):
		bombs = value
		if value > 0:
			bombCountLabel.text = str(value)
		else:
			bombCountLabel.text = ""
var animating = false

func _ready() -> void:
	sprite.texture = TILE_TEX
	bombCountLabel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if animating or isRevealed or not sprite.get_rect().has_point(to_local(event.position)):
			return

		if event.button_index == MOUSE_BUTTON_LEFT and not isFlag:
			reveal()

		elif event.button_index == MOUSE_BUTTON_RIGHT and not isRevealed:
			toggleFlag()

func reveal(sendSignal=true) -> void:
	if isRevealed:
		return
	var originalScale = scale
	var targetScale = scale * 1.2
	var tween = create_tween()
	tween.tween_property(self, 'scale', targetScale, animationDuration / 2) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		isRevealed=true
		bombCountLabel.show()
		if isBomb:
			bombCountLabel.text="X"
		if sendSignal: on_reveal.emit(self)
	)
	tween.tween_property(self, 'scale', originalScale, animationDuration / 2) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	tween.play()
	animating = true
	tween.finished.connect(func():
		animating=false
	)

func toggleFlag() -> void:
	var originalScale = scale
	var targetScale = scale * 1.2
	var tween = create_tween()
	tween.tween_property(self, 'scale', targetScale, animationDuration / 2) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		isFlag=!isFlag
		if isFlag: on_flag.emit(self)
	)
	tween.tween_property(self, 'scale', originalScale, animationDuration / 2) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	tween.play()
	animating = true
	tween.finished.connect(func(): animating=false)

func _on_texture_update():
	if isRevealed:
		if isBomb:
			if not isFlag:
				sprite.texture = BOMB_TEX
		elif isFlag:
			sprite.texture = INCORRECT_FLAG_TEX
		else:
			sprite.texture = REVEALED_TEX
	elif isFlag:
		sprite.texture = FLAG_TEX
	else:
		sprite.texture = TILE_TEX