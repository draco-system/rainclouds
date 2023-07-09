    return Def.ActorFrame{
        Def.Quad{
            InitCommand = function(self)
                self
                :SetSize(420, 40)
                :diffuse(1,1,1,1)
                :skewx(0.5)
        end,
        }
    }