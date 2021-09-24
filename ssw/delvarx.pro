;+
; Project     :	SOHO - CDS
;
; Name        :	DELVARX
;
; Purpose     : Delete variables for memory management (can call from
;               routines) 
;
; Use         : DELVARX,  a [,b,c,d,e,f,g,h,i,j]
;                                 	;deletes named variables
;					;like idl delvar, but may be used
;					;from any calling level;
; Explanation :
;
; Inputs      : p0, p1...p9 - variables to delete
;
; Opt. Inputs : None.
;
; Outputs     : None.
;
; Opt. Outputs: None.
;
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: Can't use recursively due to EXECUTE function, TEMPORARY 
;		function not available in idl versions < 2.2
;
; Side effects: None.
;
; Method      : Uses EXECUTE and TEMPORARY function   
;
; Category    :
;
; Prev. Hist. :
;      slf,  8-mar-1993			; bug fix
;      slf, 25-mar-1993			; made it work for non-scalers!
;
; Written     :	 slf, 25-feb-1993
;
; Modified    :
;
; Version     :
;-
;
PRO delvarx, p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
   FOR i = 0, N_PARAMS()-1 DO BEGIN ; for each parameter
      param = STRCOMPRESS("p" + STRING(i),/remove)
;  only delete if defined on inpu (avoids error message)
      exestat = execute("defined=n_elements(" + param + ")" ) 
      IF defined GT 0 THEN BEGIN
         exestat = execute(param + "=0")
         exestat = execute("dvar=temporary(" + param + ")" )
      ENDIF
   ENDFOR
   RETURN
END
