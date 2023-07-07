return function(t)

    return Def.Actorframe {
        Def.Quad{
            InitCommand = function(self)
                self
                    :SetWidth(t.Width)
                    :SetHeight(t.Height)
                    :diffuse(color(t.diffuse))
            end,
        },
        Def.BitmapText{
            Font = 'Common Font'
            Text = t.text or 'Button'
        }
    }
end