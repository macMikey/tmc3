script "tmc3_stepper_lib" with behavior "tmc3_MasterBehavior"
local allowTracking, thePressedControl


before mouseDown
   put empty into thePressedControl
   if within(myDecrementButton(),mouseLoc()) then put myDecrementButton() into thePressedControl
   if within(myIncrementButton(),mouseLoc()) then put myIncrementButton() into thePressedControl
   if thePressedControl is empty then exit mouseDown
   if the uDisabled of thePressedControl then
      put empty into thePressedControl
      exit mouseDown
   end if
   if not the tmControlData["autoHilite"] of me then exit mouseDown
   set colorOverLay["opacity"] of thePressedControl to myHiliteOpacity()
   updateMyValue
   put true into allowTracking
   cancel item 1 of line lineOffset("tmControlStillPressed",pendingMessages()) of pendingMessages()
   send "tmControlStillPressed" to me in 750 millisecs
   dispatch "controlDown" -- SEND TO POSSIBLE OWNER CONTROL
end mouseDown


on tmControlStillPressed
   if not the tmControlData["autoHilite"] of me then exit tmControlStillPressed
   if thePressedControl is empty or the disabled of thePressedControl then exit tmControlStillPressed
   if allowTracking then updateMyValue
   send "tmControlStillPressed" to me in 100 millisecs
end tmControlStillPressed
   

before mouseMove
   if thePressedControl is empty then exit mouseMove
   if not exists(thePressedControl) then exit mouseMove
   put within(thePressedControl,mouseLoc()) into allowTracking
   if not allowTracking then set colorOverlay["opacity"] of thePressedControl to 0
end mouseMove


before mouseUp
   put false into allowTracking
   if thePressedControl is empty then exit mouseUp
   if the uDisabled of thePressedControl then exit mouseUp
   if not the tmControlData["autoHilite"] of me then exit mouseUp
   if thePressedControl is not empty then
      set colorOverlay["opacity"] of thePressedControl to 0
      put empty into thePressedControl
   end if
   dispatch "controlUp" -- SEND TO POSSIBLE OWNER CONTROL
end mouseUp


before mouseRelease
   put false into allowTracking
   if thePressedControl is empty then exit mouseRelease
   if the uDisabled of thePressedControl then exit mouseRelease
   if thePressedControl is not empty then
      set colorOverlay["opacity"] of thePressedControl to 0
      put empty into thePressedControl
   end if
   dispatch "controlRelease" -- SEND TO POSSIBLE OWNER CONTROL
end mouseRelease


-- IMMEDIATE UNHILITE
command dehiliteMe
   put empty into allowTracking
   set colorOverLay["opacity"] of thePressedControl to 0
   put empty into thePressedControl
end dehiliteMe


command updateMyValue
   put myStepIncrement() into theDelta
   if thePressedControl = myDecrementButton() then multiply theDelta by -1
   set the tmControlData["stepValue"] of me to min(myEndValue(),max(myStepValue()+theDelta,myStartValue()))
   dispatch "stepperValueChanged" to me with the tmControlData["stepValue"] of me
   set the uDisabled of myDecrementButton() to myStepValue() = myStartValue()
   set the uDisabled of myIncrementButton() to myStepValue() = myEndValue()
   set blendLevel of grc "stepper_decicon" of me to item itemOffset(the uDisabled of myDecrementButton(),"false,true") of "0,50"
   set blendLevel of grc "stepper_incicon" of me to item itemOffset(the uDisabled of myIncrementButton(),"false,true") of "0,50"
   set colorOverLay["opacity"] of thePressedControl to item itemOffset(the uDisabled of thePressedControl,"false,true") of "128,0"
end updateMyValue


on resizeControl
   if behavior of me is empty then pass resizeControl
   updateMyButtons
end resizeControl


command updateMyButtons
   lock screen
   set rect of myBase() to rect of me
   put left of myBase() into L
   put top of myBase() into T
   put right of myBase() into R
   put bottom of myBase() into B
   put width of myBase() into W
   put height of myBase() into H
   put item 1 of loc of myBase() into X
   put item 2 of loc of myBase() into Y 
   --
   if W > H then
      set rect of myDecrementButton() to L+1,T+1,(L+W div 2)-1,B-1
      put long id of grc 1 of myDecrementButton() into theGraphic
      put rect of myDecrementButton() into theRect
      add roundRadius of theGraphic to item 3 of theRect
      set rect of theGraphic to theRect
      set rect of myIncrementButton() to (L+W div 2),T+1,R-1,B-1
      put long id of grc 1 of myIncrementButton() into theGraphic
      put rect of myIncrementButton() into theRect
      subtract roundRadius of theGraphic from item 1 of theRect
      set rect of theGraphic to theRect
      set rect of myDivider() to \
            right of myDecrementButton(),top of myBase() + 1,left of myIncrementButton(),bottom of myBase() - 1
   else
      set rect of myIncrementButton() to L+1,T+1,R-1,(T+H div 2)-1
      put long id of grc 1 of myIncrementButton() into theGraphic
      put rect of myIncrementButton() into theRect
      add roundRadius of theGraphic to item 4 of theRect
      set rect of theGraphic to theRect
      set rect of myDecrementButton() to L+1,(T+H div 2),R-1,B-1
      put long id of grc 1 of myDecrementButton() into theGraphic
      put rect of myDecrementButton() into theRect
      subtract roundRadius of theGraphic from item 2 of theRect
      set rect of theGraphic to theRect
      set rect of myDivider() to \
            left of myBase() + 1,bottom of myIncrementButton(),right of myBase() - 1,top of myDecrementButton()
   end if
   set loc of grc "stepper_decicon" of myDecrementButton() to loc of myDecrementButton()
   set loc of grc "stepper_incicon" of myIncrementButton() to loc of myIncrementButton()
   unlock screen
end updateMyButtons



-- START VALUE
setProp tmStartValue pValue
   set the tmControlData["startValue"] of me to pValue
end tmStartValue

getProp tmStartValue
   return myStartValue()
end tmStartValue

function myStartValue
   return the tmControlData["startValue"] of me
end myStartValue


-- END VALUE
setProp tmEndValue pValue
   set the tmControlData["endValue"] of me to pValue
end tmEndValue

getProp tmEndValue
   return myEndValue()
end tmEndValue

function myEndValue
   return the tmControlData["endValue"] of me
end myEndValue


-- STEP INCREMENT
setProp tmStepIncrement pValue
   set the tmControlData["stepIncrement"] of me to pValue
end tmStepIncrement

getProp tmStepIncrement
   return myStartValue()
end tmStepIncrement

function myStepIncrement
   return the tmControlData["stepIncrement"] of me
end myStepIncrement


-- STEP VALUE
setProp tmStepValue pValue
   set the tmControlData["stepValue"] of me to max(myStartValue(),pValue)
end tmStepValue

getProp tmStepValue
   return myStepValue()
end tmStepValue

function myStepValue
   return the tmControlData["stepValue"] of me
end myStepValue


-- ROUND RADIUS
setProp tmRoundRadius pValue
   put max(0,pValue) into pValue
   set roundRadius of myBase() to pValue
   set roundRadius of grc 1 of myDecrementButton() to pValue
   set roundRadius of grc 1 of myIncrementButton() to pValue
   set the tmControlData["roundRadius"] of me to pValue
   resizeControl
end tmRoundRadius

getProp tmRoundRadius
   return myRoundRadius()
end tmRoundRadius

function myRoundRadius
   return the tmControlData["roundRadius"] of me
end myRoundRadius


-- HILITE COLOR
setProp tmHiliteColor pValue
   set colorOverlay["color"] of myDecrementButton() to pValue
   set colorOverlay["color"] of myIncrementButton() to pValue
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   return colorOverlay["color"] of myDecrementButton()
end myHiliteColor


-- HILITE OPACITY
setProp tmHiliteOpacity pValue
   set the tmControlData["hiliteOpacity"] of me to pValue
   set colorOverlay["opacity"] of myDecrementButton() to pValue
   set colorOverlay["opacity"] of myIncrementButton() to pValue
end tmHiliteOpacity

getProp tmHiliteOpacity
   return myHiliteOpacity()
end tmHiliteOpacity

function myHiliteOpacity
   return the tmControlData["hiliteOpacity"] of me
end myHiliteOpacity


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   set backColor of grc "stepper_decface" of me to pValue
   set backColor of grc "stepper_incface" of me to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of me
end myBaseColor


-- BASE OPACITY
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set the tmControlData["baseOpacity"] of me to pValue
   set blendLevel of grc "stepper_decface" of me to (100 - pValue)
   set blendLevel of grc "stepper_incface" of me to (100 - pValue)
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return the tmControlData["baseOpacity"] of me
end myBaseOpacity


-- STROKE COLOR
setProp tmStrokeColor pValue
   set foreColor of myBase() to pValue
   set backColor of myDivider() to pValue
end tmStrokeColor

getProp tmStrokeColor
   return myStrokeColor()
end tmStrokeColor

function myStrokeColor
   return foreColor of myBase()
end myStrokeColor


-- ICON COLOR
setProp tmIconColor pValue
   set foreColor of grc "stepper_decicon" of me to pValue
   set foreColor of grc "stepper_incicon" of me to pValue
end tmIconColor

getProp tmIconColor
   return myIconColor()
end tmIconColor

function myIconColor
   return foreColor of grc "stepper_decicon" of me
end myIconColor


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





private function myBase
   return long id of grc "stepper_base" of me
end myBase


private function myDivider
   return long id of grc "stepper_divider" of me
end myDivider


private function myDecrementButton
   return long id of grp "stepper_decrement" of me
end myDecrementButton


private function myIncrementButton
   return long id of grp "stepper_increment" of me
end myIncrementButton
