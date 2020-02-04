; CAPE_replacement_calculated_full_post-processing.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
;  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
;  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
;  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
;  longitudes_1D_degE@units = "degrees east"

;  P_levels_1D_hPa = (/ 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 /)
;  n_P = dimsizes (P_levels_1D_hPa)

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".
		; Also change in input variable name below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  input_file_name = "output_data_CAPE_avg_calculated_full_JJAS_0-40N_40-100E_replacement_10-1000hPa_1_t_at_a_time.nc"
;  system ("/bin/rm -f " + cdf_filename)
  input_file = addfile ("/Vol2/sarthak/output_data/" + input_file_name, "r")    ; Write to netCDF file.

  CAPE_avg_3D_kJperkg = input_file->CAPE_JJAS_18UTC_3D_replaced_kJperkg
  printVarSummary (CAPE_avg_3D_kJperkg)
  printMinMax (CAPE_avg_3D_kJperkg, 0)

  CAPE_avg_925hPa_2D_kJperkg = CAPE_avg_3D_kJperkg ( {925}, :, :)
  CAPE_avg_925hPa_2D_kJperkg@long_name = "Average convective available potential energy at 925 hPa pressure level"
  printVarSummary (CAPE_avg_925hPa_2D_kJperkg)
  printMinMax (CAPE_avg_925hPa_2D_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_full_replacement_10-1000hPa.png") ; Open a workstation.

  res = True
  res@gsnDraw = True
  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  cmap = read_colormap_file ("WhiteBlueGreenYellowRed")
  res@cnFillPalette = cmap

  res@cnMinLevelValF = 0.2
  res@cnMaxLevelValF = 2.8
  res@cnLevelSpacingF  =  0.2

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, CAPE_avg_925hPa_2D_kJperkg, res)

  delete (input_file)

end
