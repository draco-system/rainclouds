-- return Def.ActorFrame{ Def.Sprite{
--     Texture = THEME:GetPathG('','caught-in-4k'), --calling GetPathG through theme functions; uses 2 strings
--     OnCommand = function(self) self:Center() 
--     end 
--     }
--}

return Def.ActorFrame{ Def.Sprite{
    Texture = THEME:GetPathG('','lichen'), --calling GetPathG through theme functions; uses 2 strings
    Frag = THEME:GetPathG('','shader.frag'), --shader :)
    -- Frag = THEME:GetPathG(',','rain.frag'), for some reason it can't find the shader
    OnCommand = function(self) self:Center() :zoomto(SCREEN_WIDTH,SCREEN_HEIGHT) --setting it to the screen width + height
end
    }
}
