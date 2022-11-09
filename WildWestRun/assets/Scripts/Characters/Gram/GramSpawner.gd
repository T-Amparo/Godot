extends Spatial

# Captura o controle do tempo que será utilizado no intervalo de geração dos Inimigos: Gram.

onready var _generation_timer: Timer = $GenerationTimer

# Configura a mecânica do Spawner para a geração dos Inimigos: Gram.

var _on = false

var _gram_rate = Options.Spawner_Gram_Wave
var _gram_generation_time = Options.Spawner_Gram_Generation_Time

var _gram_generations = []

func _update():
	
	for _gram in range(len(_gram_generations)):
		
		if not is_instance_valid(_gram_generations[_gram]):
			
			_gram_generations.remove(_gram)
			
func _generate(position=translation, size=Vector3(2, 2, 2)):
	
	if len(_gram_generations) < _gram_rate:
		
		var _root = get_parent()
		var _gram = Options.Gram.instance()
		
		_gram.translation = position
		_gram.scale = size
		
		_root.add_child(_gram)
		
		_gram_generations.append(_gram)
		
func start():
	
	_on = true
	
func stop():
	
	_on = false
	
func _ready():
	
	_generation_timer.wait_time = _gram_generation_time
	
	_generation_timer.start()
	
func _on_GenerationTimer_timeout():
	
	if _on:
		
		_update()
		_generate()
