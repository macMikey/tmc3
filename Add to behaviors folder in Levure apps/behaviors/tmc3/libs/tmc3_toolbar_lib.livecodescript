script "tmc3_toolbar_lib" with behavior "tmc3_MasterBehavior"
local allowTracking, myHoveredButton, myPressedButton, theSourceImage


on preOpenControl
   if myAutoPosition() then autoPositionMe
end preOpenControl


command autoPositionMe
   put height of the target into H
   put rect of this cd into theRect
   put item 4 of theRect - H into item 2 of theRect
   if myStickyLocation() then
      put top of the target into item 2 of theRect
      put bottom of the target into item 4 of theRect
   end if
   set rect of the target to theRect
end autoPositionMe


before mouseEnter
   if the tool is not "browse tool" then exit mouseEnter
   put empty into myHoveredButton
   if not myAutoHilite() then exit mouseEnter
   if word 1 of name of the target is not "button" then exit mouseEnter
   put long id of owner of the target into theGroup
   put hoveredButtonNumber(theGroup) into myHoveredButton
   hoverMyButtonIcon myHoveredButton
end mouseEnter


before mouseLeave
   if the tool is not "browse tool" then exit mouseLeave
   if not myAutoHilite() then exit mouseLeave
   if word 1 of name of the target is not "button" then exit mouseLeave
   dispatch "resetMyButtonIcon" to the target with myHoveredButton
end mouseLeave


before mouseDown
   -- INIT VARS
   put empty into myPressedButton
   put empty into theSourceImage
   if word 1 of (long name of the mouseControl) is not "button" then exit mouseDown
   put long id of owner of the mouseControl into theGroup
   put pressedButtonNumber(theGroup) into myPressedButton
   if not myAutoHilite() then exit mouseDown
   hiliteMyButtonIcon
end mouseDown


before mouseUp
   put false into allowTracking
   if myPressedButton is empty then exit mouseUp
   dispatch "menuPick" to the target with short name of (line myPressedButton of myButtons())
   if not myAutoHilite() then exit mouseUp
   send "resetMyButtonIcon" to the target in 0 millisecs
end mouseUp


before mouseRelease
   put false into allowTracking
   if not myAutoHilite() then exit mouseRelease
   if myPressedButton is empty then exit mouseRelease
   send "resetMyButtonIcon" to the target in 0 millisecs
end mouseRelease


command hoverMyButtonIcon pNum
   put min(number of lines of myButtons(),max(pNum,1)) into N
   put line N of myButtons() into theButtonGroup
   put long id of btn 1 of theButtonGroup into theButton
   put the tmControlData["hoverIcon"] of theButtonGroup into theHoverID
   switch the tmControlData["iconType"] of theButtonGroup
      case "glyph"
         if theHoverID is not empty and theHoverID <> 0 then set label of theButton to numToCodepoint(theHoverID)
         get the tmControlData["hoverIconColor"] of theButtonGroup
         if it is not empty then set textColor of theButton to it
         break
      case "icon"
         if theHoverID is not empty and theHoverID <> 0 then set icon of theButton to theHoverID
         -- set colorOverlay["opacity"] of theButton to 0
   end switch
end hoverMyButtonIcon


command hiliteMyButtonIcon pNum
   put myPressedButton into N
   if pNum is not empty then put pNum into N
   put min(number of lines of myButtons(),max(N,1)) into N
   put line N of myButtons() into theButtonGroup
   put long id of btn 1 of theButtonGroup into theButton
   put the tmControlData["hiliteIcon"] of theButtonGroup into theHiliteID
   switch the tmControlData["iconType"] of theButtonGroup
      case "glyph"
         if theHiliteID is not empty and theHiliteID <> 0 then set label of theButton to numToCodepoint(theHiliteID)
         get the tmControlData["hiliteIconColor"] of theButtonGroup
         if it is not empty then set textColor of theButton to it
         break
      case "icon"
         if theHiliteID is not empty and theHiliteID <> 0 then set icon of theButton to theHiliteID
         -- set colorOverlay["opacity"] of theButton to 0
   end switch
   set the tmControlData["menuHistory"] of the target to N
   put true into allowTracking
end hiliteMyButtonIcon


command resetMyButtonIcon pNum
   put myPressedButton into N
   put 150 into theDelay
   if pNum is not empty then
      put pNum into N
      put 0 into theDelay
   end if
   if N is empty then exit resetMyButtonIcon
   wait theDelay millisecs
   put line N of myButtons() into theButtonGroup
   put long id of btn 1 of theButtonGroup into theButton
   put the tmControlData["hoverIcon"] of theButtonGroup into theID
   if theID = 0 or theID is empty then put the tmControlData["icon"] of theButtonGroup into theID
   if myHoveredButton is empty or not within(theButton,mouseLoc()) then put the tmControlData["icon"] of theButtonGroup into theID
   switch the tmControlData["iconType"] of theButtonGroup
      case "glyph"
         put the tmControlData["hoverIconColor"] of theButtonGroup into theColor
         if theColor is empty or not within(theButton,mouseLoc()) then put the tmControlData["iconColor"] of theButtonGroup into theColor
         set label of theButton to numToCodepoint(theID)
         set textColor of theButton to theColor
         break
      case "icon"
         set icon of theButton to theID
         -- set colorOverlay["opacity"] of theButton to 0
   end switch
end resetMyButtonIcon


command updateMyButtons pNewButtonList
   lock screen
   put myButtons() into currButtonList
   --
   -- SAME BUTTON COUNT, RENAME ONLY
   if number of lines of pNewButtonList = myButtonCount() then
      put 1 into N
      repeat for each line theButton in currButtonList
         set name of theButton to line N of pNewButtonList
         add 1 to N
      end repeat
      set the tmControlData["text"] of the target to pNewButtonList
      exit updateMyButtons
   end if
   --
   -- REMOVE ANY BUTTONS THAT AREN'T IN NEW LIST
   local theUsedNames
   repeat for each line theButton in currButtonList
      put short name of theButton into theButtonName
      if myButtonCount() = 1 then
         if theButtonName is not among the lines of currButtonList then
            set name of theButton to line 1 of pNewButtonList
         end if
         set left of theButton to left of the target
         exit repeat -- DON'T DELETE LAST BUTTON GROUP
      end if
      if theButtonName is among the lines of theUsedNames or \
            theButtonName is not among the lines of pNewButtonList  then
         delete theButton
         next repeat
      end if
      put theButtonName & cr after theUsedNames
   end repeat
   --
   -- ADD NEW BUTTONS
   if number of lines of pNewButtonList > myButtonCount() then
      put myButtons() into currButtonList
      put 1 into C
      put 1 into N
      repeat for each line theNewButtonName in pNewButtonList
         put line C of currButtonList into theCurrButton
         if theCurrButton is not empty then
            put short name of theCurrButton into theCurrButtonName
            if theNewButtonName = theCurrButtonName then
               add 1 to C
               add 1 to N
               next repeat
            end if
         end if
         put line max(1,(N-1)) of myButtons() into theSourceButton
         clone theSourceButton
         put it into theNewButton
         set name of theNewButton to line N of pNewButtonList
         set icon of btn 1 of theNewButton to id of img 1 of theNewButton
         put left of theSourceButton + 10 into theLeft
         set topLeft of theNewButton to theLeft,top of theSourceButton
         add 1 to N
      end repeat
   end if
   --
   set the tmControlData["text"] of the target to pNewButtonList
   resizeControl
end updateMyButtons


command updateMyButtonIcon pType, pButtonGroup
   lock screen
   put long id of btn 1 of pButtonGroup into theButton
   switch pType
      case "glyph"
         set icon of theButton to 0
         set label of theButton to numToCodepoint(the tmControlData["icon"] of pButtonGroup)
         set textFont of theButton to the tmControlData["glyphFont"] of pButtonGroup
         set textColor of theButton to the tmControlData["iconColor"] of pButtonGroup
         -- if not myLockImageIconColor() then set textColor of theButton to the tmControlData["iconColor"] of pButtonGroup
         set showName of theButton to true
         break
      case "icon"
         set icon of theButton to the tmControlData["icon"] of pButtonGroup
         set showName of theButton to false
         break
      case "embedded"
         
   end switch
   unlock screen
end updateMyButtonIcon


command updateMyIconColors
   lock screen
   repeat with N = 1 to number of grps of the target
      put long id of grp N of the target into theButtonGroup
      if the tmControlData["iconType"] of theButtonGroup is "glyph" then
         -- GLYPH
         set the tmControlData["iconColor"] of theButtonGroup to myIconColor()
         set the tmControlData["hiliteIconColor"] of theButtonGroup to myHiliteIconColor()
         put long id of btn 1 of theButtonGroup into theButton
         set textColor of theButton to myIconColor()
      else
         -- IMAGE
         put long id of img N of the target into theSourceImage
         repeat for each item theRes in "ultralow,extralow,low,medium,high,extrahigh,ultrahigh"
            repeat for each item theState in "Icon,HiliteIcon"
               put theRes & theState into prop
               put the tmControlData[prop] of theSourceImage into theIconData
               if theIconData is empty then next repeat
               reset the templateImage
               set text of the templateImage to theIconData
               if theState is "Icon" then set imageData of the templateImage to solidColorImageData("the TemplateImage",myIconColor())
               if theState is "HiliteIcon" then set imageData of the templateImage to solidColorImageData("the TemplateImage",myHiliteIconColor())
               set the tmControlData[prop] of theSourceImage to text of the templateImage
            end repeat
         end repeat
         put (pixelDensity() & "Icon") into theIconProp
         set text of theSourceImage to the tmControlData[theIconProp] of theSourceImage
      end if
   end repeat
   reset the templateImage
   unlock screen
end updateMyIconColors


--command importIconData pSourceData, pButton, pGlyphFont, pGlyphColor
--   put long id of owner of pButton into theButtonGroup
--   --
--   switch myIconType()
--      case "glyph"
--         set the tmControlData["icon"] of theButtonGroup to pSourceData
--         set the tmControlData["glyphFont"] of theButtonGroup to pGlyphFont
--         set the tmControlData["iconColor"] of theButtonGroup to pGlyphColor
--         updateMyButtonIcon "glyph", theButtonGroup
--         break
--      case "icon"
--         put pSourceData into pSourceObj
--         put long id of img 1 of theButtonGroup into theIconSource
--         -- CLEAR EXISTING ICON DATA
--         set the customKeys["tmControlData"] of theIconSource to empty
--         put the customKeys["tmControlData"] of pSourceObj into theIconProps
--         -- COPY ICON RESOURCES
--         repeat for each line prop in theIconProps
--            set the tmControlData[prop] of theIconSource to the tmControlData[prop] of pSourceObj
--         end repeat
--         set text of theIconSource to the tmControlData[pixelDensity() & "icon"] of theIconSource
--         set width of theIconSource to (formattedWidth of theIconSource div screenPixelScale)
--         set height of theIconSource to (formattedHeight of theIconSource div screenPixelScale)
--         updateMyButtonIcon "image", theButtonGroup
--         if myLockImageIconColor() then updateMyIconColors
--   end switch
--   -- POSITION ICONS
--   resizeControl
--end importIconData


on resizeControl
   lock screen
   set rect of myBase() to rect of the target
   set boundingRect of the target to rect of myBase()
   set rect of the target to rect of myBase()
   put left of myBase() into L
   put top of myBase() into T
   put right of myBase() into R
   put bottom of myBase() into B
   put width of myBase() into W
   put height of myBase() into H
   put item 1 of loc of myBase() into X
   put item 2 of loc of myBase() into Y
   put myButtons() into theButtonList
   switch myButtonCount()
      case 1
         set loc of grp 1 of the target to X,Y
         break
      case 2
         set loc of (line 1 of theButtonList) to L+(W div 3),Y
         set loc of (line 2 of theButtonList) to R-(W div 3),Y
         break
      case 3
         set loc of (line 1 of theButtonList) to L+(W div 5),Y
         set loc of (line 2 of theButtonList) to L+(W div 2),Y
         set loc of (line 3 of theButtonList) to R-(W div 5),Y
         break
      default -- MORE THAN 2 ICONS
         put myButtonCount() into theButtonCount
         put round(W*0.1) into sideSpace -- INSET LEFT/RIGHT ICONS 10% OF OVERALL WIDTH
         put (W - (sideSpace * 2)) div (theButtonCount - 1) into buttonSpace
         put 1 into N
         repeat for each line theButton in myButtons()
            if N = 1 then set loc of theButton to L+sideSpace,Y
            if N = theButtonCount then set loc of theButton to R-sideSpace,Y
            if N > 1 and N < theButtonCount then set loc of theButton to L+sideSpace+((N-1)*buttonSpace),Y
            add 1 to N
         end repeat
   end switch
   unlock screen
end resizeControl



------------
# PROPERTIES
------------

-- TEXT
setProp tmText pValue
   if pValue is empty then exit tmText
   updateMyButtons pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return the tmControlData["text"] of the target
end myText


-- BUTTONS
-- THIS SERVES THE SAME FUNCTION AS tmText
setProp tmButtons pValue
   if pValue is empty then exit tmButtons
   updateMyButtons pValue
end tmButtons

getProp tmButtons
   return myButtonNames()
end tmButtons

function myButtonNames
   return the tmControlData["text"] of the target
end myButtonNames


-- AUTOPOSITION
setProp tmAutoPosition pValue
   set the tmControlData["autoPosition"] of the target to pValue
   if pValue then autoPositionMe
end tmAutoPosition

getProp tmAutoPosition
   return myAutoPosition()
end tmAutoPosition

function myAutoPosition
   return the tmControlData["autoPosition"] of the target
end myAutoPosition


-- STICKY POSITION
setProp tmStickyLocation pValue
   set the tmControlData["stickyLocation"] of the target to pValue
end tmStickyLocation

getProp tmStickyLocation
   return myStickyLocation()
end tmStickyLocation

function myStickyLocation
   return the tmControlData["stickyLocation"] of the target
end myStickyLocation


-- AUTOHILITE
setProp tmAutoHilite pValue
   set the tmControlData["autoHilite"] of the target to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   return the tmControlData["autoHilite"] of the target
end myAutoHilite


-- ICON TYPE
setProp tmIconType pValue
   -- glyph or icon
   if pValue is not among the items of "glyph,icon" then exit tmIconType
   set the tmControlData["iconType"] of the target to pValue
   repeat for each line theButtonGroup in myButtons()
      updateMyButtonIcon pValue, theButtonGroup
   end repeat
end tmIconType

getProp tmIconType
   return myIconType()
end tmIconType

function myIconType
   return the tmControlData["iconType"] of the target
end myIconType


-- ICON COLOR
setProp tmIconColor pValue
   set the tmControlData["iconColor"] of the target to pValue
   updateMyIconColors
end tmIconColor

getProp tmIconColor
   return myIconColor()
end tmIconColor

function myIconColor
   return the tmControlData["iconColor"] of the target
end myIconColor


-- ICON HILITE COLOR
setProp tmHiliteIconColor pValue
   set the tmControlData["hiliteIconColor"] of the target to pValue
   updateMyIconColors
end tmHiliteIconColor

getProp tmHiliteIconColor
   return myHiliteIconColor()
end tmHiliteIconColor

function myHiliteIconColor
   return the tmControlData["hiliteIconColor"] of the target
end myHiliteIconColor


-- LOCK ICON COLOR
setProp tmLockImageIconColor pValue
   set the tmControlData["lockImageIconColor"] of the target to pValue
end tmLockImageIconColor

getProp tmLockImageIconColor
   return myLockImageIconColor()
end tmLockImageIconColor

function myLockImageIconColor
   return the tmControlData["lockImageIconColor"] of the target
end myLockImageIconColor


---- ICON HILITE EFFECTS
--setProp tmHiliteEffects pValue
--   set the tmControlData["hiliteEffects"] of the target to pValue

--end tmHiliteEffects

--getProp tmHiliteEffects
--   return myHiliteEffects()
--end tmHiliteEffects

--function myHiliteEffects
--   return the tmControlData["hiliteEffects"] of the target
--end myHiliteEffects


-- GLYPH FONT
setProp tmGlyphFont pValue
   repeat for each line theButtonGroup in myButtons()
      set textFont of btn 1 of theButtonGroup to pValue
   end repeat
   set the tmControlData["glyphFont"] of the target to pValue
end tmGlyphFont

getProp tmGlyphFont
   return myGlyphFont()
end tmGlyphFont

function myGlyphFont
   return the tmControlData["glyphFont"] of the target
end myGlyphFont


-- GLYPH SIZE
setProp tmGlyphSize pValue
   repeat for each line theButtonGroup in myButtons()
      set textSize of btn 1 of theButtonGroup to pValue
   end repeat
   set the tmControlData["glyphSize"] of the target to pValue
end tmGlyphSize

getProp tmGlyphSize
   return myGlyphSize()
end tmGlyphSize

function myGlyphSize
   return the tmControlData["glyphSize"] of the target
end myGlyphSize


-- ICON SHIFT
setProp tmIconShift pValue
   set the tmControlData["iconShift"] of the target to pValue
   repeat for each line theButton in myButtons()
      put long id of btn 1 of theButton into theIcon
      put margins of theIcon into M
      if number of items of M = 1 then put M,M,M,M into M
      put item 1 of pValue into item 1 of M
      put item 2 of pValue into item 2 of M
      set margins of theIcon to M
   end repeat
end tmIconShift

getProp tmIconShift
   return myIconShift()
end tmIconShift

function myIconShift
   return the tmControlData["iconShift"] of the target
end myIconShift


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of the target to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return backColor of myBase()
end myBaseColor


-- BASE OPACITY
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set the tmControlData["baseOpacity"] of the target to pValue
   set blendLevel of myBase() to (100 - pValue)
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return (100 - blendLevel of myBase())
end myBaseOpacity


-- HILITE OPACITY
setProp tmHiliteOpacity pValue
   put min(255,max(pValue,0)) into pValue
   set the tmControlData["hiliteOpacity"] of the target to pValue
end tmHiliteOpacity

getProp tmHiliteOpacity
   return myHiliteOpacity()
end tmHiliteOpacity

function myHiliteOpacity
   return the tmControlData["hiliteOpacity"] of the target
end myHiliteOpacity


-- MENU HISTORY
setProp tmMenuHistory pValue
   put min(myButtonCount(),max(pValue,1)) into N
   hiliteMyButtonIcon N
end tmMenuHistory

getProp tmMenuHistory
   return myMenuHistory()
end tmMenuHistory

function myMenuHistory
   return the tmControlData["menuHistory"] of the target
end myMenuHistory


-- DISABLED
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







function myButtons
   repeat with N = 1 to number of grps of the target
      put long id of grp N of the target,left of grp N of the target & return after temp
   end repeat
   delete char -1 of temp
   sort lines of temp numeric by item 2 of each
   repeat for each line theGroup in temp
      put item 1 of theGroup & return after theList
   end repeat
   delete char -1 of theList
   return theList
end myButtons


function hoveredButtonNumber pLongID
   return lineOffset(pLongID,myButtons())
end hoveredButtonNumber


function pressedButtonNumber pLongID
   return lineOffset(pLongID,myButtons())
end pressedButtonNumber


function myButtonCount
   return number of grps of the target
end myButtonCount


function myIconResources
   
end myIconResources


private function myBase
   return long id of grc "toolbar_base" of the target
end myBase

