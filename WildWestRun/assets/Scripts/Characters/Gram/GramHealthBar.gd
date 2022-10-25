extends Viewport

onready var bar: TextureProgress = get_node("Bar")

func init(max_value):
	
	bar.max_value = max_value
	bar.value = max_value
	
func update(value):
	
	bar.value = value
	
