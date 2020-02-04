; T_vs_h_many_t_1_day.ncl

begin

  folder_path = "/Vol2/sarthak/CFSv2/y2018/"
;  files_paths_array = (/ folder_path + "pgbf2018062500.01.2009020500.grb", folder_path + "pgbf2018062506.01.2009020500.grb", folder_path + "pgbf2018062512.01.2009020500.grb", folder_path + "pgbf2018062518.01.2009020500.grb" /)
;  grb_files_list = addfiles (files_paths_array, "r")

  grb_file_00 = addfile (folder_path + "pgbf2018062500.01.2009020500.grb", "r")
  grb_file_06 = addfile (folder_path + "pgbf2018062506.01.2009020500.grb", "r")
  grb_file_12 = addfile (folder_path + "pgbf2018062512.01.2009020500.grb", "r")
  grb_file_18 = addfile (folder_path + "pgbf2018062518.01.2009020500.grb", "r")


  temperature_00 = grb_file_00->TMP_3_ISBL ({200:}, {20:25}, {70:75})
  temp_avg_lon_00 = dim_avg_n_Wrap (temperature_00, 2)
  temp_avg_lon_lat_00 = dim_avg_n_Wrap (temp_avg_lon_00, 1)

  temperature_06 = grb_file_06->TMP_3_ISBL ({200:}, {20:25}, {70:75})
  temp_avg_lon_06 = dim_avg_n_Wrap (temperature_06, 2)
  temp_avg_lon_lat_06 = dim_avg_n_Wrap (temp_avg_lon_06, 1)
 
  temperature_12 = grb_file_12->TMP_3_ISBL ({200:}, {20:25}, {70:75})
  temp_avg_lon_12 = dim_avg_n_Wrap (temperature_12, 2)
  temp_avg_lon_lat_12 = dim_avg_n_Wrap (temp_avg_lon_12, 1)

  temperature_18 = grb_file_18->TMP_3_ISBL ({200:}, {20:25}, {70:75})
  temp_avg_lon_18 = dim_avg_n_Wrap (temperature_18, 2)
  temp_avg_lon_lat_18 = dim_avg_n_Wrap (temp_avg_lon_18, 1)

  print (temp_avg_lon_lat_00)
  print (temp_avg_lon_lat_06)
  print (temp_avg_lon_lat_12)
  print (temp_avg_lon_lat_18)

  height_00 = grb_file_00->lv_ISBL4 ({200:})
  height_06 = grb_file_06->lv_ISBL4 ({200:})
  height_12 = grb_file_12->lv_ISBL4 ({200:})
  height_18 = grb_file_18->lv_ISBL4 ({200:})

  print (height_00)
;  print (height_06)
;  print (height_12)
;  print (height_18)

  temp_avg_lon_lat_all = new ((/4, 10/), float)
  temp_avg_lon_lat_all(0,:) = temp_avg_lon_lat_00
  temp_avg_lon_lat_all(1,:) = temp_avg_lon_lat_06
  temp_avg_lon_lat_all(2,:) = temp_avg_lon_lat_12
  temp_avg_lon_lat_all(3,:) = temp_avg_lon_lat_18

  resources = True
  resources@trYReverse = True
  resources@xyLineColors        = (/"red","green","blue","yellow"/)
;  resources@pmLegendDisplayMode    = "Always"

  wks = gsn_open_wks ("eps", "plot_T_vs_h_for_4_t")
  plot = gsn_xy (wks, temp_avg_lon_lat_all, height_00, resources)

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

