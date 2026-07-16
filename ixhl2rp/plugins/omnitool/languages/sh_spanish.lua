local phrases = {
	["omnitool.name"] = "Herramienta multifunción",
	["omnitool.description"] = "Una herramienta portátil de la Alianza para eludir sistemas de acceso, controlar dispositivos y retirar bloqueos biológicos.",
	["omnitool.category"] = "Herramientas",
	["omnitool.editCombineLock"] = "Editar cerradura de la Alianza",
	["omnitool.lockAccessTitle"] = "Establecer acceso",
	["omnitool.lockAccessPrompt"] = "Acceso actual de la cerradura: \"%s\"",
	["omnitool.lockAccessDenied"] = "No tienes acceso a esta cerradura.",
	["omnitool.lockAccessUnavailable"] = "No tienes ese acceso.",
	["omnitool.lockAccessChanged"] = "El acceso de la cerradura se cambió a \"%s\".",
	["omnitool.connect"] = "Conectar",
	["omnitool.connectionFailed"] = "No se pudo conectar al dispositivo.",
	["omnitool.editCitizenID"] = "Editar accesos de la tarjeta CID",
	["omnitool.dropBioLock"] = "Retirar bloqueo biológico",
	["omnitool.weaponNoBiolock"] = "Esta arma no tiene un bloqueo biológico activo.",
	["omnitool.biolockFailure"] = "El bloqueo se retiró, pero la descarga destruyó la herramienta.",
	["omnitool.biolockSuccess"] = "Bloqueo biológico retirado.",
	["omnitool.manhackConnected"] = "Conexión con el manhack establecida. Pulsa USAR para desconectarte.",
	["omnitool.manhackEjectDesc"] = "Desconectarse del manhack.",
	["omnitool.cardEditorTitle"] = "Accesos de la tarjeta CID",
	["omnitool.cardAccessColumn"] = "Acceso",
	["omnitool.addAccess"] = "Añadir acceso",
	["omnitool.addAccessTitle"] = "Nuevo acceso",
	["omnitool.removeAccess"] = "Eliminar acceso",
	["omnitool.copyAccess"] = "Copiar accesos",
	["omnitool.noSourceCards"] = "No hay tarjetas de origen disponibles",
	["omnitool.applyAccess"] = "Aplicar",
	["omnitool.invalidAccessList"] = "La lista de accesos contiene valores no válidos.",
	["omnitool.cardAccessChanged"] = "Se cambiaron los accesos de la tarjeta CID."
}

if (ix.Locale and isfunction(ix.Locale.AddTable)) then
	ix.Locale:AddTable("es", phrases)
else
	LANGUAGE = phrases
end
