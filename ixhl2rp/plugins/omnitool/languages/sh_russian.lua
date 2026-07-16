local phrases = {
	["omnitool.name"] = "Многофункциональный инструмент",
	["omnitool.description"] = "Портативный инструмент Альянса для обхода систем доступа, управления устройствами и снятия биологических замков.",
	["omnitool.category"] = "Инструменты",
	["omnitool.editCombineLock"] = "Редактировать Combine Lock",
	["omnitool.lockAccessTitle"] = "Выставление доступа",
	["omnitool.lockAccessPrompt"] = "Текущий доступ замка \"%s\"",
	["omnitool.lockAccessDenied"] = "У вас нет доступа к этому замку.",
	["omnitool.lockAccessUnavailable"] = "У вас нет такого доступа.",
	["omnitool.lockAccessChanged"] = "Доступ замка изменён на \"%s\".",
	["omnitool.connect"] = "Подключиться",
	["omnitool.connectionFailed"] = "Не удалось подключиться к устройству.",
	["omnitool.editCitizenID"] = "Редактировать доступы CID",
	["omnitool.dropBioLock"] = "Сбросить биологическую защиту",
	["omnitool.weaponNoBiolock"] = "Вооружение не имеет действующей биологической защиты.",
	["omnitool.biolockFailure"] = "Защита сброшена, но инструмент уничтожен разрядом.",
	["omnitool.biolockSuccess"] = "Биологическая защита сброшена.",
	["omnitool.manhackConnected"] = "Подключение к манхаку установлено. Нажмите USE для отключения.",
	["omnitool.manhackEjectDesc"] = "Отключиться от манхака.",
	["omnitool.cardEditorTitle"] = "Доступы CID-карты",
	["omnitool.cardAccessColumn"] = "Доступ",
	["omnitool.addAccess"] = "Добавить доступ",
	["omnitool.addAccessTitle"] = "Новый доступ",
	["omnitool.removeAccess"] = "Удалить доступ",
	["omnitool.copyAccess"] = "Скопировать доступы",
	["omnitool.noSourceCards"] = "Нет доступных карт",
	["omnitool.applyAccess"] = "Применить",
	["omnitool.invalidAccessList"] = "Список доступов содержит недопустимые значения.",
	["omnitool.cardAccessChanged"] = "Доступы CID-карты изменены."
}

if (ix.Locale and isfunction(ix.Locale.AddTable)) then
	ix.Locale:AddTable("ru", phrases)
else
	LANGUAGE = phrases
end
