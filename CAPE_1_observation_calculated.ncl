; CAPE_1_observation_calculated.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
  longitudes_1D_degE@units = "degrees east"

  P_level_1D_hPa = (/ 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 /)
  n_P = dimsizes (P_level_1D_hPa)
  extended_P_level_1D_hPa = (/ 1100, 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 /)
  n_extended_P = dimsizes (extended_P_level_1D_hPa)

  t_UTC = "00"   ; Can be "00" or "06" or "12" or "18".

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_filename = "output_data_avg_CAPE_JJAS_1999to2018_0to40N_40to100E_ERA_interim_observations.nc"
;  system ("/bin/rm -f " + cdf_filename)
;  output_file = addfile ("/Vol2/sarthak/output_data/" + output_filename, "w")    ; Write to netCDF file.
;  output_file@title = "From analysis of observations using ERA interim data, for 20 years (1999 to 2018)." ; Add some global attributes to the netCDF file.
;  output_file@date = systemfunc ("date")

  SP_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept2018_40N40E10S100E.grib2", "r")
  surface_pressure_2D_Pa = SP_grib_file->SP_GDS0_SFC (0, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.
;  avg_surface_pressure_2D_Pa = dim_avg_n_Wrap (surface_pressure_3D_Pa, 0)
  surface_pressure_2D_hPa = surface_pressure_2D_Pa / 100
  surface_pressure_2D_hPa!0 = "latitude"
  surface_pressure_2D_hPa!1 = "longitude"
  surface_pressure_2D_hPa&latitude = surface_pressure_2D_Pa&g0_lat_1
  surface_pressure_2D_hPa&longitude = surface_pressure_2D_Pa&g0_lon_2
  surface_pressure_2D_hPa@units = "hPa"
  printVarSummary (surface_pressure_2D_hPa)
  printMinMax (surface_pressure_2D_hPa, 0)

  T_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/temperature/temperature_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept2018_40N40E10S100E_1000to100hPa.grib2", "r")
  temperature_3D_K = T_grib_file->T_GDS0_ISBL (0, {P_level_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (temperature_3D_K)
  printMinMax (temperature_3D_K, 0)

  SH_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/specific_humidity/specific_humidty_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept2018_40N40E10S100E_1000to100hPa.grib2", "r")
  SH_3D = SH_grib_file->Q_GDS0_ISBL (0, {P_level_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SH_3D)
  printMinMax (SH_3D, 0)

  WVMR_3D = SH_3D / (1 - SH_3D)
;  WVMR_3D!0 = "time"
  WVMR_3D!0 = "level"
  WVMR_3D!1 = "latitude"
  WVMR_3D!2 = "longitude"
  WVMR_3D&level = SH_3D&lv_ISBL1
  WVMR_3D&latitude = SH_3D&g0_lat_2
  WVMR_3D&longitude = SH_3D&g0_lon_3
  WVMR_3D@units = "kg/kg"
  WVMR_3D@long_name = "Water vapour mixing ratio"
;  avg_WVMR_3D = dim_avg_n_Wrap (WVMR_4D, 0)
;  avg_WVMR_3D@long_name = "time-averaged water vapour mixing ratio"
  printVarSummary (WVMR_3D)
  printMinMax (WVMR_3D, 0)

  geopot_2D_file = addfile ("/Vol2/sarthak/ERA_interim_data/geopotential_2D_invariant_ERAint_1x1deg_40N40E10S100E.grib", "r")
  geopotential_2D_m2pers2 = geopot_2D_file->Z_GDS0_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  surface_height_2D_m = geopotential_2D_m2pers2 / 9.8
  surface_height_2D_m!0 = "latitude"
  surface_height_2D_m!1 = "longitude"
  surface_height_2D_m&latitude = geopotential_2D_m2pers2&g0_lat_0
  surface_height_2D_m&longitude = geopotential_2D_m2pers2&g0_lon_1
  surface_height_2D_m@units = "m"
  surface_height_2D_m@long_name = "Surface height"
  printVarSummary (surface_height_2D_m)
  printMinMax (surface_height_2D_m, 0)

  pressure_3D_Pa = conform (temperature_3D_K, P_level_1D_hPa, 0)
  pressure_3D_Pa@units = "Pa"
  pressure_3D_Pa!0 = "level"
  pressure_3D_Pa!1 = "latitude"
  pressure_3D_Pa!2 = "longitude"
  pressure_3D_Pa&level = P_level_1D_hPa
  pressure_3D_Pa&latitude = latitudes_1D_degN
  pressure_3D_Pa&longitude = longitudes_1D_degE
  printVarSummary (pressure_3D_Pa)
  printMinMax (pressure_3D_Pa, 0)

  geopot_4D_file = addfile ("/Vol2/sarthak/ERA_interim_data/geopotential_4D/geopotential_ERAint_18UTC_1x1deg_June2Sept2018_40N40E10S100E_1000to100hPa.grib2", "r")
  geopotential_3D_m2pers2 = geopot_4D_file->Z_GDS0_ISBL (0, {P_level_1D_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  full_model_height_3D_m = geopotential_3D_m2pers2 / 9.8
  full_model_height_3D_m@units = "m"
  full_model_height_3D_m!0 = "level"
  full_model_height_3D_m!1 = "latitude"
  full_model_height_3D_m!2 = "longitude"
  full_model_height_3D_m&level = P_level_1D_hPa
  full_model_height_3D_m&latitude = latitudes_1D_degN
  full_model_height_3D_m&longitude = longitudes_1D_degE
  printVarSummary (full_model_height_3D_m)
  printMinMax (full_model_height_3D_m, 0)
  
  c_pressure_3D_Pa = linmsg (pressure_3D_Pa, 0)
  temperature_3D_K = linmsg (temperature_3D_K, 0)
  WVMR_3D = linmsg (WVMR_3D, 0)
  full_model_height_3D_m = linmsg (full_model_height_3D_m, 0)
  surface_height_2D_m = linmsg (surface_height_2D_m, 0)
  surface_pressure_2D_hPa = linmsg (surface_pressure_2D_hPa, 0)

  output_4D = wrf_cape_3d (c_pressure_3D_Pa, temperature_3D_K, WVMR_3D, full_model_height_3D_m, surface_height_2D_m, surface_pressure_2D_hPa, False)
;   output_4D = wrf_cape_3d (pressure_3D_Pa, avg_temperature_3D_K, avg_WVMR_3D, full_model_height_3D_m, surface_height_2D_m, avg_surface_pressure_2D_Pa, False)
  printVarSummary (output_4D)
  printMinMax (output_4D, 0)

  CAPE_3D_Jperkg = output_4D (0, :, :, :)
  CAPE_3D_Jperkg!0 = "level"
  CAPE_3D_Jperkg!1 = "latitude"
  CAPE_3D_Jperkg!2 = "longitude"
  CAPE_3D_Jperkg&level = P_level_1D_hPa  
  CAPE_3D_Jperkg&latitude = latitudes_1D_degN
  CAPE_3D_Jperkg&longitude = longitudes_1D_degE
  CAPE_3D_Jperkg@units = "J/kg"
  CAPE_3D_Jperkg@long_name = "Convective available potential energy"
  printVarSummary (CAPE_3D_Jperkg)
  printMinMax (CAPE_3D_Jperkg, 0)

  selected_CAPE_2D_Jperkg = new ((/n_latitudes, n_longitudes/), "float")
  selected_CAPE_2D_Jperkg!0 = "latitude"
  selected_CAPE_2D_Jperkg!1 = "longitude"
  selected_CAPE_2D_Jperkg&latitude = latitudes_1D_degN
  selected_CAPE_2D_Jperkg&longitude = longitudes_1D_degE
  selected_CAPE_2D_Jperkg@units = "J/kg"
  selected_CAPE_2D_Jperkg@long_name = "Convective available potential energy"

  do n_lat = start_lat_deg_N, stop_lat_deg_N, lat_increment_deg
    do n_lon = start_lon_deg_E, stop_lon_deg_E, lon_increment_deg
      do i_level = 0, n_extended_P - 2, 1
        if ((extended_P_level_1D_hPa (i_level) .gt. surface_pressure_2D_hPa ({n_lat}, {n_lon})) .and. (surface_pressure_2D_hPa ({n_lat}, {n_lon}) .gt. extended_P_level_1D_hPa (i_level + 1))) then
          selected_CAPE_2D_Jperkg ({n_lat}, {n_lon}) = (/ CAPE_3D_Jperkg ({P_level_1D_hPa (i_level)}, {n_lat}, {n_lon}) /)
          break
        end if
      end do
    end do
  end do
;  selected_CAPE_2D_Jperkg = CAPE_3D_Jperkg ({850}, :, :)
  printVarSummary (selected_CAPE_2D_Jperkg)
  printMinMax (selected_CAPE_2D_Jperkg, 0)

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2000-2009_ERA_interim_observations") ; Open a workstation.

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

  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 50000
  res@cnLevelSpacingF  =  500

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, selected_CAPE_2D_Jperkg, res)
;  xy = gsn_csm_contour_map (wks, CAPE_3D_Jperkg, res)

;  output_file->avg_CAPE_JJAS_00UTC_3D_Jperkg = CAPE_3D_Jperkg

  delete (SP_grib_file)
  delete (T_grib_file)
  delete (SH_grib_file)
  delete (geopot_2D_file)
  delete (geopot_4D_file)

end
