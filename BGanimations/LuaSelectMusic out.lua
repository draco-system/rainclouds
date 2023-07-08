local UseTwoStepDiff = LoadModule("Config.Load.lua")("UseTwoStepDiff","/Save/OutFoxPrefs.ini")
return Def.ActorFrame{
	InitCommand=function(self)
		self:diffusealpha(0)
	end,
	OffCommand=function(self)
		if not UseTwoStepDiff then
			self:playcommand("UpdateInfo")
			self:easeoutexpo(0.5):diffusealpha(1)
		else
			self:sleep(.2)
		end
	end,
	Def.Sprite{
		UpdateInfoCommand=function(self)
			self:LoadFromSongBackground(GAMESTATE:GetCurrentSong())
			:scale_or_crop_background()
		end
	},

	Def.Quad{
		OnCommand=function(self)
			self:diffuse(Color.Black):zoomto(SCREEN_WIDTH, 128):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
			:diffusealpha(0.6)
		end
	},

	LoadModule("Gameplay/songInfo.lua")..{
		InitCommand=function(self) self:xy( SCREEN_CENTER_X,SCREEN_CENTER_Y ):zoom(1.4) end,
		UpdateInfoCommand=function(self)
			self:playcommand("UpdateSongInfo")
		end
	}
}