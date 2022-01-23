script "tmc3_mobile_scroller_lib" with behavior "tmc3_MasterBehavior"
local myMobileID
local thePressedControl, thePressedLoc


on preOpenControl
   updateMyScrollProperties
   if autoCreateMe() then createScroller
end preOpenControl


on closeControl
   if autoRemoveMe() then deleteScroller
end closeControl


--on selectedObjectChanged
--   if (the selObj = long id of the target) then 
--      set itemDel to quote
--      put item 2 of behavior of the target into theStackName
--      put long name of stack theStackName into theLibStack
--      insert script of btn "region selection monitor" of theLibStack into back
--      dispatch "tmStoreScrollingRegionID"
--   end if
--   pass selectedObjectChanged
--end selectedObjectChanged


on resizeControl pNoTableResize
   lock screen
   set lockUpdates of the target to true
   put rect of the target into theRect
   set boundingRect of the target to theRect
   set clipsToRect of the target to true
   set margins of the target to 0
   set vScroll of the target to 0
   tmUpdateScroller "vScroll",0
   set hScroll of the target to 0
   tmUpdateScroller "hScroll",0
   set topLeft of myRegion() to item 1 of theRect,item 2 of theRect
   if myType() contains "table" then
      -- TABLE
      set topLeft of myTable() to topLeft of myRegion()
      if not pNoTableResize then dispatch "resizeControl" to myTable() 
      put myControlExtents() into theRect
      put min(width of the target,(item 3 of theRect - item 1 of theRect)) div 2 into W
      put min(height of the target,(item 4 of theRect - item 2 of theRect)) div 2 into H
   else
      -- NORMAL SCROLLING REGION
      put width of the target div 2 into W
      put height of the target div 2 into H
   end if
   --
   updateMyRegion
   --
   put W,H,W,H into theMargins
   if not myUnboundedVscroll() then
      put 0 into item 2 of theMargins
      put 0 into item 4 of theMargins
   end if
   if not myUnboundedHscroll() then
      put 0 into item 1 of theMargins
      put 0 into item 3 of theMargins
   end if
   set the tmControlData["bounceMargins"] of the target to theMargins
   set margins of the target to theMargins
   if the lockLoc of the target then set boundingRect of the target to empty -- IMPORTANT! SET THIS TO EMPTY ONLY WHEN THE GROUP IS LOCKED
   set lockUpdates of the target to false
   --
   tmUpdateScroller
   if myType() contains "table" then updateMe -- NEED TO FORCE RECTS HERE FOR SOME REASON 
   --
   if onDesktop() and number of lines of the tmText of myTable() = 1 then
      -- DESKTOP WORKAROUND FOR TABLE WITH 1 CELL
      wait 50 millisecs with messages
      set topLeft of myTable() to topLeft of myRegion()
   end if
   unlock screen
end resizeControl


command updateMe
   if myType() contains "table" then
      tmUpdateScroller "rect",rect of the target
      put 0,0,max(width of myTable(),width of the target+1),max(height of myTable(),height of the target+1) into theRect
      tmUpdateScroller "contentRect",theRect
   end if
   --   if long id of the target <> long id of the target then exit updateMe
   --   put myControlMargins() into CM
   --   if CM is empty then put 0,0,0,0 into CM
   --   if number of items of CM = 1 then put CM,CM,CM,CM into CM
   --   -- MANAGE TABLE
   --   if tableCheck() is true and myType() contains "table" then
   --      put long id of grp 1 of the target into myTable
   --      put width of myTable into W
   --      put height of myTable into H
   --      lock screen
   --      set lockUpdates of the target to true
   --      put rect of myRegion() into theRect
   --      put  item 2 of CM + item 2 of theRect + H + item 4 of CM into item 4 of theRect
   --      -- set rect of myRegion() to theRect
   --      updateMyRegion
   --      -- POSITION TABLE
   --      set topLeft of myTable to item 1 of theRect,item 2 of theRect + item 2 of CM
   --      -- RESET CONTENT RECT
   --      -- put 0,0,formattedWidth of the target,formattedHeight of the target into theRect
   --      put max(width of the target + 1,width of myRegion()) into W
   --      put max(height of the target + 1,height of myRegion()) into H
   --      put 0,0,W,H into theRect
   --      tmUpdateScroller "contentRect",theRect
   --      set lockUpdates of the target to false
   --      unlock screen
   --   end if
end updateMe


command updateMyScrollProperties
   -- THE FOLLOWING ORDER IS IMPORTANT!
   set margins of the target to 0
   set vScroll of the target to 0
   set hScroll of the target to 0
   set vScrollbar of the target to false
   set hScrollbar of the target to false
   --
   if onDesktop() then
      set vScrollbar of the target to true
      set hScrollbar of the target to true
      set scrollbarwidth of the target to 0
      set margins of the target to myBounceMargins()
   end if
end updateMyScrollProperties


command updateMyRegion
   local tempLock
   if not the lockUpdates of the target then
      set lockUpdates of the target to true
      put true into tempLock
   end if
   put myControlExtents() into theRect
   put item 3 of theRect - item 1 of theRect into W
   put item 4 of theRect - item 2 of theRect into H
   put item 1 of theRect + max(width of the target,W) into item 3 of theRect
   put item 2 of theRect + max(height of the target,H) into item 4 of theRect
   set rect of myRegion() to theRect
   if tempLock then set lockUpdates of the target to false
end updateMyRegion


command clearScrollingRegion
   if onDesktop() then
      answer "Delete all controls in scrolling region?" with "Delete All" or "Cancel"
      if it is "Cancel" then exit clearScrollingRegion
   end if
   lock screen
   repeat with N = number of controls of the target down to 1
      if short name of control N of the target is among the items of  \
            "scrolling_region_tile,scrolling_region_base" then next repeat
      delete control N of the target
   end repeat
   unlock screen
end clearScrollingRegion


-- DESKTOP MOUSE EVENTS
------------------------
before mouseDown
   getPressedControl
end mouseDown

before mouseMove X,Y
   if onDesktop() then manageMouseMove X,Y
end mouseMove

before mouseUp
   if onDesktop() then prepareDesktopScroll
end mouseUp

before mouseRelease
   if onDesktop() then prepareDesktopScroll
end mouseRelease


-- PLACED CONTROL EVENTS
-------------------------
on controlDown
   
end controlDown

on controlUp
   if onDesktop() and myCanCancelTouches() then prepareDesktopScroll
end controlUp

on controlRelease
   if onDesktop() and myCanCancelTouches() then prepareDesktopScroll
end controlRelease


-- DETERMINE WHICH CONTROL WAS PRESSED
command getPressedControl
   put empty into thePressedControl
   put mouseLoc() into thePressedLoc
   if myCanCancelTouches() is false then  exit getPressedControl -- CONTROL PRESS OVERRIDES REGION SCROLL
   put myTMControlGroupOwner(long id of the target) into thePressedControl
   if tableCheck() is true and the tmControlData["type"] of thePressedControl is "table cell" then \
         put long id of owner of thePressedControl into thePressedControl
   initDesktopScrollVars
end getPressedControl


-- MANAGE CONTROL PRESSED WITHIN SCROLLER
command manageControlHilite
   if thePressedControl is empty then exit manageControlHilite
   if myCanCancelTouches() is false then exit manageControlHilite
   if abs(mouseV() - item 2 of thePressedLoc) > 5 or abs(mouseH() - item 1 of thePressedLoc) > 5 then
      switch the tmControlData["type"] of thePressedControl
         case "simple table group"
         case "template table group"
            set the tmHilitedCell of thePressedControl to empty
            break
         case "button"
         case "segmented control"
            dispatch "deHiliteMe" to thePressedControl
            break
         case "switch"
            dispatch "resetMyThumb" to thePressedControl
            break
         case "slider"
            dispatch "disableDrag" to thePressedControl
            break
      end switch
      put empty into thePressedControl
   end if
end manageControlHilite



-- CREATE MOBILE SCROLLER
command createScroller
   if onDesktop() then exit createScroller
   -- ENABLE 'OUT-OF-BOUNDS' SCROLLING FOR GROUP
   set the unboundedVScroll of the target to myUnboundedVScroll()
   set the unboundedHScroll of the target to myUnboundedHScroll()
   mobileControlCreate "scroller" -- CREATE SCROLLER/STORE ID
   put the result into myMobileId
   tmUpdateScroller -- SET SCROLLER PROPS
end createScroller


command tmUpdateScroller pProp,pValue
   if onDesktop() then exit tmUpdateScroller
   -- SET SINGLE PROP & EXIT
   if pProp is not empty then
      -- if number of items of pValue > 1 then put "(" & pValue & ")" into pValue -- BRACKET MULTI-ITEM VALUE IN PARENS
      mobileControlSet myMobileId, pProp, pValue
      exit tmUpdateScroller
   end if
   -- DEFAULT = CREATE SCROLLER & SET ALL PROPS
   mobileControlSet myMobileId, "rect", rect of the target
   get myContentRect()
   if it is empty or it is "0,0,0,0" then \
         get 0,0,max(width of the target,formattedWidth of the target),max(height of the target,formattedHeight of the target)
   -- ADD EXTRA PIXEL TO CONTENTRECT TO FORCE BOUNCE/SCROLL
   if item 3 of it = width of the target and myOrientation() is "horizontal" then add 1 to item 3 of it
   if item 4 of it = height of the target and myOrientation() is "vertical" then add 1 to item 4 of it
   --
   mobileControlSet myMobileId, "contentRect", it
   mobileControlSet myMobileId, "name", myName()
   mobileControlSet myMobileId, "visible", myVisible()
   mobileControlSet myMobileId, "canBounce", myCanBounce()
   mobileControlSet myMobileId, "scrollingEnabled", myScrollingEnabled()
   mobileControlSet myMobileId, "pagingEnabled", myPagingEnabled()
   mobileControlSet myMobileId, "canScrollToTop", myCanScrollToTop()
   mobileControlSet myMobileId, "canCancelTouches", myCanCancelTouches()
   mobileControlSet myMobileId, "delayTouches", myDelayTouches()
   mobileControlSet myMobileId, "lockDirection", myLockDirection()
   mobileControlSet myMobileId, "vIndicator", myVIndicator()
   mobileControlSet myMobileId, "hIndicator", myHIndicator()
   mobileControlSet myMobileId, "indicatorStyle", myIndicatorStyle()
   mobileControlSet myMobileId, "indicatorInsets", myIndicatorInsets()
   mobileControlSet myMobileId, "vscroll", myVscroll() -- FIX FOR BUG THAT DISABLES CONTROLS PLACED IN SCROLLING GROUP 
end tmUpdateScroller


command deleteScroller
   if onDesktop() then exit deleteScroller
   mobileControlDelete myMobileId
   put empty into myMobileId
end deleteScroller


on scrollerDidScroll pOffsetX, pOffsetY
   lock screen
   set the hScroll of the target to pOffsetX
   set the vScroll of the target to pOffsetY
   manageControlHilite
   unlock screen
   pass scrollerDidScroll
end scrollerDidScroll


on desktopScrollOccurred X,Y
   dispatch "regionDidScroll" to the target with X,Y
   manageControlHilite
   pass desktopScrollOccurred
end desktopScrollOccurred



local xStart, yStart, theLastLoc, theScrollChunks, allowDrag, theScrollID
local hScrollStart, vScrollStart

command initDesktopScrollVars
   cancel item 1 of line lineOffset("runEase",pendingMessages()) of pendingMessages()
   put empty into theLastLoc
   put empty into theScrollChunks
   put mouseH() into xStart
   put mouseV() into yStart
   put hScroll of the target into hScrollStart
   put vScroll of the target into vScrollStart
   put true into allowDrag
end initDesktopScrollVars


command manageMouseMove X,Y
   if not allowDrag then exit manageMouseMove
   lock screen
   set hScroll of the target to hScrollStart + (xStart - X)
   set vScroll of the target to vScrollStart + (yStart - Y)
   dispatch "desktopScrollOccurred" to the target with hScroll of the target - item 1 of myBounceMargins(),vScroll of the target - item 2 of myBounceMargins()
   unlock screen
   if "storeScrollChunks" is not in pendingMessages() then send "storeScrollChunks X,Y" to the target in 100 millisecs
   put X,Y into theLastLoc
end manageMouseMove


on storeScrollChunks pX,pY
   put item 1 of theLastLoc - pX,item 2 of theLastLoc - pY into theScrollChunks
end storeScrollChunks


command prepareDesktopScroll
   put false into allowDrag
   put 4 into xMultiplier
   put 1700 into xDuration
   if abs(item 1 of theScrollChunks) < 100 then
      put 3 into xMultiplier
      put 1000 into xDuration
   end if
   put 4 into yMultiplier
   put 1700 into yDuration
   if abs(item 2 of theScrollChunks) < 100 then
      put 3 into yMultiplier
      put 1000 into yDuration
   end if
   put max(xDuration,yDuration) into pDuration
   put hScroll of the target - (xMultiplier * item 1 of theScrollChunks),vScroll of the target - (xMultiplier * item 2 of theScrollChunks) into pDestScroll
   put the millisecs into theScrollID
   easeScroll long ID of the target, pDestScroll, pDuration
end prepareDesktopScroll





local theScrollStart, theScrollDistance, theStartTime, theEaseID, bounceBackBusy

command easeScroll pObj,pDestScroll,pDuration
   # CANCEL ANY EXISTING EASE MOVEMENT
   cancel item 1 of line lineOffset("runEase",pendingMessages()) of pendingMessages()
   put empty into theEaseID
   put false into bounceBackBusy
   # BEGIN EASE ROUTINE
   runEase pObj,pDestScroll,pDuration
end easeScroll


-- NOTE: HOSTOBJ PARAMETER IS ONLY USED LOCALLY
-- AND SHOULD BE EMPTY WHEN ROUTINE IS FIRST RUN
-- TO INITIALIZE EASE MOVEMENT

command runEase pObj,pDestScroll,pDuration,pHostObj
   # INIT VARIABLES
   if pHostObj = "" then
      put item 1 of line 1 of the executionContexts into pHostObj
      put hScroll of pObj,vScroll of pObj into theScrollStart
      put (item 1 of pDestScroll - item 1 of theScrollStart),(item 2 of pDestScroll - item 2 of theScrollStart) into theScrollDistance
      put millisecs() into theStartTime
   end if
   --
   # TRACK TIME
   put (the millisecs - theStartTime)/pDuration into phi
   put min(phi,1) into phi
   put (2*phi - phi^2) into tEase # EASE OUT
   --
   # MOVE OBJECT
   put item 1 of theScrollStart + round(tEase * item 1 of theScrollDistance) into newHScroll
   put item 2 of theScrollStart + round(tEase * item 2 of theScrollDistance) into newVScroll
   lock screen
   set hScroll of pObj to newHScroll
   set vScroll of pObj to newVScroll
   dispatch "desktopScrollOccurred" to the target with hScroll of the target - item 1 of myBounceMargins(),vScroll of the target - item 2 of myBounceMargins()
   unlock screen
   --
   # REVERSE DIRECTION (BOUNCEBACK) IF END OF SCROLL IS REACHED
   put hScroll of pObj,vScroll of pObj into currScroll
   put 0 into hBounce
   put 0 into vBounce
   if item 1 of currScroll < minHScroll(pObj) then put 1 into hBounce
   if item 1 of currScroll > maxHScroll(pObj) then put -1 into hBounce
   if item 2 of currScroll < minVScroll(pObj) then put 1 into vBounce
   if item 2 of currScroll > maxVScroll(pObj) then put -1 into vBounce
   if (hBounce <> 0 or vBounce <> 0) and not bounceBackBusy then
      send "bounceBack pObj,hBounce,vBounce" to the target in 10 millisecs
      exit runEase
   end if
   --
   # EXIT WHEN OBJECT REACHES ITS DESTINATION
   if ((newHScroll,newVScroll) = pDestScroll) or (phi >= 1) then
      --      put theScrollID
      put empty into theEaseID
      put false into bounceBackBusy
      dispatch "easeScrollDone" to pHostObj with pObj
      exit runEase
   end if
   --
   # LOOP SCRIPT
   send "runEase pObj,pDestScroll,pDuration,pHostObj" to the target in 10 milliseconds
   put the result into theEaseID
end runEase


command bounceBack pObj, hBounce, vBounce
   put true into bounceBackBusy
   put hScroll of pObj,vScroll of pObj into pDestScroll
   if hBounce = 1 then put minHScroll(pObj) into item 1 of pDestScroll
   if hBounce = -1 then put maxHScroll(pObj) into item 1 of pDestScroll
   if vBounce = 1 then put minVScroll(pObj) into item 2 of pDestScroll
   if vBounce = -1 then put maxVScroll(pObj) into item 2 of pDestScroll
   put 500 into pDuration
   runEase pObj,pDestScroll,pDuration
end bounceBack


function minHScroll pObj
   return item 1 of myMarginValues(pObj) 
end minHScroll

function maxHScroll pObj
   if formattedWidth of pObj <= width of pObj then return width of pObj
   return (formattedWidth of pObj - item 3 of myMarginValues(pObj) - width of pObj)
end maxHScroll

function minVScroll pObj
   return item 2 of myMarginValues(pObj)
end minVScroll

function maxVScroll pObj
   if formattedHeight of pObj <= height of pObj then return height of pObj
   return (formattedHeight of pObj - item 4 of myMarginValues(pObj) - height of pObj)
end maxVScroll


function effectiveFormattedHeight
   put 50000 into minV
   put 0 into maxV
   repeat with N = 2 to number of controls of the target
      put min(minV,top of control N of the target) into minV
      put max(maxV,bottom of control N of the target) into maxV
   end repeat
   return item 2 of myMarginValues() + (maxV - minV) + item 4 of myMarginValues()
end effectiveFormattedHeight




function firstHOffset
   put 50000 into minH
   repeat with N = 2 to number of controls of the target
      put min(minH,left of control N of the target) into minH
   end repeat
   return (minH + hScroll of the target - left of the target)
end firstHOffset

function firstVOffset
   put 50000 into minV
   repeat with N = 2 to number of controls of the target
      put min(minV,top of control N of the target) into minV
   end repeat
   return (minV + vScroll of the target - top of the target)
end firstVOffset

function virtualFormattedWidth
   put 50000 into minH
   put 0 into maxH
   repeat with N = 2 to number of controls of the target
      put min(minH,left of control N of the target) into minH
      put max(maxH,right of control N of the target) into maxH
   end repeat
   return item 1 of myMarginValues() + (maxH - minH) + item 3 of myMarginValues() + firstHOffset()
end virtualFormattedWidth

function virtualFormattedHeight
   put 50000 into minV
   put 0 into maxV
   repeat with N = 2 to number of controls of the target
      put min(minV,top of control N of the target) into minV
      put max(maxV,bottom of control N of the target) into maxV
   end repeat
   return item 2 of myMarginValues() + (maxV - minV) + item 4 of myMarginValues() + firstVOffset()
end virtualFormattedHeight

function myMarginValues
   if number of items of margins of the target > 1 then return margins of the target
   repeat 4
      put margins of the target & "," after theValues
   end repeat
   delete last char of theValues
   return theValues
end myMarginValues



------------------------------------------------------------------
# PROPERTIES
------------------------------------------------------------------

# TYPE (READ ONLY)
-------------------
getProp tmControlType
   return myType()
end tmControlType

function myType
   return the tmControlData["type"] of the target
end myType


# ID (READ ONLY)
---------------
getProp tmControlID
   return the short id of the target
end tmControlID


# SCROLLER ID (READ ONLY)
----------------------
getProp tmMobileId
   return myMobileId
end tmMobileId


# TRACKING (READ ONLY)
--------------------
getProp tmTracking
   return mobileControlGet(myMobileId,"tracking")
end tmTracking


# DRAGGING -- READ ONLY
----------
getProp tmDragging
   return mobileControlGet(myMobileId,"dragging")
end tmDragging


# DECELERATING (READ ONLY)
------------------------
getProp tmDecelerating
   return mobileControlGet(myMobileId,"decelerating")
end tmDecelerating


# RECT OF ALL CONTROLS IN REGION
------------------------------
getProp tmControlExtents
   return myControlExtents()
end tmControlExtents

function myControlExtents
   if myType() contains "table" then
      put rect of the target into theRect
      put item 1 of theRect + width of myTable() into item 3 of theRect
      put item 2 of theRect + height of myTable() into item 4 of theRect
      return theRect 
   end if
   --
   put number of lines of the childControlIDs of the target into theControlCount
   if theControlCount = 2 then return rect of the target -- NO PLACED CONTROLS
   --
   put left of the target into L
   put top of the target into T
   put right of the target into R
   put bottom of the target into B
   put myControlMargins() into CE
   repeat for each line theID in the childControlIDs of the target
      put long id of control id theID into theControl
      if the tmControlData["gridTile"] of theControl then next repeat -- EXCLUDE GRID TILE
      if theID = id of myRegion() then next repeat -- EXCLUDE GRID
      if not the vis of theControl then next repeat
      if myType() contains "table" then
         put (left of theControl - item 1 of CE) into L
         put (top of theControl - item 2 of CE) into T
         put (right of theControl + item 3 of CE) into R
         put (bottom of theControl + item 4 of CE) into B
      else
         put min(L,left of theControl - item 1 of CE) into L
         put min(T,top of theControl - item 2 of CE) into T
         put max(R,right of theControl + item 3 of CE) into R
         put max(B,bottom of theControl + item 4 of CE) into B
      end if
   end repeat
   return L,T,R,B
end myControlExtents


-- NAME
--------
setProp tmName pValue
   set name me to pValue
   tmUpdateScroller "name",pValue
end tmName

getProp tmName
   return myName()
end tmName

function myName
   return short name of the target
end myName


-- MARGINS BEYOND RECT OF ALL CONTROLS
--------------------------------------
setProp tmControlMargins pValue
   set the tmControlData["controlMargins"] of the target to pValue
   updateMyRegion
   updateMe
end tmControlMargins

getProp tmControlMargins
   return myControlMargins()
end tmControlMargins

function myControlMargins
   return the tmControlData["controlMargins"] of the target
end myControlMargins


# RECT
------
setProp tmScrollerRect pValue
   set the tmControlData["scrollerRect"] of the target to pValue
   tmUpdateScroller "rect",pValue
end tmScrollerRect

getProp tmScrollerRect
   return myScrollerRect()
end tmScrollerRect

function myScrollerRect
   return the tmControlData["rect"] of the target
end myScrollerRect


# CONTENT RECT
--------------
setProp tmContentRect pValue
   set the tmControlData["contentRect"] of the target to pValue
   tmUpdateScroller "contentRect",pValue
end tmContentRect

getProp tmContentRect
   return myContentRect()
end tmContentRect

function myContentRect
   if onMobile() then
      return mobileControlGet(myMobileId,"contentRect")
   else return the tmControlData["contentRect"] of the target
end myContentRect


# ORIENTATION
-------------
setProp tmOrientation pValue
   set the tmControlData["orientation"] of the target to pValue
   if tableCheck() is true then set the tmControlData["orientation"] of myTable() to pValue
end tmOrientation

getProp tmOrientation
   return myOrientation()
end tmOrientation

function myOrientation
   return the tmControlData["orientation"] of the target
end myOrientation


# SCROLLING ENABLED
------------------
setProp tmScrollingEnabled pValue
   set the tmControlData["scrollingEnabled"] of the target to pValue
   tmUpdateScroller "scrollingEnabled",pValue
end tmScrollingEnabled

getProp tmScrollingEnabled
   return myScrollingEnabled()
end tmScrollingEnabled

function myScrollingEnabled
   return the tmControlData["scrollingEnabled"] of the target
end myScrollingEnabled


# V SCROLL
---------
setProp tmVScroll pValue
   put empty into theOffset
   if onDesktop() then put topMargin of the target into theOffset
   set vScroll of the target to pValue + theOffset
   tmUpdateScroller "vScroll",pValue
end tmVScroll

getProp tmVScroll
   return myVScroll()
end tmVScroll

function myVScroll
   put vScroll of the target - topMargin of the target into theScroll
   if onMobile() then put mobileControlGet(myMobileId,"vScroll") into theScroll
   return theScroll
end myVScroll


# H SCROLL
---------
setProp tmHScroll pValue
   tmUpdateScroller "hScroll",pValue
end tmHScroll

getProp tmHScroll
   return myHScroll() 
end tmHScroll

function myHScroll
   put hScroll of the target into theScroll
   if onMobile() then put mobileControlGet(myMobileId,"hScroll") into theScroll
   return theScroll
end myHScroll


# UNBOUNDED V SCROLL
--------------------
setProp tmUnboundedVScroll pValue
   set the tmControlData["unboundedVScroll"] of the target to pValue
   tmUpdateScroller "unboundedVScroll",pValue
   set the unboundedVScroll of the target to pValue
   resizeControl
   updateMe
end tmUnboundedVScroll

getProp tmUnboundedVScroll
   return myUnboundedVScroll()
end tmUnboundedVScroll

function myUnboundedVScroll
   return the tmControlData["unboundedVScroll"] of the target
end myUnboundedVScroll


# V INDICATOR
------------
setProp tmVIndicator pValue
   set the tmControlData["vIndicator"] of the target to pValue
   tmUpdateScroller "vIndicator",pValue
end tmVIndicator

getProp tmVIndicator
   return myVIndicator()
end tmVIndicator

function myVIndicator
   return the tmControlData["vIndicator"] of the target
end myVIndicator


# H SCROLL
---------
setProp tmHScroll pValue
   -- set the tmControlData["hScroll"] of the target to pValue
   tmUpdateScroller "hScroll",pValue
end tmHScroll

getProp tmHScroll
   return myHScroll()
end tmHScroll

function myHScroll
   return mobileControlGet(myMobileId,"hScroll")
end myHScroll


# UNBOUNDED H SCROLL
--------------------
setProp tmUnboundedHScroll pValue
   set the tmControlData["unboundedHScroll"] of the target to pValue
   tmUpdateScroller "unboundedHScroll",pValue
   set the unboundedHScroll of the target to pValue
   resizeControl
   updateMe
end tmUnboundedHScroll

getProp tmUnboundedHScroll
   return myUnboundedHScroll()
end tmUnboundedHScroll

function myUnboundedHScroll
   return the tmControlData["unboundedHScroll"] of the target
end myUnboundedHScroll


# H INDICATOR
------------
setProp tmHIndicator pValue
   set the tmControlData["hIndicator"] of the target to pValue
   tmUpdateScroller "hIndicator",pValue
end tmHIndicator

getProp tmHIndicator
   return myHIndicator()
end tmHIndicator

function myHIndicator
   return the tmControlData["hIndicator"] of the target
end myHIndicator


# VISIBLE
--------
setProp tmVisible pValue
   set the tmControlData["visible"] of the target to pValue
   tmUpdateScroller "visible",pValue
end tmVisible

getProp tmVisible
   return myVisible()
end tmVisible

function myVisible
   return the tmControlData["visible"] of the target
end myVisible


# CAN BOUNCE
------------
setProp tmCanBounce pValue
   set the tmControlData["canBounce"] of the target to pValue
   tmUpdateScroller "canBounce",pValue
end tmCanBounce

getProp tmCanBounce
   return myCanBounce()
end tmCanBounce

function myCanBounce
   return the tmControlData["canBounce"] of the target
end myCanBounce


# BOUNCE MARGINS (DESKTOP ONLY)
-----------------------------
setProp tmBounceMargins pValue
   set the tmControlData["bounceMargins"] of the target to pValue
end tmBounceMargins

getProp tmBounceMargins
   return myBounceMargins()
end tmBounceMargins

function myBounceMargins
   return the tmControlData["bounceMargins"] of the target
end myBounceMargins


# LOCK DIRECTION
---------------
setProp tmLockDirection pValue
   set the tmControlData["lockDirection"] of the target to pValue
   tmUpdateScroller "lockDirection",pValue
end tmLockDirection

getProp tmLockDirection
   return myLockDirection()
end tmLockDirection

function myLockDirection
   return the tmControlData["lockDirection"] of the target
end myLockDirection


# CAN SCROLL TO TOP
------------------
setProp tmCanScrollToTop pValue
   set the tmControlData["canScrollToTop"] of the target to pValue
   tmUpdateScroller "canScrollToTop",pValue
end tmCanScrollToTop

getProp tmCanScrollToTop
   return myCanScrollToTop()
end tmCanScrollToTop

function myCanScrollToTop
   return the tmControlData["canScrollToTop"] of the target
end myCanScrollToTop


# CAN CANCEL TOUCHES
-------------------
setProp tmCanCancelTouches pValue
   set the tmControlData["canCancelTouches"] of the target to pValue
   tmUpdateScroller "canCancelTouches",pValue
end tmCanCancelTouches

getProp tmCanCancelTouches
   return myCanCancelTouches()
end tmCanCancelTouches

function myCanCancelTouches
   return the tmControlData["canCancelTouches"] of the target
end myCanCancelTouches


# DELAY TOUCHES
---------------
setProp tmDelayTouches pValue
   set the tmControlData["delayTouches"] of the target to pValue
   tmUpdateScroller "delayTouches",pValue
end tmDelayTouches

getProp tmDelayTouches
   return myDelayTouches()
end tmDelayTouches

function myDelayTouches
   return the tmControlData["delayTouches"] of the target
end myDelayTouches


# PAGING ENABLED
---------------
setProp tmPagingEnabled pValue
   set the tmControlData["pagingEnabled"] of the target to pValue
   tmUpdateScroller "pagingEnabled",pValue
end tmPagingEnabled

getProp tmPagingEnabled
   return myPagingEnabled()
end tmPagingEnabled

function myPagingEnabled
   return the tmControlData["pagingEnabled"] of the target
end myPagingEnabled


# INDICATOR STYLE
----------------
setProp tmIndicatorStyle pValue
   set the tmControlData["indicatorStyle"] of the target to pValue
   tmUpdateScroller "indicatorStyle",pValue
end tmIndicatorStyle

getProp tmIndicatorStyle
   return myIndicatorStyle()
end tmIndicatorStyle

function myIndicatorStyle
   return the tmControlData["indicatorStyle"] of the target
end myIndicatorStyle


# INDICATOR INSETS
----------------
setProp tmIndicatorInsets pValue
   set the tmControlData["indicatorInsets"] of the target to pValue
   tmUpdateScroller "indicatorInsets",pValue
end tmIndicatorInsets

getProp tmIndicatorInsets
   return myIndicatorInsets()
end tmIndicatorInsets

function myIndicatorInsets
   return the tmControlData["indicatorInsets"] of the target
end myIndicatorInsets


# DECELERATION RATE
------------------
setProp tmDecelerationRate pValue
   set the tmControlData["decelerationRate"] of the target to pValue
   tmUpdateScroller "decelerationRate",pValue
end tmDecelerationRate

getProp tmDecelerationRate
   return myDecelerationRate()
end tmDecelerationRate

function myDecelerationRate
   return the tmControlData["decelerationRate"] of the target
end myDecelerationRate


# SIMULATED MOMENTUM SCROLLING
------------------------------
setProp tmSimulatedMomentumScrolling pValue
   set the tmControlData["simulatedMomentumScrolling"] of the target to pValue
end tmSimulatedMomentumScrolling

getProp tmSimulatedMomentumScrolling
   return mySimulatedMomentumScrolling()
end tmSimulatedMomentumScrolling

function mySimulatedMomentumScrolling
   return the tmControlData["simulatedMomentumScrolling"] of the target
end mySimulatedMomentumScrolling


# SHOW LAYOUT GRID
-------------------
setProp tmShowGrid pValue
   set the tmControlData["showGrid"] of the target to pValue
   if pValue then
      --      set backPattern of myRegion() to id of myGridTile()
      set blendLevel of myRegion() to 0
      set lineSize of myRegion() to 1
   else
      --      set backPattern of myRegion() to empty
      set blendLevel of myRegion() to 100
      set lineSize of myRegion() to 0
   end if
end tmShowGrid

getProp tmShowGrid
   return myShowGrid()
end tmShowGrid

function myShowGrid
   return the tmControlData["showGrid"] of the target
end myShowGrid


# GUIDE COLOR
--------------
setProp tmGuideColor pValue
   set the tmControlData["guideColor"] of the target to pValue
   set foreColor of myRegion() to pValue
end tmGuideColor

getProp tmGuideColor
   return myGuideColor()
end tmGuideColor

function myGuideColor
   return the tmControlData["guideColor"] of the target
end myGuideColor


# SPECIAL LOCK
-------------
setProp tmLocked pValue
   set the tmControlData["locked"] of the target to pValue
   set lockLoc of the target to pValue
   if pValue then set boundingRect of the target to empty
end tmLocked

getProp tmLocked
   return amLocked()
end tmLocked

function amLocked
   return the tmControlData["locked"] of the target
end amLocked


# AUTO-CREATE SCROLLER UPON OPENING
----------------------------------
setProp tmAutoCreate pValue
   set the tmControlData["autoCreate"] of the target to pValue
end tmAutoCreate

getProp tmAutoCreate
   return autoCreateMe()
end tmAutoCreate

function autoCreateMe
   return the tmControlData["autoCreate"] of the target
end autoCreateMe


# AUTO-REMOVE SCROLLER WHEN CLOSING CONTROL
---------------------------------------------
setProp tmAutoRemove pValue
   set the tmControlData["autoRemove"] of the target to pValue
end tmAutoRemove

getProp tmAutoRemove
   return autoRemoveMe()
end tmAutoRemove

function autoRemoveMe
   return the tmControlData["autoRemove"] of the target
end autoRemoveMe




setProp __TABLE_SPECIFIC__
end __TABLE_SPECIFIC__


-----------------------------------------------
### THE FOLLOWING COMMANDS FOR TABLES ONLY ###
-----------------------------------------------

# ADD CELL
----------
command addCell pName, pIndex, pPosition
   dispatch "addCell" to myTable() with pName, pIndex, pPosition
end addCell 

# DELETE CELL
------------
command deleteCell pIndex
   dispatch "deleteCell" to myTable() with pIndex
end deleteCell



-----------------------------------------------
### THE FOLLOWING PROPERTIES FOR TABLES ONLY ###
-----------------------------------------------

# TEXT CONTENT
---------------
setProp tmText pValue
   if tableCheck() is false then exit tmText
   lock screen
   set the tmText of myTable() to pValue
   resizeControl
   unlock screen
end tmText

getProp tmText
   return myText()
end tmText

function myText
   if tableCheck() is false then return empty
   return the tmText of myTable()
end myText


# AUTO HILITE
-------------
setProp tmAutoHilite pValue
   if tableCheck() is false then exit tmAutoHilite
   set the tmAutoHilite of myTable() to pValue
end tmAutoHilite

getProp tmAutoHilite
   return myAutoHilite()
end tmAutoHilite

function myAutoHilite
   if tableCheck() is false then return empty
   return the tmControlData["autoHilite"] of myTable()
end myAutoHilite


# BASE COLOR
-------------
setProp tmBaseColor pValue
   if tableCheck() is false then exit tmBaseColor
   set the tmBaseColor of myTable() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   if tableCheck() is false then return empty
   return the tmControlData["baseColor"] of myTable()
end myBaseColor


# BASE OPACITY
--------------
setProp tmBaseOpacity pValue
   if tableCheck() is false then exit tmBaseOpacity
   set the tmBaseOpacity of myTable() to pValue
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   if tableCheck() is false then return empty
   return the tmControlData["baseOpacity"] of myTable()
end myBaseOpacity


# LIST BEHAVIOR
setProp tmListBehavior pValue
   if tableCheck() is false then exit tmListBehavior
   set the tmListBehavior of myTable() to pValue
end tmListBehavior

getProp tmListBehavior
   return myListBehavior()
end tmListBehavior

function myListBehavior
   if tableCheck() is false then return empty
   return the tmControlData["listBehavior"] of myTable()
end myListBehavior


# HILITE COLOR
--------------
setProp tmHiliteColor pValue
   if tableCheck() is false then exit tmHiliteColor
   set the tmHiliteColor of myTable() to pValue
end tmHiliteColor

getProp tmHiliteColor
   return myHiliteColor()
end tmHiliteColor

function myHiliteColor
   if tableCheck() is false then return empty
   return the tmControlData["hiliteColor"] of myTable()
end myHiliteColor


# HILITED CELL
-------------
setProp tmHilitedCell pValue
   if tableCheck() is false then exit tmHilitedCell
   set the tmHilitedCell of myTable() to pValue
end tmHilitedCell

getProp tmHilitedCell
   return myHilitedCell()
end tmHilitedCell

function myHilitedCell
   if tableCheck() is false then return empty
   return the tmControlData["hilitedCell"] of myTable()
end myHilitedCell


-- HILITED CELL LABEL
-------------------
setProp tmHilitedCellLabel pValue
   if tableCheck() is false then exit tmHilitedCellLabel
   set the tmHilitedCellLabel of myTable() to pValue
end tmHilitedCellLabel

getProp tmHilitedCellLabel
   return myHilitedCellLabel()
end tmHilitedCellLabel

function myHilitedCellLabel
   if tableCheck() is false then return empty
   return the tmHilitedCellLabel of myTable()
end myHilitedCellLabel


# SEPARATOR COLOR
------------------
setProp tmSeparatorColor pValue
   if tableCheck() is false then exit tmSeparatorColor
   set the tmSeparatorColor of myTable() to pValue
end tmSeparatorColor

getProp tmSeparatorColor
   return mySeparatorColor()
end tmSeparatorColor

function mySeparatorColor
   if tableCheck() is false then return empty
   return the tmControlData["separatorColor"] of myTable()
end mySeparatorColor


-- SHOW SEPARATORS
-------------------
setProp tmShowSeparators pValue
   if tableCheck() is false then exit tmShowSeparators
   set the tmShowSeparators of myTable() to pValue
end tmShowSeparators

getProp tmShowSeparators
   return myShowSeparators()
end tmShowSeparators

function myShowSeparators
   if tableCheck() is false then return empty
   return the tmControlData["showSeparators"] of myTable()
end myShowSeparators


# ALTERNATE ROW COLOR
----------------------
setProp tmAlternateRowColor pValue
   if tableCheck() is false then exit tmAlternateRowColor
   set the tmAlternateRowColor of myTable() to pValue
end tmAlternateRowColor

getProp tmAlternateRowColor
   return myAlternateRowColor()
end tmAlternateRowColor

function myAlternateRowColor
   return the tmControlData["alternateRowColor"] of myTable()
end myAlternateRowColor


# TEXT COLOR
------------
setProp tmTextColor pValue
   if tableCheck() is false then exit tmTextColor
   set the tmTextColor of myTable() to pValue
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   if tableCheck() is false then return empty
   return the tmControlData["textColor"] of myTable()
end myTextColor


# HILITED TEXT COLOR
--------------------
setProp tmHilitedTextColor pValue
   if tableCheck() is false then exit tmHilitedTextColor
   set the tmHilitedTextColor of myTable() to pValue
end tmHilitedTextColor

getProp tmHilitedTextColor
   return myHilitedTextColor()
end tmHilitedTextColor

function myHilitedTextColor
   if tableCheck() is false then return empty
   return the tmControlData["hilitedTextColor"] of myTable()
end myHilitedTextColor


# TEXT SIZE
----------
setProp tmTextSize pValue
   if tableCheck() is false then exit tmTextSize
   set the tmtextSize of myTable() to pValue
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   if tableCheck() is false then return empty
   return the tmControlData["textSize"] of myTable()
end myTextSize


# TEXT HEIGHT
------------
setProp tmTextHeight pValue
   if tableCheck() is false then exit tmTextHeight
   set the tmTextHeight of myTable() to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   if tableCheck() is false then return empty
   return the tmControlData["textHeight"] of myTable()
end myTextHeight


# TEXT ALIGN
------------
setProp tmTextAlign pValue
   if tableCheck() is false then exit tmTextAlign
   set the tmTextAlign of myTable() to pValue
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   if tableCheck() is false then return empty
   return the tmControlData["textAlign"] of myTable()
end myTextAlign


# TEXT STYLE
------------
setProp tmTextStyle pValue
   if tableCheck() is false then exit tmTextStyle
   set the tmTextStyle of myTable() to pValue
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   if tableCheck() is false then return empty
   return the tmControlData["textStyle"] of myTable()
end myTextStyle


# TEXT FONT
-----------
setProp tmTextFont pValue
   if tableCheck() is false then exit tmTextFont
   set the tmTextFont of myTable() to pValue
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   if tableCheck() is false then return empty
   return the tmControlData["textFont"] of myTable()
end myTextFont


# MARGINS
----------
setProp tmMargins pValue
   if tableCheck() is false then exit tmMargins
   set the tmMargins of myTable() to pValue
end tmMargins

getProp tmMargins
   return myMargins()
end tmMargins

function myMargins
   if tableCheck() is false then return empty
   return the tmMargins of myTable()
end myMargins


# FIRST INDENT
-------------
setProp tmFirstIndent pValue
   if tableCheck() is false then exit tmFirstIndent
   set the tmFirstIndent of myTable() to pValue
end tmFirstIndent

getProp tmFirstIndent
   return myFirstIndent()
end tmFirstIndent

function myFirstIndent
   if tableCheck() is false then return empty
   return the tmControlData["firstIndent"] of myTable()
end myFirstIndent


# TEXT OFFSET
-------------
setProp tmTextOffset pValue
   if tableCheck() is false then exit tmTextOffset
   set the tmTextOffset of myTable() to pValue
end tmTextOffset

getProp tmTextOffset
   return myTextOffset()
end tmTextOffset

function myTextOffset
   if tableCheck() is false then return empty
   return the tmControlData["textOffset"] of myTable()
end myTextOffset



--------------------------------------------------------
### THE FOLLOWING PROPERTIES FOR TEMPLATE TABLES ONLY ###
--------------------------------------------------------

# CELL TEMPLATE
---------------
setProp tmCellTemplate pValue
   if templateTableCheck() is false then exit tmCellTemplate
   set the tmControlData["cellTemplate"] of myTable() to pValue
end tmCellTemplate

getProp tmCellTemplate
   return myCellTemplate()
end tmCellTemplate

function myCellTemplate
   if templateTableCheck() is false then return empty
   return the tmControlData["cellTemplate"] of myTable()
end myCellTemplate


# CELL IDs - READ ONLY
---------
getProp tmCellIDs
   return myCellIDs()
end tmCellIDs

function myCellIDs
   if templateTableCheck() is false then return empty
   return the tmCellIDs of myTable()
end myCellIDs


# CELL NAMES - READ ONLY
------------
getProp tmCellNames
   return myCellNames()
end tmCellNames

function myCellNames
   if templateTableCheck() is false then return empty
   return the tmCellNames of myTable()
end myCellNames


# CELLS - READ ONLY
------------
getProp tmCells
   return myCells()
end tmCells

function myCells
   if templateTableCheck() is false then return empty
   return the tmCells of myTable()
end myCells


# CELL COLOR
------------
setProp tmCellColor pValue
   if templateTableCheck() is false then exit tmCellColor
   set the tmCellColor of myTable() to pValue
end tmCellColor

getProp tmCellColor
   return myCellColor()
end tmCellColor

function myCellColor
   if templateTableCheck() is false then return empty
   return the tmCellColor of myTable()
end myCellColor


# HILITE OPACITY
---------------
setProp tmHiliteOpacity pValue
   if templateTableCheck() is false then exit tmHiliteOpacity
   set the tmhiliteOpacity of myTable() to pValue
end tmHiliteOpacity

getProp tmHiliteOpacity
   return myHiliteOpacity()
end tmHiliteOpacity

function myHiliteOpacity
   if templateTableCheck() is false then return empty
   return the tmControlData["hiliteOpacity"] of myTable()
end myHiliteOpacity


# CELL GROUP PADDING
--------------------
setProp tmCellGroupPadding pValue
   if templateTableCheck() is false then exit tmCellGroupPadding
   set the tmCellGroupPadding of myTable() to pValue
end tmCellGroupPadding

getProp tmCellGroupPadding
   return myCellGroupPadding()
end tmCellGroupPadding

function myCellGroupPadding
   if templateTableCheck() is false then return empty
   return the tmControlData["cellGroupPadding"] of myTable()
end myCellGroupPadding







function tableCheck
   if "table" is not in myType() then return false
   if not exists(grp 1 of the target) then return false
   if "table" is not in the tmControlData["type"] of grp 1 of the target then return false
   return true
end tableCheck


function templateTableCheck
   if not tableCheck() then return false
   if "template" is not in myType() then return false
   return true
end templateTableCheck



function groupOwner pObj
   if "group" is not in pObj then return empty
   repeat 50
      put wordOffset("group",pObj) into N
      if N = 0 then return pObj
      delete word 1 to N of pObj
   end repeat
end groupOwner


private function myRegion
   return long ID of control 1 of the target
end myRegion


private function myGridTile
   return long ID of img "scrolling_region_tile" of the target
end myGridTile




private function myTable
   return long id of grp 1 of the target
end myTable
