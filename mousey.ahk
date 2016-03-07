;--------mousey library----------------
;mousey.ahk
;by Brother Gabriel-Marie
;Sunday, March 06, 2016
;http://ahkscript.org/boards/viewtopic.php?f=6&t=8352&p=48052#p48052

;Usage is simple:
;Create a mousey cursor and assign it a control using mousey_init()
;when you are done with it, use mousey_close() to clean up.
 
 /*
 ;mousey example
;sample change of mouse cursor on mouseover
#SingleInstance, On
#NoEnv
SetBatchLines, -1
gui, add, text, hwndmouseytext,Mousey Crosshairs
gui, add, button, gguiclose,EXIT (non-mousey)
gui, add, text, hwndhandytext,Mouse Hand

;MOUSEY IS RIGHT HERE!
mousey_cursor := mousey_init(mouseytext,"crosshair")
handy_cursor := mousey_init(handytext,"hand")

gui, show
return

guiclose:
	mousey_close(mousey_cursor)
	mousey_close(handy_cursor)
	exitapp
return
*/
 
 

;Assigns a mouse cursor to a control
;whatcontrol = hwnd of control (without the ahk_id prefix)
;whatcursor = one of the various cursors (see mousey_choose)
;returns handle to mouse cursor
mousey_init(whatcontrol,whatcursor=""){
	thiscursor := mousey_choose(whatcursor)
	thiscursorhandle:=DllCall("LoadCursor","UInt",NULL,"Int",thiscursor,"UInt") ;IDC_HAND
	OnMessage(0x200,Func("mousey_move").bind(whatcontrol,thiscursorhandle) )
	return thiscursorhandle
}
;callback function - used internally by mousey_init()
mousey_move(whatcontrol,whatcursor){
	mousegetpos,,,,thiscontrol,2
	if(thiscontrol = whatcontrol)
		DllCall("SetCursor","UInt",whatcursor)
}

;destroy the mouse cursor handle
mousey_close(whatcursorhandle){
	OnMessage(0x200,"")
	DllCall("DestroyCursor","Uint",whatcursorhandle)
}

;You specify what cursor you want, and mousey_choose() returns the cursor ID
;This is used internally by mousey_init()
mousey_choose(whatcursor="arrow"){
	;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648391(v=vs.85).aspx
	if(whatcursor = "hand")			;Hand
		return 32649	;IDC_HAND
	else if(whatcursor = "arrow")	;Standard arrow
		return 32512	;IDC_ARROW
	else if(whatcursor = "appstarting")	;Standard arrow and small hourglass
		return 32650	;IDC_APPSTARTING
	else if(whatcursor = "crosshair") ;Crosshair
		return 32515  ;IDC_CROSS
	else if(whatcursor = "help")	;Arrow and question mark
		return 32651	;IDC_HELP
	else if(whatcursor = whatcursor = "ibeam")	;I-beam
		return 32513	;IDC_IBEAM
	else if(whatcursor = "no" || whatcursor = "slashed")	;Slashed circle
		return 32648 ;IDC_NO (slashed circle)
	else if(whatcursor = "sizeall")	;Four-pointed arrow pointing north, south, east, and west
		return 32646 ;IDC_SIZEALL
	else if(whatcursor = "sizenesw")	;Double-pointed arrow pointing northeast and southwest
		return 32643		;IDC_SIZENESW
	else if(whatcursor = "sizens")	;Double-pointed arrow pointing north and south
		return 32645		;IDC_SIZENS
	else if(whatcursor = "sizenwse")	;Double-pointed arrow pointing northwest and southeast
		return 32642		;IDC_SIZENWSE
	else if(whatcursor = "sizeewe")	;Double-pointed arrow pointing west and east
		return 32644		;IDC_SIZEWE
	else if(whatcursor = "uparrow")	;Vertical arrow
		return 32516 		;IDC_UPARROW
	else if(whatcursor = "wait"||whatcursor = "hourglass")	;Hourglass
		return 32514		;IDC_WAIT							
	else
		return 32512	;IDC_ARROW
}
