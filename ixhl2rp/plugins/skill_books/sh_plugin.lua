PLUGIN.name = "Skill Books"
PLUGIN.author = ""
PLUGIN.description = ""

ix.char.RegisterVar("bookInfo", {
	field = "books",
	fieldType = ix.type.string,
	default = {},
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})