; docformat = 'rst'


;= UCoMP specific overrides from MG_FITS_Browser

;+
; Return title to display for extension.
;
; :Returns:
;   string
;
; :Params:
;   filename : in, required, type=string
;     filename of FITS file
;   header : in, required, type=strarr
;     primary header of FITS file
;-
function ucomp_browser::file_title, filename, header
  compile_opt strictarr

  return, file_basename(filename)
end


;+
; Make a solid colored icon.
;
; :Returns:
;   bytarr(16, 16, 3)
;
; :Params:
;   color : in, required, type=bytarr(3)
;     color to make icon
;-
function ucomp_browser::_make_icon, color
  compile_opt strictarr

  bmp = bytarr(16, 16, 3)
  bmp[*, *, 0] = color[0]
  bmp[*, *, 1] = color[1]
  bmp[*, *, 2] = color[2]

  return, bmp
end


;+
; Return bitmap of icon to display next to the file.
;
; :Returns:
;   `bytarr(m, n, 3)` or `bytarr(m, n, 4)` or `0` if default is to be used
;
; :Params:
;   filename : in, required, type=string
;     filename of FITS file
;   header : in, required, type=strarr
;     primary header of FITS file
;-
function ucomp_browser::file_bitmap, filename, header
  compile_opt strictarr

  ucomp_query_file, filename, datatype=datatype
  level = strtrim(sxpar(header, 'LEVEL', count=level_found), 2)

  case datatype of
    'dark': bmp = bytarr(16, 16, 3)
    'flat': bmp = bytarr(16, 16, 3) + 128B
    'cal': begin
        bmp = read_png(filepath('geardata24.png', $
                                subdir=['resource', 'bitmaps']))
        bmp = transpose(bmp, [1, 2, 0])
        bmp = congrid(bmp, 16, 16, 4)
      end
    'sci': begin
        if (level_found && level eq 'L1') then begin
          bmp = read_png(filepath('level1.png', root=mg_src_root()))
          bmp = transpose(bmp, [1, 2, 0])
        endif else begin
          bmp = read_png(filepath('raw.png', root=mg_src_root()))
          bmp = transpose(bmp, [1, 2, 0])
        endelse
      end
    else: bmp = bytarr(16, 16, 3) + 255B
  endcase

  return, bmp
end


;+
; Return title to display for extension.
;
; :Returns:
;   string
;
; :Params:
;   n_exts : in, required, type=long
;     number of extensions
;   ext_names : in, required, type=strarr
;     extension names
;
; :Keywords:
;   filename : in, required, type=string
;     filename of file
;-
function ucomp_browser::extension_title, n_exts, ext_names, filename=filename
  compile_opt strictarr

  ucomp_query_file, filename, ext_titles=ext_titles
  return, ext_titles
end


;+
; Return bitmap of icon to display next to the extension.
;
; :Returns:
;   `bytarr(m, n, 3)` or `bytarr(m, n, 4)` or `0` if default is to be used
;
; :Params:
;   ext_number : in, required, type=long
;     extension number
;   ext_name : in, required, type=long
;     extension name
;   ext_header : in, required, type=strarr
;     header for extension
;
; :Keywords:
;   filename : in, required, type=string
;     filename of file
;-
  function ucomp_browser::extension_bitmap, ext_number, ext_name, ext_header, $
                                            filename=filename
  compile_opt strictarr

  datatype = strtrim(sxpar(ext_header, 'DATATYPE'), 2)
  primary_header = headfits(filename)
  level = strtrim(sxpar(primary_header, 'LEVEL', count=level_found), 2)

  case datatype of
    'dark': bmp = bytarr(16, 16, 3)
    'flat': bmp = bytarr(16, 16, 3) + 128B
    'cal': begin
        bmp = read_png(filepath('geardata24.png', $
                                subdir=['resource', 'bitmaps']))
        bmp = transpose(bmp, [1, 2, 0])
        bmp = congrid(bmp, 16, 16, 4)
      end
    'sci': begin
        if (level_found && level eq 'L1') then begin
          bmp = read_png(filepath('level1.png', root=mg_src_root()))
          bmp = transpose(bmp, [1, 2, 0])
        endif else begin
          bmp = read_png(filepath('raw.png', root=mg_src_root()))
          bmp = transpose(bmp, [1, 2, 0])
        endelse
      end
    else: bmp = bytarr(16, 16, 3) + 255B
  endcase

  return, bmp
end


;+
; Returns valid file extensions.
;
; :Private:
;
; :Returns:
;   strarr
;-
function ucomp_browser::file_extensions
  compile_opt strictarr

  return, [['*.fts;*.fts.gz;*.FTS', '*.*'], $
           ['CoMP FITS files', 'All files']]
end


;+
; Display the given data as an image.
;
; :Private:
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   filename : in, optional, type=string
;     filename of file containing image
;   dimensions : in, required, type=fltarr(2)
;     dimensions of target window
;-
pro ucomp_browser::display_image, data, header, filename=filename, dimensions=dimensions
  compile_opt strictarr

  dims = size(data, /dimensions)

  data_aspect_ratio = float(dims[1]) / float(dims[0])
  draw_aspect_ratio = float(dimensions[1]) / float(dimensions[0])

  if (data_aspect_ratio gt draw_aspect_ratio) then begin
    ; use y as limiting factor for new dimensions
    dims *= dimensions[1] / float(dims[1])
  endif else begin
    ; use x as limiting factor for new dimensions
    dims *= dimensions[0] / float(dims[0])
  endelse

  _data = frebin(data[*, *, 0], dims[0], dims[1])
  tv, bytscl(_data, 0.0, 1200.0)
end

;+
; Overlay information on the image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   filename : in, optional, type=string
;     filename of file containing image
;   dimensions : in, required, type=fltarr(2)
;     dimensions of target window
;-
pro ucomp_browser::annotate_image, data, header, filename=filename, dimensions=dimensions
  compile_opt strictarr

  ; TODO: implement
end

;+
; Determine if annotation is available for a given image.
;
; :Params:
;   data : in, required, type=2D array
;     data to display
;   header : in, required, type=strarr
;     FITS header
;
; :Keywords:
;   filename : in, optional, type=string
;     filename of file containing image
;-
function ucomp_browser::annotate_available, data, header, filename=filename
  compile_opt strictarr

  ; TODO: implement
  return, 0B
end


;= event handling

;+
; Handle context menu events.
;
; Override this method if your subclass creates context menus in
; `create_draw_contextmenu`.
;
; :Params:
;   event : in, required, type=structure
;     `WIDGET_CONTEXT` event
;-
pro ucomp_browser::handle_contextmenu_events, event
  compile_opt strictarr

  if (n_elements(*self.current_data) eq 0L) then return

  uname = widget_info(event.id, /uname)
  self->datacoords_for_screen, self.contextmenu_loc[0], self.contextmenu_loc[1], $
                               x=x, y=y

  ;ucomp_spectral_profile, self.current_filename, pol_state, beam, x, y, error=error
end


;= widget lifecycle methods

function ucomp_browser::create_draw_contextmenu, draw_id
  compile_opt strictarr

  context_base = widget_base(draw_id, /context_menu)
  spectral_profile_button = widget_button(context_base, $
                                          value='Plot spectral profile', $
                                          uname='spectral_profile')
  return, context_base
end


;= lifecycle methods

;+
; Create a CoMP data file browser.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;  _extra : in, optional, type=keywords
;    keywords to `mg_fits_browser::init`
;-
function ucomp_browser::init, tlb=tlb, _extra=e
  compile_opt strictarr

  if (~self->mg_fits_browser::init(/tlb_size_events, _extra=e)) then return, 0

  tlb = self.tlb
  self.draw_size = 512.0

  return, 1
end


;+
; Define CoMP_Browser class, a subclass of MG_FITS_Browser.
;
; :Private:
;-
pro ucomp_browser__define
  compile_opt strictarr

  define = { ucomp_browser, inherits mg_fits_browser, $
             draw_size: 0.0 $
           }
end


;= main routine

;+
; Create the browser.
;
; :Params:
;   pfilenames : in, optional, type=string
;     filenames of FITS files to view
;
; :Keywords:
;   filenames : in, optional, type=string
;     filenames of netCDF files to view
;   tlb : out, optional, type=long
;     set to a named variable to retrieve the top-level base widget identifier
;     of the FITS browser
;-
pro ucomp_browser, pfilenames, filenames=kfilenames, tlb=tlb, _extra=e
  compile_opt strictarr
  common ucomp_browser_common, browser

  ; parameter filename takes precedence (it clobbers keyword filename,
  ; if both present)

  if (n_elements(kfilenames) gt 0L) then _filenames = kfilenames
  if (n_elements(pfilenames) gt 0L) then _filenames = pfilenames

  if (obj_valid(browser)) then begin
    browser->load_files, _filenames
  endif else begin
    browser = mg_fits_browser(filenames=_filenames, $
                              tlb=tlb, $
                              classname='ucomp_browser', $
                              _extra=e)
  endelse
end
