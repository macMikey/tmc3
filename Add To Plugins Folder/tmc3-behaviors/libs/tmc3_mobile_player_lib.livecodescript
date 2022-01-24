script "tmc3_mobile_player_lib" with behavior "tmc3_MasterBehavior"
local myMobileID


on preOpenControl
   if autoCreateMe() then createPlayer
end preOpenControl


on closeControl
   if autoRemoveMe() then deletePlayer
end closeControl


# CREATE MOBILE PLAYER
command createPlayer
   if onDesktop() then exit createPlayer
   -- CREATE MOVIEPLAYER/STORE ID
   mobileControlCreate "player"
   put the result into myMobileID
   set the tmControlData["mobileID"] of me to myMobileID
   -- SET MOVIEPLAYER PROPS
   tmUpdatePlayer
end createPlayer


command tmUpdatePlayer pProp,pValue
   if onDesktop() then exit tmUpdatePlayer
   -- SET SINGLE PROP & EXIT
   if pProp is not empty then
      if number of items of pValue > 1 then put "(" & pValue & ")" into pValue -- BRACKET MULTI-ITEM VALUE IN PARENS
      do "mobileControlSet myMobileID," & pProp & "," & pValue
      exit tmUpdatePlayer
   end if
   -- DEFAULT = CREATE PLAYER & SET ALL PROPS
   mobileControlSet myMobileID, "rect", myRect()
   mobileControlSet myMobileID, "name", myName()
   mobileControlSet myMobileID, "filename", myFilename()
   mobileControlSet myMobileID, "fullscreen", myFullscreen()
   mobileControlSet myMobileID, "preserveAspect", myPreserveAspect()
   mobileControlSet myMobileID, "showController", myShowController()
   mobileControlSet myMobileID, "useApplicationAudioSession", myUseApplicationAudioSession()
   mobileControlSet myMobileID, "shouldAutoplay", myShouldAutoplay()
   mobileControlSet myMobileID, "looping", myLooping()
   mobileControlSet myMobileID, "allowsAirPlay", myAllowsAirPlay()
   mobileControlSet myMobileID, "currentTime", myCurrentTime()
   mobileControlSet myMobileID, "startTime", myStartTime()
   mobileControlSet myMobileID, "endTime", myEndTime()
   mobileControlSet myMobileID, "visible", myVisible()
end tmUpdatePlayer


command deletePlayer
   if onDesktop() then exit deletePlayer
   mobileControlDelete myMobileID
   put empty into myMobileID
end deletePlayer


on resizeControl
   set rect of control 1 of me to rect of me
   if onMobile() then tmUpdatePlayer
end resizeControl


# MOBILE ACTIONS
----------------
command playerCommand pCommand
   -- VALID COMMANDS ARE:
   -- play
   -- pause
   -- prepareToPlay
   -- stop
   -- begin seeking forward
   -- begin seeking backward
   -- end seeking
   -- snapshot, time [ maxWidth, maxHeight ]
   -- snapshot exactly, time, [ maxWidth, maxHeight ]
   mobileControlDo myMobileID, pCommand
end playerCommand




------------------------------------------------------------------
# PROPERTIES
------------------------------------------------------------------

# TYPE - (READ ONLY)
------
getProp tmControlType
   return myControlType()
end tmControlType

function myControlType
   return the tmControlData["type"] of me
end myControlType


# CONTROL ID - (READ ONLY)
-----------
getProp tmControlID
   return myControlID()
end tmControlID

function myControlID
   return the short id of me
end myControlID


# PLAYER ID - (READ ONLY)
----------
getProp tmMobileID
   return myMobileID
end tmMobileID


# DURATION - (READ ONLY)
----------
getProp tmDuration
   return myDuration()
end tmDuration

function myDuration
   return mobileControlGet(myMobileID,"duration")
end myDuration


# PLAYABLE DURATION - (READ ONLY)
------------------
getProp tmPlayableDuration
   return myPlayableDuration()
end tmPlayableDuration

function myPlayableDuration
   return mobileControlGet(myMobileID,"playableDuration")
end myPlayableDuration


# LOAD STATE - (READ ONLY)
------------
getProp tmLoadState
   return myLoadState()
end tmLoadState

function myLoadState
   return mobileControlGet(myMobileID,"loadState")
end myLoadState


# PLAYBACK STATE - (READ ONLY)
----------------
getProp tmPlaybackState
   return myPlaybackState()
end tmPlaybackState

function myPlaybackState
   return mobileControlGet(myMobileID,"playbackState")
end myPlaybackState


# NATURAL SIZE - (READ ONLY)
-------------
getProp tmNaturalSize
   return myNaturalSize()
end tmNaturalSize

function myNaturalSize
   return the tmControlData["naturalSize"] of me
end myNaturalSize


# FORMATTED CURRENT TIME - (READ ONLY)
-----------------------
getProp tmFormattedCurrentTime
   return myFormattedCurrentTime()
end tmFormattedCurrentTime

function myFormattedCurrentTime
   put mobileControlGet(myMobileID,"currentTime") div 1000 into theSeconds
   return formattedTime(theSeconds)
end myFormattedCurrentTime


-- NAME
--------
setProp tmName pValue
   set name me to pValue
   tmUpdatePlayer "name",pValue
end tmName

getProp tmName
   return myName()
end tmName

function myName
   return short name of me
end myName


# FILENAME
----------
setProp tmRect pValue
   set rect of me to pValue
   tmUpdatePlayer "rect",pValue
end tmRect

getProp tmRect
   return myRect()
end tmRect

function myRect
   return rect of me
end myRect


# FILENAME
----------
setProp tmFilename pValue
   set the tmControlData["filename"] of me to pValue
   tmUpdatePlayer "filename",pValue
end tmFilename

getProp tmFilename
   return myFilename()
end tmFilename

function myFilename
   return the tmControlData["filename"] of me
end myFilename


# FULL SCREEN
------------
setProp tmFullscreen pValue
   set the tmControlData["fullscreen"] of me to pValue
   tmUpdatePlayer "fullscreen",pValue
end tmFullscreen

getProp tmFullscreen pValue
   return myFullScreen()
end tmFullscreen

function myFullscreen
   return the tmControlData["fullscreen"] of me
end myFullscreen


# PRESERVE ASPECT
----------------
setProp tmPreserveAspect pValue
   set the tmControlData["preserveAspect"] of me to pValue
   tmUpdatePlayer "preserveAspect",pValue
end tmPreserveAspect

getProp tmPreserveAspect
   return myPreserveAspect()
end tmPreserveAspect
   
function myPreserveAspect
   return the tmControlData["preserveAspect"] of me
end myPreserveAspect


# SHOW CONTROLLER
-----------------
setProp tmShowController pValue
   set the tmControlData["showController"] of me to pValue
   tmUpdatePlayer "showController",pValue
end tmShowController

getProp tmShowController
   return myShowController()
end tmShowController

function myShowController
   return the tmControlData["showController"] of me
end myShowController


# USE APPLICATION AUDIO SESSION
----------------------------
setProp tmUseApplicationAudioSession pValue
   set the tmControlData["useApplicationAudioSession"] of me to pValue
   tmUpdatePlayer "useApplicationAudioSession",pValue
end tmUseApplicationAudioSession

getProp tmUseApplicationAudioSession
   return myUseApplicationAudioSession()
end tmUseApplicationAudioSession

function myUseApplicationAudioSession
   return the tmControlData["useApplicationAudioSession"] of me
end myUseApplicationAudioSession


# SHOULD AUTOPLAY
-----------------
setProp tmShouldAutoplay pValue
   set the tmControlData["shouldAutoplay"] of me to pValue
   tmUpdatePlayer "shouldAutoplay",pValue
end tmShouldAutoplay

getProp tmShouldAutoplay
   return myShouldAutoplay()
end tmShouldAutoplay

function myShouldAutoplay
   return the tmControlData["shouldAutoplay"] of me
end myShouldAutoplay


# LOOPING
---------
setProp tmLooping pValue
   set the tmControlData["looping"] of me to pValue
   tmUpdatePlayer "looping",pValue
end tmLooping

getProp tmLooping
   return myLooping()
end tmLooping

function myLooping
   return the tmControlData["looping"] of me
end myLooping


# ALLOWS AIRPLAY
---------------
setProp tmAllowsAirPlay pValue
   set the tmControlData["allowsAirPlay"] of me to pValue
   tmUpdatePlayer "allowsAirPlay",pValue
end tmAllowsAirPlay

getProp tmAllowsAirPlay
   return myAllowsAirPlay()
end tmAllowsAirPlay

function myAllowsAirPlay
   return the tmControlData["allowsAirPlay"] of me
end myAllowsAirPlay


# CURRENT TIME
-------------
setProp tmCurrentTime pValue
   set the tmControlData["currentTime"] of me to pValue
   tmUpdatePlayer "currentTime",pValue
end tmCurrentTime

getProp tmCurrentTime
   return myCurrentTime()
end tmCurrentTime

function myCurrentTime
   return mobileControlGet(myMobileID,"currentTime")
end myCurrentTime


# START TIME
-----------
setProp tmStartTime pValue
   set the tmControlData["startTime"] of me to pValue
   tmUpdatePlayer "startTime",pValue
end tmStartTime

getProp tmStartTime
   return myStartTime()
end tmStartTime

function myStartTime
   return the tmControlData["startTime"] of me
   --   return mobileControlGet(myMobileID,"startTime")
end myStartTime


# END TIME
---------
setProp tmEndTime pValue
   set the tmControlData["endTime"] of me to pValue
   tmUpdatePlayer "endTime",pValue
end tmEndTime

getProp tmEndTime
   return myEndTime()
end tmEndTime

function myEndTime
   return the tmControlData["endTime"] of me
   --  return mobileControlGet(myMobileID,"endTime")
end myEndTime


# VISIBLE
--------
setProp tmVisible pValue
   set the tmControlData["visible"] of me to pValue
   tmUpdatePlayer "visible",pValue
end tmVisible

getProp tmVisible
   return myVisible()
end tmVisible

function myVisible
   return the tmControlData["visible"] of me
end myVisible


# AUTO-CREATE PLAYER UPON OPENING
----------------------------------
setProp tmAutoCreate pValue
   set the tmControlData["autoCreate"] of me to pValue
end tmAutoCreate

getProp tmAutoCreate
   return autoCreateMe()
end tmAutoCreate

function autoCreateMe
   return the tmControlData["autoCreate"] of me
end autoCreateMe


# AUTO-REMOVE PLAYER WHEN CLOSING CONTROL
------------------------------------------
setProp tmAutoRemove pValue
   set the tmControlData["autoRemove"] of me to pValue
end tmAutoRemove

getProp tmAutoRemove
   return autoRemoveMe()
end tmAutoRemove

function autoRemoveMe
   return the tmControlData["autoRemove"] of me
end autoRemoveMe


-- FORMATTED TIME
function formattedTime pSeconds
   set the numberFormat to "00"
   put pSeconds div 3600 into theHours
   put ((pSeconds - (3600*theHours)) div 60) into theMinutes
   put (pSeconds - (3600*theHours) - (60* theMinutes)) into theSeconds
   return theHours & ":" & theMinutes & ":" & theSeconds
end formattedTime


private function myRegion
   return long ID of control 1 of me
end myRegion
