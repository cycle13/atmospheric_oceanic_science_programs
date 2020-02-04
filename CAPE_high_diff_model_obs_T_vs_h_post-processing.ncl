; CAPE_high_diff_model_obs_T_vs_h_post-processing.ncl

begin

  start_lat_deg_N = 24  ; When changing, also change in input variable names below.
  stop_lat_deg_N = 28

  start_lon_deg_E = 50	; When changing, also change in input variable names below.
  stop_lon_deg_E = 55

  P_levels_1D_hPa = (/ 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  n_P = dimsizes (P_levels_1D_hPa)

  t_UTC = "18"	; Can be "00" or "06" or "12" or "18".
                ; When changing, also change in input variable names below.

  input_file = addfile ("/Vol2/sarthak/output_data/output_data_T_vs_h_high_diff_CAPE_model_obs.nc", "r")

  avg_T_model_1D_K = input_file->avg_T_CFS_v2_18UTC_24to28N_50to55E_1D_K ({P_levels_1D_hPa})
  printVarSummary (avg_T_model_1D_K)
  printMinMax (avg_T_model_1D_K, 0)

  avg_T_obs_1D_K = input_file->avg_T_ERA_int_18UTC_24to28N_50to55E_1D_K ({P_levels_1D_hPa})
  printVarSummary (avg_T_obs_1D_K)
  printMinMax (avg_T_obs_1D_K, 0)

  avg_SP_model_hPa = input_file->avg_SP_CFS_v2_18UTC_24to28N_50to55E_Pa/100
  avg_SP_model_hPa@units = "hPa"
  print (avg_SP_model_hPa)
  
  avg_SP_obs_hPa = input_file->avg_SP_ERA_int_18UTC_24to28N_50to55E_Pa/100
  avg_SP_obs_hPa@units = "hPa"
  print (avg_SP_obs_hPa)

  delete (input_file)

  T_all_2D_K = new ((/ 2, n_P /), float)
  T_all_2D_K (0, :) = (/ avg_T_model_1D_K /)
  T_all_2D_K (1, :) = (/ avg_T_obs_1D_K /)
  printVarSummary (T_all_2D_K)
  printMinMax (T_all_2D_K, 0)

  avg_T_diff_1D_K = avg_T_model_1D_K - avg_T_obs_1D_K

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_1 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_T_vs_p_level_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS_model_obs") ; Open a workstation.


  wks_2 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/diff_avg_T_vs_p_level_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS_model_obs") ; Open a workstation.

  res1 = True
  res1@trYReverse = True
  res1@xyLineColors        = (/ "red", "green" /)
  res1@tiXAxisString = "Average temperature (K)"
  res1@tiYAxisString = "Isobaric level (hPa)"
  res1@xyMonoLineThickness = True
  res1@xyLineThicknessF = 5
  res1@gsnYRefLine = (/ avg_SP_model_hPa, avg_SP_obs_hPa /)
  res1@gsnYRefLineColors = (/ "sienna", "purple" /)
  res1@gsnYRefLineThicknesses = (/ 5, 5 /)

  res2 = True
  res2@trYReverse = True
  res2@xyLineColors        = (/ "black" /)
  res2@tiXAxisString = "Average temperature difference (model - observation) (K)"
  res2@tiYAxisString = "Isobaric level (hPa)"
  res2@xyMonoLineThickness = True
  res2@xyLineThicknessF = 5
  res2@gsnYRefLine = (/ avg_SP_model_hPa, avg_SP_obs_hPa /)
  res2@gsnYRefLineColors = (/ "sienna", "purple" /)
  res2@gsnYRefLineThicknesses = (/ 5, 5 /)

  plot_1 = gsn_csm_xy (wks_1, T_all_2D_K, P_levels_1D_hPa, res1)

  gres1 = True
  gres1@YPosPercent = 90    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres1@XPosPercent = 5      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres1 = True
  lineres1@lgLineColors = (/ "red", "green", "sienna", "purple" /) ; line colors
  lineres1@lgLineThicknesses = 5                        ; line thicknesses
  lineres1@lgLineLengthPercent = 5                     ; expressed as %, 0->100, length of line

  textres1 = True
  textres1@lgLabels = (/ "Average temperature: CFS v2 (model)", "Average temperature: ERA interim (observations)", "Average model surface pressure", "Average observation surface pressure" /)  ; legend labels (required)

  plot_1 = simple_legend (wks_1, plot_1, gres1, lineres1, textres1)
  draw (plot_1)
  frame (wks_1)

  plot_2 = gsn_csm_xy (wks_2, avg_T_diff_1D_K, P_levels_1D_hPa, res2)

  gres2 = True
  gres2@YPosPercent = 40    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres2@XPosPercent = 5      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)


  lineres2 = True
  lineres2@lgLineColors = (/ "black", "sienna", "purple" /) ; line colors
  lineres2@lgLineThicknesses = 5                        ; line thicknesses
  lineres2@lgLineLengthPercent = 5                     ; expressed as %, 0->100, length of line

  textres2 = True
  textres2@lgLabels = (/ "Average temperature difference: CFS v2 - ERA interim", "Average model surface pressure", "Average observation surface pressure" /)  ; legend labels (required)

  plot_2 = simple_legend (wks_2, plot_2, gres2, lineres2, textres2)
  draw (plot_2)
  frame (wks_2)

end
