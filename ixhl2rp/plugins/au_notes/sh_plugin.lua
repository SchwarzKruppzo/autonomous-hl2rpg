local PLUGIN = PLUGIN

PLUGIN.name = "Notes"
PLUGIN.author = "Krieg & Schwarz Kruppzo"
PLUGIN.description = "@notesPluginDesc"

ix.config.Add("notesMaxLen", 2048, "Max length for notes", nil, {
    data = {min = 64, max = 5096},
    category = "Other"
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

ix.char.RegisterVar("notes", {
    field = "notes",
    fieldType = ix.type.string,
    default = "",
    isLocal = true,
    bNoDisplay = true,
    bNetworked = true
})

ix.command.Add("CharNotes", {
    description = "@notesCmdCharNotesDesc",
    privilege = "Helix - Basic Admin Commands",
    arguments = {
        ix.type.character
    },
    OnRun = function(self, client, target)
        netstream.Start(client, "ixNotes", target:GetID(), target:GetNotes())
    end
})

ix.command.Add("MyNotes", {
    description = "@notesCmdMyNotesDesc",
    OnRun = function(self, client)
        netstream.Start(client, "ixMyNotes")
    end
})
