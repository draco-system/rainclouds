-- Global Colour to define the colour of the wheel, Change this if orange isnt your flavour.
local DisplayColor = color('#798BA8')

local OffsetMath = 480 / SCREEN_HEIGHT

-- Difficulty Colours
local DiffColors = {
	color("#88ffff"), -- Difficulty_Beginner
	color("#ffff88"), -- Difficulty_Easy
	color("#ff8888"), -- Difficulty_Medium
	color("#88ff88"), -- Difficulty_Hard
	color("#8888ff"), -- Difficulty_Challenge
	color("#888888") -- Difficulty_Edit
}

-- Difficulty Names.
-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution#Difficulty
local DiffNames = {
	"PRACTICE", -- Difficulty_Beginner
	"BASIC", -- Difficulty_Easy
	"TRICK", -- Difficulty_Medium
	"MANIAC", -- Difficulty_Hard
	"EXTRA", -- Difficulty_Challenge
	"EDIT" -- Difficulty_Edit
}

-- We define the curent song if no song is selected.
if not CurSong then CurSong = 1 end

-- We define the current group to be empty if no group is defined.
if not CurGroup then GurGroup = "" end

-- Position on the difficulty select that shows up after we picked a song.
local DiffPos = { [PLAYER_1] = 1, [PLAYER_2] = 1 }

-- The increase offset for when we move with postive.
local IncOffset = 1

-- The decrease offset for when we move with negative.
local DecOffset = 13

-- The center offset of the wheel.
local XOffset = 7

local IsOnGroupMusic = false

-- Move the wheel, We define the Offset using +1 or -1.
-- We parse the Songs also so we can get the amount of songs.
local function MoveSelection(self, offset, Songs)

	-- Curent Song + Offset.
	CurSong = CurSong + offset

	-- Check if curent song is further than Songs if so, reset to 1.
	if CurSong > #Songs then CurSong = 1 end
	-- Check if curent song is lower than 1 if so, grab last song.
	if CurSong < 1 then CurSong = #Songs end

	-- Set the offsets for increase and decrease.
	DecOffset = DecOffset + offset
	IncOffset = IncOffset + offset

	if DecOffset > 13 then DecOffset = 1 end
	if IncOffset > 13 then IncOffset = 1 end

	if DecOffset < 1 then DecOffset = 13 end
	if IncOffset < 1 then IncOffset = 13 end

	-- Set the offset for the center of the wheel.
	XOffset = XOffset + offset
	if XOffset > 13 then XOffset = 1 end
	if XOffset < 1 then XOffset = 13 end

	-- If we are calling this command with an offset that is not 0 then do stuff.
	if offset ~= 0 then

		-- For every part on the wheel do.
		for i = 1, 13 do

			-- Make a transform command that changes the location of the part.
			local transform = ((i - XOffset) * (i - XOffset)) * 3

			-- If the part is outside the decrease and increase value then transform it.
			if DecOffset < i and DecOffset > XOffset then
				transform = ((13 - i + XOffset) * (13 - i + XOffset)) * 3
			end

			-- If the part is inside the decrease and increase value then transform it.
			if IncOffset > i and DecOffset < XOffset then
				transform = ((13 + i - XOffset) * (13 + i - XOffset)) * 3
			end

			-- Calculate current position based on song with a value to get center.
			local pos = CurSong + (6 * offset)

			-- Keep it within reasonable values.
			while pos > #Songs do pos = pos - #Songs end
			while pos < 1 do pos = #Songs + pos end

			-- Transform the wheel, As in make it move.
			self:GetChild("Wheel"):GetChild("Container" .. i):linear(.1):x(0):addy((offset * -45))

			-- Here we define what the wheel does if it is outside the values.
			-- So that when a part is at the bottom it will move to the top.
			if (i == IncOffset and offset == -1) or (i == DecOffset and offset == 1) then

				-- Move wheelpart instantly to new location.
				self:GetChild("Wheel"):GetChild("Container" .. i):sleep(0):addy((offset * -45) * -13)

				-- Check if it's a song.
				if type(Songs[pos]) ~= "string" then
					-- It's a song, Display song title.
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Title"):settext(Songs[pos][1]:GetDisplayMainTitle())
				else
					-- It is not a song, Display group name instead.
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Title"):settext(Songs[pos])
				end

				-- Set the width of the text.
				self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Title"):zoom(.7):y(-16):maxwidth(500)

				-- Check if it's a song.
				if type(Songs[pos]) ~= "string" then
					-- Check if song has subtitle.
					if Songs[pos][1]:GetDisplaySubTitle() ~= "" then
						-- It does have a subtitle so resize the title to fit it.
						self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Title"):zoom(.4):y(-26):maxwidth(715)
					end

					-- Set subtitle and artist to the values it has.
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("SubTitle"):settext(Songs[pos][1]:GetDisplaySubTitle())
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Artist"):settext(Songs[pos][1]:GetDisplayArtist())
				else
					-- It is not a song so we set it to empty, Because groups dont have subtitles or atists.
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("SubTitle"):settext("")
					self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Artist"):settext("")
				end

				self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Title"):Regen()
				self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("SubTitle"):maxwidth(1750):Regen()
				self:GetChild("Wheel"):GetChild("Container" .. i):GetChild("Artist"):maxwidth(1750):Regen()
			end
		end

		-- We have a top banner and an under banner to make smooth transisions between songs.

		-- Check if it's a song.
		if type(Songs[CurSong]) ~= "string" then
			-- It is a song, so we load the under banner.
			if Songs[CurSong][1]:HasBanner() then
				self:GetChild("BannerUnderlay"):visible(1):Load(Songs[CurSong][1]:GetBannerPath())
			else
				self:GetChild("BannerUnderlay"):visible(0)
			end
		else
			-- It is not a song, Do an extra check to see if group has banner.
			if SONGMAN:GetSongGroupBannerPath(Songs[CurSong]) ~= "" then
				-- It does, Display it.
				self:GetChild("BannerUnderlay"):visible(1):Load(SONGMAN:GetSongGroupBannerPath(Songs[CurSong]))
			else
				-- It doesnt, Hide it.
				self:GetChild("BannerUnderlay"):visible(0)
			end
		end

		-- Now we resize the banner to the proper size we want.
		self:GetChild("BannerUnderlay"):zoom(TF_WHEEL.Resize(self:GetChild("BannerUnderlay"):GetWidth(),
			self:GetChild("BannerUnderlay"):GetHeight(), 224, 70))

		-- Load the top banner, This one shows when its done transitioning.
		self:GetChild("BannerOverlay"):diffusealpha(1):linear(.1):diffusealpha(0):sleep(0):queuecommand("Load"):diffusealpha(1)

		-- Load the CDTitle command to do funky animation.
		self:GetChild("CDTitle"):linear(.05):zoomy(0):sleep(0):queuecommand("Load")

		-- We are on an offset of 0.
	else

		-- For every part of the wheel do.
		for i = 1, 13 do

			-- Offset for the wheel items.
			local off = i + XOffset

			-- Stay withing limits.
			while off > 13 do off = off - 13 end
			while off < 1 do off = off + 13 end

			-- Get center position.
			local pos = CurSong + i

			-- If item is above 6 then we do a +13 to fix the display.
			if i > 6 then
				pos = CurSong + i - 13
			end

			-- Keep pos withing limits.
			while pos > #Songs do pos = pos - #Songs end
			while pos < 1 do pos = #Songs + pos end

			-- Check if it's a song.
			if type(Songs[pos]) ~= "string" then
				-- It's a song, Display song title.
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Title"):settext(Songs[pos][1]:GetDisplayMainTitle())
			else
				-- It is not a song, Display group name instead.
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Title"):settext(Songs[pos])
			end

			-- Set the width of the text.
			self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Title"):zoom(.7):y(-16):maxwidth(500)

			-- Check if it's a song.
			if type(Songs[pos]) ~= "string" then
				-- Check if song has subtitle.
				if Songs[pos][1]:GetDisplaySubTitle() ~= "" then
					-- It does have a subtitle so resize the title to fit it.
					self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Title"):zoom(.4):y(-26):maxwidth(715)
				end

				-- Set subtitle and artist to the values it has.
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("SubTitle"):settext(Songs[pos][1]:GetDisplaySubTitle())
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Artist"):settext(Songs[pos][1]:GetDisplayArtist())
			else
				-- It is not a song so we set it to empty, Because groups dont have subtitles or atists.
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("SubTitle"):settext("")
				self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Artist"):settext("")
			end

			self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Title"):Regen()
			self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("SubTitle"):maxwidth(1750):Regen()
			self:GetChild("Wheel"):GetChild("Container" .. off):GetChild("Artist"):maxwidth(1750):Regen()
		end
	end

	-- Check if it's a song.
	if type(Songs[CurSong]) ~= "string" then
		-- It is, Set dancing character to bpm speed.
		self:GetChild("Dance"):SetAllStateDelays(14 / Songs[CurSong][1]:GetDisplayBpms()[2])
	end

	-- For every difficulty that we can display do.
	for i = 1, 6 do
		-- Hide Player1 diff.
		self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffBG"):diffusealpha(0)
		self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffText"):settext(""):Regen()

		-- Hide player2 diff.
		self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffBG"):diffusealpha(0)
		self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffText"):settext(""):Regen()

		-- Hide the feet difficulty meter.
		for i2 = 1, 9 do
			self:GetChild("Diffs"):GetChild("FeetCon" .. i):GetChild("Feet" .. i2):diffusealpha(0)
		end
	end

	-- Check if it's a song.
	if type(Songs[CurSong]) ~= "string" then

		-- For every difficulty do.
		for i = 1, #Songs[CurSong] - 1 do

			if i > 6 then break end

			-- Check if P1 is active.
			if GAMESTATE:IsSideJoined(PLAYER_1) then

				-- Diffuse the background of the difficulty selector.
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffBG"):diffuse(DiffColors[
					TF_WHEEL.DiffTab[Songs[CurSong][i + 1]:GetDifficulty()]])

				-- Diffuse the text.
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffText"):settext(DiffNames[
					TF_WHEEL.DiffTab[Songs[CurSong][i + 1]:GetDifficulty()]]):Regen()
			end

			-- Check if P2 is active.
			if GAMESTATE:IsSideJoined(PLAYER_2) then

				-- Diffuse the background of the difficulty selector.
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffBG"):diffuse(DiffColors[
					TF_WHEEL.DiffTab[Songs[CurSong][i + 1]:GetDifficulty()]])

				-- Diffuse the text.
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffText"):settext(DiffNames[
					TF_WHEEL.DiffTab[Songs[CurSong][i + 1]:GetDifficulty()]]):Regen()
			end

			-- Diffuse the feet.
			for i2 = 1, 9 do
				self:GetChild("Diffs"):GetChild("FeetCon" .. i):GetChild("Feet" .. i2):diffuse(DiffColors[
					TF_WHEEL.DiffTab[Songs[CurSong][i + 1]:GetDifficulty()]]):diffusealpha(.5)
			end

			-- We check the meter and see if every feet needs to be active.
			for i2 = 1, Songs[CurSong][i + 1]:GetMeter() do
				if i2 > 9 then break end
				-- Diffuse them.
				self:GetChild("Diffs"):GetChild("FeetCon" .. i):GetChild("Feet" .. i2):diffusealpha(1)
			end

			-- Extra check to diffuse the player difficulty selector on a 0 offset.
			if offset == 0 then
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):diffusealpha(0)
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):diffusealpha(0)
			end

			-- Check if P1 is active, if P1 is active, show the difficulty selector.
			if GAMESTATE:IsSideJoined(PLAYER_1) then
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):diffusealpha(1)
			end

			-- Check if P2 is active, if P2 is active, show the difficulty selector.
			if GAMESTATE:IsSideJoined(PLAYER_2) then
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):diffusealpha(1)
			end

			-- Check the diffuse position of P1, if its not active, hide it.
			if DiffPos[PLAYER_1] ~= i then
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):stopeffect()
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffBG"):stopeffect()
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffText"):stopeffect()
			end

			-- Keep withing boundaries.
			if DiffPos[PLAYER_1] > #Songs[CurSong] - 1 then
				DiffPos[PLAYER_1] = 1
			end

			-- Do effects on active position of player.
			if DiffPos[PLAYER_1] == i then
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):bounce():effectmagnitude(-20, 0, 0):effectperiod(.6)
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffBG"):glowshift():effectperiod(1.2)
				self:GetChild("Diffs"):GetChild("DiffName1P" .. i):GetChild("DiffText"):glowshift():effectperiod(1.2)
			end

			-- Check the diffuse position of P2, if its not active, hide it.
			if DiffPos[PLAYER_2] ~= i then
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):stopeffect()
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffBG"):stopeffect()
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffText"):stopeffect()
			end

			-- Keep withing boundaries.
			if DiffPos[PLAYER_2] > #Songs[CurSong] - 1 then
				DiffPos[PLAYER_2] = 1
			end

			-- Do effects on active position of player.
			if DiffPos[PLAYER_2] == i then
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):bounce():effectmagnitude(20, 0, 0):effectperiod(.6)
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffBG"):glowshift():effectperiod(1.2)
				self:GetChild("Diffs"):GetChild("DiffName2P" .. i):GetChild("DiffText"):glowshift():effectperiod(1.2)
			end
		end
	end

	local Difficulties = #Songs[CurSong] - 1
	if Difficulties > 6 then Difficulties = 6 end

	-- Check if it has more difficulties than 3, If it does, zoom them to make space for the other ones.
	if #Songs[CurSong] - 1 > 3 then
		self:GetChild("Diffs"):zoomy(3 / Difficulties):y(-45 + Difficulties)
	else
		self:GetChild("Diffs"):zoomy(1):y(-45)
	end

	-- Check if its a song.
	if type(Songs[CurSong]) ~= "string" then
		-- Do a counting up or counting down effect on the BPM display.
		self:GetChild("BPM"):settext(string.format("%.0f", Songs[CurSong][1]:GetDisplayBpms()[2])):Regen()
				
	else
		self:GetChild("BPM"):settext(0):Regen()
		
	end


	-- Check if offset is not 0.
	if offset ~= 0 then

		self:GetChild("Slider"):linear(.1):y(-176 + (350 * (CurSong / #Songs)))

		-- Stop all the music playing, Which is the Song Music
		if not IsOnGroupMusic then
			SOUND:StopMusic()
		end

		-- Play Current selected Song Music.
		self:GetChild("MusicCon"):stoptweening():sleep(0.4):queuecommand("PlayCurrentSong")
	else
		self:GetChild("Slider"):y(-176 + (350 * (CurSong / #Songs)))
	end
end

-- Change the cursor of Player on the difficulty selector.
local function MoveDifficulty(self, offset, Songs)

	-- check if player is joined.
	if GAMESTATE:IsSideJoined(self.pn) then

		-- Move cursor.
		DiffPos[self.pn] = DiffPos[self.pn] + offset

		-- Keep within boundaries.
		if DiffPos[self.pn] < 1 then DiffPos[self.pn] = 1 end
		if DiffPos[self.pn] > #Songs[CurSong] - 1 then DiffPos[self.pn] = #Songs[CurSong] - 1 end

		-- Call the move selecton command to update the graphical location of cursor.
		MoveSelection(self, 0, Songs)
	end
end

-- This is the main function, Its the function that contains the wheel.
return function(Style)

	-- Load the songs from the Songs.Loader module.
	local Songs = LoadModule("Songs.Loader.lua")(Style)

	-- Sort the Songs and Group.
	local GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs, CurGroup)

	-- We define here is we load the Options menu when people double press,
	-- Because they need to double press it starts at false.
	local StartOptions = false

	-- The actual wheel.
	local Wheel = Def.ActorFrame { Name = "Wheel" }

	-- The difficulties.
	local Diffs = Def.ActorFrame { Name = "Diffs" }

	-- For every item on the wheel do.
	for i = 1, 13 do
		-- Grab center of wheel.
		local offset = i - 7

		-- Also grab center of wheel.
		local pos = CurSong + i - 7

		-- But we keep it within limits.
		while pos > #GroupsAndSongs do pos = pos - #GroupsAndSongs end
		while pos < 1 do pos = #GroupsAndSongs + pos end

		-- Append to the wheel.
		Wheel[#Wheel + 1] = Def.ActorFrame {
			Name = "Container" .. i,

			-- Set position of item.
			OnCommand = function(self) self:xy(0, offset * 45) end,

			-- Song Title for on wheel.
			Def.Text {
				Name = "Title",
				Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
				Font = THEME:GetPathF('','AlphaProta.ttf'),
				StrokeSize = 2,
				OnCommand = function(self)
					-- Check if we are on group.
					if type(GroupsAndSongs[pos]) == "string" then
						-- Show group name.
						self:settext(GroupsAndSongs[pos])
						-- not group.
					else
						-- Show song title.
						self:settext(GroupsAndSongs[pos][1]:GetDisplayMainTitle())
					end

					-- Set the size of the text and the location.
					self:zoom(.4):y(-26)
						:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
						:skewx(-.2)
						:MainActor():diffusealpha(0)

					-- Check if it's a song.
					if type(GroupsAndSongs[pos]) ~= "string" then

						-- Check if song subtitle is empty.
						if GroupsAndSongs[pos][1]:GetDisplaySubTitle() == "" then

							-- Its empty, Make title full size.
							self:zoom(.7):y(-16)
						end
					else
						-- It's not a song, And groups dont have subtitles.
						self:zoom(.7):y(-16)
					end
				end
			},

			-- The subtitle.
			Def.Text {
				Name = "SubTitle",
				Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
				Font = THEME:GetPathF('','AlphaProta.ttf'),
				StrokeSize = 2,
				OnCommand = function(self)
					-- Check if we are on group.
					if type(GroupsAndSongs[pos]) ~= "string" then
						-- Set Subtitle.
						self:settext(GroupsAndSongs[pos][1]:GetDisplaySubTitle())
					end

					-- Set size and colour.
					self:zoom(.2):y(-12)
						:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
						:skewx(-.2)
						:MainActor():diffusealpha(0)
				end
			},
			Def.Text {
				Name = "Artist",
				Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
				Font = THEME:GetPathF('','AlphaProta.ttf'),
				StrokeSize = 2,
				OnCommand = function(self)
					-- Check if we are on group.
					if type(GroupsAndSongs[pos]) ~= "string" then
						-- Set artist.
						self:settext(GroupsAndSongs[pos][1]:GetDisplayArtist())
					end

					-- Set size and colour.
					self:zoom(.2):y(-4)
						:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
						:skewx(-.2)
						:MainActor():diffusealpha(0)
				end
			}
		}
	end

	-- For every difficulty do.
	for i = 1, 6 do

		-- Let the feet difficulty meter contain the feet.
		local Feet = Def.ActorFrame { Name = "FeetCon" .. i }

		-- Then for ever feet.
		for i2 = 1, 9 do
			Feet[#Feet + 1] = Def.Sprite {
				Name = "Feet" .. i2,
				-- Load feet image from grahpics folder.
				Texture = THEME:GetPathG("", "DDR/Feet"),
				InitCommand = function(self)
					-- Set the colour to black.
					self:zoom(.125):diffuse(0, 0, 0, 0):xy(14 * i2, 22 * i)
				end
			}
		end

		-- Put the feet container inside the difficulty container.
		Diffs[#Diffs + 1] = Feet

		-- Player 1 difficulty selector.
		Diffs[#Diffs + 1] = Def.ActorFrame {
			Name = "DiffName1P" .. i,
			Def.Sprite {
				Name = "DiffBG",
				-- Load difficulty selector image.
				Texture = THEME:GetPathG("", "DDR/DiffSel"),
				InitCommand = function(self)
					-- Resize and position.
					self:zoom(.04):xy(-14, 22 * i)
				end
			},

			-- Difficulty text.
			Def.Text {
				Name = "DiffText",
				Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
				Font = THEME:GetPathF('','AlphaProta.ttf'),
				InitCommand = function(self)
					-- Set size, colour, position and maxwidth.
					self:zoom(.18):diffuse(0, 0, 0, 1):xy(-17, 22 * i):maxwidth(140)
				end
			}
		}

		-- Player 2 difficulty selector.
		Diffs[#Diffs + 1] = Def.ActorFrame {
			Name = "DiffName2P" .. i,
			Def.Sprite {
				-- Load difficulty selector image.
				Name = "DiffBG",
				Texture = THEME:GetPathG("", "DDR/DiffSel"),
				InitCommand = function(self)
					-- Resize and position.
					-- We do minus on the zoom to flip the image.
					self:zoom(-.04):xy(150.5, 22 * i)
				end
			},

			-- Difficulty text.
			Def.Text {
				Name = "DiffText",
				Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
				Font = THEME:GetPathF('','AlphaProta.ttf'),
				InitCommand = function(self)
					-- Set size, colour, position and maxwidth.
					self:zoom(.18):diffuse(0, 0, 0, 1):xy(154, 22 * i):maxwidth(140)
				end
			}
		}
	end



	-- Here we return the actual Music Wheel Actor.
	return Def.ActorFrame {
		OnCommand = function(self)
			self:Center():zoom(SCREEN_HEIGHT / 480)
			-- We use a Input function from the Scripts folder.
			-- It uses a Command function. So you can define all the Commands,
			-- Like MenuLeft is MenuLeftCommand.
			SCREENMAN:GetTopScreen():AddInputCallback(TF_WHEEL.Input(self))

			MoveSelection(self, 0, GroupsAndSongs)

			-- Sleep for 0.2 sec, And then load the current song music.
			self:GetChild("MusicCon"):stoptweening():sleep(0):queuecommand("PlayCurrentSong")
		end,

		-- Play Music at start of screen,.
		Def.ActorFrame {
			Name = "MusicCon",
			PlayCurrentSongCommand = function(self)
				-- TF_WHEEL.BG:Load(GroupsAndSongs[CurSong][1]:GetBackgroundPath()):FullScreen()
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					if GroupsAndSongs[CurSong][1].PlayPreviewMusic then
						GroupsAndSongs[CurSong][1]:PlayPreviewMusic()
					elseif GroupsAndSongs[CurSong][1]:GetMusicPath() then
						SOUND:PlayMusicPart(GroupsAndSongs[CurSong][1]:GetMusicPath(),
							GroupsAndSongs[CurSong][1]:GetSampleStart(),
							GroupsAndSongs[CurSong][1]:GetSampleLength(), 0, 0, true)
					end
					IsOnGroupMusic = false
				elseif not IsOnGroupMusic then
					SOUND:PlayMusicPart(THEME:GetPathS('','MusicWheel.ogg'),0,89,0,0, true)
					IsOnGroupMusic = true
				end
			end
		},

		-- Do stuff when a user presses left on Pad or Menu buttons.
		MenuLeftCommand = function(self) MoveSelection(self, -1, GroupsAndSongs) end,

		-- Do stuff when a user presses Right on Pad or Menu buttons.
		MenuRightCommand = function(self) MoveSelection(self, 1, GroupsAndSongs) end,

		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuDownCommand = function(self) MoveDifficulty(self, 1, GroupsAndSongs) end,

		-- Do stuff when a user presses the Down on Pad or Menu buttons.
		MenuUpCommand = function(self) MoveDifficulty(self, -1, GroupsAndSongs) end,

		-- Do stuff when a user presses the Back on Pad or Menu buttons.
		BackCommand = function(self)
			-- Check if User is joined.
			if GAMESTATE:IsSideJoined(self.pn) then
				if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2) then
					-- If both players are joined, We want to unjoin the player that pressed back.
					GAMESTATE:UnjoinPlayer(self.pn)

					MoveSelection(self, 0, GroupsAndSongs)
				else
					-- Go to the previous screen.
					SCREENMAN:GetTopScreen():SetNextScreenName(SCREENMAN:GetTopScreen():GetPrevScreenName()):StartTransitioningScreen("SM_GoToNextScreen")
				end
			end
		end,

		-- Do stuff when a user presses the Start on Pad or Menu buttons.
		StartCommand = function(self)
			-- Check if we want to go to ScreenPlayerOptions instead of ScreenGameplay.
			if StartOptions then
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPlayerOptions"):StartTransitioningScreen("SM_GoToNextScreen")
			end
			-- Check if player is joined.
			if GAMESTATE:IsSideJoined(self.pn) then

				-- Check if we are on a group.
				if type(GroupsAndSongs[CurSong]) == "string" then

					-- Check if we are on the same group thats currently open,
					-- If not we set the curent group to our new selection.
					if CurGroup ~= GroupsAndSongs[CurSong] then
						CurGroup = GroupsAndSongs[CurSong]

						-- Same group, Close it.
					else
						CurGroup = ""
					end

					-- Reset the groups location so we dont bug.
					GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs, "")
					MoveSelection(self, 0, GroupsAndSongs)

					-- Set CurSong to the right group.
					for i, v in ipairs(GroupsAndSongs) do
						if v == CurGroup then
							CurSong = i
						end
					end

					-- Set the current group.
					GroupsAndSongs = LoadModule("Group.Sort.lua")(Songs, CurGroup)
					MoveSelection(self, 0, GroupsAndSongs)

					-- Not on a group, Start song.
				else

					--We use PlayMode_Regular for now.
					GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")

					--Set the song we want to play.
					GAMESTATE:SetCurrentSong(GroupsAndSongs[CurSong][1])

					-- Check if 2 players are joined.
					if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2) then

						-- If they are, We will use Versus.
						GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDBVersus[Style])

						-- Save Profiles.
						PROFILEMAN:SaveProfile(PLAYER_1)
						PROFILEMAN:SaveProfile(PLAYER_2)

						-- Set the Current Steps to use.
						GAMESTATE:SetCurrentSteps(PLAYER_1, GroupsAndSongs[CurSong][DiffPos[PLAYER_1] + 1])
						GAMESTATE:SetCurrentSteps(PLAYER_2, GroupsAndSongs[CurSong][DiffPos[PLAYER_2] + 1])
					else

						-- If we are single player, Use Single.
						GAMESTATE:SetCurrentStyle(TF_WHEEL.StyleDB[Style])

						-- Save Profile.
						PROFILEMAN:SaveProfile(self.pn)

						-- Set the Current Step to use.
						GAMESTATE:SetCurrentSteps(self.pn, GroupsAndSongs[CurSong][DiffPos[self.pn] + 1])
					end

					-- We want to go to player options when people doublepress, So we set the StartOptions to true,
					-- So when the player presses Start again, It will go to player options.
					StartOptions = true

					-- Wait 0.4 sec before we go to next screen.
					self:sleep(0.4):queuecommand("StartSong")
				end
			else
				-- If no player is active Join.
				GAMESTATE:JoinPlayer(self.pn)

				-- Load the profles.
				GAMESTATE:LoadProfiles()

				MoveSelection(self, 0, GroupsAndSongs)
			end
		end,

		-- Change to ScreenGameplay.
		StartSongCommand = function(self)
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
		end,

		-- The Info display container.
		Def.Sprite {
			Texture = THEME:GetPathG("DDR/Info", "Display"),
			OnCommand = function(self)
				self:zoom(.45):xy(-(SCREEN_CENTER_X * OffsetMath), -60):halign(0)
					:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
			end
		},

		-- The BPM Container.
		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/DiffSel"),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 180, -162):zoom(.05)
					:diffuse(DisplayColor[1] / 1.5, DisplayColor[2] / 1.5, DisplayColor[3] / 1.5, DisplayColor[4])
			end
		},

		-- The BPN Text.
		Def.Text {
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			Text = "BPM",
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 178, -162):zoom(.2):zoomx(.3)
					:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
			end
		},

		-- The BPM numbers.
		Def.Text {
			Name = "BPM",
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			Text = "0",
			OnCommand = function(self)
				-- Check if its a song.
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					-- It is, Display BPM of current song.
					self:settext(string.format("%.0f", GroupsAndSongs[CurSong][1]:GetDisplayBpms()[2])):Regen()
				end

				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 190, -134)
					:zoomy(.6):diffusebottomedge(1, .5, 0, 1)
					:diffusetopedge(1, 1, 0, 1):skewx(-.2)
			end
		},

		Def.Text {
			Text = "bpm",
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 238, -130):zoom(.2)
					:diffuse(1, 1, 0, 1):skewx(-.3)
			end
		},

		-- The stage text container.
		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/DiffSel"),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 70, -154):zoom(.05):zoomx(.07)
					:diffuse(DisplayColor[1] / 1.5, DisplayColor[2] / 1.5, DisplayColor[3] / 1.5, DisplayColor[4])
			end
		},

		-- Set the stage text.
		Def.Text {
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			Text = "STAGE",
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 68, -154):zoom(.2):zoomx(.3)
					:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
			end
		},

		-- The actual event text.
		Def.Text {
			Text = ToEnumShortString(GAMESTATE:GetCurrentStage()):upper(),
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			OnCommand = function(self)
				self:MainActor():diffuse(0, 0.5, 0, 1)
				self:StrokeActor():diffuse(0, 0.5, 0, 1)
				self:zoom(0.3)
				:xy(-(SCREEN_CENTER_X * OffsetMath) + 68, -136):skewx(-0.2)
			end
		},

		-- Load the dancing character.
		Def.Sprite {
			Name = "Dance",
			Texture = THEME:GetPathG("", "DDR/Dance"),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 272, -140):zoom(.14)
			end
		},

		-- Load the under banner.
		Def.Sprite {
			Name = "BannerUnderlay",
			InitCommand = function(self)
				self:zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 224, 70))
					:xy(-(SCREEN_CENTER_X * OffsetMath) + 150, -84)
			end
		},

		-- Load the top banner.
		Def.Sprite {
			Name = "BannerOverlay",
			InitCommand = function(self)
				-- Check if its a song.
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					-- It is, Load banner.
					self:Load(GroupsAndSongs[CurSong][1]:GetBannerPath())
				else
					-- It's a group, Check if it has a banner.
					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]) ~= "" then
						-- It does, Load it.
						self:Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]))
					end
				end

				self:zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 224, 70))
					:xy(-(SCREEN_CENTER_X * OffsetMath) + 150, -84)
			end,
			LoadCommand = function(self)
				-- Check if its a song.
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					-- It is, Check if it has a banner.
					if GroupsAndSongs[CurSong][1]:HasBanner() then
						-- It does, Load it.		
						self:visible(1):Load(GroupsAndSongs[CurSong][1]:GetBannerPath())
					else
						-- It doesnt, Hide the banner.
						self:visible(0)
					end
				else
					-- It's a group, Check if it has a banner.
					if SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]) ~= "" then
						-- It does, Load it.
						self:visible(1):Load(SONGMAN:GetSongGroupBannerPath(GroupsAndSongs[CurSong]))
					else
						-- It doesnt, Hide the banner.
						self:visible(0)
					end
				end

				self:zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 224, 70))
			end
		},

		Def.Sprite {
			Name = "CDTitle",
			InitCommand = function(self)
				-- Check if its a song.
				if type(GroupsAndSongs[CurSong]) ~= "string" then
					-- It is, Get CDTitle.
					self:Load(GroupsAndSongs[CurSong][1]:GetCDTitlePath())
				end

				self:zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 50, 50))
					:xy(-(SCREEN_CENTER_X * OffsetMath) + 240, -102)
			end,
			LoadCommand = function(self)
				-- Check if its a song.
				-- Also check if we have a CDTitle to display. ~Sudo
				if type(GroupsAndSongs[CurSong]) ~= "string" and GroupsAndSongs[CurSong][1]:GetCDTitlePath() then
					-- It is, Get CDTitle.
					self:visible(true):Load(GroupsAndSongs[CurSong][1]:GetCDTitlePath())
				else
					-- It's not, Hide CDTitle.
					self:visible(false)
				end

				self:zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 60, 60)):zoomy(0)
					:linear(.05):zoom(TF_WHEEL.Resize(self:GetWidth(), self:GetHeight(), 60, 60))
			end
		},

		-- Load left part of difficulty text container.
		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/DiffSel"),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 120, -42):zoom(.033):zoomx(-.08)
					:diffuse(DisplayColor[1] / 1.5, DisplayColor[2] / 1.5, DisplayColor[3] / 1.5, DisplayColor[4])
			end
		},

		-- Load right part of difficulty text container.
		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/DiffSel"),
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 174, -42):zoom(.033):zoomx(.08)
					:diffuse(DisplayColor[1] / 1.5, DisplayColor[2] / 1.5, DisplayColor[3] / 1.5, DisplayColor[4])
			end
		},

		-- Actual P1 text.
		Def.Text {
			Text = "1P",
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			OnCommand = function(self)
				self:MainActor():diffuse(DisplayColor[1] / 4, DisplayColor[2] / 4, DisplayColor[3] / 4, DisplayColor[4])
					self:StrokeActor():diffuse(DisplayColor[1] / 4, DisplayColor[2] / 4, DisplayColor[3] / 4, DisplayColor[4])
					self:xy(-(SCREEN_CENTER_X * OffsetMath) + 36, -40):zoomy(.23):zoomx(.33):skewx(-.25)
			end
		},

		Def.Text {
			Text = "2P",
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			OnCommand = function(self)
				self:MainActor():diffuse(DisplayColor[1] / 4, DisplayColor[2] / 4, DisplayColor[3] / 4, DisplayColor[4])
					self:StrokeActor():diffuse(DisplayColor[1] / 4, DisplayColor[2] / 4, DisplayColor[3] / 4, DisplayColor[4])
					self:xy(-(SCREEN_CENTER_X * OffsetMath) + 260, -40):zoomy(.23):zoomx(.33):skewx(-.25)
			end
		},

		-- The difficulty text.
		Def.Text {
			Fallback = THEME:GetPathF('','NotoSans-All.ttf'),
			Font =  THEME:GetPathF('','AlphaProta.ttf'),
			Text = "DIFFICULTY",
			OnCommand = function(self)
				self:xy(-(SCREEN_CENTER_X * OffsetMath) + 148, -42):zoom(.18):zoomx(.3)
					:diffuse(DisplayColor[1], DisplayColor[2], DisplayColor[3], DisplayColor[4])
			end
		},

		-- Load the difficulties selector.
		Diffs .. { OnCommand = function(self) self:x(-(SCREEN_CENTER_X * OffsetMath) + 78):valign(0) end },

		-- Wheel background
		Def.Quad {
			InitCommand = function(self)
				self
					:x((SCREEN_CENTER_X * OffsetMath) - 180)
					:SetSize(360, SCREEN_HEIGHT)
					:diffuse(0, 0, 0, 0.5)
					:fadeleft(0.025)
					:faderight(0.025)
			end,
		},

		-- Add the glowing selector part on the top of the wheel.
		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/Selector"),
			OnCommand = function(self)
				self:zoom(.65):xy((SCREEN_CENTER_X * OffsetMath) - 180, -2):faderight(1)
					:diffuseshift():effectcolor1(0, 0, 0, .3)
					:effectcolor2(DisplayColor[1], DisplayColor[2], DisplayColor[3], .5)
			end
		},

		Def.Sprite {
			Texture = THEME:GetPathG("", "DDR/Slider"),
			OnCommand = function(self)
				self:zoom(.35):diffuse(.8, .8, 0, 1):x((SCREEN_CENTER_X * OffsetMath) - 20)
			end
		},

		Def.Sprite {
			Name = "Slider",
			Texture = THEME:GetPathG("", "DDR/SlidSelect"),
			OnCommand = function(self)
				self:zoom(.35):diffuse(1, 0, 0, 1):xy((SCREEN_CENTER_X * OffsetMath) - 20, -176 + (350 * (CurSong / #GroupsAndSongs)))
			end
		},

		-- Load the wheel.
		Wheel .. {
			OnCommand = function(self) self:x((SCREEN_CENTER_X * OffsetMath) - 180):y(18) end
		}
	}
end
