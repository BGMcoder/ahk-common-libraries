/*!
	Library: core.ahk
		version 1.0
		Sunday, June 16, 2013
	Author: Brother Gabriel-Marie
		an autohotkey inclusion with all the re-usable stuff
	
*/
;HISTORY
;version 1.1 : Tuesday, November 26, 2013 - added TrimMatch
;version 1.0 : June 16, 2013 : first release

;alert(whatmessage, whaticon=0)
;enc(whattext)
;len(whattext)
;right(whattext, numchars=0, shift=false)
;left(whattext, numchars=1, shift=false)
;mid(whattext, startindex, numchars=1, shift=false)
;Count(whattext, findwhat)
;trimtrim(whatstring, trimhow=0)
;TrimMatch(whatstring, trimthis, rightside=1, casesensitive=0)
;ReplaceString(whattext, replacethis, withthis="", replaceall=0, casesensitive=1, isregex=0)
;ReplaceChars(whatstring, whatchars, replacement="", caseon=0)
;EscapeRegex(whatstring)
;Rand( a=0.0, b=1 )

;case(whattext, how)
;SetCase(caseon)

;GetAppName(whatfile=a_scriptname)
;slash(whatstring, how=true, slashtype=false)
;RunIt(whatprogram, whatparams="", whatdir="", whaterrormessage="", whaterroricon="")
;GetTheDate(how="")

;gui_getValue(whatcontrol)
;gui_setValue(whatvalue, whatcontrol)

;global string variables
vowels 		:= "aeiou"
consonants 	:= "bcdfghjklmnpqrstvwxyz"
alphabet := vowels . consonants
numbers 	:= "1234567890"
asciistring := " !#$%&'()*+,-./0123456789:;<=>? @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_ 'abcdefghijklmnopqrstuvwxyz{|}~"""
punctuation := "`.`,`;"
a_doublequote := chr(34)
a_singlequote := chr(39)
validchars	:= alphabet . numbers . "#_@$"
regexchars	:= "\`.*?+[`{|()^$"
g_delimiter := ""

/*!
	Function: alert(whatmessage, whaticon="", whattitle="", whattimeout="")
		A Wrapper for messagebox with intuitive parameters
	Parameters:
		whatmessage - What you want to say
		whaticon - The icon you like.  Leave blank for no icon.  
			You can specify: "asterisk", "exclamation", "warning", "hand", "stop", "error", "question", "help", "okay" or blank.
		whattitle - Your custom title for the messagebox window
		whattimeout - When you want the messagebox to disappear on it own; leave blank to have it not disappear.
	Returns: none
	Notes: If the original window is topmost, this messagebox will also be topmost
*/
alert(whatmessage, whaticon="", whattitle="", whattimeout=""){
	if(!thistitle){	;use the apptitle variable if it is defined
		thistitle := apptitle
	}
	if(whaticon = "asterisk")
		theseoptions := 64
	else if(whaticon = "exclamation" || whaticon = "warning")
		theseoptions := 48
	else if(whaticon = "hand" || whaticon = "stop" || whaticon = "error")
		theseoptions := 16
	else if(whaticon = "help" || whaticon = "question")
		theseoptions := 32
	else if(whaticon = "okay")
		theseoptions := 0
	else
		theseoptions := 0
		
	;if the original window is topmost, make this here msgbox topmost, too, so it doesn't disappear behind the window
	WinGet, ExStyle, ExStyle, a
	if (ExStyle & 0x8){  ; 0x8 is WS_EX_TOPMOST.
		theseoptions := theseoptions + 4096
	}
	
	;the "options" number must be a forced expression
	msgbox, % theseoptions, %whattitle%, %whatmessage%, %whattimeout%			;%
}




;simply enclose the text in double-quotes
;mode uses doubled double quotes
;trimquotes trims existing quotes before adding new ones so they aren't doubled - useful for commandline operations
enc(whatstring, mode=0, trimquotes=true){
	global a_doublequote
	if(trimquotes){
		whatstring := trim(whatstring, a_doublequote) ;remove any existing doublequotes
		whatstring := whatstring
	}
	
	if(mode){
		quotedvar = "%a_doublequote%%whatstring%%a_doublequote%"
	}else{
		quotedvar := a_doublequote . whatstring . a_doublequote
	}
	return quotedvar
}

;I prefer this calling!
len(whattext){
	return strlen(whattext)
}


;returns the rightmost number of characters
;if shift is true, then return the string with the number of characters removed
;example := right(123abc, 2, true)
;result:  bc
;example := right(123abc, 2, false)
;result: 123a
right(whattext, numchars=1, shift=false){
	StringLen, thislen, whattext
	numchars := abs(numchars) ;remove the negativity!
	if(shift){
		thisstring := substr(whattext, 1, thislen - numchars)
	}else{
		thisstring := substr(whattext, thislen - numchars +1, thislen)
	}
	return thisstring
}


;returns the leftmost number of characters
;if shift is true, then return the string with the number of characters removed - that is, shift = trim
left(whattext, numchars=1, shift=false){
	StringLen, thislen, whattext
	numchars := abs(numchars) ;remove the negativity!
	if(shift){
		thisstring := substr(whattext, numchars+1, thislen)
	}else{
		thisstring := substr(whattext, 1, numchars)
	}
	return thisstring
}

;shift=false : fetch the characters from the middle of a string
;shift=true : remove the characters from the middle of a string (same as substr)
mid(whattext, startindex, numchars=1, shift=false){
	if(shift){
		leftpart := left(whattext, startindex - 1)	;store the text left of the startindex
		rightpart := left(whattext, len(leftpart) + numchars, true)
		thisstring := leftpart . rightpart
	}else{
		thisstring :=  substr(whattext, startindex, numchars)
	}
	return thisstring
}

;get the position of a string within a string
pos(whattext, findthis, leftright="", offset=""){
	stringgetpos thisposition, whattext, %findthis%, %leftright%, %offset%
	return thisposition
}


;gets the number of occurrences of the substring within a string (unconventional method : http://rosettacode.org/wiki/Count_occurrences_of_a_substring#AutoHotkey)
count(whattext, findwhat){
   StringReplace, nooutput, whattext, %findwhat%, , UseErrorLevel
   return errorlevel		
}


;check to see whether the leftmost or rightmost part of a string matches a particular string
;if it matches, return the string with the match trimmed away or just the original string if there is nothing to trim
;trims to the right by default so it is easy to remove trailing characters
TrimMatch(whatstring, trimthis, rightside=1, casesensitive=0){
	lenmatch := len(trimthis)
	if(rightside){
		trimmode := "right"
	}else{
		trimmode := "left"
	}
	thismatch := %trimmode%(whatstring, lenmatch)		;see if the strings match
	
	if(casesensitive){
		if(thismatch == trimthis){
			return %trimmode%(whatstring, lenmatch, true)  ;return the string without the matched chars
		}else{
			return whatstring	
		}
	}else{
		if(thismatch = trimthis){
			return %trimmode%(whatstring, lenmatch, true)  ;return the string without the matched chars
		}else{
			return whatstring	
		}

	}
}

;remove all whitespace from the start or tail of a string
;trimhow = 0 or "" will trim both sides
;trimhow = 1 will trim right
;trimhow = 2 will trim left
trimtrim(whatstring, trimhow=0){
	if(!trimhow){
		whatstring := RegExReplace( whatstring, "mO)(\s+$)")
		whatstring := RegExReplace( whatstring, "mO)(^\s+)")
	}else if(trimhow = 1){
		whatstring := RegExReplace( whatstring, "mO)(\s+$)")
	}else{
		whatstring := RegExReplace( whatstring, "mO)(^\s+)")
	}
	Return whatstring
} 


;Change Case
;return the regular string if nothing is specified
case(whattext, how){
	if(how = 1 || how="lower")	;lower case
		stringlower, workingtext, whattext
	else if(how = 2 || how="upper")	;upper case
		stringupper, workingtext, whattext
	else if(how = 3 || how="sentence")	;Sentence Case
		workingtext := RegExReplace(whattext, "((^|[.!?]\s+)[a-z])", "$u1")
	else if(how = 4 || how="title") ;Title Case
		stringlower, workingtext, whattext, T
	else
		workingtext := whattext
		
	return workingtext
}


;set the stringcasesense
;returns the stringcase before the modification was made
SetCase(caseon){
	currentcase := a_stringcasesense
	if(caseon = 1 or caseon = "on")
		stringcasesense, on
	else
		stringcasesense, off
	return currentcase
}

StringMatch(whatword1, whatword2, caseon=0){
	alert(whatword1 . "`r" . whatword2)
	if(caseon)
		matchingwords := regexmatch(whatword1, whatword2)
	else
		matchingwords := regexmatch(whatword1, "i)" . whatword2)
	return matchingwords
}

;replace instances of one string with another
ReplaceString(whattext, replacethis, withthis="", replaceall=1, caseon=0, isregex=0){
	if(isregex){
		if(replaceall = 1)
			rxlimit = -1	;because regex wants "all" to be -1
		returnthis := RegexReplace(whattext, replacethis, withthis,"",rxlimit)
	}else{
		currentstate := SetCase(caseon)
		stringreplace, returnthis, whattext, %replacethis%, %withthis%, %replaceall%
		;msgbox, %returnthis%-%whattext%-%replacethis%-%withthis%-%replaceall%
		SetCase(currentstate)
	}
	return returnthis
}



;replace all instances of a single glyph within the string
ReplaceChars(whatstring, whatchars, replacement="", caseon=0){
	currentstate := SetCase(caseon)
	loop, parse, whatstring
	{
	   thischar := a_loopfield
		if(instr(whatchars, thischar,0,1)){
			stringreplace, thischar, thischar, %thischar%, %replacement%
		}
		newstring := newstring . thischar
	}
	SetCase(currentstate)
	return newstring
}

;  escape any regex characters
; allowchars = a string of characters that you don't want to s
EscapeRegex(whatstring, allowchars=""){
	global regexchars
	loop, parse, whatstring
	{
	   thischar := a_loopfield
		if(instr(regexchars, thischar,0,1)){
			if(!instr(allowchars, thischar,0,1)){
				stringreplace, thischar, thischar, %thischar%, \%thischar%
			}
		}
		safestring := safestring . thischar
	}
	return safestring
}

; Random command wrapper by [VxE]
; http://www.autohotkey.com/forum/viewtopic.php?p=333325#333325
Rand( a=0.0, b=1 ) {
   IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
   Else Random,r,a,b
   Return r
}

;add/remove trailing backslash
;Adds a slash if there isn't one (if there are two slashes, "slash" won't change anything)
;whatstring = string to check
;how = whether to add or remove trailing slash (add by default)
;backslash is assumed by default.  If forwardslash is needed, change slashtype to true
slash(whatstring, how=true, whichslash=false){
	if(!whatstring)
		return
	slashtype := "\"
	if(whichslash)
		slashtype := "/"
	lastchar := right(whatstring, 1)
	thisstring := whatstring
	if(how){	;if there aint no slash, add one
		if(lastchar != slashtype){
			thisstring := whatstring . slashtype
			;alert(thisstring . "`r" . whatstring . "`r" . slashtype . "=" . lastchar)
		} ;else don't do anything
	}else{		;if there is a slash, remove it
		if(lastchar == slashtype){
			thisstring := right(whatstring 1, true)
		}
	}
	return thisstring
}

;return the name of the application without any path or extension
GetAppName(whatfile=""){
	if(!whatfile)
		whatfile := a_scriptname
	splitpath, whatfile,,,,thisnameonly
	return thisnameonly
}


;Run a program, and give a report in case it doesn't launch correctly.
;return the PID
RunIt(whatprogram, whatparams="", whatdir="", whaterrormessage="", whaterroricon="error"){
	run, %whatprogram% %whatparams%, %whatdir%,UseErrorLevel, toolPID
	if ErrorLevel
	{
		if(!whaterrormessage){
			whaterrormessage := "The document could not be launched.`rApplication=" . whatprogram . "`rParameters=" . whatparams . "`rMaybe the program path or the parameter is incorrect?"
		}
		alert(whaterrormessage, whaterroricon)
	}
		
	return toolPID
}


GetTheDate(how=""){
	FormatTime, thisdate,,%how%
	return thisdate
}


;make a string into a valid variable name by replacing the not-allowed characters with # marks
;it is better to replace them than to remove them to help prevent duplicates.	
makeVarNameValid(whatname){
	global validchars
	Loop, Parse, whatname
	{
		thischar := a_loopfield
		ifnotinstring, validchars, %a_loopfield%
			thischar := "#"
		validname := validname . thischar
	}
	return validname	
}	


;-------------------------------------------------------------------

;fetches the value of a control
gui_getValue(whatcontrol){
	guicontrolget, thisvalue, ,%whatcontrol%
	return thisvalue
}

