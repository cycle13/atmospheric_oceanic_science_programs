; moisture_balance_ERAinterim.ncl

begin

  g_m2pers2 = 9.81
  water_density_kgperm3 = 997.0
  earth_radius_m = 6371000.0
  P_bottom_Pa = 110000
  P_top_Pa = 1000

  start_lat_deg_N = 8  ; When changing, also change in output variable names below.
  stop_lat_deg_N = 28
  n_lat = stop_lat_deg_N - start_lat_deg_N + 1
;  lat_1D_deg_N = ispan (start_lat_deg_N, stop_lat_deg_N, 1)

  start_lon_deg_E = 70  ; When changing, also change in output variable names below.
  stop_lon_deg_E = 90
  n_lon = stop_lon_deg_E - start_lon_deg_E + 1
;  lon_1D_deg_E = ispan (start_lon_deg_E, stop_lon_deg_E, 1)

 t_UTC = "18"	; Can be "00" or "06" or "12" or "18". When changing, also change in output variable names below.
  print (t_UTC)
  
  output_file_name = "output_data_moisture_balance_CFSv2_ERAinterim_vibeta.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")  ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model and ERA interim observations." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  SH_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/specific_humidity/specific_humidty_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  SH_input_files = addfiles (SH_files_list, "r")
  ListSetType (SH_input_files, "join")
;  printVarSummary (SH_input_files)

  P_levels_1D_hPa = (/ 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10 /)
  P_levels_1D_Pa = P_levels_1D_hPa * 100
  print (P_levels_1D_Pa)

  n_P = dimsizes (P_levels_1D_Pa)
  print (n_P)

  printMinMax (SH_obs_start_lat_4D, 0)

  SH_obs_stop_lat_4D = SH_input_files[:]->Q_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SH_obs_stop_lat_4D)
  printMinMax (SH_obs_stop_lat_4D, 0)

  SH_obs_start_lon_4D = SH_input_files[:]->Q_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E})
  printVarSummary (SH_obs_start_lon_4D)
  printMinMax (SH_obs_start_lon_4D, 0)

  SH_obs_stop_lon_4D = SH_input_files[:]->Q_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {stop_lon_deg_E})
  printVarSummary (SH_obs_stop_lon_4D)
  printMinMax (SH_obs_stop_lon_4D, 0)

  SP_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept????_40N40E10S100E.grib2")
  SP_input_files = addfiles (SP_files_list, "r")
  ListSetType (SP_input_files, "join")

  SP_obs_start_lat_3D_Pa = SP_input_files[:]->SP_GDS0_SFC (:, :, {start_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SP_obs_start_lat_3D_Pa)
  printMinMax (SP_obs_start_lat_3D_Pa, 0)

  SP_obs_stop_lat_3D_Pa = SP_input_files[:]->SP_GDS0_SFC (:, :, {stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SP_obs_stop_lat_3D_Pa)
  printMinMax (SP_obs_stop_lat_3D_Pa, 0)

  SP_obs_start_lon_3D_Pa = SP_input_files[:]->SP_GDS0_SFC (:, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E})
  printVarSummary (SP_obs_start_lon_3D_Pa)
  printMinMax (SP_obs_start_lon_3D_Pa, 0)

  SP_obs_stop_lon_3D_Pa = SP_input_files[:]->SP_GDS0_SFC (:, :, {start_lat_deg_N : stop_lat_deg_N}, {stop_lon_deg_E})
  printVarSummary (SP_obs_stop_lon_3D_Pa)
  printMinMax (SP_obs_stop_lon_3D_Pa, 0)

  velocity_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/velocity/velocity_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10-1000hPa.grib2")
  velocity_input_files = addfiles (velocity_files_list, "r")
  ListSetType (velocity_input_files, "join")

  V_obs_start_lat_4D_mpers = velocity_input_files[:]->V_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (V_obs_start_lat_4D_mpers)
  printMinMax (V_obs_start_lat_4D_mpers, 0)

  V_obs_stop_lat_4D_mpers = velocity_input_files[:]->V_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (V_obs_stop_lat_4D_mpers)
  printMinMax (V_obs_stop_lat_4D_mpers, 0)

  U_obs_start_lon_4D_mpers = velocity_input_files[:]->U_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E})
  printVarSummary (U_obs_start_lon_4D_mpers)
  printMinMax (U_obs_start_lon_4D_mpers, 0)

  U_obs_stop_lon_4D_mpers = velocity_input_files[:]->U_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {stop_lon_deg_E})
  printVarSummary (U_obs_stop_lon_4D_mpers)
  printMinMax (U_obs_stop_lon_4D_mpers, 0)

  delete (SH_input_files)
  delete (velocity_input_files)
  delete (SP_input_files)

;  return

  year_1D = ispan (1999, 2018, 1)
  n_years = dimsizes (year_1D)
  day_1D = ispan (1, 122, 1)
  n_days = dimsizes (day_1D)
  n_latlon = 21

  V_SH_per_g_obs_start_lat_4D_s = V_obs_start_lat_4D_mpers * SH_obs_start_lat_4D / g_m2pers2
  V_SH_per_g_obs_start_lat_4D_s!0 = "year"
  V_SH_per_g_obs_start_lat_4D_s!1 = V_obs_start_lat_4D_mpers!1
  V_SH_per_g_obs_start_lat_4D_s!2 = V_obs_start_lat_4D_mpers!2
  V_SH_per_g_obs_start_lat_4D_s!3 = V_obs_start_lat_4D_mpers!3
  V_SH_per_g_obs_start_lat_4D_s&year = year_1D
  V_SH_per_g_obs_start_lat_4D_s&initial_time0_hours = V_obs_start_lat_4D_mpers&initial_time0_hours
  V_SH_per_g_obs_start_lat_4D_s&lv_ISBL1 = V_obs_start_lat_4D_mpers&lv_ISBL1
  V_SH_per_g_obs_start_lat_4D_s&g0_lon_3 = V_obs_start_lat_4D_mpers&g0_lon_3
  V_SH_per_g_obs_start_lat_4D_s@units = "s"

  V_SH_per_g_obs_stop_lat_4D_s = V_obs_stop_lat_4D_mpers * SH_obs_stop_lat_4D / g_m2pers2
  V_SH_per_g_obs_stop_lat_4D_s!0 = "year"
  V_SH_per_g_obs_stop_lat_4D_s!1 = V_obs_stop_lat_4D_mpers!1
  V_SH_per_g_obs_stop_lat_4D_s!2 = V_obs_stop_lat_4D_mpers!2
  V_SH_per_g_obs_stop_lat_4D_s!3 = V_obs_stop_lat_4D_mpers!3
  V_SH_per_g_obs_stop_lat_4D_s&year = year_1D
  V_SH_per_g_obs_stop_lat_4D_s&initial_time0_hours = V_obs_stop_lat_4D_mpers&initial_time0_hours
  V_SH_per_g_obs_stop_lat_4D_s&lv_ISBL1 = V_obs_stop_lat_4D_mpers&lv_ISBL1
  V_SH_per_g_obs_stop_lat_4D_s&g0_lon_3 = V_obs_stop_lat_4D_mpers&g0_lon_3
  V_SH_per_g_obs_stop_lat_4D_s@units = "s"

  U_SH_per_g_obs_start_lon_4D_s = U_obs_start_lon_4D_mpers * SH_obs_start_lon_4D / g_m2pers2
  U_SH_per_g_obs_start_lon_4D_s!0 = "year"
  U_SH_per_g_obs_start_lon_4D_s!1 = U_obs_start_lon_4D_mpers!1
  U_SH_per_g_obs_start_lon_4D_s!2 = U_obs_start_lon_4D_mpers!2
  U_SH_per_g_obs_start_lon_4D_s!3 = U_obs_start_lon_4D_mpers!3
  U_SH_per_g_obs_start_lon_4D_s&year = year_1D
  U_SH_per_g_obs_start_lon_4D_s&initial_time0_hours = U_obs_start_lon_4D_mpers&initial_time0_hours
  U_SH_per_g_obs_start_lon_4D_s&lv_ISBL1 = U_obs_start_lon_4D_mpers&lv_ISBL1
  U_SH_per_g_obs_start_lon_4D_s&g0_lat_2 = U_obs_start_lon_4D_mpers&g0_lat_2
  U_SH_per_g_obs_start_lon_4D_s@units = "s"

  U_SH_per_g_obs_stop_lon_4D_s = U_obs_stop_lon_4D_mpers * SH_obs_stop_lon_4D / g_m2pers2
  U_SH_per_g_obs_stop_lon_4D_s!0 = "year"
  U_SH_per_g_obs_stop_lon_4D_s!1 = U_obs_stop_lon_4D_mpers!1
  U_SH_per_g_obs_stop_lon_4D_s!2 = U_obs_stop_lon_4D_mpers!2
  U_SH_per_g_obs_stop_lon_4D_s!3 = U_obs_stop_lon_4D_mpers!3
  U_SH_per_g_obs_stop_lon_4D_s&year = year_1D
  U_SH_per_g_obs_stop_lon_4D_s&initial_time0_hours = U_obs_stop_lon_4D_mpers&initial_time0_hours
  U_SH_per_g_obs_stop_lon_4D_s&lv_ISBL1 = U_obs_stop_lon_4D_mpers&lv_ISBL1
  U_SH_per_g_obs_stop_lon_4D_s&g0_lat_2 = U_obs_stop_lon_4D_mpers&g0_lat_2
  U_SH_per_g_obs_stop_lon_4D_s@units = "s"

  printVarSummary (V_SH_per_g_obs_start_lat_4D_s)
  printVarSummary (V_SH_per_g_obs_stop_lat_4D_s)
  printVarSummary (U_SH_per_g_obs_start_lon_4D_s)
  printVarSummary (U_SH_per_g_obs_stop_lon_4D_s)

  integral_obs_start_lat_3D_kgperms = vibeta (P_levels_1D_Pa, V_SH_per_g_obs_start_lat_4D_s (year|:, initial_time0_hours|:, g0_lon_3|:, lv_ISBL1|:), 1, SP_obs_start_lat_3D_Pa, P_bottom_Pa, P_top_Pa)
  integral_obs_stop_lat_3D_kgperms = vibeta (P_levels_1D_Pa, V_SH_per_g_obs_stop_lat_4D_s (year|:, initial_time0_hours|:, g0_lon_3|:, lv_ISBL1|:), 1, SP_obs_stop_lat_3D_Pa, P_bottom_Pa, P_top_Pa)
  integral_obs_start_lon_3D_kgperms = vibeta (P_levels_1D_Pa, U_SH_per_g_obs_start_lon_4D_s (year|:, initial_time0_hours|:, g0_lat_2|:, lv_ISBL1|:), 1, SP_obs_start_lon_3D_Pa, P_bottom_Pa, P_top_Pa)
  integral_obs_stop_lon_3D_kgperms = vibeta (P_levels_1D_Pa, U_SH_per_g_obs_stop_lon_4D_s (year|:, initial_time0_hours|:, g0_lat_2|:, lv_ISBL1|:), 1, SP_obs_stop_lon_3D_Pa, P_bottom_Pa, P_top_Pa)

  printVarSummary (integral_obs_start_lat_3D_kgperms)
  printVarSummary (integral_obs_stop_lat_3D_kgperms)
  printVarSummary (integral_obs_start_lon_3D_kgperms)
  printVarSummary (integral_obs_stop_lon_3D_kgperms)

  integral_obs_start_lat_interval_3D_kgperms = new ((/ n_years, n_days, n_lon - 1 /), float)
  integral_obs_stop_lat_interval_3D_kgperms = new ((/ n_years, n_days, n_lon - 1 /), float)
  integral_obs_start_lon_interval_3D_kgperms = new ((/ n_years, n_days, n_lat - 1 /), float)
  integral_obs_stop_lon_interval_3D_kgperms = new ((/ n_years, n_days, n_lat - 1 /), float)

  do i_latlon = 0, n_latlon - 2
    integral_obs_start_lat_interval_3D_kgperms (:, :, i_latlon) = (integral_obs_start_lat_3D_kgperms (:, :, i_latlon) + integral_obs_start_lat_3D_kgperms (:, :, i_latlon + 1)) / 2
    integral_obs_stop_lat_interval_3D_kgperms (:, :, i_latlon) = (integral_obs_stop_lat_3D_kgperms (:, :, i_latlon) + integral_obs_stop_lat_3D_kgperms (:, :, i_latlon + 1)) / 2
    integral_obs_start_lon_interval_3D_kgperms (:, :, i_latlon) = (integral_obs_start_lon_3D_kgperms (:, :, i_latlon) + integral_obs_start_lon_3D_kgperms (:, :, i_latlon + 1)) / 2
    integral_obs_stop_lon_interval_3D_kgperms (:, :, i_latlon) = (integral_obs_stop_lon_3D_kgperms (:, :, i_latlon) + integral_obs_stop_lon_3D_kgperms (:, :, i_latlon + 1)) / 2
  end do

  moisture_rate_obs_start_lat_3D_kgpers = integral_obs_start_lat_interval_3D_kgperms * gc_latlon (start_lat_deg_N, 80, start_lat_deg_N, 81, 2, -3)
  moisture_rate_obs_stop_lat_3D_kgpers = integral_obs_stop_lat_interval_3D_kgperms * gc_latlon (stop_lat_deg_N, 80, stop_lat_deg_N, 81, 2, -3)
  moisture_rate_obs_start_lon_3D_kgpers = integral_obs_start_lon_interval_3D_kgperms * gc_latlon (15, start_lon_deg_E, 16, start_lon_deg_E, 2, -3)
  moisture_rate_obs_stop_lon_3D_kgpers = integral_obs_stop_lon_interval_3D_kgperms * gc_latlon (15, stop_lon_deg_E, 16, stop_lon_deg_E, 2, -3)

  moisture_rate_obs_start_lat_2D_kgpers = dim_sum_n_Wrap (moisture_rate_obs_start_lat_3D_kgpers, 2)
  moisture_rate_obs_start_lat_2D_kgpers!0 = "year"
  moisture_rate_obs_start_lat_2D_kgpers!1 = "day"
  moisture_rate_obs_start_lat_2D_kgpers&year = year_1D
  moisture_rate_obs_start_lat_2D_kgpers&day = day_1D
  moisture_rate_obs_start_lat_2D_kgpers@units = "kg/s"
  moisture_rate_obs_start_lat_2D_kgpers@long_name = "Moisture transfer rate for starting latitude (ERA interim)"
  print (avg (moisture_rate_obs_start_lat_2D_kgpers))

  moisture_rate_obs_stop_lat_2D_kgpers = dim_sum_n_Wrap (moisture_rate_obs_stop_lat_3D_kgpers, 2)
  moisture_rate_obs_stop_lat_2D_kgpers!0 = "year"
  moisture_rate_obs_stop_lat_2D_kgpers!1 = "day"
  moisture_rate_obs_stop_lat_2D_kgpers&year = year_1D
  moisture_rate_obs_stop_lat_2D_kgpers&day = day_1D
  moisture_rate_obs_stop_lat_2D_kgpers@units = "kg/s"
  moisture_rate_obs_stop_lat_2D_kgpers@long_name = "Moisture transfer rate for stopping latitude (ERA interim)"
  print (avg (moisture_rate_obs_stop_lat_2D_kgpers))

  moisture_rate_obs_start_lon_2D_kgpers = dim_sum_n_Wrap (moisture_rate_obs_start_lon_3D_kgpers, 2)
  moisture_rate_obs_start_lon_2D_kgpers!0 = "year"
  moisture_rate_obs_start_lon_2D_kgpers!1 = "day"
  moisture_rate_obs_start_lon_2D_kgpers&year = year_1D
  moisture_rate_obs_start_lon_2D_kgpers&day = day_1D
  moisture_rate_obs_start_lon_2D_kgpers@units = "kg/s"
  moisture_rate_obs_start_lon_2D_kgpers@long_name = "Moisture transfer rate for starting longitude (ERA interim)"
  print (avg (moisture_rate_obs_start_lon_2D_kgpers))

  moisture_rate_obs_stop_lon_2D_kgpers = dim_sum_n_Wrap (moisture_rate_obs_stop_lon_3D_kgpers, 2)
  moisture_rate_obs_stop_lon_2D_kgpers!0 = "year"
  moisture_rate_obs_stop_lon_2D_kgpers!1 = "day"
  moisture_rate_obs_stop_lon_2D_kgpers&year = year_1D
  moisture_rate_obs_stop_lon_2D_kgpers&day = day_1D
  moisture_rate_obs_stop_lon_2D_kgpers@units = "kg/s"
  moisture_rate_obs_stop_lon_2D_kgpers@long_name = "Moisture transfer rate for stopping longitude (ERA interim)"
  print (avg (moisture_rate_obs_stop_lon_2D_kgpers))

  moisture_rate_ERAinterim_3D_kgpers = (/ moisture_rate_obs_start_lat_2D_kgpers, moisture_rate_obs_stop_lat_2D_kgpers, moisture_rate_obs_start_lon_2D_kgpers, moisture_rate_obs_stop_lon_2D_kgpers /)
  moisture_rate_ERAinterim_3D_kgpers!0 = "boundary"
  moisture_rate_ERAinterim_3D_kgpers!1 = "year"
  moisture_rate_ERAinterim_3D_kgpers!2 = "day"
  moisture_rate_ERAinterim_3D_kgpers&year = year_1D
  moisture_rate_ERAinterim_3D_kgpers&day = day_1D
  moisture_rate_ERAinterim_3D_kgpers@units = "kg/s"
  output_file->moisture_rate_18UTC_ERAinterim_3D_kgpers = moisture_rate_ERAinterim_3D_kgpers

  net_moisture_change_2D_kgpers = moisture_rate_obs_start_lat_2D_kgpers - moisture_rate_obs_stop_lat_2D_kgpers + moisture_rate_obs_start_lon_2D_kgpers - moisture_rate_obs_stop_lon_2D_kgpers
  printVarSummary (net_moisture_change_2D_kgpers)
  printMinMax (net_moisture_change_2D_kgpers, 0)

  net_moisture_change_kgpers = avg (net_moisture_change_2D_kgpers)
  print (net_moisture_change_kgpers)
  output_file->net_moisture_change_18UTC_ERAinterim_kgpers = net_moisture_change_kgpers

  lat_1D_deg_N = (/ start_lat_deg_N, start_lat_deg_N, stop_lat_deg_N, stop_lat_deg_N /)
  lon_1D_deg_E = (/ start_lon_deg_E, stop_lon_deg_E, stop_lon_deg_E, start_lon_deg_E /)
  area_m2 = earth_radius_m * earth_radius_m * gc_qarea (lat_1D_deg_N, lon_1D_deg_E)
;  print (area_m2)

  moisture_rate_obs_start_lat_2D_mmperday = 1000 * moisture_rate_obs_start_lat_2D_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (avg (moisture_rate_obs_start_lat_2D_mmperday))
  moisture_rate_obs_stop_lat_2D_mmperday = 1000 * moisture_rate_obs_stop_lat_2D_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (avg (moisture_rate_obs_stop_lat_2D_mmperday))
  moisture_rate_obs_start_lon_2D_mmperday = 1000 * moisture_rate_obs_start_lon_2D_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (avg (moisture_rate_obs_start_lon_2D_mmperday))
  moisture_rate_obs_stop_lon_2D_mmperday = 1000 * moisture_rate_obs_stop_lon_2D_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (avg (moisture_rate_obs_stop_lon_2D_mmperday))

  moisture_rate_ERAinterim_3D_mmperday = (/ moisture_rate_obs_start_lat_2D_mmperday, moisture_rate_obs_stop_lat_2D_mmperday, moisture_rate_obs_start_lon_2D_mmperday, moisture_rate_obs_stop_lon_2D_mmperday /)
  moisture_rate_ERAinterim_3D_mmperday!0 = "boundary"
  moisture_rate_ERAinterim_3D_mmperday!1 = "year"
  moisture_rate_ERAinterim_3D_mmperday!2 = "day"
  moisture_rate_ERAinterim_3D_mmperday&year = year_1D
  moisture_rate_ERAinterim_3D_mmperday&day = day_1D
  moisture_rate_ERAinterim_3D_mmperday@units = "mm/day"
  output_file->moisture_rate_18UTC_ERAinterim_3D_mmperday = moisture_rate_ERAinterim_3D_mmperday

  net_moisture_change_mmperday = 1000 * net_moisture_change_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (net_moisture_change_mmperday)

  output_file->net_moisture_change_18UTC_ERAinterim_mmperday = net_moisture_change_mmperday

end
