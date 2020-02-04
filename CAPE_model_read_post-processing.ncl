; CAPE_model_read_post-processing.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  cdf_filename = "output_data_avg_CAPE_read_JJAS_2009to2025_0to40N_40to100E_CFSv2_model.nc"
;  system ("/bin/rm -f " + cdf_filename)
  cdf_file = addfile ("/Vol2/sarthak/output_data/" + cdf_filename, "r")    ; Write to netCDF file.

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".
		; When changing, also change in input variable names below.

  avg_CAPE_SPDY_D2_Jperkg = cdf_file->avg_CAPE_SPDY_JJAS_18UTC_D2_Jperkg ( {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )    ; Store some data from input file to local variable.
  avg_CAPE_SFC_D2_Jperkg = cdf_file->avg_CAPE_SFC_JJAS_18UTC_D2_Jperkg ( {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )

  avg_CAPE_SPDY_D2_kJperkg = avg_CAPE_SPDY_D2_Jperkg / 1000
  avg_CAPE_SPDY_D2_kJperkg!0 = avg_CAPE_SPDY_D2_Jperkg!0
  avg_CAPE_SPDY_D2_kJperkg!1 = avg_CAPE_SPDY_D2_Jperkg!1
  avg_CAPE_SPDY_D2_kJperkg&lat_3 = avg_CAPE_SPDY_D2_Jperkg&lat_3
  avg_CAPE_SPDY_D2_kJperkg&lon_3 = avg_CAPE_SPDY_D2_Jperkg&lon_3
  avg_CAPE_SPDY_D2_kJperkg@units = "kJ/kg"
  avg_CAPE_SPDY_D2_kJperkg@long_name = "Convective available potential energy (SPDY)"

  printVarSummary (avg_CAPE_SPDY_D2_kJperkg)
  printMinMax (avg_CAPE_SPDY_D2_kJperkg, 0)
  
  avg_CAPE_SFC_D2_kJperkg = avg_CAPE_SFC_D2_Jperkg / 1000
  avg_CAPE_SFC_D2_kJperkg!0 = avg_CAPE_SFC_D2_Jperkg!0
  avg_CAPE_SFC_D2_kJperkg!1 = avg_CAPE_SFC_D2_Jperkg!1
  avg_CAPE_SFC_D2_kJperkg&lat_3 = avg_CAPE_SFC_D2_Jperkg&lat_3
  avg_CAPE_SFC_D2_kJperkg&lon_3 = avg_CAPE_SFC_D2_Jperkg&lon_3
  avg_CAPE_SFC_D2_kJperkg@units = "kJ/kg"
  avg_CAPE_SFC_D2_kJperkg@long_name = "Convective available potential energy (SFC)"

  printVarSummary (avg_CAPE_SFC_D2_kJperkg)
  printMinMax (avg_CAPE_SFC_D2_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_SPDY = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_SPDY_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2025_CFSv2_model") ; Open a workstation.
  wks_SFC = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_SFC_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2025_CFSv2_model") 

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

  res@cnMinLevelValF = 0.15
  res@cnMaxLevelValF = 2.4
  res@cnLevelSpacingF  =  0.15

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy_SPDY = gsn_csm_contour_map (wks_SPDY, avg_CAPE_SPDY_D2_kJperkg, res)
  xy_SFC = gsn_csm_contour_map (wks_SFC, avg_CAPE_SFC_D2_kJperkg, res)

  delete (cdf_file)

end
