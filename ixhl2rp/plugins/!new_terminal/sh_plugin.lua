local PLUGIN = PLUGIN

PLUGIN.name = "Civil Terminal"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.util.Include("ui/datafile/page.info.lua", "client")
ix.util.Include("ui/datafile/page.credits.lua", "client")
ix.util.Include("ui/datafile/page.messages.lua", "client")

ix.util.Include("sv_page.messages.lua")
ix.util.Include("sv_page.credits.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

