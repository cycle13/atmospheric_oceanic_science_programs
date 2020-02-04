; CAPE_high_diff_model_obs_T_vs_h_least_squares_fit_post-processing.ncl

begin

  start_lat_deg_N = 31 ; When changing, also change in output variable names below.
  stop_lat_deg_N = 34

  start_lon_deg_E = 70 ; When changing, also change in output variable names below.
  stop_lon_deg_E = 72

  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  P_levels_1D_hPa!0 = "pressure"
  P_levels_1D_hPa&pressure = P_levels_1D_hPa
  P_levels_1D_hPa@units = "hPa"
  P_levels_1D_hPa@long_name = "Pressure levels"
;  n_P = dimsizes (P_levels_1D_hPa)

  t_UTC = "00"  ; Can be "00" or "06" or "12" or "18".
                ; When changing, also change in input variable names below.
  print (t_UTC)

; ------------- Data input. ----------------

  input_file_name = "output_data_T_vs_h_high_diff_CAPE_model_obs.nc"
;  system ("/bin/rm -f " + cdf_filename)
  input_file = addfile ("/Vol2/sarthak/output_data/" + input_file_name, "r")    ; Write to netCDF file.

  avg_T_model_1D_K = input_file->avg_T_CFS_v2_00UTC_31to34N_70to72E_1D_K
  print (avg_T_model_1D_K)

  avg_T_obs_1D_K = input_file->avg_T_ERA_int_00UTC_31to34N_70to72E_1D_K
  print (avg_T_obs_1D_K)

;  avg_SP_model_hPa = input_file->avg_SP_CFS_v2_00UTC_31to34N_70to72E_Pa / 100
;  print (avg_SP_model_hPa)

;  avg_SP_obs_hPa = input_file->avg_SP_ERA_int_00UTC_31to34N_70to72E_Pa / 100
;  print (avg_SP_obs_hPa)

  avg_GPH_model_1D_gpm = input_file->avg_GPH_CFS_v2_00UTC_31to34N_70to72E_gpm
  print (avg_GPH_model_1D_gpm)

  avg_GPH_obs_1D_gpm = input_file->avg_GPH_ERA_int_00UTC_31to34N_70to72E_gpm
  print (avg_GPH_obs_1D_gpm)

;  avg_SP_model_hPa = avg_SP_model_Pa / 100
;  avg_SP_model_hPa@units = "hPa"
;  print (avg_SP_model_hPa)

;  avg_SP_obs_hPa = avg_SP_obs_Pa / 100
;  avg_SP_obs_hPa@units = "hPa"
;  print (avg_SP_obs_hPa)

; --- Finding best fit straight line by minimizing sum of squares of errors. ---

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

;  T_plot_model_1D_K = avg_T_model_1D_K ({100 : 1000})
;  T_model_P_1D_KhPa = T_plot_model_1D_K * P_plot_1D_hPa
;  sum_T_model_K = sum (T_plot_model_1D_K)
;  sum_T_model_P_KhPa = sum (T_model_P_1D_KhPa)

  intercept_model_K = ((sum_GPH_model_squared_gpm2 * sum_T_model_K) - (sum_GPH_model_gpm * sum_T_GPH_model_Kgpm )) / ((n_plot * sum_GPH_model_squared_gpm2) - (sum_GPH_model_gpm * sum_GPH_model_gpm))
  intercept_model_K@units = "K"
  print (intercept_model_K)

;  intercept_model_K = ((sum_P_squared_hPa2 * sum_T_model_K) - (sum_P_hPa * sum_T_model_P_KhPa )) / ((n_plot * sum_P_squared_hPa2) - (sum_P_hPa * sum_P_hPa))
;  print (intercept_model_K)

  slope_model_Kpergpm = ((n_plot * sum_T_GPH_model_Kgpm) - (sum_GPH_model_gpm * sum_T_model_K)) / ((n_plot * sum_GPH_model_squared_gpm2) - (sum_GPH_model_gpm * sum_GPH_model_gpm))
  slope_model_Kpergpm@units = "K/gpm"
  print (slope_model_Kpergpm)

;  slope_model_KperhPa = ((n_plot * sum_T_model_P_KhPa) - (sum_P_hPa * sum_T_model_K)) / ((n_plot * sum_P_squared_hPa2) - (sum_P_hPa * sum_P_hPa))
;  print (slope_model_KperhPa)

  T_line_m_1D_K = intercept_model_K + (slope_model_Kpergpm * GPH_model_plot_1D_gpm)
  print (T_line_m_1D_K)

;  T_line_m_1D_K = intercept_model_K + (slope_model_KperhPa * P_plot_1D_hPa)

; -------- Plotting T vs. z, for model and observation. ---------

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  gres = True
  gres@YPosPercent = 10 ; expressed as %, 0->100, sets position of top border of legend
                        ; when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 1; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

; --------------- first plot ----------------

  T_first_2D_K = new ((/ 2, n_plot /), float)
  T_first_2D_K (0, :) = (/ T_plot_model_1D_K /)
;  T_first_2D_K (1, :) = (/ T_plot_obs_1D_K /)
  T_first_2D_K (1, :) = (/ T_line_m_1D_K /)
;  T_first_2D_K (3, :) = (/ T_line_o_1D_K /)
  printVarSummary (T_first_2D_K)
  printMinMax (T_first_2D_K, 0)

  GPH_first_2D_gpm = new ((/ 2, n_plot /), float)
  GPH_first_2D_gpm (0, :) = (/ GPH_model_plot_1D_gpm /)
;  GPH_first_2D_gpm (1, :) = (/ GPH_obs_plot_1D_gpm /)
  GPH_first_2D_gpm (1, :) = (/ GPH_model_plot_1D_gpm /)
;  GPH_first_2D_gpm (3, :) = (/ GPH_obs_plot_1D_gpm /)
  printVarSummary (GPH_first_2D_gpm)
  printMinMax (GPH_first_2D_gpm, 0)

  wks_1 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/T_vs_h_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS_CFSv2_100-1000hPa_actual_BFSL") ; Open a workstation.

  res1 = True
;  res1@trYReverse = True
  res1@xyLineColors = (/ "red", "orange" /) ;, "blue", "green" /)
  res1@tiXAxisString = "Average temperature (K)"
;  res1@tiYAxisString = "Isobaric level (hPa)"
  res1@tiYAxisString = "Height (m)"
  res1@xyMonoLineThickness = True
  res1@xyLineThicknessF = 10
;  res1@gsnYRefLine = (/avg_SP_model_hPa, avg_SP_obs_hPa/)
;  res1@gsnYRefLineColors = (/ "sienna", "purple" /)
;  res1@gsnYRefLineThicknesses = (/ 5, 5 /)

  plot_1 = gsn_csm_xy (wks_1, T_first_2D_K, GPH_first_2D_gpm, res1)

  lineres1 = True
  lineres1@lgLineColors = (/ "red","orange" /) ;, "blue", "green", "sienna", "purple" /) ; line colors
  lineres1@lgLineThicknesses = 10   ; line thicknesses
  lineres1@lgLineLengthPercent = 5 ; expressed as %, 0->100, length of line

  textres1 = True
  textres1@lgLabels = (/ "Model (CFS v2): actual", "Model (CFS v2): best fit straight line" /) ;, "Average model surface pressure", "Average observation surface pressure" /)  ; legend labels (required)

  plot_1 = simple_legend (wks_1, plot_1, gres, lineres1, textres1)
  draw (plot_1)
  frame (wks_1)

; --------------- second plot ----------------

  T_second_2D_K = new ((/ 2, n_plot /), float)
;  T_second_2D_K (0, :) = (/ T_plot_model_1D_K /)
  T_second_2D_K (0, :) = (/ T_plot_obs_1D_K /)
;  T_second_2D_K (0, :) = (/ T_line_m_1D_K /)
  T_second_2D_K (1, :) = (/ T_line_o_1D_K /)
  printVarSummary (T_second_2D_K)
  printMinMax (T_second_2D_K, 0)

  GPH_second_2D_gpm = new ((/ 2, n_plot /), float)
;  GPH_second_2D_gpm (0, :) = (/ GPH_model_plot_1D_gpm /)
  GPH_second_2D_gpm (0, :) = (/ GPH_obs_plot_1D_gpm /)
;  GPH_second_2D_gpm (2, :) = (/ GPH_model_plot_1D_gpm /)
  GPH_second_2D_gpm (1, :) = (/ GPH_obs_plot_1D_gpm /)
;  printVarSummary (GPH_second_2D_gpm)
;  printMinMax (GPH_second_2D_gpm, 0)

  wks_2 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/T_vs_h_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS_ERAinterim_100-1000hPa_actual_BFSL") ; Open a workstation.

  res2 = True
;  res1@trYReverse = True
  res2@xyLineColors = (/ "green", "blue" /) ; "red", "orange"
  res2@tiXAxisString = "Temperature (K)"
;  res1@tiYAxisString = "Isobaric level (hPa)"
  res2@tiYAxisString = "Height (m)"
  res2@xyMonoLineThickness = True
  res2@xyLineThicknessF = 10
;  res1@gsnYRefLine = (/avg_SP_model_hPa, avg_SP_obs_hPa/)
;  res1@gsnYRefLineColors = (/ "sienna", "purple" /)
;  res1@gsnYRefLineThicknesses = (/ 5, 5 /)

  plot_2 = gsn_csm_xy (wks_2, T_second_2D_K, GPH_second_2D_gpm, res2)

  lineres2 = True
  lineres2@lgLineColors = (/ "green", "blue" /) ;, "red", "orange" /) ; line colors
  lineres2@lgLineThicknesses = 10   ; line thicknesses
  lineres2@lgLineLengthPercent = 5 ; expressed as %, 0->100, length of line

  textres2 = True
  textres2@lgLabels = (/ "Observation (ERA interim): actual", "Observation (ERA interim): best fit straight line" /) ;, "Average model surface pressure", "Average observation surface pressure" /)  ; legend labels (required)

  plot_2 = simple_legend (wks_2, plot_2, gres, lineres2, textres2)
  draw (plot_2)
  frame (wks_2)

; ----------------------------------------------

  delete (input_file)

end
