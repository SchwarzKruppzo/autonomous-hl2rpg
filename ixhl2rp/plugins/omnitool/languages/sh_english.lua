local phrases = {
	["omnitool.name"] = "Multifunctional Tool",
	["omnitool.description"] = "A portable Combine tool for bypassing access systems, controlling devices and removing biological locks.",
	["omnitool.category"] = "Tools",
	["omnitool.editCombineLock"] = "Edit Combine Lock",
	["omnitool.lockAccessTitle"] = "Set access",
	["omnitool.lockAccessPrompt"] = "Current lock access: \"%s\"",
	["omnitool.lockAccessDenied"] = "You do not have access to this lock.",
	["omnitool.lockAccessUnavailable"] = "You do not have that access.",
	["omnitool.lockAccessChanged"] = "Lock access changed to \"%s\".",
	["omnitool.connect"] = "Connect",
	["omnitool.connectionFailed"] = "Could not connect to the device.",
	["omnitool.editCitizenID"] = "Edit CID access",
	["omnitool.dropBioLock"] = "Remove biological lock",
	["omnitool.weaponNoBiolock"] = "This weapon has no active biological lock.",
	["omnitool.biolockFailure"] = "The lock was removed, but the tool was destroyed by the discharge.",
	["omnitool.biolockSuccess"] = "Biological lock removed.",
	["omnitool.manhackConnected"] = "Manhack connection established. Press USE to disconnect.",
	["omnitool.manhackEjectDesc"] = "Disconnect from the manhack.",
	["omnitool.cardEditorTitle"] = "CID card access",
	["omnitool.cardAccessColumn"] = "Access",
	["omnitool.addAccess"] = "Add access",
	["omnitool.addAccessTitle"] = "New access",
	["omnitool.removeAccess"] = "Remove access",
	["omnitool.copyAccess"] = "Copy access",
	["omnitool.noSourceCards"] = "No source cards available",
	["omnitool.applyAccess"] = "Apply",
	["omnitool.invalidAccessList"] = "The access list contains invalid values.",
	["omnitool.cardAccessChanged"] = "CID card access changed."
}

if (ix.Locale and isfunction(ix.Locale.AddTable)) then
	ix.Locale:AddTable("en", phrases)
else
	LANGUAGE = phrases
end
