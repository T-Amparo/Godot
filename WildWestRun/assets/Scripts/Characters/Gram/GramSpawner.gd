extends Spatial

# Captura as configurações do Spawner dos Inimigos: Gram.

var _options: Control = preload("res://assets/Scripts/Main/Options/Options.gd").new()

# Captura a cena dos Inimigos: Gram.

export (PackedScene) var _gram_scene

# Captura o controle do tempo que será utilizado no intervalo de geração dos Inimigos: Gram.

onready var _generation_timer: Timer = $GenerationTimer

# Configura a mecânica do Spawner para a geração dos Inimigos: Gram.

var _on = true

var _gram_rate = round(_options.Spawner_Gram_Rate / _options.Spawner_Gram)
var _gram_generation_time = _options.Spawner_Gram_Generation_Time

var _gram_generations = []

func _update():
	
	for _gram in range(len(_gram_generations)):
		
		if not is_instance_valid(_gram_generations[_gram]):
			
			_gram_generations.remove(_gram)
			
func _generate(position=translation, size=Vector3(4,4,4)):
	
	if len(_gram_generations) < _gram_rate:
		
		var _root: Spatial = get_parent()
		var _gram: KinematicBody = _gram_scene.instance()
		
		_gram.translation = position
		_gram.scale = size
		
		_root.add_child(_gram)
		
		_gram_generations.append(_gram)
		
func _ready():
	
	_generation_timer.wait_time = _gram_generation_time
	
	_generation_timer.start()
	
func _on_GenerationTimer_timeout():
	
	if _on:
		
		_update()
		_generate()
