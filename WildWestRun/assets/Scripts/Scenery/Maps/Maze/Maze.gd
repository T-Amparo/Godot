extends Spatial

export var width = 10
export var height = 10
tool
class Maze:
	
	var random = RandomNumberGenerator.new()
	
	var nodes = []
	var maze = [[], []]
	
	var width
	var height
	var scale
	
	var fill
	var empty
	
	var block

	func _init(width=10, height=10, scale=4, fill=1, empty=0):
		
		self.width = width
		self.height = height
		self.scale = scale
		
		self.fill = fill
		self.empty = empty

		for _i in range(height):
			
			nodes.append(_vector(0, width, 1))
		
		nodes += [_vector(1, width + 1)]
		
		for _i in range(height + 1):
			
			if (_i < height): maze[0].append(_vector(_vector(empty, scale, fill, true), width, _vector(fill, 1)))
			
			maze[1].append(_vector(_vector(fill, scale, fill, true), width, _vector(fill, 1)))
		
		maze[0] += [[]]
		
		random.randomize()
		
		_walk(Vector2(random.randi_range(0, width - 1), random.randi_range(0, height - 1)))
		
		maze = _zip(maze[1], maze[0], scale)
		
	func _to_string():
		
		var maze_asc = _maze_asc()
		
		var string = ''
		
		for _i in range(len(maze_asc)):
			
			for _j in maze_asc[_i]:
				
				for _k in _j:
				
					string += str(_k)
			
			string += '\n'
		
		return string
	
	func _get(property): return property
	
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
					
					if (_j[_k] == fill):
						
						if (_k == 0):
						
							asc.append(fill_asc_1) if (_i % 2 == 0) else asc.append(fill_asc_3)
						
						else:
							
							asc.append(fill_asc_2) if (_i % 2 == 0) else asc.append(fill_asc_3)
					
					else: asc.append(empty_asc)
				
			maze_asc.append(asc)
		
		return maze_asc
		
	func _number(numbers):
		
		var string = ''
		
		for number in numbers:
			
			string += str(number)
		
		return int(string)
		
	func _zip(vectorA, vectorB, scale=1):
		
		var vector = []
		
		for _i in (len(vectorA) if (len(vectorA) <= len(vectorB)) else len(vectorB)):
			
			vector.append(vectorA[_i])
			
			for _j in scale: vector.append(vectorB[_i])
			
		return vector
		
	func _vector(value, iteration, increment=null, front=false):
		
		var vector = []
		
		for _i in range(iteration):
			
			vector.append(value)
		
		if increment: vector.insert(0, increment) if (front) else vector.append(increment)
		
		return vector
		
	func _walk(coordinate):
		
		nodes[coordinate.y][coordinate.x] = 1

		var direction = [
			
			Vector2(coordinate.x - 1, coordinate.y), 
			Vector2(coordinate.x, coordinate.y + 1), 
			Vector2(coordinate.x + 1, coordinate.y),
			Vector2(coordinate.x, coordinate.y - 1)
			
		  ]
		
		direction.shuffle()

		for vector in direction:

			if (nodes[vector.y][vector.x]): continue

			if (vector.x == coordinate.x): maze[1][max(coordinate.y, vector.y)][coordinate.x] = _vector(empty, scale, fill, true)

			if (vector.y == coordinate.y): maze[0][coordinate.y][max(coordinate.x, vector.x)] = _vector(empty, scale + 1, empty, true)
			
			_walk(Vector2(vector.x, vector.y))
	
	func _create_block(size=Vector3(2, 2, 2)):
		
		var block = MeshLibrary.new()
		
		var cube = CubeMesh.new()
		var shape = BoxShape.new()
		
		cube.size = size
		shape.extents = Vector3((size.x * 0.36), (size.y * 0.36), (size.z * 0.36))
		
		block.create_item(0)
		block.set_item_mesh(0, cube)
		block.set_item_shapes(0, [shape])
		
		self.block = block
		
	func _render():
		
		var render = GridMap.new()
		
		var map = []
		
		for room in maze:
			
			var path = []
			
			for fill in room:
				
				path += fill
			
			map.append(path)
		
		if !block: _create_block()
		
		render.mesh_library = block
		
		for x in range(len(map)):
			for z in range(len(map[x])):
				
				if (map[x][z]): render.set_cell_item(x, 0, z, 0)
				
				else: render.set_cell_item(x, 0, z, 1)
		
		return render
		
func _ready():
	
	var maze = Maze.new(width, height)
	var grid = maze._render()
	
	add_child(grid)
