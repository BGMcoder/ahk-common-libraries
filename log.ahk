;Tuesday, June 18, 2013
;log.ahk
;by Brother Gabriel-Marie
;a simple library for working with log files

#include file.ahk

; log.new(whatlog, whatencoding="")
; log.append(whattext="", mode="", timestamp=true, overwrite=0)
; log.separator(mode=0, whattext="")


class log {

	__new(whatlog, whatencoding=""){
		this.logfile := whatlog
		this.encoding := whatencoding
	}

	;creates an empty log if it doesn't exist
	;never overwrites the log
	;timestamp=true uses the default date for a timestamp
	;mode sets the text for denoting ERROR, WARNING, INFO, NOTICE or custom.
	append(whattext="", mode="", timestamp=true, overwrite=0){
		if(overwrite){
			file.delete(this.logfile)
		}
		if (mode=1){
			mode := "ERROR:   "
		}else if(mode=2){
			mode := "WARNING: "
		}else if(mode=3){
			mode := "INFO:    "	
		}else if(mode=4){
			mode := "NOTICE: "
		}else{
			if(mode){
				mode := mode . ": "
			}
		}
		
		if(timestamp){
			timestamp := path.date() . "---"
		}else{
			timestamp := ""
		}
		thistext := timestamp . mode . whattext . "`r`n"
		this.appendtext(thistext)
	}
	
	separator(mode=0, whattext=""){
		if(mode=1){
			thistext := "==========================" . whattext . "=========================="
		}else if(mode=2){
			thistext := "<><><><><><><><" . whattext . "><><><><><><><><><>"
		}else{
			thistext := "-----------------------------" . whattext . "--------------------------------------"		
		}
		thistext := thistext . "`r`n"
		this.appendtext(thistext)
	}
	
	
	;PRIVATE FUNCTIONS -------------------------------------------------------------------
	;always use this function to write to the log
	appendtext(whattext){
		thislog := this.logfile
		thisencoding := this.encoding
		fileappend, %whattext%, %thislog%, %thisencoding%	
	}

} ;end log class
