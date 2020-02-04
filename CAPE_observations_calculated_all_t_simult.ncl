; CAPE_observations_calculated_all_t_simult.ncl

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

  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  n_P = dimsizes (P_levels_1D_hPa)
  extended_P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000, 1100 /)
  n_extended_P = dimsizes (extended_P_levels_1D_hPa)

;  years_1D = ispan (1999, 2018, 1)

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".
	; When modifying, also modify in output variable names below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_file_name = "output_data_CAPE_calculated_JJAS_1999to2018_0to40N_40to100E_ERA_interim_observations_10to1000hPa.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")    ; Write to netCDF file.
  output_file@title = "From analysis of observations using ERA interim data, for 20 years (1999 to 2018)." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  SP_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept????_40N40E10S100E.grib2")
  SP_grib_files = addfiles (SP_files_list, "r")
  ListSetType (SP_grib_files, "join")
  surface_pressure_4D_Pa = SP_grib_files[:]->SP_GDS0_SFC (:, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.
;  avg_surface_pressure_2D_Pa = dim_avg_n_Wrap (surface_pressure_3D_Pa, 0)
  surface_pressure_4D_hPa = surface_pressure_4D_Pa / 100
  surface_pressure_4D_hPa!0 = "year"
  surface_pressure_4D_hPa!1 = "hour"
  surface_pressure_4D_hPa!2 = "latitude"
  surface_pressure_4D_hPa!3 = "longitude"
;  surface_pressure_4D_hPa&year = years_1D
  surface_pressure_4D_hPa&latitude = surface_pressure_4D_Pa&g0_lat_1
  surface_pressure_4D_hPa&longitude = surface_pressure_4D_Pa&g0_lon_2
  surface_pressure_4D_hPa@units = "hPa"
  y_avg_SP_3D_hPa = dim_avg_n_Wrap (surface_pressure_4D_hPa, 0)
  printVarSummary (y_avg_SP_3D_hPa)
  printMinMax (y_avg_SP_3D_hPa, 0)

  T_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/temperature/temperature_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  T_grib_files = addfiles (T_files_list, "r")
  ListSetType (T_grib_files, "join")
  temperature_5D_K = T_grib_files[:]->T_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  y_avg_T_4D_K = dim_avg_n_Wrap (temperature_5D_K, 0)
  printVarSummary (y_avg_T_4D_K)
  printMinMax (y_avg_T_4D_K, 0)

  SH_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/specific_humidity/specific_humidty_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  SH_grib_files = addfiles (SH_files_list, "r")
  ListSetType (SH_grib_files, "join")
  SH_5D = SH_grib_files[:]->Q_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  y_avg_SH_4D = dim_avg_n_Wrap (SH_5D, 0)
  printVarSummary (y_avg_SH_4D)
  printMinMax (y_avg_SH_4D, 0)

  y_avg_WVMR_4D = y_avg_SH_4D / (1 - y_avg_SH_4D)
  y_avg_WVMR_4D!0 = "time"
  y_avg_WVMR_4D!1 = "level"
  y_avg_WVMR_4D!2 = "latitude"
  y_avg_WVMR_4D!3 = "longitude"
  y_avg_WVMR_4D&time = SH_5D&initial_time0_hours
  y_avg_WVMR_4D&latitude = SH_5D&g0_lat_2
  y_avg_WVMR_4D&longitude = SH_5D&g0_lon_3
  y_avg_WVMR_4D@units = "kg/kg"
  y_avg_WVMR_4D@long_name = "Water vapour mixing ratio"
  printVarSummary (y_avg_WVMR_4D)
  printMinMax (y_avg_WVMR_4D, 0)

  geopot_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/geopotential_2D_invariant_ERAint_1x1deg_40N40E10S100E.grib", "r")
  geopotential_2D_m2pers2 = geopot_grib_file->Z_GDS0_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  surface_height_2D_m = geopotential_2D_m2pers2 / 9.8
  surface_height_3D_m = conform (y_avg_SP_3D_hPa, surface_height_2D_m, (/ 1, 2 /))
  surface_height_3D_m!0 = "time"
  surface_height_3D_m!1 = "latitude"
  surface_height_3D_m!2 = "longitude"
  surface_height_3D_m&latitude = geopotential_2D_m2pers2&g0_lat_0
  surface_height_3D_m&longitude = geopotential_2D_m2pers2&g0_lon_1
  surface_height_3D_m@units = "m"
  surface_height_3D_m@long_name = "Surface height"
  printVarSummary (surface_height_3D_m)
  printMinMax (surface_height_3D_m, 0)

  pressure_4D_hPa = conform (y_avg_T_4D_K, P_levels_1D_hPa, 1)
  pressure_4D_Pa = pressure_4D_hPa * 100
;  pressure_3D_Pa = new ((/ n_P, n_latitudes, n_longitudes /), float)
  pressure_4D_Pa@units = "Pa"
  pressure_4D_Pa!0 = y_avg_T_4D_K!0
  pressure_4D_Pa!1 = y_avg_T_4D_K!1
  pressure_4D_Pa!2 = y_avg_T_4D_K!2
  pressure_4D_Pa!3 = y_avg_T_4D_K!3
  pressure_4D_Pa&initial_time0_hours = y_avg_T_4D_K&initial_time0_hours
  pressure_4D_Pa&lv_ISBL1 = y_avg_T_4D_K&lv_ISBL1
  pressure_4D_Pa&g0_lat_2 = y_avg_T_4D_K&g0_lat_2
  pressure_4D_Pa&g0_lon_3 = y_avg_T_4D_K&g0_lon_3
  printVarSummary (pressure_4D_Pa)
  printMinMax (pressure_4D_Pa, 0)

  g_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/geopotential_4D/geopotential_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  geopot_grib_files = addfiles (g_files_list, "r")
  ListSetType (geopot_grib_files, "join")
  geopotential_5D_m2pers2 = geopot_grib_files[:]->Z_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  full_model_height_5D_m = geopotential_5D_m2pers2 / 9.8
;  full_model_height_3D_m = new ((/ n_P, n_latitudes, n_longitudes /), float)
  full_model_height_5D_m@units = "m"
;  full_model_height_5D_m!0 = "year"
;  full_model_height_5D_m!0 = geopotential_5D_m2pers2!0
  full_model_height_5D_m!1 = geopotential_5D_m2pers2!1
  full_model_height_5D_m!2 = geopotential_5D_m2pers2!2
  full_model_height_5D_m!3 = geopotential_5D_m2pers2!3
  full_model_height_5D_m!4 = geopotential_5D_m2pers2!4
  full_model_height_5D_m&initial_time0_hours = geopotential_5D_m2pers2&initial_time0_hours
  full_model_height_5D_m&lv_ISBL1 = geopotential_5D_m2pers2&lv_ISBL1
  full_model_height_5D_m&g0_lat_2 = geopotential_5D_m2pers2&g0_lat_2
  full_model_height_5D_m&g0_lon_3 = geopotential_5D_m2pers2&g0_lon_3
  y_avg_H_4D_m = dim_avg_n_Wrap (full_model_height_5D_m, 0)
  printVarSummary (y_avg_H_4D_m)
  printMinMax (y_avg_H_4D_m, 0)
  
  c_pressure_4D_Pa = linmsg (pressure_4D_Pa, 0)
  y_avg_T_4D_K = linmsg (y_avg_T_4D_K, 0)
  y_avg_WVMR_4D = linmsg (y_avg_WVMR_4D, 0)
  y_avg_H_4D_m = linmsg (y_avg_H_4D_m, 0)
  surface_height_3D_m = linmsg (surface_height_3D_m, 0)
  y_avg_SP_3D_hPa = linmsg (y_avg_SP_3D_hPa, 0)

  output_5D = wrf_cape_3d (c_pressure_4D_Pa, y_avg_T_4D_K, y_avg_WVMR_4D, y_avg_H_4D_m, surface_height_3D_m, y_avg_SP_3D_hPa, False)
  printVarSummary (output_5D)
  printMinMax (output_5D, 0)

  y_avg_CAPE_4D_Jperkg = output_5D (0, :, :, :, :)
  y_avg_CAPE_4D_kJperkg = y_avg_CAPE_4D_Jperkg / 1000
  y_avg_CAPE_4D_kJperkg!0 = y_avg_T_4D_K!0
  y_avg_CAPE_4D_kJperkg!1 = y_avg_T_4D_K!1
  y_avg_CAPE_4D_kJperkg!2 = y_avg_T_4D_K!2
  y_avg_CAPE_4D_kJperkg!3 = y_avg_T_4D_K!3
  y_avg_CAPE_4D_kJperkg&initial_time0_hours = y_avg_T_4D_K&initial_time0_hours
  y_avg_CAPE_4D_kJperkg&lv_ISBL1 = y_avg_T_4D_K&lv_ISBL1
  y_avg_CAPE_4D_kJperkg&g0_lat_2 = y_avg_T_4D_K&g0_lat_2
  y_avg_CAPE_4D_kJperkg&g0_lon_3 = y_avg_T_4D_K&g0_lon_3
  y_avg_CAPE_4D_kJperkg@units = "kJ/kg"
  y_avg_CAPE_4D_kJperkg@long_name = "Convective available potential energy"
  printVarSummary (y_avg_CAPE_4D_kJperkg)
  printMinMax (y_avg_CAPE_4D_kJperkg, 0)

  surface_y_avg_CAPE_3D_kJperkg = new ( (/ 122, n_latitudes, n_longitudes /), float)

  surface_y_avg_CAPE_3D_kJperkg!0 = y_avg_CAPE_4D_kJperkg!0
  surface_y_avg_CAPE_3D_kJperkg!1 = y_avg_CAPE_4D_kJperkg!2
  surface_y_avg_CAPE_3D_kJperkg!2 = y_avg_CAPE_4D_kJperkg!3
  surface_y_avg_CAPE_3D_kJperkg&initial_time0_hours = y_avg_CAPE_4D_kJperkg&initial_time0_hours
  surface_y_avg_CAPE_3D_kJperkg&g0_lat_2 = y_avg_CAPE_4D_kJperkg&g0_lat_2
  surface_y_avg_CAPE_3D_kJperkg&g0_lon_3 = y_avg_CAPE_4D_kJperkg&g0_lon_3
  surface_y_avg_CAPE_3D_kJperkg@units = "kJ/kg"
  surface_y_avg_CAPE_3D_Jperkg@long_name = "Surface convective available potential energy"

do i_time = 0, 121
  do i_lat = 0, n_latitudes - 1
    do i_lon = 0, n_longitudes - 1
      do i_level = 0, n_extended_P - 2
        if (y_avg_SP_3D_hPa (i_time, i_lat, i_lon) .gt. extended_P_levels_1D_hPa (i_level)) .and. (y_avg_SP_3D_hPa (i_time, i_lat, i_lon) .lt. extended_P_levels_1D_hPa (i_level + 1)) then
          surface_y_avg_CAPE_3D_kJperkg (i_time, i_lat, i_lon) = (/ y_avg_CAPE_4D_kJperkg (i_time, i_level, i_lat, i_lon) /)
          break
        end if
      end do
    end do
  end do
end do

;  selected_CAPE_3D_kJperkg = y_avg_CAPE_4D_kJperkg (:, {925}, :, :)
  printVarSummary (surface_y_avg_CAPE_3D_kJperkg)
  printMinMax (surface_y_avg_CAPE_3D_kJperkg, 0)

  avg_surface_CAPE_2D_kJperkg = dim_avg_n_Wrap (surface_y_avg_CAPE_3D_kJperkg, 0)
  printVarSummary (avg_surface_CAPE_2D_kJperkg)
  printMinMax (avg_surface_CAPE_2D_kJperkg, 0)

  output_file->y_avg_CAPE_JJAS_18UTC_4D_kJperkg = y_avg_CAPE_4D_kJperkg
  output_file->y_avg_surface_CAPE_JJAS_18UTC_3D_kJperkg = surface_y_avg_CAPE_3D_kJperkg

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_surface_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_1999-2018_ERA_interim_observations") ; Open a workstation.

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

;  res@cnMinLevelValF = 200
;  res@cnMaxLevelValF = 3800
;  res@cnLevelSpacingF  =  200

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, avg_surface_CAPE_2D_kJperkg, res)

  delete (SP_grib_files)
  delete (T_grib_files)
  delete (SH_grib_files)
  delete (geopot_grib_file)
  delete (geopot_grib_files)

end
