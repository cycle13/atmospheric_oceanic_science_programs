; cre_CAPE_calculated_925hPa_replacement_observations.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40

  start_lon_deg_E = 40
  stop_lon_deg_E = 100

  t_UTC = "18" ; Can be "00" or "06" or "12" or "18".
		; Also change in input variable names below.

  replace_file = addfile ("/Vol2/sarthak/output_data/output_data_CAPE_avg_calculated_full_JJAS_0-40N_40-100E_replacement_10-1000hPa_1_t_at_a_time.nc", "r")
  avg_CAPE_925hPa_replace_2D_kJperkg = replace_file->CAPE_JJAS_18UTC_3D_replaced_kJperkg ( {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )
;  avg_surface_CAPE_model_2D_Jperkg = dim_avg_n_Wrap (surface_CAPE_model_4D_Jperkg, (/ 0, 1 /))
;  selected_avg_CAPE_model_2D_Jperkg = avg_CAPE_model_3D_Jperkg ({925}, :, :)
  printVarSummary (avg_CAPE_925hPa_replace_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_replace_2D_kJperkg, 0)

  obs_file = addfile ("/Vol2/sarthak/output_data/output_data_CAPE_calculated_JJAS_1999-2018_0-40N_40-100E_ERA_interim_observations_10-1000hPa.nc", "r")
  CAPE_925hPa_obs_3D_Jperkg = obs_file->y_avg_CAPE_JJAS_18UTC_4D_Jperkg ( :, {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )
  avg_CAPE_925hPa_obs_2D_Jperkg = dim_avg_n_Wrap (CAPE_925hPa_obs_3D_Jperkg, 0)
;  selected_avg_CAPE_obs_2D_Jperkg = avg_CAPE_obs_3D_Jperkg ({925}, :, :)
  avg_CAPE_925hPa_obs_2D_kJperkg = avg_CAPE_925hPa_obs_2D_Jperkg / 1000
  avg_CAPE_925hPa_obs_2D_kJperkg!0 = avg_CAPE_925hPa_obs_2D_Jperkg!0
  avg_CAPE_925hPa_obs_2D_kJperkg!1 = avg_CAPE_925hPa_obs_2D_Jperkg!1
  avg_CAPE_925hPa_obs_2D_kJperkg&g0_lat_2 = avg_CAPE_925hPa_obs_2D_Jperkg&g0_lat_2
  avg_CAPE_925hPa_obs_2D_kJperkg&g0_lon_3 = avg_CAPE_925hPa_obs_2D_Jperkg&g0_lon_3
  avg_CAPE_925hPa_obs_2D_kJperkg@units = "kJ/kg"
  avg_CAPE_925hPa_obs_2D_kJperkg@long_name = "Average CAPE at 925 hPa pressure level, from ERA interim"

;  model_lat = model_file->lat_3
;  model_lon = model_file->lon_3
  obs_lat = obs_file->g0_lat_2
  obs_lon = obs_file->g0_lon_3

  printVarSummary (avg_CAPE_925hPa_obs_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_obs_2D_kJperkg, 0)

  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg = avg_CAPE_925hPa_replace_2D_kJperkg - avg_CAPE_925hPa_obs_2D_kJperkg

  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg!0 = "latitude"
  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg!1 = "longitude"
  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg&latitude = obs_lat
  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg&longitude = obs_lon
  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg@units = "kJ/kg"
  avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg@long_name = "Average CAPE difference (replacement - ERA interim) at 925 hPa pressure level"

  printVarSummary (avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_difference_replacement_ERAinterim_10to1000hPa.png") ; Open a workstation.

  res = True
  res@gsnDraw = True
  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  cmap = read_colormap_file ("testcmap")
  res@cnFillPalette = cmap

  res@cnMinLevelValF = -1.6
  res@cnMaxLevelValF = 1.6
  res@cnLevelSpacingF  = 0.2

  res@mpMinLatF = start_lat_deg_N    ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N        
  res@mpMinLonF = start_lon_deg_E       
  res@mpMaxLonF = stop_lon_deg_E

  plot = gsn_csm_contour_map (wks, avg_CAPE_925hPa_diff_replace_obs_2D_kJperkg, res)

  delete (replace_file)
  delete (obs_file)

end
