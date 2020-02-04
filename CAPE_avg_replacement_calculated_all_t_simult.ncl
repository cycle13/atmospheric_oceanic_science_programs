; CAPE_avg_replacement_calculated_all_t_simult.ncl

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
;  extended_P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000, 1100 /)

  t_UTC = "00"   ; Can be "00" or "06" or "12" or "18".
		; Also change in output variable name below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_file_name = "output_data_avg_CAPE_calculated_JJAS_0to40N_40to100E_replacement_10to1000hPa.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "c")    ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 (model), with temperature and specific humidity at 925 hPa pressure level replaced with those of ERA interim (observations)." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  T_obs_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/temperature/temperature_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  T_obs_files = addfiles (T_obs_files_list, "r")
  ListSetType (T_obs_files, "join")
  T_obs_925hPa_4D_K = T_obs_files[:]->T_GDS0_ISBL (:, :, {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (T_obs_925hPa_4D_K)
  printMinMax (T_obs_925hPa_4D_K, 0)
  avg_T_obs_925hPa_2D_K = dim_avg_n_Wrap (T_obs_925hPa_4D_K, (/0, 1/))
  printVarSummary (avg_T_obs_925hPa_2D_K)
  printMinMax (avg_T_obs_925hPa_2D_K, 0)

  SH_obs_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/specific_humidity/specific_humidty_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  SH_obs_files = addfiles (SH_obs_files_list, "r")
  ListSetType (SH_obs_files, "join")
  SH_obs_925hPa_4D = SH_obs_files[:]->Q_GDS0_ISBL (:, :, {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SH_obs_925hPa_4D)
  printMinMax (SH_obs_925hPa_4D, 0)
  avg_SH_obs_925hPa_2D = dim_avg_n_Wrap (SH_obs_925hPa_4D, (/0, 1/))
  printVarSummary (avg_SH_obs_925hPa_2D)
  printMinMax (avg_SH_obs_925hPa_2D, 0)

  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y20??/pgbf20??0[6-9]??" + t_UTC + ".01.2009020500")
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
  SP_3D_hPa&lat_3 = SP_3D_Pa&lat_3
  SP_3D_hPa&lon_3 = SP_3D_Pa&lon_3
  avg_SP_2D_hPa = dim_avg_n_Wrap (SP_3D_hPa, 0)
  printVarSummary (avg_SP_2D_hPa)
  printMinMax (avg_SP_2D_hPa, 0)

  T_4D_K = grib_files[:]->TMP_3_ISBL (:, :, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_T_3D_K = dim_avg_n_Wrap (T_4D_K, 0)
  avg_T_3D_K ({925}, :, :) = (/ avg_T_obs_925hPa_2D_K /)
  printVarSummary (avg_T_3D_K)
  printMinMax (avg_T_3D_K, 0)

  SH_4D = grib_files[:]->SPF_H_3_ISBL (:, :, {latitudes_1D_degN}, {longitudes_1D_degE})
  avg_SH_3D = dim_avg_n_Wrap (SH_4D, 0)
  avg_SH_3D ({925}, :, :) = (/ avg_SH_obs_925hPa_2D /)
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
  avg_CAPE_3D_kJperkg = avg_CAPE_3D_Jperkg / 1000
  avg_CAPE_3D_kJperkg!0 = avg_T_3D_K!0
  avg_CAPE_3D_kJperkg!1 = avg_T_3D_K!1
  avg_CAPE_3D_kJperkg!2 = avg_T_3D_K!2
  avg_CAPE_3D_kJperkg&lv_ISBL4 = avg_T_3D_K&lv_ISBL4
  avg_CAPE_3D_kJperkg&lat_3 = avg_T_3D_K&lat_3
  avg_CAPE_3D_kJperkg&lon_3 = avg_T_3D_K&lon_3
  avg_CAPE_3D_kJperkg@units = "kJ/kg"
  avg_CAPE_3D_kJperkg@long_name = "Convective available potential energy"
  printVarSummary (avg_CAPE_3D_kJperkg)
  printMinMax (avg_CAPE_3D_kJperkg, 0)

  avg_CAPE_925hPa_2D_kJperkg = avg_CAPE_3D_kJperkg ({925}, :, :)
  printVarSummary (avg_CAPE_925hPa_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_2D_kJperkg, 0)

  output_file->avg_CAPE_JJAS_00UTC_3D_Jperkg = avg_CAPE_3D_kJperkg

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_replacement_10-1000hPa_all_t_simult.png") ; Open a workstation.

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

  xy = gsn_csm_contour_map (wks, avg_CAPE_925hPa_2D_kJperkg, res)

  delete (SH_obs_files)
  delete (T_obs_files)
  delete (grib_files)

end

