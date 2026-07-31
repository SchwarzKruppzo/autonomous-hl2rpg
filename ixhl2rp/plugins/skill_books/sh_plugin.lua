PLUGIN.name = "Skill Books"
PLUGIN.author = ""
PLUGIN.description = ""

ix.char.RegisterVar("bookInfo", {
	field = "books",
	fieldType = ix.type.text,
	default = {},
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})