script "tmc3_navbar_lib" with behavior "tmc3_MasterBehavior"
local navStateOverride


on preOpenControl
   if myAutoPosition() then autoPositionMe
   if the tmControlData["iconType"] of myLeftButton() is "icon" then updateMyButtonIcon "left"
   if the tmControlData["iconType"] of myRightButton() is "icon" then updateMyButtonIcon "right"
end preOpenControl


command autoPositionMe
   if not myAutoPosition() then exit autoPositionMe
   put height of me into H
   put rect of this cd into theRect
   put item 2 of theRect + H into item 4 of theRect
   if myStickyLocation() then
      put top of me into item 2 of theRect
      put bottom of me into item 4 of theRect
   end if
   set rect of me to theRect
end autoPositionMe


command positionMyButton pSide
   put value("my" & pSide & "Button()") into theButton
   if pSide is "left" then set bottomLeft of theButton to bottomLeft of myBase()
   if pSide is "right" then set bottomRight of theButton to bottomRight of myBase()
end positionMyButton


command updateMyButton pSide
   lock screen
   set lockUpdates of me to true
   put long id of control ("nav_" & pSide) of me into theButtonGroup
   put the tmMargins of theButtonGroup into theMargins
   put long id of btn "button_icon" of theButtonGroup into theButtonIcon
   put long id of btn "button_label" of theButtonGroup into theButtonLabel
   --
   if navStateOverride then set the tmControlData[pSide & "NavStyle"] of me to false
   put empty into navStateOverride
   --
   -- SET BUTTON STYLE
   if value("my" & pSide & "NavStyle()") then
      -- NAV STYLE
      set the tmControlData["class"] of theButtonGroup to "iosNav" -- CHANGE CLASS FOR BUTTON BEHAVIOR SCRIPT
      -- REMOVE STROKE
      set the tmStrokeWidth of theButtonGroup to 0
      put "show" & pSide & "Bezel" into bezelProp
      set the tmControlData[bezelProp] of me to false
   else
      --
      -- ANY STYLE
      put (pSide & "NavStyle") into navProp
      set the tmControlData[navProp] of me to false
      set the tmControlData["class"] of theButtonGroup to "inNavBar" -- CHANGE CLASS FOR BUTTON BEHAVIOR SCRIPT
      -- MANAGE STROKE
      put 0 into LS
      if value("myShow" & pSide & "Bezel()") then put 1 into LS
      set the tmStrokeWidth of theButtonGroup to LS
   end if
   --
   -- MANAGE BUTTON LABEL
   put the tmControlData["label"] of theButtonGroup into theLabel
   if theLabel is empty then put space into theLabel
   set label of theButtonLabel to theLabel
   set the tmShowName of theButtonGroup to value("myShow" & pSide & "Label()")
   --
   -- MANAGE BUTTON ICON
   updateMyButtonIcon pSide
   dispatch "positionMyLabel" to theButtonGroup
   --
   -- SIZE/POSITION BUTTON
   
   put formattedWidth of theButtonLabel into theLabelWidth
   if not the vis of theButtonLabel then put 0 into theLabelWidth
   put max(44,theLabelWidth) into theWidth
   put rect of theButtonGroup into theRect
   if pSide is "left" then put item 1 of theRect + theWidth into item 3 of theRect
   if pSide is "right" then put item 3 of theRect - theWidth into item 1 of theRect
   set rect of theButtonGroup to theRect
   dispatch "resizeControl" to theButtonGroup
   positionMyButton pSide
   --
   if environment() is "development" then selectedObjectChanged -- UPDATE EDITOR
   set lockUpdates of me to false
   unlock screen
   unlock screen -- KEEP 2ND UNLOCK FOR NOW, MAY NEED TO REMOVE IF INTERRUPTING CARD TRANSITIONS
end updateMyButton


command updateMyButtonIcon pSide
   lock screen
   put long id of control ("nav_" & pSide) of me into theButtonGroup
   put long id of btn "button_icon" of theButtonGroup into theButtonIcon
   put long id of img 1 of theButtonGroup into theSourceImage
   --
   -- NOTE: MAXICONHEIGHT IS AN ARBITRARY HEIGHT LIMIT FOR ICONS, MAY NEED TO CHANGE
   --
   if the tmIconType of theButtonGroup is "glyph" then
      -- GLYPH
      set icon of theButtonIcon to 0
      set showName of theButtonIcon to true
      if value("my" & pSide & "NavStyle()") then
         put item itemOffset(pSide,"left,right") of (myDefaultLeftNavIcon(),myDefaultRightNavIcon()) into theID
         put myDefaultNavFont() into theFont
      else
         put item itemOffset(pSide,"left,right") of (myDefaultLeftIcon(),myDefaultRightIcon()) into theID
         -- put myDefaultGlyphFont() into theFont
         put the tmControlData["glyphFont"] of theButtonGroup into theFont
      end if
      set the tmControlData["icon"] of theButtonGroup to theID
      set label of theButtonIcon to numToCodepoint(the tmControlData["icon"] of theButtonGroup)
      set the tmControlData["glyphFont"] of theButtonGroup to theFont
      set textFont of theButtonIcon to the tmControlData["glyphFont"] of theButtonGroup
      set the tmControlData["iconColor"] of theButtonGroup to value("my" & pSide &"IconColor()")
      set textColor of theButtonIcon to the tmControlData["iconColor"] of theButtonGroup
      set width of theButtonIcon to formattedWidth of theButtonIcon
      set height of theButtonIcon to min(formattedHeight of theButtonIcon,myMaxIconHeight())
   else
      --IMAGE
      set showName of theButtonIcon to false
      if value("my" & pSide & "NavStyle()") then
         -- USE EMBEDDED NAV ICON
         set the tmShowIcon of theButtonGroup to true
         put "show" & pSide & "Icon" into iconProp
         set the tmControlData[iconProp] of me to true
         put item (the screenPixelScale) of "mediumNavIcon,extrahighNavIcon" into iconData
         set text of theSourceImage to the tmControlData[iconData] of theSourceImage
         set width of theSourceImage to formattedWidth of theSourceImage
         set height of theSourceImage to formattedHeight of theSourceImage
         set icon of theButtonIcon to id of theSourceImage
      else
         -- USE ANY ICON
         put value("myShow" & pSide & "Icon()") into theVis
         if theVis then
            put the tmIcon of theButtonGroup into theID
            if theID is empty then
               put id of theSourceImage into theID
               put item (the screenPixelScale) of "mediumIcon,extrahighIcon" into iconData
               set text of theSourceImage to the tmControlData[iconData] of theSourceImage
               set width of theSourceImage to formattedWidth of theSourceImage
               set height of theSourceImage to formattedHeight of theSourceImage
               set icon of theButtonIcon to theID -- USE EMBEDDED IMAGE (DEFAULT)
            else
               set icon of theButtonIcon to theID -- USE REFERENCED IMAGE
            end if
         end if
      end if
   end if
   -- dispatch "resizeControl" to theButtonGroup
   set loc of theButtonIcon to loc of theButtonGroup
   set the pSide of theButtonIcon to the pSide of theButtonGroup
   unlock screen
end updateMyButtonIcon


on resizeControl
   lock screen
   set lockUpdates of me to true
   put rect of me into theRect
   set rect of myLabel() to theRect -- RESIZE LABEL FIRST TO ALLOW FOR VERTICAL 1 PIXEL BASE OFFSET WORKAROUND
   -- add 1 to item 2 of theRect -- MAY NOT BE NEEDED FOR v6.6+
   set rect of myBase() to theRect
   positionMyButton "left"
   positionMyButton "right"
   set topMargin of myLabel() to height of myBase() - 43
   set lockUpdates of me to false
   unlock screen
end resizeControl


--on resizeControl
--   lock screen
--   set lockUpdates of me to true
--   put rect of me into theRect
--   set rect of myLabel() to theRect -- RESIZE LABEL FIRST TO ALLOW FOR VERTICAL 1 PIXEL BASE OFFSET WORKAROUND
--   -- add 1 to item 2 of theRect -- MAY NOT BE NEEDED FOR v6.6+
--   set rect of myBase() to theRect
--   positionMyButton "left"
--   positionMyButton "right"
--   set topMargin of myLabel() to height of myBase() - 43
--   set lockUpdates of me to false
--   unlock screen
--end resizeControl






-- CONTROL TYPE - READ ONLY
---------------
getProp tmControlType
   return myControlType()
end tmControlType

function myControlType
   return the tmControlData["type"] of me
end myControlType


-- NAV BAR LABEL
setProp tmLabel pValue
   put rect of me into theRect
   put right of myLeftButton() into item 1 of theRect
   put left of myRightButton() into item 3 of theRect
   put effectRate into ER
   set effectRate to 1000
   put myUseTransition() into theTransition
   if theTransition is not "none" then
      put "push " before theTransition
      lock screen for visual effect in rect theRect
   end if
   set label of myLabel() to pValue
   if theTransition is not "none" then unlock screen with visual effect theTransition very fast
   set effectRate to ER
   set the tmControlData["label"] of me to pValue
end tmLabel

getProp tmLabel
   return myLabelText()
end tmLabel

function myLabelText
   return the tmControlData["label"] of me
end myLabelText


-- ICON TYPE
setProp tmIconType pValue
   -- glyph or image
   if pValue is not among the items of "glyph,image" then exit tmIconType
   set the tmControlData["iconType"] of myLeftButton() to pValue
   set the tmControlData["iconType"] of myRightButton() to pValue
   if pValue is "glyph" then put true into navStateOverride
   updateMyButton "left"
   updateMyButton "right"
end tmIconType

getProp tmIconType
   return myIconType()
end tmIconType

function myIconType
   get the tmControlData["iconType"] of myLeftButton()
   if it = the tmControlData["iconType"] of myRightButton() then return it
   return "mixed"
end myIconType


-- LEFT BUTTON LABEL
setProp tmLeftButtonLabel pValue
   set the tmControlData["label"] of myLeftButton() to pValue
   updateMyButton "left"
end tmLeftButtonLabel

getProp tmLeftButtonLabel
   return myLeftButtonLabelText()
end tmLeftButtonLabel

function myLeftButtonLabelText
   return the tmControlData["label"] of myLeftButton()
end myLeftButtonLabelText


-- LEFT NAV STYLE
setProp tmLeftNavStyle pValue
   set the tmControlData["leftNavStyle"] of me to pValue
   updateMyButton "left"
end tmLeftNavStyle

getProp tmLeftNavStyle
   return myLeftNavStyle()
end tmLeftNavStyle

function myLeftNavStyle
   return the tmControlData["leftNavStyle"] of me
end myLeftNavStyle


-- SHOW LEFT LABEL
setProp tmShowLeftLabel pValue
   set the tmControlData["showLeftLabel"] of me to pValue
   updateMyButton "left"
end tmShowLeftLabel

getProp tmShowLeftLabel
   return myShowLeftLabel()
end tmShowLeftLabel

function myShowLeftLabel
   return the tmControlData["showLeftLabel"] of me
end myShowLeftLabel


-- LEFT BUTTON MARGINS
setProp tmLeftMargins pValue
   set the tmControlData["margins"] of myLeftButton() to pValue
   updateMyButton "left"
end tmLeftMargins

getProp tmLeftMargins
   return myLeftMargins()
end tmLeftMargins

function myLeftMargins
   return the tmControlData["margins"] of myLeftButton()
end myLeftMargins


-- LEFT ICON
setProp tmLeftIcon pValue
   if the tmControlData["iconType"] of myLeftButton() is "glyph" then set the tmControlData["defaultLeftIcon"] of me to pValue
   set the tmIcon of myLeftButton() to pValue
   updateMyButton "left"
end tmLeftIcon

getProp tmLeftIcon
   return myLeftIconID()
end tmLeftIcon

function myLeftIconID
   return the tmControlData["icon"] of myLeftButton()
end myLeftIconID


-- SHOW LEFT ICON
setProp tmShowLeftIcon pValue
   set the tmControlData["showLeftIcon"] of me to pValue
   lock screen
   set the tmShowIcon of myLeftButton() to pValue
   if pValue is false then put true into navStateOverride
   updateMyButton "left"
   unlock screen
end tmShowLeftIcon

getProp tmShowLeftIcon
   return myShowLeftIcon()
end tmShowLeftIcon

function myShowLeftIcon
   return the tmControlData["showLeftIcon"] of me
end myShowLeftIcon


-- SHOW LEFT BEZEL
setProp tmShowLeftBezel pValue
   set the tmControlData["showLeftBezel"] of me to pValue
   if pValue is true then put true into navStateOverride
   updateMyButton "left"
end tmShowLeftBezel

getProp tmShowLeftBezel
   return myShowLeftBezel()
end tmShowLeftBezel

function myShowLeftBezel
   return the tmControlData["showLeftBezel"] of me
end myShowLeftBezel


-- LEFT BUTTON VISIBILITY
setProp tmShowLeftButton pValue
   set vis of myLeftButton() to pValue
end tmShowLeftButton

getProp tmShowLeftButton
   return myShowLeftButton()
end tmShowLeftButton

function myShowLeftButton
   return vis of myLeftButton()
end myShowLeftButton


-- RIGHT BUTTON LABEL
setProp tmRightButtonLabel pValue
   set the tmControlData["label"] of myRightButton() to pValue
   updateMyButton "right"
end tmRightButtonLabel

getProp tmRightButtonLabel
   return myRightButtonLabelText()
end tmRightButtonLabel

function myRightButtonLabelText
   return the tmControlData["label"] of myRightButton()
end myRightButtonLabelText


-- RIGHT BUTTON MARGINS
setProp tmRightMargins pValue
   set the tmControlData["margins"] of myRightButton() to pValue
   updateMyButton "right"
end tmRightMargins

getProp tmRightMargins
   return myRightMargins()
end tmRightMargins

function myRightMargins
   return the tmControlData["margins"] of myRightButton()
end myRightMargins


-- RIGHT NAV STYLE
setProp tmRightNavStyle pValue
   set the tmControlData["rightNavStyle"] of me to pValue
   updateMyButton "right"
end tmRightNavStyle

getProp tmRightNavStyle
   return myRightNavStyle()
end tmRightNavStyle

function myRightNavStyle
   return the tmControlData["rightNavStyle"] of me
end myRightNavStyle


-- SHOW RIGHT LABEL
setProp tmShowRightLabel pValue
   set the tmControlData["showRightLabel"] of me to pValue
   updateMyButton "right"
end tmShowRightLabel

getProp tmShowRightLabel
   return myShowRightLabel()
end tmShowRightLabel

function myShowRightLabel
   return the tmControlData["showRightLabel"] of me
end myShowRightLabel


-- RIGHT ICON
setProp tmRightIcon pValue
   if the tmControlData["iconType"] of myRightButton() is "glyph" then set the tmControlData["defaultRightIcon"] of me to pValue
   set the tmIcon of myRightButton() to pValue
   updateMyButton "right"
end tmRightIcon

getProp tmRightIcon
   return myRightIconID()
end tmRightIcon

function myRightIconID
   return the tmControlData["icon"] of myRightButton()
end myRightIconID


-- SHOW RIGHT ICON
setProp tmShowRightIcon pValue
   set the tmControlData["showRightIcon"] of me to pValue
   lock screen
   set the tmShowIcon of myRightButton() to pValue
   if pValue is false then put true into navStateOverride
   updateMyButton "right"
   unlock screen
end tmShowRightIcon

getProp tmShowRightIcon
   return myShowRightIcon()
end tmShowRightIcon

function myShowRightIcon
   return the tmControlData["showRightIcon"] of me
end myShowRightIcon


-- SHOW RIGHT BEZEL
setProp tmShowRightBezel pValue
   set the tmControlData["showRightBezel"] of me to pValue
   if pValue is true then put true into navStateOverride
   updateMyButton "right"
end tmShowRightBezel

getProp tmShowRightBezel
   return myShowRightBezel()
end tmShowRightBezel

function myShowRightBezel
   return the tmControlData["showRightBezel"] of me
end myShowRightBezel


-- RIGHT BUTTON VISIBILITY
setProp tmShowRightButton pValue
   set vis of myRightButton() to pValue
end tmShowRightButton

getProp tmShowRightButton
   return myShowRightButton()
end tmShowRightButton

function myShowRightButton
   return vis of myRightButton()
end myShowRightButton


-- LOCK ICON COLOR
setProp tmLockImageIconColor pValue
   set the tmControlData["lockImageIconColor"] of me to pValue
   set the tmControlData["lockImageIconColor"] of myLeftButton() to pValue
   set the tmControlData["lockImageIconColor"] of myRightButton() to pValue
end tmLockImageIconColor

getProp tmLockImageIconColor
   return myLockImageIconColor()
end tmLockImageIconColor

function myLockImageIconColor
   return the tmControlData["lockImageIconColor"] of me
end myLockImageIconColor


-- MAXIMUM ICON HEIGHT, PREVENTS NAV BUTTON HEIGHT FROM EXCEEDING AVAILABLE SPACE
setProp tmMaxIconHeight pValue
   set the tmControlData["maxIconHeight"] of me to pValue
end tmMaxIconHeight

getProp tmMaxIconHeight
   return myMaxIconHeight()
end tmMaxIconHeight

function myMaxIconHeight
   return the tmControlData["maxIconHeight"] of me
end myMaxIconHeight


-- GLYPH FONT
setProp tmGlyphFont pValue
   set textFont of btn 1 of myLeftButton() to pValue
   set textFont of btn 1 of myRightButton() to pValue
   set the tmControlData["glyphFont"] of me to pValue
   put true into navStateOverride
   updateMyButton "left"
   updateMyButton "right"
end tmGlyphFont

getProp tmGlyphFont
   return myGlyphFont()
end tmGlyphFont

function myGlyphFont
   local theFont
   put textFont of btn 1 of myLeftButton() into theFont
   get textFont of btn 1 of myRightButton()
   if it is empty and theFont is empty then return empty -- NO GLYPH FONTS
   if it = theFont then return theFont
   if it <> theFont then return "mixed" -- MULTIPLE SETTINGS
end myGlyphFont


-- GLYPH SIZE
setProp tmGlyphSize pValue
   set textSize of btn 1 of myLeftButton() to pValue
   set textSize of btn 1 of myRightButton() to pValue
   set the tmControlData["glyphSize"] of me to pValue
   updateMyButton "left"
   updateMyButton "right"
end tmGlyphSize

getProp tmGlyphSize
   return myGlyphSize()
end tmGlyphSize

function myGlyphSize
   get textSize of btn 1 of myLeftButton()
   if textSize of btn 1 of myRightButton() = it then return it
   return empty
end myGlyphSize


-- TEXT FONT
setProp tmTextFont pValue
   set the tmControlData["textFont"] of me to pValue
   set textFont of myLabel() to pValue
   set the tmTextFont of myLeftButton() to pValue
   set the tmTextFont of myRightButton() to pValue
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return the tmControlData["textFont"] of me
end myTextFont


-- TEXT STYLE
setProp tmTextStyle pValue
   set the tmControlData["textStyle"] of me to pValue
   set textStyle of myLabel() to pValue
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return the tmControlData["textStyle"] of me
end myTextStyle


-- TEXT SIZE
setProp tmTextSize pValue
   set the tmControlData["textSize"] of me to pValue
   set textSize of myLabel() to pValue
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return the tmControlData["textSize"] of me
end myTextSize


-- BASE COLOR
setProp tmBaseColor pValue
   set the tmControlData["baseColor"] of me to pValue
   set backColor of myBase() to pValue
end tmBaseColor

getProp tmBaseColor
   return myBaseColor()
end tmBaseColor

function myBaseColor
   return backColor of myBase()
end myBaseColor


-- TEXT COLOR
setProp tmTextColor pValue
   set the tmControlData["textColor"] of me to pValue
   set textColor of myLabel() to pValue
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return the tmControlData["textColor"] of me
end myTextColor


-- LEFT TEXT COLOR
setProp tmLeftTextColor pValue
   set the tmTextColor of myLeftButton() to pValue
end tmLeftTextColor

getProp tmLeftTextColor
   return myLeftTextColor()
end tmLeftTextColor

function myLeftTextColor
   return the tmControlData["textColor"] of myLeftButton()
end myLeftTextColor


-- LEFT ICON COLOR
setProp tmLeftIconColor pValue
   set the tmIconColor of myLeftButton() to pValue
end tmLeftIconColor

getProp tmLeftIconColor
   return myLeftIconColor()
end tmLeftIconColor

function myLeftIconColor
   return the tmIconColor of myLeftButton()
end myLeftIconColor


-- LEFT STROKE COLOR
setProp tmLeftStrokeColor pValue
   set the tmStrokeColor of myLeftButton() to pValue
end tmLeftStrokeColor

getProp tmLeftStrokeColor
   return myLeftStrokeColor()
end tmLeftStrokeColor

function myLeftStrokeColor
   return the tmStrokeColor of myLeftButton()
end myLeftStrokeColor


-- LEFT HILITE COLOR
setProp tmLeftHiliteColor pValue
   set the tmControlData["hiliteColor"] of myLeftButton() to pValue
   set the tmControlData["leftHiliteColor"] of me to pValue
end tmLeftHiliteColor

getProp tmLeftHiliteColor
   return myLeftHiliteColor()
end tmLeftHiliteColor

function myLeftHiliteColor
   return the tmControlData["leftHiliteColor"] of me
end myLeftHiliteColor


# LEFT ICON HOVER COLOR
-----------------------
setProp tmLeftHoverIconColor pValue
   set the tmHoverIconColor of myLeftButton() to pValue
end tmLeftHoverIconColor

getProp tmLeftHoverIconColor
   return myLeftHoverIconColor()
end tmLeftHoverIconColor

function myLeftHoverIconColor
   return the tmHoverIconColor of myLeftButton()
end myLeftHoverIconColor


# LEFT ICON HILITE COLOR
----------------------
setProp tmLeftHiliteIconColor pValue
   set the tmHiliteIconColor of myLeftButton() to pValue
end tmLeftHiliteIconColor

getProp tmLeftHiliteIconColor
   return myLeftHiliteIconColor()
end tmLeftHiliteIconColor

function myLeftHiliteIconColor
   return the tmHiliteIconColor of myLeftButton()
end myLeftHiliteIconColor


-- RIGHT TEXT COLOR
setProp tmRightTextColor pValue
   set the tmTextColor of myRightButton() to pValue
end tmRightTextColor

getProp tmRightTextColor
   return myRightTextColor()
end tmRightTextColor

function myRightTextColor
   return the tmControlData["textColor"] of myRightButton()
end myRightTextColor


-- RIGHT ICON COLOR
setProp tmRightIconColor pValue
   set the tmIconColor of myRightButton() to pValue
end tmRightIconColor

getProp tmRightIconColor
   return myRightIconColor()
end tmRightIconColor

function myRightIconColor
   return the tmIconColor of myRightButton()
end myRightIconColor


-- RIGHT STROKE COLOR
setProp tmRightStrokeColor pValue
   set the tmStrokeColor of myRightButton() to pValue
end tmRightStrokeColor

getProp tmRightStrokeColor
   return myRightStrokeColor()
end tmRightStrokeColor

function myRightStrokeColor
   return the tmStrokeColor of myRightButton()
end myRightStrokeColor


-- RIGHT HILITE COLOR
setProp tmRightHiliteColor pValue
   set the tmControlData["hiliteColor"] of myRightButton() to pValue
   set the tmControlData["rightHiliteColor"] of me to pValue
end tmRightHiliteColor

getProp tmRightHiliteColor
   return myRightHiliteColor()
end tmRightHiliteColor

function myRightHiliteColor
   return the tmControlData["rightHiliteColor"] of me
end myRightHiliteColor


-- RIGHT ICON HOVER COLOR
setProp tmRightHoverIconColor pValue
   set the tmHoverIconColor of myRightButton() to pValue
end tmRightHoverIconColor

getProp tmRightHoverIconColor
   return myRightHoverIconColor()
end tmRightHoverIconColor

function myRightHoverIconColor
   return the tmHoverIconColor of myRightButton()
end myRightHoverIconColor


--  RIGHT ICON HILITE COLOR
setProp tmRightHiliteIconColor pValue
   set the tmHiliteIconColor of myRightButton() to pValue
end tmRightHiliteIconColor

getProp tmRightHiliteIconColor
   return myRightHiliteIconColor()
end tmRightHiliteIconColor

function myRightHiliteIconColor
   return the tmHiliteIconColor of myRightButton()
end myRightHiliteIconColor


-- TEXT HEIGHT
setProp tmTextHeight pValue
   set the tmControlData["textHeight"] of me to pValue
   set textHeight of myLabel() to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return the tmControlData["textHeight"] of me
end myTextHeight


-- TEXT ALIGN -- NOT SET ON NAV BARS SINCE ALWAYS CENTERED
--setProp tmTextAlign pValue
--   set the tmControlData["textAlign"] of me to pValue
--end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return "center"
end myTextAlign


-- BASE OPACITY
setProp tmBaseOpacity pValue
   put min(100,max(pValue,0)) into pValue
   set the tmControlData["baseOpacity"] of me to pValue
   set blendLevel of myBase() to (100 - pValue)
end tmBaseOpacity

getProp tmBaseOpacity
   return myBaseOpacity()
end tmBaseOpacity

function myBaseOpacity
   return (100 - blendLevel of myBase())
end myBaseOpacity


-- DEFAULT LEFT NAV ICON
setProp tmDefaultLeftNavIcon pValue
   set the tmControlData["defaultLeftNavIcon"] of me to pValue
end tmDefaultLeftNavIcon

getProp tmDefaultLeftNavIcon
   return myDefaultLeftNavIcon()
end tmDefaultLeftNavIcon

function myDefaultLeftNavIcon
   return the tmControlData["defaultLeftNavIcon"] of me
end myDefaultLeftNavIcon


-- DEFAULT RIGHT NAV ICON
setProp tmDefaultRightNavIcon pValue
   set the tmControlData["defaultRightNavIcon"] of me to pValue
end tmDefaultRightNavIcon

getProp tmDefaultRightNavIcon
   return myDefaultRightNavIcon()
end tmDefaultRightNavIcon

function myDefaultRightNavIcon
   return the tmControlData["defaultRightNavIcon"] of me
end myDefaultRightNavIcon


-- DEFAULT NAV FONT
setProp tmDefaultNavFont pValue
   set the tmControlData["defaultNavFont"] of me to pValue
   set the tmGlyphFont of myLeftButton() to pValue
   set the tmGlyphFont of myRightButton() to pValue
end tmDefaultNavFont

getProp tmDefaultNavFont
   return myDefaultNavFont()
end tmDefaultNavFont

function myDefaultNavFont
   return the tmControlData["defaultNavFont"] of me
end myDefaultNavFont


-- DEFAULT LEFT ICON
setProp tmDefaultLeftIcon pValue
   set the tmControlData["defaultLeftIcon"] of me to pValue
end tmDefaultLeftIcon

getProp tmDefaultLeftIcon
   return myDefaultLeftIcon()
end tmDefaultLeftIcon

function myDefaultLeftIcon
   return the tmControlData["defaultLeftIcon"] of me
end myDefaultLeftIcon


-- DEFAULT RIGHT ICON
setProp tmDefaultRightIcon pValue
   set the tmControlData["defaultRightIcon"] of me to pValue
end tmDefaultRightIcon

getProp tmDefaultRightIcon
   return myDefaultRightIcon()
end tmDefaultRightIcon

function myDefaultRightIcon
   return the tmControlData["defaultRightIcon"] of me
end myDefaultRightIcon


-- DEFAULT GLYPH FONT
setProp tmDefaultGlyphFont pValue
   set the tmControlData["defaultGlyphFont"] of me to pValue
   set the tmGlyphFont of myLeftButton() to pValue
   set the tmGlyphFont of myRightButton() to pValue
end tmDefaultGlyphFont

getProp tmDefaultGlyphFont
   return myDefaultGlyphFont()
end tmDefaultGlyphFont

function myDefaultGlyphFont
   return the tmControlData["defaultGlyphFont"] of me
end myDefaultGlyphFont


-- USE TRANSITION
setProp tmUseTransition pValue
   if pValue is not among the items of "left,right,none" then exit tmUseTransition
   set the tmControlData["useTransition"] of me to pValue
end tmUseTransition

getProp tmUseTransition
   return myUseTransition()
end tmUseTransition

function myUseTransition
   return the tmControlData["useTransition"] of me
end myUseTransition


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


-- AUTO POSITION
setProp tmAutoPosition pValue
   set the tmControlData["autoPosition"] of me to pValue
   if pValue then autoPositionMe
end tmAutoPosition

getProp tmAutoPosition
   return myAutoPosition()
end tmAutoPosition

function myAutoPosition
   return the tmControlData["autoPosition"] of me
end myAutoPosition


-- STICKY POSITION
setProp tmStickyLocation pValue
   set the tmControlData["stickyLocation"] of me to pValue
end tmStickyLocation

getProp tmStickyLocation
   return myStickyLocation()
end tmStickyLocation

function myStickyLocation
   return the tmControlData["stickyLocation"] of me
end myStickyLocation






private function myRegion
   return long id of grc "navbar_region" of me
end myRegion


private function myBase
   return long id of grc "navbar_base" of me
end myBase


private function myLabel
   return long id of btn "navbar_label" of me
end myLabel


private function myLeftButton
   return long id of grp "nav_left" of me
end myLeftButton


private function myRightButton
   return long id of grp "nav_right" of me
end myRightButton


private function myLeftIcon
   return long id of btn "button_icon" of myLeftButton()
end myLeftIcon


private function myRightIcon
   return long id of btn "button_icon" of myRightButton()
end myRightIcon
