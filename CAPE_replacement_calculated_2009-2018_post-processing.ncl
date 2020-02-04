; CAPE_replacement_calculated_1_t_at_a_time_post-processing.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40

  start_lon_deg_E = 40
  stop_lon_deg_E = 100

  t_UTC = "12"   ; Can be "00" or "06" or "12" or "18".
                ; When changing, also change in input variable name below.

  print (t_UTC)

  input_file = addfile ("/Vol2/sarthak/output_data/output_data_CAPE_calculated_JJAS_2009-2018_0-40N_40-100E_replacement_10-1000hPa.nc", "r")

  y_avg_CAPE_5D_kJperkg = input_file->CAPE_JJAS_12UTC_5D_kJperkg
  printVarSummary (y_avg_CAPE_5D_kJperkg)
  printMinMax (y_avg_CAPE_5D_kJperkg, 0)

  y_avg_CAPE_925hPa_4D_kJperkg = y_avg_CAPE_5D_kJperkg (:, :, {925}, :, :)
  y_avg_CAPE_925hPa_4D_kJperkg@long_name = "Convective available potential energy at 925 hPa pressure level"
  printVarSummary (y_avg_CAPE_925hPa_4D_kJperkg)
  printMinMax (y_avg_CAPE_925hPa_4D_kJperkg, 0)
  
  avg_CAPE_925hPa_2D_kJperkg = dim_avg_n_Wrap (y_avg_CAPE_925hPa_4D_kJperkg, (/ 0, 1 /))
  avg_CAPE_925hPa_2D_kJperkg@long_name = "Average convective available potential energy at 925 hPa pressure level"
  printVarSummary (avg_CAPE_925hPa_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_2D_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2018_replacement.png") ; Open a workstation.

  res = True
  res@gsnDraw = True
  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  cmap = read_colormap_file ("WhiteBlueGreenYellowRed")
  res@cnFillPalette = cmap

  res@cnMinLevelValF = 0.25
  res@cnMaxLevelValF = 3.75
  res@cnLevelSpacingF  =  0.25

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, avg_CAPE_925hPa_2D_kJperkg, res)

end

