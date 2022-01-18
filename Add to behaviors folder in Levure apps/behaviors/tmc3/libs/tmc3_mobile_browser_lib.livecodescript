script "tmc3_mobile_browser_lib" with behavior "tmc3_MasterBehavior"
local myMobileID


on preOpenControl
   if autoCreateMe() then createBrowser
end preOpenControl


on closeControl
   if autoRemoveMe() then deleteBrowser
end closeControl


# CREATE MOBILE BROWSER
command createBrowser
   if onDesktop() then exit createBrowser
   -- CREATE BROWSER/STORE ID
   mobileControlCreate "browser"
   put the result into myMobileID
   set the tmControlData["mobileID"] of me to myMobileID
   -- SET BROWSER PROPS
   tmUpdateBrowser
end createBrowser


command tmUpdateBrowser pProp,pValue
   if onDesktop() then exit tmUpdateBrowser
   -- SET SINGLE PROP & EXIT
   if pProp is not empty then
      if number of items of pValue > 1 then put "(" & pValue & ")" into pValue -- BRACKET MULTI-ITEM VALUE IN PARENS
      -- do "mobileControlSet myMobileID," & "," & pProp & "," & pValue
      mobileControlSet myMobileID, pProp, pValue
      exit tmUpdateBrowser
   end if
   -- DEFAULT = CREATE BROWSER & SET ALL PROPS
   mobileControlSet myMobileID, "rect", myRect()
   mobileControlSet myMobileID, "name", myName()
   mobileControlSet myMobileID, "url", myURL()
   mobileControlSet myMobileID, "autoFit", myAutofit()
   mobileControlSet myMobileID, "canAdvance", myCanAdvance()
   mobileControlSet myMobileID, "canRetreat", myCanRetreat()
   mobileControlSet myMobileID, "delayRequests", myDelayRequests()
   mobileControlSet myMobileID, "dataDetectorTypes", myDataDetectorTypes()
   mobileControlSet myMobileID, "allowsInlinePlayback", myAllowsInlinePlayback()
   mobileControlSet myMobileID, "mediaPlaybackRequiresUserAction", myMediaPlaybackRequiresUserAction()
   mobileControlSet myMobileID, "scrollingEnabled", myScrollingEnabled()
   mobileControlSet myMobileID, "canBounce", myCanBounce()
   mobileControlSet myMobileID, "visible", myVisible()
end tmUpdateBrowser


command deleteBrowser
   if onDesktop() then exit deleteBrowser
   mobileControlDelete myMobileID
   put empty into myMobileID
end deleteBrowser


on resizeControl
   set rect of control 1 of me to rect of me
   if onMobile() then tmUpdateBrowser "rect",rect of me
end resizeControl


# MOBILE ACTIONS
----------------
command browserCommand pCommand
   -- VALID COMMANDS ARE:
   -- advance
   -- retreat
   -- reload
   -- stop
   -- load, baseURL, htmlText
   -- execute, script
   mobileControlDo myMobileID, pCommand
end browserCommand




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


# BROWSER ID - (READ ONLY)
------------
getProp tmMobileID
   return myMobileID
end tmMobileID


# CAN RETREAT - (READ ONLY)
-------------
getProp tmCanRetreat
   return myCanRetreat()
end tmCanRetreat

function myCanRetreat
   if onDesktop() then return empty
   return mobileControlGet(myMobileID,"canRetreat")
end myCanRetreat


# CAN ADVANCE - (READ ONLY)
-------------
getProp tmCanAdvance
   return myCanAdvance()
end tmCanAdvance

function myCanAdvance
   if onDesktop() then return empty
   return mobileControlGet(myMobileID,"canAdvance")
end myCanAdvance


-- NAME
--------
setProp tmName pValue
   set name me to pValue
   tmUpdateBrowser "name",pValue
end tmName

getProp tmName
   return myName()
end tmName

function myName
   return short name of me
end myName


# RECT
----------
setProp tmRect pValue
   set rect of control 1 of me to pValue
   set rect of me to rect of control 1 of me
   tmUpdateBrowser "rect",pValue
end tmRect

getProp tmRect
   return myRect()
end tmRect

function myRect
   return rect of me
end myRect


# URL
----
setProp tmURL pValue
   set the tmControlData["URL"] of me to pValue
   tmUpdateBrowser "url",pValue
end tmURL

getProp tmURL
   return myURL()
end tmURL

function myURL
   return the tmControlData["URL"] of me
end myURL


# AUTOFIT
---------
setProp tmAutoFit pValue
   set the tmControlData["autoFit"] of me to pValue
   tmUpdateBrowser "autoFit",pValue
end tmAutoFit

getProp tmAutoFit
   return myAutoFit()
end tmAutoFit

function myAutoFit
   return the tmControlData["autoFit"] of me
end myAutoFit


# DELAY REQUESTS
---------------
setProp tmDelayRequests pValue
   set the tmControlData["delayRequests"] of me to pValue
   tmUpdateBrowser "delayRequests",pValue
end tmDelayRequests

getProp tmDelayRequests
   return myDelayRequests()
end tmDelayRequests

function myDelayRequests
   return the tmControlData["delayRequests"] of me
end myDelayRequests


# DATA DETECTOR TYPES
--------------------
setProp tmDataDetectorTypes pValue
   set the tmControlData["dataDetectorTypes"] of me to pValue
   tmUpdateBrowser "dataDetectorTypes",pValue
end tmDataDetectorTypes

getProp tmDataDetectorTypes
   return myDataDetectorTypes()
end tmDataDetectorTypes

function myDataDetectorTypes
   return the tmControlData["dataDetectorTypes"] of me
end myDataDetectorTypes


# ALLOW INLINE PLAYBACK
---------------------
setProp tmAllowsInlinePlayback pValue
   set the tmControlData["allowsInlinePlayback"] of me to pValue
   tmUpdateBrowser "allowsInlinePlayback",pValue
end tmAllowsInlinePlayback

getProp tmAllowsInlinePlayback
   return myAllowsInlinePlayback()
end tmAllowsInlinePlayback

function myAllowsInlinePlayback
   return the tmControlData["allowsInlinePlayback"] of me
end myAllowsInlinePlayback


# MEDIA PLAYBACK REQUIRES USER ACTION
-----------------------------------
setProp tmMediaPlaybackRequiresUserAction pValue
   set the tmControlData["mediaPlaybackRequiresUserAction"] of me to pValue
   tmUpdateBrowser "mediaPlaybackRequiresUserAction",pValue
end tmMediaPlaybackRequiresUserAction

getProp tmMediaPlaybackRequiresUserAction
   return myMediaPlaybackRequiresUserAction()
end tmMediaPlaybackRequiresUserAction

function myMediaPlaybackRequiresUserAction
   return the tmControlData["mediaPlaybackRequiresUserAction"] of me
end myMediaPlaybackRequiresUserAction


# SCROLLING ENABLED
-------------------
setProp tmScrollingEnabled pValue
   set the tmControlData["scrollingEnabled"] of me to pValue
   tmUpdateBrowser "scrollingEnabled",pValue
end tmScrollingEnabled

getProp tmScrollingEnabled
   return myScrollingEnabled()
end tmScrollingEnabled

function myScrollingEnabled
   return the tmControlData["scrollingEnabled"] of me
end myScrollingEnabled


# CAN BOUNCE
-------------
setProp tmCanBounce pValue
   set the tmControlData["canBounce"] of me to pValue
   tmUpdateBrowser "canBounce",pValue
end tmCanBounce

getProp tmCanBounce
   return myCanBounce()
end tmCanBounce

function myCanBounce
   return the tmControlData["canBounce"] of me
end myCanBounce


# VISIBLE
--------
setProp tmVisible pValue
   set the tmControlData["visible"] of me to pValue
   tmUpdateBrowser "visible",pValue
end tmVisible

getProp tmVisible
   return myVisible()
end tmVisible

function myVisible
   return the tmControlData["visible"] of me
end myVisible


# AUTO-CREATE BROWSER UPON OPENING
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


# AUTO-REMOVE BROWSER WHEN CLOSING CONTROL
--------------------------------------------
setProp tmAutoRemove pValue
   set the tmControlData["autoRemove"] of me to pValue
end tmAutoRemove

getProp tmAutoRemove
   return autoRemoveMe()
end tmAutoRemove

function autoRemoveMe
   return the tmControlData["autoRemove"] of me
end autoRemoveMe





private function myRegion
   return long ID of control 1 of me
end myRegion
