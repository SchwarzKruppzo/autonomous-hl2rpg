-- Соответствие моделей и энтити или NPC
local modelToEntity = {
    ["models/props_combine/combine_barricade_short01a.mdl"] = "ix_combinebarricade",
    ["models/combine_turrets/floor_turret.mdl"] = "npc_turret_floor",
    ["models/manhack.mdl"] = "npc_manhack",
    -- Добавьте сюда свои соответствия моделей и энтити или NPC
}

local Item = class("ItemBuildable"):implements("Item")

Item.stackable = false

if CLIENT then
    do
        local mat = Material("debug/debugdrawflat")
        local preview = false
        local mdl = NULL
        local angle = Angle()

        local origin
        local trace
        local data = {}

        local validPlacement = false  -- Флаг для проверки, можно ли разместить

        local function PostDrawTranslucentRenderables(depth, sky)
            if depth or sky then return end
            if not preview or not IsValid(mdl) then return end

            render.MaterialOverride(mat)

            trace = LocalPlayer():GetEyeTraceNoCursor()
            mdl:SetAngles(angle)

            local mins, maxs = mdl:GetModelBounds()

            data.mins = mins
            data.maxs = maxs
            data.start = trace.StartPos
            data.endpos = trace.StartPos + trace.Normal * 70
            data.filter = LocalPlayer()

            local trace = util.TraceLine(data)

            local sitTrace = util.TraceHull({
                start = trace.HitPos,
                endpos = trace.HitPos - Vector(0, 0, 70),
                mins = mins,
                maxs = maxs,
                filter = LocalPlayer()
            })

            if sitTrace.AllSolid or not sitTrace.Hit then
                render.SetColorModulation(1, 0, 0, 1)  -- Красный для невалидного места
                validPlacement = false
            else
                render.SetColorModulation(0, 1, 0, 1)  -- Зеленый для валидного места
                validPlacement = true
            end

            render.SetBlend(0.2)

            origin = sitTrace.HitPos
            mdl:SetPos(sitTrace.HitPos)
            mdl.normal = trace.Normal
            mdl:DrawModel()

            render.MaterialOverride(nil)
        end

        local function HUDPaint()
            if not preview then return end
            draw.DrawText("[ЛКМ/ПКМ] — поставить/отменить", "ixMediumFont", ScrW() * 0.5 + 1, ScrH() * 0.95 + 1, color_black, TEXT_ALIGN_CENTER)
            draw.DrawText("[ЛКМ/ПКМ] — поставить/отменить", "ixMediumFont", ScrW() * 0.5, ScrH() * 0.95, color_white, TEXT_ALIGN_CENTER)
        end

        local buildCallback
        local function PlayerBindPress(player, bind, bPressed)
            if not preview then return end

            if (bind:find("invnext") or bind:find("invprev")) and bPressed then
                return true
            elseif bind:find("attack2") and bPressed then
                net.Start("build.stop")
                net.SendToServer()

                ix.Item:BuildPreview(false)
                return true
            elseif bind:find("attack") and bPressed then
                if validPlacement then  -- Проверка, можно ли разместить
                    if buildCallback then
                        buildCallback()
                    end

                    ix.Item:BuildPreview(false)
                else
                    chat.AddText(Color(255, 0, 0), "Невозможно разместить объект здесь!")
                end
                return true
            end
        end

        local function InputMouseApply(cmd)
            if not preview then return end

            local scrollDelta = cmd:GetMouseWheel()
            if scrollDelta == 0 then return end

            local pos = scrollDelta > 0
            angle.y = math.NormalizeAngle(angle.y + (pos and 1 or -1))
        end

        function ix.Item:BuildPreview(enable, path)
            if enable and not preview then
                ix.gui.preventSelection = true
                preview = true

                mdl = ClientsideModel(path, RENDERGROUP_OPAQUE)
                mdl:SetNoDraw(true)
                angle = angle_zero

                hook.Add('PostDrawTranslucentRenderables', 'item.preview', PostDrawTranslucentRenderables)
                hook.Add('PlayerBindPress', 'item.preview', PlayerBindPress)
                hook.Add('InputMouseApply', 'item.preview', InputMouseApply)
                hook.Add('HUDPaint', 'item.preview', HUDPaint)
            elseif not enable then
                ix.gui.preventSelection = false

                hook.Remove('PostDrawTranslucentRenderables', 'item.preview')
                hook.Remove('PlayerBindPress', 'item.preview')
                hook.Remove('InputMouseApply', 'item.preview')
                hook.Remove('HUDPaint', 'item.preview')

                preview = false

                if IsValid(mdl) then
                    mdl:Remove()
                end
            end
        end

        net.Receive("build.place", function()
            if IsValid(ix.gui.menu) then
                ix.gui.menu:Remove()
            end

            local mdl = net.ReadString()

            ix.Item:BuildPreview(true, mdl)

            buildCallback = function()
                net.Start("build.place")
                net.WriteAngle(angle)
                net.WriteVector(origin)
                net.SendToServer()
            end
        end)
    end
else
    util.AddNetworkString("build.place")
    util.AddNetworkString("build.stop")

    net.Receive("build.stop", function(len, client)
        local item = client.build_item
        if item and item.user == client then
            item.user = nil
        end
    end)

    net.Receive("build.place", function(len, client)
        local angle = net.ReadAngle()
        local pos = net.ReadVector()
        local item = client.build_item

        --print("[Server] Получены данные для размещения: позиция =", pos, ", угол =", angle)

        if item and item.user == client then
            --print("[Server] Начинаем размещение.")
            item:OnPlace(client, pos, angle)
            item:Remove()
        else
            --print("[Server] Ошибка: item или user невалиден.")
        end
    end)
end

function Item:Init()
    self.category = 'Строительство'
    self.preview_model = self.preview_model or ""
    self.isEntity = self.isEntity or false

    self.functions.place = {
        name = "Разместить",
        OnRun = function(item)
            if item.factionLock then
                local client = item.player

                if !item.factionLock[client:Team()] then
                    client:Notify("Вы не можете этим пользоваться!")
                    return
                end
            end
            
            if item.preview_model then
                net.Start("build.place")
                net.WriteString(item.preview_model)
                net.Send(item.player)

                item.player.build_item = item
                item.user = item.player
            end
        end,
        OnCanRun = function(item)
            return IsValid(item.player) and not IsValid(item.entity) and not item.player:IsRestricted() and not IsValid(item.user)
        end
    }
end

function Item:OnPlace(client, pos, angle)
    -- Проверяет, есть ли данные для контейнера
    local data = ix.container.stored[self.preview_model:lower()]

    if data then
        -- Создаем контейнер
        local container = ents.Create("ix_container")
        container:SetPos(pos)
        container:SetAngles(angle)
        container:SetModel(self.preview_model)
        container:Spawn()

        if IsValid(container) then
            container:SetNetVar("owner", client:GetCharacter():GetID())
            
            local phys = container:GetPhysicsObject()

            if IsValid(phys) then
                phys:EnableMotion(false)  -- Замораживаем физику контейнера
            end
            
            container:CreateInventory(data)
           -- print("[Server] Контейнер успешно создан.")
        else
           -- print("[Server] Ошибка: контейнер невалиден.")
        end
    else
        -- Если это не контейнер, проверяем, можно ли создать Энтити или NPC
        local entityClass = modelToEntity[self.preview_model]
        
        if entityClass then
            -- Создаем Энтити или NPC
           --print("[Server] Создаем Энтити или NPC: ", entityClass)
            local ent = ents.Create(entityClass)
            if IsValid(ent) then
                ent:SetPos(pos)
                ent:SetAngles(angle)
                ent:Spawn()

                -- Если это не NPC, замораживаем физику
                if not ent:IsNPC() then
                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:EnableMotion(false)  -- Замораживаем физику энтити
                    end
                else
                    ent:SetKeyValue("spawnflags", 8192) -- Пример настройки флага для NPC
                end

                ent:SetNetVar("owner", client:GetCharacter():GetID())
                --print("[Server] Энтити или NPC успешно создан.")
            else
                --print("[Server] Ошибка: Энтити или NPC невалиден.")
            end
        else
            -- Если это не Энтити или NPC, пробуем создать как обычный проп
            --print("[Server] Создаем проп: ", self.preview_model)
            local prop = ents.Create("prop_physics")
            prop:SetModel(self.preview_model)
            prop:SetPos(pos)
            prop:SetAngles(angle)
            prop:Spawn()

            local phys = prop:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)  -- Замораживаем физику пропа
            end

            prop:SetNetVar("owner", client:GetCharacter():GetID())
            prop:SetPersistent( true )
            --print("[Server] Проп успешно создан.")
        end
    end
end

if CLIENT then
    function Item:PopulateTooltip(tooltip)
        local data = ix.container.stored[self.preview_model:lower()]
        if data then
            local size = tooltip:AddRowAfter("name")
            size:SetBackgroundColor(derma.GetColor("Success", tooltip))
            size:SetText(string.format("Вместимость: %s", tostring(data.width).."x"..tostring(data.height)))
        end
    end
end

return Item
