; CAPE_high_diff_model_obs_T_vs_h_least_squares_fit.ncl

begin

  start_lat_deg_N = 31	; When changing, also change in output variable names below.
  stop_lat_deg_N = 34
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 70	; When changing, also change in output variable names below.
  stop_lon_deg_E = 72
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
  longitudes_1D_degE@units = "degrees east"

  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  P_levels_1D_hPa!0 = "pressure"
  P_levels_1D_hPa&pressure = P_levels_1D_hPa
  P_levels_1D_hPa@units = "hPa"
  P_levels_1D_hPa@long_name = "Pressure levels"
  n_P = dimsizes (P_levels_1D_hPa)

  t_UTC = "18"	; Can be "00" or "06" or "12" or "18".
                ; When changing, also change in output variable names below.
  print (t_UTC)

  output_file_name = "output_data_T_vs_h_high_diff_CAPE_model_obs.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")    ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model and ERA interim observations." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

; -------------- observation (ERA interim) input ---------------

  obs_T_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/temperature/temperature_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  obs_T_input_files = addfiles (obs_T_files_list, "r")
  ListSetType (obs_T_input_files, "join")
  T_obs_5D_K = obs_T_input_files[:]->T_GDS0_ISBL (:, :, {P_levels_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (T_obs_5D_K)
  printMinMax (T_obs_5D_K, 0)

  avg_T_obs_3D_K = dim_avg_n_Wrap (T_obs_5D_K, (/ 0, 1 /))
  printVarSummary (avg_T_obs_3D_K)
  printMinMax (avg_T_obs_3D_K, 0)
  avg_T_obs_1D_K = dim_avg_n_Wrap (avg_T_obs_3D_K, (/ 1, 2 /))
  printVarSummary (avg_T_obs_1D_K)
  printMinMax (avg_T_obs_1D_K, 0)

  obs_SP_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept????_40N40E10S100E.grib2")
  obs_SP_input_files = addfiles (obs_SP_files_list, "r")
  ListSetType (obs_SP_input_files, "join")
  SP_obs_4D_Pa = obs_SP_input_files[:]->SP_GDS0_SFC (:, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SP_obs_4D_Pa)
  printMinMax (SP_obs_4D_Pa, 0)

  avg_SP_obs_Pa = avg (SP_obs_4D_Pa)
  avg_SP_obs_Pa@units = "Pa"
  print (avg_SP_obs_Pa)

  obs_GP_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/geopotential_4D/geopotential_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  obs_GP_input_files = addfiles (obs_GP_files_list, "r")
  ListSetType (obs_GP_input_files, "join")
  GP_obs_5D_m2pers2 = obs_GP_input_files[:]->Z_GDS0_ISBL (:, :, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (GP_obs_5D_m2pers2)
  printMinMax (GP_obs_5D_m2pers2, 0)

  avg_GP_obs_3D_m2pers2 = dim_avg_n_Wrap (GP_obs_5D_m2pers2, (/ 3, 4 /))
  avg_GP_obs_1D_m2pers2 = dim_avg_n_Wrap (avg_GP_obs_3D_m2pers2, (/ 0, 1 /))
  avg_GPH_obs_1D_gpm = avg_GP_obs_1D_m2pers2 / 9.80665
  avg_GPH_obs_1D_gpm!0 = avg_GP_obs_1D_m2pers2!0
  avg_GPH_obs_1D_gpm&lv_ISBL1 = avg_GP_obs_1D_m2pers2&lv_ISBL1
  avg_GPH_obs_1D_gpm@units = "geopotential meter (gpm)"
  avg_GPH_obs_1D_gpm@long_name = "Average geopotential height, from ERA interim"
  printVarSummary (avg_GPH_obs_1D_gpm)
  printMinMax (avg_GPH_obs_1D_gpm, 0)

  delete (obs_T_input_files)
  delete (obs_SP_input_files)
  delete (obs_GP_input_files)

; ------------------ model (CFS v2) input -------------------

  folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  n_years = 17

  T_model_6D_K = new ((/ n_years, 4, 31, n_P, n_latitudes, n_longitudes /), float)
  SP_model_5D_Pa = new ((/ n_years, 4, 31, n_latitudes, n_longitudes /), float)
  GPH_model_6D_gpm = new ((/ n_years, 4, 31, n_P, n_latitudes, n_longitudes /), float)

  do i_year = 0, n_years - 1
    year = i_year + 2009
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)
        ; print (i_month + " " + i_day)
        f_in = folder_path + "y" + year + "/pgbf" + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + t_UTC + ".01.2009020500"
;        print (f_in)

        model_input_file = addfile (f_in + ".grb", "r")

        i_month = month - 6
	i_day = day - 1

        T_model_6D_K (i_year, i_month, i_day, :, :, :) = model_input_file->TMP_3_ISBL ({P_levels_1D_hPa}, {latitudes_1D_degN}, {longitudes_1D_degE})

	SP_model_5D_Pa (i_year, i_month, i_day, :, :) = model_input_file->PRES_3_SFC ({latitudes_1D_degN}, {longitudes_1D_degE})

	GPH_model_6D_gpm (i_year, i_month, i_day, :, :, :)  = model_input_file->HGT_3_ISBL ({P_levels_1D_hPa}, {latitudes_1D_degN}, {longitudes_1D_degE})

        delete (model_input_file)

      end do
    end do
  end do

  avg_T_model_3D_K = dim_avg_n_Wrap (T_model_6D_K, (/ 0, 1, 2 /))
;  printVarSummary (avg_T_model_3D_K)
;  printMinMax (avg_T_model_3D_K, 0)
  avg_T_model_1D_K = dim_avg_n_Wrap (avg_T_model_3D_K, (/ 1, 2 /))
  printVarSummary (avg_T_model_1D_K)
  printMinMax (avg_T_model_1D_K, 0)

  avg_SP_model_Pa = avg (SP_model_5D_Pa)
  avg_SP_model_Pa@units = "Pa"
  print (avg_SP_model_Pa)

  avg_GPH_model_3D_gpm = dim_avg_n_Wrap (GPH_model_6D_gpm, (/ 0, 1, 2 /))
  avg_GPH_model_1D_gpm = dim_avg_n_Wrap (avg_GPH_model_3D_gpm, (/1, 2 /))
  printVarSummary (avg_GPH_model_1D_gpm)
  printMinMax (avg_GPH_model_1D_gpm, 0)

; ----------- Saving data to variables in output file. -----------

  output_file->avg_T_CFS_v2_18UTC_31to34N_70to72E_1D_K = avg_T_model_1D_K
;  avg_T_CFS_v2_24to28N_50to55E_1D_K!0 = avg_T_model_1D_K!0
;  avg_T_CFS_v2_24to28N_50to55E_1D_K&lv_ISBL4 = avg_T_model_1D_K&lv_ISBL4
;  avg_T_CFS_v2_24to28N_50to55E_1D_K@units = avg_T_model_1D_K@units

  output_file->avg_T_ERA_int_18UTC_31to34N_70to72E_1D_K = avg_T_obs_1D_K
;  avg_T_ERA_int_24to28N_50to55E_1D_K!0 = avg_T_obs_1D_K!0
;  avg_T_ERA_int_24to28N_50to55E_1D_K&lv_ISBL1 = avg_T_obs_1D_K&lv_ISBL1
;  avg_T_ERA_int_24to28N_50to55E_1D_K@units = avg_T_obs_1D_K@units

  output_file->avg_SP_CFS_v2_18UTC_31to34N_70to72E_Pa = avg_SP_model_Pa
  output_file->avg_SP_ERA_int_18UTC_31to34N_70to72E_Pa = avg_SP_obs_Pa

  output_file->avg_GPH_CFS_v2_18UTC_31to34N_70to72E_gpm = avg_GPH_model_1D_gpm

  output_file->avg_GPH_ERA_int_18UTC_31to34N_70to72E_gpm = avg_GPH_obs_1D_gpm

  avg_SP_model_hPa = avg_SP_model_Pa / 100
  avg_SP_model_hPa@units = "hPa"

  avg_SP_obs_hPa = avg_SP_obs_Pa / 100
  avg_SP_obs_hPa@units = "hPa"

;  avg_T_diff_1D_K = avg_T_model_1D_K - avg_T_obs_1D_K

; --- Best fit straight line by minimizing sum of squares of errors. --

  P_plot_1D_hPa = P_levels_1D_hPa ({100 : 1000})
  n_plot = dimsizes (P_plot_1D_hPa)
;  P_squared_1D_hPa2 = P_plot_1D_hPa * P_plot_1D_hPa
;  sum_P_squared_hPa2 = sum (P_squared_1D_hPa2)
;  sum_P_hPa = sum (P_plot_1D_hPa)

; observation least squares fit

  GPH_obs_plot_1D_gpm = avg_GPH_obs_1D_gpm ({100 : 1000})
;  n_plot = dimsizes (GPH_obs_plot_1D_gpm)
  GPH_obs_squared_1D_gpm2 = GPH_obs_plot_1D_gpm * GPH_obs_plot_1D_gpm
  sum_GPH_obs_squared_gpm2 = sum (GPH_obs_squared_1D_gpm2)
  sum_GPH_obs_gpm = sum (GPH_obs_plot_1D_gpm)

  T_plot_obs_1D_K = avg_T_obs_1D_K ({100 : 1000})
  T_GPH_obs_1D_Kgpm = T_plot_obs_1D_K * GPH_obs_plot_1D_gpm
  sum_T_obs_K = sum (T_plot_obs_1D_K)
  sum_T_GPH_obs_Kgpm = sum (T_GPH_obs_1D_Kgpm)

  intercept_obs_K = ((sum_GPH_obs_squared_gpm2 * sum_T_obs_K) - (sum_GPH_obs_gpm * sum_T_GPH_obs_Kgpm )) / ((n_plot * sum_GPH_obs_squared_gpm2) - (sum_GPH_obs_gpm * sum_GPH_obs_gpm))
  intercept_obs_K@units = "K"
  print (intercept_obs_K)

  slope_obs_Kpergpm = ((n_plot * sum_T_GPH_obs_Kgpm) - (sum_GPH_obs_gpm * sum_T_obs_K)) / ((n_plot * sum_GPH_obs_squared_gpm2) - (sum_GPH_obs_gpm * sum_GPH_obs_gpm))
  slope_obs_Kpergpm@units = "K/gpm"
  print (slope_obs_Kpergpm)

  T_line_o_1D_K = intercept_obs_K + (slope_obs_Kpergpm * GPH_obs_plot_1D_gpm)
  print (T_line_o_1D_K)

; model least squares fit

  GPH_model_plot_1D_gpm = avg_GPH_model_1D_gpm ({100 : 1000})
;  n_plot_model = dimsizes (GPH_model_plot_1D_gpm)
  GPH_model_squared_1D_gpm2 = GPH_model_plot_1D_gpm * GPH_model_plot_1D_gpm
  sum_GPH_model_squared_gpm2 = sum (GPH_model_squared_1D_gpm2)
  sum_GPH_model_gpm = sum (GPH_model_plot_1D_gpm)

  T_plot_model_1D_K = avg_T_model_1D_K ({100 : 1000})
  T_GPH_model_1D_Kgpm = T_plot_model_1D_K * GPH_model_plot_1D_gpm
  sum_T_model_K = sum (T_plot_model_1D_K)
  sum_T_GPH_model_Kgpm = sum (T_GPH_model_1D_Kgpm)
  
  intercept_model_K = ((sum_GPH_model_squared_gpm2 * sum_T_model_K) - (sum_GPH_model_gpm * sum_T_GPH_model_Kgpm )) / ((n_plot * sum_GPH_model_squared_gpm2) - (sum_GPH_model_gpm * sum_GPH_model_gpm))
  intercept_model_K@units = "K"
  print (intercept_model_K)
  
  slope_model_Kpergpm = ((n_plot * sum_T_GPH_model_Kgpm) - (sum_GPH_model_gpm * sum_T_model_K)) / ((n_plot * sum_GPH_model_squared_gpm2) - (sum_GPH_model_gpm * sum_GPH_model_gpm))
  slope_model_Kpergpm@units = "K/gpm"
  print (slope_model_Kpergpm)

  T_line_m_1D_K = intercept_model_K + (slope_model_Kpergpm * GPH_model_plot_1D_gpm)
  print (T_line_m_1D_K)

; ----------- Plotting T vs GPH for model and observation. -----------
  
  T_all_2D_K = new ((/ 4, n_plot /), float)
  T_all_2D_K (0, :) = (/ T_plot_model_1D_K /)
  T_all_2D_K (1, :) = (/ T_plot_obs_1D_K /)
  T_all_2D_K (2, :) = (/ T_line_m_1D_K /)
  T_all_2D_K (3, :) = (/ T_line_o_1D_K /)
  printVarSummary (T_all_2D_K)
  printMinMax (T_all_2D_K, 0)

  GPH_all_2D_gpm = new ((/ 4, n_plot /), float)
  GPH_all_2D_gpm (0, :) = (/ GPH_model_plot_1D_gpm /)
  GPH_all_2D_gpm (1, :) = (/ GPH_obs_plot_1D_gpm /)
  GPH_all_2D_gpm (2, :) = (/ GPH_model_plot_1D_gpm /)
  GPH_all_2D_gpm (3, :) = (/ GPH_obs_plot_1D_gpm /)
  printVarSummary (GPH_all_2D_gpm)
  printMinMax (GPH_all_2D_gpm, 0)

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_1 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_T_vs_p_level_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS_least_squares_fit") ; Open a workstation.

;  wks_2 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/diff_avg_T_vs_p_level_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS") ; Open a workstation.

  res1 = True
;  res1@trYReverse = True
  res1@xyLineColors = (/ "red", "green", "orange", "blue" /)
  res1@tiXAxisString = "Average temperature (K)"
;  res1@tiYAxisString = "Isobaric level (hPa)"
  res1@tiYAxisString = "Geopotential height (gpm)"
  res1@xyMonoLineThickness = True
  res1@xyLineThicknessF = 5
  res1@gsnYRefLine = (/ avg_SP_model_hPa, avg_SP_obs_hPa /)
  res1@gsnYRefLineColors = (/ "purple", "purple" /)
  res1@gsnYRefLineThicknesses = (/ 5, 5 /)

;  res2 = True
;  res2@trYReverse = True
;  res2@xyLineColors        = (/ "blue" /)
;  res2@tiXAxisString = "Temperature difference (K)"
;  res2@tiYAxisString = "Isobaric level (hPa)"
;  res2@gsnYRefLine = (/ avg_SP_model_hPa, avg_SP_obs_hPa /)
;  res2@gsnYRefLineColors = (/ "purple", "purple" /)
;  res2@gsnYRefLineThicknesses = (/ 5, 5 /)

  plot_1 = gsn_csm_xy (wks_1, T_all_2D_K, GPH_all_2D_gpm, res1)
;  plot_2 = gsn_csm_xy (wks_2, avg_T_diff_1D_K, P_levels_1D_hPa, res2)

  gres = True
  gres@YPosPercent = 90.    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 5      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres1 = True
  lineres1@lgLineColors = (/ "red", "green", "orange", "blue" /) ;, "sienna", "purple" /) ; line colors
  lineres1@lgLineThicknesses = 5                        ; line thicknesses
  lineres1@lgLineLengthPercent = 5                         ; expressed as %, 0->100, length of line

  textres1 = True
  textres1@lgLabels = (/ "Average temperature: model (CFS v2)", "Average temperature: observation (ERA int)", "Model T: best fit straight line", "Observation T: best fit straight line" /) ;, "Average model surface pressure", "Average observation surface pressure" /)  ; legend labels (required)


  plot_1 = simple_legend (wks_1, plot_1, gres, lineres1, textres1)
  draw (plot_1)
  frame (wks_1)

;  lineres2 = True
;  lineres2@lgLineColors = (/ "black", "purple" /) ; line colors
;  lineres2@lgLineThicknesses = 5                        ; line thicknesses
;  lineres2@lgLineLengthPercent = 5                     ; expressed as %, 0->100, length of line

;  textres2 = True
;  textres2@lgLabels = (/ "Average temperature difference: CFS v2 - ERA interim", "Average surface pressure" /)  ; legend labels (required)

;  plot_2 = simple_legend (wks_2, plot_2, gres2, lineres2, textres2)
;  draw (plot_2)
;  frame (wks_2)

end
