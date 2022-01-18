script "tmc3_MasterBehavior"
local myL, myT, myR, myB, myW, myH, myRegion, theProportionalW, theProportionalH, origW, origH, myLoc, theX, theY
local theClickPosition, theClickX, theClickY
local self
local mouseResize, mouseResizeActive, mouseScaleActive



on mouseMove
   if mouseResizeActive or mouseScaleActive then
      if the mouse is "up" then
         put false into mouseResizeActive
         put false into mouseScaleActive
      end if
   end if
   pass mouseMove
end mouseMove


--on newGroup
--   put name of me
--end newGroup


# DIMENSIONAL FUNCTIONS

setProp GEOMETRY_FUNCTIONS
end GEOMETRY_FUNCTIONS


command tmManageControlGeometry
   if word 1 of the target is not "group" then exit tmManageControlGeometry
   lock screen
   lock messages
   tmInitMyGeometry
   put true into mouseResize
   --
   -- RESIZE/SCALE CUSTOM CONTROL GROUP
   if word 1 of name of me is "group" then
      if mouseResize then
         --
         -- RESIZE/SCALE VIA MOUSE
         get the clickLoc
         if it <> theClickPosition then
            --  STORE THESE PROPS ONLY ONCE DURING INITIAL MOUSEDOWN EVENT
            put it into theClickPosition
            put item 1 of theClickPosition into mouseX
            put item 2 of theClickPosition into mouseY
            tmInitMyLoc
            tmInitMyProportions
            if mouseX > myL and mouseX < myL + 8 then put "L" into theClickX
            if mouseX > theX - 4 and mouseX < theX + 4 then put "M" into theClickX
            if mouseX > myR - 8 and mouseX < myR then put "R" into theClickX
            if mouseY > myT and mouseY < myT + 8 then put "T" into theClickY
            if mouseY > theY - 4 and mouseY < theY + 4 then put "M" into theClickY
            if mouseY > myB - 8 and mouseY < myB then put "B" into theClickY
         end if
         --         if "M" is in theClickX or "M" is in theClickY then
         --            -- RESIZE
         --            put true into mouseResizeActive
         --            tmResizeCustomControl theControl
         --         else
         --            -- SCALE
         --            put true into mouseScaleActive
         --            tmScaleCustomControl theControl
         --         end if
         put true into mouseResizeActive
         tmResizeMe
      else
         --
         -- RESIZE/SCALE VIA SCRIPT
         get the tmGeometryData["proportionalScaling"] of theControl
         if it is true or it is empty then
            tmInitControlLoc theControl
            tmInitControlProportions theControl
            tmScaleCustomControl theControl
         else tmResizeCustomControl theControl
      end if
      exit tmManageControlGeometry
   end if
   --
   -- RESIZE/SCALE STOCK LIVECODE CONTROL
   tmScaleAndPositionObject theControl
   --
   unlock messages
   unlock screen
end tmManageControlGeometry


command tmResizeMe
   if mouseScaleActive then -- PREVENT RESIZING WHEN MOUSE IS RELEASED AFTER MANUAL SCALE
      put false into mouseScaleActive
      exit tmResizeMe
   end if
   --
   put long id of control 1 of me into myRegion
   set rect of myRegion to myL,myT,myR,myB
   --   set boundingRect of me to rect of myRegion --< !! MAY NEED THIS !!
   tmInitMyLoc
   tmInitMyProportions
   repeat with N = 1 to number of controls of me
      put long id of control N of me into theObj
      tmScaleAndPositionObject theObj, long id of me, "resize"
   end repeat
   --   put (width of theRegion/height of theRegion) into theProportionalW
   --   set the tmGeometryData["proportionalWidth"] of pControl to theProportionalW
   --   put (height of theRegion/width of theRegion) into theProportionalH
   --   set the tmGeometryData["proportionalHeight"] of pControl to theProportionalH
   
end tmResizeMe


command tmScaleCustomControl
   lock screen
   put long id of the target & return into theControlList
   if word 1 of long name of the target is "group" then
      repeat with C = 1 to number of controls of the target
         put long id of control C of the target & return after theControlList
      end repeat
   end if
   delete last char of theControlList
   put width of the target into W
   put height of the target into H
   put left of the target into L
   put top of the target into T
   --
   put H into referenceDimension -- SCALE CONTROL WHEN HEIGHT CHANGES
   --  put W into referenceDimension
   --
   repeat for each line theControl in theControlList
      set width of theControl to round(the tmGeometryData["width"] of theControl * W)
      set height of theControl to round(the tmGeometryData["height"] of theControl * H)
      set left of theControl to (L + round(the tmGeometryData["leftOffset"] of theControl * referenceDimension))
      set top of theControl to (T + round(the tmGeometryData["topOffset"] of theControl * referenceDimension))
      -- MARGINS
      put the tmGeometryData["margins"] of theControl into theMargins
      repeat with N = 1 to number of items of theMargins
         if N = 2 and word 1 of theControl is "field" then -- IGNORE TOP MARGIN OF FIELDS!
            put item N of theMargins into item N of theMargins
            next repeat
         end if
         put round(item N of theMargins * referenceDimension) into item N of theMargins  
      end repeat
      set margins of theControl to theMargins
      --      put short name of theControl && margins of theControl
      switch word 1 of theControl
         case "image"
            put the tmGeometryData["imageProportions"] of theControl into IP
            put rect of theControl into theRect
            put item 1 of theRect + (height of theControl * IP) into item 3 of theRect
            set rect of theControl to theRect
            break
         case "graphic"
            if style of theControl is "roundRect" then \
                  set roundRadius of theControl to round(the tmGeometryData["roundRadius"] of theControl * referenceDimension)
            set lineSize of theControl to round(the tmGeometryData["lineSize"] of theControl * referenceDimension)
            set textSize of theControl to round(the tmGeometryData["textSize"] of theControl * referenceDimension)
            break
         case "button"
            set borderWidth of theControl to round(the tmGeometryData["borderWidth"] of theControl * referenceDimension)
            set textSize of theControl to round(the tmGeometryData["textSize"] of theControl * referenceDimension)
            break
         case "field"
            set textSize of theControl to round(the tmGeometryData["textSize"] of theControl * referenceDimension)
            set textHeight of theControl to round(the tmGeometryData["textHeight"] of theControl * referenceDimension)
            set borderWidth of theControl to round(the tmGeometryData["borderWidth"] of theControl * referenceDimension)
            put the tmGeometryData["tabStops"] of theControl into theTabStops
            repeat with N = 1 to number of items of theTabStops
               put round(item N of theTabStops * referenceDimension) into item N of theTabStops 
            end repeat
            set tabStops of theControl to theTabStops
            break
      end switch
      -- GRAPHIC EFFECTS
      repeat for each item graphicEffect in "dropshadow,innershadow,outerglow,innerglow"
         put the tmGeometryData[graphicEffect] of theControl into theArray
         if theArray is not an array then next repeat
         put round(theArray["size"] * referenceDimension) into theArray["size"]
         put round(theArray["distance"] * referenceDimension) into theArray["distance"]
         put round(theArray["spread"] * referenceDimension) into theArray["spread"]
         set the graphicEffect of theControl to theArray
      end repeat
   end repeat
   unlock screen
end tmScaleCustomControl


local cTemp
command tmScaleAndPositionObject pObj, pParentControl, pMode
   if pObj is empty then exit tmScaleAndPositionObject
   put long id of control 1 of pParentControl into theRegion
   if pObj = theRegion then exit tmScaleAndPositionObject -- REGION OBJECT HAS ALREADY BEEN MODIFIED ABOVE
   local L, T, R, B, W, H, X, Y, RNDRAD, LNSZ, BW, RCT, BRCT
   --
   --   if pMode is "resize" then
   --      put the tmGeometryData["resizing"] of pObj into geomData
   --   else put the tmGeometryData["scaling"] of pObj into geomData
   
   put the tmGeometryData["resizeGeometry"] of pObj into geomData
   
   -- NO GEOMETRY
   if geomData is empty then
      -- IMAGE DEFAULT = CENTER IMAGE WITHIN REGION
      if word 1 of pObj is "image" then
         set loc of pObj to loc of theRegion
         exit tmScaleAndPositionObject
      end if
      -- FIELD DEFAULT = SET RECT OF FIELD TO RECT OF CONTROL
      --      if word 1 of pObj is "field" then
      --         set rect of pObj to rect of theRegion
      --         tmPositionFieldText pObj -- CENTER TEXT VERTICALLY IF APPLICABLE
      --         exit tmScaleAndPositionObject
      --      end if
   end if
   set itemDel to ":"
   set the lockErrorDialogs to true
   repeat for each line propData in geomData
      repeat for each item geomVar in "L:T:R:B:W:H:X:Y:RNDRAD:LNSZ:BW:RCT:BRCT"
         if item 1 of propData = geomVar then do "put value(item 2 of propData) into" && geomVar
      end repeat
   end repeat
   --
   -- SET SIZE
   if W is not empty then set width of pObj to W
   if H is not empty then set height of pObj to H
   --
   put valueCount(L,T,R,B) into theCount
   put false into polarOpposites
   if theCount = 2 then put oppositeEdgeCheck(L,T,R,B) into polarOpposites
   if (theCount > 2) or (theCount = 2 and polarOpposites) then
      -- SET RECT
      set itemDel to ","
      put rect of pObj into newRect
      if L is not empty then put L into item 1 of newRect
      if T is not empty then put T into item 2 of newRect
      if R is not empty then put R into item 3 of newRect
      if B is not empty then put B into item 4 of newRect
      set rect of pObj to newRect
      set itemDel to ":"
   else
      -- SET POSITION
      if L is not empty then set left of pObj to L
      if T is not empty then set top of pObj to T
      if R is not empty then set right of pObj to R
      if B is not empty then set bottom of pObj to B
   end if
   --
   -- SET LOCATION OR X OR Y
   if X is not empty and Y is not empty then
      set loc of pObj to X,Y
   else
      set itemDel to ","
      put loc of pObj into theLoc
      if X is not empty then set loc of pObj to X,item 2 of theLoc
      if Y is not empty then set loc of pObj to item 1 of theLoc,Y
   end if
   --
   -- NO SIZE, RECT, OR LOCATION
   put true into noGeomValues
   set itemDel to ","
   repeat for each item geomVar in "W,H,L,T,R,B,X,Y"
      if value(geomVar) is not empty then put false into noGeomValues
   end repeat
   -- if noGeomValues then set rect of pObj to rect of theRegion
   set itemDel to ":"
   --
   -- CENTER FIELD TEXT VERTICALLY IF APPLICABLE
   --   if word 1 of pObj is "field" then tmPositionFieldText pObj
   --
   -- ROUNDRADIUS
   if RNDRAD is not empty then set roundRadius of pObj to max(0,RNDRAD)
   --
   -- LINESIZE
   if LNSZ is not empty then set lineSize of pObj to max(0,LNSZ)
   --
   -- BORDERWIDTH
   if BW is not empty then set lineSize of pObj to max(0,BW)
   --
   -- RECT
   if RCT is not empty then set rect of pObj to RCT
   --
   -- BOUNDINGRECT
   if BRCT is not empty then set boundingRect of pObj to BRCT
   --
   -- SCALE EFFECTS
   --
end tmScaleAndPositionObject


-- COUNT NON-EMPTY VALUES IN L,T,R,B VARS
function valueCount L,T,R,B
   local N
   repeat for each item V in L,T,R,B
      if value(V) is not empty then add 1 to N
   end repeat
   return N
end valueCount


-- CHECK IF 2 VARS OF L,T,R,B ARE OPPOSITE OF EACH OTHER
function oppositeEdgeCheck L,T,R,B
   if (L is not empty and R is not empty) then return true
   if (T is not empty and B is not empty) then return true
   return false
end oppositeEdgeCheck


--command tmScaleAndPositionObject pObj, pGroup
--   if pObj is empty and pGroup is empty then exit tmScaleAndPositionObject
--   put long id of grc "region" of pGroup into theRegion
--   put the tmGeometryData["referenceObject"] of pObj into refObjName
--   if refObjName is empty then put "region" into refObjName
--   local L, T, R, B, X, Y, W, H, RNDRAD, LNSZ, RCT, BRCT
--   --
--   --   put the tmControlData["geometryConstants"] of pObj into geomData
--   --   if geomData is not empty then
--   --      set itemDel to tab
--   --      repeat for each line constantData in geomData
--   --         replace ":" with tab in constantData
--   --         put item 1 of constantData into theConstant
--   --         put value(item 2 of constantData) into theValue
--   --         do "put" && theValue && "into" && theConstant -- SET UP EACH CONSTANT AS A LOCAL VARIABLE
--   --      end repeat
--   --   end if
--   --
--   put the tmGeometryData["resizeGeometry"] of pObj into geomData
--   -- NO GEOMETRY
--   if geomData is empty then
--      -- IMAGE DEFAULT = CENTER IMAGE WITHIN REGION
--      if word 1 of pObj is "image" then
--         set loc of pObj to loc of theRegion
--         exit tmScaleAndPositionObject
--      end if
--   end if
--   set itemDel to ":"
--   set the lockErrorDialogs to true
--   repeat for each line propData in geomData
--      repeat for each item geomVar in "L:T:R:B:W:H:X:Y:RNDRAD:LNSZ:RCT:BRCT"
--         if item 1 of propData = geomVar then
--            put item 2 of propData into theExpression
--            do "put round(value(theExpression)) into" && geomVar
--            if item 2 of propData is a number and item 1 of propData is in "LTRBXY" then
--               -- IF ITEM 2 OF PROPDATA IS A NUMBER ONLY THEN
--               -- GET BASE POSITION VALUE OF REFERENCE OBJECT AND ADD TO GEOMVAR
--               -- THIS PREVENTS OBJECT FROM GETTING PLACED RELATIVE TO CARD
--               put item 1 of propData & "(" & refObjName & ")" into theExpression
--               put round(value(theExpression)) into temp
--               do "add temp to" && geomVar
--            end if
--         end if
--      end repeat
--   end repeat
--   --
--   -- SET SIZE
--   if W is not empty then set width of pObj to W
--   if H is not empty then set height of pObj to H
--   --
--   -- SET RECT OR SIDE
--   if L is not empty and T is not empty and R is not empty and B is not empty then
--      set rect of pObj to L,T,R,B
--   else
--      if L is not empty then set left of pObj to L
--      if T is not empty then set top of pObj to T
--      if R is not empty then set right of pObj to R
--      if B is not empty then set bottom of pObj to B
--   end if
--   --
--   -- SET LOCATION OR X OR Y
--   if X is not empty and Y is not empty then
--      set loc of pObj to X,Y
--   else
--      set itemDel to ","
--      put loc of pObj into theLoc
--      if X is not empty then set loc of pObj to X,item 2 of theLoc
--      if Y is not empty then set loc of pObj to item 1 of theLoc,Y
--   end if
--   --
--   -- NO SIZE, RECT OR LOCATION
--   --   put true into noGeomValues
--   --   repeat for each item geomVar in "W,H,L,T,R,B,X,Y"
--   --      if value(geomVar) is not empty then put false into noGeomValues
--   --   end repeat
--   --   if noGeomValues then set rect of pObj to rect of theRegion
--   --
--   -- CENTER FIELD TEXT VERTICALLY IF APPLICABLE
--   -- if word 1 of pObj is "field" then tmPositionFieldText pObj
--   --
--   -- ROUNDRADIUS
--   if RNDRAD is not empty then set roundRadius of pObj to max(0,RNDRAD)
--   --
--   -- LINESIZE
--   if LNSZ is not empty then set lineSize of pObj to max(0,LNSZ)
--   --
--   -- RECT
--   if RCT is not empty then set rect of pObj to RCT
--   --
--   -- BOUNDINGRECT
--   if BRCT is not empty then set boundingRect of pObj to BRCT
--end tmScaleAndPositionObject

command tmInitMyGeometry
   put left of me into myL
   put top of me into myT
   put right of me into myR
   put bottom of me into myB
   put width of me into myW
   put height of me into myH
end tmInitMyGeometry


command tmInitMyLoc
   put loc of me into theLoc
   put item 1 of theLoc into theX
   put item 2 of theLoc into theY
end tmInitMyLoc


command tmInitMyProportions
   put width of me into theW
   put height of me into theH
   put theW into origW
   put theH into origH
   set the tmGeometryData["proportionalWidth"] of me to theW/theH
   set the tmGeometryData["proportionalHeight"] of me to theH/theW
end tmInitMyProportions


function distance p1,p2 
   return sqrt((item 1 of p1 - item 1 of p2)^2 + (item 2 of p1 - item 2 of p2)^2) 
end distance


function L pName
   if pName is empty then return left of myRegion
   put long id of control pName of me into theObj
   return left of theObj
end L


function T pName
   if pName is empty then return top of myRegion
   put long id of control pName of me into theObj
   return top of theObj
end T


function R pName
   if pName is empty then return right of myRegion
   put long id of control pName of me into theObj
   return right of theObj
end R


function B pName
   if pName is empty then return bottom of myRegion
   put long id of control pName of me into theObj
   return bottom of theObj
end B


function W pName
   if pName is empty then return width of myRegion
   put long id of control pName of me into theObj
   return width of theObj
end W


function H pName
   if pName is empty then return height of myRegion
   put long id of control pName of me into theObj
   return height of theObj
end H


function X pName
   if pName is empty then return item 1 of loc of myRegion
   put long id of control pName of me into theObj
   return item 1 of loc of theObj
end X


function Y pName
   if pName is empty then return item 2 of loc of myRegion
   put long id of control pName of me into theObj
   return item 2 of loc of theObj
end Y



# GRAPHICS & EFFECTS FUNCTIONS/COMMANDS

setProp GRAPHICS_FUNCTIONS
end GRAPHICS_FUNCTIONS

function defaultVerticalGradient pObj
   put "linear" into theArray["type"]
   put "0.0,0,0,0" & cr & "1.0,255,255,255" into theArray["ramp"]
   put line 1 of vLinearGradPoints(pObj) into theArray["from"]
   put line 2 of vLinearGradPoints(pObj) into theArray["via"]
   put line 3 of vLinearGradPoints(pObj) into theArray["to"]
   -- setPoints theArray
   put "good" into theArray["quality"]
   put 1 into theArray["repeat"]
   put false into theArray["mirror"]
   put false into theArray["wrap"]
   return theArray
end defaultVerticalGradient


function defaultHorizontalGradient pObj
   put "linear" into theArray["type"]
   put "0.0,0,0,0" & cr & "1.0,255,255,255" into theArray["ramp"]
   put line 1 of hLinearGradPoints(pObj) into theArray["from"]
   put line 2 of hLinearGradPoints(pObj) into theArray["via"]
   put line 3 of hLinearGradPoints(pObj) into theArray["to"]
   -- setPoints theArray
   put "good" into theArray["quality"]
   put 1 into theArray["repeat"]
   put false into theArray["mirror"]
   put false into theArray["wrap"]
   return theArray
end defaultHorizontalGradient


-- for testing
command setPoints theArray
   set loc of grc "p1" of the topstack to theArray["from"]
   set loc of grc "p2" of the topstack to theArray["via"]
   set loc of grc "p3" of the topstack to theArray["to"]
end setPoints


function defaultRadialGradient pObj
   put "radial" into theArray["type"]
   put "0.0,0,0,0" & cr & "1.0,255,255,255" into theArray["ramp"]
   put line 1 of radialGradPoints(pObj) into theArray["from"]
   put line 2 of radialGradPoints(pObj) into theArray["via"]
   put line 3 of radialGradPoints(pObj) into theArray["to"]
   -- setPoints theArray
   put "good" into theArray["quality"]
   put 1 into theArray["repeat"]
   put false into theArray["mirror"]
   put false into theArray["wrap"]
   return theArray
end defaultRadialGradient


function defaultConicalGradient pObj
   put "conical" into theArray["type"]
   put "0.0,0,0,0" & cr & "1.0,255,255,255" into theArray["ramp"]
   put line 1 of conicalGradPoints(pObj) into theArray["from"]
   put line 2 of conicalGradPoints(pObj) into theArray["via"]
   put line 3 of conicalGradPoints(pObj) into theArray["to"]
   -- setPoints theArray
   put "good" into theArray["quality"]
   put 1 into theArray["repeat"]
   put false into theArray["mirror"]
   put false into theArray["wrap"]
   return theArray
end defaultConicalGradient


function vLinearGradPoints pObj
   return \
         item 1 of loc of pObj,top of pObj & cr & \
         right of pObj,top of pObj & cr & \
         item 1 of loc of pObj,bottom of pObj
end vLinearGradPoints


function hLinearGradPoints pObj
   return \
         left of pObj,item 2 of loc of pObj & cr & \
         left of pObj,top of pObj & cr & \
         right of pObj,item 2 of loc of pObj
end hLinearGradPoints


function radialGradPoints pObj
   return \
         loc of pObj & cr & \
         right of pObj,item 2 of loc of pObj & cr & \
         item 1 of loc of pObj,bottom of pObj
end radialGradPoints


function conicalGradPoints pObj
   return \
         loc of pObj & cr & \
         left of pObj,item 2 of loc of pObj & cr & \
         item 1 of loc of pObj,top of pObj
end conicalGradPoints


function defaultDropShadow
   put "gaussian" into tArray["filter"]
   put "normal" into tArray["blendMode"]
   put 0,0,0 into tArray["color"]
   put 180 into tArray["opacity"]
   put 0 into tArray["spread"]
   put 5 into tArray["size"]
   put 5 into tArray["distance"]
   put 90 into tArray["angle"]
   put false into tArray["knockout"]
   return tArray
end defaultDropShadow


function defaultInnerShadow
   put "gaussian" into tArray["filter"]
   put "normal" into tArray["blendMode"]
   put 0,0,0 into tArray["color"]
   put 180 into tArray["opacity"]
   put 0 into tArray["spread"]
   put 5 into tArray["size"]
   put 5 into tArray["distance"]
   put 90 into tArray["angle"]
   return tArray
end defaultInnerShadow


function defaultOuterGlow
   put "gaussian" into tArray["filter"]
   put "normal" into tArray["blendMode"]
   put 0,0,0 into tArray["color"]
   put 180 into tArray["opacity"]
   put 0 into tArray["spread"]
   put 5 into tArray["size"]
   put 255 into tArray["range"]
   return tArray
end defaultOuterGlow


function defaultInnerGlow
   put "gaussian" into tArray["filter"]
   put "normal" into tArray["blendMode"]
   put 0,0,0 into tArray["color"]
   put 180 into tArray["opacity"]
   put 0 into tArray["spread"]
   put 5 into tArray["size"]
   put 255 into tArray["range"]
   put "edge" into tArray["source"]
   return tArray
end defaultInnerGlow


function defaultColorOverlay
   put "normal" into tArray["blendMode"]
   put 255,0,0 into tArray["color"]
   put 128 into tArray["opacity"]
   return tArray
end defaultColorOverlay


function imageToAlpha pData
   put 2 into C
   repeat (length(pData)/4)
      put numToChar(255 - charToNum(char C of pData)) after tAlpha
      add 4 to C
   end repeat
   return tAlpha
end imageToAlpha


command scaleEffects pObj,pValue
   repeat for each item prop in "dropshadow,innershadow,outerglow,innerglow"
      put the prop of pObj into theArray
      put round(theArray["size"] * pValue) into theArray["size"]
      put round(theArray["distance"] * pValue) into theArray["distance"]
      put round(theArray["spread"] * pValue) into theArray["spread"]
      set the prop of pObj to theArray
   end repeat
end scaleEffects


command generateBlur pAmount, pImage, pUseAlpha
   local theOriginalImageData,theNewImageData,theNewAlphaData
   put the imageData of pImage into theOriginalImageData
   blur pAmount,"theOriginalImageData", width of pImage, height of pImage, "theNewImageData" -- ,"theNewAlphaData", 5
   set imageData of pImage to theNewImageData
   --set the alphaData of image 2 to theNewAlphaData
end generateBlur


function pixelDensity
   put the systemPixelScale into V
   switch
      case V <= 0.25
         return "ultralow"
         break
      case V > 0.25 and V <= 0.5
         return "extralow"
         break
      case V > 0.5 and V <= 0.75
         return "low"
         break
      case V > 0.75 and V <= 1
         return "medium"
         break
      case V > 1 and V <= 1.5
         return "high"
         break
      case V > 1.5 and V <= 2
         return "extrahigh"
         break
      case V > 2 -- UP TO 4
         return "ultrahigh"
   end switch   
end pixelDensity




# COLOR FUNCTIONS/COMMANDS

setProp COLOR_FUNCTIONS
end COLOR_FUNCTIONS


command setIconColor pImage, pState, pColor
   put the customKeys["tmControlData"] of pImage into theList
   repeat for each line prop in theList
      if pState is "normal" and prop contains "hilite" then next repeat
      if pState is "hilite" and "hilite" is not in prop then next repeat
      set text of the templateImage to the tmControlData[prop] of pImage
      put binaryEncode("CCCC",0,item 1 of pColor,item 2 of pColor,item 3 of pColor) into V
      repeat (width of the templateImage * height of the templateImage)
         put V after theColorData
      end repeat
      set imageData of the templateImage to theColorData
      set the tmControlData[prop] of pImage to the text of the templateImage
   end repeat
   set text of pImage to the tmControlData["mediumIcon"] of pImage
   reset the templateImage
end setIconColor


command fillWithColor pImage, pColor
   put binaryEncode("CCCC",0,item 1 of pColor,item 2 of pColor,item 3 of pColor) into V
   repeat (width of pImage * height of pImage)
    put V after theColorData
  end repeat
  set imageData of pImage to theColorData
end fillWithColor


function solidColorImageData pImage, pColor
  put binaryEncode("CCCC",0,item 1 of pColor,item 2 of pColor,item 3 of pColor) into V
  repeat (width of pImage * height of pImage)
    put V after theImageData
  end repeat
  return theImageData
end solidColorImageData


function colorToRGB pColor
   if item 1 of pColor is not a number then
      put long id of grc "color_sample" of stack "tmCommon" into tObj
      set backColor of tObj to pColor
      set the backPixel of tObj to the effective backPixel of tObj
      put the backcolor of tObj into pColor
   end if
   return pColor
end colorToRGB


function HSVtoRGB pColor
   local rgb, i, f, p, q, t
   set the numberFormat to "0.###############"
   put item 1 of pColor into h
   put item 2 of pColor into s
   put item 3 of pColor into v
   divide s by 100
   divide v by 100
   if s = 0 then put v,v,v into rgb
   else
      divide h by 60
      put trunc(h) into i
      put h - i into f
      put v * (1 - s) into p
      put v * (1 - s * f) into q
      put v * (1 - s * (1- f)) into t
      if i = 0 then put v,t,p into rgb
      if i = 1 then put q,v,p into rgb
      if i = 2 then put p,v,t into rgb
      if i = 3 then put p,q,v into rgb
      if i = 4 then put t,p,v into rgb
      if i = 5 then put v,p,q into rgb
   end if
   return round(item 1 of rgb * 255), round(item 2 of rgb * 255), round(item 3 of rgb * 255)
end HSVtoRGB


function RGBtoHSV pColor
   local maxv, minv, diff, s, rc, gc, bc, h
   set the numberFormat to "0.###############"
   put item 1 of pColor into r
   put item 2 of pColor into g
   put item 3 of pColor into b
   divide r by 255
   divide g by 255
   divide b by 255
   put max(r,g,b) into maxv
   put min(r,g,b) into minv
   put maxv - minv into diff
   if maxv <> 0 and diff <> 0 then
      put diff / maxv into s
      put (maxv - r) / diff into rc
      put (maxv - g) / diff into gc
      put (maxv - b) / diff into bc
      if r = maxv then put bc - gc into h
      else if g = maxv then put 2 + rc - bc into h
      else if b = maxv then put 4 + gc - rc into h
      multiply h by 60
      if h < 0 then
         add 360 to h
      end if
   else
      put 0 into s
      put 0 into h
   end if
   return round(h),round(s * 100),round(maxv * 100)
end RGBtoHSV


function HEXtoRGB N
  put char 1 to 2 of N into R
  put char 3 to 4 of N into G
  put char 5 to 6 of N into B
  put R,G,B into temp
  repeat for each item C in temp
    put baseConvert(C,16,10) & "," after theColor
  end repeat
  delete last char of theColor
  return theColor
end HEXtoRGB


function colorTint pColor, pValue
   -- pValue is between 0 and 1
   put item 1 of pColor into R
   put item 2 of pColor into G
   put item 3 of pColor into B
   put round(R + (pValue * (255 - R))) into newR
   put round(G + (pValue * (255 - G))) into newG
   put round(B + (pValue * (255 - B))) into newB
   return newR,newG,newB
end colorTint


function colorShade pColor, pValue
   -- pValue is between 0 and 1
   put item 1 of pColor into R
   put item 2 of pColor into G
   put item 3 of pColor into B
   put round(R * pValue) into newR
   put round(G * pValue) into newG
   put round(B * pValue) into newB
   return newR,newG,newB
end colorShade


function desaturate RGB
  put round((0.3333 * item 1 of RGB) + (0.3333 * item 2 of RGB) + (0.3333 * item 3 of RGB)) into N
  return N,N,N
end desaturate






# MISC FUNCTIONS

setProp MISC_FUNCTIONS
end MISC_FUNCTIONS

-- GET GROUP OWNER OF OBJECT
function myGroupOwner
   put long name of me into myName
   if "group" is not in myName then return empty
   put 0 into wordSkip
   if word 1 of myName = "group" then put 1 into wordSkip
   return word (wordOffset("group",myName,wordSkip) + wordSkip) to -1 of myName
end myGroupOwner


-- GET TMCONTROL GROUP OWNER OF OBJECT
function myTMControlGroupOwner pObj
   if pObj is empty then put long id of me into pObj
   if "group" is not in pObj then return empty
   repeat 50
      put wordOffset("group",pObj) into N
      if N = 0 then return empty
      put word N to -1 of pObj into pObj
      if the tmControlData["type"] of pObj is empty then
         delete word 1 of pObj
         next repeat
      end if
      return pObj
   end repeat
   return empty
end myTMControlGroupOwner


-- GET CONTROL'S STACK OWNER
function myStackOwner pObj
   put long id of me into theObjName
   if pObj is not empty then put pObj into theObjName
   return word wordOffset("stack",theObjName) to -1 of theObjName
end myStackOwner


-- GET CONTROL'S MAINSTACK
function myMainStack pObj
   put long id of me into theObj
   if pObj is not empty then put pObj into theObj
   repeat 100
      get owner of theObj
      if it is empty then return theObj
      put it into theObj
   end repeat
end myMainStack


-- CHECK IF CONTROL IS NESTED WITHIN A SCROLLING REGION
function isWithinScrollingRegion pObj
   put long id of me into theObj
   if pObj is not empty then put pObj into theObj
   repeat 100
      put owner of theObj into theOwner
      get word 1 of theOwner
      if it is "card" then return false
      if it is "group" and the tmControlData["type"] of theOwner is "scrolling region" then
         return long id of theOwner
      end if
      put long id of theOwner into theObj
   end repeat
   return false
end isWithinScrollingRegion



# ENVIRONMENT FUNCTIONS

setProp ENVIRONMENT_FUNCTIONS
end ENVIRONMENT_FUNCTIONS

function onMobile
   return environment() is "mobile"
end onMobile


function onDesktop
   return "Mac" is in platform() or "Win" is in platform()
end onDesktop
