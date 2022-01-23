script "tmc3_switch_lib" with behavior "tmc3_MasterBehavior"
local myL, myT, myR, myB, myW, myH, myX, myY, myLmargin, myTmargin, myRmargin, myBmargin
local allowToggle, extendBusy, thumbExtended, switchBusy


------------------------------------------------
#                           MOUSE/TOUCH EVENTS
------------------------------------------------


# MOUSEDOWN
-------------
before mouseDown
   put false into allowToggle
   if not the tmControlData["autoHilite"] of the target then exit mouseDown
   if extendBusy or thumbExtended or switchBusy then exit mouseDown
   extendMyThumb
   dispatch "controlDown" -- SEND TO POSSIBLE OWNER CONTROL
end mouseDown


# MOUSEUP
----------
before mouseUp pID
   if not the tmControlData["autoHilite"] of the target then exit mouseUp
   wait until not extendBusy
   toggleMyHilite
   dispatch "controlUp" -- SEND TO POSSIBLE OWNER CONTROL
end mouseUp

after mouseUp -- JUST IN CASE
   wait until not toggleBusy
   resetMyThumb
end mouseUp


# MOUSERELEASE
---------------
before mouseRelease pID
   wait until not extendBusy
   resetMyThumb
end mouseRelease


# RESIZE
-------
command resizeControl
   --
   -- DON'T ALLOW RESIZING OF THIS CONTROL - 02/21/2014
   --
   lock screen
   set rect of the target to rect of myRegion()
   --   set rect of myRegion() to rect of the target
   --   put left of myRegion() into myL
   --   put top of myRegion() into myT
   --   put right of myRegion() into myR
   --   put bottom of myRegion() into myB
   --   put width of myRegion() into myW
   --   put height of myRegion() into myH
   --   put item 1 of loc of myRegion() into myX
   --   put item 2 of loc of myRegion() into myY
   --   put margins of the target into M
   --   if number of items of M = 1 then put M,M,M,M into M
   --   put item 1 of M into myLmargin
   --   put item 2 of M into myTmargin
   --   put item 3 of M into myRmargin
   --   put item 4 of M into myBmargin
   --   --
   --   put rect of myRegion() into theRect
   --   add 5 to item 2 of theRect
   --   subtract 5 from item 4 of theRect
   --   set rect of myBase() to theRect
   --   set roundRadius of myBase() to height of myBase()
   --   add 2 to item 1 of theRect
   --   add 2 to item 2 of theRect
   --   subtract 2 from item 3 of theRect
   --   subtract 2 from item 4 of theRect
   --   if not the tmControlData["hilite"] of the target then
   --      -- NORMAL
   --      set rect of myFace() to theRect
   --      put item 1 of theRect + (item 4 of theRect - item 2 of theRect) into item 3 of theRect
   --   else
   --      -- HILITED
   --      set width of myFace() to round(width of myBase() * 0.125)
   --      set height of myFace() to round(height of myBase() * 0.125)
   --      set loc of myFace() to loc of myBase()
   --      put item 3 of theRect - (item 4 of theRect - item 2 of theRect) into item 1 of theRect
   --   end if
   --   set roundRadius of myFace() to height of myFace()
   --   set rect of myThumb() to theRect
   --   set roundRadius of myThumb() to height of myThumb()
   unlock screen
end resizeControl


# PREHILITE
---------
command extendMyThumb
   put true into extendBusy
   put rect of myThumb() into theRect
   if the tmControlData["hilite"] of the target then
      put -1 into V
      put 1 into theNum
   else
      put 1 into V
      put 3 into theNum
   end if
   repeat 6
      add V to item theNum of theRect
      set rect of myThumb() to theRect
      wait 0 millisecs
   end repeat
   wait 50 millisecs
   put true into allowToggle
   put true into thumbExtended
   put false into extendBusy
end extendMyThumb


-- RESET THUMB SHAPE
--------------------
command resetMyThumb
   put false into allowToggle
   put height of myThumb() into H
   put rect of myThumb() into theRect
   if the tmControlData["hilite"] of the target then
      put item 3 of rect of myBase() - 1 into item 3 of theRect
      put item 3 of theRect - H into item 1 of theRect
   else
      put item 1 of rect of myBase() + 1 into item 3 of theRect
      put item 1 of theRect + H into item 3 of theRect
   end if
   set rect of myThumb() to theRect
   put false into extendBusy
   put false into thumbExtended
   put false into switchBusy
   if onMobile() then mobileClearTouches
end resetMyThumb


-- MANAGE HILITE
---------------
command toggleMyHilite
   if not allowToggle then exit toggleMyHilite
   wait until not extendBusy
   put true into switchBusy
   lock messages -- USED TO AVOID CONTROL ANIMATION INTERRUPTS
   if the tmControlData["hilite"] of the target then
      -- UNHILITE
      put "left" into prop
      put 2 into theStep
      put -1 into V
      put 3 into theNum
      put 90 into blendStart
      set backColor of myBase() to myNormalColor()
   else
      -- HILITE
      put "right" into prop
      put -2 into theStep
      put 1 into V
      put 1 into theNum
      put 15 into blendStart
      set backColor of myBase() to myHiliteColor()
   end if
   repeat with N = 1 to 8
      lock screen
      if N <= 6 then
         put rect of myFace() into theFaceRect
         put rect of myThumb() into theThumbRect
         add V to item theNum of theThumbRect
         set rect of myThumb() to theThumbRect
         subtract theStep from item 1 of theFaceRect
         subtract theStep from item 2 of theFaceRect
         add theStep to item 3 of theFaceRect
         add theStep to item 4 of theFaceRect
         set rect of myFace() to theFaceRect
         set roundRadius of myFace() to (item 4 of theFaceRect - item 2 of theFaceRect)
         set blendLevel of myFace() to (blendStart + (N * 15 * V))
      end if
      set the prop of myThumb() to (the prop of myThumb() - theStep)
      unlock screen
      wait 5 millisecs
   end repeat
   set the prop of myThumb() to (the prop of myThumb() + theStep) -- BOUNCE BACK
   unlock messages
   set the tmControlData["hilite"] of the target to not the tmControlData["hilite"] of the target
   put false into thumbExtended
   put false into switchBusy
end toggleMyHilite


# UPDATE LABEL
-------------
--command updateMyLabel
--   set label of myLabel to the tmControlData["label"] of the target
--   set textAlign of myLabel to the tmControlData["textAlign"] of the target
--   set margins of myLabel to the tmControlData["margins"] of the target
--end updateMyLabel


# UPDATE BUTTON ICON
---------------------
--command updateMyIcon
--   if not the tmControlData["showIcons"] of the target then
--      try
--         hide myIcon
--      end try
--      exit updateMyIcon
--   end if
--   put the tmControlData["icons"] of the target into theArray
--   put the tmControlData["displayResolution"] of the target into theRes 
--   put theArray[1][theRes] into theIconData
--   if theIconData is empty then
--      set icon of myIcon to 0
--      set text of img "button_iconsource" of the target to empty
--      exit updateMyIcon
--   end if
--   if theIconData is a number then
--      -- REFERENCED IMAGE ID
--      put short name of myStackOwner() into theMainStack
--      if there is an img id theIconData of stack theMainStack then
--         put long id of img id theIconData of stack theMainStack into theIcon
--      else
--         repeat for each line theSubStack in (the subStacks of stack theMainStack)
--            if there is an img id theIconData of stack theSubStack then
--               put long id of img id theIconData of stack theSubStack into theIcon
--            end if
--         end repeat
--      end if
--      set width of myIcon to formattedWidth of theIcon
--      set height of myIcon to formattedHeight of theIcon
--      set icon of myIcon to theIconData
--   else
--      -- EMBEDDED IMAGE
--      set text of img "button_iconsource" of the target to theIconData
--      set width of myIcon to formattedWidth of img "button_iconsource" of the target
--      set height of myIcon to formattedHeight of img "button_iconsource" of the target
--      set icon of myIcon to id of img "button_iconsource" of the target
--   end if
--   put the tmControlData["iconMargins"] of the target into M
--   if number of items of M = 1 then put M,M,M,M into M
--   put item 1 of M into ML
--   put item 2 of M into MT
--   put item 3 of M into MR
--   put item 4 of M into MB
--   put the tmControlData["iconAlign"] of the target into theAlign
--   if "top" is in theAlign then set top of myIcon to top of myBase() + MT
--   if "mid" is in theAlign then set loc of myIcon to item 1 of loc of myIcon,item 2 of loc of myBase() + MT - MB
--   if "bottom" is in theAlign then set bottom of myIcon to bottom of myBase() - MB
--   if "left" is in theAlign then set left of myIcon to left of myBase() + ML
--   if "center" is in theAlign then set loc of myIcon to item 1 of loc of myBase() + ML - MR,item 2 of loc of myIcon
--   if "right" is in theAlign then set right of myIcon to right of myBase() - MR
--   show myIcon
--end updateMyIcon






------------------------------------------------
#                             PROPERTIES
------------------------------------------------

# TYPE (READ ONLY)
-------------------
getProp tmControlType
   return the tmControlData["type"] of the target
end tmControlType


# ID (READ ONLY)
---------------
getProp tmControlID
   return the short id of the target
end tmControlID


# CLASS (READ ONLY)
-------------------
getProp tmClass
   return the tmControlData["class"] of the target
end tmClass


# DEFAULT SIZE
------------------------
setProp tmDefaultSize pValue
   if pValue is not "true" then exit tmDefaultSize
   put the tmControlData["defaultSize"] of the target into theDimensions
   if theDimensions is empty then exit tmDefaultSize
   if item 1 of theDimensions is not empty then set width of the target to item 1 of theDimensions
   if item 2 of theDimensions is not empty then set height of the target to item 2 of theDimensions
end tmDefaultSize

getProp tmDefaultSize
   return myDefaultSize()
end tmDefaultSize

function myDefaultSize
   return the tmControlData["defaultSize"] of the target
end myDefaultSize


# COLOR ORIENTATION
--------------------
setProp tmColorOrientation pValue
   set the tmControlData["colorOrientation"] of the target to pValue
   repeat for each item tState in "normal,hover,hilite"
      put the tmControlData[tState&"color"] of the target into theArray
      get theArray["type"]
      if it is empty then next repeat
      if it is "linear" then
         put value(char 1 of pValue & it & "GradPoints(me)") into thePoints
      else put value(it & "GradPoints(me)") into thePoints
      put line 1 of thePoints into theArray["from"]
      put line 2 of thePoints into theArray["via"]
      put line 3 of thePoints into theArray["to"]
      set the tmControlData[tState&"color"] of the target to theArray
      if tState = "normal" then updateMyColors "normal"
   end repeat
end tmColorOrientation

getProp tmColorOrientation
   return myColorOrientation()
end tmColorOrientation

function myColorOrientation
   return the tmControlData["colorOrientation"] of the target
end myColorOrientation


# LOCK COLOR ORIENTATION
-------------------------
setProp tmLockColorOrientation pValue
   set the tmControlData["lockColorOrientation"] of the target to pValue
end tmLockColorOrientation

getProp tmLockColorOrientation
   return myLockColorOrientation()
end tmLockColorOrientation

function myLockColorOrientation
   return the tmControlData["lockColorOrientation"] of the target
end myLockColorOrientation


# HILITE COLOR
---------------
setProp tmHiliteColor pValue
   set the tmControlData["hiliteColor"] of the target to pValue
   if the tmControlData["hilite"] of the target then set backColor of myBase() to pValue
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return the tmControlData["hiliteColor"] of the target
end myHiliteColor


# NORMAL COLOR
---------------
setProp tmNormalColor pValue
   set the tmControlData["normalColor"] of the target to pValue
   if not the tmControlData["hilite"] of the target then set backColor of myBase() to pValue
end tmNormalColor

getProp tmNormalColor
   return myNormalColor()
end tmNormalColor

function myNormalColor
   return the tmControlData["normalColor"] of the target
end myNormalColor


# HILITE STROKE COLOR
---------------------
setProp tmHiliteStrokeColor pValue
   set the tmControlData["hiliteStrokeColor"] of the target to pValue
   if the tmControlData["hilite"] of the target then set foreColor of myBase() to pValue
end tmHiliteStrokeColor

getProp tmHiliteStrokeColor
   return myHiliteStrokeColor()
end tmHiliteStrokeColor

function myHiliteStrokeColor
   return the tmControlData["hiliteStrokeColor"] of the target
end myHiliteStrokeColor


# NORMAL STROKE COLOR
---------------------
setProp tmNormalStrokeColor pValue
   set the tmControlData["normalStrokeColor"] of the target to pValue
   if not the tmControlData["hilite"] of the target then set foreColor of myBase() to pValue
end tmNormalStrokeColor

getProp tmNormalStrokeColor
   return myNormalStrokeColor()
end tmNormalStrokeColor

function myNormalStrokeColor
   return the tmControlData["normalStrokeColor"] of the target
end myNormalStrokeColor


# BKGND BORDER WIDTH
---------------------
setProp tmBkgndBorderWidth pValue
   if the tmControlData["type"] of the target is not "accordion" then exit tmBkgndBorderWidth
   set the tmControlData["bkgndBorderWidth"] of the target to pValue
   updateMyPanes "color"
end tmBkgndBorderWidth

getProp tmBkgndBorderWidth
   return myBkgndBorderWidth()
end tmBkgndBorderWidth

function myBkgndBorderWidth
   return the tmControlData["bkgndBorderColor"] of the target
end myBkgndBorderWidth


# BORDER WIDTH
---------------------
setProp tmBorderWidth pValue
   set the tmControlData["borderWidth"] of the target to pValue
   if the tmControlData["type"] of the target is among the items of "smartburst,panel" then
      set lineSize of myBase() to pValue
   end if
end tmBorderWidth

getProp tmBorderWidth
   return myBorderWidth()
end tmBorderWidth

function myBorderWidth
   get the tmControlData["borderWidth"] of the target
   if it is empty then get "0"
   return it
end myBorderWidth


# BORDER COLOR
---------------------
setProp tmBorderColor pValue
   set the tmControlData["borderColor"] of the target to pValue
   if the tmControlData["type"] of the target is "table" then
      updateMyRows "color"
      exit tmBorderColor
   end if
   if the tmControlData["type"] of the target is in "button,panel,smartburst" then set strokeGradient of myBase() to pValue
end tmBorderColor

getProp tmBorderColor
   return myBorderColor()
end tmBorderColor

function myBorderColor
   return the tmControlData["borderColor"] of the target
end myBorderColor


# STROKE WIDTH
--------------
setProp tmStrokeWidth pValue
   set the tmControlData["strokeWidth"] of the target to pValue
   set lineSize of myBase() to pValue
end tmStrokeWidth

getProp tmStrokeWidth
   return myStrokeWidth()
end tmStrokeWidth

function myStrokeWidth
   get the tmControlData["strokeWidth"] of the target
   if it is empty then get "0"
   return it
end myStrokeWidth


# STROKE COLOR
---------------------
setProp tmStrokeColor pValue
   set the tmControlData["strokeColor"] of the target to pValue
   set foreColor of myBase() to pValue
end tmStrokeColor

getProp tmStrokeColor
   return myStrokeColor()
end tmStrokeColor

function myStrokeColor
   return the tmControlData["strokeColor"] of the target
end myStrokeColor


# HILITE
--------
setProp tmHilite pValue
   if pValue <> myHilite() then
      extendMyThumb
      toggleMyHilite
      set the tmControlData["hilite"] of the target to pValue
   end if
end tmHilite

getProp tmHilite
   return myHilite()
end tmHilite

function myHilite
   return the tmControlData["hilite"] of the target
end myHilite


# AUTOHILITE
-------------
setProp tmAutoHilite pValue
   set the tmControlData["autoHilite"] of the target to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   return the tmControlData["autoHilite"] of the target
end myAutoHilite


# LABEL
-------
setProp tmLabel pValue
   set the tmControlData["label"] of the target to pValue
   updateMyLabel
end tmLabel

getProp tmLabel
   return myLabel()
end tmLabel

function myLabel
   return the tmControlData["label"] of the target
end myLabel


# MARGINS
----------
setProp tmMargins pValue
   set the tmControlData["margins"] of the target to pValue
   updateMyLabel
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   return the tmControlData["margins"] of the target
end myMargins


# ICONS
------
setProp tmIcons pValue
   set the tmControlData["icons"] of the target to pValue
   if theType is "button" then updateMyIcon
end tmIcons

getProp tmIcons
   put the tmControlData["icons"] of the target into theArray
   if the keys of theArray is empty then return empty
   return theArray
end tmIcons


# ICON ALIGNMENT
-----------------
setProp tmIconAlign pValue
   set the tmControlData["iconAlign"] of the target to pValue
   updateMyIcon
end tmIconAlign

getProp tmIconAlign
   return myIconAlign()
end tmIconAlign

function myIconAlign
   return the tmControlData["iconAlign"] of the target
end myIconAlign


# ICON MARGINS
---------------
setProp tmIconMargins pValue
   set the tmControlData["iconMargins"] of the target to pValue
   updateMyIcon
end tmIconMargins

getProp tmIconMargins
   return myIconMargins()
end tmIconMargins

function myIconMargins
   return the tmControlData["iconMargins"] of the target
end myIconMargins


# SHOW ICONS
------------
setProp tmShowIcons pValue
   set the tmControlData["showIcons"] of the target to pValue
  updateMyIcon
end tmShowIcons

getProp tmShowIcons
   return myShowIcons()
end tmShowIcons

function myShowIcons
   return the tmControlData["showIcons"] of the target
end myShowIcons


# ORIENTATION
--------------
setProp tmOrientation pValue
   set the tmControlData["orientation"] of the target to pValue
   dispatch "resizeControl" to the target
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   return the tmControlData["orientation"] of the target
end myOrientation



# BKGND MARGINS
----------------
setProp tmBkgndMargins pValue
   set the tmControlData["bkgndMargins"] of the target to pValue
   dispatch "resizeControl" to the target
end tmBkgndMargins

getProp tmBkgndMargins
   return myBkgndMargins()
end tmBkgndMargins

function myBkgndMargins
   return the tmControlData["bkgndMargins"] of the target
end myBkgndMargins


# ROUND RADIUS
----------------
setProp tmRoundRadius pValue
   set the tmControlData["roundRadius"] of the target to pValue
   set roundRadius of myBase() to pValue
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return the tmControlData["roundRadius"] of the target
end myRoundRadius


# BASE OPACITY
-------------
setProp tmBaseOpacity pValue
   set the blendLevel of myBase() to (100 - pValue)
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return (100 - blendLevel of myBase())
end myBaseOpacity


# DISABLED
----------
setProp tmDisabled pValue
   set the tmControlData["disabled"] of the target to pValue
   set disabled of the target to pValue
   set blendLevel of the target to item wordOffset(pValue,"true false") of "50,0"
end tmDisabled

getProp tmDisabled
   return myDisabled()
end tmDisabled

function myDisabled
   return the tmControlData["disabled"] of the target
end myDisabled


# ENABLED
----------
setProp tmEnabled pValue
   set the tmControlData["disabled"] of the target to not pValue
   set the enabled of the target to pValue
   updateControlStates
end tmEnabled

getProp tmEnabled
   return myEnabled()
end tmEnabled

function myEnabled
   return not the tmControlData["disabled"] of the target
end myEnabled








private function myRegion
   return long id of control 1 of the target
end myRegion


private function myBase
   return long id of grc "switch_base" of the target
end myBase


private function myFace
   return long id of grc "switch_face" of the target
end myFace


private function myThumb
   if exists(grp "switch_thumb" of the target) then return long id of grp "switch_thumb" of the target
   return long id of grc "switch_thumb" of the target
end myThumb


private function myActiveIcon
   put long id of img "switch_activeicon" of the target
end myActiveIcon


private function myInactiveIcon
   return long id of img "switch_inactiveicon" of the target
end myInactiveIcon

