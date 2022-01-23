script "tmc3_slider_lib" with behavior "tmc3_MasterBehavior"
local allowTracking


before mouseDown
   put true into allowTracking
end mouseDown


before mouseMove X,Y
   if not allowTracking then exit mouseMove
   lock screen
   lock messages
   if myOrientation() is "horizontal" then
      -- HORIZONTAL
      set loc of myThumb() to max(left of myBase(),min(X,right of myBase())),item 2 of loc of myThumb()
   else
      -- VERTICAL
      set loc of myThumb() to item 1 of loc of myThumb(),max(top of myBase(),min(Y,bottom of myBase()))
   end if
   -- SLIDER FILL
   if myFill() is not empty then
      put rect of myFill() into theRect
      if myOrientation() is "horizontal" then put item 1 of loc of myThumb() into item 3 of theRect
      if myOrientation() is "vertical" then put item 2 of loc of myThumb() into item 2 of theRect
      set rect of myFill() to theRect
   end if
   unlock messages
   unlock screen
   put thumbSliderPercent(myOrientation()) into thePercent
   if myStartValue() > myEndValue() then put (1 - thePercent) into thePercent
   if myOrientation() is "vertical" then put (1 - thePercent) into thePercent
   put round(abs(myEndValue() - myStartValue()) * thePercent) + myStartValue() into thePos
   -- EXIT IF THUMB REACHES EXTENTS OF SLIDER *AND* CURRENT THUMBPOS IS MINNED/MAXXED OUT
   if thePos = the tmControlData["thumbPos"] of the target and (thePos = myStartValue() or thePos = myEndValue()) then exit mouseMove
   set the tmControlData["thumbPos"] of the target to thePos
   --
   dispatch "sliderDrag" to the target with thePos
end mouseMove


before mouseUp
   put false into allowTracking
end mouseUp


before mouseRelease
   put false into allowTracking
end mouseRelease


command disableDrag
   put false into allowTracking
end disableDrag


on resizeControl
   lock screen
   lock messages
   set rect of myRegion() to rect of the target
   put left of myRegion() into L
   put top of myRegion() into T
   put right of myRegion() into R
   put bottom of myRegion() into B
   put width of myRegion() into W
   put height of myRegion() into H
   put myThumbMargins() into M
   put item 1 of M into ML
   put item 2 of M into MT
   put item 3 of M into MR
   put item 4 of M into MB
   put width of myThumb() into thumbW
   put height of myThumb() into thumbH
   put max(thumbW,thumbH) into thumbMax
   put min(thumbW,thumbH) into thumbMin
   put the tmControlData["thumbPos"] of the target/abs(myEndValue() - myStartValue()) into thePercent
   if myStartValue() > myEndValue() then put (1 - thePercent) into thePercent
   -- ASSUME RECTANGULAR THUMB IS ALWAYS ORIENTED PERPENDICULAR TO BASE
   put thumbMin div 2 into minW
   if H <= W then
      -- HORIZONTAL
      set rect of myBase() to L+minW+ML,T,R-minW-MR,T+myBaseSize()
      set loc of myBase() to loc of the target
      set width of myThumb() to thumbMin
      set height of myThumb() to thumbMax
      set loc of myThumb() to left of myBase() + (width of myBase()*thePercent),item 2 of loc of myBase()
      if myFill() is not empty then set rect of myFill() to left of myBase(),top of myBase(),item 1 of loc of myThumb(),bottom of myBase()
      set the tmControlData["orientation"] of the target to "horizontal"
   else
      -- VERTICAL
      set rect of myBase() to L,T+minW+MT,L+myBaseSize(),B
      set loc of myBase() to loc of the target
      set width of myThumb() to thumbMax
      set height of myThumb() to thumbMin
      set loc of myThumb() to item 1 of loc of myBase(),bottom of myBase() - (height of myBase()*thePercent)
      if myFill() is not empty then set rect of myFill() to left of myBase(),item 2 of loc of myThumb(),right of myBase(),bottom of myBase()
      set the tmControlData["orientation"] of the target to "vertical"
   end if
   unlock messages
   unlock screen
end resizeControl


command updateMyThumbPosition
   -- THUMB MARGINS
   put myThumbMargins() into M
   put item 1 of M into TML
   put item 2 of M into TMT
   put item 3 of M into TMR
   put item 4 of M into TMB
   -- FILL MARGINS
   put myFillMargins() into M
   put item 1 of M into FML
   put item 2 of M into FMT
   put item 3 of M into FMR
   put item 4 of M into FMB
   --
   put abs(myEndValue() - myStartValue()) into maxDist
   put the tmControlData["minimumBarLength"] of the target into minLength
   put the tmControlData["thumbPos"] of the target/maxDist into thePercent
   put rect of myBase() into theRect
   put the tmControlData["thumbPos"] of the target - myStartValue() into thePos
   put loc of myBase() into theLoc
   --
   if myOrientation() is "horizontal" then
      -- THUMB - HORIZONTAL
      put baseR() - baseL() - TML - TMR into fullDist
      put baseL() + TML + round(thePos/maxDist*fullDist) into item 1 of theLoc
      -- FILL
      add FML to item 1 of theRect
      add FMT to item 2 of theRect
      put item 1 of theRect + minLength + ((width of myBase() - FML - FMR - minLength) * thePercent) into item 3 of theRect
      subtract FMB from item 4 of theRect
   else
      -- THUMB - VERTICAL
      put baseB() - baseT() - TMT - TMB into fullDist
      put baseB() - TMB - round(thePos/maxDist*fullDist) into item 2 of theLoc
      -- FILL
      add FML to item 1 of theRect
      put item 4 of theRect - minLength - ((height of myBase() - FMT - FMB - minLength) * thePercent) into item 2 of theRect
      subtract FMR from item 3 of theRect
      subtract FMB from item 4 of theRect
   end if
   set loc of myThumb() to theLoc
   set rect of myFill() to theRect
   --
   dispatch "sliderDrag" to the target with myThumbPos()
end updateMyThumbPosition


function thumbSliderPercent pOrientation
   put 0 into tPercent
   if pOrientation is "horizontal" then
      -- HORIZONTAL
      put baseR() - baseL() into maxDist
      if maxDist > 0 then
         put (item 1 of loc of myThumb() - baseL())/maxDist into thePercent
      end if
   else
      -- VERTICAL
      put baseB() - baseT() into maxDist
      if maxDist > 0 then
         put (item 2 of loc of myThumb() - baseT())/maxDist into thePercent
      end if
   end if
   return thePercent
end thumbSliderPercent




-- START VALUE
setProp tmStartValue pValue
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
   set the tmControlData["thumbPos"] of the target to min(myEndValue(),max(myStartValue(),pValue))
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
   else
      set width of myBase() to pValue
      set width of myFill() to pValue
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
   resizeControl
   unlock screen
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   if width of the target >= height of the target then return "horizontal"
   return "vertical"
end myOrientation


-- THUMB MARGINS
setProp tmThumbMargins pValue
   set the tmControlData["thumbMargins"] of the target to pValue
end tmThumbMargins

getProp tmThumbMargins
   return the tmControlData["thumbMargins"] of the target
end tmThumbMargins

function myThumbMargins
   put the tmControlData["thumbMargins"] of the target into M
   if M is empty then put 0 into M
   if number of items of M = 1 then put M,M,M,M into M
   return M 
end myThumbMargins


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




function baseL
   return item 1 of rect of myBase()
end baseL

function baseT
   return item 2 of rect of myBase()
end baseT

function baseR
   return item 3 of rect of myBase()
end baseR
         
function baseB
   return item 4 of rect of myBase()
end baseB




-- COMPONENT REFERENCES

private function myRegion
   return long id of grc "slider_region" of the target
end myRegion

private function myBase
   return long id of grc "slider_base" of the target
end myBase

private function myFill
   return long id of grc "slider_fill" of the target
end myFill

private function myThumb
   if exists(grp "slider_thumb" of the target) then return long id of grp "slider_thumb" of the target
   return long id of grc "slider_thumb" of the target
end myThumb
