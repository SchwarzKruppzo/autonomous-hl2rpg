ix.dialogues.Add("mark_pootisman", {
	["GREETINGS"] = {
		response = {
			[1] = {
				text = {"@r_mark_greetings_1f", "@r_mark_greetings_2f", "@r_mark_greetings_3f"},
				gender = GENDER_FEMALE
			},
			[2] = {
				text = {"@r_mark_greetings_1m", "@r_mark_greetings_2m", "@r_mark_greetings_3m"},
				gender = GENDER_MALE
			},
		},
		choices = {"NeverSeenYou", "Rent", "CheckMail", "LatestRumours", "GOODBYE"}
	},
	["NeverSeenYou"] = {
		response = "@r_mark_neverseen",
		data = {
			mailtopic = true,
			renttopic = true
		},
		topic = {
			[1] = {
				text = "@t_mark_neverseen_f",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "@t_mark_neverseen_m",
				gender = GENDER_MALE
			},
		},
		flags = DFLAG_ONCE
	},
	["Rent"] = {
		response = "@r_mark_rent",
		topic = {
			[1] = {
				text = "@t_mark_rent_f",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "@t_mark_rent_m",
				gender = GENDER_MALE
			},
		},
		condition = function(client, npc, self) return self.data.renttopic end,
	},
	["CheckMail"] = {
		response = "@r_mark_checkmail",
		topic = {
			[1] = {
				text = "@t_mark_checkmail_f",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "@t_mark_checkmail_m",
				gender = GENDER_MALE
			},
		},
		choices = function(client, npc, dialogue) 
            local choices = {}
            for k, v in pairs(client:GetCharacter():GetInventory():GetItemsByUniqueID("cid")) do
            	local citizenID = v:GetData("id", "0000")

                choices[#choices + 1] = {label = L("t_mail_check_id", client, citizenID), cid = citizenID}
            end

            choices[#choices + 1] = {label = (client:GetCharacter():GetGender() == GENDER_MALE and "@t_checkmail_no_m" or "@t_checkmail_no_f")}

            return choices
        end,
        choose = function(choice, client, npc, dialogue)
            if SERVER then
            	if choice.cid then
            		client:OpenMailbox(choice.cid)
            	end
            end
            return choice.cid and "GOODBYE" or "GREETINGS"
        end,
		condition = function(client, npc, self) return self.data.mailtopic end,
		flags = DFLAG_DYNAMIC
	},
	["LatestRumours"] = {
		response = "@r_mark_rumours",
		topic = "@t_mark_rumours",
		rumours = true
	},
	["GOODBYE"] = {
		topic = "@t_generic_goodbye",
		flags = DFLAG_GOODBYE
	}
})

ix.dialogues.Add("_Rumours", {
	["ARumour1"] = {
		response = "@r_rumour1",
		flags = bit.bor(DFLAG_RUMOURS, DFLAG_ONCE)
	}
})

ix.dialogues.Add("mark_pootis", {
	["GREETINGS"] = {
		response = "Привет. Чем могу быть полезен?",
		choices = {"GarbageWorkDone", "CWUWork", "WhereIam", "CWUSetup", "GOODBYE"}
	},
	["OKAY_NO_WORK"] = {
		response = "Ладно.",
		topic = {
			[1] = {
				text = "Я передумала.",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "Я передумал, извини.",
				gender = GENDER_MALE
			},
		},
		choices = {"CWUWork", "WhereIam", "CWUSetup", "GOODBYE"}
	},
	["NoWork"] = {
		response = "Сегодня у меня работы для тебя нет. Обратись в другой раз.",
		topic = {
			[1] = {
				text = "Привет. Я бы хотела взять работу в вашем офисе.",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "Привет. Я бы хотел взять работу в вашем офисе.",
				gender = GENDER_MALE
			},
		},
	},
	["CWUWork"] = {
		response = {
			[1] = {
				condition = function(client, npc, self)
					local gender = client:GetCharacter():GetGender()

					if self.data.haswork then
						return gender == GENDER_MALE and "Ты уже брал работу. Для начала выполни ее, а потом уже обращайся." or "Ты уже брала работу. Для начала выполни ее, а потом уже обращайся."
					elseif self.data.workcooldown and os.time() < self.data.workcooldown then
						return gender == GENDER_MALE and "Извини. Для тебя лимиты пока-что превышены, так что приходи чуть позже." or "Извини. Для тебя лимиты пока-что превышены, так что приходи чуть позже."
					end

					return "Ну, по другому вопросу ко мне, обычно, и не обращаются. Чем хочешь заняться сегодня?"
				end
			}
		},
		topic = {
			[1] = {
				text = "Привет. Я бы хотела взять работу в вашем офисе.",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "Привет. Я бы хотел взять работу в вашем офисе.",
				gender = GENDER_MALE
			},
		},
		choices = function(client, npc, dialogue) 
            local choices = {}

            if (!dialogue.data.workcooldown or (dialogue.data.workcooldown and os.time() > dialogue.data.workcooldown)) and !dialogue.data.haswork then
            	choices = {
					--{label = "Влажная уборка.", work = 1, topic = "GET_WORK1"}, 
					{label = "Уборка мусора в городе.", work = 2, topic = "GET_WORK2"}, 
					--{label = "Разнос корреспонденции.", topic = "GET_WORK3"}, 
					--{label = "Пополнение картриджей автоматов с водой.", topic = "GET_WORK4"}, 
					--{label = "Перенос стройматериалов.", topic = "GET_WORK5"}, 
					{label = "Я передумал, извини.", topic = "OKAY_NO_WORK"}
            	}
            else
            	choices = {
            		{label = "...", topic = "OKAY_NO_WORK"}
            	}
            end

            return choices
        end,
        choose = function(choice, client, npc, dialogue)
    		local character = client:GetCharacter()

    		if choice.work == 2 then
    			if SERVER then
	    			local quests = character:GetData("quests", {})
					quests["cwu_garbage"] = true
					character:SetData("cwuGarbage", 0)
					character:SetData("quests", quests)
					net.Start("ixUpdateQuests")
					net.Send(client)
				end

				dialogue.data.haswork = true

				return "GarbageWork"
    		end

            return choice.topic and choice.topic or "OKAY_NO_WORK"
        end,
		flags = DFLAG_DYNAMIC
	},
	["GarbageWorkDone"] = {
		response = {
			[1] = {
				text = {
					"Неплохо, такие работники мне нравятся! Вот, твои десять токенов за работу и наградной купон! Купон можно обменять на дополнительные очки лояльности и премию в временных пунктах выдачи поощрений. О таких пунктах обычно оповещают.",
					"Хорошая работа. Вот твоя награда.",
					"Достойная плата за достойную работу.",
				},
			},
		},
		topic = {
			[1] = {
				text = "Я собрала мусор, который только смогла найти.",
				gender = GENDER_FEMALE
			},
			[2] = {
				text = "Я собрал мусор, который только смог найти.",
				gender = GENDER_MALE
			},
		},
		select = function(client, npc, self)
			local character = client:GetCharacter()
			if SERVER then
				local quests = character:GetData("quests", {})
				quests["cwu_garbage"] = nil

				character:SetData("quests", quests)
				character:SetMoney(character:GetMoney() + 10)
				net.Start("ixUpdateQuests")
				net.Send(client)

				local new_item = ix.Item:Instance("coupon_workforce")
				local success = client:AddItem(new_item)

				if !success then
					ix.Item:Spawn(client, nil, new_item)
				end

				client:NotifyLocalized("npc.garbageReward")
			end

			self.data.haswork = false
			self.data.workcooldown = os.time() + 14400
		end,
		condition = function(client, npc, self)
			local character = client:GetCharacter()

			return self.data.haswork and character:GetData("quests", {})["cwu_garbage"] and character:GetData("cwuGarbage", 0) == 4
		end
	},
	["GarbageWork"] = {
		data = {
			haswork = true,
		},
		response = "Бери перчатки, пакет и шуруй на улицу. Уберешь 4 куч, которых тут довольно много, после чего можешь возвращаться.",
		choices = {"GOODBYE"}
	},
	["WhereIam"] = {
		response = "Ты находишься в офисе Гражданского Союза Рабочих. Тут, обычно, люди получают разную работу - подай и принеси, ну или устраиваются на более престижные должности на завод, например. Если тебе интересно узнать подробнее - поймай другого сотрудника, который не будет так занят, как я. Они помогут тебе.",
		topic = "Где я нахожусь?",
	},
	["CWUSetup"] = {
		response = "Тебе нужно обратиться к нашему начальнику. Обычно, он тут довольно часто появляется и он носит на себе престижный костюм. Если же его нет рядом, то обратись к кому-то, кто не сидит со мной за одним столом. Увы, заняться твоим вопросом самостоятельно я не смогу.",
		topic = "Как мне получить такую же классную рубашку как у тебя и постоянную работу?",
	},
	["LatestRumours"] = {
		response = "@r_mark_rumours",
		topic = "@t_mark_rumours",
		rumours = true
	},
	["GOODBYE"] = {
		topic = "До встречи.",
		flags = DFLAG_GOODBYE
	}
})

ix.dialogues.Add("cp", {
	["GREETINGS"] = {
		response = {
			[1] = {
				condition = function(client) 
					if client:IsCombine() or client:IsCityAdmin() then
						return "Служу Покровителям!"
					else
						return {
									"Проходи.", 
									"...", 
									"Двигай отсюда.", 
									"Гражданин.", 
									"Не трать моё время.",
									"Чего ты хочешь?",
								}
					end
				end,
			}
		},
		choices = {"GOODBYE"}
	},
	["GOODBYE"] = {
		topic = "...",
		flags = DFLAG_GOODBYE
	}
})

ix.dialogues.Add("snektil", {
	["GREETINGS"] = {
		response = "Привет.",
		choices = {"RationSell", "GOODBYE"}
	},
	["RationSell"] = {
		response = {
			[1] = {
				text = "...",
			},
		},
		topic = {
			[1] = {
				text = "[СДАТЬ ПРОДУКЦИЮ]",
			}
		},
		select = function(client, npc, self)
			if SERVER then
				local rations = 0
				local work_points = {}
				local unique_crates = {}

				for k, v in ipairs(ents.FindByClass("ix_ration_palette")) do
					for z, x in pairs(v.crates or {}) do
						if !IsValid(x) then continue end
						local entIndex = x:EntIndex()
						
						if table.HasValue(unique_crates, entIndex) then continue end
						table.insert(unique_crates, entIndex)
					end

					v.crates = {}
				end

				for _, index in pairs(unique_crates) do
					local crate = Entity(index)

					if !IsValid(crate) then continue end
					
					for _, charID in pairs(crate.workers or {}) do
						work_points[charID] = math.min((work_points[charID] or 0) + 1, 75)
					end

					rations = rations + (crate:GetCount() * 11)
					crate:Remove()
				end

				for charID, points in pairs(work_points) do
					local new = (rations - points)

					if new < 0 then
						points = (points + new)
						new = (rations - points)
					end
					
					if points > 0 then
						local character = ix.char.loaded[charID]
						
						if character then
							local owner = character:GetPlayer()
							
							if IsValid(owner) then
								character:GiveMoney(points)
								owner:NotifyLocalized("npc.rationReward", points)
								
								owner:RewardXP(math.max(math.Round(points), 50), "производство")
							end
						end
					end

					rations = new
				end

				if rations > 0 then
					local character = client:GetCharacter()
					character:GiveMoney(rations)

					client:NotifyLocalized("npc.productionReward", rations)
				end
			end
		end,
		condition = function(client, npc, self)
			return client:IsCWU()
		end
	},
	["GOODBYE"] = {
		topic = "До встречи.",
		flags = DFLAG_GOODBYE
	}
})
