script "tmc3_mobile_text_input_lib" with behavior "tmc3_MasterBehavior"
local myMobileID


on preOpenControl
   if onMobile() then set text of myField() to empty
   if autoCreateMe() then createInput
end preOpenControl


on closeControl
   if autoRemoveMe() then deleteInput
end closeControl


command createInput
   if onDesktop() then exit createInput
   put "input" into theInputType
   if myClass() is "multiline" then put "multiline" into theInputType
   mobileControlCreate theInputType -- CREATE INPUT & STORE ID
   put the result into myMobileID
   set the tmControlData["mobileID"] of me to myMobileID
   tmUpdateInput -- SET INPUT PROPS
end createInput


command tmUpdateInput pProp,pValue
   if not onMobile() then exit tmUpdateInput
   -- SET SINGLE PROP & EXIT
   if pProp is not empty then
      -- if number of items of pValue > 1 then put "(" & pValue & ")" into pValue -- BRACKET MULTI-ITEM VALUE IN PARENS
      mobileControlSet myMobileID, pProp, pValue
      exit tmUpdateInput
   end if
   set the tmControlData["inputRect"] of me to rect of myField()
   -- DEFAULT = CREATE INPUT & SET ALL PROPS
   mobileControlSet myMobileID, "rect", myInputRect()
   mobileControlSet myMobileID, "name", myName()
   mobileControlSet myMobileID, "fontName", myFontName()
   mobileControlSet myMobileID, "fontSize", myFontSize()
   mobileControlSet myMobileID, "minimumFontSize", myFontSize()
   mobileControlSet myMobileID, "backgroundColor", myBackgroundColor()
   mobileControlSet myMobileID, "textColor", myTextColor()
   mobileControlSet myMobileID, "textAlign", myTextAlign()
   mobileControlSet myMobileID, "borderStyle", myBorderStyle()
   mobileControlSet myMobileID, "clearButtonMode", myClearButtonMode()
   mobileControlSet myMobileID, "autoCapitalizationType", myAutoCapitalizationType()
   mobileControlSet myMobileID, "autoCorrectionType", myAutoCorrectionType()
   mobileControlSet myMobileID, "autoClear", myAutoClear()
   mobileControlSet myMobileID, "autoFit", myAutoFit()
   mobileControlSet myMobileID, "keyboardType", myKeyboardType()
   mobileControlSet myMobileID, "keyboardStyle", myKeyboardStyle()
   mobileControlSet myMobileID, "returnKeyType", myReturnKeyType()
   mobileControlSet myMobileID, "manageReturnKey", myManageReturnKey()
   mobileControlSet myMobileID, "contentType", myContentType()
   mobileControlSet myMobileID, "visible", myVisible()
   mobileControlSet myMobileID, "opaque", myOpaque()
   mobileControlSet myMobileID, "enabled", myEnabled()
   -- MULTILINE PROPERTIES
   if myClass() is not "multiline" then exit tmUpdateInput
   mobileControlSet myMobileID, "editable", myEditable()
   mobileControlSet myMobileID, "dataDetectorTypes", myDataDetectorTypes()
   mobileControlSet myMobileID, "canScrollToTop", myCanScrollToTop()
   mobileControlSet myMobileID, "canCancelTouches", myCanCancelTouches()
   mobileControlSet myMobileID, "delayTouches", myDelayTouches()
   mobileControlSet myMobileID, "pagingEnabled", myPagingEnabled()
   mobileControlSet myMobileID, "indicatorStyle", myIndicatorStyle()
   mobileControlSet myMobileID, "hIndicator", myHIndicator()
   mobileControlSet myMobileID, "vIndicator", myVIndicator()
   mobileControlSet myMobileID, "scrollingEnabled", myScrollingEnabled()
   mobileControlSet myMobileID, "decelerationRate", myDecelerationRate()
   mobileControlSet myMobileID, "lockDirection", myLockDirection()
end tmUpdateInput


on inputEndEditing
   set the tmControlData["text"] of me to mobileControlGet(myMobileID,"text")
   pass inputEndEditing
end inputEndEditing


on resizeControl
   lock screen
   set rect of myRegion() to rect of me
   put rect of myRegion() into theRect
   set rect of myBase() to theRect
   -- NEED TO REPLACE HARD-WIRED DIMENSIONS HERE WITH GEOMETRY
   add 8 to item 1 of theRect
   add 8 to item 2 of theRect
   subtract 8 from item 3 of theRect
   subtract 8 from item 4 of theRect
   set rect of myFace() to theRect
   -- INSET LEFT/RIGHT SIDES
   add 8 to item 1 of theRect
   if myClass() is "single line" then add 2 to item 2 of theRect
   subtract 8 from item 3 of theRect
   set rect of myField() to theRect
   --
   set the tmControlData["inputRect"] of me to theRect
   if onMobile() then tmUpdateInput
   unlock screen
end resizeControl


command checkForMultiline pProperty
   if myClass() is not "multiline" then return (pProperty && "cannot be set on this control")
end checkForMultiline


command deleteInput
   if onDesktop() then exit deleteInput
   mobileControlDelete myMobileID
   put empty into myMobileID
end deleteInput

   




------------------------------------------------------------------
# PROPERTIES
------------------------------------------------------------------

# TYPE - (READ ONLY)
------
getProp tmControlType
   return myControlType()
end tmControlType

function myControlType
   return the tmControlData["type"] of me
end myControlType


# CONTROL ID - (READ ONLY)
-----------
getProp tmControlID
   return myControlID()
end tmControlID

function myControlID
   return the short id of me
end myControlID


# CLASS - (READ ONLY)
-------
getProp tmClass
   return myClass()
end tmClass

function myClass
   return the tmControlData["class"] of me
end myClass


-- INPUT ID (READ ONLY)
--------------------
getProp tmMobileID
   return myMobileID
end tmMobileID


-- CONTENT RECT (READ ONLY)
---------------
function myContentRect
   checkForMultiline "myContentRect"
   return mobileControlGet(myMobileID, "contentRect")
end myContentRect


-- EDITING (READ ONLY)
---------------------
getProp tmEditing
   return mobileControlGet(myMobileID, "editing")
end tmEditing


-- TRACKING (READ ONLY)
-----------
getProp tmTracking
   checkForMultiline "tmTracking"
   return mobileControlGet(myMobileID, "tracking")
end tmTracking


-- DRAGGING (READ ONLY)
-----------
getProp tmDragging
   checkForMultiline "tmDragging"
   return mobileControlGet(myMobileID, "dragging")
end tmDragging


-- DECELERATING (READ ONLY)
---------------
getProp tmDecelerating
   checkForMultiline "tmDecelerating"
   return mobileControlGet(myMobileID, "decelerating")
end tmDecelerating


-- NAME
--------
setProp tmName pValue
   set name me to pValue
   tmUpdateInput "name",pValue
end tmName

getProp tmName
   return myName()
end tmName

function myName
   return short name of me
end myName


-- EDITABLE
----------
setProp tmEditable pValue
   checkForMultiline "tmEditable"
   set the tmControlData["editable"] of me to pValue
   tmUpdateInput "editable",pValue
end tmEditable

getProp tmEditable
   return myEditable()
end tmEditable

function myEditable
   return the tmControlData["editable"] of me
end myEditable


-- TEXT
----------
setProp tmText pValue
   -- string
   set the tmControlData["text"] of me to pValue
   tmUpdateInput "text",pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return the tmControlData["text"] of me
end myText


-- UNICODE TEXT
--------------
setProp tmUnicodeText pValue
   -- binary
   set the tmControlData["unicodeText"] of me to pValue
   tmUpdateInput "unicodeText",pValue
end tmUnicodeText

getProp tmUnicodeText
   return myUnicodeText()
end tmUnicodeText

function myUnicodeText
   return the tmControlData["unicodeText"] of me
end myUnicodeText


-- CONTENT TYPE
---------------
setProp tmContentType pValue
   -- plain, password
   set the tmControlData["contentType"] of me to pValue
   tmUpdateInput "contentType",pValue
end tmContentType

getProp tmContentType
   return myContentType()
end tmContentType

function myContentType
   return the tmControlData["contentType"] of me
end myContentType


-- INPUT RECT
----------
setProp tmInputRect pValue
   -- comma separated list of 4 integers
   set the tmControlData["inputRect"] of me to pValue
   tmUpdateInput "rect",pValue
end tmInputRect

getProp tmInputRect
   return myInputRect()
end tmInputRect

function myInputRect
   return the tmControlData["inputRect"] of me
end myInputRect


-- OPAQUE
----------
setProp tmOpaque pValue
   -- true, false
   set the tmControlData["opaque"] of me to pValue
   set opaque of myField() to pValue
   tmUpdateInput "opaque",pValue
end tmOpaque

getProp tmOpaque
   return myOpaque()
end tmOpaque

function myOpaque
   return the tmControlData["opaque"] of me
end myOpaque


-- BASE COLOR
-------------
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return the tmControlData["baseColor"] of me
end myBaseColor


-- FACE COLOR
-------------
setProp tmFaceColor pValue
   set the tmControlData["faceColor"] of me to pValue
   set backColor of myFace() to pValue
end tmFaceColor

getProp tmFaceColor
   return myFaceColor()
end tmFaceColor

function myFaceColor
   return the tmControlData["faceColor"] of me
end myFaceColor


-- BACKGROUND COLOR
---------------------
setProp tmBackgroundColor pValue
   -- name, RGB, RGBA (0 - 255)
   set the tmControlData["backgroundColor"] of me to pValue
   set backColor of myField() to pValue
   tmUpdateInput "backgroundColor",pValue
end tmBackgroundColor

getProp tmBackgroundColor
   return myBackgroundColor()
end tmBackgroundColor

function myBackgroundColor
   return the tmControlData["backgroundColor"] of me
end myBackgroundColor


-- TEXT COLOR
-------------
setProp tmTextColor pValue
   -- name, RGB, RGBA (0 - 255)
   set the tmControlData["textColor"] of me to pValue
   set textColor of myField() to pValue
   tmUpdateInput "textColor",pValue
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of me
end myTextColor


-- FONT NAME
------------
setProp tmFontName pValue
   -- string
   set the tmControlData["fontName"] of me to pValue
   set textFont of myField() to pValue
   tmUpdateInput "fontName",pValue
end tmFontName

getProp tmFontName
   return myFontName()
end tmFontName

function myFontName
   return the tmControlData["fontName"] of me
end myFontName


-- TEXT FONT (SYNONYM FOR tmFontName)
------------
setProp tmTextFont pValue
   set the tmFontName of me to pValue
end tmTextFont

getProp tmTextFont
   return myFontName()
end tmTextFont


-- FONT SIZE
-----------
setProp tmFontSize pValue
   -- integer
   set the tmControlData["fontSize"] of me to pValue
   set textSize of myField() to pValue
   tmUpdateInput "fontSize",pValue
end tmFontSize

getProp tmFontSize
   return myFontSize()
end tmFontSize

function myFontSize
   return the tmControlData["fontSize"] of me
end myFontSize


-- TEXT SIZE (SYNONYM FOR tmFontSize)
------------
setProp tmTextSize pValue
   set the tmFontSize of me to pValue
end tmTextSize

getProp tmTextSize
   return myFontSize()
end tmTextSize


-- MINIMUM FONT SIZE
--------------------
setProp tmMinimumFontSize pValue
   -- integer
   set the tmControlData["minimumFontSize"] of me to pValue
   tmUpdateInput "minimumFontSize",pValue
end tmMinimumFontSize

getProp tmMinimumFontSize
   return myMinimumFontSize()
end tmMinimumFontSize

function myMinimumFontSize
   return the tmControlData["minimumFontSize"] of me
end myMinimumFontSize


-- TEXT ALIGN
------------
setProp tmTextAlign pValue
   -- left, center, right
   set the tmControlData["textAlign"] of me to pValue
   set textAlign of myField() to pValue
   tmUpdateInput "textAlign",pValue
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return the tmControlData["textAlign"] of me
end myTextAlign


-- AUTO FIT
----------
setProp tmAutoFit pValue
   -- true, false
   set the tmControlData["autoFit"] of me to pValue
   tmUpdateInput "autoFit",pValue
end tmAutoFit

getProp tmAutoFit
   return myAutoFit()
end tmAutoFit

function myAutoFit
   return the tmControlData["autoFit"] of me
end myAutoFit


-- AUTO CLEAR
-------------------
setProp tmAutoClear pValue
   -- true, false
   set the tmControlData["autoClear"] of me to pValue
   tmUpdateInput "autoClear",pValue
end tmAutoClear

getProp tmAutoClear
   return myAutoClear()
end tmAutoClear

function myAutoClear
   return the tmControlData["autoClear"] of me
end myAutoClear


-- CLEAR BUTTON MODE
---------------------
setProp tmClearButtonMode pValue
   -- never, while editing, unless editing, always
   set the tmControlData["clearButtonMode"] of me to pValue
   tmUpdateInput "clearButtonMode",pValue
end tmClearButtonMode

getProp tmClearButtonMode
   return myClearButtonMode()
end tmClearButtonMode

function myClearButtonMode
   return the tmControlData["clearButtonMode"] of me
end myClearButtonMode


-- BORDER STYLE
---------------
setProp tmBorderStyle pValue
   -- none, line, bezel, rounded
   set the tmControlData["borderStyle"] of me to pValue
   tmUpdateInput "borderStyle",pValue
end tmBorderStyle

getProp tmBorderStyle
   return myBorderStyle()
end tmBorderStyle

function myBorderStyle
   return the tmControlData["borderStyle"] of me
end myBorderStyle


-- AUTO CAPITALIZATION
---------------------
setProp tmAutoCapitalizationType pValue
   -- none, words, sentences, all characters
   set the tmControlData["autoCapitalizationType"] of me to pValue
   tmUpdateInput "autoCapitalizationType",pValue
end tmAutoCapitalizationType

getProp tmAutoCapitalizationType
   return myAutoCapitalizationType()
end tmAutoCapitalizationType

function myAutoCapitalizationType
   return the tmControlData["autoCapitalizationType"] of me
end myAutoCapitalizationType


-- AUTO CORRECTION
-------------------
setProp tmAutoCorrectionType pValue
   -- default, no, yes
   set the tmControlData["autoCorrectionType"] of me to pValue
   tmUpdateInput "autoCorrectionType",pValue
end tmAutoCorrectionType

getProp tmAutoCorrectionType
   return myAutoCorrectionType()
end tmAutoCorrectionType

function myAutoCorrectionType
   return the tmControlData["autoCorrectionType"] of me
end myAutoCorrectionType


-- MANAGE RETURN KEY
--------------------
setProp tmManageReturnKey pValue
   -- true, false
   set the tmControlData["manageReturnKey"] of me to pValue
   tmUpdateInput "manageReturnKey",pValue
end tmManageReturnKey

getProp tmManageReturnKey
   return myManageReturnKey()
end tmManageReturnKey

function myManageReturnKey
   return the tmControlData["manageReturnKey"] of me
end myManageReturnKey


-- KEYBOARD STYLE
-----------------
setProp tmKeyboardStyle pValue
   -- default, alert (iPhone, iPod only)
   set the tmControlData["keyboardStyle"] of me to pValue
   tmUpdateInput "keyboardStyle",pValue
end tmKeyboardStyle

getProp tmKeyboardStyle
   return myKeyboardStyle()
end tmKeyboardStyle

function myKeyboardStyle
   return the tmControlData["keyboardStyle"] of me
end myKeyboardStyle


-- KEYBOARD TYPE
-----------------
setProp tmKeyboardType pValue
   -- default, alphabet, numeric, url, number, phone, contact, email, decimal
   set the tmControlData["keyboardType"] of me to pValue
   tmUpdateInput "keyboardType",pValue
end tmKeyboardType

getProp tmKeyboardType
   return myKeyboardType()
end tmKeyboardType

function myKeyboardType
   return the tmControlData["keyboardType"] of me
end myKeyboardType


-- RETURNKEY TYPE
-----------------
setProp tmReturnKeyType pValue
   -- default, go, google, join, next, route, search, send, yahoo, done, emergency call
   set the tmControlData["returnKeyType"] of me to pValue
   tmUpdateInput "returnKeyType",pValue
end tmReturnKeyType

getProp tmReturnKeyType
   return myReturnKeyType()
end tmReturnKeyType

function myReturnKeyType
   return the tmControlData["returnKeyType"] of me
end myReturnKeyType


-- SELECTED RANGE
-----------------
setProp tmSelectedRange pValue
   -- start index and length of text
   checkForMultiline "tmSelectedRange"
   set the tmControlData["selectedRange"] of me to pValue
   tmUpdateInput "selectedRange",pValue
end tmSelectedRange

getProp tmSelectedRange
   return mySelectedRange()
end tmSelectedRange

function mySelectedRange
   return the tmControlData["selectedRange"] of me
end mySelectedRange


-- DATA DETECTOR TYPES
----------------------
setProp tmDataDetectorTypes pValue
   -- phone number, calendar event, link, address 
   checkForMultiline "tmDataDetectorTypes"
   set the tmControlData["dataDetectorTypes"] of me to pValue
   tmUpdateInput "dataDetectorTypes",pValue
end tmDataDetectorTypes

getProp tmDataDetectorTypes
   return myDataDetectorTypes()
end tmDataDetectorTypes

function myDataDetectorTypes
   return the tmControlData["dataDetectorTypes"] of me
end myDataDetectorTypes


-- VSCROLL
----------
setProp tmVScroll pValue
   -- integer
   checkForMultiline "tmVScroll"
   tmUpdateInput "vScroll",pValue
end tmVScroll

getProp tmVScroll
   return myVScroll()
end tmVScroll

function myVScroll
   return mobileControlGet(myMobileID,"vScroll")
end myVScroll


-- HSCROLL
----------
setProp tmHScroll pValue
   -- integer
   checkForMultiline "tmHScroll"
   tmUpdateInput "hScroll",pValue
end tmHScroll

getProp tmHScroll
   return myHScroll()
end tmHScroll

function myHScroll
   return mobileControlGet(myMobileID,"hScroll")
end myHScroll


-- CAN BOUNCE
-------------
setProp tmCanBounce pValue
   -- true, false
   checkForMultiline "tmCanBounce"
   set the tmControlData["canBounce"] of me to pValue
   tmUpdateInput "canBounce",pValue
end tmCanBounce

getProp tmCanBounce
   return myCanBounce()
end tmCanBounce

function myCanBounce
   return the tmControlData["canBounce"] of me
end myCanBounce


-- CAN SCROLL TO TOP
--------------------
setProp tmCanScrollToTop pValue
   -- true, false
   checkForMultiline "tmCanScrollToTop"
   set the tmControlData["canScrollToTop"] of me to pValue
   tmUpdateInput "canScrollToTop",pValue
end tmCanScrollToTop

getProp tmCanScrollToTop
   return myCanScrollToTop()
end tmCanScrollToTop

function myCanScrollToTop
   return the tmControlData["canScrollToTop"] of me
end myCanScrollToTop


-- CAN CANCEL TOUCHES
---------------------
setProp tmCanCancelTouches pValue
   -- true, false
   checkForMultiline "tmCanCancelTouches"
   set the tmControlData["canCancelTouches"] of me to pValue
   tmUpdateInput "canCancelTouches",pValue
end tmCanCancelTouches

getProp tmCanCancelTouches
   return myCanCancelTouches()
end tmCanCancelTouches

function myCanCancelTouches
   return the tmControlData["canCancelTouches"] of me
end myCanCancelTouches


-- CAN DELAY TOUCHES
--------------------
setProp tmDelayTouches pValue
   -- true, false
   checkForMultiline "tmDelayTouches"
   set the tmControlData["delayTouches"] of me to pValue
   tmUpdateInput "delayTouches",pValue
end tmDelayTouches

getProp tmDelayTouches
   return myDelayTouches()
end tmDelayTouches

function myDelayTouches
   return the tmControlData["delayTouches"] of me
end myDelayTouches


-- PAGING ENABLED
-----------------
setProp tmPagingEnabled pValue
   -- true, false
   checkForMultiline "tmPagingEnabled"
   set the tmControlData["pagingEnabled"] of me to pValue
   tmUpdateInput "pagingEnabled",pValue
end tmPagingEnabled

getProp tmPagingEnabled
   return myPagingEnabled()
end tmPagingEnabled

function myPagingEnabled
   return the tmControlData["pagingEnabled"] of me
end myPagingEnabled


-- INDICATOR STYLE
-----------------
setProp tmIndicatorStyle pValue
   -- default, white, black
   checkForMultiline "tmIndicatorStyle"
   set the tmControlData["indicatorStyle"] of me to pValue
   tmUpdateInput "indicatorStyle",pValue
end tmIndicatorStyle

getProp tmIndicatorStyle
   return myIndicatorStyle()
end tmIndicatorStyle

function myIndicatorStyle
   return the tmControlData["indicatorStyle"] of me
end myIndicatorStyle


-- INDICATOR INSETS
------------------
setProp tmIndicatorInsets pValue
   -- comma separated list of 4 integers
   checkForMultiline "tmIndicatorInsets"
   set the tmControlData["indicatorInsets"] of me to pValue
   tmUpdateInput "indicatorInsets",pValue
end tmIndicatorInsets

getProp tmIndicatorInsets
   return myIndicatorInsets()
end tmIndicatorInsets

function myIndicatorInsets
   return the tmControlData["indicatorInsets"] of me
end myIndicatorInsets


-- H INDICATOR
--------------
setProp tmHIndicator pValue
   -- true, false
   checkForMultiline "tmHIndicator"
   set the tmControlData["hIndicator"] of me to pValue
   tmUpdateInput "hIndicator",pValue
end tmHIndicator

getProp tmHIndicator
   return myHIndicator()
end tmHIndicator

function myHIndicator
   return the tmControlData["hIndicator"] of me
end myHIndicator


-- V INDICATOR
--------------
setProp tmVIndicator pValue
   -- true, false
   checkForMultiline "tmVIndicator"
   set the tmControlData["vIndicator"] of me to pValue
   tmUpdateInput "vIndicator",pValue
end tmVIndicator

getProp tmVIndicator
   return myVIndicator()
end tmVIndicator

function myVIndicator
   return the tmControlData["vIndicator"] of me
end myVIndicator


-- SCROLLING ENABLED
--------------------
setProp tmScrollingEnabled pValue
   -- true, false
   checkForMultiline "tmScrollingEnabled"
   set the tmControlData["scrollingEnabled"] of me to pValue
   tmUpdateInput "scrollingEnabled",pValue
end tmScrollingEnabled

getProp tmScrollingEnabled
   return myScrollingEnabled()
end tmScrollingEnabled

function myScrollingEnabled
   return the tmControlData["scrollingEnabled"] of me
end myScrollingEnabled


-- DECELERATION RATE
--------------------
setProp tmDecelerationRate pValue
   -- normal, fast, real number
   checkForMultiline "tmDecelerationRate"
   set the tmControlData["decelerationRate"] of me to pValue
   tmUpdateInput "decelerationRate",pValue
end tmDecelerationRate

getProp tmDecelerationRate
   return myDecelerationRate()
end tmDecelerationRate

function myDecelerationRate
   return the tmControlData["decelerationRate"] of me
end myDecelerationRate


-- LOCK DIRECTION
-----------------
setProp tmLockDirection pValue
   -- true, false
   checkForMultiline "tmLockDirection"
   set the tmControlData["lockDirection"] of me to pValue
   tmUpdateInput "lockDirection",pValue
end tmLockDirection

getProp tmLockDirection
   return myLockDirection()
end tmLockDirection

function myLockDirection
   return the tmControlData["lockDirection"] of me
end myLockDirection


-- VISIBLE
----------
setProp tmVisible pValue
   -- true, false
   set the tmControlData["visible"] of me to pValue
   tmUpdateInput "visible",pValue
end tmVisible

getProp tmVisible
   return myVisible()
end tmVisible

function myVisible
   return the tmControlData["visible"] of me
end myVisible


-- ENABLED
----------
setProp tmEnabled pValue
   -- true, false
   set the tmControlData["enabled"] of me to pValue
   tmUpdateInput "enabled",pValue
end tmEnabled

getProp tmEnabled
   return myEnabled()
end tmEnabled

function myEnabled
   return the tmControlData["enabled"] of me
end myEnabled


-- DISABLED
-----------
setProp tmDisabled pValue
   -- true, false
   put not pValue into pValue
   set the tmControlData["enabled"] of me to pValue
   tmUpdateInput "enabled",pValue
end tmDisabled

getProp tmDisabled
   return not myEnabled()
end tmDisabled

function tmDisabled
   return not the tmControlData["enabled"] of me
end tmDisabled


# AUTO-CREATE INPUT UPON OPENING
--------------------------------
setProp tmAutoCreate pValue
   set the tmControlData["autoCreate"] of me to pValue
end tmAutoCreate

getProp tmAutoCreate
   return autoCreateMe()
end tmAutoCreate

function autoCreateMe
   return the tmControlData["autoCreate"] of me
end autoCreateMe


# AUTO-REMOVE INPUT WHEN CLOSING CONTROL
-----------------------------------------
setProp tmAutoRemove pValue
   set the tmControlData["autoRemove"] of me to pValue
end tmAutoRemove

getProp tmAutoRemove
   return autoRemoveMe()
end tmAutoRemove

function autoRemoveMe
   return the tmControlData["autoRemove"] of me
end autoRemoveMe





private function myRegion
   return long id of control 1 of me
end myRegion


private function myBase
   return long id of grc "input_base" of me
end myBase


private function myFace
   return long id of grc "input_face" of me
end myFace


private function myField
   return long id of fld "input_field" of me
end myField
