; compare_CAPE_read_model_observations.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40

  start_lon_deg_E = 40
  stop_lon_deg_E = 100

  t_UTC = "18"
  t_obs_UTC = "12+6"

  model_file = addfile ("/Vol2/sarthak/output_data/output_data_avg_CAPE_read_JJAS_2009to2025_0to40N_40to100E_CFSv2_model.nc", "r")

  avg_CAPE_model_D2_Jperkg = model_file->avg_CAPE_SFC_JJAS_00UTC_D2_Jperkg ( {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )

;  observations_file = addfile ("/Vol2/sarthak/programs/result_data_avg_precipitation_JJAS_1998to2014_0to40N_40to100E_TRMM_observations.nc", "r")

  files = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/CAPE/CAPE_ERAint_" + t_obs_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_surface.grib2")
  grib_files = addfiles (files, "r")
  ListSetType (grib_files, "cat")
  CAPE_SFC_D3_Jperkg = grib_files[:]->CAPE_GDS0_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.
  avg_CAPE_obs_D2_Jperkg = dim_avg_n_Wrap (CAPE_SFC_D3_Jperkg, 0)

  model_lat = model_file->lat_3
  model_lon = model_file->lon_3
;  obs_lat = observations_file->latitude
;  obs_lon = observations_file->longitude

  printVarSummary (avg_CAPE_model_D2_Jperkg)
  printMinMax (avg_CAPE_model_D2_Jperkg, 0)

  printVarSummary (avg_CAPE_obs_D2_Jperkg)
  printMinMax (avg_CAPE_obs_D2_Jperkg, 0)

  avg_CAPE_diff_model_obs_D2_kJperkg = (avg_CAPE_model_D2_Jperkg - avg_CAPE_obs_D2_Jperkg) / 1000

  avg_CAPE_diff_model_obs_D2_kJperkg!0 = "latitude"
  avg_CAPE_diff_model_obs_D2_kJperkg!1 = "longitude"
  avg_CAPE_diff_model_obs_D2_kJperkg&latitude = model_lat
  avg_CAPE_diff_model_obs_D2_kJperkg&longitude = model_lon
  avg_CAPE_diff_model_obs_D2_kJperkg@units = "kJ/kg"
  avg_CAPE_diff_model_obs_D2_kJperkg@long_name = "average surface CAPE difference (CFS v2 model - ERA interim observation)"

  printVarSummary (avg_CAPE_diff_model_obs_D2_kJperkg)
  printMinMax (avg_CAPE_diff_model_obs_D2_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/difference_avg_surface_CAPE_model_obs_" + t_UTC + "UTC_0-40N_40-100E_JJAS") ; Open a workstation.

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

  res@cnMinLevelValF = -1.2
  res@cnMaxLevelValF = 1.2
  res@cnLevelSpacingF  =  0.15

  res@mpMinLatF = start_lat_deg_N    ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N        
  res@mpMinLonF = start_lon_deg_E       
  res@mpMaxLonF = stop_lon_deg_E

  plot = gsn_csm_contour_map (wks, avg_CAPE_diff_model_obs_D2_kJperkg, res)

  delete (model_file)
;  delete (observations_file)

end
