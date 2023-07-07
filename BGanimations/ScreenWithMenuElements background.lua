-- return Def.ActorFrame{ Def.Sprite{
--     Texture = THEME:GetPathG('','caught-in-4k'), --calling GetPathG through theme functions; uses 2 strings
--     OnCommand = function(self) self:Center() 
--     end 
--     }
--}

return Def.ActorFrame{ Def.Sprite{
    Frag = THEME:GetPathG('','shader.frag'), --shader :)
    OnCommand = function(self) self:Center() :zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
end
    }
}
