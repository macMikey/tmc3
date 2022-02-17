script "tmc3_tab_bar_lib" with behavior "tmc3_MasterBehavior"
local allowTracking, myHoveredTab, theSourceImage


on preOpenControl
   if myAutoPosition() then autoPositionMe
   put true into hiliteOnly
   if myMenuHistory() <> 0 then hiliteMyTab myMenuHistory(), hiliteOnly
end preOpenControl


on newGroup
   preOpenControl
end newGroup


command autoPositionMe
   put height of me into H
   put rect of this cd into theRect
   put item 4 of theRect - H into item 2 of theRect
   if myStickyLocation() then
      put top of me into item 2 of theRect
      put bottom of me into item 4 of theRect
   end if
   set rect of me to theRect
end autoPositionMe


before mouseEnter
   if the tool is not "browse tool" then exit mouseEnter
   put empty into myHoveredTab
   if not myAutoHilite() then exit mouseEnter
   if word 1 of name of me is not "button" then exit mouseEnter
   put long id of owner of me into theGroup
   put tabNumber(theGroup) into temp
   if temp = myMenuHistory() then exit mouseEnter
   put temp into myHoveredTab
   hoverMyTab myHoveredTab
end mouseEnter


before mouseLeave
   if the tool is not "browse tool" then exit mouseLeave
   if not myAutoHilite() then exit mouseLeave
   if myHoveredTab is empty then exit mouseLeave
   if word 1 of name of me is not "button" then exit mouseLeave
   dispatch "resetMyHilitedTab" to me with myHoveredTab
end mouseLeave


before mouseDown
   if not myAutoHilite() then exit mouseDown
   if not within(me,mouseLoc()) then exit mouseDown
   if the mouseControl is empty then exit mouseDown
   if word 1 of (long name of the mouseControl) is not in "button,field" then exit mouseDown
   put long id of owner of the mouseControl into theGroup
   put tabNumber(theGroup) into N
   hiliteMyTab N
end mouseDown


before mouseUp
   put false into allowTracking
end mouseUp


before mouseRelease
   put false into allowTracking
end mouseRelease


command hoverMyTab pNum
   put line pNum of myTabs() into theTab
   put long id of btn 1 of theTab into theButton
   put the tmControlData["hoverIcon"] of theTab into theHoverID
   switch the tmControlData["iconType"] of theTab
      case "glyph"
         if theHoverID is not empty and theHoverID <> 0 then set label of theButton to numToCodepoint(theHoverID)
         get the tmControlData["hoverIconColor"] of theTab
         if it is not empty then set textColor of theButton to it
         break
      case "icon"
         if theHoverID is not empty and theHoverID <> 0 then set icon of theButton to theHoverID
         --         get the tmControlData["hoverIconColor"] of theTab
         --         if it is not empty then
         --            put it into theArray["color"]
         --            put 100 into theArray["opacity"]
         --            put "normal" into theArray["blendMode"]
         --            set colorOverlay of theButton to theArray
         --         end if
   end switch
   put line pNum of myLabels() into theLabel
   set textColor of theLabel to the tmControlData["hoverIconColor"] of theTab
end hoverMyTab


--command unhoverMyTab
--   put line myHoveredTab of myTabs() into theTab
--   put long id of btn 1 of theTab into theButton
--   put the tmControlData["icon"] of theTab into theIconID
--   switch the tmControlData["iconType"] of theTab
--      case "glyph"
--         if theHoverID is not empty and theHoverID <> 0 then set label of theButton to numToCodepoint(theHoverID)
--         get the tmControlData["hoverIconColor"] of theTab
--         if it is not empty then set textColor of theButton to it
--         break
--      case "icon"
--         if theHoverID is not empty and theHoverID <> 0 then set icon of theButton to theHoverID
--         get the tmControlData["hoverIconColor"] of theTab
--         if it is not empty then
--            put it into theArray["color"]
--            put 100 into theArray["opacity"]
--            put "normal" into theArray["blendMode"]
--            set colorOverlay of theButton to theArray
--         end if
--   end switch
--   put line pNum of myLabels() into theLabel
--   set textColor of theLabel to the tmControlData["hoverIconColor"] of theTab
--end unhoverMyTab


command hiliteMyTab pNum, pHiliteOnly
   resetMyHilitedTab
   put min(myTabCount(),max(pNum,0)) into N
   if N = 0 then
      set the tmControlData["menuHistory"] of me to 0
      exit hiliteMyTab -- SET tmMenuHistory TO 0 (NO SELECTION)
   end if
   put line N of myTabs() into theTab
   put long id of btn 1 of theTab into theButton
   put the tmControlData["hiliteIcon"] of theTab into theHiliteID
   switch the tmControlData["iconType"] of theTab
      case "glyph"
         if theHiliteID is not empty and theHiliteID <> 0 then set label of theButton to numToCodepoint(theHiliteID)
         get the tmControlData["hiliteIconColor"] of theTab
         if it is not empty then set textColor of theButton to it
         break
      case "icon"
         if theHiliteID is not empty and theHiliteID <> 0 then set icon of theButton to theHiliteID
         --         get the tmControlData["hiliteIconColor"] of theTab
         --         if it is not empty then
         --            put it into theArray["color"]
         --            put 100 into theArray["opacity"]
         --            put "normal" into theArray["blendMode"]
         --            set colorOverlay of theButton to theArray
         --         end if
   end switch
   put line N of myLabels() into theLabel
   if theLabel is not empty then set textColor of theLabel to the tmControlData["hiliteIconColor"] of theTab
   set the tmControlData["menuHistory"] of me to N
   put empty into myHoveredTab
   if not pHiliteOnly then dispatch "menuPick" to me with short name of (line N of myTabs())
end hiliteMyTab


command resetMyHilitedTab pNum
   put myMenuHistory() into N
   if pNum is not empty then put pNum into N
   if N is empty or N = 0 then exit resetMyHilitedTab
   if N > myTabCount() then put 1 into N -- TAB DOESN'T EXIST, PROBABLY WAS DELETED
   put line N of myTabs() into theTab
   put long id of btn 1 of theTab into theButton
   put the tmControlData["icon"] of theTab into theIconID
   switch the tmControlData["iconType"] of theTab
      case "glyph"
         if theIconID is not empty and theIconID <> 0 then set label of theButton to numToCodepoint(theIconID)
         get the tmControlData["iconColor"] of theTab
         if it is not empty then set textColor of theButton to it
         break
      case "icon"
         if theIconID is not empty and theIconID <> 0 then set icon of theButton to theIconID
         --         get the tmControlData["iconColor"] of theTab
         --         if it is not empty then
         --            put it into theArray["color"]
         --            put 100 into theArray["opacity"]
         --         else
         --            put 255,255,255 into theArray["color"]
         --            put 0 into theArray["opacity"]
         --         end if
         --         put "normal" into theArray["blendMode"]
         --         set colorOverlay of theButton to theArray
   end switch
   put line N of myLabels() into theLabel
   if theLabel is not empty then set textColor of theLabel to the tmControlData["iconColor"] of theTab
end resetMyHilitedTab


command positionTabComponents pTab, pX
   put top of myBase() into T
   put long id of btn 1 of pTab into theIcon
   set top of theIcon to T + 3
   put loc of theIcon into theLoc
   put pX into item 1 of theLoc
   set loc of theIcon to theLoc
   --
   put bottom of myBase() into B
   put long id of fld 1 of pTab into theLabel
   set bottom of theLabel to B - 13
   put loc of theLabel into theLoc
   put pX into item 1 of theLoc
   set loc of theLabel to theLoc
   
   --   put long id of btn 1 of pTab into theButton
   --   put round(width of theButton div 2) into buttonW
   --   put top of myBase() into T
   --   put pX,T into theTopLeft
   --   subtract buttonW from item 1 of theTopLeft
   --   set topLeft of theButton to theTopLeft
   --   put long id of fld 1 of pTab into theLabel
   --   put width of theLabel div 2 into labelW
   --   put bottom of myBase() into B
   --   put pX,B into theBottomLeft
   --   subtract labelW from item 1 of theBottomLeft
   --   set bottomLeft of theLabel to theBottomLeft
end positionTabComponents


command updateMyTabs pNewTabList
   lock screen
   put myTabs() into currTabList
   put number of lines of pNewTabList into theNewTabCount
   --
   -- SAME TAB COUNT: RENAME ONLY
   if theNewTabCount = myTabCount() then
      put 1 into N
      repeat for each line theTab in currTabList
         set name of theTab to line N of pNewTabList
         put long id of fld 1 of theTab into theLabel
         set text of theLabel to line N of pNewTabList
         set width of theLabel to formattedWidth of theLabel
         set height of theLabel to formattedHeight of theLabel
         set loc of theLabel to item 1 of loc of theTab,item 2 of loc of theLabel
         add 1 to N
      end repeat
      set the tmControlData["text"] of me to pNewTabList
      exit updateMyTabs
   end if
   --
   -- FEWER TABS: RENAME EXISTING TABS AND DELETE EXTRA
   if theNewTabCount < myTabCount() then
      put 1 into N
      repeat for each line theTab in currTabList
         if N <= theNewTabCount then
            set name of theTab to line N of pNewTabList
            put long id of fld 1 of theTab into theLabel
            set text of theLabel to line N of pNewTabList
            set width of theLabel to formattedWidth of theLabel
            set height of theLabel to formattedHeight of theLabel
            set loc of theLabel to item 1 of loc of theTab,item 2 of loc of theLabel
         else delete theTab
         add 1 to N
      end repeat
   end if
   --
   -- MORE TABS: ADD NEW
   if number of lines of pNewTabList > myTabCount() then
      put myTabs() into currTabList
      put 1 into C
      put 1 into N
      repeat for each line theNewTabName in pNewTabList
         put line C of currTabList into theCurrTab
         if theCurrTab is not empty then
            put short name of theCurrTab into theCurrTabName
            if theNewTabName = theCurrTabName then
               add 1 to C
               add 1 to N
               next repeat
            end if
         end if
         put line max(1,(N-1)) of myTabs() into theSourceTab
         clone theSourceTab
         put it into theNewTab
         set name of theNewTab to line N of pNewTabList
         if the tmControlData["iconType"] of theNewTab is "icon" then \
               set icon of btn 1 of theNewTab to id of img 1 of theNewTab
         put long id of fld 1 of theNewTab into theLabel
         set text of theLabel to theNewTabName
         set width of theLabel to formattedWidth of theLabel
         set height of theLabel to formattedHeight of theLabel
         put left of theSourceTab + 10 into theLeft
         set topLeft of theNewTab to theLeft,top of theSourceTab
         add 1 to N
      end repeat
   end if
   --
   set the tmControlData["text"] of me to pNewTabList
   resizeControl
end updateMyTabs


# UPDATE ICON
-------------
command updateMyTabIcon pType, pTab
   put long id of btn 1 of pTab into theButton
   if pType is "glyph" then
      -- GLYPH
      set icon of theButton to 0
      set label of theButton to numToCodepoint(the tmControlData["icon"] of pTab)
      set textFont of theButton to the tmControlData["glyphFont"] of pTab
      set textColor of theButton to the tmControlData["iconColor"] of pTab
      set showName of theButton to true
   else
      -- IMAGE
      set icon of theButton to the tmControlData["icon"] of pTab
      set showName of theButton to false
   end if
end updateMyTabIcon


command updateMyIconColors
   lock screen
   repeat with N = 1 to number of grps of me
      put long id of grp N of me into theTab
      if the tmControlData["iconType"] of theTab is "glyph" then
         -- GLYPH
         set the tmControlData["iconColor"] of theTab to myIconColor()
         set the tmControlData["hiliteIconColor"] of theTab to myHiliteIconColor()
         put long id of btn 1 of theTab into theButton
         if N = myMenuHistory() then
            set textColor of theButton to myHiliteIconColor()
            else
            set textColor of theButton to myIconColor()
         end if
      else
         -- IMAGE
         put long id of img 1 of theTab into theSourceImage
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
   put true into hiliteOnly
   hiliteMyTab myMenuHistory(), hiliteOnly 
   unlock screen
end updateMyIconColors


command updateMyLabelColors
   put myMenuHistory() into MH
   put 1 into N
   repeat for each line theLabel in myLabels()
      if N <> MH then set textColor of theLabel to myIconColor()
      add 1 to N
   end repeat
end updateMyLabelColors


--command importIconData pSourceData, pButton, pGlyphFont, pGlyphHiliteCode, pGlyphColor
--   put long id of owner of pButton into theTab
--   --
--   if pSourceData is a number then
--      -- GLYPH
--      set the tmControlData["glyphCode"] of theTab to pSourceData
--      set the tmControlData["glyphHiliteCode"] of theTab to pGlyphHiliteCode
--      set the tmControlData["glyphFont"] of theTab to pGlyphFont
--      set the tmControlData["iconColor"] of theTab to pGlyphColor
--      updateMyTabIcon "glyph", theTab
--   else
--      -- IMAGE
--      set the tmControlData["glyphCode"] of theTab to empty
--      put pSourceData into pSourceObj
--      put long id of img 1 of theTab into theIconSource
--      -- CLEAR EXISTING ICON DATA
--      set the customKeys["tmControlData"] of theIconSource to empty
--      put the customKeys["tmControlData"] of pSourceObj into theIconProps
--      -- COPY ICON RESOURCES
--      repeat for each line prop in theIconProps
--         set the tmControlData[prop] of theIconSource to the tmControlData[prop] of pSourceObj
--      end repeat
--      set text of theIconSource to the tmControlData[pixelDensity() & "Icon"] of theIconSource
--      set width of theIconSource to (formattedWidth of theIconSource div screenPixelScale)
--      set height of theIconSource to (formattedHeight of theIconSource div screenPixelScale)
--      updateMyTabIcon "image", theTab
--      if myLockImageIconColor() then updateMyIconColors
--   end if
--   -- UPDATE HILITED TAB IF APPROPRIATE
--   put true into hiliteOnly
--   hiliteMyTab myMenuHistory(), hiliteOnly
--end importIconData


on resizeControl
   lock screen
   set rect of myBase() to rect of me
   set boundingRect of me to rect of myBase()
   set rect of me to rect of myBase()
   put left of myBase() into L
   put top of myBase() into T
   put right of myBase() into R
   put bottom of myBase() into B
   put width of myBase() into W
   put height of myBase() into H
   put item 1 of loc of myBase() into X
   put item 2 of loc of myBase() into Y
   put myTabs() into theTabList
   switch myTabCount()
      case 1
         positionTabComponents line 1 of theTabList,X
         break
      case 2
         put L+(W div 3) into X
         positionTabComponents line 1 of theTabList,X
         put R-(W div 3) into X
         positionTabComponents line 2 of theTabList,X
         break
      case 3
         put L+(W div 5) into X
         positionTabComponents line 1 of theTabList,X
         put L+(W div 2) into X
         positionTabComponents line 2 of theTabList,X
         put R-(W div 5) into X
         positionTabComponents line 3 of theTabList,X
         break
      default -- MORE THAN 3 TABS
         put myTabCount() into theTabCount
         put round(W*0.1) into sideSpace -- INSET LEFT/RIGHT TABS 10% OF OVERALL WIDTH
         put (W - (sideSpace * 2)) div (theTabCount - 1) into buttonSpace
         put 1 into N
         repeat for each line theTab in theTabList
            if N = 1 then positionTabComponents theTab,L+sideSpace
            if N = theTabCount then positionTabComponents theTab,R-sideSpace
            if N > 1 and N < theTabCount then positionTabComponents theTab, L+sideSpace+((N-1)*buttonSpace)
            add 1 to N
         end repeat
   end switch
   unlock screen
end resizeControl


------------
# PROPERTIES
------------

-- TABS (GROUPS)
getProp tmTabs
   return myTabs()
end tmTabs


-- TEXT
setProp tmText pValue
   if pValue is empty then exit tmText
   updateMyTabs pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return the tmControlData["text"] of me
end myText


-- AUTOPOSITION
setProp tmAutoPosition pValue
   set the tmControlData["autoPosition"] of me to pValue
   if pValue then autoPositionMe
end tmAutoPosition

getProp tmAutoPosition
   return myAutoPosition()
end tmAutoPosition

function myAutoPosition
   return the tmControlData["autoPosition"] of me
end myAutoPosition


-- STICKY POSITION
setProp tmStickyLocation pValue
   set the tmControlData["stickyLocation"] of me to pValue
end tmStickyLocation

getProp tmStickyLocation
   return myStickyLocation()
end tmStickyLocation

function myStickyLocation
   return the tmControlData["stickyLocation"] of me
end myStickyLocation


-- AUTOHILITE
setProp tmAutoHilite pValue
   set the tmControlData["autoHilite"] of me to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   return the tmControlData["autoHilite"] of me
end myAutoHilite


-- ICON TYPE
setProp tmIconType pValue
   -- glyph or image
   if pValue is not among the items of "glyph,image" then exit tmIconType
   set the tmControlData["iconType"] of me to pValue
   repeat for each line theTab in myTabs()
      updateMyTabIcon pValue, theTab
   end repeat
end tmIconType

getProp tmIconType
   return myIconType()
end tmIconType

function myIconType
   local theType
   repeat for each line theTab in myTabs()
      if theType is empty then
         if the showName of btn 1 of theTab then put "glyph" into theType
         if not the showName of btn 1 of theTab then put "image" into theType
      end if
      if theType is "glyph" and not the showName of btn 1 of theTab then return "mixed"
      if theType is "image" and the showName of btn 1 of theTab then return "mixed"
   end repeat
   return theType
end myIconType


-- ICON COLOR
setProp tmIconColor pValue
   set the tmControlData["iconColor"] of me to pValue
   updateMyIconColors
   updateMyLabelColors
   if myMenuHistory() > 0 then hiliteMyTab myMenuHistory()
end tmIconColor

getProp tmIconColor
   return myIconColor()
end tmIconColor

function myIconColor
   return the tmControlData["iconColor"] of me
end myIconColor


-- ICON HILITE COLOR
setProp tmHiliteIconColor pValue
   set the tmControlData["hiliteIconColor"] of me to pValue
   updateMyIconColors
   if myMenuHistory() > 0 then hiliteMyTab myMenuHistory()
end tmHiliteIconColor

getProp tmHiliteIconColor
   return myHiliteIconColor()
end tmHiliteIconColor

function myHiliteIconColor
   return the tmControlData["hiliteIconColor"] of me
end myHiliteIconColor


-- LOCK ICON COLOR
setProp tmLockImageIconColor pValue
   set the tmControlData["lockImageIconColor"] of me to pValue
end tmLockImageIconColor

getProp tmLockImageIconColor
   return myLockImageIconColor()
end tmLockImageIconColor

function myLockImageIconColor
   return the tmControlData["lockImageIconColor"] of me
end myLockImageIconColor


---- ICON HILITE EFFECTS
--setProp tmHiliteEffects pValue
--   set the tmControlData["hiliteEffects"] of me to pValue

--end tmHiliteEffects

--getProp tmHiliteEffects
--   return myHiliteEffects()
--end tmHiliteEffects

--function myHiliteEffects
--   return the tmControlData["hiliteEffects"] of me
--end myHiliteEffects


-- GLYPH FONT
setProp tmGlyphFont pValue
   repeat for each line theTab in myTabs()
      set textFont of btn 1 of theTab to pValue
   end repeat
end tmGlyphFont

getProp tmGlyphFont
   return myGlyphFont()
end tmGlyphFont

function myGlyphFont
   local theFont
   repeat for each line theTab in myTabs()
      if textFont of btn 1 of theTab is empty then next repeat
      if theFont is empty then put textFont of btn 1 of theTab into theFont
      if the textFont of btn 1 of theTab is not in theFont then return "mixed"
   end repeat
   return theFont
end myGlyphFont


-- GLYPH SIZE
setProp tmGlyphSize pValue
   repeat for each line theTab in myTabs()
      set textSize of btn 1 of theTab to pValue
   end repeat
   set the tmControlData["glyphSize"] of me to pValue
end tmGlyphSize

getProp tmGlyphSize
   return myGlyphSize()
end tmGlyphSize

function myGlyphSize
   return the tmControlData["glyphSize"] of me
end myGlyphSize


-- ICON SHIFT
setProp tmIconShift pValue
   set the tmControlData["iconShift"] of me to pValue
   repeat for each line theTab in myTabs()
      put long id of btn 1 of theTab into theIcon
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
   return the tmControlData["iconShift"] of me
end myIconShift


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
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
   set the tmControlData["baseOpacity"] of me to pValue
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
   -- set colorOverlay["opacity"] of btn 1 of myHilitedTab() to pValue
   set the tmControlData["hiliteOpacity"] of me to pValue
end tmHiliteOpacity

getProp tmHiliteOpacity
   return myHiliteOpacity()
end tmHiliteOpacity

function myHiliteOpacity
   return the tmControlData["hiliteOpacity"] of me
end myHiliteOpacity


-- MENU HISTORY
setProp tmMenuHistory pValue
   put min(myTabCount(),max(pValue,0)) into N
   hiliteMyTab N
end tmMenuHistory

getProp tmMenuHistory
   return myMenuHistory()
end tmMenuHistory

function myMenuHistory
   return the tmControlData["menuHistory"] of me
end myMenuHistory


-- LOCKED MENU HISTORY
setProp tmLockedMenuHistory pValue
   put min(myTabCount(),max(pValue,0)) into N
   put true into hiliteOnly
   hiliteMyTab N,hiliteOnly
end tmLockedMenuHistory


-- TEXT SIZE
setProp tmTextSize pValue
   repeat for each line theLabel in myLabels()
      set textSize of theLabel to pValue
      set width of theLabel to formattedWidth of theLabel
      set height of theLabel to formattedHeight of theLabel
   end repeat
   set the tmControlData["textSize"] of me to pValue
   resizeControl
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return the tmControlData["textSize"] of me
end myTextSize


-- TEXT FONT
setProp tmTextFont pValue
   repeat for each line theLabel in myLabels()
      set textFont of theLabel to pValue
      set width of theLabel to formattedWidth of theLabel
      set height of theLabel to formattedHeight of theLabel
   end repeat
   set the tmControlData["textFont"] of me to pValue
   resizeControl
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return the tmControlData["textFont"] of me
end myTextFont


-- TEXT STYLE
setProp tmTextStyle pValue
   repeat for each line theLabel in myLabels()
      set textStyle of theLabel to pValue
   end repeat
   set the tmControlData["textStyle"] of me to pValue
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return the tmControlData["textStyle"] of me
end myTextStyle


-- DISABLED
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



function myTabs
   repeat with N = 1 to number of grps of me
      put long id of grp N of me,left of grp N of me & return after temp
   end repeat
   delete last char of temp
   sort lines of temp numeric by item 2 of each
   repeat for each line theTab in temp
      put item 1 of theTab & return after theList
   end repeat
   delete last char of theList
   return theList
end myTabs


function myLabels
   repeat with N = 1 to number of flds of me
      put long id of fld N of me,left of fld N of me & return after temp
   end repeat
   delete char -1 of temp
   sort lines of temp numeric by item 2 of each
   repeat for each line theLabel in temp
      put item 1 of theLabel & return after theList
   end repeat
   delete char -1 of theList
   return theList
end myLabels


function myTabNames
   repeat for each line theLabel in myLabels()
      put short name of owner of theLabel & cr after theList
   end repeat
   delete char -1 of theList
   return theList
end myTabNames


function myHilitedTab
   return line (myMenuHistory()) of myTabs()
end myHilitedTab


function tabNumber pLongID
   return lineOffset(pLongID,myTabs())
end tabNumber


function myTabCount
   return number of grps of me
end myTabCount


private function myBase
   return long id of grc "tabbar_base" of me
end myBase
