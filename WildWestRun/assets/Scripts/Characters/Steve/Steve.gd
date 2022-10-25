extends KinematicBody

# Captura as configurações do Player Steve.

var _options: Control = preload("res://assets/Scripts/Main/Options/Options.gd").new()

# Captura a barra de saúde do Player Steve.

onready var _health_bar: Spatial = $HealthBar

# Captura as animações de movimentos do Player Steve.

onready var _animations: AnimationTree = $Movements

# Captura a camera de visão do Player Steve.

onready var _vision: SpringArm = $SteveVision

# Captura o modelo do Player Steve.

onready var _model: Spatial = $Model

# Define o nome das animações do Player Steve.

var Walk = 'Walk'
var Run = 'Run'
var Pose = 'Pose'

# Configura a mecânica para a movimentação do Player Steve.

var _damage = _options.Player_Damage
var _health = _options.Player_Health
var _hit_rate = _options.Player_Hit_Rate

var _walk_speed = _options.Player_Walk_Speed
var _run_speed = _options.Player_Run_Speed
var _jump_strength = _options.Player_Jump_Strength

var _speed = 0

var _acceleration = Vector3.ZERO
var _jumping = Vector3.DOWN

# Criar e retorna uma matriz de acordo com os parametrôs informados.

func matrixFill(lines, columns, value=0):
	
	var matrix = []
	
	for _i in range(lines):
		
		matrix.append([])
		
		for _j in range(columns):
			
			matrix[_i].append(value)
	
	return matrix

# Retorna uma matriz resultante da multiplicação de duas matrizes.

func multiplication(matrixA, matrixB):
	
	var matrix = matrixFill(matrixA.size(), matrixB[0].size())
	
	for i in range(matrixA.size()):
		for j in range(matrixB[0].size()):
			for k in range(matrixA[0].size()):
				
				matrix[i][j] = matrix[i][j] + matrixA[i][k] * matrixB[k][j]
	
	return matrix

# Realiza a multiplicação de um vetor por uma matriz.

func pointTransform(point, matrix):
	
	var x = matrix[0][0] * point.x + matrix[0][1] * point.y + matrix[0][2] * point.z
	var y = matrix[1][0] * point.x + matrix[1][1] * point.y + matrix[1][2] * point.z
	var z = matrix[2][0] * point.x + matrix[2][1] * point.y + matrix[2][2] * point.z
	
	return [x, y, z]

# Simula a função de translação nativa do Godot.

func matrixTranslation(motion, direction, snapshot):
	
	var x = direction.x + motion.x + snapshot.x
	var y = direction.y + motion.y + snapshot.y
	var z = direction.z + motion.z + snapshot.z
	
	return Vector3(x, y, z)

# Simula a função de rotação nativa do Godot.

func matrixRotation(axle, motion):
	
	var angle = -lerp(axle, atan2(-motion.x, -motion.z), 0)
	var position = [0, angle, 0]
	
	var rotation = [[], [], []]
	var transformation
	var vector
	
	rotation[0] = [
		
		[1, 0, 0],
		[0, cos(position[0]), sin(position[0])],
		[0, -sin(position[0]), cos(position[0])]
		
	]
	
	rotation[1] = [
		
		[cos(position[1]), 0, -sin(position[1])],
		[0, 1, 0],
		[sin(position[1]), 0, cos(position[1])]
		
	]
	
	rotation[2] = [
		
		[cos(position[2]), sin(position[2]), 0],
		[-sin(position[2]), cos(position[2]), 0],
		[0, 0, 1]
		
	]
	
	transformation = multiplication(rotation[0], multiplication(rotation[1], rotation[2]))
	vector = pointTransform(motion, transformation)
	
	return Vector3(vector[0], vector[1], vector[2])

func _update_health(value):
	
	_health += value
	_health_bar.update(_health)
	
	if _health < 0: queue_free()
	
func _animation_player(animation, animations=_animations, path='parameters/playback'): 
	
	animations[path].travel(animation)

func _move_player(delta):
	
	var Direction = Vector3.ZERO
	
	var is_running = Input.is_action_pressed("run")
	var is_walking = Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")
	var is_landed = is_on_floor() and _jumping == Vector3.ZERO
	
	if is_running: 
		
		_animation_player(Run)
		_speed = _run_speed
		
	elif is_walking:
		
		_animation_player(Walk)
		_speed = _walk_speed
		
	else: 
		
		_animation_player(Pose)
		_speed = 0
		
	if is_jumping:
		
		_acceleration.y = _jump_strength
		_jumping = Vector3.ZERO
		
	elif is_landed: _jumping = Vector3.DOWN		
		
	Direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	Direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	if _options.Godot:
		
		Direction = Direction.rotated(Vector3.UP, _vision.rotation.y).normalized()
		
		_acceleration.x = Direction.x * _speed
		_acceleration.z = Direction.z * _speed
		_acceleration.y -= _options.Gravity * delta
		
		_acceleration = move_and_slide_with_snap(_acceleration, _jumping, Vector3.UP, true)
		
		if _acceleration.length() > 0.2:
			
			_model.rotation.y = Vector2(_acceleration.z, _acceleration.x).angle()
			
	else:
		
		Direction = matrixRotation(_vision.rotation.y, Direction).normalized()
		
		_acceleration.x = Direction.x * _speed * delta
		_acceleration.z = Direction.z * _speed * delta
		_acceleration.y -= _options.Gravity * delta
		
		_acceleration = matrixTranslation(_acceleration, _jumping, Vector3.UP)
		
		translation.x += _acceleration.x
		translation.z += _acceleration.z
		
		if _acceleration.length() > 0.2:
			
			_model.rotation.y = lerp(_model.rotation.y, atan2(_acceleration.x, _acceleration.z), 0)
			
func _physics_process(delta):
		
		_move_player(delta)
		
func _process(_delta):
	
	_vision.translation = translation
	
func _ready():
	
	_health_bar.init(_health)
