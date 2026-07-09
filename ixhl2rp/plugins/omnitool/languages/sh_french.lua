local phrases = {
	["omnitool.name"] = "Outil multifonction",
	["omnitool.description"] = "Un outil Combine portable pour contourner les systèmes d'accès, contrôler des appareils et retirer les verrous biologiques.",
	["omnitool.category"] = "Outils",
	["omnitool.editCombineLock"] = "Modifier le verrou Combine",
	["omnitool.lockAccessTitle"] = "Définir l'accès",
	["omnitool.lockAccessPrompt"] = "Accès actuel du verrou : \"%s\"",
	["omnitool.lockAccessDenied"] = "Vous n'avez pas accès à ce verrou.",
	["omnitool.lockAccessUnavailable"] = "Vous n'avez pas cet accès.",
	["omnitool.lockAccessChanged"] = "Accès du verrou défini sur \"%s\".",
	["omnitool.connect"] = "Se connecter",
	["omnitool.connectionFailed"] = "Connexion à l'appareil impossible.",
	["omnitool.editCitizenID"] = "Modifier les accès de la CID",
	["omnitool.dropBioLock"] = "Retirer le verrou biologique",
	["omnitool.weaponNoBiolock"] = "Cette arme n'a pas de verrou biologique actif.",
	["omnitool.biolockFailure"] = "Le verrou a été retiré, mais l'outil a été détruit par la décharge.",
	["omnitool.biolockSuccess"] = "Verrou biologique retiré.",
	["omnitool.manhackConnected"] = "Connexion au manhack établie. Appuyez sur USE pour vous déconnecter.",
	["omnitool.manhackEjectDesc"] = "Se déconnecter du manhack.",
	["omnitool.cardEditorTitle"] = "Accès de la carte CID",
	["omnitool.cardAccessColumn"] = "Accès",
	["omnitool.addAccess"] = "Ajouter un accès",
	["omnitool.addAccessTitle"] = "Nouvel accès",
	["omnitool.removeAccess"] = "Supprimer l'accès",
	["omnitool.copyAccess"] = "Copier les accès",
	["omnitool.noSourceCards"] = "Aucune carte source disponible",
	["omnitool.applyAccess"] = "Appliquer",
	["omnitool.invalidAccessList"] = "La liste d'accès contient des valeurs invalides.",
	["omnitool.cardAccessChanged"] = "Les accès de la carte CID ont été modifiés."
}

if (ix.Locale and isfunction(ix.Locale.AddTable)) then
	ix.Locale:AddTable("fr", phrases)
else
	LANGUAGE = phrases
end
