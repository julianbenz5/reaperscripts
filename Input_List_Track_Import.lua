--[[
 * Author: Julian Benz
 * Location: Phoenix SharePoint/#Production/2a_Audio/Reaper_Scripts or https://github.com/julianbenz5/reaperscripts
]]


--[[
 * Changelog:
 * V1.0 17/09/2024 Reaper Version v7.16
]]


function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function splitCSVLine(line)
  local columns = {}
  for column in
string.gmatch(line, '([^,]*),?') do
  table.insert(columns,
column)
  end
  return columns[5]
-- Return the first two columns
end

----------------------------------------------------------------------

function read_lines(filepath)

  reaper.Undo_BeginBlock() -- Begin undo group

  local f = io.input(filepath)
  i = 0
  firstrow = true
  repeat

    s = f:read ("*l") -- read one line

    if s then  -- if not end of file (EOF)

      name = splitCSVLine(s)
      if name ~= nil and name ~= "*~##~*" and not firstrow then
        track = reaper.GetTrack(0, i)
      
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
        i = i + 1
      end
      firstrow = false
    end

  until not s  -- until end of file

  f:close()

  count_lines = reaper.CountTracks(0)
  for id = count_lines - 1, i, -1 do
    track = reaper.GetTrack(0, id)
    _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if name == "" then
      reaper.DeleteTrack(track)
    end
  end

  reaper.Undo_EndBlock("Display script infos in the console", -1) -- End undo group

end



-- START -----------------------------------------------------
retval, filetxt = reaper.GetUserFileNameForRead("", "Import tracks from file", "csv")

if retval then

  reaper.PreventUIRefresh(1)
  read_lines(filetxt)



  -- Update TCP
  reaper.TrackList_AdjustWindows(false)
  reaper.UpdateTimeline()

  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)

end
