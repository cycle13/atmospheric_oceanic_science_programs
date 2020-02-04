; plot_2d_variable.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  n_latitudes = 41
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
  latitudes_1D = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  n_longitudes = 61
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  longitudes_1D = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)

  input_file = addfile ("/Vol2/sarthak/ERA_interim_data/CAPE/CAPE_ERAint_12+12UTC_1x1deg_JJAS_2018_40N40E10S100E_surface.grib2", "r")
  variable_2D_1 = input_file->CAPE_GDS0_SFC (0, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )
;  variable_2D_2 = input_file->avg_CAPE_JJAS_00UTC_3D_Jperkg ({925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )
  
;  variable_2D = dim_avg_n_Wrap (variable_3D, 0)

;  variable_2D = variable_2D
  variable_2D_1!0 = "latitude"
  variable_2D_1!1 = "longitude"
  variable_2D_1@units = "J/kg"
  variable_2D_1&latitude = latitudes_1D
  variable_2D_1&longitude = longitudes_1D

;  variable_2D_2!0 = "latitude"
;  variable_2D_2!1 = "longitude"
;  variable_2D_2@units = "J/kg"
;  variable_2D_2&latitude = latitudes_1D
;  variable_2D_2&longitude = longitudes_1D

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_1 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/plot_2D_variable_1") ; Open a workstation.
;  wks_2 = gsn_open_wks (wks_type, "/Vol2/sarthak/images/plot_2D_variable_2")

  res = True
  res@gsnDraw = True
  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  cmap = read_colormap_file ("WhViBlGrYeOrRe")
  res@cnFillPalette = cmap

;  scale_min = round (min (variable_2D) + (0.1 * (max (variable_2D) - min (variable_2D))), 0)
;  scale_max = round (max (variable_2D) - (0.1 * (max (variable_2D) - min (variable_2D))), 0)
  
;  res@cnMinLevelValF = scale_min
;  res@cnMaxLevelValF = scale_max
;  res@cnLevelSpacingF  =  round ((scale_max - scale_min) / 50, 0)

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  printMinMax (variable_2D_1, 0)
;  printMinMax (variable_2D_2, 0)
;  print (scale_min)
;  print (scale_max)

  xy_1 = gsn_csm_contour_map (wks_1, variable_2D_1, res)
;  xy_2 = gsn_csm_contour_map (wks_2, variable_2D_2, res)

  delete (input_file)
  
end
