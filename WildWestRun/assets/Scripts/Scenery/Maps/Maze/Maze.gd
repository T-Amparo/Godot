extends GridMap
tool

# Captura as configurações do Labirinto.

var _options: Control = preload("res://assets/Scripts/Main/Options/Options.gd").new()

# Configura a mecânica para geração do Labirinto.

var _width = _options.Maze_Width
var _height = _options.Maze_Height
var _padding = _options.Maze_Padding

var _block_size = _options.Maze_Block_Size
var _block_extents = _options.Maze_Block_Extents

# Define um classe que ira gerar o Labirinto.

class Maze:
	
	var random = RandomNumberGenerator.new()
	
	var halls = []
	var maze = [[], []]
	
	var _width
	var _height
	var _padding
	
	var _fill
	var _empty
	
	func _init(width=10, height=10, padding=4, fill=1, empty=0):
		
		_width = width
		_height = height
		_padding = padding
		
		_fill = fill
		_empty = empty
		
		_run()
		
	func _to_string():
		
		var maze_asc = _maze_asc()
		
		var string = ''
		
		for _i in range(len(maze_asc)):
			
			for _j in maze_asc[_i]:
				
				for _k in _j:
				
					string += str(_k)
					
			string += '\n'
			
		return string
		
	func _run():
		
		for _i in range(_height):
			
			halls.append(_vector_fill(_empty, _width, _fill))
			
		halls += [_vector_fill(_fill, _width + 1)]
		
		for _i in range(_height + 1):
			
			if _i < _height: 
				
				maze[0].append(_vector_fill(_vector_fill(_empty, _padding, _fill, true), _width, _vector_fill(_fill, 1)))
			
			maze[1].append(_vector_fill(_vector_fill(_fill, _padding, _fill, true), _width, _vector_fill(_fill, 1)))
			
		maze[0] += [[]]
		
		random.randomize()
		
		_walk(Vector2(random.randi_range(0, _width - 1), random.randi_range(0, _height - 1)))
		
		maze = _zip(maze[1], maze[0], _padding)
		
	func _walk(coordinate):
		
		halls[coordinate.y][coordinate.x] = 1
		
		var directions = [
			
			Vector2(coordinate.x - 1, coordinate.y), 
			Vector2(coordinate.x, coordinate.y + 1), 
			Vector2(coordinate.x + 1, coordinate.y),
			Vector2(coordinate.x, coordinate.y - 1)
			
		]
		
		directions.shuffle()
		
		for direction in directions:
			
			if halls[direction.y][direction.x]: 
				
				continue
				
			if (direction.x == coordinate.x): 
				
				maze[1][max(coordinate.y, direction.y)][coordinate.x] = _vector_fill(_empty, _padding, _fill, true)
				
			if (direction.y == coordinate.y): 
				
				maze[0][coordinate.y][max(coordinate.x, direction.x)] = _vector_fill(_empty, _padding + 1, _empty, true)
				
			_walk(Vector2(direction.x, direction.y))
			
	func _zip(vectorA, vectorB, padding=1):
		
		var vector = []
		
		for _i in (len(vectorA) if (len(vectorA) <= len(vectorB)) else len(vectorB)):
			
			vector.append(vectorA[_i])
			
			for _j in padding: 
				
				vector.append(vectorB[_i])
				
		return vector
		
	func _vector_fill(value, iteration, increment=null, front=false):
		
		var vector = []
		
		for _i in range(iteration):
			
			vector.append(value)
			
		if increment:
			
			if front:
				
				vector.insert(0, increment)
				
			else: 
				
				vector.append(increment)
				
		return vector
		
	func _numbers_to_string(numbers):
		
		var string = ''
		
		for number in numbers:
			
			string += str(number)
			
		return int(string)
		
	func _maze_asc():
		
		var maze_asc = []
		
		var fill_asc_1 = '+'
		var fill_asc_2 = '-'
		var fill_asc_3 = '|'
		
		var empty_asc = ' '
		
		for _i in range(len(maze)):
			
			var asc = []
			
			for _j in maze[_i]:
				
				for _k in range(len(_j)):
					
					if (_j[_k] == _fill):
						
						if (_k == _empty):
							
							if (_i % 2 == 0):
								
								asc.append(fill_asc_1)
								
							else:
								
								asc.append(fill_asc_3)
								
						else:
							
							if (_i % 2 == 0):
								
								asc.append(fill_asc_2)
								
							else:
								
								asc.append(fill_asc_3)
								
					else: 
						
						asc.append(empty_asc)
						
			maze_asc.append(asc)
			
		return maze_asc
			
	func _render(grid, blocks, ground=true):
		
		grid.mesh_library = blocks
		
		for _i in range(len(maze)):
			
			var last_point = 0
			
			for _j in range(len(maze[_i])):
				
				for _k in range(len(maze[_i][_j])):
					
					if maze[_i][_j][_k]:
						
						grid.set_cell_item(_i, 0, last_point, _fill)
						
					else:
						
						grid.set_cell_item(_i, 0, last_point, _empty)
						
					last_point += 1
					
func _ready():
	
	var blocks = MeshLibrary.new()
	
	var wall = CubeMesh.new()
	var wall_shape = BoxShape.new()
	
	var ground = CubeMesh.new()
	var ground_shape = BoxShape.new()
	
	wall.size = Vector3(_block_size, _block_size, _block_size)
	ground.size = Vector3(_block_size, 1, _block_size)
	
	wall_shape.extents = Vector3(_block_size * _block_extents, _block_size * _block_extents, _block_size * _block_extents)
	ground_shape.extents = Vector3(_block_size * _block_extents, 0.05, _block_size * _block_extents)
	
	blocks.create_item(0)
	
	blocks.create_item(1)
	blocks.set_item_mesh(1, wall)
	blocks.set_item_shapes(1, [wall_shape])
	
	blocks.create_item(2)
	blocks.set_item_mesh(2, ground)
	blocks.set_item_shapes(2, [ground_shape])
	
	Maze.new(_width, _height, _padding)._render(self, blocks)
