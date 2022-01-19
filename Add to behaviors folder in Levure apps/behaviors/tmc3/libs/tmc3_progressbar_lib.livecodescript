script "tmc3_progressbar_lib" with behavior "tmc3_MasterBehavior"
 
on resizeControl
   lock screen
   set rect of myRegion() to rect of the target
   put rect of myRegion() into theRect
   put the tmControlData["padding"] of the target into P
   if number of items of P = 1 then put P,P,P,P into P
   add item 1 of P to item 1 of theRect
   add item 2 of P to item 2 of theRect
   subtract item 3 of P from item 3 of theRect
   subtract item 4 of P from item 4 of theRect
   set rect of myBase() to theRect
   set the tmControlData["orientation"] of the target to "horizontal" -- DEFAULT
   if width of the target < height of the target then set the tmControlData["orientation"] of the target to "vertical"
   updateMyThumbPosition
   unlock screen
end resizeControl


command updateMyThumbPosition
   put abs(myEndValue() - myStartValue()) into maxDist
   put the tmControlData["minimumFillLength"] of the target into minLength
   put the tmControlData["thumbPos"] of the target/maxDist into thePercent
   put rect of myBase() into theRect
   put myFillMargins() into M
   put item 1 of M into ML
   put item 2 of M into MT
   put item 3 of M into MR
   put item 4 of M into MB
   if myOrientation() is "horizontal" then
      -- HORIZONTAL
      add ML to item 1 of theRect
      add MT to item 2 of theRect
      put item 1 of theRect + minLength + ((width of myBase() - ML - MR - minLength) * thePercent) into item 3 of theRect
      subtract MB from item 4 of theRect
   else
      -- VERTICAL
      add ML to item 1 of theRect
      put item 4 of theRect - minLength - ((height of myBase() - MT - MB - minLength) * thePercent) into item 2 of theRect
      subtract MR from item 3 of theRect
      subtract MB from item 4 of theRect
   end if
   set rect of myFill() to theRect
end updateMyThumbPosition



-- START VALUE
setProp tmStartValue pValue
   put max(0,pValue) into pValue -- DON'T ALLOW PROGRESS VALUES LESS THAN 0
   set the tmControlData["startValue"] of the target to pValue
   updateMyThumbPosition
end tmStartValue

getProp tmStartValue
   return myStartValue()
end tmStartValue

function myStartValue
   return the tmControlData["startValue"] of the target
end myStartValue


-- END VALUE
setProp tmEndValue pValue
   put max(0,pValue) into pValue -- DON'T ALLOW PROGRESS VALUES LESS THAN 0
   set the tmControlData["endValue"] of the target to pValue
   updateMyThumbPosition
end tmEndValue

getProp tmEndValue
  return myEndValue()
end tmEndValue

function myEndValue
    return the tmControlData["endValue"] of the target
end myEndValue


-- THUMB POSITION
setProp tmThumbPos pValue
   put max(0,pValue) into pValue
   set the tmControlData["thumbPos"] of the target to min(the tmControlData["endValue"] of the target,max(the tmControlData["startValue"] of the target,pValue))
   updateMyThumbPosition
end tmThumbPos

getProp tmThumbPos
   return myThumbPos()
end tmThumbPos

function myThumbPos
   return the tmControlData["thumbPos"] of the target
end myThumbPos


-- BASE SIZE
setProp tmBaseSize pValue
   if myOrientation() is "horizontal" then
      set height of myBase() to pValue
      set height of myFill() to pValue
      --      set height of myTrans() to pValue + 2
   else
      set width of myBase() to pValue
      set width of myFill() to pValue
      --      set width of myTrans() to pValue + 2
   end if
   set roundRadius of myBase() to pValue
   set roundRadius of myFill() to pValue
   set the tmControlData["baseSize"] of the target to pValue
   resizeControl
end tmBaseSize

getProp tmBaseSize
   return myBaseSize()
end tmBaseSize

function myBaseSize
  return the tmControlData["baseSize"] of the target
end myBaseSize


-- BASE COLOR
setProp tmBaseColor pValue
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


-- FILL COLOR
setProp tmFillColor pValue
   set backColor of myFill() to pValue
end tmFillColor

getProp tmFillColor
   return myFillColor()
end tmFillColor

function myFillColor
   return backColor of myFill()
end myFillColor


-- FILL MARGINS
setProp fillMargins pValue
   set the tmControlData["fillMargins"] of the target to pValue
end fillMargins

getProp fillMargins
   return myFillMargins()
end fillMargins

function myFillMargins
   return the tmControlData["fillMargins"] of the target
end myFillMargins


-- ORIENTATION
setProp tmOrientation pValue
   set the tmControlData["orientation"] of the target to pValue
   lock screen
   put width of the target into W
   put height of the target into H
   if (pValue is "horizontal" and H > W) or (pValue is "vertical" and W > H) then
      set width of the target to H
      set height of the target to W
   end if
   updateMyThumbPosition
   unlock screen
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   if width of the target >= height of the target then return "horizontal"
   return "vertical"
end myOrientation


-- FILL MARGINS
setProp tmFillMargins pValue
   set the tmControlData["fillMargins"] of the target to pValue
end tmFillMargins

getProp tmFillMargins
   return the tmControlData["fillMargins"] of the target
end tmFillMargins

function myFillMargins
   put the tmControlData["fillMargins"] of the target into M
   if M is empty then put 0 into M
   if number of items of M = 1 then put M,M,M,M into M
   return M
end myFillMargins


-- ROUND RADIUS
setProp tmRoundRadius pValue
   set roundRadius of myBase() to pValue
   set roundRadius of myFill() to pValue
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return roundRadius of myBase()
end myRoundRadius


-- DEFAULT SIZE
setProp tmDefaultSize pValue
   set the tmControlData["defaultSize"] of the target to max(2,pValue)
end tmDefaultSize

getProp tmDefaultSize
   return myDefaultSize()
end tmDefaultSize

function myDefaultSize
   return the tmControlData["defaultSize"] of the target
end myDefaultSize



private function myBase
   return long id of grc "progress_base" of the target
end myBase

private function myFill
   return long id of grc "progress_fill" of the target
end myFill

private function myRegion
   return long id of grc "progress_region" of the target
end myRegion
