class_name Maze
extends RefCounted

@export var dimensions: Vector2i = Vector2i(1, 1)
@export var choose_cell_weights: Array[float] = [0.0, 0.0, 1.0]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var grid: Array[Array]  # Array[Array[MazeCell]]
var start: Vector2i
var end: Vector2i
var walls: Array[Vector2i] = []:
	get:
		if len(walls) != 0:
			return walls
		# Outer Walls
		walls.append_array(
			[
				Vector2i.ZERO,
				Vector2i(dimensions.x, 0),
				Vector2i.ZERO,
				Vector2i(0, dimensions.y),
				Vector2i(dimensions.x, 0),
				dimensions,
				Vector2i(0, dimensions.y),
				dimensions
			]
		)
		# Inner Walls
		for y in range(dimensions.y):
			for x in range(dimensions.x):
				var cell := Vector2i(x, y)
				# Right Wall
				if (
					not grid[cell.y][cell.x].right_open
					and cell.x < dimensions.x - 1
				):
					walls.append_array(
						[Vector2i(x + 1, y), Vector2i(x + 1, y + 1)]
					)
				# Bottom Wall
				if (
					not grid[cell.y][cell.x].down_open
					and cell.y < dimensions.y - 1
				):
					walls.append_array(
						[Vector2i(x, y + 1), Vector2i(x + 1, y + 1)]
					)
		return walls


func can_travel_to(cell: Vector2i, destination: Vector2i) -> bool:
	var direction: Vector2i = destination - cell
	return can_travel_in(cell, direction)


func can_travel_in(cell: Vector2i, direction: Vector2i) -> bool:
	var dst := cell + direction
	match direction:
		Vector2i.UP:
			return Vector2i.ZERO <= cell and grid[dst.y][dst.x].down_open
		Vector2i.DOWN:
			return grid[cell.y][cell.x].down_open
		Vector2i.LEFT:
			return Vector2i.ZERO <= cell and grid[dst.y][dst.x].right_open
		Vector2i.RIGHT:
			return grid[cell.y][cell.x].right_open
		_:
			return false


func is_inbounds(cell: Vector2i) -> bool:
	return (
		0 <= cell.x
		and cell.x < dimensions.x
		and 0 <= cell.y
		and cell.y < dimensions.y
	)


func follow_branch(
	last_cell: Vector2i, curr_cell: Vector2i, ignore_straights := true
) -> Array[Vector2i]:
	if not can_travel_to(last_cell, curr_cell):
		return []
	var result: Array[Vector2i] = []
	while true:
		if not ignore_straights:
			result.append(curr_cell)
		var valid_neighbors: Array[Vector2i] = []
		var is_straight: bool = true
		for neighbor: Vector2i in [
			curr_cell + Vector2i(-1, 0),
			curr_cell + Vector2i(1, 0),
			curr_cell + Vector2i(0, -1),
			curr_cell + Vector2i(0, 1),
		]:
			if neighbor != last_cell and can_travel_to(curr_cell, neighbor):
				valid_neighbors.push_back(neighbor)
				if (
					(neighbor - last_cell).x != 0
					and (neighbor - last_cell).y != 0
				):
					is_straight = false
		if ignore_straights and not is_straight:
			result.append(curr_cell)
		if len(valid_neighbors) != 1:
			if len(result) == 0 or result[-1] != curr_cell:
				result.append(curr_cell)
			return result
		last_cell = curr_cell
		curr_cell = valid_neighbors[0]
	return result


func new_maze(
	_new_dimensions: Vector2i = Vector2i.ZERO, rng_seed: int = 0
) -> void:
	if rng_seed == 0:
		rng.randomize()
	else:
		rng.seed = rng_seed

	_generate()
	var start_end := furthest_pair()
	start = start_end[0]
	end = start_end[1]
	walls.clear()


func furthest_pair() -> Array[Vector2i]:
	var furthest1 := furthest_point(Vector2i(0, 0))
	return [furthest1, furthest_point(furthest1)]


func furthest_point(from: Vector2i) -> Vector2i:
	var distances: Array[Array] = []  # int
	for i in range(len(grid)):
		distances.append([])
		distances[i].resize(len(grid[i]))
		distances[i].fill(INF)
	var cells: Array[Vector2i] = [from]
	var furthest: Vector2i = cells[0]
	distances[furthest.y][furthest.x] = 0
	while not cells.is_empty():
		var cell: Vector2i = cells.pop_back()
		if distances[cell.y][cell.x] > distances[furthest.y][furthest.x]:
			furthest = cell
		for next: Vector2i in [
			cell + Vector2i(-1, 0),
			cell + Vector2i(1, 0),
			cell + Vector2i(0, -1),
			cell + Vector2i(0, 1),
		]:
			if (
				can_travel_to(cell, next)
				and distances[next.y][next.x] > distances[cell.y][cell.x] + 1
			):
				distances[next.y][next.x] = distances[cell.y][cell.x] + 1
				cells.push_back(next)
	return furthest


func _choose_cell(
	cells: Array[Vector2i],
) -> Vector2i:
	match rng.rand_weighted(choose_cell_weights):
		0:  # Breadth First
			return cells[0]
		1:  # Depth First
			return cells[-1]
		2:  # Random
			return cells[rng.randi_range(0, len(cells) - 1)]
		_:
			push_error("Undefined case in `choose_cell`")
			return cells[0]


func _generate() -> void:
	# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm.html

	# Make Base Grid
	#const grid: Array[Array[int]] = []
	grid = []
	for y in range(dimensions.y):
		grid.append([])
		for x in range(dimensions.x):
			grid[y].append(MazeCell.new())

	# Get vector's neightbors in a random order
	var rand_neighbors := func(cell: Vector2i) -> Array[Vector2i]:
		var neighbors: Array[Vector2i] = [
			cell + Vector2i(-1, 0),
			cell + Vector2i(1, 0),
			cell + Vector2i(0, -1),
			cell + Vector2i(0, 1),
		]
		var t: Vector2i

		for m in range(3, 0 - 1, -1):
			var i: int = rng.randi_range(0, m)
			t = neighbors[i]
			neighbors[i] = neighbors[m]
			neighbors[m] = t
		return neighbors

	# Generate tree
	var cells: Array[Vector2i] = [
		Vector2i(
			rng.randi_range(0, dimensions.x - 1),
			rng.randi_range(0, dimensions.y - 1),
		)
	]
	grid[cells[0].y][cells[0].x].visited = true
	while not cells.is_empty():
		var cell: Vector2i = _choose_cell(cells)
		var found_neighbor: bool = false
		for next_cell: Vector2i in rand_neighbors.call(cell):
			if (
				is_inbounds(next_cell)
				and not grid[next_cell.y][next_cell.x].visited
			):
				found_neighbor = true
				cells.push_back(next_cell)
				grid[next_cell.y][next_cell.x].visited = true
				match next_cell - cell:
					Vector2i.UP:
						grid[next_cell.y][next_cell.x].down_open = true
					Vector2i.DOWN:
						grid[cell.y][cell.x].down_open = true
					Vector2i.LEFT:
						grid[next_cell.y][next_cell.x].right_open = true
					Vector2i.RIGHT:
						grid[cell.y][cell.x].right_open = true
				break
		if not found_neighbor:
			cells.remove_at(cells.find(cell))


class MazeCell:
	#var up_open := false
	var down_open := false
	#var left_open := false
	var right_open := false
	var visited := false
