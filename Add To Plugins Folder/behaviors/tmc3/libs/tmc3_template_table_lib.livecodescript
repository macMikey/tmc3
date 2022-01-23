script "tmc3_template_table_lib" with behavior "tmc3_MasterBehavior"
before mouseDown
   if not myAutoHilite() then exit mouseDown
   get controlAtLoc(mouseLoc())
   if it is empty then exit mouseDown
   put long id of owner of it into theObj
   if theObj = long id of the target or theObj is empty then exit mouseDown
   put lineOffset(theObj,myCells()) into N
   manageMyHilitedCell N
end mouseDown


before mouseUp
   put myHilitedCell() into N
   if N = 0 then 
      put empty into theName
   else put line N of myCellNames() into theName
   dispatch "menuPick" to the target with theName
   if not myAutoHilite() then exit mouseUp
   if myListBehavior() then exit mouseUp
   unhiliteMe
   set the tmControlData["hilitedCell"] of the target to 0
end mouseUp


before mouseRelease
   if not myAutoHilite() then exit mouseRelease
   unhiliteMe
end mouseRelease


command manageMyHilitedCell pNum
   unhiliteMe -- UNHILITE CURRENTLY HILITED CELL
   --
   if pNum is empty then exit manageMyHilitedCell
   set the tmControlData["hilitedCell"] of the target to pNum
   set the tmControlData["menuHistory"] of the target to pNum
   if pNum = 0 then
      set the tmControlData["hilitedCellLabel"] of the target to empty
      exit manageMyHilitedCell
   end if
   set the tmControlData["hilitedCellLabel"] of the target to short name of (line pNum of myCells())
   hiliteMe
end manageMyHilitedCell


command hiliteMe
   local theCellBase
   if myHilitedCell() is empty then exit hiliteMe
   put line myHilitedCell() of myCells() into theCellGroup
   try
      put long id of control 1 of theCellGroup into theCellBase
   end try
   if theCellBase is empty then exit hiliteMe
   if word 1 of theCellBase is "graphic" then set colorOverlay["opacity"] of theCellBase to myHiliteOpacity()
end hiliteMe


command unhiliteMe
   local theCellBase
   if myHilitedCell() = 0 then exit unhiliteMe
   put line myHilitedCell() of myCells() into theCellGroup
   if not exists(theCellGroup) then exit unhiliteMe
   try
      put long id of control 1 of theCellGroup into theCellBase
   end try
   if theCellBase is empty then exit unhiliteMe
   if word 1 of theCellBase is "graphic" then set colorOverlay["opacity"] of theCellBase to 0
end unhiliteMe


command unhiliteAllCells
   repeat for each line theCell in myCells()
      put long id of control 1 of theCell into theBase
      if word 1 of theBase is "graphic" then set colorOverlay["opacity"] of theBase to 0
   end repeat
   set the tmControlData["hilitedCell"] of the target to 0
   set the tmControlData["hilitedCellLabel"] of the target to empty
   set the tmControlData["menuHistory"] of the target to 0
end unhiliteAllCells


on resizeControl
   lock screen
   put long owner of the target into myOwner
   if word 1 of myOwner is "group" and the tmControlData["type"] of myOwner is "template table" then
      -- RESIZE TABLE GROUP INSIDE SCROLLING REGION
      put rect of control 1 of myOwner into theRect
      put the tmControlData["controlMargins"] of myOwner into M
      add item 1 of M to item 1 of theRect
      add item 2 of M to item 2 of theRect
      if myOrientation() is "vertical" then
         subtract item 3 of M from item 3 of theRect
         put item 2 of theRect + formattedHeight of the target into item 4 of theRect
      else
         put item 1 of theRect + formattedWidth of the target into item 3 of theRect
         subtract item 4 of M from item 4 of theRect
      end if
   else
      -- RESIZE TABLE GROUP OUTSIDE OF CONTAINER
      put rect of the target into theRect
      if myOrientation() is "vertical" then
         put item 2 of theRect + formattedHeight of the target into item 4 of theRect
      else put item 1 of theRect + formattedWidth of the target into item 3 of theRect
   end if
   set rect of the target to theRect
   unlock screen
end resizeControl





# BUILD TABLE
------------
command buildTable pCellTemplate
   -- CHECK FOR EXISTENCE OF CELL TEMPLATE
   put pCellTemplate into theTemplate
   if theTemplate is empty then put myCellTemplate() into theTemplate
   if not exists(theTemplate) then
      put "Error: unable to find cell template group." into theError
      if environment() is "development" then answer theError
      return theError
   end if
   put long id of theTemplate into theTemplate
   --
   lock screen
   set vScroll of the target to 0
   set lockUpdates of the target to true
   if the tmControlData["type"] of owner of the target is "template table" then
      set vScroll of owner of the target to 0
      set hScroll of owner of the target to 0
   end if
   -- CLEAR CELL GROUPS
   put false into cellsHadToBeCleared
   repeat for each line theCell in myCells()
      put true into cellsHadToBeCleared
      delete theCell
   end repeat
   --
   set the tmControlData["hilitedCell"] of the target to empty
   --
   -- CREATE FIRST CELL FROM TEMPLATE
   put myText() into theCellList
   --
   if cellsHadToBeCleared then -- WORKAROUND FOR SERIOUS COPY BUG?
      send "buildTable" && pCellTemplate to the target in 20 millisecs
      exit buildTable
   end if
   --
   -- CREATE LIST OF ANY PLACED CONTROLS
   put the childControlIDs of the target into thePlacedControlList
   get long name of control id (line 1 of thePlacedControlList)
   if word 1 of it is "graphic" then delete line 1 of thePlacedControlList -- REMOVE BASE GRAPHIC FROM LIST
   --
   copy theTemplate to the target
   --
   put it into theMasterCell
   put theMasterCell into theCell -- TO BE USED BELOW IF THERE IS ONLY ONE CELL IN TABLE
   set name of theMasterCell to (line 1 of theCellList)
   delete line 1 of theCellList
   set topLeft of theMasterCell to topLeft of myBase()
   put rect of theMasterCell into theRect
   if myOrientation() is "vertical" then
      put right of myBase() into item 3 of theRect
   else
      put bottom of myBase() into item 4 of theRect
   end if
   set rect of theMasterCell to theRect
   put bottom of theMasterCell into theLastBottom
   put right of theMasterCell into theLastRight
   lock messages
   repeat for each line theString in theCellList
      if theString is empty then
         add myCellGroupPadding() to theLastBottom
         add myCellGroupPadding() to theLastRight
         next repeat
      end if
      clone theMasterCell
      put it into theCell
      set name of theCell to theString
      if myOrientation() is "vertical" then
         -- VERTICAL TABLE
         set topLeft of theCell to left of theMasterCell,theLastBottom
         add height of theCell to theLastBottom
      else
         -- HORIZONTAL TABLE
         set topLeft of theCell to theLastRight,top of theMasterCell
         add width of theCell to theLastRight
      end if
   end repeat
   --
   dispatch "postProcessTable" to the target -- SENT FOR ANY SPECIAL PROCESSING AFTER TABLE IS BUILT
   --
   put myCells() into theCells
   put topLeft of (line 1 of theCells),bottomRight of (line -1 of theCells) into theRect
   set rect of myBase() to theRect
   set rect of the target to theRect
   unlock messages
   --
   -- RESTORE POSITIONS OF PLACED CONTROLS
   repeat for each line theID in thePlacedControlList
      relayer control id theID to front of the target
   end repeat
   --
   put true into noTableResize
   dispatch "resizeControl" to owner of the target with noTableResize
   --
   -- UPDATE SCROLLING REGION
   -- if the tmControlData["type"] of owner of the target is "template table" then dispatch "updateMe" to owner of the target
   --
   set lockUpdates of the target to false
   unlock screen
end buildTable


# ADD CELL
----------
command addCell pName, pIndex, pPosition
   lock screen
   if pName is empty then put "untitled" into pName
   if pIndex is not a number then return "error: index is not a number (" & pIndex & ")"
   put myCells() into theCellList -- STORE CURRENT CELL LIST
   put myCellCount() into theCellCount -- STORE CURRENT CELL COUNT
   put min(theCellCount,max(1,pIndex)) into theIndex
   put line theIndex of theCellList into theReferenceCell
   if theIndex = 1 and pPosition is "before" then put line 1 of theCellList into theReferenceCell
   if theIndex = theCellCount and pPosition is "after" then put line -1 of theCellList into theReferenceCell
   copy myCellTemplate() to the target
   put it into theNewCell
   set name of theNewCell to pName
   set rect of theNewCell to rect of theReferenceCell
   put height of theNewCell into H
   put width of theNewCell into W
   if myOrientation() is "vertical" then
      -- VERTICAL
      if pPosition is "after" then
         set top of theNewCell to (top of theNewCell + H)
         add 1 to theIndex -- START COUNTING FROM NEXT CELL IN CELL LIST
      end if
      -- REPOSITION SUBSEQUENT CELLS
      if theIndex <=  theCellCount then
         repeat with N = theIndex to theCellCount
            put line N of theCellList into theCell
            set top of theCell to (top of theCell + H)
         end repeat
      end if
      put rect of myBase() into theRect
      add H to item 4 of theRect
      set rect of myBase() to theRect
   else
      -- HORIZONTAL
      if pPosition is "after" then
         set left of theNewCell to (left of theNewCell + W)
         add 1 to theIndex -- START COUNTING FROM NEXT CELL IN CELL LIST
      end if
      -- REPOSITION SUBSEQUENT CELLS
      if theIndex <=  theCellCount then
         repeat with N = theIndex to theCellCount
            put line N of theCellList into theCell
            set left of theCell to (left of theCell + W)
         end repeat
      end if
      put rect of myBase() into theRect
      add W to item 3 of theRect
      set rect of myBase() to theRect
   end if
   set rect of the target to theRect
   --
   -- UPDATE TEXT PROPERTY
   put myText() into theData
   if pPosition is "before" then
      -- BEFORE
      if pIndex = 1 then
         put pName & return before theData
      else put pName & return before line adjustedLineNumber(pIndex) of theData
   end if
   if pPosition is "after" then
      -- AFTER
      if pIndex = number of lines of theData then
         put return & pName after theData
      else put return & pName after line adjustedLineNumber(pIndex) of theData
   end if
   set the tmControlData["text"] of the target to theData
   dispatch "postProcessTable" to the target
   dispatch "updateMyRegion" to owner of the target
   dispatch "updateMe" to owner of the target -- UPDATE SCROLLER
   unlock screen
end addCell


# DELETE CELL
------------
command deleteCell pIndex
   lock screen
   if pIndex is empty then return "error: missing index"
   if pIndex > myCellCount() or pIndex < 1 then return "error: index" && pIndex && "is outside of table cell range"
   if myCellCount() = 1 then return "error: can't delete cell of single-cell table"
   put pIndex into theIndex
   --
   put line theIndex of myCells() into theCell
   put height of theCell into H
   put width of theCell into W
   delete theCell
   --
   -- REPOSITION SUBSEQUENT CELLS
   put myCells() into theCellList
   put myCellCount() into theCellCount
   if myOrientation() is "vertical" then
      -- VERTICAL
      if theIndex <=  theCellCount then
         repeat with N = theIndex to theCellCount
            put line N of theCellList into theCell
            set top of theCell to (top of theCell - H)
         end repeat
      end if
      put rect of myBase() into theRect
      subtract H from item 4 of theRect
      set rect of myBase() to theRect
   else
      -- HORIZONTAL
      if theIndex <=  theCellCount then
         repeat with N = theIndex to theCellCount
            put line N of theCellList into theCell
            set left of theCell to (left of theCell - W)
         end repeat
      end if
      put rect of myBase() into theRect
      subtract W from item 3 of theRect
      set rect of myBase() to theRect
   end if
   set rect of the target to theRect
   -- UPDATE TEXT PROPERTY
   put myText() into theData
   delete line adjustedLineNumber(theIndex) of theData
   set the tmControlData["text"] of the target to theData
   dispatch "postProcessTable" to the target
   dispatch "updateMyRegion" to owner of the target
   dispatch "updateMe" to owner of the target -- UPDATE SCROLLER
   unlock screen
end deleteCell


# UPDATE APPEARANCE
-------------------
command updateMe
   put rect of myBase() into theRect
   put 1 into N
   repeat for each line theCell in myCells()
      
      add 1 to N
   end repeat
   -- UPDATE HILITE
   -- updateHilite
end updateMe


function adjustedLineNumber pNum
   put 0 into theCellCount
   put 0 into N
   repeat for each line theLine in myText()
      add 1 to N
      if theLine is not empty then add 1 to theCellCount
      if theCellCount = pNum then return N
   end repeat
   return N
end adjustedLineNumber


--------------------------------------------------------------
# PROPERTIES
--------------------------------------------------------------

# TYPE - READ ONLY
------
getProp tmControlType
   return myControlType()
end tmControlType

function myControlType
   return the tmControlData["type"] of the target
end myControlType


# CELLS - READ ONLY
-------
getProp tmCells
   return myCells()
end tmCells

function myCells -- MISSING CODE FOR HORIZONTAL ORIENTATION
   repeat for each line theID in the childControlIDs of the target
      put long id of control id theID into theControl
      if the tmControlData["type"] of theControl is not "table cell" then next repeat
      put theControl,top of theControl & return after temp
   end repeat
   delete char -1 of temp
   sort lines of temp numeric by item 2 of each
   repeat for each line objData in temp
      put item 1 of objData & return after theList
   end repeat
   delete char -1 of theList
   return theList
end myCells


# CELL COUNT - READ ONLY
------------
getProp tmCellCount
   return myCellCount()
end tmCellCount

function myCellCount
   return number of lines of myCells()
end myCellCount


# CELL NAMES - READ ONLY
------------
getProp tmCellNames
   return myCellNames()
end tmCellNames

function myCellNames
   put myCells() into temp
   repeat for each line theCell in temp
      put short name of theCell & return after theList
   end repeat
   delete char -1 of theList
   return theList
end myCellNames


# CELL IDS - READ ONLY
---------
getProp tmCellIDs
   return myCellIDs()
end tmCellIDs

function myCellIDs
   put myCells() into temp
   repeat for each line theCell in temp
      put id of theCell & return after theList
   end repeat
   delete char -1 of theList
   return theList
end myCellIDs


# CELL TEMPLATE STACK - READ ONLY
--------------------
--getProp tmCellTemplateStack
--   return myCellTemplateStack()
--end tmCellTemplateStack

--function myCellTemplateStack
--   put the subStacks of this stack into theList
--   put "iOS_TableTemplates" into theStackName
--   put substacks of myMainStack() into theList
--   if theList is not empty then
--      put line lineOffset(theStackName,theList) of theList into theTemplateStackName
--      if theTemplateStackName is not empty then return long name of stack theTemplateStackName
--   end if
--   --
--   -- CHECK OPEN STACKS
--   put openStacks() into theList
--   if theStackName is among the lines of theList then
--      put line lineOffset(theStackName,theList) of theList into theTemplateStackName
--      if theTemplateStackName is not empty then return long name of stack theTemplateStackName
--   end if
--   --
--   -- CHECK SUBSTACKS OF OPEN STACKS
--   repeat for each line theStack in theList
--      if char 1 to 3 of theStack is "rev" then next repeat
--      put substacks of stack theStack into theSubstacks
--      if theSubstacks is empty then next repeat
--      put line lineOffset(theStackName,theList) of theList into theTemplateStackName
--      if theTemplateStackName is not empty then return long name of stack theTemplateStackName
--   end repeat
--   --
--   return empty
--end myCellTemplateStack


# TEXT
------
setProp tmText pValue
   set the tmControlData["text"] of the target to pValue
   buildTable
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return the tmControlData["text"] of the target
end myText


# CELL TEMPLATE REFERENCE
-------------------------
setProp tmCellTemplate pValue
   set the tmControlData["cellTemplate"] of the target to pValue
   buildTable
end tmCellTemplate

getProp tmCellTemplate
   return myCellTemplate()
end tmCellTemplate

function myCellTemplate
   return the tmControlData["cellTemplate"] of the target
end myCellTemplate


# ORIENTATION
-------------
setProp tmOrientation pValue
   set the tmControlData["orientation"] of the target to pValue
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   return the tmControlData["orientation"] of the target
end myOrientation


# HILITED CELL
-------------
setProp tmHilitedCell pValue
   -- integer
   put min(myCellCount(),max(0,pValue)) into pValue
   if pValue = 0 or pValue is not a number then
      unhiliteAllCells
      exit tmHilitedCell
   end if
   manageMyHilitedCell pValue
end tmHilitedCell

getProp tmHilitedCell
   return myHilitedCell()
end tmHilitedCell

function myHilitedCell
   return the tmControlData["hilitedCell"] of the target
end myHilitedCell


# HILITED CELL LABEL
------------------
setProp tmHilitedCellLabel pValue
   -- string (short name)
   put lineOffset(pValue,myCellNames()) into N
   if N = 0 or N is empty then
      unhiliteAllCells
      exit tmHilitedCellLabel
   end if
   manageMyHilitedCell N
end tmHilitedCellLabel

getProp tmHilitedCellLabel
   return myHilitedCellLabel()
end tmHilitedCellLabel

function myHilitedCellLabel
   return the tmControlData["hilitedCellLabel"] of the target
end myHilitedCellLabel


-- LIST BEHAVIOR
setProp tmListBehavior pValue
   set the tmControlData["listBehavior"] of the target to pValue
   --   set listBehavior of myField() to true
end tmListBehavior

getProp tmListBehavior
   return myListBehavior()
end tmListBehavior

function myListBehavior
   return the tmControlData["listBehavior"] of the target
end myListBehavior


# AUTOHILITE
-----------
setProp tmAutoHilite pValue
   set the tmControlData["autoHilite"] of the target to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   return the tmControlData["autoHilite"] of the target
end myAutoHilite


# BASE COLOR
------------
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of the target to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of the target to pValue
end myBaseColor


# BASE OPACITY
--------------
setProp tmBaseOpacity pValue
   set the tmControlData["baseOpacity"] of the target to pValue
   set blendLevel of myBase() to 100 - pValue
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return the tmControlData["baseOpacity"] of the target
end myBaseOpacity


# CELL COLOR
------------
setProp tmCellColor pValue
   set the tmControlData["cellColor"] of the target to pValue
   repeat for each line theCell in myCells()
      set backColor of grc 1 of theCell to pValue
   end repeat
end tmCellColor

getProp tmCellColor
   return myCellColor()
end tmCellColor

function myCellColor
   return the tmControlData["cellColor"] of the target to pValue
end myCellColor


# HILITE COLOR
-------------
setProp tmHiliteColor pValue
   set the tmControlData["hiliteColor"] of the target to pValue
   repeat for each line theCell in myCells()
      set colorOverlay["color"] of grc 1 of theCell to pValue
   end repeat
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return the tmControlData["hiliteColor"] of the target
end myHiliteColor


# HILITE OPACITY
--------------
setProp tmHiliteOpacity pValue
   set the tmControlData["hiliteOpacity"] of the target to pValue
   hiliteMe
end tmHiliteOpacity

getProp tmHiliteOpacity
   return myHiliteOpacity()
end tmHiliteOpacity

function myHiliteOpacity
   return the tmControlData["hiliteOpacity"] of the target
end myHiliteOpacity


# CELL HEIGHT
------------
--setProp tmCellHeight pValue
--   set the tmControlData["cellHeight"] of the target to pValue
--   updateMe
--end tmCellHeight

--getProp tmCellHeight
--   return myCellHeight()
--end tmCellHeight

--function myCellHeight
--   return the tmControlData["cellHeight"] of the target
--end myCellHeight


# CELL GROUP PADDING
--------------------
setProp tmCellGroupPadding pValue
   set the tmControlData["cellGroupPadding"] of the target to pValue
   put myText() into theCellNames
   put line 1 of myCells() into theMasterCell
   put bottom of theMasterCell into theLastBottom
   put right of theMasterCell into theLastRight
   delete line 1 of theCellNames
   lock screen
   set lockUpdates of the target to true
   repeat for each line theString in theCellNames
      if theString is empty then
         add myCellGroupPadding() to theLastBottom
         add myCellGroupPadding() to theLastRight
         next repeat
      end if
      put long id of grp theString of the target into theCell
      if myOrientation() is "vertical" then
         -- VERTICAL TABLE
         set topLeft of theCell to left of theMasterCell,theLastBottom
         add height of theCell to theLastBottom
      else
         -- HORIZONTAL TABLE
         set topLeft of theCell to theLastRight,top of theMasterCell
         add width of theCell to theLastRight
      end if
   end repeat
   --
   dispatch "postProcessTable" to the target -- SENT FOR ANY SPECIAL PROCESSING AFTER TABLE IS BUILT
   --
   put myCells() into theCells
   put topLeft of (line 1 of theCells),bottomRight of (line -1 of theCells) into theRect
   set rect of myBase() to theRect
   set rect of the target to theRect
   --
   put true into noTableResize
   dispatch "resizeControl" to owner of the target with noTableResize
   set lockUpdates of the target to false
   unlock screen
end tmCellGroupPadding

getProp tmCellGroupPadding
   return myCellGroupPadding()
end tmCellGroupPadding

function myCellGroupPadding
   return the tmControlData["cellGroupPadding"] of the target
end myCellGroupPadding


# MARGINS
---------
setProp tmMargins pValue
   set the tmControlData["margins"] of the target to pValue
   updateMe
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   return the tmControlData["margins"] of the target
end myMargins



# BORDER WIDTH
--------------
--setProp tmBorderWidth pValue
--   set the tmControlData["borderWidth"] of the target to pValue
--   set lineSize of grc "table_base" of the target to pValue
--   set lineSize of grc "table_rowSeparators" of the target to pValue
--end tmBorderWidth

--getProp tmBorderWidth
--   return the tmControlData["borderWidth"] of the target
--end tmBorderWidth


# DISABLED
---------
setProp tmDisabled pValue
   set the tmControlData["disabled"] of the target to pValue
   set the disabled of the target to pValue
end tmDisabled

getProp tmDisabled
   return the tmControlData["disabled"] of the target
end tmDisabled


# COMPONENT STYLE
-----------------
--setProp tmComponentStyle pValue
--   set the tmControlData["componentStyle"] of the target to pValue
--   if pValue is "plain" then
--      set roundRadius of myBase() to 0
--      set the tmControlData["roundRadius"] of the target to 0
--   end if
--   if pValue is "grouped" then
--      set roundRadius of myBase() to 20
--      set the tmControlData["roundRadius"] of the target to 20
--   end if
--   updateMe
--end tmComponentStyle

--getProp tmComponentStyle
--   return the tmControlData["componentStyle"] of the target
--end tmComponentStyle


# MENUHISTORY
-------------
setProp tmMenuHistory pValue
   set the tmControlData["menuHistory"] of the target to max(0,pValue)
   hiliteMe pValue
end tmMenuHistory

getProp tmMenuHistory
   return myMenuHistory()
end tmMenuHistory

function myMenuHistory
   return the tmControlData["menuHistory"] of the target
end myMenuHistory


# ROUND RADIUS
--------------
setProp tmRoundRadius pValue
   set the tmControlData["roundRadius"] of the target to pValue
   set roundRadius of grc "table_base" of the target to pValue
   updateHilite
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return the tmControlData["roundRadius"] of the target
end myRoundRadius









private function myBase
   return long id of control 1 of the target
end myBase
