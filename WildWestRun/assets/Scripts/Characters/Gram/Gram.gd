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
var Run = 'Run'
var Pose = 'Pose'
var Jump = 'Jump'
var Attack = 'Attack'
var ComboAttack = 'ComboAttack'
var FallFront = 'FallFront'
var FallBack = 'FallBack'

# Configura a mecânica para a movimentação dos Inimigos: Gram.

var _health = _options.Gram_Health
var _damage = _options.Gram_Damage
var _damage_critical = _options.Gram_Damage_Critical
var _hit_rate = _options.Gram_Hit_Rate
var _hit_rate_critical = _options.Gram_Hit_Rate_Critical

var _walk_speed = _options.Gram_Walk_Speed
var _run_speed = _options.Gram_Run_Speed
var _jump_strength = _options.Gram_Jump_Strength

var _acceleration = Vector3.ZERO
var _jumping = Vector3.DOWN

func _update_health(value):
	
	_health += value
	_health_bar.update(_health)
	
	if _health < 0: _defeated()
	
func _animation_enemy(animation, animations=_animations, path='parameters/playback'): 
	
	animations[path].travel(animation)
	
func _defeated():
	
	$AttackSensor/AttackTimer.stop()
	$HuntingSensor/HuntingTimer.stop()
	
	_animation_enemy(FallFront if (random.randf_range(0, 1) < 0.5) else FallBack)
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	queue_free()
	
func _attack(body):
	
	if random.randf_range(0, 1) < _hit_rate:
		
		if random.randf_range(0, 1) < _hit_rate_critical:
			
			_animation_enemy(ComboAttack)
			
			body._update_health(-(_damage + (_damage * _damage_critical)))
			
		else:
			
			_animation_enemy(Attack)
			
			body._update_health(-_damage)
			
func _hunt(delta):
	
	var target = _track.get_next_location()
	var direction = global_transform.origin.direction_to(target)
	var distance = global_transform.origin.distance_to(_player.global_transform.origin)
	
	if distance > 6:
		
		_animation_enemy(Run)
		_track.max_speed = _run_speed
		
	elif distance > 2:
		
		_animation_enemy(Walk)
		_track.max_speed = _walk_speed
		
	else:
		
		_track.max_speed = 0
		
	direction = direction.rotated(Vector3.UP, rotation.y).normalized()
	
	_acceleration.x = direction.x * _track.max_speed
	_acceleration.z = direction.z * _track.max_speed
	_acceleration.y -= _options.Gravity * delta
	
	_model.rotation.y = lerp(_model.rotation.y, atan2(-direction.x, -direction.z), delta * _track.max_speed)
	
	_track.set_velocity(_acceleration)
	
func _ready():
	
	_health_bar.init(_health)
	
	_track.set_target_location(global_transform.origin)
	
func _physics_process(delta):
	
	if not _track.is_navigation_finished(): 
		
		_hunt(delta)
		
	else:
		
		_track.max_speed = 0
		
func _on_AttackSensor_body_entered(body):
	
	if body.is_in_group('Player') and _health >= 0:
		
		_attack(body)
		
		$AttackSensor/AttackTimer.start()
		
func _on_AttackSensor_body_exited(body):
	
	if body.is_in_group('Player') and _health >= 0:
		
		$AttackSensor/AttackTimer.stop()
		
func _on_AttackTimer_timeout():
	
	_attack(_player)
	
func _on_SensitivitySensor_body_entered(body):
	
	if body.is_in_group('Player') and _health >= 0:
		
		_update_health(-body._damage)
		
func _on_HuntingSensor_body_entered(body):
	
	if body.is_in_group('Player') and _health >= 0:
		
		$HuntingSensor/HuntingTimer.start()
		
func _on_HuntingSensor_body_exited(body):
	
	if body.is_in_group('Player') and _health >= 0:
		
		$HuntingSensor/HuntingTimer.stop()
		
func _on_HuntingTimer_timeout():
	
	_track.set_target_location(_player.global_transform.origin)
	
func _on_Track_velocity_computed(safe_velocity):
	
	_acceleration = move_and_slide_with_snap(safe_velocity, _jumping, Vector3.UP, true)
	
