script "tmc3_simple_gauge_lib" with behavior "tmc3_MasterBehavior"
 
on resizeControl
   lock screen
   lock messages
   put loc of myRegion() into theLoc
   put min(width of me,height of me) div 2 into R
   put item 1 of theLoc - R,item 2 of theLoc - R,item 1 of theLoc + R,item 2 of theLoc + R into theRect
   set rect of myRegion() to theRect
   set loc of myRegion() to theLoc
   set rect of me to rect of myRegion()
   put left of myRegion() into L
   put top of myRegion() into T
   put right of myRegion() into R
   put bottom of myRegion() into B
   put width of myRegion() into W
   put height of myRegion() into H
   set rect of myBase() to rect of myRegion()
   set rect of myFill() to rect of myRegion()
   set rect of myDisplay() to rect of myRegion()
   set textSize of myDisplay() to width of me * myTextScale()
   unlock messages
   unlock screen
end resizeControl


command updateMyValue
   lock screen
   put abs(myEndValue() - myStartValue()) into theRange
   put ((myGaugeValue() - myStartValue())/theRange) into thePercent
   if myStartValue() > myEndValue() then put (1 - thePercent) into thePercent
   put round(thePercent * 360) into theAmount
   if myFillDirection() is "clockwise" then
      put (450 - theAmount) into theStartValue
   else put 90 into theStartValue
   put theAmount into theArcValue
   set startAngle of myFill() to theStartValue
   set arcAngle of myFill() to theArcValue
   set label of myDisplay() to myGaugeValue()
   unlock screen
end updateMyValue


command updateMyColors
   lock screen
   set foreColor of myBase() to myBaseColor()
   set foreColor of myFill() to myFillColor()
   set textColor of myDisplay() to myTextColor()
   unlock screen
end updateMyColors



-- START VALUE
-------------
setProp tmStartValue pValue
   set the tmControlData["startValue"] of me to pValue
   updateMyValue
end tmStartValue

getProp tmStartValue
   return myStartValue()
end tmStartValue

function myStartValue
   return the tmControlData["startValue"] of me
end myStartValue


-- END VALUE
------------
setProp tmEndValue pValue
   set the tmControlData["endValue"] of me to pValue
   updateMyValue
end tmEndValue

getProp tmEndValue
  return myEndValue()
end tmEndValue

function myEndValue
    return the tmControlData["endValue"] of me
end myEndValue


-- GAUGE VALUE
setProp tmGaugeValue pValue
   set the tmControlData["gaugeValue"] of me to pValue
   updateMyValue
end tmGaugeValue

getProp tmGaugeValue
   return myGaugeValue()
end tmGaugeValue

function myGaugeValue
   return the tmControlData["gaugeValue"] of me
end myGaugeValue


-- BASE COLOR
-------------
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   updateMyColors
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of me
end myBaseColor


-- FILL COLOR
------------
setProp tmFillColor pValue
   set the tmControlData["fillColor"] of me to pValue
   updateMyColors
end tmFillColor

getProp tmFillColor
   return myFillColor()
end tmFillColor

function myFillColor
   return the tmControlData["fillColor"] of me
end myFillColor


-- FILL DIRECTION
---------------
setProp tmFillDirection pValue
   set the tmControlData["fillDirection"] of me to pValue
   updateMyValue
end tmFillDirection

getProp tmFillDirection
   return myFillDirection()
end tmFillDirection

function myFillDirection
   return the tmControlData["fillDirection"] of me
end myFillDirection


-- BAR SIZE
------------
setProp tmBarSize pValue
   set the tmControlData["barSize"] of me to pValue
   set lineSize of myBase() to pValue
   set lineSize of myFill() to pValue
end tmBarSize

getProp tmBarSize
   return myBarSize()
end tmBarSize

function myBarSize
   return the tmControlData["barSize"] of me
end myBarSize


-- TEXT COLOR
-------------
setProp tmTextColor pValue
   set the tmControlData["textColor"] of me to pValue
   updateMyColors
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of me
end myTextColor


-- TEXT FONT
------------
setProp tmTextFont pValue
   set textFont of myDisplay() to pValue
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return textFont of myDisplay()
end myTextFont


-- TEXT SIZE
-----------
setProp tmTextSize pValue
   set textSize of myDisplay() to pValue
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return textSize of myDisplay()
end myTextSize


-- TEXT SCALE
-------------
setProp tmTextScale pValue
   set the tmControlData["textScale"] of me to pValue
   resizeControl
end tmTextScale

getProp tmTextScale
   return myTextScale()
end tmTextScale

function myTextScale
   return the tmControlData["textScale"] of me
end myTextScale


-- BASE OPACITY
--------------
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set blendLevel of myBase() to (100 - pValue)
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return (100 - blendLevel of myBase())
end myBaseOpacity




private function myRegion
   return long id of grc "gauge_region" of me
end myRegion

private function myBase
   return long id of grc "gauge_base" of me
end myBase

private function myFill
   return long id of grc "gauge_fill" of me
end myFill

private function myDisplay
   return long id of btn "gauge_display" of me
end myDisplay
