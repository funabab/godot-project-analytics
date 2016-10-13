tool
extends VBoxContainer
var tree;
var utils = preload("res://addons/godot-project-analytics.funabab/Utils.gd");

func _ready():
	tree = self.get_node("tree");
	pass

func _feed_tree(data):
	tree.clear();
	var section_title;
	var key_title;
	var pkeys = utils.DictionaryHelper.keys(data);
	var ckeys;
	for parent_key in pkeys:
		if (data[parent_key].size() > 0):
			section_title = parent_key.capitalize();
			ckeys = utils.DictionaryHelper.keys(data[parent_key]);
			tree.create_item_from_path(section_title);
			for key in ckeys:
				key_title = key;
				##Display workarounds
				##if section child begins with an _ 
				##Then dont capitalize
				if (key_title.begins_with("_")):
					key_title = key_title.right(1);
				else:
					key_title = key_title.capitalize();
				tree.create_item_from_path(section_title.capitalize() + "/" + key_title + "," + str(data[parent_key][key]));


