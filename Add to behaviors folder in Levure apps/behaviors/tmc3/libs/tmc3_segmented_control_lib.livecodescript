script "tmc3_segmented_control_lib" with behavior "tmc3_MasterBehavior"
local allowTracking, allowHiliting, thePressedTab


before mouseDown
   put false into allowHiliting
   if not the tmControlData["autoHilite"] of the target then exit mouseDown
   put myPressedTab() into thePressedTab
   updateMySemiHilite thePressedTab
   put true into allowHiliting
   put true into allowTracking
   dispatch "controlDown" -- SEND TO POSSIBLE OWNER CONTROL
end mouseDown


before mouseMove
   if not allowTracking then exit mouseMove
   if not the tmControlData["autoHilite"] of the target then exit mouseMove
   if within(me,mouseLoc()) then updateMySemiHilite
   if not within(me,mouseLoc()) and the vis of mySemiHilite() then
      repeat with N = 1 to 10
         set blendLevel of mySemiHilite() to (50 + (N*5))
         wait 5 millisecs
      end repeat
      hide mySemiHilite()
   end if
end mouseMove


before mouseUp
   put false into allowTracking
   if not allowHiliting then exit mouseUp
   if not the tmControlData["autoHilite"] of the target then exit mouseUp
   -- wait 150 millisecs
   lock screen
   put 1 into N
   repeat for each line theTab in myTabs()
      set textColor of theTab to myTextColor()
      set dropShadow of theTab to empty
      if theTab = thePressedTab then set the tmControlData["menuHistory"] of the target to N
      add 1 to N
   end repeat
   updateMyHilite
   hide mySemiHilite()
   unlock screen
   dispatch "menuPick" to the target with myHilitedTabLabel()
   dispatch "controlUp" -- SEND TO POSSIBLE OWNER CONTROL
end mouseUp


before mouseRelease
   put false into allowTracking
   hide mySemiHilite()
end mouseRelease


on resizeControl
   if behavior of the target is empty then pass resizeControl
   updateMyTabs
end resizeControl


command updateMyTabs pValue
   lock screen
   if pValue is not empty then
      -- CHANGE TABS
      put number of lines of pValue into labelCount
      if labelCount < myTabCount() then
         -- DELETE ANY EXTRANEOUS TABS
         repeat with N = myTabCount() down to (labelCount + 1)
            if N = 2 then exit repeat
            delete btn ("label" & N) of the target
            delete grc ("divider" & (N-1)) of the target
         end repeat
      end if
      repeat with N = 1 to labelCount
         if not exists(btn ("label" & N) of the target) then
            -- CREATE NEW TABS IF NEEDED
            clone btn "label1" of the target
            put it into theButtonTab
            set name of theButtonTab to ("label" & N)
            set label of theButtonTab to (line N of pValue)
            set width of theButtonTab to formattedWidth of theButtonTab
            set topLeft of theButtonTab to topRight of btn ("label" & (N-1)) of the target
            clone grc "divider1" of the target
            put it into theNewDivider
            set name of theNewDivider to ("divider" & (N-1))
            set topLeft of theNewDivider to right of btn ("label" & (N-1)) of the target, top of grc "divider1" of the target
         else
            put long id of btn ("label" & N) of the target into theButtonTab
            set label of theButtonTab to (line N of pValue)
            set width of theButtonTab to formattedWidth of theButtonTab
         end if
      end repeat
   end if
   --
   set rect of myBase() to rect of the target
   put left of myBase() into L
   put top of myBase() into T
   put right of myBase() into R
   put bottom of myBase() into B
   put width of myBase() into W
   put height of myBase() into H
   put item 1 of loc of myBase() into X
   put item 2 of loc of myBase() into Y
   --
   repeat for each line theTab in myTabs()
      add formattedWidth of theTab to totalTabWidth
   end repeat
   put ((W - totalTabWidth)/myTabCount())/2 into tabSpace
   put L into theLeft
   put 0 into theInset -- TOP/BOTTOM INSET FOR DIVIDERS
   put 1 into N
   repeat for each line theTab in myTabs()
      put formattedWidth of theTab + (tabSpace * 2) into theWidth
      if myEqualWidths() then put width of myBase()/myTabCount() into theWidth
      set rect of theTab to theLeft,T,theLeft + theWidth,B
      add theWidth to theLeft
      if N < number of lines of myTabs() then
         set rect of grc ("divider" & N) of the target to theLeft - 1,T+theInset,theLeft + 1,B-theInset
      end if
      add 1 to N
   end repeat
   --
   updateMyHilite
   unlock screen
end updateMyTabs


command updateMySemiHilite
   put pressedTabNum() into theTabNum
   put rect of btn ("label" & theTabNum) of the target into theRect
   add 1 to item 2 of theRect
   add -1 to item 4 of theRect
   if theTabNum = 1 then add 1 to item 1 of theRect
   if theTabNum = myTabCount() then subtract 1 from item 3 of theRect
   set rect of mySemiHilite() to theRect
   put long id of grc 1 of mySemiHilite() into theHiliteGraphic
   set roundRadius of theHiliteGraphic to max(0,roundRadius of myBase() - 0)
   put roundRadius of theHiliteGraphic into R
   multiply R by 2
   if theTabNum > 1 then subtract R from item 1 of theRect
   if theTabNum < myTabCount() then add R to item 3 of theRect
   set rect of theHiliteGraphic to theRect
   set blendLevel of mySemiHilite() to 50
   show mySemiHilite()
end updateMySemiHilite


command updateMyHilite
   put myMenuHistory() into N
   repeat for each line theTab in myTabs()
      set textColor of theTab to myTextColor()
   end repeat
   if N = 0 then
      hide myHilite()
      exit updateMyHilite
   end if
   put rect of btn ("label" & N) of the target into theRect
   add 1 to item 2 of theRect
   add -1 to item 4 of theRect
   if N = 1 then add 1 to item 1 of theRect
   if N = myTabCount() then subtract 1 from item 3 of theRect
   set rect of myHilite() to theRect
   put long id of grc 1 of myHilite() into theHiliteGraphic
   set roundRadius of theHiliteGraphic to max(0,roundRadius of myBase() - 0)
   put roundRadius of theHiliteGraphic into R
   multiply R by 2
   if N > 1 then subtract R from item 1 of theRect
   if N < myTabCount() then add R to item 3 of theRect
   set rect of theHiliteGraphic to theRect
   set textColor of btn ("label" & N) of the target to myTextHiliteColor()
   show myHilite()
end updateMyHilite


-- IMMEDIATELY REMOVE ANY SEMIHILITE
command deHiliteMe
   put false into allowTracking
   hide mySemiHilite()
   put false into allowHiliting
end deHiliteMe


-- TEXT
setProp tmText pValue
   updateMyTabs pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   repeat for each line theTab in myTabs()
      put label of theTab & return after theList 
   end repeat
   delete last char of theList
   return theList
end myText


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


-- MENU HISTORY
setProp tmMenuHistory pValue
   set the tmControlData["menuHistory"] of the target to min(myTabCount(),max(0,pValue))
   updateMyTabs
end tmMenuHistory

getProp tmMenuHistory
   return myMenuHistory()
end tmMenuHistory

function myMenuHistory
   return the tmControlData["menuHistory"] of the target
end myMenuHistory


-- HILITED TAB LABEL
getProp tmHilitedTabLabel
   return myHilitedTabLabel()
end tmHilitedTabLabel

function myHilitedTabLabel
   return label of btn myMenuHistory() of the target
end myHilitedTabLabel


-- TEXT STYLE
setProp tmTextStyle pValue
   set the tmControlData["textStyle"] of the target to pValue
   repeat for each line theTab in myTabs()
      set textStyle of theTab to pValue
   end repeat
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return the tmControlData["textStyle"] of the target
end myTextStyle


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of the target to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of the target
end myBaseColor


-- HILITE COLOR
setProp tmHiliteColor pValue
   set the tmControlData["hiliteColor"] of the target to pValue
   set backColor of grc 1 of myHilite() to pValue
   set backColor of grc 1 of mySemiHilite() to pValue
   set foreColor of myBase() to pValue
   repeat for each line theDivider in myDividers()
      set foreColor of theDivider to pValue
   end repeat
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return the tmControlData["hiliteColor"] of the target
end myHiliteColor


-- TEXT FONT
setProp tmTextFont pValue
   set the tmControlData["textFont"] of the target to pValue
   repeat for each line theTab in myTabs()
      set textFont of theTab to pValue
   end repeat
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return the tmControlData["textFont"] of the target
end myTextFont


-- TEXT SIZE
setProp tmTextSize pValue
   set the tmControlData["textSize"] of the target to pValue
   repeat for each line theTab in myTabs()
      set textSize of theTab to pValue
   end repeat
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return the tmControlData["textSize"] of the target
end myTextSize


-- TEXT ALIGNMENT
setProp tmTextHeight pValue
   --   NO EFFECT
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return empty
end myTextHeight


-- TEXT ALIGNMENT
setProp tmTextAlign pValue
   set the tmControlData["textAlign"] of the target to pValue
   repeat for each line theTab in myTabs()
      set textAlign of theTab to pValue
   end repeat
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return the tmControlData["textAlign"] of the target
end myTextAlign


-- TEXT COLOR
setProp tmTextColor pValue
   set the tmControlData["textColor"] of the target to pValue
   repeat for each line theTab in myTabs()
      set textColor of theTab to pValue
   end repeat
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of the target
end myTextColor


-- TEXT HILITE COLOR
setProp tmTextHiliteColor pValue
   set the tmControlData["textHiliteColor"] of the target to pValue
   updateMyHilite
end tmTextHiliteColor

getProp tmTextHiliteColor
   return myTextHiliteColor()
end tmTextHiliteColor

function myTextHiliteColor
   return the tmControlData["textHiliteColor"] of the target
end myTextHiliteColor


-- VERTICAL TEXT OFFSET
setProp tmVerticalTextOffset pValue
   repeat for each line theTab in myTabs()
      set topMargin of theTab to pValue
   end repeat
end tmVerticalTextOffset

getProp tmVerticalTextOffset
   return myVerticalTextOffset()
end tmVerticalTextOffset

function myVerticalTextOffset
   return topMargin of btn "label1" of the target
end myVerticalTextOffset


-- ROUND RADIUS
setProp tmRoundRadius pValue
   set roundRadius of myBase() to pValue
   updateMyHilite
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return roundRadius of myBase()
end myRoundRadius


-- EQUAL WIDTHS
setProp tmEqualWidths pValue
   set the tmControlData["equalWidths"] of the target to pValue
   updateMyTabs
end tmEqualWidths

getProp tmEqualWidths
   return myEqualWidths()
end tmEqualWidths

function myEqualWidths
   return the tmControlData["equalWidths"] of the target
end myEqualWidths


-- SHOW DIVIDERS
setProp tmShowDividers pValue
   repeat for each line theDivider in myDividers()
      set vis of theDivider to pValue
   end repeat
   set the tmControlData["showDividers"] of the target to pValue
end tmShowDividers

getProp tmShowDividers
   return myShowDividers()
end tmShowDividers

function myShowDividers
   return the tmControlData["showDividers"] of the target
end myShowDividers


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





function myTabCount
   repeat with N = 1 to number of controls of the target
      if exists(btn ("label" & N) of the target) then next repeat
      return (N-1)
   end repeat
   return 0
end myTabCount


function defaultShadow
   --   put 0,0,0 into theArray["color"]
   --   put 120 into theArray["opacity"]
   --   put "box3pass" into theArray["filter"]
   --   put 0 into theArray["spread"]
   --   put 2 into theArray["size"]
   --   put 1 into theArray["distance"]
   --   put 90 into theArray["angle"]
   --   put false into theArray["knockout"]
   --   return theArray
   return empty
end defaultShadow


function defaultPressColor
   put 214,25,97 into theArray["color"]
   put 255 into theArray["opacity"]
   put "normal" into theArray["blendMode"]
   return theArray
end defaultPressColor


function myPressedTab
   repeat for each line theTab in myTabs()
      if within(theTab,mouseLoc()) then return theTab
   end repeat
end myPressedTab


function pressedTabNum
   return lineOffset(thePressedTab,myTabs())
end pressedTabNum


private function myBase
   return long id of grc "base" of the target
end myBase


private function myTabs
   repeat with N = 1 to number of btns of the target
      if exists(btn ("label" & N) of the target) then put long id of btn ("label" & N) of the target & return after theList
   end repeat
   delete last char of theList
   return theList
end myTabs


private function myDividers
   repeat with N = 1 to number of grcs of the target
      if exists(grc ("divider" & N) of the target) then put long id of grc ("divider" & N) of the target & return after theList
   end repeat
   delete last char of theList
   return theList
end myDividers


private function mySemiHilite
   return long id of grp "tabsemihilite" of the target
end mySemiHilite


private function myHilite
   return long id of grp "tabhilite" of the target
end myHilite
