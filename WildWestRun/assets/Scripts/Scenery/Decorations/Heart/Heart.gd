extends Spatial

# Captura as configurações do Bônus: Heart.

var _options: Control = preload("res://assets/Scripts/Main/Options/Options.gd").new()

# Define o nome das animações do Bônus: Heart.

var Rotation = 'Rotation'

# Captura as animações de movimentos do Bônus: Heart.

onready var _animations: AnimationTree = $Movements

# Configura os valores para o Bônus: Heart.

var recharge = _options.Bonus_Heart_Recharge

func _animation_bonus(animation, animations=_animations, path='parameters/playback'): 
	
	animations[path].travel(animation)
	
func _ready():
	
	_animation_bonus(Rotation)
	
func _on_CollectionSensor_body_entered(body):
	
	if body.is_in_group('Player'):
		
		body._update_health(recharge)
		
		queue_free()
