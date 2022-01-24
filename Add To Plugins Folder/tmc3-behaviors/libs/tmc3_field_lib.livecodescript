script "tmc3_field_lib" with behavior "tmc3_MasterBehavior"
-- TEXT CONTENT
setProp tmText pValue
   set text of me to pValue
end tmText

getProp tmText
   return myText()
end tmText

function myText
   return text of me
end myText


-- HTML TEXT
setProp tmHTMLText pValue
   set htmlText of me to pValue
end tmHTMLText

getProp tmText
   return myHTMLText()
end tmText

function myText
   return the htmlText of me
end myText


-- LOCKED TEXT
setProp tmLockText pValue
   set the lockText of me to pValue
end tmLockText

getProp tmLockText
   return myLockText()
end tmLockText

function myLockText
   return the lockText of me
end myLockText


-- TEXT SIZE
setProp tmTextSize pValue
   set textSize of me to pValue
   set textSize of char 1 to -1 of me to empty
end tmTextSize

getProp tmTextSize
   return myTextSize()
end tmTextSize

function myTextSize
   return effective textSize of me
end myTextSize


-- TEXT HEIGHT
setProp tmTextHeight pValue
   set textHeight of me to pValue
end tmTextHeight

getProp tmTextHeight
   return myTextHeight()
end tmTextHeight

function myTextHeight
   return effective textHeight of me
end myTextHeight


-- TEXT COLOR
setProp tmTextColor pValue
   set textColor of me to pValue
   set textColor of char 1 to -1 of me to empty
end tmTextColor

getProp tmTextColor
   return myTextColor()
end tmTextColor

function myTextColor
   return effective textColor of me
end myTextColor


-- TEXT STYLE
setProp tmTextStyle pValue
   set textStyle of me to pValue
   set textStyle of char 1 to -1 of me to empty
end tmTextStyle

getProp tmTextStyle
   return myTextStyle()
end tmTextStyle

function myTextStyle
   return effective textStyle of me
end myTextStyle


-- TEXT FONT
setProp tmTextFont pValue
   set textFont of me to pValue
   set textFont of char 1 to -1 of me to empty
end tmTextFont

getProp tmTextFont
   return myTextFont()
end tmTextFont

function myTextFont
   return effective textFont of me
end myTextFont


-- TEXT ALIGN
setProp tmTextAlign pValue
   set textAlign of me to pValue
end tmTextAlign

getProp tmTextAlign
   return myTextAlign()
end tmTextAlign

function myTextAlign
   return the effective textAlign of me
end myTextAlign
