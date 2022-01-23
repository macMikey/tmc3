script "tmc3_region_selection_monitor" with behavior "tmc3_MasterBehavior"
local theScrollingControl

on selectedObjectChanged
   if theScrollingControl is empty then pass selectedObjectChanged
   if not exists(theScrollingControl) then
      put empty into theScrollingControl
      pass selectedObjectChanged
   end if
   --
   if the selObj <> theScrollingControl then
      -- LOCK
      set lockLoc of theScrollingControl to true
      set boundingRect of theScrollingControl to empty
      put value("myRegion()",theScrollingControl) into theBaseObj
      put value("myControlExtents()",theScrollingControl) into theExtents
      set rect of theBaseObj to theExtents
      set margins of theScrollingControl to value("myBounceMargins()",theScrollingControl)
      set the vScrollbar of theScrollingControl to value("myUnboundedVscroll()",theScrollingControl)
      set the hScrollbar of theScrollingControl to value("myUnboundedHscroll()",theScrollingControl)
      send "tmRemoveSelectionMonitor" to the target in 1 millisec
      pass selectedObjectChanged
   end if
   --
   if not the tmLocked of theScrollingControl then
      -- UNLOCK
      set margins of theScrollingControl to 0
      set lockLoc of theScrollingControl to false
   end if
   pass selectedObjectChanged
end selectedObjectChanged


on tmStoreScrollingControlID
   if the selObj is empty then exit tmStoreScrollingControlID
   put long id of the selObj into theScrollingControl
end tmStoreScrollingControlID


command tmRemoveSelectionMonitor
   put empty into theScrollingControl
   remove script of the target from back
end tmRemoveSelectionMonitor
