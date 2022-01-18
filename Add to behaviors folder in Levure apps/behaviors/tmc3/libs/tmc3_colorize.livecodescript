script "tmc3_colorize" with behavior "tmc3_MasterBehavior"
command colorizeControls pColor
   put defaultStack into DS
   set defaultStack to the topStack
   lock screen
   repeat with N = 1 to number of controls
      put the tmControlData["type"] of control N into theType
      if theType is empty then next repeat
      if word 1 of name of control N is not in "group,field" then next repeat
      put long id of control N into theControl
      switch theType
         case "field"
            set textColor of theControl to pColor
            break
         case "simple gauge"
            set the tmFillColor of theControl to pColor
            set the tmTextColor of theControl to pColor
            break
         case "tab bar"
            set the tmHiliteIconColor of theControl to pColor
            break
         case "toolbar"
            set the tmIconColor of theControl to pColor
            break
         case "navbar"
            set the tmLeftTextColor of theControl to pColor
            set the tmLeftHiliteColor of theControl to tint(pColor,0.25)
            set the tmLeftIconColor of theControl to pColor
            set the tmLeftHoverIconColor of theControl to pColor
            set the tmLeftHiliteIconColor of theControl to tint(pColor,0.25)
            set the tmRightTextColor of theControl to pColor
            set the tmRightHiliteColor of theControl to tint(pColor,0.25)
            set the tmRightIconColor of theControl to pColor
            set the tmRightHoverIconColor of theControl to pColor
            set the tmRightHiliteIconColor of theControl to tint(pColor,0.25)
            break
         case "stepper"
            set the tmStrokeColor of theControl to pColor
            set the tmIconColor of theControl to pColor
            set the tmHiliteColor of theControl to pColor
            break
         case "page control"
            set the tmFillColor of theControl to pColor
            break
         case "progress bar"
            set the tmFillColor of theControl to pColor
            break
         case "slider"
            set the tmFillColor of theControl to pColor
            break
         case "switch"
            set the tmHiliteColor of theControl to pColor
            break
         case "segmented control"
            set the tmTextColor of theControl to pColor
            set the tmHiliteColor of theControl to pColor
            set the tmTextHiliteColor of theControl to the tmBaseColor of theControl
            break
         case "button"
            set the tmTextColor of theControl to pColor
            set the tmStrokeColor of theControl to pColor
            set the tmIconColor of theControl to pColor
            set the tmHoverIconColor of theControl to pColor
            set the tmHiliteIconColor of theControl to pColor
            if the tmControlData["class"] of theControl is "ios7bezel" then \
                  set the tmStrokeColor of theControl to pColor
            if the tmControlData["class"] of theControl is "ios7nav" then \
                  set the tmIconColor of theControl to pColor
            set the tmHiliteColor of theControl to tint(pColor,0.25)
            break
         case "scrolling region"
            set the tmGuideColor of theControl to pColor
            break
         case "simple chart"
            set the tmFillColor of theControl to pColor
            break
         case "simple table"
            set the tmHiliteColor of theControl to pColor
            break
      end switch
   end repeat
   unlock screen
   set defaultStack to DS
end colorizeControls



-- OPTIONAL
command colorizeCard
   set backColor of this cd of the topStack to random(255),random(255),random(255)
end colorizeCard


function tint pColor, pPercent
   put (1 - pPercent) into thePercent
   put item 1 of pColor into R
   put item 2 of pColor into G
   put item 3 of pColor into B
   put round((255-R)*thePercent)+R,round((255-G)*thePercent)+G,round((255-B)*thePercent)+B into theTint
   return theTint
end tint
