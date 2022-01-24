script "tmc3_card_resize_behavior" with behavior "tmc3_MasterBehavior"
local lastAppliedProfile

on resizeStack
   lock screen
   repeat with N = 1 to number of controls of this cd
      dispatch "autoPositionMe" to control N
   end repeat
   positionProfiledControls
   unlock screen
   pass resizeStack
end resizeStack


-- MAY NEED TO EXECUTE THIS ON OPENCARD INSTEAD OF PREOPENCARD
on preOpenCard
   lock screen
   positionProfiledControls
   unlock screen
   pass preOpenCard
end preOpenCard


-- PROFILE ARRAY STRUCTURE: theArray[theDimensions][theCardID][theObjectID][theProp]
command positionProfiledControls
   put the tmControlData["controlProfiles"] of this stack into theArray
   put the keys of theArray into theProfilesList
   replace "x" with "." in theProfilesList
   sort lines of theProfilesList numeric
   replace "." with comma in theProfilesList
   put width of this stack into theStackWidth
   put height of this stack into theStackHeight
   local theNewProfile
   repeat for each line theLine in theProfilesList
      if theStackWidth >= item 1 of theLine and theStackHeight >= item 2 of theLine then \
            put item 1 of theLine & "x" & item 2 of theLine into theNewProfile
   end repeat
   if theNewProfile = theLastAppliedProfile then exit positionProfiledControls
   put the keys of theArray[theNewProfile][id of this cd] into theControlIDs
   if theControlIDs is empty then exit positionProfiledControls
   set itemDel to tab
   repeat for each line theID in theControlIDs
      if not exists(control id theID of this cd) then next repeat
      repeat for each line prop in the keys of theArray[theNewProfile][id of this cd][theID]
         try -- RUN TWICE FOR OBJECTS THAT SCALE PROPORTIONALLY (IE GAUGE)
            set the prop of control id theID to theArray[theNewProfile][id of this cd][theID][prop]
            set the prop of control id theID to theArray[theNewProfile][id of this cd][theID][prop]
         end try
         dispatch "resizeControl" to control id theID
      end repeat
      -- NEEDS TO BE SET AFTER TEXT SIZE
      if the keys of theArray[theNewProfile][id of this cd][theID] contains "tmTextHeight" then
         try
            set the tmTextHeight of control id theID to theArray[theNewProfile][id of this cd][theID]["tmTextHeight"]
         end try
      end if
   end repeat
   put theNewProfile into lastAppliedProfile
end positionProfiledControls
