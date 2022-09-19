tool
extends Tree
export(Color) var subsection_color;

func _ready():
	if (subsection_color == null):
		subsection_color = Color("312e37");
	self.create_item();
	self.set_hide_root(true);
	self.set_columns(2);
	##self.set_column_titles_visible(true);
	
	##self.set_column_title(0, "Name");
	##self.set_column_expand(0, true);
	##self.set_column_min_width(0, 214);
	
	##self.set_column_title(1, "Value");
	##self.set_column_expand(1, true);
	##self.set_column_min_width(1, 214);


## A simple function used to create a subsection
func create_subsection(name, parent = null):
	var subsection = self.create_item(parent);
	subsection.set_text(0, name.capitalize());
	subsection.set_custom_bg_color(0, subsection_color);
	subsection.set_custom_bg_color(1, subsection_color);
	subsection.set_selectable(0, false);
	subsection.set_selectable(1, false);
	return subsection;


## A simple function used to create a Name/value
func create_child_item(section, name, value):
	var child_item = self.create_item(section);
	child_item.set_text(0, name);
	child_item.set_text(1, value);


## A simple function to create TreeItem(s) from path
## Eg. hello/How are you/name,value
#eg create_item_from_path("hello/How are you/name,value");
func create_item_from_path(path):
	var split = path.split("/");
	var lenght = split.size();
	var parent = self.get_root();
	for i in range(lenght):
		## End of Road !!!
		## Search for a 2 value (A string seperated by comma) to use
		## as name/value
		if (i == lenght - 1):
			var values = split[i].split(",");
			var vsize = values.size();
			##Is it empty? Ignore
			if (vsize == 0):
				break;
			## Maybe not what we are looking for, create a subsection from first value
			elif (vsize != 2):
				## First check if TreeItem (SubSection) exist otherwise create
				if (get_tree_item(split[i], parent) != null):
					parent = get_tree_item(values[0], parent);
				else:
					parent = create_subsection(values[0], parent);
			## This what we are looking for ... lol
			## Create a Name / Value for it
			else:
				create_child_item(parent, values[0], values[1]);
		##It a subsection
		## Create one
		else:
			## First check if TreeItem (SubSection) exist otherwise create
			if (get_tree_item(split[i], parent) != null):
				parent = get_tree_item(split[i], parent);
			else:
				parent = create_subsection(split[i], parent);

## A simple function that loops through a TreeItem to check
## if a particular TreeItem exist by it name
## return TreeItem if exist otherwise null

func get_tree_item(name, item):
	if (item == null):
		return null;
	name = name.to_lower();
	item = item.get_children();
	if (item == null):
		return null;
	while(true):
		if (item == null):
			break;
		if (item.get_text(0).to_lower() == name):
			return item;
		else:
			item = item.get_next();
	return null;


