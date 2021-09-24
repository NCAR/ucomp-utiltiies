PRO DAYCNV,XJD,YR,MN,DAY,HR
;+
; NAME:
;       DAYCNV
; PURPOSE:
;       Converts julian dates to gregorian calendar dates
; CALLING SEQUENCE:
;       DAYCNV,XJD,YR,MN,DAY,HR
; INPUTS:
;       XJD = Julian date, double precision scalar or vector
; OUTPUTS:
;       YR = Year (Integer)
;       MN = Month (Integer)
;       DAY = Day (Integer)
;       HR = Hours and fractional hours (Real).   If XJD is a vector,
;            then YR,MN,DAY and HR will be vectors of the same length.
; EXAMPLE:
;       DAYCNV,2440000.,YR,MN,DAY,HR
;       yields YR = 1968, MN =5, DAY = 23, HR =12.
; REVISION HISTORY:
;       Converted to IDL from Yeoman's Comet Ephemeris Generator, 
;       B. Pfarr, STX, 6/16/88
;-
if n_params(0) lt 2 then begin
    print,"CALLING SEQUENCE - daycnv,xjd,yr,mn,day,hr
    return
endif
sz = size(xjd)
scalar = sz(0) eq 0                       ;Scalar input?
;
; Adjustment needed because Julian day starts at noon, calender day at midnight
;
jd = long(xjd)                         ;Truncate to integral day
if scalar then jd = lonarr(1) + jd
frac = xjd-jd +0.5                     ;Fractional part of calender day
after_noon = where(frac ge 1.0)
if !ERR gt 0 then begin                ;Is it really the next calender day
      frac(after_noon) = frac(after_noon) - 1.0
      jd(after_noon) = jd(after_noon) + 1
endif
hr = frac*24.0
l = jd+68569
n = 4*l/146097
l = l-(146097*n+3)/4
yr = 4000*(l+1)/1461001
l = l-1461*yr/4+31        ;1461 = 365.25 * 4
mn = 80*l/2447
day = l-2447*mn/80
l = mn/11
mn = mn+2-12*l
yr = 100*(n-49) + yr + l
if scalar then begin
    yr = yr(0) & mn = mn(0) & day = day(0) & hr = hr(0) 
endif
return
end
