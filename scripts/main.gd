extends Node

const TILE = preload ("res://scenes/tile.tscn")
@export var boardSize = Vector2(16, 16)
@export var tileSize = Vector2(32, 32)
@export var tileMargin = Vector2(4, 4)

@onready var winLabel: Label = $WinLabel
@onready var loseLabel: Label = $LoseLabel

var grid = []
var bombCount = 0

func _ready() -> void:
	winLabel.hide()
	loseLabel.hide()

	var windowSizeY = get_viewport().size.y
	boardSize = round(Vector2(windowSizeY, windowSizeY) / tileSize) - Vector2(2, 2)
	build_grid()

func get_neighbors(tile) -> Array:
	var neighbors = []
	var i = grid.find(tile)
	for x in range( - 1, 2):
		for y in range( - 1, 2):
			if x == 0 and y == 0:
				continue
			var pos = Vector2(i % int(boardSize.x), i / int(boardSize.x)) + Vector2(x, y)
			if pos.x < 0 or pos.x >= boardSize.x or pos.y < 0 or pos.y >= boardSize.y:
				continue
			neighbors.append(grid[int(pos.x + pos.y * boardSize.x)])
	return neighbors

func build_grid() -> void:
	if grid.size() > 0:
		for tile in grid:
			tile.queue_free()
	grid.clear()

	var windowSize = Vector2(get_viewport().size)
	var start = (windowSize - boardSize * (tileSize + tileMargin)) / 2 \
			+ (tileSize + tileMargin) / 2

	for x in range(boardSize.x):
		for y in range(boardSize.y):
			var tile = TILE.instantiate()
			add_child(tile)
			grid.append(tile)
			tile.position = start + Vector2(x, y) * (tileSize + tileMargin)
			tile.scale = tileSize / tile.spriteSize
			if randf() > 0.8:
				tile.isBomb = true
				bombCount += 1
				tile.bombs = -1
			tile.on_reveal.connect(on_tile_revealed)
			tile.on_flag.connect(on_tile_flagged)

	for i in range(grid.size()):
		var tile = grid[i]
		var bombs = 0
		if not tile.isBomb:
			var neighbors = get_neighbors(tile)
			for neighbor in neighbors:
				if neighbor.isBomb:
					bombs += 1
			tile.bombs = bombs

func on_tile_revealed(tile) -> void:
	if tile.isBomb:
		loseLabel.show()
		for otherTile in grid:
			otherTile.reveal(false)
	else:
		reveal_neighbors(tile)

func on_tile_flagged(tile) -> void:
	var correctly_flagged = 0
	for otherTile in grid:
		if otherTile.isBomb and otherTile.isFlag:
			correctly_flagged += 1
	if correctly_flagged == bombCount:
		winLabel.show()

func reveal_neighbors(tile) -> void:
	var neighbors = get_neighbors(tile)
	for neighbor in neighbors:
		if not neighbor.animating \
				and not neighbor.isRevealed \
				and not neighbor.isFlag \
				and not neighbor.isBomb \
				and (neighbor.bombs <= 1 or tile.bombs == 0):
			neighbor.reveal()
