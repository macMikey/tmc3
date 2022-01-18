script "tmc3_simple_chart_lib" with behavior "tmc3_MasterBehavior"
on resizeControl
   lock screen
   set rect of myRegion() to rect of me
   positionMyBars
   updateMyValues
   unlock screen
end resizeControl


command positionMyBars
   lock screen
   set the lockUpdates of me to true
   put left of myRegion() into L
   put top of myRegion() into T
   put right of myRegion() into R
   put bottom of myRegion() into B
   put width of myRegion() into W
   put height of myRegion() into H
   put myMargins() into P
   if number of items of P = 1 then put P,P,P,P into P
   put item 1 of P into PL
   put item 2 of P into PT
   put item 3 of P into PR
   put item 4 of P into PB
   if myOrientation() is "vertical" then
      put (W - PL - PR) into D
   else put (H - PT - PB) into D
   put (D - (myBarCount() * myBarSize())) / (myBarCount() - 1) into barSpace
   put myBases() into theBaseList
   put myBars() into theBarList
   put 0,0,0,0 into theRect
   put 1 into N
   repeat for each line theBase in theBaseList
      put line N of theBarList into theBar
      if N = 1 then
         put L + PL into item 1 of theRect
         put T + PT into item 2 of theRect
         if myOrientation() is "vertical" then
            put item 1 of theRect + myBarSize() into item 3 of theRect
            put B - PB into item 4 of theRect
         else
            put R - PR into item 3 of theRect
            put item 2 of theRect + myBarSize() into item 4 of theRect
         end if
      end if
      put round(item 1 of theRect),round(item 2 of theRect),round(item 3 of theRect),round(item 4 of theRect) into theNewRect
      set rect of theBase to theNewRect
      if myOrientation() is "vertical" then
         set bottomLeft of theBar to bottomLeft of theBase
         put rect of theBar into theBarRect
         put item 3 of theNewRect into item 3 of theBarRect
         set rect of theBar to theBarRect
         add (barSpace + myBarSize()) to item 1 of theRect
         add (barSpace + myBarSize()) to item 3 of theRect
      else
         set topLeft of theBar to topLeft of theBase
         put rect of theBar into theBarRect
         put item 4 of theNewRect into item 4 of theBarRect
         set rect of theBar to theBarRect
         add (barSpace + myBarSize()) to item 2 of theRect
         add (barSpace + myBarSize()) to item 4 of theRect
      end if
      add 1 to N
   end repeat
   set the lockUpdates of me to false
   unlock screen
end positionMyBars


command updateMyValues
   lock screen
   put myChartValues() into theData
   put number of items of theData into theItemCount
   put myBars() into myBars
   put myBarCount() into theBarCount
   if theItemCount = 0 or theBarCount = 0 then return "error"
   put myMaxValue() into theMax
   if theMax is empty then put max(theData) into theMax
   if myOrientation() is "vertical" then
      put height of grc 2 of me into D
   else put width of grc 2 of me into D
   -- 
   repeat with N = 1 to max(theItemCount,theBarCount)
      -- DELETE ALL UNEEDED BARS
      if item N of theData is empty then
         repeat (theBarCount - theItemCount)
            put line -1 of myBases() into theBase
            delete theBase
            put line -1 of myBars() into theBar
            delete theBar
         end repeat
         positionMyBars
         exit updateMyValues
      end if
      --
      -- ADD NEW BARS IF NEEDED
      if line N of myBars is empty then
         put line -1 of myBases() into theLastBase
         clone theLastBase
         put it into theNewBase
         put line -1 of myBars() into theLastBar
         clone theLastBar
         put it into theNewBar
         if myOrientation() is "vertical" then
            put bottomRight into prop
         else put bottomLeft into prop
         set bottomLeft of theNewBase to the prop of theLastBase
         set topLeft of theNewBar to the prop of theLastBar
         positionMyBars
      end if
      --
      put line N of myBars() into theBar
      put line N of myBases() into theBase
      put rect of theBase into theRect
      put max(0,min(item N of theData,theMax)) into theValue
      if myOrientation() is "vertical" then
         put item 4 of theRect - round(theValue/theMax*D) into item 2 of theRect
      else put item 1 of theRect + round(theValue/theMax*D) into item 3 of theRect
      set rect of theBar to theRect
      set vis of theBar to (theValue > 0)
   end repeat
   unlock screen
end updateMyValues


-- CHART VALUES
setProp tmChartValues pValue
   -- comma delimited list
   set the tmControlData["chartValues"] of me to pValue
   updateMyValues
end tmChartValues

getProp tmChartValues
   return myChartValues()
end tmChartValues

function myChartValues
   return the tmControlData["chartValues"] of me
end myChartValues


-- MAXIMUM CHART VALUE
setProp tmMaxValue pValue
   set the tmControlData["maxValue"] of me to pValue
   updateMyValues
end tmMaxValue

getProp tmMaxValue
   return myMaxValue()
end tmMaxValue

function myMaxValue
   return the tmControlData["maxValue"] of me
end myMaxValue


-- BAR SIZE
setProp tmBarSize pValue
   set the tmControlData["barSize"] of me to pValue
   positionMyBars
end tmBarSize

getProp tmBarSize
   return myBarSize()
end tmBarSize

function myBarSize
   return the tmControlData["barSize"] of me
end myBarSize


-- FILL COLOR
setProp tmFillColor pValue
   set the tmControlData["fillColor"] of me to pValue
   repeat for each line theBar in myBars()
      set backColor of theBar to pValue
   end repeat
end tmFillColor

getProp tmFillColor
   return myFillColor()
end tmFillColor

function myFillColor
   return the tmControlData["fillColor"] of me
end myFillColor


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   repeat for each line theBase in myBases()
      set backColor of theBase to pValue
   end repeat
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of me
end myBaseColor


-- BASE OPACITY
--------------
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set the tmControlData["baseOpacity"] of me to pValue
   repeat for each line theBase in myBases()
      set blendLevel of theBase to (100 - pValue)
   end repeat
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return the tmControlData["baseOpacity"] of me
end myBaseOpacity


-- MARGINS
setProp tmMargins pValue
   set the tmControlData["margins"] of me to pValue
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   return the tmControlData["margins"] of me
end myMargins


-- ORIENTATION
setProp tmOrientation pValue
   set the tmControlData["orientation"] of me to pValue
   positionMyBars
   updateMyValues
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   return the tmControlData["orientation"] of me
end myOrientation






private function myBars
   local theList
   repeat with N = 1 to number of grcs of me
      put long id of grc N of me into theObj
      get short name of theObj
      if "chart_bar" is in it and "base" is not in it then
         if myOrientation() is "vertical" then
            put "left" into prop
         else put "top" into prop
         put theObj & tab & the prop of theObj & return after theList
      end if
   end repeat
   delete char -1 of theList
   set itemDel to tab
   sort lines of theList numeric by item 2 of each
   split theList by column
   return theList[1]
end myBars


function myBarCount
   return number of lines of myBars()
end myBarCount


private function myBases
   local theList
   repeat with N = 1 to number of grcs of me
      put long id of grc N of me into theObj
      if short name of theObj is not "chart_barbase" then next repeat
      if myOrientation() is "vertical" then
         put "left" into prop
      else put "top" into prop
      put theObj & tab & the prop of theObj & return after theList
   end repeat
   delete char -1 of theList
   set itemDel to tab
   sort lines of theList numeric by item 2 of each
   split theList by column
   return theList[1]
end myBases


private function myRegion
   return long id of control 1 of me
end myRegion
