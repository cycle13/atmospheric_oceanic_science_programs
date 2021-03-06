; moisture_balance_CFSv2.ncl

begin

  g_m2pers2 = 9.81
  water_density_kgperm3 = 997.0
  earth_radius_m = 6371000.0

  start_lat_deg_N = 8  ; When changing, also change in output variable names below.
  stop_lat_deg_N = 28
  n_lat = stop_lat_deg_N - start_lat_deg_N + 1
;  lat_1D_deg_N = ispan (start_lat_deg_N, stop_lat_deg_N, 1)

  start_lon_deg_E = 70  ; When changing, also change in output variable names below.
  stop_lon_deg_E = 90
  n_lon = stop_lon_deg_E - start_lon_deg_E + 1
;  lon_1D_deg_E = ispan (start_lon_deg_E, stop_lon_deg_E, 1)

  folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  n_years_model = 17
 
 t_UTC = "12"	; Can be "00" or "06" or "12" or "18". When changing, also change in output variable names below.
  print (t_UTC)
  
  output_file_name = "output_data_moisture_balance_CFSv2_ERAinterim.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")  ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model and ERA interim observations." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  P_levels_1D_Pa = P_levels_1D_hPa * 100
  print (P_levels_1D_Pa)

  n_P = dimsizes (P_levels_1D_Pa)
  print (n_P)

  n_intervals = n_P - 1
  P_intervals_1D_Pa = new (n_intervals, float)
  do x = 0, n_intervals - 1
    P_intervals_1D_Pa (x) = P_levels_1D_Pa (x + 1) - P_levels_1D_Pa (x)
  end do
  print (P_intervals_1D_Pa)

  year_1D = ispan (2009, 2025, 1)
  n_years = dimsizes (year_1D)
  n_months = 4
  n_days = 31
  n_latlon = 21

  SH_int_start_lat_2D = new ((/ n_intervals, n_lon/), float)
  SH_int_stop_lat_2D = new ((/ n_intervals, n_lon/), float)
  SH_int_start_lon_2D = new ((/ n_intervals, n_lat/), float)
  SH_int_stop_lon_2D = new ((/ n_intervals, n_lat/), float)
  V_int_start_lat_2D_mpers = new ((/ n_intervals, n_lon/), float)
  V_int_stop_lat_2D_mpers = new ((/ n_intervals, n_lon/), float)
  U_int_start_lon_2D_mpers = new ((/ n_intervals, n_lat/), float)
  U_int_stop_lon_2D_mpers = new ((/ n_intervals, n_lat/), float)

  V_SH_dP_per_g_start_lat_5D_kgperms = new ((/n_years, n_months, n_days, n_intervals, n_lon/), float)
  V_SH_dP_per_g_stop_lat_5D_kgperms = new ((/n_years, n_months, n_days, n_intervals, n_lon/), float)
  U_SH_dP_per_g_start_lon_5D_kgperms = new ((/n_years, n_months, n_days, n_intervals, n_lat/), float)
  U_SH_dP_per_g_stop_lon_5D_kgperms = new ((/n_years, n_months, n_days, n_intervals, n_lat/), float)

  do i_year = 0, n_years_model - 1
    year = i_year + 2009
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)

        i_month = month - 6
        i_day = day - 1

        ; print (i_month + " " + i_day)
        f_in = folder_path + "y" + year + "/pgbf" + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + t_UTC + ".01.2009020500"
;        print (f_in)

        grib_file = addfile (f_in + ".grb", "r")

	SH_start_lat_2D = grib_file->SPF_H_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
        SH_stop_lat_2D = grib_file->SPF_H_3_ISBL ({P_levels_1D_hPa}, {stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
        SH_start_lon_2D = grib_file->SPF_H_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E})
        SH_stop_lon_2D = grib_file->SPF_H_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {stop_lon_deg_E})

        V_start_lat_2D_mpers = grib_file->V_GRD_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
        V_stop_lat_2D_mpers = grib_file->V_GRD_3_ISBL ({P_levels_1D_hPa}, {stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
        U_start_lon_2D_mpers = grib_file->U_GRD_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E})
        U_stop_lon_2D_mpers = grib_file->U_GRD_3_ISBL ({P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {stop_lon_deg_E})

do i_interval = 0, n_intervals - 1
    SH_int_start_lat_2D (i_interval, :) = (SH_start_lat_2D (i_interval, :) + SH_start_lat_2D (i_interval + 1, :)) / 2
    SH_int_stop_lat_2D (i_interval, :) = (SH_stop_lat_2D (i_interval, :) + SH_stop_lat_2D (i_interval + 1, :)) / 2
    SH_int_start_lon_2D (i_interval, :) = (SH_start_lon_2D (i_interval, :) + SH_start_lon_2D (i_interval + 1, :)) / 2
    SH_int_stop_lon_2D (i_interval, :) = (SH_stop_lon_2D (i_interval, :) + SH_stop_lon_2D (i_interval + 1, :)) / 2
    V_int_start_lat_2D_mpers (i_interval, :) = (V_start_lat_2D_mpers (i_interval, :) + V_start_lat_2D_mpers (i_interval + 1, :)) / 2
    V_int_stop_lat_2D_mpers (i_interval, :) = (V_stop_lat_2D_mpers (i_interval, :) + V_stop_lat_2D_mpers (i_interval + 1, :)) / 2
    U_int_start_lon_2D_mpers (i_interval, :) = (U_start_lon_2D_mpers (i_interval, :) + U_start_lon_2D_mpers (i_interval + 1, :)) / 2
    U_int_stop_lon_2D_mpers (i_interval, :) = (U_stop_lon_2D_mpers (i_interval, :) + U_stop_lon_2D_mpers (i_interval + 1, :)) / 2

        do i_latlon = 0, n_latlon - 1
	  V_SH_dP_per_g_start_lat_5D_kgperms (i_year, i_month, i_day, i_interval, i_latlon) = V_int_start_lat_2D_mpers (i_interval, i_latlon) * SH_int_start_lat_2D (i_interval, i_latlon) * P_intervals_1D_Pa (i_interval) / g_m2pers2
	  V_SH_dP_per_g_stop_lat_5D_kgperms (i_year, i_month, i_day, i_interval, i_latlon) = V_int_stop_lat_2D_mpers (i_interval, i_latlon) * SH_int_stop_lat_2D (i_interval, i_latlon) * P_intervals_1D_Pa (i_interval) / g_m2pers2
	  U_SH_dP_per_g_start_lon_5D_kgperms (i_year, i_month, i_day, i_interval, i_latlon) = U_int_start_lon_2D_mpers (i_interval, i_latlon) * SH_int_start_lon_2D (i_interval, i_latlon) * P_intervals_1D_Pa (i_interval) / g_m2pers2
	  U_SH_dP_per_g_stop_lon_5D_kgperms (i_year, i_month, i_day, i_interval, i_latlon) = U_int_stop_lon_2D_mpers (i_interval, i_latlon) * SH_int_stop_lon_2D (i_interval, i_latlon) * P_intervals_1D_Pa (i_interval) / g_m2pers2
        end do
      end do

      delete (grib_file)

      end do
    end do
  end do

  printVarSummary (V_SH_dP_per_g_start_lat_5D_kgperms)
;  output_file->V_SH_dP_per_g_obs_start_lat_06UTC_4D_kgperms = V_SH_dP_per_g_obs_start_lat_4D_kgperms
  printVarSummary (V_SH_dP_per_g_stop_lat_5D_kgperms)
;  output_file->V_SH_dP_per_g_obs_stop_lat_06UTC_4D_kgperms = V_SH_dP_per_g_obs_stop_lat_4D_kgperms
  printVarSummary (U_SH_dP_per_g_start_lon_5D_kgperms)
;  output_file->U_SH_dP_per_g_obs_start_lon_06UTC_4D_kgperms = U_SH_dP_per_g_obs_start_lon_4D_kgperms
  printVarSummary (U_SH_dP_per_g_stop_lon_5D_kgperms)
;  output_file->U_SH_dP_per_g_obs_stop_lon_06UTC_4D_kgperms = U_SH_dP_per_g_obs_stop_lon_4D_kgperms

  integral_start_lat_4D_kgperms = dim_sum_n_Wrap (V_SH_dP_per_g_start_lat_5D_kgperms, 3)
  integral_stop_lat_4D_kgperms = dim_sum_n_Wrap (V_SH_dP_per_g_stop_lat_5D_kgperms, 3)
  integral_start_lon_4D_kgperms = dim_sum_n_Wrap (U_SH_dP_per_g_start_lon_5D_kgperms, 3)
  integral_stop_lon_4D_kgperms = dim_sum_n_Wrap (U_SH_dP_per_g_stop_lon_5D_kgperms, 3)

  integral_start_lat_interval_4D_kgperms = new ((/n_years, n_months, n_days, n_lon - 1/), float)
  integral_stop_lat_interval_4D_kgperms = new ((/n_years, n_months, n_days, n_lon - 1/), float)
  integral_start_lon_interval_4D_kgperms = new ((/n_years, n_months, n_days, n_lat - 1/), float)
  integral_stop_lon_interval_4D_kgperms = new ((/n_years, n_months, n_days, n_lat - 1/), float)

  do i_latlon = 0, n_latlon - 2
    integral_start_lat_interval_4D_kgperms (:, :, :, i_latlon) = (integral_start_lat_4D_kgperms (:, :, :, i_latlon) + integral_start_lat_4D_kgperms (:, :, :, i_latlon + 1)) / 2
    integral_stop_lat_interval_4D_kgperms (:, :, :, i_latlon) = (integral_stop_lat_4D_kgperms (:, :, :, i_latlon) + integral_stop_lat_4D_kgperms (:, :, :, i_latlon + 1)) / 2
    integral_start_lon_interval_4D_kgperms (:, :, :, i_latlon) = (integral_start_lon_4D_kgperms (:, :, :, i_latlon) + integral_start_lon_4D_kgperms (:, :, :, i_latlon + 1)) / 2
    integral_stop_lon_interval_4D_kgperms (:, :, :, i_latlon) = (integral_stop_lon_4D_kgperms (:, :, :, i_latlon) + integral_stop_lon_4D_kgperms (:, :, :, i_latlon + 1)) / 2
  end do

  moisture_rate_start_lat_4D_kgpers = integral_start_lat_interval_4D_kgperms * gc_latlon (start_lat_deg_N, 80, start_lat_deg_N, 81, 2, -3)
  moisture_rate_stop_lat_4D_kgpers = integral_stop_lat_interval_4D_kgperms * gc_latlon (stop_lat_deg_N, 80, stop_lat_deg_N, 81, 2, -3)
  moisture_rate_start_lon_4D_kgpers = integral_start_lon_interval_4D_kgperms * gc_latlon (15, start_lon_deg_E, 16, start_lon_deg_E, 2, -3)
  moisture_rate_stop_lon_4D_kgpers = integral_stop_lon_interval_4D_kgperms * gc_latlon (15, stop_lon_deg_E, 16, stop_lon_deg_E, 2, -3)

  moisture_rate_start_lat_3D_kgpers = dim_sum_n_Wrap (moisture_rate_start_lat_4D_kgpers, 3)
  moisture_rate_stop_lat_3D_kgpers = dim_sum_n_Wrap (moisture_rate_stop_lat_4D_kgpers, 3)
  moisture_rate_start_lon_3D_kgpers = dim_sum_n_Wrap (moisture_rate_start_lon_4D_kgpers, 3)
  moisture_rate_stop_lon_3D_kgpers = dim_sum_n_Wrap (moisture_rate_stop_lon_4D_kgpers, 3)

  net_moisture_change_3D_kgpers = moisture_rate_start_lat_3D_kgpers - moisture_rate_stop_lat_3D_kgpers + moisture_rate_start_lon_3D_kgpers - moisture_rate_stop_lon_3D_kgpers
  printVarSummary (net_moisture_change_3D_kgpers)
  printMinMax (net_moisture_change_3D_kgpers, 0)

  net_moisture_change_kgpers = avg (net_moisture_change_3D_kgpers)
  print (net_moisture_change_kgpers)
  output_file->net_moisture_change_CFSv2_12UTC_kgpers = net_moisture_change_kgpers

  lat_1D_deg_N = (/ start_lat_deg_N, start_lat_deg_N, stop_lat_deg_N, stop_lat_deg_N /)
  lon_1D_deg_E = (/ start_lon_deg_E, stop_lon_deg_E, stop_lon_deg_E, start_lon_deg_E /)
  area_m2 = earth_radius_m * earth_radius_m * gc_qarea (lat_1D_deg_N, lon_1D_deg_E) ; Calculating area.
;  print (area_m2)

  net_moisture_change_mmperday = 1000 * net_moisture_change_kgpers * (60 * 60 * 24) / (water_density_kgperm3 * area_m2)
  print (net_moisture_change_mmperday)

  output_file->net_moisture_change_CFSv2_12UTC_mmperday = net_moisture_change_mmperday

end
