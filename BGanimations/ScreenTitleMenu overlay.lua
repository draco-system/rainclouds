return Def.Sprite{
    Texture = THEME:GetPathG('','logo'),
    InitCommand = function(self)
        self:Center():addy(-220):zoom(0.5):bob():effectmagnitude(0, 5, 0) -- :)
    end
}
