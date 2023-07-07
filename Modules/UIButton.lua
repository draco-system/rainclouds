return function(t)

    return Def.Actorframe {
        Def.Quad{
            InitCommand = function(self)
                self
                    :SetWidth(t.Width)
                    :SetHeight(t.Height)
                    :diffuse(color(t.Diffuse))
            end,
        },
        Def.BitmapText{
            Font = 'Common Font'
            Text = t.Text or 'Button'
        }
    }
end