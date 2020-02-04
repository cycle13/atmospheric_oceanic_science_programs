; CAPE_model_calculated_all_t_simult.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
  longitudes_1D_degE@units = "degrees east"

;  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
;  n_P = dimsizes (P_levels_1D_hPa)
  extended_P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000, 1100 /)

  t_UTC = "00"   ; Can be "00" or "06" or "12" or "18".
		; Also change in output variable name below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_file_name = "output_data_avg_surface_CAPE_calculated_JJAS_2010to2019_0to40N_40to100E_CFSv2_model.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "c")    ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y201?/pgbf201?0[6-9]??" + t_UTC + ".01.2009020500")
  grib_files = addfiles (files + ".grib", "r")
  ListSetType (grib_files, "join")

  P_levels_1D_hPa = grib_files[:]->lv_ISBL4 (0, :)
  print (P_levels_1D_hPa)
  n_P = dimsizes (P_levels_1D_hPa)

  SP_3D_Pa = grib_files[:]->PRES_3_SFC (:, {latitudes_1D_degN}, {longitudes_1D_degE})    ; Store some data from the grib file to local variable.
  SP_3D_hPa = SP_3D_Pa / 100
  SP_3D_hPa!0 = "time"
  SP_3D_hPa!1 = SP_3D_Pa!1
  SP_3D_hPa!2 = SP_3D_Pa!2
  SP_3D_hPa&latitude = SP_3D_Pa&lat_3
  SP_3D_hPa&longitude = SP_3D_Pa&lon_3
  avg_SP_2D_hPa = dim_avg_n_Wrap (SP_3D_hPa, 0)
  printVarSummary (avg_SP_2D_hPa)
  printMinMax (avg_SP_2D_hPa, 0)

  T_4D_K = grib_files[:]->TMP_3_ISBL (:, :, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_T_3D_K = dim_avg_n_Wrap (T_4D_K, 0)
  printVarSummary (avg_T_3D_K)
  printMinMax (avg_T_3D_K, 0)

  SH_4D = grib_files[:]->SPF_H_3_ISBL (:, :, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_SH_3D = dim_avg_n_Wrap (SH_4D, 0)
  avg_WVMR_3D = avg_SH_3D / (1 - avg_SH_3D)
  avg_WVMR_3D!0 = avg_SH_3D!0
  avg_WVMR_3D!1 = avg_SH_3D!1
  avg_WVMR_3D!2 = avg_SH_3D!2
  avg_WVMR_3D&lv_ISBL4 = avg_SH_3D&lv_ISBL4
  avg_WVMR_3D&lat_3 = avg_SH_3D&lat_3
  avg_WVMR_3D&lon_3 = avg_SH_3D&lon_3
  printVarSummary (avg_WVMR_3D)
  printMinMax (avg_WVMR_3D, 0)
  
  surface_GH_3D_gpm = grib_files[:]->HGT_3_SFC (:, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_surface_GH_2D_gpm = dim_avg_n_Wrap (surface_GH_3D_gpm, 0)
  printVarSummary (avg_surface_GH_2D_gpm)
  printMinMax (avg_surface_GH_2D_gpm, 0)

  P_3D_hPa = conform (avg_T_3D_K, P_levels_1D_hPa, 0)
  P_3D_Pa = P_3D_hPa * 100
  printVarSummary (P_3D_Pa)
  printMinMax (P_3D_Pa, 0)

  GH_4D_gpm = grib_files[:]->HGT_3_ISBL (:, :, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_GH_3D_gpm = dim_avg_n_Wrap (GH_4D_gpm, 0)
  printVarSummary (avg_GH_3D_gpm)
  printMinMax (avg_GH_3D_gpm, 0)
  
  c_P_3D_hPa = linmsg (P_3D_hPa, 0)
  c_P_3D_Pa!0 = avg_T_3D_K!0
  c_P_3D_Pa!1 = avg_T_3D_K!1
  c_P_3D_Pa!2 = avg_T_3D_K!2
  c_P_3D_Pa&lv_ISBL4 = avg_T_3D_K&lv_ISBL4
  c_P_3D_Pa&lat_3 = avg_T_3D_K&lat_3
  c_P_3D_Pa&lon_3 = avg_T_3D_K&lon_3

  avg_T_3D_K = linmsg (avg_T_3D_K, 0)
  avg_WVMR_3D = linmsg (avg_WVMR_3D, 0)
  avg_GH_3D_gpm = linmsg (avg_GH_3D_gpm, 0)
  avg_surface_GH_2D_gpm = linmsg (avg_surface_GH_2D_gpm, 0)
  avg_SP_2D_hPa = linmsg (avg_SP_2D_hPa, 0)

  output_4D =  wrf_cape_3d (c_P_3D_hPa, avg_T_3D_K, avg_WVMR_3D, avg_GH_3D_gpm, avg_surface_GH_2D_gpm, avg_SP_2D_hPa, False)
  printVarSummary (output_4D)
  printMinMax (output_4D, 0)

  avg_CAPE_3D_Jperkg = output_4D (0, :, :, :)
  avg_CAPE_3D_Jperkg&lv_ISBL4 = avg_T_3D_K&lv_ISBL4
  avg_CAPE_3D_Jperkg&lat_3 = avg_T_3D_K&lat_3
  avg_CAPE_3D_Jperkg&lon_3 = avg_T_3D_K&lon_3
  avg_CAPE_3D_Jperkg@units = "J/kg"
  avg_CAPE_3D_Jperkg@long_name = "Convective available potential energy"
  printVarSummary (avg_CAPE_3D_Jperkg)
  printMinMax (avg_CAPE_3D_Jperkg, 0)

  

  selected_avg_CAPE_2D_Jperkg = avg_CAPE_3D_Jperkg ({925}, :, :)
  printVarSummary (selected_avg_CAPE_2D_Jperkg)
  printMinMax (selected_avg_CAPE_2D_Jperkg, 0)

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2010-2019_CFSv2_model.png") ; Open a workstation.

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

;  res@cnMinLevelValF = 0
;  res@cnMaxLevelValF = 2100
;  res@cnLevelSpacingF  =  150

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, selected_avg_CAPE_2D_Jperkg, res)

  output_file->avg_CAPE_JJAS_18UTC_3D_Jperkg = avg_CAPE_3D_Jperkg

  delete (grib_files)

end
