; SH_vs_h_CFSv2_ERAinterim_JJAS.ncl

begin

  start_lat_deg_N = 31  ; When changing, also change in output variable names below.
  stop_lat_deg_N = 34

  start_lon_deg_E = 70  ; When changing, also change in output variable names below.
  stop_lon_deg_E = 72

  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
  P_levels_1D_hPa!0 = "pressure"
  P_levels_1D_hPa&pressure = P_levels_1D_hPa
  P_levels_1D_hPa@units = "hPa"
  P_levels_1D_hPa@long_name = "Pressure levels"

  t_UTC = "06"  ; Can be "00" or "06" or "12" or "18".
                ; When changing, also change in output variable names below.
  print (t_UTC)

  input_file_name = "output_data_SH_SP_high_diff_CAPE_model_obs.nc"
;  system ("/bin/rm -f " + cdf_filename)
  input_file = addfile ("/Vol2/sarthak/output_data/" + input_file_name, "r")  ; Write to netCDF file.

  avg_SH_model_1D = input_file->avg_SH_CFS_v2_06UTC_31to34N_70to72E_1D

  avg_SH_obs_1D = input_file->avg_SH_ERA_int_06UTC_31to34N_70to72E_1D

  avg_SP_model_Pa = input_file->avg_SP_CFS_v2_06UTC_31to34N_70to72E_Pa

  avg_SP_obs_Pa = input_file->avg_SP_ERA_int_06UTC_31to34N_70to72E_Pa

  avg_SP_model_hPa = avg_SP_model_Pa / 100
  avg_SP_model_hPa@units = "hPa"

  avg_SP_obs_hPa = avg_SP_obs_Pa / 100
  avg_SP_obs_hPa@units = "hPa"

  avg_SH_model_plot_1D = avg_SH_model_1D ({300 : 1000})
  avg_SH_obs_plot_1D = avg_SH_obs_1D ({300 : 1000})
  P_levels_plot_1D_hPa =  P_levels_1D_hPa ({300 : 1000})
  n_plot = dimsizes (P_levels_plot_1D_hPa)

  SH_all_2D = new ((/ 2, n_plot /), float)
  SH_all_2D (0, :) = (/ avg_SH_model_plot_1D /)
  SH_all_2D (1, :) = (/ avg_SH_obs_plot_1D /)
  printVarSummary (SH_all_2D)
  printMinMax (SH_all_2D, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_1 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_SH_vs_P_level_" + t_UTC + "UTC_" + start_lat_deg_N + "-" + stop_lat_deg_N + "N_" + start_lon_deg_E + "-" + stop_lon_deg_E + "E_JJAS") ; Open a workstation.

  res1 = True
  res1@trYReverse = True
  res1@xyLineColors        = (/ "red", "green" /)
  res1@tiXAxisString = "Specific humidity (kg/kg)"
  res1@tiYAxisString = "Isobaric level (hPa)"
  res1@xyMonoLineThickness = True
  res1@xyLineThicknessF = 10
  res1@gsnYRefLine = (/ avg_SP_model_hPa, avg_SP_obs_hPa /)
  res1@gsnYRefLineColors = (/ "purple", "blue" /)
  res1@gsnYRefLineThicknesses = (/ 10, 10 /)

  plot_1 = gsn_csm_xy (wks_1, SH_all_2D, P_levels_plot_1D_hPa, res1)

  gres = True
  gres@YPosPercent = 20    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 20      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres1 = True
  lineres1@lgLineColors = (/ "red", "green", "purple", "blue" /) ; line colors
  lineres1@lgLineThicknesses = 10                        ; line thicknesses
  lineres1@LineLengthPercent = 9.                         ; expressed as %, 0->100, length of line

  textres1 = True
  textres1@lgLabels = (/ "Specific humidity (CFS v2)", "Specific humidity (ERA interim)", "Surface pressure (CFS v2)", "Surface pressure (ERA interim)" /)  ; legend labels (required)

  plot_1 = simple_legend (wks_1, plot_1, gres, lineres1, textres1)
  draw (plot_1)
  frame (wks_1)

end
