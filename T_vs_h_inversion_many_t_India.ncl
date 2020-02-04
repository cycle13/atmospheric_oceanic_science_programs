; T_vs_h_inversion_many_t_observations_India.ncl

begin

  model_nc_file = addfile ("/Vol2/sarthak/programs/avg_no_of_T_inversions_per_monsoon_per_year_2009to2025_0to40N_40to100E_model_break.nc", "r")
  obs_nc_file = addfile ("/Vol2/sarthak/programs/avg_no_of_T_inversions_per_monsoon_per_year_1999to2018_0to40N_40to100E_observations_break.nc", "r")
  
  stop_lat_deg_N = 38
  start_lat_deg_N = 8
  start_lon_deg_E = 68
  stop_lon_deg_E = 98

  t_UTC = "18"

  model_avg_T_inv_D2 = model_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D2 ({ start_lat_deg_N : stop_lat_deg_N }, { start_lon_deg_E : stop_lon_deg_E })
  obs_avg_T_inv_D2 = obs_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D2 ({ start_lat_deg_N : stop_lat_deg_N }, { start_lon_deg_E : stop_lon_deg_E })

  res = True
  res@gsnDraw = True

  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  res@cnFillPalette = read_colormap_file ("WhViBlGrYeOrRe")

  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 60
  res@cnLevelSpacingF = 1

  res@mpMinLatF = start_lat_deg_N	; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E	 

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_model = gsn_open_wks (wks_type, "Plot_T_inversions_" + t_UTC + "UTC_8-38N_68-98E_June-September_2009-2025_model_break")
  plot_model = gsn_csm_contour_map (wks_model, model_avg_T_inv_D2, res)
  wks_obs = gsn_open_wks (wks_type, "Plot_T_inversions_" + t_UTC + "UTC_8-38N_68-98E_June-September_1999-2018_observations_break")
  plot_obs = gsn_csm_contour_map (wks_obs, obs_avg_T_inv_D2, res)
  
end
