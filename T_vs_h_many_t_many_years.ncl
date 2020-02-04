; T_vs_h_many_t_many_years.ncl

begin

  folder_path = "/Vol2/sarthak/CFSv2/"

  files_00 = systemfunc ("ls " + folder_path + "y20??/pgbf20??0[6-9]*00.01.2009020500")
  files_06 = systemfunc ("ls " + folder_path + "y20??/pgbf20??0[6-9]*06.01.2009020500")
  files_12 = systemfunc ("ls " + folder_path + "y20??/pgbf20??0[6-9]*12.01.2009020500")
  files_18 = systemfunc ("ls " + folder_path + "y20??/pgbf20??0[6-9]*18.01.2009020500")

  grb_files_00 = addfiles (files_00 + ".grb", "r")
  grb_files_06 = addfiles (files_06 + ".grb", "r")
  grb_files_12 = addfiles (files_12 + ".grb", "r")
  grb_files_18 = addfiles (files_18 + ".grb", "r")

  ListSetType (grb_files_00, "join")
  ListSetType (grb_files_06, "join")
  ListSetType (grb_files_12, "join")
  ListSetType (grb_files_18, "join")

  temperature_00 = grb_files_00[:]->TMP_3_ISBL (:, {200:}, {20:25}, {70:75})
  temp_avg_lon_00 = dim_avg_n_Wrap (temperature_00, 3)
  temp_avg_lon_lat_00 = dim_avg_n_Wrap (temp_avg_lon_00, 2)
  temp_avg_lon_lat_day_00 = dim_avg_n_Wrap (temp_avg_lon_lat_00, 0)

  temperature_06 = grb_files_06[:]->TMP_3_ISBL (:, {200:}, {20:25}, {70:75})
  temp_avg_lon_06 = dim_avg_n_Wrap (temperature_06, 3)
  temp_avg_lon_lat_06 = dim_avg_n_Wrap (temp_avg_lon_06, 2)
  temp_avg_lon_lat_day_06 = dim_avg_n_Wrap (temp_avg_lon_lat_06, 0)
 
  temperature_12 = grb_files_12[:]->TMP_3_ISBL (:, {200:}, {20:25}, {70:75})
  temp_avg_lon_12 = dim_avg_n_Wrap (temperature_12, 3)
  temp_avg_lon_lat_12 = dim_avg_n_Wrap (temp_avg_lon_12, 2)
  temp_avg_lon_lat_day_12 = dim_avg_n_Wrap (temp_avg_lon_lat_12, 0)

  temperature_18 = grb_files_18[:]->TMP_3_ISBL (:, {200:}, {20:25}, {70:75})
  temp_avg_lon_18 = dim_avg_n_Wrap (temperature_18, 3)
  temp_avg_lon_lat_18 = dim_avg_n_Wrap (temp_avg_lon_18, 2)
  temp_avg_lon_lat_day_18 = dim_avg_n_Wrap (temp_avg_lon_lat_18, 0)

  print (temp_avg_lon_lat_day_00)
  print (temp_avg_lon_lat_day_06)
  print (temp_avg_lon_lat_day_12)
  print (temp_avg_lon_lat_day_18)

  height_00 = grb_files_00[:]->lv_ISBL4 (0, {200:})

  print (height_00)

  temp_avg_lon_lat_day_all = new ((/ 4, dimsizes (temp_avg_lon_lat_day_00) /), float)
  temp_avg_lon_lat_day_all (0, :) = temp_avg_lon_lat_day_00
  temp_avg_lon_lat_day_all (1, :) = temp_avg_lon_lat_day_06
  temp_avg_lon_lat_day_all (2, :) = temp_avg_lon_lat_day_12
  temp_avg_lon_lat_day_all (3, :) = temp_avg_lon_lat_day_18

  print (temp_avg_lon_lat_day_all)

  resources = True
  resources@trYReverse = True
  resources@xyLineColors        = (/ "red", "green", "blue", "yellow" /)
  resources@tiXAxisString = "Temperature (K)"
  resources@tiYAxisString = "Isobaric level (hPa)"

  wks = gsn_open_wks ("eps", "plot_T_vs_h_0_6_12_18_GMT_June_July_August_September_2009_2025")
  plot = gsn_xy (wks, temp_avg_lon_lat_day_all, height_00, resources)

  gres = True
  gres@YPosPercent = 95.    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 5      ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres = True
  lineres@lgLineColors = (/ "red", "green", "blue", "yellow" /) ; line colors
  lineres@lgLineThicknesses = 2.5                        ; line thicknesses
  lineres@LineLengthPercent = 9.                         ; expressed as %, 0->100, length of line

  textres = True
  textres@lgLabels = (/ "Time: 00 GMT", "Time: 06 GMT", "Time: 12 GMT", "Time: 18 GMT" /)  ; legend labels (required)

  plot = simple_legend (wks, plot, gres, lineres, textres)
  draw (plot)
  frame (wks)

end

