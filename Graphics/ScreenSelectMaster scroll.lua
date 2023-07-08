local gc = Var("GameCommand")

return Def.Text{
    Font = THEME:GetPathF('','EXO-REGULAR.TTF'),
    Text=gc:GetName(),
    Size = 45,
    StrokeSize = 2,
    OnCommand  = function(self) 
        self:MainActor() :diffuse(color('#FFFFFF'))
        self:StrokeActor() :diffuse(color('#798BA8'))   
    end,
    LoseFocusCommand=function (self)
        self:visible(false)
    end,
    GainFocusCommand=function (self)
        self:visible(true)
    end
}
