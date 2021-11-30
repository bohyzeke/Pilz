
;~ na odheslovanie PILZ PNOZMULTI
;~ generuje heslo od 00000 az po 99999


Opt("WinWaitDelay",1)
Opt("WinTitleMatchMode",2)
Opt("SendKeyDelay",0)
Opt("SendKeyDownDelay",0)
;~ Opt("MustDeclareVars", 1)

#include <GUIConstants.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <Array.au3>


Dim $INI = @ScriptDir & "\file.ini"

Global $odpocet
Dim $a = 1
Dim $Znaky = "0123456789"

Global $Sec, $Min, $Hour
Global $HZnak[6],$Hcislo[6]
GuiCreate("Sample GUI", 300, 150, 500, 0);,$WS_POPUP,$WS_EX_TOPMOST)


$Last1 = IniRead($INI, "Last", "ID", "00000")
; vstup pre Startovaci KOD
$Start = GUICtrlCreateInput($Last1, 12, 30, 100, 20)

;vstup pocet znakov v hesle
;~ GuiCtrlCreateLabel("Pocet znakov", 200, 10)
GUICtrlCreateLabel("Start Heslo", 12,10)


$znakov = 5

$Actual = GuiCtrlCreateLabel(GUICtrlRead($Start), 12, 60,100 ,20)

$Stime = GUICtrlCreateLabel("Start",12,80,100,20)
$Etime = GUICtrlCreateLabel ("End", 12,100,100,20)
$But1 = GUICtrlCreateButton("Start", 180, 115, 50, 25)

GUISetState ()



	$Pocet =  StringLen($Znaky)

While 1
	$msg = GUIGetMsg()

	Select
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop

		Case $msg = $But1


			$Ado = 0
			$i=1
			For $i=1 to $znakov
			$Ado = $Ado + $Pocet^$i
			next

;~ 			ConsoleWrite("START :"&$Ado & @CR)

; 			zapisanie casu odstartovania
			$StartTicks = _TimeToTicks(@HOUR,@MIN,@SEC)			; zistenie startovacieho casu
			$temp = _TicksToTime($StartTicks,$Hour,$Min,$Sec)	; prevedenie tikov na hod min sec
			GUICtrlSetData ($Stime,$Hour &":"& $Min &":"& $Sec)	; zobrazenie startovacieho casu

			$Ctik = 1
			For $a = 1 To $Ado

				$TempTick = _TimeToTicks(@HOUR,@MIN,@SEC) 	; zistenie aktualneho casu

				If $Ctik == 1 Then							; zapisanie prveho casu
					$StartTicks = $TempTick					; zapisanie aktualneho casu pri prechode nulou do Startovacieho casu
				EndIf

				If $Ctik >= 51 Then								; zapisanie posledneho casu a  nulovanie pocitadla kusov
					IniWrite($INI,"Last","ID",GUICtrlRead($Start))
					$tempc = $TempTick - $StartTicks				; odratanie startovacieho casu od aktualneho casu
					$tempc = (($Ado-$a)/50*$tempc)-$tempc			; prepocet pravdepodobnego ukoncenia
					$temp = _TicksToTime($tempc,$Hour,$Min,$Sec)	; prevod ukoncenia na hod min a sekundy
;~ 					ConsoleWrite($TempTick &@CR&$tempC&@CR)
					GUICtrlSetData ($Etime,$Hour &":"& $Min &":"& $Sec)	; zobrazenie zostavajuceho casu
					$Ctik = 0
				EndIf

				$out= ""

				$HesloC = $a
				$out= ""
				For $p = 1 To $znakov
					$nasobitel = $Pocet^ ($znakov-$p) 				;Vyratanie nasobitela pre cislo
					$Temp1 = Int($HesloC / $nasobitel)  			;konecne cislo pre aktualny vysledok
					$HesloC = $HesloC - $nasobitel * $Temp1			;odratanie posledneho od hesla
					$out = $out&StringMid($Znaky,$Temp1+1,1)		;najdenie pismena podla prepoctu
				Next

				ConsoleWrite("Ostava " & $Ado - $a&" heslo "&$out&@CR) 	;zapisanie na konzolu Autoitu
				IniWrite($INI,"Last","ID",$out)							;zapisanie do INI suboru
				GUICtrlSetData($Actual,$out)							;zapisanie na obrazovku

				WinWait("Login","Enter &password:")						;Cakanie na Login okno
				If Not WinActive("Login","Enter &password:") Then WinActivate("Login","Enter &password:")	;ak nieje aktivne okno Loginu aktivuj ho
				WinWaitActive("Login","Enter &password:")				;Cakanie na aktivaciu okna Loginu

				Send($out )												;Zapisanie hesla do okna loginu
				Send("{ENTER}")											;Stlacenie ENTER-u pre potvrdenie zadania hesla
				WinWait("PNOZmulti Configurator","Password not recogni");Cakanie na okno s chybovou hláškou
				If Not WinActive("PNOZmulti Configurator","Password not recogni") Then WinActivate("PNOZmulti Configurator","Password not recogni") ;ak nieje aktivne okno s chybovou hláškou aktivuj ho
				WinWaitActive("PNOZmulti Configurator","Password not recogni");Cakanie na aktivaciu okna s chybovou hláškou
				Send("{ENTER}")											;Stlacenie ENTER-u pre potvrdenie chybovej hlášky
				 $Ctik += 1
			Next

	EndSelect
Wend


