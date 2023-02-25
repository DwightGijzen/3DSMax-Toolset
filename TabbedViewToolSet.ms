/*
-- ToolSet for Pirates' Nest
-- Version: 19012019a
-- Author: Dwight Gijzen
-- Notes: This toolset should be used for any serious developer in HeroEngine. This will help you in the export process of static assets.
-- Feedback: All feedback is welcome about the Toolset in the appropriate HE Forum Topic
-- Feature Request(s): All feature requests are welcome; Please keep in mind that if it's unrelevant for Pirates' Nest, the feature development will most likely be slow.
-- Website: http://www.pirates-nest.com

-- Upcoming features:
---- Character .dat file creator
*/
Global LastSubRollout = 1
--
-- EXTERNAL ROLLOUTS (Secondary Rollouts, e.g Stone Generator, Physics Window, ...)
--
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Mesh Demolisher */
rollout DemolishMesh "Mesh Destroyer" width:176 height:280
(
	GroupBox grp_DemolishWindow_Step1 "Step 1: Select Mesh" pos:[8,8] width:161 height:41
	fn geometryFilter obj = (superClassOf obj == GeometryClass)
	pickbutton btn_PickMesh "Choose Mesh" pos:[16,24] width:145 height:17 filter:geometryFilter
	GroupBox grp_DemolishWindow_Step2 "Step 2: Demolish Properties" pos:[8,56] width:161 height:81
	label lbl_DemolishWindow_NbParts "Number of Parts:" pos:[16,72] width:88 height:16
	label lbl_DemolishWindow_Reps "Repetitions" pos:[16,96] width:88 height:16
	spinner spn_Parts "" pos:[112,72] width:48 height:16 enabled:false range:[0,8,1] type:#integer
	spinner spn_Iterations "" pos:[112,96] width:48 height:16 enabled:false range:[0,8,1] type:#integer
	GroupBox grp_DemolishWindow_Step3 "Step 3: Optional Coloring" pos:[8,144] width:161 height:57
	radiobuttons rdo1 "" pos:[16,160] width:100 height:32 labels:#("Uniform Coloring", "Multi Coloring") default:1 columns:1
	GroupBox grp_DemolishWindow_Step4 "Step 4: Create" pos:[8,208] width:161 height:65
	button btn_Demolish "Demolish that Mesh!" pos:[16,224] width:145 height:17 enabled:true
	progressBar pb1 "ProgressBar" pos:[16,248] width:145 height:17
	colorPicker cp1 "" pos:[126,180] width:32 height:11 color:[128,96,64]
	label lbl_DemolishWindow_Pieces "Demolish in ... pieces." pos:[16,119] width:144 height:16
	
	local theMesh -- Original Object

	on btn_PickMesh picked obj do
	(
		btn_PickMesh.caption	= "Selected: " + obj.name
		btn_PickMesh.tooltip 	= "Selected for Demolition: \n" + obj.name
		theMesh 					= obj
		spn_Parts.enabled 		= true
		spn_Iterations.enabled 	= true
		btn_Demolish.enabled 	= true
		cp1.color 					= obj.wireColor
	
	)
	on spn_Parts changed val do
	(
		lbl_DemolishWindow_Pieces.text = "Demolish in " + ((val ^ spn_Iterations.value) as string) +" pieces."
	)
	on spn_Iterations changed val do
	(
		lbl_DemolishWindow_Pieces.text = "Demolish in " + ((val ^ spn_Parts.value) as string) +" pieces."
	)
	on btn_Demolish pressed do
	(
		local arrTemp 	= #()
		local arrFinal 		= #()
		local nbParts 		= spn_Parts.value
		local rotPlane 	= plane isHidden:true
	
		start = timeStamp()
	
		theMesh.isHidden 	= true
		theMesh.isSelected 	= false
	
		append arrFinal (copy theMesh)
		collapseStack arrFinal[1]
	
		for iter = 1 to spn_Iterations.value do
		(
			counter = 0
			arrTemp = arrFinal
			arrFinal = #()
			for obj in arrTemp do obj.isHidden = true
	
			for obj in arrTemp do
			(
				nbPartsys = pcloud emitter:obj formation:3 quantityMethod:1 total_number:nbParts \
								 viewPercent:100 seed:(random 0 1000) isHidden:true
				arrCoords = #()
				for i = 1 to nbParts do arrCoords[i] = (particlePos nbPartsys i)
				delete nbPartsys
	
				for i = 1 to nbParts do
				(
					thePart = editable_mesh pos:arrCoords[i]
					thePart.wireColor = case rdo1.state of
										(
											1: cp1.color
											2: random black white
										)	-- end case rdoColor.state
					attach thePart (copy obj isHidden:true)
	
					for j = 1 to nbParts where j != i do
					(
						theVec = arrCoords[j] - arrCoords[i]
						rotPlane.dir = theVec
						mSlice = sliceModifier slice_type:2
						addModifier thePart mSlice
						mSlice.slice_plane.rotation = rotPlane.rotation
						mSlice.slice_plane.pos = theVec / 2
						addModifier thePart (cap_holes())
						collapseStack thePart
	
					)	-- end for j = 1 to nbParts
	
					append arrFinal thePart
					thePart.isHidden = false
					redrawViews()
					end = timeStamp()
					counter += 1
					total = nbParts ^ iter
					prog = 100 * counter / total
					pb1.value = prog
					pb1.color = [200 - prog * 2,prog * 2,0]
	
				)	-- end for i = 1 to nbParts
	
				delete obj
	
			)	-- end for obj in arrTemp
	
		)	-- end for iter = 1 to spnNbIter.value
	
		for obj in arrFinal do obj.name = (uniqueName (theMesh.name + "_demolished_"))
		delete rotPlane
		btn_PickMesh.caption = "Choose Mesh"
		spn_Parts.enabled = false
		spn_Iterations.enabled = false
		btn_Demolish.enabled = false
	
	)
)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Notes Rollout */
rollout QuickNotes "Quick Notes" width:432 height:464
(
	button 		btn_Save 			"Save" 			pos:[8,432] 	width:116 height:24
	button 		btn_Clear 			"Clear" 		pos:[308,432] 	width:116 height:24
	edittext 	notez 				"" 				pos:[4,58] 		width:420 height:366 	enabled:true readOnly:false
	edittext 	edt_NotesLocalTime 	"" 				pos:[4,8] 		width:232 height:24
	label 		lbl_LastSave 		"Last Save:" 	pos:[9,38] 		width:227 height:15 	enabled:true
	
	on QuickNotes open do
	(
		if persistents.isPersistent #NotezText	== false then global NotezText	= ""
		if persistents.isPersistent #LastSave	== false then global LastSave	= ""
		edt_NotesLocalTime.text		= localTime
		lbl_LastSave.text					= LastSave
		notez.text							= NotezText
	)
	on btn_Save pressed do
	(
		NotezText				= notez.text
		persistents.make #NotezText
		lbl_LastSave.text		= localTime
		LastSave				= lbl_LastSave.text
		persistents.make #LastSave
	)
	on btn_Clear pressed do
	(
		global oldtext			= notez.text
		notez.text				= ""
		lbl_LastSave.text		= "Cleared!"
	)
)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Simple planks generator */
rollout PlankGenerator "Uniform Plank Generator" width:200 height:344
(
	label lbl_PlankGenerator_2 "X Amount :" pos:[17,25] width:56 height:16
	label lbl_PlankGenerator_3 "Y Amount :" pos:[17,48] width:56 height:16
	label lbl_PlankGenerator_4 "Length per plank :" pos:[15,96] width:96 height:16
	label lbl_PlankGenerator_5 "Width per plank :" pos:[15,120] width:96 height:16
	GroupBox grp_PlankGenerator_Segments "Segments" pos:[8,152] width:185 height:41
	spinner spn_PlankGenerator_L "L :" pos:[24,169] width:40 height:16 range:[1,5,1] type:#integer
	spinner spn_PlankGenerator_W "W :" pos:[76,169] width:48 height:16 range:[1,5,1] type:#integer
	spinner spn_PlankGenerator_H "H :" pos:[137,169] width:48 height:16 range:[1,5,1] type:#integer
	GroupBox grp_PlankGenerator_Spread "Spread" pos:[8,200] width:185 height:41
	spinner spn_PlankGenerator_Spread_X "X :" pos:[24,217] width:40 height:16 range:[0,50,0] type:#integer
	spinner spn_PlankGenerator_X_Amount "" pos:[129,25] width:56 height:16 range:[1,50,1] type:#integer
	spinner spn_PlankGenerator_Y_Amount "" pos:[129,48] width:56 height:16 range:[1,50,1] type:#integer
	GroupBox grp_PlankGenerator_Quantity "Quantity" pos:[8,8] width:185 height:65
	GroupBox grp_PlankGenerator_Dimensions "Dimensions" pos:[8,80] width:185 height:65
	spinner spn_PlankGenerator_Length "" pos:[129,96] width:56 height:16 range:[1,50,25] type:#integer
	spinner spn_PlankGenerator_Width "" pos:[129,120] width:56 height:16 range:[1,50,5] type:#integer
	spinner spn_PlankGenerator_Spread_Y "Y : " pos:[76,217] width:48 height:16 range:[0,50,0] type:#integer
	GroupBox grp_PlankGenerator_Deformation "Deformations" pos:[8,248] width:185 height:41
	radiobuttons rdo_PlankGenerators_Deform "" pos:[16,264] width:162 height:16 labels:#("Deform", "No Deform") columns:2
	button btn_GeneratePlanks "Build my planks!" pos:[8,296] width:185 height:17
	button btn_CloseGeneratePlanks "Close Window" pos:[8,320] width:185 height:17
	

	on btn_GeneratePlanks pressed do
	(
			y_amount = spn_PlankGenerator_Y_Amount.value
			x_amount = spn_PlankGenerator_X_Amount.value
			
			spread_y_between = spn_PlankGenerator_Spread_Y.value
			spread_x_between = spn_PlankGenerator_Spread_X.value
			
			plank_length = spn_PlankGenerator_Length.value
			plank_width = spn_PlankGenerator_Width.value
			
			length_segments = spn_PlankGenerator_L.value
			width_segments = spn_PlankGenerator_W.value
			height_segments = spn_PlankGenerator_H.value
			
			for y=0 to y_amount do
			(
				for x=0 to x_amount do
				(
					i = Box lengthsegs:length_segments widthsegs:width_segments heightsegs:height_segments length:plank_length width:plank_width height:1 pos:[(x*(spread_x_between + plank_width)),-(y*(plank_length+spread_y_between)),0]
					i.name = ("Plank_"+x as string +"_"+y as string)
						
					case rdo_PlankGenerators_Deform.state of
					(
						1:(
						thedisplacer = Displace()
						AddModifier i thedisplacer
	
						thewood = Wood()
						i.modifiers[#Displace].map = thewood
						i.modifiers[#Displace].maptype = 0
						i.modifiers[#Displace].strength = random -1.9 1.9
						i.modifiers[#Displace].decay = 0
						i.modifiers[#Displace].lumCenterEnable = on
						i.modifiers[#Displace].lumCenter = random 0.5 0.8
						i.modifiers[#Displace].length = 10.344m
						i.modifiers[#Displace].width = 10.344m
						i.modifiers[#Displace].height = 10.344m
						)
						2:()
					)
				)
			)
			max select all
		)
	on btn_CloseGeneratePlanks pressed do
		(DestroyDialog PlankGenerator)
)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Rock Generator Rollout */
rollout RockGenerator "Rock Generator" width:200 height:184
(
	button btn_GenerateSmoothRocks "Generate Smooth Rocks" pos:[8,136] width:185 height:17
	spinner spn_SmoothRocksXAmount "X Amount" pos:[29,10] width:80 height:16 range:[0,15,0] type:#integer
	spinner spn_SmoothRocksYAmount "Y Amount" pos:[29,34] width:80 height:16 range:[0,15,0] type:#integer
	label lbl_TotalAmountOfSmoothRocks "Total Amount : 1" pos:[8,58] width:184 height:16
	radiobuttons rdo_VertsPerRock "Vertices per Rock:" pos:[8,82] width:164 height:46 labels:#("866", "602", "450", "386", "258", "218", "98", "26") columns:4
	button btn_GenerateRougherRocks "Generate Rougher Rocks" pos:[8,160] width:185 height:17
	
	on btn_GenerateSmoothRocks pressed do
	(
		case rdo_VertsPerRock.state of
			(
				1:( --866 vertices
				lengthsegm = 6
				widthsegm = 6
				heightsegm = 6
				)
				2:( --602 vertices
				lengthsegm = 5
				widthsegm = 5
				heightsegm = 5
				)
				3:( --450 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 5
				)
				4:( --386 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 4
				)
				5:( --258 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 2
				)
				6:( --218 vertices
				lengthsegm = 3
				widthsegm = 3
				heightsegm = 3
				)
				7:( --98 vertices
				lengthsegm = 2
				widthsegm = 2
				heightsegm = 2
				)
				8:( --26 vertices
				lengthsegm = 1
				widthsegm = 1
				heightsegm = 1
				)
			)
	
		y_amount = spn_SmoothRocksYAmount.value
		x_amount = spn_SmoothRocksXAmount.value
			
		for y=0 to y_amount do
		(
			for x=0 to x_amount do
			(
			SmoothStone = Box lengthsegs:lengthsegm widthsegs:widthsegm heightsegs:heightsegm length:5 width:5 height:5 pos:[(x*40),-(y*40),0]
			SmoothStone.name = uniquename ("SmoothStone_"+x as string +"_"+y as string)
			--define modifiers
			turbosm 	= TurboSmooth()
			makesphere 	= Spherify()
			thenoise 	= Noisemodifier ()
			--add modifiers
			addmodifier SmoothStone makesphere
			addmodifier SmoothStone turbosm
			addmodifier SmoothStone thenoise
			--randomize modifier properties	
			strengthx 		= random 1.80 3.45
			strengthy 		= random 1.80 3.45
			strengthz 		= random 1.80 3.45
			noiseseeder 	= random 1 11
			roughnessseeder = random 0.85 0.96
			scalex			= random 1.00 5.5
			scaley			= random 1.00 5.5
			scalez			= random 1.00 5.5
			-- apply randomization
			SmoothStone.modifiers[#Noise].seed = noiseseeder
			SmoothStone.modifiers[#Noise].fractal = on
			SmoothStone.modifiers[#Noise].roughness = roughnessseeder
			SmoothStone.modifiers[#Noise].strength = [strengthx,strengthy,strengthz]
			--apply random scale
			scale SmoothStone [scalex,scaley,scalez]
			)
		)
	)
	on spn_SmoothRocksXAmount changed val do
	(
			lbl_TotalAmountOfSmoothRocks.text = "Total Amount : " + ((val + 1) * (spn_SmoothRocksYAmount.value + 1)) as string
		)
	on spn_SmoothRocksYAmount changed val do
	(
			lbl_TotalAmountOfSmoothRocks.text = "Total Amount : " + ((spn_SmoothRocksXAmount.value + 1) * (val + 1)) as string
		)
	on btn_GenerateRougherRocks pressed do
	(
		case rdo_VertsPerRock.state of
			(
				1:( --866 vertices
				lengthsegm = 6
				widthsegm = 6
				heightsegm = 6
				)
				2:( --602 vertices
				lengthsegm = 5
				widthsegm = 5
				heightsegm = 5
				)
				3:( --450 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 5
				)
				4:( --386 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 4
				)
				5:( --258 vertices
				lengthsegm = 4
				widthsegm = 4
				heightsegm = 2
				)
				6:( --218 vertices
				lengthsegm = 3
				widthsegm = 3
				heightsegm = 3
				)
				7:( --98 vertices
				lengthsegm = 2
				widthsegm = 2
				heightsegm = 2
				)
				8:( --26 vertices
				lengthsegm = 1
				widthsegm = 1
				heightsegm = 1
				)
			)
	
		y_amount = spn_SmoothRocksYAmount.value
		x_amount = spn_SmoothRocksXAmount.value
			
		for y=0 to y_amount do
		(
			for x=0 to x_amount do
			(
				RoughStone = Box lengthsegs:lengthsegm widthsegs:widthsegm heightsegs:heightsegm length:5 width:5 height:5 pos:[(x*30),-(y*30),0]
				RoughStone.name = uniquename ("RoughStone_"+x as string +"_"+y as string)
				
				-- Define all modifiers:
				turbosm 	= TurboSmooth()
				makesphere	= Spherify()
				thenoise	= Noisemodifier ()
				displacer	= Displace()
				noisemod	= noise()
				-- Add all modifiers to selection:
				addmodifier RoughStone makesphere
				addmodifier RoughStone turbosm
				addmodifier RoughStone thenoise
				addmodifier RoughStone displacer
				--random elements
				strengthx		= random 1.80 3.45
				strengthy		= random 1.80 3.45
				strengthz		= random 1.80 3.45
				noiseseeder 	= random 1 11
				roughnessseeder = random 0.85 0.96
				scalex			= random 1.00 5.50
				scaley			= random 1.00 5.50
				scalez			= random 1.00 5.50
				-- apply modifiers with randomness
				RoughStone.modifiers[#Noise].seed = noiseseeder
				RoughStone.modifiers[#Noise].fractal = on
				RoughStone.modifiers[#Noise].roughness = roughnessseeder
				RoughStone.modifiers[#Noise].strength = [strengthx,strengthy,strengthz]
				RoughStone.modifiers[#Displace].strength = -2.58
				RoughStone.modifiers[#Displace].decay = 0.3
				RoughStone.modifiers[#Displace].lumCenterEnable = on
				RoughStone.modifiers[#Displace].lumCenter = 1
				RoughStone.modifiers[#Displace].map = noisemod
				RoughStone.modifiers[#Displace].maptype = 3
				RoughStone.modifiers[#Displace].length = 5.35346
				RoughStone.modifiers[#Displace].width = 5.35346
				RoughStone.modifiers[#Displace].height = 5.35346
				scale RoughStone [scalex,scaley,scalez]
			)
		)
	)
)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Physics Window Rollout */
rollout RunPhysX "Physics Effects" width:192 height:168
(
	button btn_StartPhysicsCalculus "Start Calculus" pos:[16,40] width:161 height:17
	button btn_removePhysicsModifier "Remove Physics Modifier" pos:[16,88] width:161 height:17
	button btn_ApplyAllSettingsAndClearAll "Apply All and Close Window" pos:[16,136] width:161 height:17
	GroupBox grp_PhysicsWindow_StartCalculus "Step 2: Start Calculations" pos:[8,24] width:177 height:41
	label lbl_PhysicsStep1 "Step 1: Select Objects" pos:[17,8] width:111 height:16
	GroupBox grp_PhysicsStep3Group "Step 3: Remove the Modifiers" pos:[8,72] width:177 height:41
	GroupBox grp_PhysicsWindow_Step4 "Step 4: Finalization" pos:[8,120] width:177 height:41
	
	on btn_StartPhysicsCalculus pressed do
	(
		if ($ == undefined) then MessageBox "Please select at least 1 object first!"
		else(
			local myPhysx				= PhysXPanelInterface.instance
			myPhysx.useGroundPlane		= true
			myPhysx.onLastFrame			= 2 --stop simulation on last frame
			myPhysx.useMultiThread		= true
	
			local myMassFX				= MassFX_RBody()
			myMassFX.type				= 2 --Kinematic
			myMassFX.switchType			= true
			myMassFX.switchTypeAtFrame	= 1 --Activate the mesh on first frame
	
			max modify mode
			addModifier $ (myMassFX) --Add the modifier to all selected objects
	
			nvpx.InitializePhysX
			nvpx.CreateToolbar()
			nvpx.ShowToolbar true
		)
	)
	on btn_removePhysicsModifier pressed do
	(
		if ($ == undefined) then MessageBox "Please Select the objects you selected\nat step 1! Will result into an error if you do not select those!"
		else (
		deletemodifier $ 1
		)
	)
	on btn_ApplyAllSettingsAndClearAll pressed do
	(
			sliderTime = 0f
			nvpx.ShowToolbar false
			DestroyDialog RunPhysX
	)
)

--
-- MAIN TAB
--
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Main Window */
	rollout SCToolSet_MainWindow "Basic Operations"
	(
		GroupBox 		grp_ColorOverrides 			"Color Overrides" 					pos:[8,1] 		width:117 	height:64
			button 		btn_ApplyGrey 				"Apply Grey Color" 					pos:[16,40] 	width:100 	height:17
			colorPicker theColor 					"" 									pos:[12,17] 	width:104 	height:17 color:[0,0,255] modal:true	

		GroupBox 		grp_PivotOperations 		"Pivot Operations" 					pos:[420,1] 	width:117 	height:86
			button 		btn_PivotCenterObject 		"Center Object" 					pos:[428,17] 	width:100 	height:17
			button 		btn_PivotWorldOrigin 		"World Origin" 						pos:[428,40] 	width:100 	height:17
			button 		btn_PivotCenterBottomObject "Bottom Object" 					pos:[428,63] 	width:100 	height:17

		GroupBox 		grp_Generators 				"Generators" 						pos:[132,1] 	width:117 	height:86
			button 		btn_StoneGenerator 			"Stone Generator" 					pos:[140,17] 	width:100 	height:17 enabled:true
			button 		btn_PlanksGenerator 		"Planks Generator" 					pos:[140,40] 	width:100 	height:17 enabled:true
			button 		btn_WallsGenerator 			"Walls Generator" 					pos:[140,63] 	width:100 	height:17 enabled:false
	

		GroupBox 		grp_BonesAndPhysics			"Bones / Physics" 					pos:[257,1] 	width:156 	height:86
			fn geometryFilter obj = (superClassOf obj == GeometryClass)
			pickbutton 	btn_AddBonePicker 			"Picker: Add Bone" 					pos:[265,17] 	width:140 	height:17 filter:geometryFilter
			checkbox 	chk_HideAfterPick 			"Hide after" 						pos:[266,41] 	width:80 	height:17
			button 		btn_UnhideAll 				"Unhide All" 						pos:[345,40] 	width:60 	height:17
			button 		btn_PhysicsEffects 			"Physics Effect Window" 			pos:[265,63] 	width:140 	height:17
		
		on SCToolSet_MainWindow open do (

		)
		-----------------------------------------------------------------------------------------------------------------------------Color Overrides:-------------------------------------------------------------------------------------------------------------------------
		on btn_ApplyGrey pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			else
			(
				for o in $ do (o.wirecolor = color 86 86 86)
				theColor.color = color 86 86 86
			)
		)
		on theColor changed new_col do
		(
			selection.wirecolor = new_col
		)
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------Pivot Operations:-------------------------------------------------------------------------------------------------------------------------
		on btn_PivotCenterObject pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			try
			(
				for obj in $ do 
				(
					CenterPivot obj
					WorldAlignPivot obj
				)
			)
			catch
			(
				CenterPivot $
				WorldAlignPivot $
			)
		)
		on btn_PivotWorldOrigin pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			try
			(
				for obj in $ do 
				(
					obj.pivot = [0,0,0]
					WorldAlignPivot obj
				)
			)
			catch
			(
				$.pivot = [0,0,0]
				WorldAlignPivot $
			)
		)
		on btn_PivotCenterBottomObject pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			else(
				for obj in $ do (
				obj.pivot = [(obj.max.x+obj.min.x)/2, (obj.max.y+obj.min.y)/2, obj.min.z]
				)
			)
		)
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------Generators:-----------------------------------------------------------------------------------------------------------------------------
		on btn_StoneGenerator pressed do
		(
			if RockGenerator.open == true then DestroyDialog RockGenerator
				else
			CreateDialog RockGenerator lockWidth:true lockHeight: true style:#(#style_toolwindow, #style_sysmenu)
		)
		on btn_PlanksGenerator pressed do
		(
			if PlankGenerator.open == true then DestroyDialog PlankGenerator
				else
			CreateDialog PlankGenerator lockWidth:true lockHeight: true style:#(#style_toolwindow, #style_sysmenu)
		)
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------Bones / Physics:-------------------------------------------------------------------------------------------------------------------------
		on btn_AddBonePicker picked obj do
		(
			setCommandPanelTaskMode #modify
			fn PrepareMaxForSkinOps TheToBeSkinnedNode = 
			(	
				if not TheToBeSkinnedNode.IsSelected do 
				(
					Select TheToBeSkinnedNode
				)
				if TheToBeSkinnedNode.IsFrozen do 
				(
					Unfreeze TheToBeSkinnedNode DoLayer:true
				)
				if ModPanel.GetCurrentObject() != TheToBeSkinnedNode.skin do 
				(
					ModPanel.SetCurrentObject TheToBeSkinnedNode.skin
				)
			)
			
			fn CalculateVolumeAndCenterOfMass obj =
			(
				local Volume	= 0.0
				local Center	= [0.0, 0.0, 0.0]
				local theMesh 	= snapshotasmesh obj
				local numFaces 	= theMesh.numfaces
				for i = 1 to numFaces do
					(
					  local Face	= getFace theMesh i
					  local vert2	= getVert theMesh Face.z
					  local vert1	= getVert theMesh Face.y
					  local vert0	= getVert theMesh Face.x
					  local dV = Dot (Cross (vert1 - vert0) (vert2 - vert0)) vert0
					  Volume+= dV
					  Center+= (vert0 + vert1 + vert2) * dV
					)
				delete theMesh
				Volume /= 6
				Center /= 24
				Center /= Volume
		
				return Center
			)
			
			BeginningNewBone = CalculateVolumeAndCenterOfMass $
			EndNewBone = (BeginningNewBone + [0,0,0.0001]) 
			b = boneSys.createBone BeginningNewBone EndNewBone [0,0,1]
			b.name = ("SC_Bone_" + $.name)
			b.width = 0.0003
			b.height = 0.0003
		
			skinmodifier = Skin()
			addmodifier $ skinmodifier
			PrepareMaxForSkinOps ($)
			skinOps.addBone $.modifiers[#Skin] b 1
			
			if chk_HideAfterPick.state == true do hide $
		)
		on btn_UnhideAll pressed do
			(max unhide all)
		on btn_PhysicsEffects pressed do
		(
			if (RunPhysX.open == true) then DestroyDialog RunPhysx
			else(
				CreateDialog RunPhysX lockWidth:true lockHeight: true style:#(#style_toolwindow, #style_sysmenu)
			)
		)
	)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Additional Tools Rollout */
	rollout AdditionalTools "Miscellaneous Tools"
	(
			button btn_ToggleSeeThrough 	"Toggle See-Through" 	pos:[140,5] width:129 height:17 toolTip:"Toggles the See-Through property of an object"
			button btn_OpenNotes 			"Notes" 				pos:[272,5] width:129 height:17 toolTip:"Opens the Notes of the current scene; persistent with each max file"
			button btn_DemolishTool 		"Demolish Tool" 		pos:[404,5] width:129 height:17 toolTip:"Opens the Mesh Demolisher window. Great for destructible objects!"
			button btn_ToggleObjectNames 	"Toggle Mesh Names" 	pos:[8,5] 	width:129 height:17 toolTip:"Toggles the object names above each object."
		
		on btn_ToggleObjectNames pressed do
		(
			global showNodeLabelsList
			if showNodeLabelsList == undefined then showNodeLabelsList = #()
					
			fn drawNodeLabels = (
				gw.setTransform (matrix3 1)		
				for i = showNodeLabelsList.count to 1 by -1 do (
					local obj = showNodeLabelsList[i]
					if (isValidNode obj)  then (
						if (not obj.isHiddenInVpt ) then (
							gw.text (obj.pos+[0,0,(obj.max.z)]) (obj.name as string) color:(color 255 10 25)
						)
					) else (
						deleteItem showNodeLabelsList i
					)
				)
				gw.enlargeUpdateRect #whole
				gw.updateScreen()
			)
			
			if (classOf showNodeLabelsList)==Array then
			(
				max select all
					if (selection.count==0) then (
						showNodeLabelsList = #()
					) else (
						-- some objects selected, toggle them in/out
						selnodes = selection as array
						for o in selnodes do (
							local i = findItem showNodeLabelsList o
							if i==0 then (
								append showNodeLabelsList o
							) else (
								deleteItem showNodeLabelsList i
							)
						) -- end: for o
					) -- end: else
					if showNodeLabelsList.count > 0 then (
						registerRedrawViewsCallback drawNodeLabels
					) else (
						unregisterRedrawViewsCallback drawNodeLabels
					)
					
					max views redraw
			) -- end: if classOf
			ClearSelection()
		)	
		on btn_ToggleSeeThrough pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			for obj in selection do (
				if (obj.xray == on) then obj.xray = off
				else (obj.xray = on)
			)
		)
		on btn_OpenNotes pressed do
		(
			if QuickNotes.open == true then DestroyDialog QuickNotes
				else				
			CreateDialog QuickNotes lockWidth:true lockHeight: true style:#(#style_toolwindow, #style_sysmenu) 
		)
		on btn_DemolishTool pressed do
		( 
			if DemolishMesh.open == true then DestroyDialog DemolishMesh
				else
			CreateDialog DemolishMesh lockWidth:true lockHeight: true style:#(#style_toolwindow, #style_sysmenu) 
		)
	)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Save/Backup Rollout */
	rollout SavesAndBackUps "Saving and Back-ups"
	(
		GroupBox 		grp_SaveAndBackUp 			"Auto-Save / BackUps" 		pos:[8,5] 		width:241 	height:65
			checkbox 	chk_AutoSave 				"AutoSave" 					pos:[16,23] 	width:88 	height:17 enabled:true
			spinner 	spn_AutoSaveMinutes 		"" 							pos:[194,23] 	width:46 	height:16 enabled:true range:[1,60,5] type:#integer
			button 		btn_CreateManual_BackUp 	"Create Manual BackUp" 		pos:[15,45] 	width:225 	height:17
			label 		lbl_InMinutesLabel 			"In Minutes:" 				pos:[135,24] 	width:57 	height:16
		
		on chk_AutoSave changed theState do
		(
			if (theState == true) then (
				MessageBox ("File will get saved every " + spn_AutoSaveMinutes.value as string + " minutes!")
				fn SaveFile = (
					local maxfile_filename = maxFileName
					if (maxFileName == "") then CheckForSave()
					else
					(
						local suffix = 1
						local filecount = 0
						local savefilepath = maxfilepath + "\_" + (substring maxfile_filename 1 (maxfilename.count-4)) + "_BackUps\\"
						if not (makeDir (savefilepath as String) all:true) do
						(
							MessageBox "Directory could not be created!\nDo you have write-access?"
						)
						local files = getfiles (savefilepath + "*.max")
						for f in files do
						(
							if ((FindString f (substring maxfile_filename 1 (maxfile_filename.count - 4))) != undefined) then
							(
								filecount += 1
									if (filecount == 10) then
									(
										for f in files do deleteFile f
											filecount = 0
									)
							)
						)
						suffix = filecount
						maxfile_filename = "Old_" + (substring maxfile_filename 1 (maxfilename.count-4)) + "_" + (suffix as string)
						if not doesFileExist (savefilepath + maxfile_filename) do
						(
							if not (saveMaxFile (savefilepath + maxfile_filename) useNewFile:false quiet:true) do
							(
								print "Could not save the backup file!!"
							)
						)
					)
				)
				
				dotnet.addEventHandler theTimer "tick" SaveFile
				theTimer.interval = (spn_AutoSaveMinutes.value * 60000)
				theTimer.start() 
			)
			else ( theTimer.stop() )
		)
		on btn_CreateManual_BackUp pressed do
		(
			local maxfile_filename = maxFileName
			if (maxFileName == "") then CheckForSave()
			else
			(
				local suffix = 1
				local filecount = 0
				local savefilepath = maxfilepath + "\_" + (substring maxfile_filename 1 (maxfilename.count-4)) + "_BackUps\\"
				if not (makeDir (savefilepath as String) all:true) do
				(
					MessageBox "Directory could not be created!\nDo you have write-access?"
				)
				local files = getfiles (savefilepath + "*.max")
				for f in files do
				(
					if ((FindString f (substring maxfile_filename 1 (maxfile_filename.count - 4))) != undefined) then
					(
						filecount += 1
							if (filecount == 10) then
							(
								for f in files do deleteFile f
									filecount = 0
							)
					)
				)
				suffix = filecount
				maxfile_filename = "Old_" + (substring maxfile_filename 1 (maxfilename.count-4)) + "_" + (suffix as string)
				if not doesFileExist (savefilepath + maxfile_filename) do
				(
					if not (saveMaxFile (savefilepath + maxfile_filename) useNewFile:false quiet:true) do
					(
						print "Could not save the backup file!!"
					)
				)
			)	
		)
	)
--
-- WHITEBOX IMPORTER TAB
--
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Jrome90's Whitebox Importer rollout */
	rollout xmlreader "HeroEngine WhiteBox Importer"
	(
		edittext 	edt_xml 			"" 														pos:[4,32] 		width:474 height:600
		button 		btn_xml_clear 		"Clear" 												pos:[350,8] 	width:129 height:16
		button 		btn_xml_apply 		"Apply" 												pos:[319,640] 	width:160 height:16 enabled:false
		button 		btn_xml_verify 		"Verify" 												pos:[7,640] 	width:160 height:16
		label 		lbl_xml_information "Paste your generated code from HeroEngine in here:" 	pos:[8,8] 		width:272 height:16

		on btn_xml_clear pressed do
		(
			edt_xml.text = ""
		)
		on btn_xml_apply pressed do
		(
			global xmldoc = dotnetobject "System.XML.XMLDocument"
			xmldoc.load (GetDir #scripts + "\Projects\TempWhiteBox.xml")
			
			itemIter = (xmldoc.selectnodes "/Root/Item").GetEnumerator()
			while itemIter.MoveNext() do
			(
				attrIter	= itemIter.Current.Attributes.GetEnumerator()
				_Name		= itemIter.Current.getAttribute "Name" as string
				_length 	= itemIter.Current.getAttribute "length" as float
				_width		= itemIter.Current.getAttribute "width" as float
				_height 	= itemIter.Current.getAttribute "height" as float
				_radius		= itemIter.Current.getAttribute "radius" as float
				_radius1	= itemIter.Current.getAttribute "radius1" as float
				_radius2	= itemIter.Current.getAttribute "radius2" as float
				_depth		= itemIter.Current.getAttribute "depth" as float
				pos_x 		= itemIter.Current.getAttribute "x" as float
				pos_y 		= itemIter.Current.getAttribute "y" as float
				pos_z 		= itemIter.Current.getAttribute "z" as float
				
				/*
					IMPORTANT NOTICE: HeroEngine uses a different axes-sytem, and this is why the pos_z and pos_y have been changed to make the fit accordingly to 3DS MAX
				*/
				if ( _Name == "Cube" ) then (
					__cube = box length:_length width:_width height:_height pos:[pos_x,-pos_z,-pos_y] wirecolor:[255,255,255]
					__cube.name = uniquename ("PN_" + _Name)
				)
				if (_Name == "Cone" ) then (
					__cone = Cone smooth:on heightsegs:1 capsegs:1 sides:24 height:_height radius1:_radius1 radius2:_radius2 pos:[pos_x,-pos_z,-pos_y] wirecolor:[255,255,255]
					__cone.name = uniquename ("PN_" + _Name)
					)
				if (_Name == "Cylinder" ) then (
					__cylinder = Cylinder smooth:on heightsegs:1 capsegs:1 sides:18 height:_height radius:_radius pos:[pos_x,-pos_z,-pos_y] wirecolor:[255,255,255]
					__cylinder.name = uniquename ("PN_" + _Name)
					)
				if (_Name == "Sphere" ) then (
					__sphere = Sphere radius:_radius smooth:on segs:32 chop:0 slice:off sliceFrom:0 sliceTo:0  recenter:off pos:[pos_x,-pos_z,(-(pos_y) + _radius)] wirecolor:[255,255,255]
					__sphere.name = uniquename ("PN_" + _Name)
					)
				if (_Name == "Pyramid" ) then (
					__pyramid = Pyramid widthsegs:1 depthSegs:1 heightsegs:1 width:_width depth:_depth height:_height pos:[pos_x,-pos_z,-pos_y] wirecolor:[255,255,255]
					__pyramid.name = uniquename ("PN_" + _Name)
					)
			)
			fileclass = DotNetclass "System.IO.File"
			fileClass.Delete (((getDir #scripts) + "\Projects\TempWhiteBox.xml") as string)
			max tool zoomextents all
			edt_xml.text = ""
			btn_xml_apply.enabled = false
		)
		on btn_xml_verify pressed do (
			fileclass = DotNetclass "System.IO.File"
			temporaryFile = (((getDir #scripts) + "\Projects\TempWhiteBox.xml") as string)
			
			fileclass.WriteAllText temporaryFile edt_xml.text
		
			btn_xml_apply.enabled = true
		)
	)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* HeroEngine Tools */
	rollout GameEngineTools_HeroEngine "HeroEngine Tools"
	(
		GroupBox		grp_GET_HE_Instructions			"Tool Instructions"				pos:[8,5]		width:396	height:65
			label		lbl_GET_HE_Instruction_Occluder "The Occluder group checks for a single selected mesh if it has the occlusion \nproperty for HeroEngine. The views will show additional information for analyzing your materials and meshes." pos:[16,23] height:45 width:380
		GroupBox		grp_GET_HE_QuickLinks			"Quick Hyperlinks"				pos:[412,5] width:323 height:65
			Hyperlink	Hyperlink_HEWIKI				"HeroEngine Wiki"				pos:[422,20] address:"http://wiki.heroengine.com/wiki/Main_Page" color:[250,250,50]
				label	HEWIKI_LABEL					"- HE knowledge-center" 		pos:[550,20]
			Hyperlink	Hyperlink_HECommunity			"HeroEngine Community"			pos:[422,36] address:"https://community.heroengine.com/forums/index.php" color:[250,250,50]
				label	HECOMMUNITY_LABEL				"- HE Main Forums and reports"	pos:[550,36]
			Hyperlink	Hyperlink_HEMain				"HeroEngine Main"				pos:[422,52] address:"https://www.heroengine.com/" color:[250,250,50]
				label	HEMAIN_LABEL					"- HeroEngine's product site"	pos:[550,52]
		
		GroupBox			grp_GET_HE_MaterialAnalyzing				"Material Analyzer per mesh"		pos:[8,75]		width:728	height:186
			dotNetControl 	lv_objects 									"System.Windows.Forms.ListView" 	pos:[16,93]		width:574 	height:160  align:#left
			GroupBox 		HE_MAterial_Explanations					 "Color Legend"						pos:[598,87]	width:128	height:74
				Hyperlink 	define_color_red 							 "HeroMaterial errors!"				pos:[606,102]							color:[255,0,0] 	enabled:false
				Hyperlink 	define_color_yellow 						 "Not a HeroMaterial" 				pos:[606,122]							color:[255,255,0] 	enabled:false
				Hyperlink 	define_color_green 							 "HeroMaterial will show" 			pos:[606,142]							color:[144,238,100] enabled:false
			GroupBox 		HE_Material_ListButtons						 "List actions"						pos:[598,170]	width:128	height:83
				button 		btn_HEMaterialInspector_SelectAllObjects 	"Select All Objects" 				pos:[606,195] 	width:112 	height:18
				button 		btn_HEMaterialInspector_Refresh 		 	"REFRESH LIST" 						pos:[606,222] 	width:112 	height:18		
				
		GroupBox			grp_GET_HE_MeshAnalyzing					"Mesh Analyzer"						pos:[8,267]		width:728	height:184
			dotNetControl 	lv_meshes 									"System.Windows.Forms.ListView" 	pos:[16,285]	width:324 	height:160  align:#left
			GroupBox		HE_Meshes_Explanations						"Color Legend"						pos:[350,279]	width:134	height:54
				Hyperlink 	define_color_green_meshes					"Mesh has no errors!"	 			pos:[358,295]							color:[144,238,100] enabled:false
				Hyperlink 	define_color_red_meshes						"Mesh has Errors!!"		 			pos:[358,312]							color:[255,0,0] enabled:false
			GroupBox 		grp_GET_HE_MeshProperties 					"Occluder Properties"				pos:[350,334]	width:134 	height:42
				button 		btn_GET_HE_TurnIntoOccluder 				"Toggle Occlusion"		 			pos:[358,350] 	width:117 	height:18 toolTip:"This will add the occluder=true property in the UD. Toggles."
			GroupBox 		grp_GET_HE_ErrorFixes 						"Error Fixes" 						pos:[350,380] 	width:134 	height:65
				button 		btn_GET_HE_ClearUD 							"Clear All User Defines"			pos:[358,395] 	width:117 	height:18 toolTip:"Clears all User Defined properties."
				button 		btn_GET_HE_XFormAdd 						"Reset XForm" 						pos:[358,420] 	width:117 	height:18
				
		GroupBox			grp_MeshAnalyzer_BeforeExporting			"Quick Checks Before Exporting"		pos:[492,279]	width:234	height:166
			label			lbl_BeforeExporting_Step1					"1. Are all Rows green?" 			pos:[500,295] 	width:220 	height:18
			label			lbl_BeforeExporting_Step2					"2. If you are not using occluders, make sure to select all objects and clear all User Defined properties, just to be sure!" pos:[500,312] width:220 height:45
			label			lbl_BeforeExporting_Step3					"3. Are all your naming conventions correct? Think about mesh-names and material names." pos:[500,355] width:200 height:45

		fn initMeshView lvs =
		(
			lvs.View = (dotNetClass "System.Windows.Forms.View").Details
			lvs.gridLines = true
			lvs.fullRowSelect = true
			lvs.HideSelection=true -- When this ListView loses the focus, it will still show what's selected
			lvs.HeaderStyle=lvs.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable 
			layout_def_meshes = #("Mesh Name", "Occluder", "Errors")
			lvs.Columns.add layout_def_meshes[1] 150
			lvs.Columns.add layout_def_meshes[2] 70
			lvs.Columns.add layout_def_meshes[3] 100
		)
		
		fn fillInMeshes lv =
		(
			theRange = #()
			for o in Geometry do
			(
				SelectedNode = getUserPropBuffer o
				CharactersInUD = SelectedNode as string
				CharacterCountInUD = CharactersInUD.count
				-- Object name Column
				li = dotNetObject "System.Windows.Forms.ListViewItem" o.name
				Colors = DotNetClass "System.Drawing.Color"
				-- Occluder Column
				if (matchPattern SelectedNode pattern:"*occluder=true*" == 		false	) do (sub_li_Occluder = li.SubItems.add ("--")		)
				if (matchPattern SelectedNode pattern:"*occluder=true*" == 		true	) do (sub_li_Occluder = li.SubItems.add ("Occluder"))
				-- Error Column
				if (CharacterCountInUD == 0) then (sub_li_Errors = li.Subitems.add ("None"))
				else if (CharacterCountInUD == 13 or CharacterCountInUD == 14) then (sub_li_Errors = li.subitems.add ("None"))
				else (sub_li_Errors = li.Subitems.add ("Error Found!"))

 				if (sub_li_Errors.text == "None") then (li.BackColor = Colors.LightGreen) else (li.BackColor = Colors.Red)
					
				append theRange li
			)
			lv.Items.AddRange theRange
		)
		fn initListView lv =
		(
			lv.View = (dotNetClass "System.Windows.Forms.View").Details
			lv.gridLines = true
			lv.fullRowSelect = true
			lv.HideSelection=true -- When this ListView loses the focus, it will still show what's selected
			lv.HeaderStyle=lv.HeaderStyle.Nonclickable -- Flattens the headers a bit (although they're still somewhat 3D) and keeps them from being clickable 
			layout_def = #("Mesh Name", "HE-Material", "Contains spaces", "In HE-Directory", "HE-Directory contains spaces")
			lv.Columns.add layout_def[1] 150
			lv.Columns.add layout_def[2] 70
			lv.Columns.add layout_def[3] 100
			lv.Columns.add layout_def[4] 90
			lv.Columns.add layout_def[5] 160
		)

		fn fillInSpreadSheet lv =
		(
			theRange = #()
			for o in Geometry do
			(
				SelectedNode = getUserPropBuffer o
				-- Object name Column
				li = dotNetObject "System.Windows.Forms.ListViewItem" o.name
				Colors = DotNetClass "System.Drawing.Color"
				-- H-Material
				if (o.material == undefined) then (sub_li_HeroMaterial = li.SubItems.add ("Undefined"))
					else(
						if (matchPattern (o.material as string) pattern:"*:Hero" ignoreCase:false == false	) do (sub_li_HeroMaterial = li.SubItems.add ("No")		)
						if (matchPattern (o.material as string) pattern:"*:Hero" ignoreCase:false == true	) do (sub_li_HeroMaterial = li.SubItems.add ("Yes")		)
					)
				-- H-Material Spaces
				if (o.material == undefined) then (sub_li_MaterialSpaces = li.SubItems.add ("Undefined"))
					else(
						if (matchPattern (o.material as string) pattern:"* *" ignoreCase:false == false	) do (sub_li_MaterialSpaces = li.SubItems.add ("No")		)
						if (matchPattern (o.material as string) pattern:"* *" ignoreCase:false == true	) do (sub_li_MaterialSpaces = li.SubItems.add ("Yes")		)
					)					
				-- H-Material Directory
				if (o.material == undefined or o.material.Diffuse == undefined) then (sub_li_MaterialDirectory = li.SubItems.add ("Undefined"))
					else(
						if (matchPattern (o.material.Diffuse.filename as string) 	pattern:"*HE\*" ignoreCase:false == false	) do (sub_li_MaterialDirectory = li.SubItems.add ("No")		)
						if (matchPattern (o.material.Diffuse.filename as string) 	pattern:"*HE\*" ignoreCase:false == true	) do (sub_li_MaterialDirectory = li.SubItems.add ("Yes")	)
					)					
				-- H-Material Directory Spaces
				if (o.material == undefined or o.material.Diffuse == undefined) then (sub_li_MaterialDirectorySpaces = li.SubItems.add ("Undefined"))
					else(
						if (matchPattern (o.material.Diffuse.filename as string) 	pattern:"* *" ignoreCase:false == false	) do (sub_li_MaterialDirectorySpaces = li.SubItems.add ("No")		)
						if (matchPattern (o.material.Diffuse.filename as string) 	pattern:"* *" ignoreCase:false == true	) do (sub_li_MaterialDirectorySpaces = li.SubItems.add ("Yes")		)	
					)	
				if (sub_li_HeroMaterial.text == "No" 		or 	sub_li_MaterialSpaces.text == "Yes" 		or 	sub_li_MaterialDirectory.text == "No" 			or 	sub_li_MaterialDirectorySpaces.text == "Yes"		) then (li.BackColor = Colors.Red)
				if (sub_li_HeroMaterial.text == "Yes" 		and sub_li_MaterialSpaces.text == "No" 			and sub_li_MaterialDirectory.text == "Yes" 			and sub_li_MaterialDirectorySpaces.text == "No"			) then (li.BackColor = Colors.LightGreen)
				if (sub_li_HeroMaterial.text == "Undefined" and sub_li_MaterialSpaces.text == "Undefined" 	and sub_li_MaterialDirectory.text == "Undefined" 	and sub_li_MaterialDirectorySpaces.text == "Undefined"	) then (li.BackColor = Colors.Yellow)
					
				append theRange li
			)
			lv.Items.AddRange theRange
		)
		
		fn RefreshAllLists = (
			lv_objects.Items.Clear()
			lv_meshes.Items.Clear()
			max select all
			fillInSpreadSheet lv_objects
			fillInMeshes lv_meshes
			ClearSelection()
		)	
		
		on GameEngineTools_HeroEngine open do (
			max select all
			initListView lv_objects
			initMeshView lv_meshes
			fillInSpreadSheet lv_objects
			fillInMeshes lv_meshes
			ClearSelection()
		)
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------Error Fixes:-----------------------------------------------------------------------------------------------------------------------------
		on btn_GET_HE_ClearUD pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			else
			(
				for obj in selection do
				(
				setuserpropbuffer (getcurrentselection()) ""
				)
				print "User Defines: Cleared!"
				RefreshAllLists()
			)
		)
		on btn_GET_HE_XFormAdd pressed do
		(
			if ($ == undefined) then Messagebox "SnowCloud ToolSet Error: No Objects Selected. \nFix: Select at least 1 object."
			else
			(
				for obj in selection do
				(
					xformmod = XForm()
					addModifier obj xformmod
				)
				print "XForm Succesfully added to selection!"
			)
		)
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------Occluders:-----------------------------------------------------------------------------------------------------------------------------
		on btn_GET_HE_TurnIntoOccluder pressed do
		(
			for o in selection do
			(
				OriginalNode	= getUserPropBuffer o
				Occluder_prop	= "occluder=true"
				if matchPattern OriginalNode pattern:"*occluder=true*" == false do
				( 
					setUserPropBuffer o Occluder_prop
				)
				if matchPattern OriginalNode pattern:"*occluder=true*" == true do (
					bad_start	=	findString OriginalNode Occluder_prop
					new_prop	=	substring OriginalNode 1 (bad_start-1)
									setUserPropBuffer o new_prop
				)
			)
			RefreshAllLists()
		)
		-- Material checker
		on btn_HEMaterialInspector_Refresh pressed do
		(
			RefreshAllLists()
		)
		on lv_objects MouseClick arg do (
			hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
			theObject = getnodebyname(hit.item.text)
			select theObject
			max tool zoomextents all
		)
		on lv_objects MouseDoubleClick arg do (
			hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
			theObject = getnodebyname(hit.item.text)
			select theObject
			actionMan.executeAction 0 "40022"  -- Edit: Properties
		)
		on lv_meshes MouseClick arg do (
			hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
			theObject = getnodebyname(hit.item.text)
			select theObject
			max tool zoomextents all
		)
		on lv_meshes MouseDoubleClick arg do (
			hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
			theObject = getnodebyname(hit.item.text)
			select theObject
			actionMan.executeAction 0 "40022"  -- Edit: Properties
		)
		on btn_HEMaterialInspector_SelectAllObjects pressed do (
			max select all
			max tool zoomextents all
		)
	)
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Esenthel Engine toolset rollout (bone renamer only) */
	rollout GameEngineTools_Esenthel "Esenthel Engine Tools"
	(
		button btn_GET_EE_RenameBones "Rename All Bones" pos:[8,8] width:121 height:17 toolTip:"Renames a Bip001 bone structure to the Esenthel Naming conventions."
		on btn_GET_EE_RenameBones pressed do
		(
			_EmptyBone = GetNodeByName ""
			if (not _EmptyBone == undefined) then 
				_EmptyBone.name = "Root"
			else ( print "Root not found" )
			
			_Pelvis = GetNodeByName "Bip001 Pelvis"
			if (not _Pelvis == undefined) then 
				_Pelvis.name = "Body"
			else ( print "Pelvis not found" )
			
			_Spine = GetNodeByName "Bip001 Spine"
			if (not _Spine == undefined) then 
				_Spine.name = "Body0"
			else ( print "Spine not found" )
			
			_Spine1 = GetNodeByName "Bip001 Spine1"
			if (not _Spine1 == undefined) then 
				_Spine1.name = "BodyU"
			else ( print "Spine1 not found" )
			
			_Spine2 = GetNodeByName "Bip001 Spine2"
			if (not _Spine2 == undefined) then 
				_Spine2.name = "BodyU0"
			else ( print "Spine2 not found" )
			
			_Spine3 = GetNodeByName "Bip001 Spine3"
			if (not _Spine3 == undefined) then 
				_Spine3.name = "BodyU1"
			else ( print "Spine3 not found" )
			
			_Neck = GetNodeByName "Bip001 Neck"
			if (not _Neck == undefined) then 
				_Neck.name = "Neck"
			else ( print "Neck not found" )
	
			_Head = GetNodeByName "Bip001 Head"
			if (not _Head == undefined) then 
				_Head.name = "Head"
			else ( print "Head not found" )
			
			_Footsteps = GetNodeByName "Bip001 Footsteps"
			if (not _Footsteps == undefined) then 
				_Footsteps.name = "Footsteps"
			else ( print "Footsteps not found" )
			
			_R_Clavicle = GetNodeByName "Bip001 R Clavicle"
			if (not _R_Clavicle == undefined) then 
				_R_Clavicle.name = "ShoulderR"
			else ( print "ShoulderR not found" )
			
			_L_Clavicle = GetNodeByName "Bip001 L Clavicle"
			if (not _L_Clavicle == undefined) then 
				_L_Clavicle.name = "ShoulderL"
			else ( print "ShoulderL not found" )
			
			_R_UpperArm = GetNodeByName "Bip001 R UpperArm"
			if (not _R_UpperArm == undefined) then 
				_R_UpperArm.name = "ArmRU"
			else ( print "ArmRU not found" )
			
			_L_UpperArm = GetNodeByName "Bip001 L UpperArm"
			if (not _L_UpperArm == undefined) then 
				_L_UpperArm.name = "ArmLU"
			else ( print "ArmLU not found" )
			
			_R_Forearm = GetNodeByName "Bip001 R Forearm"
			if (not _R_Forearm == undefined) then 
				_R_Forearm.name = "ArmRD"
			else ( print "ArmRD not found" )
			
			_L_Forearm = GetNodeByName "Bip001 L Forearm"
			if (not _L_Forearm == undefined) then 
				_L_Forearm.name = "ArmLD"
			else ( print "ArmLD not found" )
			
			_R_Thigh = GetNodeByName "Bip001 R Thigh"
			if (not _R_Thigh == undefined) then 
				_R_Thigh.name = "LegRU"
			else ( print "LegRU not found" )
			
			_L_Thigh = GetNodeByName "Bip001 L Thigh"
			if (not _L_Thigh == undefined) then 
				_L_Thigh.name = "LegLU"
			else ( print "LegLU not found" )
			
			_R_Calf = GetNodeByName "Bip001 R Calf"
			if (not _R_Calf == undefined) then 
				_R_Calf.name = "LegRD"
			else ( print "LegRD not found" )
			
			_L_Calf = GetNodeByName "Bip001 L Calf"
			if (not _L_Calf == undefined) then 
				_L_Calf.name = "LegLD"
			else ( print "LegLD not found" )
			
			_R_Hand = GetNodeByName "Bip001 R Hand"
			if (not _R_Hand == undefined) then 
				_R_Hand.name = "HandR"
			else ( print "HandR not found" )
			
			_L_Hand = GetNodeByName "Bip001 L Hand"
			if (not _L_Hand == undefined) then 
				_L_Hand.name = "HandL"
			else ( print "HandL not found" )
			
			_R_Foot = GetNodeByName "Bip001 R Foot"
			if (not _R_Foot == undefined) then 
				_R_Foot.name = "FootR"
			else ( print "FootR not found" )
			
			_L_Foot = GetNodeByName "Bip001 L Foot"
			if (not _L_Foot == undefined) then 
				_L_Foot.name = "FootL"
			else ( print "FootL not found" )
			
			_R_Toe0 = GetNodeByName "Bip001 R Toe0"
			if (not _R_Toe0 == undefined) then 
				_R_Toe0.name = "FootR0"
			else ( print "FootR0 not found" )
			
			_L_Toe0 = GetNodeByName "Bip001 L Toe0"
			if (not _L_Toe0 == undefined) then 
				_L_Toe0.name = "FootL0"
			else ( print "FootL0 not found" )
			
			_R_Finger0 = GetNodeByName "Bip001 R Finger0"
			if (not _R_Finger0 == undefined) then 
				_R_Finger0.name = "FingerR00"
			else ( print "FingerR00 not found" )
			
			_L_Finger0 = GetNodeByName "Bip001 L Finger0"
			if (not _L_Finger0 == undefined) then 
				_L_Finger0.name = "FingerL00"
			else ( print "FingerL00 not found" )
			
			_R_Finger01 = GetNodeByName "Bip001 R Finger01"
			if (not _R_Finger01 == undefined) then 
				_R_Finger01.name = "FingerR01"
			else ( print "FingerR01 not found" )
			
			_L_Finger01 = GetNodeByName "Bip001 L Finger01"
			if (not _L_Finger01 == undefined) then 
				_L_Finger01.name = "FingerL01"
			else ( print "FingerL01 not found" )
			
			_R_Finger02 = GetNodeByName "Bip001 R Finger02"
			if (not _R_Finger02 == undefined) then 
				_R_Finger02.name = "FingerR02"
			else ( print "FingerR02 not found" )
			
			_L_Finger02 = GetNodeByName "Bip001 L Finger02"
			if (not _L_Finger02 == undefined) then 
				_L_Finger02.name = "FingerL02"
			else ( print "FingerL02 not found" )
	
			_R_Finger1 = GetNodeByName "Bip001 R Finger1"
			if (not _R_Finger1 == undefined) then 
				_R_Finger1.name = "FingerL10"
			else ( print "FingerL10 not found" )
			
			_R_Finger11 = GetNodeByName "Bip001 R Finger11"
			if (not _R_Finger11 == undefined) then 
				_R_Finger11.name = "FingerR11"
			else ( print "FingerR11 not found" )
			
			_L_Finger11 = GetNodeByName "Bip001 L Finger11"
			if (not _L_Finger11 == undefined) then 
				_L_Finger11.name = "FingerL11"
			else ( print "FingerL11 not found" )
			
			_R_Finger12 = GetNodeByName "Bip001 R Finger12"
			if (not _R_Finger12 == undefined) then 
				_R_Finger12.name = "FingerR12"
			else ( print "FingerR12 not found" )
			
			_L_Finger12 = GetNodeByName "Bip001 L Finger12"
			if (not _L_Finger12 == undefined) then 
				_L_Finger12.name = "FingerL12"
			else ( print "FingerL12 not found" )
			
			_R_Finger2 = GetNodeByName "Bip001 R Finger2"
			if (not _R_Finger2 == undefined) then 
				_R_Finger2.name = "FingerR20"
			else ( print "FingerR20 not found" )
			
			_L_Finger2 = GetNodeByName "Bip001 L Finger2"
			if (not _L_Finger2 == undefined) then 
				_L_Finger2.name = "FingerL20"
			else ( print "FingerL20 not found" )
			
			_R_Finger21 = GetNodeByName "Bip001 R Finger21"
			if (not _R_Finger21 == undefined) then 
				_R_Finger21.name = "FingerR21"
			else ( print "FingerR21 not found" )
			
			_L_Finger21 = GetNodeByName "Bip001 L Finger21"
			if (not _L_Finger21 == undefined) then 
				_L_Finger21.name = "FingerL21"
			else ( print "FingerL21 not found" )
			
			_R_Finger22 = GetNodeByName "Bip001 R Finger22"
			if (not _R_Finger22 == undefined) then 
				_R_Finger22.name = "FingerR22"
			else ( print "FingerR22 not found" )
			
			_L_Finger22 = GetNodeByName "Bip001 L Finger22"
			if (not _L_Finger22 == undefined) then 
				_L_Finger22.name = "FingerL22"
			else ( print "FingerL22 not found" )
			
			_R_Finger3 = GetNodeByName "Bip001 R Finger3"
			if (not _R_Finger3 == undefined) then 
				_R_Finger3.name = "FingerR30"
			else ( print "FingerR30 not found" )
			
			_L_Finger3 = GetNodeByName "Bip001 L Finger3"
			if (not _L_Finger3 == undefined) then 
				_L_Finger3.name = "FingerL30"
			else ( print "FingerL30 not found" )
			
			_R_Finger31 = GetNodeByName "Bip001 R Finger31"
			if (not _R_Finger31 == undefined) then 
				_R_Finger31.name = "FingerR31"
			else ( print "FingerR31 not found" )
			
			_L_Finger31 = GetNodeByName "Bip001 L Finger31"
			if (not _L_Finger31 == undefined) then 
				_L_Finger31.name = "FingerL31"
			else ( print "FingerL31 not found" )
			
			_R_Finger32 = GetNodeByName "Bip001 R Finger32"
			if (not _R_Finger32 == undefined) then 
				_R_Finger32.name = "FingerR32"
			else ( print "FingerR32 not found" )
			
			_L_Finger32 = GetNodeByName "Bip001 L Finger32"
			if (not _L_Finger32 == undefined) then 
				_L_Finger32.name = "FingerL32"
			else ( print "FingerL32 not found" )
			
			_R_Finger4 = GetNodeByName "Bip001 R Finger4"
			if (not _R_Finger4 == undefined) then 
				_R_Finger4.name = "FingerR40"
			else ( print "FingerR40 not found" )
			
			_L_Finger4 = GetNodeByName "Bip001 L Finger4"
			if (not _L_Finger4 == undefined) then 
				_L_Finger4.name = "FingerL40"
			else ( print "FingerL40 not found" )
			
			_R_Finger41 = GetNodeByName "Bip001 R Finger41"
			if (not _R_Finger41 == undefined) then 
				_R_Finger41.name = "FingerR41"
			else ( print "FingerR41 not found" )
			
			_L_Finger41 = GetNodeByName "Bip001 L Finger41"
			if (not _L_Finger41 == undefined) then 
				_L_Finger41.name = "FingerL41"
			else ( print "FingerL41 not found" )
			
			_R_Finger42 = GetNodeByName "Bip001 R Finger42"
			if (not _R_Finger42 == undefined) then 
				_R_Finger42.name = "FingerR42"
			else ( print "FingerR42 not found" )
			
			_L_Finger42 = GetNodeByName "Bip001 L Finger42"
			if (not _L_Finger42 == undefined) then 
				_L_Finger42.name = "FingerL42"
			else ( print "FingerL42 not found" )
		)
	)
--
-- TAB ORDER AND NAMING
--
	SCTabs_Rollouts =
	#(
		#("Main"						,#(SCToolSet_MainWindow,AdditionalTools,SavesAndBackUps	)),
		#("WhiteBox Importer"	,#(xmlreader																	)),
		#("Game Engine Tools"	,#(GameEngineTools_HeroEngine,GameEngineTools_Esenthel	))
	)
--
-- MAIN ROLLOUT 
--
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/* Main Rollout (tabbed view) */
	rollout SCTabs "PNToolSet: Main"
	(
		dotNetControl dn_tabs "System.Windows.Forms.TabControl" height:20 width:550 align:#left
		subRollout theSubRollout width:560 height:283 align:#left
		on dn_tabs Selected itm do
		(
			if (itm.TabPageIndex == 0) then -- main toolkit
			(	
				SCTabs.title = "PN ToolSet: Main"
				SCTabs.width = 586
				SCTabs.height = 330
				theSubRollout.width = 560
				theSubRollout.height = 283
			)
			if (itm.TabPageIndex == 1) then -- WhiteBox Importer
			(	
				SCTabs.title = "PN ToolSet: WhiteBox Importer"
				SCTabs.width = 526
				SCTabs.height = 740
				theSubRollout.width = 500
				theSubRollout.height = 691
			)
			if (itm.TabPageIndex == 2) then -- Game Engine Tools
			(	
				SCTabs.title = "PN ToolSet: Game Engine Tools"
				SCTabs.width = 786
				SCTabs.height = 550
				theSubRollout.width = 760
				theSubRollout.height = 504
			)
			if LastSubRollout != (itm.TabPageIndex+1) do --do not update if the same tab is clicked while the tab is active already
			(
				for subroll in SCTabs_Rollouts[LastSubRollout][2] do
					removeSubRollout theSubRollout subroll
				for subroll in SCTabs_Rollouts[LastSubRollout = itm.TabPageIndex+1][2] do
					addSubRollout theSubRollout subroll
			)
		)--end tabs clicked

		on SCTabs open do
		(
			-- Set starting width
			SCTabs.width = 586
			SCTabs.height = 330
			
			for aTab in SCTabs_Rollouts do
			(
				dn_tabs.TabPages.add aTab[1]
			)
			for subroll in SCTabs_Rollouts[1][2] do
			(
				addSubRollout theSubRollout subroll
			)
		)
		on SCTabs close do
		(
			deleteAllChangeHandlers
		)
	)
		createDialog SCTabs lockWidth:true lockHeight:true style:#(#style_border, #style_titlebar, #style_minimizebox, #style_sysmenu, #style_sunkenedge)