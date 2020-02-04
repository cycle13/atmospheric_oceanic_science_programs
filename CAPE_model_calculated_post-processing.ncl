; CAPE_model_calculated_post-processing.ncl

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

  t_UTC = "00"   ; Can be "00" or "06" or "12" or "18".
		; Also change in input variable name below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  input_file_name = "output_data_CAPE_calculated_JJAS_2009-2025_0-40N_40-100E_CFSv2_model_10-1000hPa.nc"
;  system ("/bin/rm -f " + cdf_filename)
  input_file = addfile ("/Vol2/sarthak/output_data/" + input_file_name, "r")    ; Write to netCDF file.

  CAPE_925hPa_4D_Jperkg = input_file->CAPE_JJAS_00UTC_5D_Jperkg (:, :, {925}, :, :)
  printVarSummary (CAPE_925hPa_4D_Jperkg)
  printMinMax (CAPE_925hPa_4D_Jperkg, 0)

;  selected_avg_CAPE_2D_Jperkg = avg_CAPE_3D_Jperkg ({925}, :, :)

  avg_CAPE_925hPa_2D_Jperkg = dim_avg_n_Wrap (CAPE_925hPa_4D_Jperkg, (/ 0, 1 /))
  printVarSummary (avg_CAPE_925hPa_2D_Jperkg)
  printMinMax (avg_CAPE_925hPa_2D_Jperkg, 0)

  avg_CAPE_925hPa_2D_kJperkg = avg_CAPE_925hPa_2D_Jperkg / 1000
  avg_CAPE_925hPa_2D_kJperkg!0 = avg_CAPE_925hPa_2D_Jperkg!0
  avg_CAPE_925hPa_2D_kJperkg!1 = avg_CAPE_925hPa_2D_Jperkg!1
  avg_CAPE_925hPa_2D_kJperkg&lat_3 = avg_CAPE_925hPa_2D_Jperkg&lat_3
  avg_CAPE_925hPa_2D_kJperkg&lon_3 = avg_CAPE_925hPa_2D_Jperkg&lon_3
  avg_CAPE_925hPa_2D_kJperkg@units = "kJ/kg"
  avg_CAPE_925hPa_2D_kJperkg@long_name = "Average convective available potential energy at 925 hPa pressure level"
  printVarSummary (avg_CAPE_925hPa_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_2D_kJperkg, 0)

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2025_CFSv2_model_10to1000hPa.png") ; Open a workstation.

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

  xy = gsn_csm_contour_map (wks, avg_CAPE_925hPa_2D_kJperkg, res)

end
