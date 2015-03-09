Scriptname zBFSSKYUIConfig extends SKI_ConfigBase  

;;; SCRIPT VERSION
int function GetVersion()
    return 3	;; Current version (3 = 3.6)
endFunction

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int	_BFSActiveOID_B
int	_BFSPeltOID_B
int	_BFSFoodOID_B
int	_BFSZombiesOID_B
int	_BFSWeaponsOID_T
int	_BFSPoisonOID_T
int	_BFSSteamOID_B
int	_BFSsliderPCOID_S
int	_BFSsliderPCR2OID_S
int	_BFSsliderNPCOID_S
int	_BFSsliderNPCR2OID_S
int	_BFSsliderExtraOID_S

; State
bool	_BFSActive					= true
bool	_BFSPelt					= true
bool	_BFSFood					= true
bool	_BFSZombies				= false
bool	_BFSSteam					= true
int		_BFSWeapons				= 1
int		_BFSPoison					= 1
float	_BFSsliderPCPercent			= 5.0
float	_BFSsliderPCR2Percent		= 100.0
float	_BFSsliderNPCPercent		= 5.0
float	_BFSsliderNPCR2Percent		= 100.0
float	_BFSsliderExtraPercent		= 30.0
bool	BFSResetMsg				= false

string	BFSversion					= "3.6"
string[] WeaponList
string[] PoisonList
string[] ActiveList

; Global variables
GlobalVariable Property BFSEffectsActivated Auto
GlobalVariable Property BFSEffectsPelts Auto
GlobalVariable Property BFSEffectsMeat Auto
GlobalVariable Property BFSEffectsZombies Auto
GlobalVariable Property BFSEffectsWeapons Auto
GlobalVariable Property BFSEffectsPoison Auto
GlobalVariable Property BFSEffectsSteam Auto
GlobalVariable Property BFSEffectsChance Auto
GlobalVariable Property BFSEffectsChanceRank2 Auto
GlobalVariable Property BFSEffectsChanceNPC Auto
GlobalVariable Property BFSEffectsChanceNPCRank2 Auto
GlobalVariable Property BFSEffectsChanceExtra Auto
; Quest
Quest property BFSEffectsQuest Auto
; Spell
Spell property BFSEffectsCloakSpell auto
; Player
Actor Property PlayerRef Auto

;; ==== Functions ====
; Make changes
Function ApplySettings()
	BFSEffectsPelts.SetValue(_BFSPelt as int)
	BFSEffectsMeat.SetValue(_BFSFood as int)
	BFSEffectsZombies.SetValue(_BFSZombies as int)
	BFSEffectsWeapons.SetValue(_BFSWeapons)
	BFSEffectsPoison.SetValue(_BFSPoison)
	BFSEffectsSteam.SetValue(_BFSSteam as int)

	BFSEffectsChance.SetValue(_BFSsliderPCPercent) 
	BFSEffectsChanceRank2.SetValue(_BFSsliderPCR2Percent) 
	BFSEffectsChanceNPC.SetValue(_BFSsliderNPCPercent) 
	BFSEffectsChanceNPCRank2.SetValue(_BFSsliderNPCR2Percent) 
	BFSEffectsChanceExtra.SetValue(_BFSsliderExtraPercent) 
 
	if BFSResetMsg == true
		if (_BFSActive == false)
			BFSEffectsActivated.SetValue(0)
			BFSEffectsQuest.Stop()
			utility.wait(1)
			PlayerRef.DispelSpell(BFSEffectsCloakSpell)
			Debug.Notification("$ActivateMsg2")
		elseif (_BFSActive == true)
			BFSEffectsActivated.SetValue(1)
			BFSEffectsQuest.Start()
			Debug.Notification("$ActivateMsg1")
		endif
		BFSResetMsg = false
	endif

endFunction

;; ================ EVENTS ========================

Event OnInit()
	If(!Self.IsRunning())
		Return
	EndIf
EndEvent

;;; overrides SKI_ConfigBase
Event OnConfigInit()
	Pages = new string[2]
	Pages[0] = "$Options"
	Pages[1] = "$Credits"

	WeaponList = New String[3]
	WeaponList[0] = "$Weapons0"
	WeaponList[1] = "$Weapons1"
	WeaponList[2] = "$Weapons2"

	ActiveList = New String[2]
	ActiveList[0] = "$Deactivated"
	ActiveList[1] = "$Activated"

	PoisonList = New String[3]
	PoisonList[0] = "$Poison0"
	PoisonList[1] = "$Poison1"
	PoisonList[2] = "$Poison2"

endEvent

Event OnVersionUpdate(int a_version)

	if (CurrentVersion == 0)	;;; First time using it
		Debug.Notification("BFSEffects v" + BFSversion)
	elseif (a_version > 0 && CurrentVersion < 3)	;;; Updating
		Debug.Notification("BFSEffects updated to " + BFSversion)
		;; If updating call config init again to create the lists and pages
		OnConfigInit()
	endIf
endEvent


Event OnPageReset(string a_page)

	if (a_page == "")     ;; Default page, load custom logo in DDS format
		LoadCustomContent("BFSEffects/BFSlogo.dds")
		return
	else
		UnloadCustomContent()
	endIf

	if (a_page == "$Options")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$SliderPCTitle")
			_BFSsliderPCOID_S     = AddSliderOption("$Slider", _BFSsliderPCPercent, "{0}%")
			_BFSsliderPCR2OID_S = AddSliderOption("$SliderR2", _BFSsliderPCR2Percent, "{0}%")
		AddEmptyOption()
		AddHeaderOption("$SliderNPCTitle")
			_BFSsliderNPCOID_S     = AddSliderOption("$Slider", _BFSsliderNPCPercent, "{0}%")
			_BFSsliderNPCR2OID_S = AddSliderOption("$SliderR2", _BFSsliderNPCR2Percent, "{0}%")
		AddEmptyOption()
			_BFSsliderExtraOID_S = AddSliderOption("$SliderExtra", _BFSsliderExtraPercent, "{0}%")
		AddEmptyOption()
		AddHeaderOption("$WeaponsTitle")
			_BFSWeaponsOID_T = AddTextOption("", WeaponList[_BFSWeapons])

		SetCursorPosition(1)   ;;;Change column

		AddHeaderOption("$ToggleTitle")
			_BFSPeltOID_B        = AddToggleOption("$TooglePelt", _BFSPelt)
			_BFSFoodOID_B      = AddToggleOption("$ToogleFood", _BFSFood)
			_BFSZombiesOID_B = AddToggleOption("$ToogleZombies", _BFSZombies)
			_BFSSteamOID_B    = AddToggleOption("$ToogleSteam", _BFSSteam)
			_BFSPoisonOID_T    = AddTextOption("$TooglePoison", PoisonList[_BFSPoison])
		AddEmptyOption()
		AddHeaderOption("$ToggleActivate")
			_BFSActiveOID_B = AddTextOption("", ActiveList[_BFSActive as int])
	endif

	if (a_page == "$Credits")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$Author")
			AddTextOption("", "pauderek")
		AddHeaderOption("$Translations")
			;AddTextOption("$Czech", "")
			AddTextOption("$English", "pauderek")
			AddTextOption("$French", "Ragae")
			AddTextOption("$German", "ubuntufreakdragon")
			AddTextOption("$Italian", "Lucasssvt")
			;AddTextOption("$Japanese", "")
			;AddTextOption("$Polish", "")
			;AddTextOption("$Russian", "")
			AddTextOption("$Spanish", "pauderek")

		SetCursorPosition(1)   ;;;Change column

		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
			AddTextOption("VERSION", BFSversion, OPTION_FLAG_DISABLED)
	endif

endEvent


Event OnOptionSelect(int a_option)
    
	if (a_option == _BFSPeltOID_B)
		_BFSPelt = !_BFSPelt
		SetToggleOptionValue(a_option, _BFSPelt)
	elseif (a_option == _BFSFoodOID_B)
		_BFSFood = !_BFSFood
		SetToggleOptionValue(a_option, _BFSFood)
	elseif (a_option == _BFSZombiesOID_B)
		_BFSZombies = !_BFSZombies
		SetToggleOptionValue(a_option, _BFSZombies)
	elseif (a_option == _BFSWeaponsOID_T)
		if _BFSWeapons == 2
			_BFSWeapons = 0
		else
			_BFSWeapons += 1
		endif
		SetTextOptionValue(a_option, WeaponList[_BFSWeapons])
	elseif (a_option == _BFSSteamOID_B)
		_BFSSteam = !_BFSSteam
		SetToggleOptionValue(a_option, _BFSSteam)
	elseif (a_option == _BFSPoisonOID_T)
		if _BFSPoison == 2
			_BFSPoison = 0
		else
			_BFSPoison += 1
		endif
		SetTextOptionValue(a_option, PoisonList[_BFSPoison])
	elseif (a_option == _BFSActiveOID_B)
		_BFSActive = !_BFSActive
		SetTextOptionValue(a_option, ActiveList[_BFSActive as int])
		BFSResetMsg = true
		ShowMessage("$ActivateMsg3", false)
	endif

endEvent


Event OnOptionSliderOpen(int a_option)

	if (a_option == _BFSsliderPCOID_S)
		SetSliderDialogStartValue(_BFSsliderPCPercent)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (a_option == _BFSsliderPCR2OID_S)
		SetSliderDialogStartValue(_BFSsliderPCR2Percent)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (a_option == _BFSsliderNPCOID_S)
		SetSliderDialogStartValue(_BFSsliderNPCPercent)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (a_option == _BFSsliderNPCR2OID_S)
		SetSliderDialogStartValue(_BFSsliderNPCR2Percent)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (a_option == _BFSsliderExtraOID_S)
		SetSliderDialogStartValue(_BFSsliderExtraPercent)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endIf

endEvent


Event OnOptionSliderAccept(int a_option, float a_value)
        
	if (a_option == _BFSsliderPCOID_S)
		_BFSsliderPCPercent = a_value
		SetSliderOptionValue(a_option, a_value, "{0}%")
	elseif (a_option == _BFSsliderPCR2OID_S)
		_BFSsliderPCR2Percent = a_value
		SetSliderOptionValue(a_option, a_value, "{0}%")
	elseif (a_option == _BFSsliderNPCOID_S)
		_BFSsliderNPCPercent = a_value
		SetSliderOptionValue(a_option, a_value, "{0}%")
	elseif (a_option == _BFSsliderNPCR2OID_S)
		_BFSsliderNPCR2Percent = a_value
		SetSliderOptionValue(a_option, a_value, "{0}%")
	elseif (a_option == _BFSsliderExtraOID_S)
		_BFSsliderExtraPercent = a_value
		SetSliderOptionValue(a_option, a_value, "{0}%")
	endIf

endEvent


Event OnOptionHighlight(int a_option)
    
	if (a_option == _BFSPeltOID_B)
		SetInfoText("$PeltInfo")
	elseif (a_option == _BFSFoodOID_B)
		SetInfoText("$FoodInfo")
	elseif (a_option == _BFSZombiesOID_B)
		SetInfoText("$ZombiesInfo")
	elseif (a_option == _BFSWeaponsOID_T)
		SetInfoText("$WeaponsInfo")
	elseif (a_option == _BFSPoisonOID_T)
		SetInfoText("$PoisonInfo")
	elseif (a_option == _BFSSteamOID_B)
		SetInfoText("$SteamInfo")
	elseif (a_option == _BFSsliderPCOID_S)
		SetInfoText("$SliderPCInfo")
	elseif (a_option == _BFSsliderPCR2OID_S)
		SetInfoText("$SliderPCR2Inf")
	elseif (a_option == _BFSsliderNPCOID_S)
		SetInfoText("$SliderNPCInfo")
	elseif (a_option == _BFSsliderNPCR2OID_S)
		SetInfoText("$SliderNPCR2Inf")
	elseif (a_option == _BFSsliderExtraOID_S)
		SetInfoText("$SliderExtraInfo")
	elseif (a_option == _BFSActiveOID_B)
		SetInfoText("$ActivateInf")
	endIf
endEvent


Event OnConfigClose()
	ApplySettings()
EndEvent