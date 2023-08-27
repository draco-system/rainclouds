-- return Def.ActorFrame{ Def.Sprite{
--     Texture = THEME:GetPathG('','caught-in-4k'), --calling GetPathG through theme functions; uses 2 strings
--     OnCommand = function(self) self:Center() 
--     end 
--     }
--}
   
return Def.ActorFrame{ 
        Def.Sprite{
        Texture = THEME:GetPathG('','static_stretch'), --calling GetPathG through theme functions; uses 2 strings
        Frag = THEME:GetPathG('','rain.frag'), --shader :)
        OnCommand = function(self)
            self:Center():zoomto(SCREEN_WIDTH,SCREEN_HEIGHT) --setting it to the screen width + height
            self:queuecommand('Update')
        end,
        UpdateCommand = function(self)
            self:aux(self:getaux() + self:GetEffectDelta())
            self:GetShader():uniform1f('realtime', self:getaux()) -- creating our own time variable
            self:sleep(self:GetEffectDelta()):queuecommand('Update')
        end,
    },
}
