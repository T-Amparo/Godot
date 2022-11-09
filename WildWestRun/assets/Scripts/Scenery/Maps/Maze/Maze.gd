extends GridMap
tool

# Configura a mecânica para geração do Labirinto.

var _width = Options.Maze_Width
var _height = Options.Maze_Height
var _padding = Options.Maze_Padding

var _block_size = Options.Maze_Block_Size
var _block_extents = Options.Maze_Block_Extents

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
	
	var _block
	var _block_size
	var _block_extents
	
	var elements = {}
	
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
			
		halls += [_vector_fill(_fill, _width, _fill)]
		
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
		
	func _is_coordinate_valid(coordinate):
		
		coordinate = _coordinate_convert(coordinate)
		
		if coordinate.x > (_height * (_padding + 1)):
			
			return false
			
		elif coordinate.y > _width:
			
			return false
			
		elif coordinate.z > _padding:
			
			return false
			
		else:
			
			return maze[coordinate.x][coordinate.y][coordinate.z] == _empty
			
	func _coordinate_convert(coordinate):
		
		var _i = int(coordinate.x / _block_size)
		var _j = int(int(coordinate.z / _block_size) / (_padding + 1))
		var _k = int(int(coordinate.z / _block_size) - (_j * (_padding + 1)))
		
		return Vector3(_i, _j, _k)
		
	func _coordinate_to_grid(up=0):
		
		var _i = random.randi_range(1, ((_height * (_padding + 1)) * _block_size) - 1)
		var _j = random.randi_range(1, ((_width * (_padding + 1)) * _block_size) - 1)
		
		while not _is_coordinate_valid(Vector3(_i, up, _j)):
			
			_i = random.randi_range(1, ((_height * (_padding + 1)) * _block_size) - 1)
			_j = random.randi_range(1, ((_width * (_padding + 1)) * _block_size) - 1)
			
		return Vector3(_i, up, _j)
		
	func _insert(grid, node, distance=10, coordinate=null):
		
		var name = node.name
		
		grid.add_child(node)
		
		if name in elements:
			
			elements[name].append(node)
			
		else:
			
			elements[name] = [node]
			
		if not coordinate:
			
			var is_distant = false
			
			while not is_distant:
				
				coordinate = _coordinate_to_grid()
				
				for _i in elements[name]:
					
					if _i.global_transform.origin.distance_to(coordinate) < distance:
						
						is_distant = true
						
				is_distant = not is_distant
				
		node.transform.origin = coordinate
		
		var id = elements.keys().find(name) + (_empty + _fill) + 1
		
		coordinate = _coordinate_convert(coordinate)
		
		maze[coordinate.x][coordinate.y][coordinate.z] = id
		
	func _blocks(block_size, block_extents):
		
		var blocks = MeshLibrary.new()
		
		var wall = CubeMesh.new()
		var wall_shape = BoxShape.new()
		
		var size = Vector3(block_size, block_size, block_size)
		
		var extents = block_size * block_extents
		extents = Vector3(extents, extents, extents)
		
		wall.size = size
		wall_shape.extents = extents
		
		blocks.create_item(0)
		
		blocks.create_item(1)
		blocks.set_item_mesh(1, wall)
		blocks.set_item_shapes(1, [wall_shape])
		
		_block = blocks
		_block_size = block_size
		_block_extents = _block_extents
		
		return blocks
		
	func _render(grid, block_size, block_extents):
		
		grid.mesh_library = _blocks(block_size, block_extents)
		
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
	
	translation.x = -_width * (_padding + 1)
	translation.z = -_height * (_padding + 1)
	
	var maze = Maze.new(_width, _height, _padding)
	
	maze._render(self, _block_size, _block_extents)
	
	for _i in Options.Spawner_Gram_Rate:
		
		maze._insert(self, Options.Spawner_Gram.instance(), 20)
		
	for _i in Options.Bonus_Heart:
		
		maze._insert(self, Options.Heart.instance(), 20)
