;lv.ahk
;a wrapper library for the listview control
;8:44 AM Friday, November 07, 2014
;by Brother Gabriel-Marie
;contributors:  Just Me from the ahkscript.org forum


;NOTES:
;the class does not need to be initiated

;----------PROPERTIES---------------------------------------------------------
; countcolumns(hListview)
; countrows(hListview)

;------------METHODS-------------------------------------------------------
; activate(hListview)
; add(hListview, Options := "", Fields*)
; rename(hListview, whatcolumn, whatname)
; autowidth(hListview, whichcolumn="", matchheaderwidth=1)
; clear(hListview){
; deletecol(hListview, whatcolumnnumber=0)
; setColumns(hListview, howmany)


class lv {


;----------PROPERTIES---------------------------------------------------------
;count the number of columns
countcolumns(hListview){
	;this.activate(hListview)
	return lv_getcount("column")
}

;Count the number of rows
countrows(hListview){
	;this.activate(hListview)
	return lv_getcount()
}

;------------METHODS-------------------------------------------------------

;set a particular listview as default
activate(hListview) {
	hGUI := DllCall("USer32.dll\GetParent", "Ptr", hListview, "UPtr")
	Gui, %hGUI%:Default
	Gui, %hGUI%:listview, hwnd %hListview%
}


;add lines to a listview
add(hListview, Options := "", Fields*) {
   ;this.activate(hListview)
   return LV_Add(Options, Fields*)
}

;renames a column title
rename(hListview, whatcolumn, whatname){
	;this.activate(hListview)
	return lv_modifycol(whatcolumn,,whatname)
}

;set the width to auto.  
;Leave whichcolumn empty for all columns or operate on that column number
;matchheader:  1=by column header, 0=by contents
auto(hListview, whichcolumn="", matchheader=1){
  ; this.activate(hListview)
   if(!matchheader && !whichcolumn){
		return lv_modifycol()
   }
   if(matchheader){
		return lv_modifycol(whichcolumn,"autohdr")
	}else{
		return lv_modifycol(whichcolumn,"auto")
	}
}


;clears the listview of all the row information
clear(hListview){
	;this.activate(hListview)
	return lv_delete()
}


;deletes a particular column
;if no column is specified, it deletes them all but the first one
deletecol(hListview, whatcolumnnumber=0){
   ;this.activate(hListview)
   if(whatcolumnnumber){
		return lv_deletecol(whatcolumnnumber)
   }else{
		tot := this.countcolumns(hListview)
		loop, %tot%+1
		{
			lv_deletecol(a_index)
		}
   }  
}

;Change the number of columns
setColumns(hListview, howmany){
	;this.activate(hListview)
	totcols := lv_getcount("column")
	if(totcols < howmany){
		loop, % howmany-totcols
		{
			lv_insertcol(totcols+a_index,,"")
		}
	}else if(totcols > howmany){
		loop, % totcols - howmany
		{
			lv_deletecol(howmany+a_index -1)
		}
	}
}




}   ;end class