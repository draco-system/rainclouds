return Def.Quad{
    InitCommand = function(self)
        self
        :xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        :diffusealpha(0.2)
        :diffuse((1/255)*121,(1/255)*139,(1/255)*168,0.3)
        :SetSize(1000,500)
end,
}   