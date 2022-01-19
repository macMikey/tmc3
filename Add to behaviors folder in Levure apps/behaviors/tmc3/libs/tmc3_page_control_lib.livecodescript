script "tmc3_page_control_lib" with behavior "tmc3_MasterBehavior"
on resizeControl
   set rect of myRegion() to rect of the target
   put left of myRegion() into L
   put top of myRegion() into T
   put right of myRegion() into R
   put bottom of myRegion() into B
   put width of myRegion() into W
   put height of myRegion() into H
   put item 1 of loc of myRegion() into X
   put item 2 of loc of myRegion() into Y
   put margins of myRegion() into M
   if number of items of M = 1 then put M,M,M,M into M
   add item 1 of M to L
   add item 2 of M to T
   subtract item 3 of M from R
   subtract item 4 of M from B
   --
   lock screen
   if W >= H then
      set the tmControlData["orientation"] of the target to "horizontal"
   else set the tmControlData["orientation"] of the target to "vertical"
   updateDotSpacing
   unlock screen
end resizeControl


command updateDots
   lock screen
   put 1 into N
   repeat for each line theDot in myDots()
      set foreColor of theDot to myStrokeColor()
      set backColor of theDot to myFillColor()
      set filled of theDot to myFilled()
      set blendLevel of theDot to 100 - myOpacity()
      set lineSize of theDot to myStrokeWidth()
      if N = myCurrentPage() then
         set blendLevel of theDot to 0
         set opaque of theDot to true
      end if
      add 1 to N
   end repeat
   unlock screen
end updateDots


command updateDotSpacing
   lock screen
   put left of myRegion() into L
   put top of myRegion() into T
   put right of myRegion() into R
   put bottom of myRegion() into B
   put width of myRegion() into W
   put height of myRegion() into H
   put myIndicatorMargins() into M
   if M is empty then put 0 into M
   if number of items of M = 1 then put M,M,M,M into M
   put item 1 of M into ML
   put item 2 of M into MT
   put item 3 of M into MR
   put item 4 of M into MB
   put myDots() into theDots
   put myIndicatorSize() into dotWidth
   put (dotWidth / 2) into dotRadius
   put number of lines of theDots into C
   --
   put 1 into N
   repeat for each line theDot in myDots()
      put loc of theDot into theLoc
      if myOrientation() is "horizontal" then
         -- HORIZONTAL
         if myProportionalSpacing() then
            put W / (C+1) into theSpace
            put theSpace into firstOffset
         else
            put myIndicatorSpacing() into S
            put S + dotWidth into theSpace
            put (C * dotWidth) + ((C-1) * S) into fullWidth
            put ((W - fullWidth) / 2) + dotRadius into firstOffset
         end if
         if N = 1 then
            put L + round(firstOffset) into item 1 of theLoc
         else put L + round(firstOffset) + round((N-1) * theSpace) into item 1 of theLoc
         put T + round(H / 2) into item 2 of theLoc
      else
         -- VERTICAL
         if myProportionalSpacing() then
            put H / (C+1) into theSpace
            put theSpace into firstOffset
         else
            put myIndicatorSpacing() into S
            put S + dotWidth into theSpace
            put (C * dotWidth) + ((C-1) * S) into fullHeight
            put ((H - fullHeight) / 2) + dotRadius into firstOffset
         end if
         if N = 1 then
            put T + round(firstOffset) into item 2 of theLoc
         else put T + round(firstOffset) + round((N-1) * theSpace) into item 2 of theLoc
         put L + round(W / 2) into item 1 of theLoc
      end if
      set loc of theDot to theLoc
      add 1 to N
   end repeat
   unlock screen
end updateDotSpacing


setProp tmCurrentPage pValue
   -- integer
   put number of lines of myDots() into N
   set the tmControlData["currentPage"] of the target to min(N,max(0,pValue))
   updateDots
end tmCurrentPage

getProp tmCurrentPage
   return myCurrentPage()
end tmCurrentPage

function myCurrentPage
   return the tmControlData["currentPage"] of the target
end myCurrentPage


-- PAGE COUNT
setProp tmPageCount pValue
   -- integer
   put number of lines of myDots() into C
   if pValue = C then exit tmPageCount
   lock screen
   lock messages
   if pValue < C then
      put myDots() into theList
      repeat (C - pValue)
         put line -1 of theList into theDot
         delete theDot
         delete line -1 of theList
      end repeat
   end if
   if pValue > C then
      put line 1 of myDots() into firstDot
      put line -1 of myDots() into lastDot
      put 1 into theAxis
      if myOrientation() is "vertical" then put 2 into theAxis
      repeat (pValue - C)
         clone firstDot
         put it into newDot
         set name of newDot to "pagecontrol_indicator"
         put loc of lastDot into theLoc
         add 2 to item theAxis of theLoc
         set loc of newDot to theLoc
      end repeat
   end if
   unlock messages
   updateDotSpacing
   set the tmCurrentPage of the target to 1
   set the tmControlData["pageCount"] of the target to pValue
   unlock screen
end tmPageCount

getProp tmPageCount
   return myPageCount()
end tmPageCount

function myPageCount
   return the tmControlData["pageCount"] of the target
end myPageCount


-- INDICATOR SIZE
setProp tmIndicatorSize pValue
   -- integer
   set the tmControlData["indicatorSize"] of the target to pValue
   lock screen
   repeat for each line theDot in myDots()
      set width of theDot to pValue
      set height of theDot to pValue
   end repeat
   updateDotSpacing
end tmIndicatorSize

getProp tmIndicatorSize
   return myIndicatorSize()
end tmIndicatorSize

function myIndicatorSize
   return the tmControlData["indicatorSize"] of the target
end myIndicatorSize


-- INDICATOR SPACING
setProp tmIndicatorSpacing pValue
   -- integer
   set the tmControlData["indicatorSpacing"] of the target to max(0,pValue)
   updateDotSpacing
end tmIndicatorSpacing

getProp tmIndicatorSpacing
   return myIndicatorSpacing()
end tmIndicatorSpacing

function myIndicatorSpacing
   return the tmControlData["indicatorSpacing"] of the target
end myIndicatorSpacing


-- PROPORTIONAL SPACING
setProp tmProportionalSpacing pValue
   -- true, false
   set the tmControlData["proportionalSpacing"] of the target to pValue
   updateDotSpacing
end tmProportionalSpacing

getProp tmProportionalSpacing
   return myProportionalSpacing()
end tmProportionalSpacing

function myProportionalSpacing
   return the tmControlData["proportionalSpacing"] of the target
end myProportionalSpacing


setProp tmIndicatorMargins pValue
   -- comma separate list of 4 integers
   set the tmControlData["indicatorMargins"] of the target to pValue
   updateDotSpacing
end tmIndicatorMargins

getProp tmIndicatorMargins
   return myIndicatorMargins()
end tmIndicatorMargins

function myIndicatorMargins
   return the tmControlData["indicatorMargins"] of the target
end myIndicatorMargins


-- FILL
setProp tmFillColor pValue
   -- RGB values from 0 to 255
   set the tmControlData["fillColor"] of the target to pValue
   updateDots
end tmFillColor

getProp tmFillColor
   return myFillColor()
end tmFillColor

function myFillColor
   return the tmControlData["fillColor"] of the target
end myFillColor


-- STROKE
setProp tmStrokeColor pValue
   -- RGB values from 0 to 255
   set the tmControlData["strokeColor"] of the target to pValue
   updateDots
end tmStrokeColor

getProp tmStrokeColor
   return myStrokeColor()
end tmStrokeColor

function myStrokeColor
   return the tmControlData["strokeColor"] of the target
end myStrokeColor


-- COLOR: SET FILL AND STROKE TOGETHER
setProp tmIndicatorColor pValue
   -- RGB values from 0 to 255
   set the tmControlData["fillColor"] of the target to pValue
   set the tmControlData["strokeColor"] of the target to pValue
   updateDots
end tmIndicatorColor

getProp tmIndicatorColor
   return myFillColor(),myStrokeColor()
end tmIndicatorColor


-- STROKE WIDTH
setProp tmStrokeWidth pValue
   -- integer
   set the tmControlData["strokeWidth"] of the target to pValue
   updateDots
end tmStrokeWidth

getProp tmStrokeWidth
   return myStrokeWidth()
end tmStrokeWidth

function myStrokeWidth
   return the tmControlData["strokeWidth"] of the target
end myStrokeWidth


-- FILLED
setProp tmFilled pValue
   -- true, false
   set the tmControlData["filled"] of the target to pValue
   updateDots
end tmFilled

getProp tmFilled
   return myFilled()
end tmFilled

function myFilled
   return the tmControlData["filled"] of the target
end myFilled


-- OPACITY
setProp tmOpacity pValue
   -- integer value from 0 to 100 (iOS standard is 30?)
   set the tmControlData["opacity"] of the target to pValue
   updateDots
end tmOpacity

getProp tmOpacity
   return myOpacity()
end tmOpacity

function myOpacity
   return the tmControlData["opacity"] of the target
end myOpacity


-- ORIENTATION
setProp tmOrientation pValue
   -- horizontal, vertical
   set the tmControlData["orientation"] of the target to pValue
   updateDotSpacing
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   return the tmControlData["orientation"] of the target
end myOrientation



function myDots
   repeat with N = 1 to number of grcs of the target
      if "indicator" is in short name of grc N of the target then put long id of grc N of the target & tab & left of grc N of the target & cr after temp
   end repeat
   delete last char of temp
   set itemDel to tab
   sort lines of temp numeric by item 2 of each
   repeat for each line theObj in temp
      put item 1 of theObj & cr after theList
   end repeat
   delete last char of theList
   return theList
end myDots



private function myRegion
   return long id of grc "pagecontrol_region" of the target
end myRegion
