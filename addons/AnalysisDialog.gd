tool
extends AcceptDialog

func setup(data):
	for key in data:
		self.get_node("v_container/tab_container/" + key.capitalize())._feed_tree(data[key]);
	pass