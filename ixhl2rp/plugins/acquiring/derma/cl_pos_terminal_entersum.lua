local PANEL = {}

function PANEL:Init()
    self:SetSize(200,95)
    self:SetTitle("Выставление оплаты")
    self:Center()
    self:MakePopup()

    self.checkboxDismiss = self:Add("DCheckBoxLabel")
    self.checkboxDismiss:Dock(TOP)
    self.checkboxDismiss:SetText("Не сбрасывать при оплате")

    self.textEntry = self:Add("DTextEntry")
    self.textEntry:Dock(TOP)

    self.saveBtn = self:Add("DButton")
    self.saveBtn:Dock(BOTTOM)
    self.saveBtn:SetText("Выставить оплату")

    self.saveBtn.DoClick = function()
        netstream.Start("acquiringEnterSum", self.checkboxDismiss:GetChecked(), self.textEntry:GetValue())
    end
end

function PANEL:SetData(data)
    self.checkboxDismiss:SetChecked(data.dismiss)
    self.textEntry:SetValue(data.sum)
end

vgui.Register("ixPosTerminalInput", PANEL, "DFrame")