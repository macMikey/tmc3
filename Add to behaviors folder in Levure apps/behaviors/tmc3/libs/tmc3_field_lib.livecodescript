script "tmc3_field_lib" with behavior "tmc3_MasterBehavior"
-- TEXT CONTENT
setProp tmText pValue
   set text of the target to pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return text of the target
end myText


-- HTML TEXT
setProp tmHTMLText pValue
   set htmlText of the target to pValue
end tmHTMLText

getProp tmText
   return myHTMLText()
end tmText

function myText
   return the htmlText of the target
end myText


-- LOCKED TEXT
setProp tmLockText pValue
   set the lockText of the target to pValue
end tmLockText

getProp tmLockText
   return myLockText()
end tmLockText

function myLockText
   return the lockText of the target
end myLockText


-- TEXT SIZE
setProp tmTextSize pValue
   set textSize of the target to pValue
   set textSize of char 1 to -1 of the target to empty
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return effective textSize of the target
end myTextSize


-- TEXT HEIGHT
setProp tmTextHeight pValue
   set textHeight of the target to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return effective textHeight of the target
end myTextHeight


-- TEXT COLOR
setProp tmTextColor pValue
   set textColor of the target to pValue
   set textColor of char 1 to -1 of the target to empty
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return effective textColor of the target
end myTextColor


-- TEXT STYLE
setProp tmTextStyle pValue
   set textStyle of the target to pValue
   set textStyle of char 1 to -1 of the target to empty
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return effective textStyle of the target
end myTextStyle


-- TEXT FONT
setProp tmTextFont pValue
   set textFont of the target to pValue
   set textFont of char 1 to -1 of the target to empty
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return effective textFont of the target
end myTextFont


-- TEXT ALIGN
setProp tmTextAlign pValue
   set textAlign of the target to pValue
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return the effective textAlign of the target
end myTextAlign
