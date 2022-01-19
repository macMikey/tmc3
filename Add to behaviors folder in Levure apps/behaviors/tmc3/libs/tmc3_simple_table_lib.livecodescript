script "tmc3_simple_table_lib" with behavior "tmc3_MasterBehavior"
local thePressedLine


before mouseDown
   if not myAutoHilite() then exit mouseDown
   put word 2 of mouseLine() into thePressedLine
   set hilitedLines of myField() to thePressedLine
   set the tmControlData["hilitedCell"] of the target to thePressedLine
   updateMyColors
end mouseDown

before mouseUp
   if not myAutoHilite() then exit mouseUp
   if myListBehavior() then exit mouseUp
   set hilitedLines of myField() to 0
   updateMyColors
end mouseUp


on resizeControl
   lock screen
   put long owner of the target into myOwner
   if word 1 of myOwner is "group" and the tmControlData["type"] of myOwner is "simple table" then
      put long owner of the target into myOwner
      put rect of myOwner into theRect
      put the tmControlData["controlMargins"] of myOwner into M
      add item 1 of M to item 1 of theRect
      add item 2 of M to item 2 of theRect
      subtract item 3 of M from item 3 of theRect
      put item 2 of theRect + (number of lines of text of myField() * textHeight of myField()) into item 4 of theRect
      set rect of myBase() to theRect
      set rect of myField() to theRect
   end if
   --
   put rect of the target into theRect
   put text of myField() into theText
   put item 2 of theRect + (number of lines of theText * textHeight of myField()) into item 4 of theRect
   set rect of myBase() to theRect
   put item 2 of theRect + formattedHeight of myField() into item 4 of theRect
   set rect of myField() to theRect
   unlock screen
end resizeControl


command updateMyColors
   lock screen
   set textColor of char 1 to -1 of myField() to myTextColor()
   set backColor of line 1 to -1 of myField() to empty
   if myAlternateRowColor() is not empty then
      repeat with N = 1 to number of lines of text of myField()
         if N mod 2 = 0 then set backColor of line N of myField() to myAlternateRowColor()
      end repeat
   end if
   get myHilitedCell()
   if it > 0 then set textColor of line it of myField() to myHilitedTextColor()
   unlock screen
end updateMyColors


command updateMyOffset
   set textshift of line 1 to -1 of myField() to -(myTextOffset())
end updateMyOffset


command importIconData pSourceObj, pX, pY, pCode
   copy pSourceObj to me
   set loc of it to pX,pY
   if pCode is not empty then set name of it to "glyph" && pCode
end importIconData


--------------
-- PROPERTIES
--------------

-- TEXT
setProp tmText pValue
   set text of myField() to pValue
   updateMyColors
   updateMyOffset
   -- set height of the target to formattedHeight of myField()
   resizeControl
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return text of myField()
end myText


-- MARGINS
setProp tmMargins pValue
   set the tmControlData["margins"] of the target to pValue
   set margins of myField() to pValue
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   return margins of myField()
end myMargins


-- LIST BEHAVIOR
setProp tmListBehavior pValue
   set the tmControlData["listBehavior"] of the target to pValue
   set listBehavior of myField() to true
end tmListBehavior

getProp tmListBehavior
   return myListBehavior()
end tmListBehavior

function myListBehavior
   return the tmControlData["listBehavior"] of the target
end myListBehavior


-- HILITED CELL
setProp tmHilitedCell pValue
   set the tmControlData["hilitedCell"] of the target to pValue
   set hilitedLines of myField() to pValue
   updateMyColors
end tmHilitedCell

getProp tmHilitedCell
   return myHilitedCell()
end tmHilitedCell

function myHilitedCell
   return the tmControlData["hilitedCell"] of the target
end myHilitedCell


-- HILITED CELL LABEL
setProp tmHilitedCellLabel pValue
   set the tmControlData["hilitedCellLabel"] of the target to pValue
   set hilitedLines of myField() to lineOffset(pValue,text of myField()) 
end tmHilitedCellLabel

getProp tmHilitedCellLabel
   return myHilitedCellLabel()
end tmHilitedCellLabel

function myHilitedCellLabel
   put hilitedLines of myField() into N
   if N = 0 or N is empty then return empty
   return text of line N of myField()
end myHilitedCellLabel


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


-- HILITE COLOR
setProp tmHiliteColor pValue
   set the tmControlData["hiliteColor"] of the target to pValue
   set hiliteColor of myField() to pValue
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return hiliteColor of myField()
end myHiliteColor


-- TEXT SIZE
setProp tmTextSize pValue
   set the tmControlData["textSize"] of the target to pValue
   set textSize of myField() to pValue
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return textSize of myField()
end myTextSize


-- TEXT HEIGHT
setProp tmTextHeight pValue
   set the tmControlData["textHeight"] of the target to pValue
   set textHeight of myField() to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return textHeight of myField()
end myTextHeight


-- CELL HEIGHT -- VIRTUAL PROPERTY, SAME AS TEXTHEIGHT
setProp tmCellHeight pValue
   set the tmControlData["textHeight"] of the target to pValue
   set textHeight of myField() to pValue
end tmCellHeight

getProp tmCellHeight
   return myTextHeight()
end tmCellHeight


-- TEXT FONT
setProp tmTextFont pValue
   set the tmControlData["textFont"] of the target to pValue
   set textFont of myField() to pValue
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return textFont of myField()
end myTextFont


-- TEXT STYLE
setProp tmTextStyle pValue
   set the tmControlData["textStyle"] of the target to pValue
   set textStyle of myField() to pValue
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return textStyle of myField()
end myTextStyle


-- TEXT ALIGN
setProp tmTextAlign pValue
   set the tmControlData["textAlign"] of the target to pValue
   set textAlign of myField() to pValue
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return textAlign of myField()
end myTextAlign


-- TEXT COLOR
setProp tmTextColor pValue
   set the tmControlData["textColor"] of the target to pValue
   updateMyColors
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of the target
end myTextColor


-- HILITED TEXT COLOR
setProp tmHilitedTextColor pValue
   set the tmControlData["hilitedTextColor"] of the target to pValue
   updateMyColors
end tmHilitedTextColor

getProp tmHilitedTextColor
   return myHilitedTextColor()
end tmHilitedTextColor

function myHilitedTextColor
   return the tmControlData["hilitedTextColor"] of the target
end myHilitedTextColor


-- SEPARATOR COLOR
setProp tmSeparatorColor pValue
   set the tmControlData["separatorColor"] of the target to pValue
   set borderColor of myField() to pValue
end tmSeparatorColor

getProp tmSeparatorColor
   return mySeparatorColor()
end tmSeparatorColor

function mySeparatorColor
   return the tmControlData["separatorColor"] of the target
end mySeparatorColor


-- SHOW SEPARATORS
setProp tmShowSeparators pValue
   set the tmControlData["showSeparators"] of the target to pValue
   set hGrid of myField() to pValue
end tmShowSeparators

getProp tmShowSeparators
   return myShowSeparators()
end tmShowSeparators

function myShowSeparators
   return the tmControlData["showSeparators"] of the target
end myShowSeparators


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
--------------
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set the tmControlData["baseOpacity"] of the target to pValue
   set blendLevel of myBase() to 100 - pValue
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return (100 - blendLevel of myBase())
end myBaseOpacity


-- ALTERNATE ROW COLOR
-----------------------
setProp tmAlternateRowColor pValue
   set the tmControlData["alternateRowColor"] of the target to pValue
   updateMyColors
end tmAlternateRowColor

getProp tmAlternateRowColor
   return myAlternateRowColor()
end tmAlternateRowColor

function myAlternateRowColor
   return the tmControlData["alternateRowColor"] of the target
end myAlternateRowColor


-- FIRST INDENT
setProp tmFirstIndent pValue
   set the tmControlData["firstIndent"] of the target to pValue
   set firstIndent of myField() to pValue
end tmFirstIndent

getProp tmFirstIndent
   return myFirstIndent()
end tmFirstIndent

function myFirstIndent
   return the tmControlData["firstIndent"] of the target
end myFirstIndent


-- VERTICAL TEXT OFFSET
setProp tmTextOffset pValue
   set the tmControlData["textOffset"] of the target to pValue
   updateMyOffset
end tmTextOffset

getProp tmTextOffset
   return myTextOffset()
end tmTextOffset

function myTextOffset
   return the tmControlData["textOffset"] of the target
end myTextOffset




private function myBase
   return long id of control 1 of the target
end myBase


private function myField
   return long id of fld 1 of the target
end myField
