extends KinematicBody

var random = RandomNumberGenerator.new()

# Captura as configurações dos Inimigos: Gram.

var _options: Control = preload("res://assets/Scripts/Main/Options/Options.gd").new()

# Captura a barra de saúde dos Inimigos: Gram.

onready var _health_bar: Viewport = $HealthBar

# Captura as animações de movimentos dos Inimigos: Gram.

onready var _animations: AnimationTree = $Movements

# Captura o modelo dos Inimigos: Gram.

onready var _model: Spatial = $Model

# Captura o Agente de Movimentação dos Inimigos: Gram.

onready var _track: NavigationAgent = $Track

# Captura o Mapa de Movimentação.

onready var _mapping: NavigationMeshInstance = $"../Mapping"

# Captura o objeto Player Steve.

onready var _player: KinematicBody = $"../Steve"

# Define o nome das animações dos Inimigos: Gram.

var Walk = 'Walk'
var Howl = 'Howl'
var Pose = 'Pose'

# Configura a mecânica para a movimentação dos Inimigos: Gram.

var _health = _options.Simba_Health
var _damage = _options.Simba_Damage
var _damage_critical = _options.Simba_Damage_Critical
var _hit_rate = _options.Simba_Hit_Rate
var _hit_rate_critical = _options.Simba_Hit_Rate_Critical

var _walk_speed = _options.Simba_Walk_Speed
var _run_speed = _options.Simba_Run_Speed
var _jump_strength = _options.Simba_Jump_Strength

var _acceleration = Vector3.ZERO
var _jumping = Vector3.DOWN

func _update_health(value):
	
	_health += value
	_health_bar.update(_health)
	
	if _health < 0: _defeated()
	
func _animation_enemy(animation, animations=_animations, path='parameters/playback'): 
	
	animations[path].travel(animation)
	
func _defeated():
	
	_animation_enemy(Howl)
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	queue_free()
	
func _follow(delta):
	
	var target = _track.get_next_location()
	var direction = global_transform.origin.direction_to(target)
	var distance = global_transform.origin.distance_to(_player.global_transform.origin)
	
	if distance > 6:
		
		_animation_enemy(Walk)
		_track.max_speed = _run_speed
		
	elif distance > 2:
		
		_animation_enemy(Walk)
		_track.max_speed = _walk_speed
		
	else:
		
		_animation_enemy(Pose)
		_track.max_speed = 0
	
	direction = direction.rotated(Vector3.UP, rotation.y).normalized()
	
	_acceleration.x = direction.x * _track.max_speed
	_acceleration.z = direction.z * _track.max_speed
	_acceleration.y -= _options.Gravity * delta
	
	_model.rotation.y = lerp(_model.rotation.y, atan2(-direction.x, -direction.z), delta * _track.max_speed)
	
	_track.set_velocity(_acceleration)

func _physics_process(delta):
	
	_track.set_target_location(_player.global_transform.origin)
	
	if not _track.is_navigation_finished(): 
		
		_follow(delta)
		
func _on_Track_velocity_computed(safe_velocity):
	
	_acceleration = move_and_slide_with_snap(safe_velocity, _jumping, Vector3.UP, true)
	
