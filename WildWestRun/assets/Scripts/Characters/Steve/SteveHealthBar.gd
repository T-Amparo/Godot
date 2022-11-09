extends Spatial

onready var bar: TextureProgress = get_node("Bar")
onready var ratio: Label = get_node("Ratio")

func init(max_value):
	
	bar.max_value = max_value
	bar.value = max_value
	
	ratio.text = String(max_value)
	
func update(value):
	
	bar.value = value
	
	ratio.text = String(value)
	
	if bar.value > bar.max_value:
		
		bar.max_value = value
	
