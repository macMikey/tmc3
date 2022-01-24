script "tmc3_swipe_lib" with behavior "tmc3_MasterBehavior"
local hStart, vStart, theSwipeData
local theThreshold
local theDefaultThreshold = 50 -- DEFAULT VALUE


on mouseDown
   if onMobile() then exit mouseDown
   touchStart
end mouseDown

on mouseMove X,Y
   if onMobile() then exit mouseMove
   touchmove "", X, Y
end mouseMove

on mouseUp
   if onMobile() then exit mouseUp
   touchEnd
end mouseUp

on touchStart theID
   get mouseLoc()
   put item 1 of it into hStart
   put item 2 of it into vStart
   if theThreshold is empty then put theDefaultThreshold into theThreshold
end touchStart

on touchmove theID, X, Y
   put empty into theSwipeData
   if Y > vStart and abs(vStart - Y) > theThreshold  then put "down," after theSwipeData
   if Y < vStart and abs(vStart - Y) > theThreshold  then put "up," after theSwipeData
   if X > hStart and abs(hStart - X) > theThreshold  then put "right," after theSwipeData
   if X < hStart and abs(hStart - X) > theThreshold  then put "left," after theSwipeData
   if theSwipeData is not empty then put locToAngle(X,Y,hStart,vStart) & numToChar(161) after theSwipeData
end touchmove

on touchEnd theID
   dispatch "swipe" to me with theSwipeData
end touchEnd

function locToAngle pX,pY,pXorigin,pYorigin
   put atan2(pY - pYorigin,pXorigin - pX) into R
   return round(180+(R*(180/pi)))
end locToAngle

setProp swipeThreshold pValue
   put pValue into theThreshold
end swipeThreshold

getProp swipeThreshold
   get theThreshold
   if it is not empty then return it
   return theDefaultThreshold
end swipeThreshold
