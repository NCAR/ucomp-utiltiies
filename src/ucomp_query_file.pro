; docformat = 'rst'

;+
; Procedure to inventory contents of CoMP raw data file: onband, wavelength,
; data type and exposure time are returned.
;
; Groups are defined to be unique combinations of wavelength, beam and
; polarization state.
;
; Based on `COMP_INVENTORY`.
;
; :Params:
;   filename : in, required, type=string
;     UCoMP FITS file to query
;
; :Keywords:
;   datatype : out, optional, type=string
;     type of CoMP data file "dark", "flat", "cal", or "sci"
;   wave_region : out, optional, type=string
;     wave region of the CoMP data file, i.e, "530", "637", etc.
;   onband : out, optional, type=strarr
;     specifies which camera is onband
;   wavelength : out, optional, type=fltarr
;     wavelength
;   exposure : out, optional, type=float
;     exposure time in milliseconds
;   cal_polarizer : out, optional, type=int
;     polarizer present
;   cal_retarder : out, optional, type=int
;     retarder present
;   observation_id : out, optional, type=string
;     ID for observation within an `OBSERVATION_PLAN`
;   observation_plan : out, optional, type=string
;     plan for file, i.e., synoptic, waves, etc.
;   pol_angle : out, optional, type=fltarr
;     polarization angle `POLANGLE` keyword
;   ret_angle : out, optional, type=fltarr
;     retarder angle `RETANGLE` keyword
;   ext_titles : out, optional, type=strarr
;     extension titles
;-
pro ucomp_query_file, filename, $
                      datatype=datatype, $
                      wave_region=wave_region, $
                      onband=onband, $
                      wavelength=wavelength, $
                      exposure=exposure, $
                      observation_id=observation_id, $
                      observation_plan=observation_plan, $
                      pol_angle=pol_angle, $
                      ret_angle=ret_angle, $
                      ext_titles=ext_titles
  compile_opt idl2

  fits_open, filename, fcb
  if (n_elements(fcb) eq 0 || fcb.nextend eq 0L) then begin
    type = 'invalid'
    onband = !null
    wavelength = !null
    exposure = !null
    cal_polarizer = !null
    cal_retarder = !null
    observation_id = ''
    observation_plan = ''
    pol_angle = !null
    ext_titles = !null
    return
  endif

  n_extensions = fcb.nextend   ; number of images in file

  onband             = strarr(n_extensions)
  wavelength         = fltarr(n_extensions)
  pol_angle          = fltarr(n_extensions)
  ret_angle          = fltarr(n_extensions)
  ext_titles         = strarr(n_extensions)

  fits_read, fcb, data, header, /header_only, exten_no=0
  fits_read, fcb, data, ext_header, /header_only, exten_no=1

  wave_region = sxpar(header, 'FILTER')

  datatype    = sxpar(ext_header, 'DATATYPE')
  exposure    = sxpar(ext_header, 'EXPTIME')

  observation_id = strtrim(sxpar(header, 'OBS_ID', count=count), 2)
  if (count eq 0L) then observation_id = ''
  observation_plan = strtrim(sxpar(header, 'OBS_PLAN', count=count), 2)
  if (count eq 0L) then observation_plan = ''

  ; other keywords
  if (arg_present(onband) $
        || arg_present(wavelength) $
        || arg_present(pol_angle) $
        || arg_present(ret_angle) $
        || arg_present(ext_titles)) then begin
    for i = 0L, n_extensions - 1L do begin
      fits_read, fcb, data, ext_header, /header_only, exten_no=i + 1L

      onband[i] = sxpar(ext_header, 'ONBAND', count=count)
      if (count eq 0L) then onband[i] = ''
      wavelength[i] = sxpar(ext_header, 'WAVELNG', count=count)
      if (count eq 0L) then wavelength[i] = !values.f_nan
      pol_angle[i] = sxpar(ext_header, 'POLANGLE', count=count)
      if (count eq 0L) then wavelength[i] = !values.f_nan
      ret_angle[i] = sxpar(ext_header, 'RETANGLE', count=count)
      if (count eq 0L) then ret_angle[i] = !values.f_nan
      ext_titles[i] = sxpar(ext_header, 'EXTNAME', count=count)
      if (count eq 0L) then ext_titles[i] = '<unknown>'
    endfor
  endif

  fits_close, fcb
end
