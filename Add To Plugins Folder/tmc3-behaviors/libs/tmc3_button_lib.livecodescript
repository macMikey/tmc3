script "tmc3_button_lib" with behavior "tmc3_MasterBehavior"
local myL, myT, myR, myB, myW, myH, myX, myY, myLmargin, myTmargin, myRmargin, myBmargin
local allowTracking


on preOpenControl
   if myIconType() is "glyph" then exit preOpenControl
   if the tmControlData["type"] of owner of me is "navbar" then exit preOpenControl -- ICON UPDATE OCCURS IN NAV BAR BEHAVIOR
   if myIconType() is "icon" then set icon of btn 1 of me to the tmControlData["icon"] of me
   --   else
   --      -- OLD ICON METHOD
   --      put long id of img 1 of me into theSourceImage
   --      put pixelDensity() & "Icon" into iconProp
   --      put the tmControlData[iconProp] of theSourceImage into theText
   --      set text of theSourceImage to theText
   --      set icon of btn 1 of me to id of theSourceImage
   --   end if
end preOpenControl


on newGroup
   preOpenControl
end newGroup


------------------------------------------------
#                           MOUSE/TOUCH EVENTS
------------------------------------------------


# MOUSEENTER
before mouseEnter
   if myAutoHilite() then hoverMe
end mouseEnter


# MOUSELEAVE
before mouseLeave
   if myAutoHilite() then unhoverMe
end mouseLeave


# MOUSEDOWN
-------------
before mouseDown
   put mouseLoc() into theLoc
   put true into allowTracking
   -- NAV BUTTON
   if myClass() is among the items of "iosNav,nav,inNavBar" then \
         dispatch "buttonDown" to myTMControlGroupOwner() with char 5 to -1 of short name of me
   if myAutoHilite() then hiliteMe
   dispatch "controlDown" -- SEND TO POSSIBLE OWNER CONTROL
end mouseDown


# MOUSESTILLDOWN
-----------------
--before mouseStillDown
--   dispatch "mouseStillDown" to me
--end mouseStillDown


# MOUSEDOUBLEDOWN
--------------------
--on tmMouseDoubleDownEvent
--   hiliteMe
--end tmMouseDoubleDownEvent


# MOUSEMOVE
-------------
before mouseMove X,Y,pID
   if not allowTracking then exit mouseMove
   if not the tmControlData["autoHilite"] of me then exit mouseMove
   if within(me,mouseLoc()) then hiliteMe
   if not within(me,mouseLoc()) and the tmControlData["hilite"] of me then unhiliteMe
end mouseMove


# MOUSEUP
----------
before mouseUp pID
   put false into allowTracking
   if myClass() is among the items of "iosNav,nav,inNavBar" then \
         dispatch "buttonUp" to myTMControlGroupOwner() with char 5 to -1 of short name of me
   if myAutoHilite() then send "unhiliteMe" to me in 0 millisecs
   dispatch "controlUp" -- SEND TO POSSIBLE OWNER CONTROL
end mouseUp


# MOUSEDOUBLEUP
----------------
--on tmMouseDoubleUpEvent
--   put false into allowTracking
--   unhiliteMe
--end tmMouseDoubleUpEvent


# MOUSERELEASE
---------------
before mouseRelease pID
   put false into allowTracking
   if myClass() is among the items of "iosNav,nav,inNavBar" then \
         dispatch "buttonRelease" to myTMControlGroupOwner() with char 5 to -1 of short name of me
   if the tmControlData["autoHilite"] of me then
      if the tmControlData["hilite"] of me then unhiliteMe
   end if
   dispatch "controlRelease" -- SEND TO POSSIBLE OWNER CONTROL
end mouseRelease


# HOVER
-------
command hoverMe
   if the tool is not "browse tool" then exit hoverMe
   if myClass() is "iosNav" then exit hoverMe
   if myShowIcon() then
      if myHoverIconValue() is not empty and myHoverIconValue() is not 0 then
         if myIconType() is "glyph" then
            set label of myIcon() to numToCodepoint(myHoverIconValue())
            if myHoverIconColor() is not empty then set textColor of myIcon() to myHoverIconColor()
         end if
         if myIconType() is "icon" then set icon of myIcon() to myHoverIcon()
      end if
   end if
end hoverMe


# UNHOVER
----------
command unhoverMe
   if the tool is not "browse tool" then exit unhoverMe
   if myClass() is "iosNav" then exit unhoverMe
   if myIconType() is "glyph" and myShowIcon() then
      set label of myIcon() to numToCodepoint(myIconValue())
      set textColor of myIcon() to myIconColor()
   end if
   if myIconType() is in "icon,embedded" and myShowIcon() then
      get myIconValue()
      if it is empty then get id of img 1 of me
      set icon of myIcon() to it
   end if
end unhoverMe


# HILITE
-------
command hiliteMe pManualPropUpdate
   switch myClass()
      case "iosBezel"
         if myHiliteColor() is not empty then
            set colorOverlay["color"] of myBase() to myHiliteColor()
            set colorOverlay["opacity"] of myBase() to 255
         end if
         if myTextHiliteColor() is not empty then set textColor of myLabel() to myTextHiliteColor()
         break
      case "iosNav"
      case "inNavBar"
         set colorOverlay["color"] of me to myHiliteColor()
         set colorOverlay["opacity"] of me to 255
         break
      default -- iosSystem
         set colorOverlay["opacity"] of myLabel() to myTextHiliteOpacity()
   end switch
   if myShowIcon() and myClass() is not "iosNav" then
      put myHiliteIconValue() into theID
      if myIconType() is "glyph" and theID is not empty and theID is not 0 then set label of myIcon() to numToCodepoint(theID)
      if myIconType() is "icon" and theID is not empty and theID is not 0 then set icon of myIcon() to theID
   end if
   if myHiliteIconColor() is not empty then set textColor of myIcon() to myHiliteIconColor()
   put true into isHilited
   set the tmControlData["hilite"] of me to true
end hiliteMe


# UNHILITE
----------
command unhiliteMe pManualPropUpdate
   if not the tmControlData["hilite"] of me then exit unhiliteMe
   if myShowIcon() and myClass() is not "iosNav" then
      if within(me,mouseLoc()) and myHoverIconValue() is not empty and myHoverIconValue() is not 0 then
         put myHoverIconValue() into theID
         put myHoverIconColor() into theColor
      else
         put myIconValue() into theID
         if theID is empty then put id of img 1 of me into theID
         put myIconColor() into theColor
      end if
      if myIconType() is "glyph" then
         set label of myIcon() to numToCodepoint(theID)
         set textColor of myIcon() to theColor
      end if
      if myIconType() is "icon" then set icon of myIcon() to theID
   end if
   switch myClass()
      case "iosBezel"
         put myTextColor() into TC
         put myTextHiliteColor() into THC
         if THC is not empty then
            put (item 1 of THC - item 1 of TC)/10 into rStep
            put (item 2 of THC - item 2 of TC)/10 into gStep
            put (item 3 of THC - item 3 of TC)/10 into bStep
         end if
         repeat with N = 9 down to 0
            set colorOverlay["opacity"] of myBase() to round(N * 255/10)
            if THC is not empty then
               set textColor of myLabel() to \
                     item 1 of TC + round(N * rStep),item 2 of TC + round(N * gStep),item 3 of TC + round(N * bStep)
            end if
            wait 5 millisecs
         end repeat
         break
      case "iosNav"
      case "inNavBar"
         repeat with N = 9 down to 0
            set colorOverlay["opacity"] of me to round(N * 255/10)
            wait 5 millisecs
         end repeat
         break
      default -- iosSystem
         repeat with N = 9 down to 0
            set colorOverlay["opacity"] of myLabel() to round(N * myTextHiliteOpacity()/10)
            wait 5 millisecs
         end repeat
   end switch
   put false into isHilited
   set the tmControlData["hilite"] of me to false
end unhiliteMe


-- IMMEDIATE UNHILITE (USE EXAMPLE: SCROLLING REGION)
command deHiliteMe
   put false into allowTracking
   set colorOverlay["opacity"] of myBase() to 0
   set textColor of myLabel() to myTextColor()
   set the tmControlData["hilite"] of me to false
end deHiliteMe


# UPDATE LABEL
-------------
command updateMyLabel
   set label of myLabel() to the tmControlData["label"] of me
   set textAlign of myLabel() to the tmControlData["textAlign"] of me
   set margins of myLabel() to the tmControlData["margins"] of me
   if myClass() contains "nav" then
      -- AUTO-RESIZE NAV BUTTONS
      put "left" into prop -- DEFAULT
      if short name of me contains "right" then put "right" into prop
      put the prop of myLabel() into thePosition
      set width of myLabel() to formattedWidth of myLabel()
      set the prop of myLabel() to thePosition
      set rect of me to rect of myLabel()
      resizeControl
   end if
end updateMyLabel


# UPDATE ICON
-------------
command updateMyIcon pState
   if pState is not empty and pState is not "default" then exit updateMyIcon
   lock screen
   replace "default" with empty in pState
   put value("my" & pState & "IconValue()") into theID
   switch myIconType()
      case "glyph"
         set icon of myIcon() to 0
         set label of myIcon() to numToCodepoint(theID)
         set textFont of myIcon() to myGlyphFont()
         set textColor of myIcon() to myIconColor()
         if textSize of myIcon() is empty or textSize of myIcon() < 10 then set textSize of myIcon() to 10
         set showName of myIcon() to true
         break
      case "icon"
         set icon of myIcon() to theID
         set showName of myIcon() to false
         break
      case "embedded"
         -- set icon of myIcon() to id of myIconSource()
         set showName of myIcon() to false
         set label of myIcon() to space -- KEEP SINGLE CHARACTER IN LABEL 
   end switch
   positionMyLabel
   unlock screen
end updateMyIcon


# UPDATE ICON COLOR
-------------------
command updateMyIconColor
   if myIconColor() is empty then exit updateMyIconColor
   -- GLYPH
   if myIconType() is "glyph" then
      set textColor of myIcon() to myIconColor()
      exit updateMyIconColor
   end if
   -- ICON
   lock screen
   repeat for each item theState in ",Hilite" -- NORMAL STATE IS EMPTY
      repeat for each item theRes in "ultralow,extralow,low,medium,high,extrahigh,ultrahigh"
         -- CUSTOM ICON
         put theRes & theState & "Icon" into prop
         put the tmControlData[prop] of myIconSource() into theIconData
         if theIconData is not empty then
            reset the templateImage
            set text of the templateImage to theIconData
            set imageData of the templateImage to solidColorImageData("the TemplateImage",myIconColor())
            set the tmControlData[prop] of myIconSource() to text of the templateImage
         end if
         -- NAV ICON
         put theRes & "Nav" & theState & "Icon" into prop
         put the tmControlData[prop] of myIconSource() into theIconData
         if theIconData is not empty then
            reset the templateImage
            set text of the templateImage to theIconData
            set imageData of the templateImage to solidColorImageData("the TemplateImage",myIconColor())
            set the tmControlData[prop] of myIconSource() to text of the templateImage
         end if
      end repeat
   end repeat
   put (pixelDensity() & "Icon") into theIconProp
   if myClass() contains "nav" then put (pixelDensity() & "NavIcon") into theIconProp
   set text of myIconSource() to the tmControlData[theIconProp] of myIconSource()
   reset the templateImage
   unlock screen
end updateMyIconColor


# POSITION LABEL
---------------
command positionMyLabel
   lock screen
   if not the lockUpdates of me then set the lockUpdates of me to true
   get the tmControlData["maxIconHeight"] of owner of me -- CURRENTLY ONLY PROVIDED BY NAV BAR CONTROL
   if it is not empty then put it into theHeightLimit
   if myIconType() is "glyph" then
      -- GLYPH
      put measureText(label of myIcon(),myIcon(),"size") into theSize
      add 2 to item 1 of theSize -- ADD EXTRA SPACE HERE TO MINIMIZE CLIPPING OF ICON CHARACTER
      set width of myIcon() to min(width of me,item 1 of theSize)
      set height of myIcon() to min(height of me,item 2 of theSize)
   end if
   if myIconType() is "icon" then
      -- ICON
      if exists(img id (icon of myIcon())) then 
         set width of myIcon() to formattedWidth of img id (icon of myIcon())
         set height of myIcon() to formattedHeight of img id (icon of myIcon())
      else
         set width of myIcon() to formattedWidth of img 1 of me
         set height of myIcon() to formattedHeight of img 1 of me
      end if
   end if
   if myIconType() is "embedded" or myIconType() is empty then
      -- OLD ICON METHOD
      set width of myIcon() to (formattedWidth of myIconSource() div screenPixelScale)
      set height of myIcon() to min((formattedHeight of myIconSource() div screenPixelScale),height of me)
   end if
   --
   put width of myIcon() into iconW
   put height of myIcon() into iconH
   --
   put myMargins() into M
   if number of items of M = 1 then put M,M,M,M into M
   put M into theLabelMargins
   set margins of myLabel() to 0 -- RESET HERE, WILL BE UPDATED BELOW
   put formattedWidth of myLabel() into labelW
   put formattedHeight of myLabel() into labelH
   if not myShowIcon() then
      put 0 into iconW
      put 0 into iconH
   end if
   if not myShowName() then
      put 0 into labelW
      put 0 into labelH
   end if
   put loc of me into theIconLoc
   set loc of myIcon() to theIconLoc -- RESET HERE, WILL BE UPDATED BELOW
   switch myTextAlign()
      case "left"
         switch
            case myIconAlign() contains "left"
               add iconW to item 1 of theLabelMargins
               put left of me + round(iconW/2) into item 1 of theIconLoc
               break
            case myIconAlign() contains "right"
               put left of me + labelW + round(iconW/2) into item 1 of theIconLoc
               break
         end switch
         break
         --
      case "center"
         put (labelH + iconH) div 2 into vOffset
         put (labelW + iconW) div 2 into hOffset
         if not myShowIcon() then
            put 0 into vOffset
            put 0 into hOffset
         end if
         switch
            case myIconAlign() is among the items of "topleft,topcenter,topright"
               add vOffset to item 2 of theLabelMargins
               subtract (vOffset - round(iconH/2)) from item 2 of theIconLoc
               break
            case myIconAlign() is among the items of "bottomleft,bottomcenter,bottomright"
               add vOffset to item 4 of theLabelMargins
               add (vOffset - round(iconH/2)) to item 2 of theIconLoc
               break
            case myIconAlign() is "midleft"
               add hOffset to item 1 of theLabelMargins
               subtract (hOffset - round(iconW/2)) from item 1 of theIconLoc
               break
            case myIconAlign() is "midright"
               add hOffset to item 3 of theLabelMargins
               add (hOffset - round(iconW/2)) to item 1 of theIconLoc
               break
            case myIconAlign() is "midcenter"
               set loc of myIcon() to loc of me
               break
         end switch
         break
         --
      case "right"
         switch
            case myIconAlign() contains "left"
               put right of me - labelW - round(iconW/2) into item 1 of theIconLoc
               break
            case myIconAlign() contains "right"
               add iconW to item 3 of theLabelMargins
               put right of me - round(iconW/2) into item 1 of theIconLoc
               break
         end switch
         break
   end switch
   set margins of myLabel() to theLabelMargins
   get item 1 of myIconShift()
   if it is not empty then add it to item 1 of theIconLoc
   get item 2 of myIconShift()
   if it is not empty then add it to item 2 of theIconLoc
   --
   -- NAV REQUIRES 10 PIX MARGIN
   if myClass() contains "nav" then
      if short name of me contains "left" then add 10 to item 1 of theIconLoc
      if short name of me contains "right" then subtract 10 from item 1 of theIconLoc
   end if
   --
   set loc of myIcon() to theIconLoc
   -- TRIM ICON RECT IF NEEDED
   put rect of myIcon() into theRect
   put max(left of me,left of myIcon()) into item 1 of theRect
   put max(top of me,top of myIcon()) into item 2 of theRect
   put min(right of me,right of myIcon()) into item 3 of theRect
   put min(bottom of me,bottom of myIcon()) into item 4 of theRect
   set rect of myIcon() to theRect
   set the lockUpdates of me to false
   unlock screen
end positionMyLabel


# IMPORT ICON DATA
------------------
--command importIconData pSourceData, pDestinationObj, pGlyphFont, pGlyphHiliteCode, pGlyphColor
--   switch myIconType()
--      case "glyph"
--         set the tmControlData["iconType"] of me to "glyph"
--         set the tmControlData["icon"] of me to pSourceData
--         set the tmControlData["hiliteIcon"] of me to pGlyphHiliteCode
--         set the tmControlData["glyphFont"] of me to pGlyphFont
--         get the textColor of myIcon()
--         if it is not empty then
--            set the tmControlData["iconColor"] of me to it
--         else set the tmControlData["iconColor"] of me to pGlyphColor
--         break
--      case "icon"

--         break
--      case "embedded"
--         set the tmControlData["iconType"] of me to "image"
--         put pSourceData into theSourceObj
--         put the customKeys["tmControlData"] of theSourceObj into theIconProps
--         -- COPY ICON RESOURCES
--         repeat for each line prop in theIconProps
--            set the tmControlData[prop] of myIconSource() to the tmControlData[prop] of theSourceObj
--         end repeat
--         set text of myIconSource() to the tmControlData[pixelDensity() & "icon"] of myIconSource()
--         set width of myIconSource() to formattedWidth of myIconSource()
--         set height of myIconSource() to formattedHeight of myIconSource()
--         set width of myIcon() to formattedWidth of myIconSource()
--         set height of myIcon() to formattedHeight of myIconSource()
--         if short name of me contains "nav_" and the tmControlData["type"] of owner of me is "navbar" then
--            put "tm" & char 5 to -1 of short name of me & "ButtonStyle" into prop
--            set the prop of me to "icon"
--         end if
--         break
--   end switch
--   updateMyIcon
--   if myLockImageIconColor() then updateMyIconColor
--   set the tmShowIcon of me to true
--   -- POSITION
--   positionMyLabel
--   -- POSITION/UPDATE NAV BUTTON WITHIN NAV BAR
--   if the tmControlData["type"] of owner of me is "navbar" and short name of me contains "nav_" then
--      put char 5 to -1 of short name of me into theSide
--      put (theSide & "NavStyle") into prop
--      set the tmControlData[prop] of owner of me to false
--      dispatch "updateMyButton" to owner of me with theSide -- LEFT OR RIGHT
--   end if
--end importIconData


# RESIZE
-------
command resizeControl
   lock screen
   lock messages
   set lockUpdates of me to true
   set rect of myRegion() to rect of me
   put left of myRegion() into myL
   put top of myRegion() into myT
   put right of myRegion() into myR
   put bottom of myRegion() into myB
   put width of myRegion() into myW
   put height of myRegion() into myH
   put item 1 of loc of myRegion() into myX
   put item 2 of loc of myRegion() into myY
   put margins of me into M
   if number of items of M = 1 then put M,M,M,M into M
   put item 1 of M into myLmargin
   put item 2 of M into myTmargin
   put item 3 of M into myRmargin
   put item 4 of M into myBmargin
   --
   set rect of myBase() to rect of myRegion()
   if myFace() is not empty then
      put rect of myRegion() into theRect
      put lineSize of myBase() into LS
      add LS to item 1 of theRect
      add LS to item 2 of theRect
      subtract LS from item 3 of theRect
      subtract LS from item 4 of theRect
      set rect of myFace() to rect of myRegion()
   end if
   set rect of myLabel() to rect of myRegion()
   positionMyLabel
   set lockUpdates of me to false
   unlock messages
   unlock screen
end resizeControl



------------------------------------------------
#                             PROPERTIES
------------------------------------------------

# TYPE (READ ONLY)
-------------------
getProp tmControlType
   return myControlType()
end tmControlType

function myControlType
   return the tmControlData["type"] of me
end myControlType
   

# ID (READ ONLY)
---------------
getProp tmControlID
   return the short id of me
end tmControlID


# CLASS (READ ONLY)
-------------------
getProp tmClass
   return myClass()
end tmClass

function myClass
   return the tmControlData["class"] of me
end myClass


# NAV STYLE (READ ONLY) - ONLY FOR BUTTONS WITHIN NAV BAR
----------------------
getProp tmNavStyle
   return myNavStyle()
end tmNavStyle

function myNavStyle
   return the tmControlData["navStyle"] of me
end myNavStyle


# DEFAULT SIZE
------------------------
setProp tmDefaultSize pValue
   if pValue is not "true" then exit tmDefaultSize
   put the tmControlData["defaultSize"] of me into theDimensions
   if theDimensions is empty then exit tmDefaultSize
   if item 1 of theDimensions is not empty then set width of me to item 1 of theDimensions
   if item 2 of theDimensions is not empty then set height of me to item 2 of theDimensions
end tmDefaultSize

getProp tmDefaultSize
   return myDefaultSize()
end tmDefaultSize

function myDefaultSize
   return the tmControlData["defaultSize"] of me
end myDefaultSize


# COLOR ORIENTATION
--------------------
setProp tmColorOrientation pValue
   set the tmControlData["colorOrientation"] of me to pValue
   repeat for each item tState in "normal,hover,hilite"
      put the tmControlData[tState&"color"] of me into theArray
      get theArray["type"]
      if it is empty then next repeat
      if it is "linear" then
         put value(char 1 of pValue & it & "GradPoints(me)") into thePoints
      else put value(it & "GradPoints(me)") into thePoints
      put line 1 of thePoints into theArray["from"]
      put line 2 of thePoints into theArray["via"]
      put line 3 of thePoints into theArray["to"]
      set the tmControlData[tState&"color"] of me to theArray
      if tState = "normal" then updateMyColors "normal"
   end repeat
end tmColorOrientation

getProp tmColorOrientation
   return the tmControlData["colorOrientation"] of me
end tmColorOrientation


# LOCK COLOR ORIENTATION
-------------------------
setProp tmLockColorOrientation pValue
   set the tmControlData["lockColorOrientation"] of me to pValue
end tmLockColorOrientation

getProp tmLockColorOrientation
   return myLockColorOrientation()
end tmLockColorOrientation

function myLockColorOrientation
   return the tmControlData["lockColorOrientation"] of me
end myLockColorOrientation


# LOCK ICON COLOR
-----------------
setProp tmLockImageIconColor pValue
   set the tmControlData["lockImageIconColor"] of me to pValue
   updateMyIconColor
end tmLockImageIconColor

getProp tmLockImageIconColor
   return myLockImageIconColor()
end tmLockImageIconColor

function myLockImageIconColor
   return the tmControlData["lockImageIconColor"] of me
end myLockImageIconColor


# STROKE WIDTH
--------------
setProp tmStrokeWidth pValue
   set the tmControlData["strokeWidth"] of me to pValue
   if myFace() is not empty then
      set lineSize of myFace() to pValue
   else set lineSize of myBase() to pValue
end tmStrokeWidth

getProp tmStrokeWidth
   return myStrokeWidth()
end tmStrokeWidth

function myStrokeWidth
   get the tmControlData["strokeWidth"] of me
   if it is empty then get "0"
   return it
end myStrokeWidth


# STROKE COLOR
---------------------
setProp tmStrokeColor pValue
   set the tmControlData["strokeColor"] of me to pValue
   if myFace() is not empty then
      set foreColor of myFace() to pValue
   else set foreColor of myBase() to pValue
end tmStrokeColor

getProp tmStrokeColor
   return myStrokeColor()
end tmStrokeColor

function myStrokeColor
   return the tmControlData["strokeColor"] of me
end myStrokeColor


# BASE COLOR
---------------------
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of me
end myBaseColor


# HILITE COLOR
-------------
setProp tmHiliteColor pValue
   set the tmControlData["hiliteColor"] of me to pValue
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return the tmControlData["hiliteColor"] of me
end myHiliteColor


# HILITE
--------
setProp tmHilite pValue
   set the tmControlData["hilite"] of me to pValue
   if pValue then
      hiliteMe
   else unhiliteMe
end tmHilite

getProp tmHilite
   return myHilite()
end tmHilite

function myHilite
   return the tmControlData["hilite"] of me
end myHilite


# AUTOHILITE
-------------
setProp tmAutoHilite pValue
   set the tmControlData["autoHilite"] of me to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   return the tmControlData["autoHilite"] of me
end myAutoHilite


# LABEL
-------
setProp tmLabel pValue
   set the tmControlData["label"] of me to pValue
   updateMyLabel
end tmLabel

getProp tmLabel
   return myLabelText()
end tmLabel

function myLabelText
   return the tmControlData["label"] of me
end myLabelText


# TEXT
-------
setProp tmText pValue
   set the tmControlData["text"] of me to pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return the tmControlData["text"] of me
end myText


# TEXT SIZE
-----------
setProp tmTextSize pValue
   set the tmControlData["textSize"] of me to pValue
   set textSize of myLabel() to pValue
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return textSize of myLabel()
end myTextSize


# TEXT HEIGHT
-------------
setProp tmTextHeight pValue
   set the tmControlData["textHeight"] of me to pValue
   set textHeight of myLabel() to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return effective textHeight of myLabel()
end myTextHeight


# TEXT COLOR
-------------
setProp tmTextColor pValue
   set the tmControlData["textColor"] of me to pValue
   set textColor of myLabel() to pValue
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of me
end myTextColor


# TEXT HILITE COLOR
-------------------
setProp tmTextHiliteColor pValue
   -- set colorOverlay["color"] of myLabel() to pValue
   set the tmControlData["textHiliteColor"] of me to pValue
end tmTextHiliteColor

getProp tmTextHiliteColor 
   return myTextHiliteColor()
end tmTextHiliteColor

function myTextHiliteColor 
   return the tmControlData["textHiliteColor"] of me
end myTextHiliteColor


# TEXT HILITE OPACITY
-------------------
setProp tmTextHiliteOpacity pValue
   set the tmControlData["textHiliteOpacity"] of me to pValue
end tmTextHiliteOpacity

getProp tmTextHiliteOpacity 
   return myTextHiliteOpacity()
end tmTextHiliteOpacity

function myTextHiliteOpacity 
   return the tmControlData["textHiliteOpacity"] of me
end myTextHiliteOpacity


# TEXT FONT
-----------
setProp tmTextFont pValue
   set textFont of myLabel() to pValue
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return effective textFont of myLabel()
end myTextFont


# TEXT STYLE
-------------
setProp tmTextStyle pValue
   set textStyle of myLabel() to pValue
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return effective textStyle of myLabel()
end myTextStyle


# TEXT DROPSHADOW
-------------------
setProp tmTextShadow pValue
   set dropshadow of myLabel() to pValue
end tmTextShadow

getProp tmTextShadow
  return myTextShadow()
end tmTextShadow

function myTextShadow
   return the dropshadow of myLabel()
end myTextShadow


# TEXT OUTERGLOW
-------------------
setProp tmTextGlow pValue
   set outerGlow of myLabel() to pValue
end tmTextGlow

getProp tmTextGlow
   return myTextGlow()
end tmTextGlow

function myTextGlow
   return the outerGlow of myLabel()
end myTextGlow


# TEXT ALIGNMENT
------------------
setProp tmTextAlign pValue
   set the tmControlData["textAlign"] of me to pValue
   set textAlign of myLabel() to pValue
   positionMyLabel
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   get the tmControlData["textAlign"] of me
   if it is empty then get effective textAlign of myLabel()
   return it
end myTextAlign


# MARGINS
----------
setProp tmMargins pValue
   put pValue into M
   if number of items of M = 1 then put M,M,M,M into M
   set the tmControlData["margins"] of me to M
   set margins of myLabel() to M
   positionMyLabel
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   return the tmControlData["margins"] of me
end myMargins


/*
<image>@ultra-low.<ex> - 0.25x
<image>@extra-low.<ext> - 0.5x
<image>@low.<ext> - 0.75x
<image>@medium.<ext> / <image>.<ext> - 1x
<image>@high.<ext> - 1.5x
<image>@extra-high.<ext> / <image>@2x - 2x
<image>@ultra-high.<ext> - 4x
*/


# ICON TYPE
----------
setProp tmIconType pValue
   set the tmControlData["iconType"] of me to pValue
   updateMyIcon
end tmIconType

getProp tmIconType
   return myIconType()
end tmIconType

function myIconType
   get the tmControlData["iconType"] of me
   if it is empty then get "embedded"
   return it
end myIconType


# ICON (USE ICONVALUE TO PREVENT CONFLICT WITH ICON OBJECT OF CONTROL)
--------------
setProp tmIcon pValue
   set the tmControlData["icon"] of me to pValue
   updateMyIcon "default"
end tmIcon

getProp tmIcon
   return myIconValue()
end tmIcon

function myIconValue
  return the tmControlData["icon"] of me
end myIconValue


# HOVER ICON
------------
setProp tmHoverIcon pValue
   set the tmControlData["hoverIcon"] of me to pValue
end tmHoverIcon

getProp tmHoverIcon
   return myHoverIconValue()
end tmHoverIcon

function myHoverIconValue
   return the tmControlData["hoverIcon"] of me
end myHoverIconValue


# HILITE ICON
------------
setProp tmHiliteIcon pValue
   set the tmControlData["hiliteIcon"] of me to pValue
end tmHiliteIcon

getProp tmHiliteIcon
   return myHiliteIconValue()
end tmHiliteIcon

function myHiliteIconValue
   return the tmControlData["hiliteIcon"] of me
end myHiliteIconValue


# ICON COLOR
------------
setProp tmIconColor pValue
   set the tmControlData["iconColor"] of me to pValue
   updateMyIconColor
end tmIconColor

getProp tmIconColor
   return myIconColor()
end tmIconColor

function myIconColor
   return the tmControlData["iconColor"] of me
end myIconColor


# ICON HOVER COLOR
------------------
setProp tmHoverIconColor pValue
   set the tmControlData["hoverIconColor"] of me to pValue
end tmHoverIconColor

getProp tmHoverIconColor
   return myHoverIconColor()
end tmHoverIconColor

function myHoverIconColor
   return the tmControlData["hoverIconColor"] of me
end myHoverIconColor


# ICON HILITE COLOR
------------------
setProp tmHiliteIconColor pValue
   set the tmControlData["hiliteIconColor"] of me to pValue
end tmHiliteIconColor

getProp tmHiliteIconColor
   return myHiliteIconColor()
end tmHiliteIconColor

function myHiliteIconColor
   return the tmControlData["hiliteIconColor"] of me
end myHiliteIconColor


# ICON ALIGNMENT
-----------------
setProp tmIconAlign pValue
   set the tmControlData["iconAlign"] of me to pValue
   positionMyLabel
end tmIconAlign

getProp tmIconAlign
   return myIconAlign()
end tmIconAlign

function myIconAlign
   return the tmControlData["iconAlign"] of me
end myIconAlign


# ICON SIZE
---------------
setProp tmIconSize pValue
   set the tmControlData["iconSize"] of me to pValue
   if myIconType() is "glyph" then set textSize of myIcon() to pValue
   if myIconType() is "image" then
      set width of myIcon() to pValue
      set height of myIcon() to pValue
   end if
   updateMyLabel
   resizeControl
end tmIconSize

setProp tmIconSize
   return myIconSize()
end tmIconSize

function myIconSize
   return the tmControlData["iconSize"] of me
end myIconSize


# ICON MARGINS
---------------
setProp tmIconMargins pValue
   set the tmControlData["iconMargins"] of me to pValue
   positionMyLabel
end tmIconMargins

getProp tmIconMargins
   return myIconMargins()
end tmIconMargins

function myIconMargins
   return the tmControlData["iconMargins"] of me
end myIconMargins


# ICON SHIFT
-----------
setProp tmIconShift pValue
   set the tmControlData["iconShift"] of me to pValue
   positionMyLabel
end tmIconShift

getProp tmIconShift
   return myIconShift()
end tmIconShift

function myIconShift
   return the tmControlData["iconShift"] of me
end myIconShift


# GLYPH FONTS
-------------
setProp tmGlyphFont pValue
   set the tmControlData["glyphFont"] of me to pValue
end tmGlyphFont

getProp tmGlyphFont
   return myGlyphFont()
end tmGlyphFont

function myGlyphFont
   return the tmControlData["glyphFont"] of me
end myGlyphFont


# GLYPH SIZE
------------
setProp tmGlyphSize pValue
   set lockUpdates of me to true
   set textSize of myIcon() to pValue
   positionMyLabel
end tmGlyphSize

getProp tmGlyphSize
   return myGlyphSize()
end tmGlyphSize

function myGlyphSize
   return textSize of myIcon()
end myGlyphSize


# SHOW ICON
------------
setProp tmShowIcon pValue
   set the tmControlData["showIcon"] of me to pValue
   lock screen
   set vis of myIcon() to pValue
   positionMyLabel
   unlock screen
end tmShowIcon

getProp tmShowIcon
   return myShowIcon()
end tmShowIcon

function myShowIcon
   return the tmControlData["showIcon"] of me
end myShowIcon


# ROUND RADIUS
----------------
setProp tmRoundRadius pValue 
   set roundRadius of myBase() to max(pValue,0)
   set roundRadius of myFace() to max(pValue,0)
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return roundRadius of myBase()
end myRoundRadius


# BEVEL WIDTH
----------------
setProp tmBevelWidth pValue
   set the tmControlData["bevelWidth"] of me to pValue
end tmBevelWidth

getProp tmBevelWidth
   return the tmControlData["bevelWidth"] of me
end tmBevelWidth


# SHOW NAME
-------------
setProp tmShowName pValue
   set vis of myLabel() to pValue
   positionMyLabel
end tmShowName

getProp tmShowName
    return myShowName()
end tmShowName

function myShowName
   return the vis of myLabel()
end myShowName


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
   set the tmControlData["disabled"] of me to pValue
   set disabled of me to pValue
   set blendLevel of me to item wordOffset(pValue,"true false") of "50,0"
end tmDisabled

getProp tmDisabled
   return myDisabled()
end tmDisabled

function myDisabled
   return the tmControlData["disabled"] of me
end myDisabled


# ENABLED
----------
setProp tmEnabled pValue
   set the enabled of me to pValue
end tmEnabled

getProp tmEnabled
   return myEnabled()
end tmEnabled

function myEnabled
   return the enabled of me
end myEnabled



private function myRegion
   return long id of grc "button_region" of me
end myRegion

private function myBase
   return long id of grc "button_base" of me
end myBase

private function myFace
   if exists(grc "button_face" of me) then return long id of grc "button_face" of me
   return empty
end myFace

private function myIcon
   return long id of btn "button_icon" of me
end myIcon

function myIconSource
   return long id of img 1 of me
end myIconSource

private function myLabel
   return long id of btn "button_label" of me
end myLabel

private function myIcon
   return long id of btn "button_icon" of me
end myIcon

private function myPointer
   if there is a grc "button_pointer" of me then return long id of grc "button_pointer" of me
   return empty
end myPointer
