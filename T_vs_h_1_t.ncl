begin

  grb_file = addfile ("/Vol2/sarthak/CFSv2/y2018/pgbf2018062506.01.2009020500.grb", "r")

  temperature = grb_file->TMP_3_ISBL (:, {20:25}, {70:75})
  temp_avg_lon = dim_avg_n_Wrap (temperature, 2)
  temp_avg_lon_lat = dim_avg_n_Wrap (temp_avg_lon, 1)

  height = grb_file->lv_ISBL4
  
  print (temp_avg_lon_lat)
  print (height)

  resources = True
  resources@trYReverse = True

  wks = gsn_open_wks ("eps", "T_vs_h_plot")
  plot = gsn_xy (wks, temp_avg_lon_lat, height, resources)

end

