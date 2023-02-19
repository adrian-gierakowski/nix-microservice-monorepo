{
	writers,
	name,
}:
writers.writeJSBin
	name
	{ libraries = []; }
	(builtins.readFile ./src/index.js)
