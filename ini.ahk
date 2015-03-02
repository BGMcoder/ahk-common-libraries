;Sunday, June 16, 2013
;ini.ahk
;by Brother Gabriel-Marie
;a common library for the usual ini functions

;make sure core.ahk is loaded since it is required - it will only be included again if it hasn't already
#include core.ahk
#include file.ahk
#include text.ahk

;write(whatini, whatsection, whatkey, whatvalue)
;read(whatini, whatsection, whatkey, whatdefault)
;validate(whatini)
;getsectiontext(whatini, whatsection)
;delete(whatini, whatsection, whatkey)
;getsectioncount(whatini)
;getsectionarray(whatini)
;open(whatini)

;readparameter(whatini, whatsection, whatkey, whatparameter=1, whatdelimiter="|")
;writeparameter(whatvalue, whatini, whatsection, whatkey, whatparameter=1, whatdelimiter="|")

;getsectioncount(whatini)
;getsectionarray(whatini)

;--------------------------------------------------------------------------------------------------------------------------------------

class ini
{

write(whatini, whatsection, whatkey, whatvalue, default0=0){
	if(!whatkey)		;keep from overwriting the section if the key is empty!!!
		return		
	;send a string for 0 so you can write "0" to the ini file.
	if(default0){
		if(!whatvalue)
			whatvalue := "0"
	}
	iniwrite, %whatvalue%, %whatini%, %whatsection%, %whatkey%
	if ErrorLevel   ; i.e. it's not blank or zero.
		return false	;failure
	else
		return true	;success
}


writesection(whatini, whatsection, whatvalue){
	iniwrite,%whatvalue%, %whatini%, %whatsection%
	if ErrorLevel   ; i.e. it's not blank or zero.
		return false	;failure
	else
		return true	;success	
}

;returns the text of a specific section without the comments
readsection(whatini, whatsection){
	iniread, thissection, %whatini%, %whatsection%
	return thissection
}

;returns a list of section names separated by a linefeed `n character
sections(whatini){
	iniread, thesenames, %whatini%
	return thesenames
}

read(whatini, whatsection, whatkey, whatdefault="", suppress=0){
	;if there is an error, the returnvalue will be whatdefault
	if(suppress){
		if(whatdefault = "")
			whatdefault := a_space
		if(whatdefault = 0)
			whatdefault := "0"
	}
	iniread, returnvalue, %whatini%, %whatsection%, %whatkey%, %whatdefault%
	return returnvalue
}

delete(whatini, whatsection, whatkey){
	if(!whatkey)		;keep from overwriting the section if the key is empty!!!
		return		
	inidelete, %whatini%, %whatsection%, %whatkey%
	;if no key is specified, the entire section is deleted
	if ErrorLevel   ; i.e. it's not blank or zero.
		return false	;failure
	else
		return true	;success
}


validate(whatini){
	if(FileExist(whatini) ){
		return true	;success
	}else{
		return false ;failure	
	}
}

open(whatini){
	runit("notepad", whatini)
}


;-------------------------------------------------------------------
;INI KEY PARAMETERS
;in an ini key,you can specify parameters like this:
;  thiskey=first|second|third

;fetch a particular parameter
readparameter(whatini, whatsection, whatkey, whatparameter=1, whatdefault="", whatdelimiter="|"){
	thisstring := this.read(whatini, whatsection, whatkey, whatdefault)
	stringsplit, parameter, thisstring, %whatdelimiter%, %a_space%
	parameter%whatparameter% := trimmatch(parameter%whatparameter%, "|")
	return parameter%whatparameter%
}

;write to a particular parameter
writeparameter(whatvalue, whatini, whatsection, whatkey, whatparameter=1, whatdelimiter="|"){
	thisstring := this.read(whatini, whatsection, whatkey, "")
	stringsplit, parameter, thisstring, %whatdelimiter%, %a_space%
	parameter%whatparameter% := whatvalue
	loop %parameter0%{
		theseparameters .= parameter%a_index% . whatdelimiter
	}
	theseparameters := trimmatch(theseparameters, "|")

	this.write(whatini, whatsection, whatkey, theseparameters)
}

;return a count of the parameters in the key
countparameters(whatini, whatsection, whatkey, whatdefault=0, whatdelimiter="|"){
	parametercount := whatdefault
	theseparameters := this.read(whatini, whatsection, whatkey, "ERROR")
	stringsplit, parametercount, thisstring, %whatdelimiter%, %a_space%
	return parametercount0
}

;return a key name from a known parameter
;In the case of menus, we may know only a certain parameter and have to grab the item's key.
;this will work as long as the parameters for each corresponding keys are unique.
;for example:
;100=first|param1|param2
;101=second|param1|param2
;in these keys, the first parameter is unique, so we can fetch that parameter.
;you can use this in a section of keys that don't have parameters as long as the other keys don't contain the delimiter.
keyfromparameter(whatini, whatsection, whatparameter, whatvalue, whatdelimiter="|"){
	sectiontext := this.readsection(whatini, whatsection)
	loop, parse, sectiontext, `r, %a_space%
	{
		stringsplit, thisline, a_loopfield, =, %a_space%`r`n
		if(trimtrim(thisline1)){	;make sure there is a keyname
			IfNotInString, thisline2, %whatdelimiter%
				continue		
			stringsplit, parameter, thisline2, %whatdelimiter%, %a_space%
			thisvalue := parameter%whatparameter%
			if(thisvalue = whatvalue){
				return thisline1
			}
		}
	}	
	return ""
}

countkeys(whatini, whatsection){
	sectiontext := this.readsection(whatini, whatsection)
	keycount := 0
	loop, parse, sectiontext, `r, %a_space%
	{
		stringsplit, thisline, a_loopfield, =, %a_space%
		if(trim(thisline1," `t`r`n")){
			keycount++
		}
	}	
	return keycount
}

;-------------------------------------------------------------------

;http://stackoverflow.com/questions/15468085/regex-return-ini-section-as-string#15468861
getsectiontextx(whatini, whatsection){
	sectiontext := ""
	;thisfileencoding := getFileEncoding(whatini)			;cp1252 is my default ANSI encoding
	;msgbox, %thisfileencoding%
	;curencoding := a_fileencoding
	;FileEncoding, UTF-8
	fileread, INIall, %whatini%
	;FileEncoding := curencoding
	inisection := "[" . whatsection . "]"
	
	;iniregex := "ms)(?<=^\[" . whatsection . "\])(?:(?!^\[).)*"
	;iniregex := "ms)(?<=^\[" . whatsection . "\])(?:(?!^\[.+\]$).)*"
	;iniregex := "(?ms)(?<=^\[" . whatsection . "\])(?:(?!^\[[^]\r\n]+]).)*"
	iniregex := "ms)^(?<=\[" . whatsection . "\]\r\n)(?:(?!^\[).)*(?=\r\n)"
	
	;find from the end of inisection to the next section definition or the eof
	ismatch := regexmatch(INIall, iniregex, sectiontext)	;get the key and the value whilst excluding the comments
	if(!ismatch)
		return ""
	else
		return trimmatch(sectiontext, "`r`n")	;remove a tailing carriage return
}

;sinkfaze's attempt
;Fetches an entire section as a block of text
;however, this will fetch also a trailing carriage return, so we will have to trim it
getsectiontextfull(whatini, whatsection) {
	FileRead, INIall, %whatini%
	ismatch := RegExMatch(INIall,"`ami)\[" whatsection "\]\v+\K[^\[]+", sectionText)
	if(!ismatch)
		return ""
	else
		return trimtrim(sectiontext)	;remove a tailing carriage return
}

;get the count of sections in the file
;a section is a line that that begins with "["
getsectioncount(whatini){
	iniall := text.get(whatini)
	sectioncount := 0
	loop, parse, iniall
	{
		if(left(trim(a_loopfield), 1) = "["){
			sectioncount++
		}
	}
	return sectioncount
}

;gets the list of sections into an array
getsectionarray(whatini){
	iniall := text.get(whatini)
	sectionarray := object()
	sectionindex := 0
	loop, parse, iniall, `n, `r
	{
		if(left(a_loopfield, 1) = "["){
			thissection := trim(replacechars(a_loopfield, "[]"))
			sectionindex++
			sectionarray[sectionindex] := thissection
		}else{
			continue
		}
	}
	return sectionarray
}


} ;end ini class

