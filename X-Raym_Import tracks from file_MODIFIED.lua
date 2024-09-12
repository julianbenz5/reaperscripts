--[[
 * ReaScript Name: Import tracks from file
 * About: Import tracks from a TXT or CSV file. One track name per line.
 * Instructions: Select an item. Use it.
 * Screenshot: http://i.giphy.com/3oEduTrQlzj80oPpWE.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Import track titles from file (eg: CSV)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1564559
 * REAPER: 5.0 pre 36
 * Version: 1.1.1
]]


--[[
 * Changelog:
 * v1.1.1 (2015-08-27)
  # .csv file extension for MacOS
 * v1.1 (2015-08-27)
  # Track order
 * v1.0 (2015-08-27)
  + Initial Release
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
      if name ~= nil and name ~= 
        "*~##~*" and not firstrow then
        track = reaper.GetTrack(0, i)
      
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
          i = i + 1
        end
      firstrow = false
    end

  until not s  -- until end of file

  f:close()

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
