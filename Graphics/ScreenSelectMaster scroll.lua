local gc = Var("GameCommand")

return Def.ActorFrame {
    Def.ActorFrame {
        LoseFocusCommand = function(self)
            self:zoom(0.75)
        end,
        GainFocusCommand = function(self)
            self:zoom(1)
        end,
        Def.Quad {
            InitCommand = function(self)
                self:SetSize(300, 60):diffuse(0, 0, 0, 0.5)
            end,
        },
        Def.Text{
            Font = THEME:GetPathF('','EXO-REGULAR.TTF'),
            Text = gc:GetText() or gc:GetName(),
            Size = 45,
            StrokeSize = 2,
            InitCommand = function(self)
                self:y(12)
                self:MainActor() :diffuse(color('#FFFFFF'))
                self:StrokeActor() :diffuse(color('#798BA8'))
            end,
            LoseFocusCommand = function(self)
                self:glow(0, 0, 0, 0.5)
            end,
            GainFocusCommand = function(self)
                self:glow(1, 1, 1, 0)
            end
        },
    },
}
