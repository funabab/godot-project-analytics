##CodeScanner Class: script that analysises a particular GDscript file.
##This is a dumb, studpid zombie class that just look for stuffs and doesnt check for error
##if you are a core dev for Godot please dont look or you might proberbly hate me :)#
class CodeScanner:
	const TOK_COMMENT = "#"; 
	const TOK_CLASS = "class";
	const TOK_EXTENDS = "extends";
	const TOK_VAR = "var";
	const TOK_CONST = "const";
	const TOK_FUNC = "func";
	const TOK_EXPORT = "export"
##Array of chars that end token search of a particular line
	const IGNORE = [".",":", ";"];

##This func scans/records a particular GDscript file for some specific tokens
	func scan_file(path):
		##result of the scan
		var result = {
			"classes": 0,
			"constants": 0,
			"functions": 0,
			"member variables": 0,
			"total lines of code": 0,
			"total lines of text": 0,
		};
		##Open script file
		var file = File.new();
		file.open(path, file.READ);
		
		##Need this variables in the loop, i just like creating them ahead of time in some cases.
		var line;
		var token = "";
		##This two variables are needed for checking tabs
		var tab_idx = 0;
		var tabs = 0;
		while(!file.eof_reached()):
			line = file.get_line();
			token = get_token(line);
			tabs = count_tabs_left(line);
			result["total lines of text"] += 1;
			##if line is a comment, skip cause i dont count comments as lines of codes.
			##If comments is a line of code to you delete this statement
			if (token == TOK_COMMENT || token.empty()):
				continue;
			##Since tabs are not needed after using extends keyword, leave it zero.
			##Increase class count
			if (token == TOK_EXTENDS):
				tab_idx = 0;
				result["classes"] = result["classes"] + 1;
			##Tabs are needed after class keyword set it to -1
			##Increase class count
			elif (token == TOK_CLASS):
				result["classes"] = result["classes"] + 1;
				tab_idx = -1;
			if (token == TOK_VAR && (tab_idx + tabs == 0)):
				result["member variables"] += 1;
			if (token == TOK_CONST && (tab_idx + tabs == 0)):
				result["constants"] += 1;
			elif (token == TOK_FUNC && (tab_idx + tabs == 0)):
				result["functions"] += 1;
			result["total lines of code"] += 1;
			pass
		file.close();
		return result;
		pass
	##Thsi function gets a token at a particular line
	func get_token(line):
		var token = "";
		##Strip non printable chars from the edges cause we wont be needing them
		line = line.strip_edges();
		var char;
		var prev_char;
		var braces = 0;
		for i in range(line.length()):
			##Get the next char
			char = line.substr(i, 1);
			if (char == "("):##If it a braces increase braces (Open braces)
				braces = braces + 1;
			elif (char == ")"):
				braces = braces - 1;
				prev_char = char;
				continue;
			if (char == " " || braces != 0):
				##A workaround to get the var token after the export keyword is to reset the token ahead if it an export token
				if (token == TOK_EXPORT):
					token = "";
				prev_char = char;
				continue;
			##if it a non space char an braces are not open
			else:
				if (token.empty()):
					##If it a token comment there is no point readin the rest
					if (char == TOK_COMMENT):
						token = TOK_COMMENT;
						break;
					token = token + char; ##otherwise add char to token
				else:
					##Check if we come across some end of token search chars
					##If so, there is no point in continue reading...
					if (prev_char == " " || IGNORE.has(char)):
						break;
					else:
						if (char == TOK_COMMENT):##Also check for comment after a statment, like this one..
							break;
						token = token + char;
					pass
			prev_char = char;
		return token;
		pass
	## this function count tabs
	func count_tabs_left(line):
		line = line.c_escape();
		var find = line.find("\\t");##Find the first tab char occurance
		var count = 0;
		##if found loop and find the rest, if any...
		while(find != -1):
			count += 1;
			if (line.substr(find+2, 1) != "\\"):
				break;
			find = line.find("\\t", find+1);
			pass
		return count;
