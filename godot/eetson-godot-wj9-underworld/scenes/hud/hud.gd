extends Control

func _process(delta):
	$"score-label".text = var2str(globals.score) + "/" + var2str(globals.total)