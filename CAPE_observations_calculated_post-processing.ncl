; CAPE_observations_calculated_post-processing.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
;  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
;  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
;  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
;  longitudes_1D_degE@units = "degrees east"

;  P_level_1D_hPa = (/ 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 /)
;  n_P = dimsizes (P_level_1D_hPa)
;  extended_P_level_1D_hPa = (/ 1100, 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100 /)
;  n_extended_P = dimsizes (extended_P_level_1D_hPa)

  t_UTC = "00"   ; Can be "00" or "06" or "12" or "18".
		; When changing, also change in input variable names below.

  input_file = addfile ("/Vol2/sarthak/output_data/output_data_CAPE_calculated_JJAS_1999-2018_0-40N_40-100E_ERA_interim_observations_10-1000hPa.nc", "r")
  y_avg_CAPE_925hPa_3D_Jperkg = input_file->y_avg_CAPE_JJAS_00UTC_4D_Jperkg (:, {925}, :, :)
  printVarSummary (y_avg_CAPE_925hPa_3D_Jperkg)
  printMinMax (y_avg_CAPE_925hPa_3D_Jperkg, 0)

;  SP_file_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept????_40N40E10S100E.grib2")
;  SP_grib_files = addfiles (SP_file_list, "r")
;  ListSetType (SP_grib_files, "cat")
;  surface_pressure_3D_Pa = SP_grib_files[:]->SP_GDS0_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.
;  avg_surface_pressure_2D_Pa = dim_avg_n_Wrap (surface_pressure_3D_Pa, 0)
;  surface_pressure_3D_hPa = surface_pressure_3D_Pa / 100
;  surface_pressure_3D_hPa!0 = "latitude"
;  surface_pressure_3D_hPa!1 = "longitude"
;  surface_pressure_3D_hPa&latitude = surface_pressure_3D_Pa&g0_lat_1
;  surface_pressure_3D_hPa&longitude = surface_pressure_3D_Pa&g0_lon_2
;  surface_pressure_3D_hPa@units = "hPa"
;  printVarSummary (surface_pressure_3D_hPa)
;  printMinMax (surface_pressure_3D_hPa, 0)

;do i_time = 0, 121
;  do n_lat = start_lat_deg_N, stop_lat_deg_N, lat_increment_deg
;    do n_lon = start_lon_deg_E, stop_lon_deg_E, lon_increment_deg
;      do i_level = 0, n_extended_P - 2, 1
;        if ((extended_P_level_1D_hPa (i_level) .gt. surface_pressure_3D_hPa (i_time, {n_lat}, {n_lon})) .and. (surface_pressure_3D_hPa (i_time, {n_lat}, {n_lon}) .gt. extended_P_level_1D_hPa (i_level + 1))) then
;          selected_CAPE_3D_Jperkg (i_time, {n_lat}, {n_lon}) = (/ CAPE_4D_Jperkg (i_time, {P_level_1D_hPa (i_level)}, {n_lat}, {n_lon}) /)
;          break
;        end if
;      end do
;    end do
;  end do
;end do

;  selected_CAPE_3D_Jperkg = y_avg_CAPE_4D_Jperkg (:, {925}, :, :)
;  selected_CAPE_3D_Jperkg!0 = "time"
;  selected_CAPE_3D_Jperkg!1 = "latitude"
;  selected_CAPE_3D_Jperkg!2 = "longitude"
;  selected_CAPE_3D_Jperkg&latitude = latitudes_1D_degN
;  selected_CAPE_3D_Jperkg&longitude = longitudes_1D_degE
;  selected_CAPE_3D_Jperkg@units = "J/kg"
;  selected_CAPE_3D_Jperkg@long_name = "Convective available potential energy"
;  printVarSummary (selected_CAPE_3D_Jperkg)
;  printMinMax (selected_CAPE_3D_Jperkg, 0)

  avg_CAPE_925hPa_2D_Jperkg = dim_avg_n_Wrap (y_avg_CAPE_925hPa_3D_Jperkg, 0)
  printVarSummary (avg_CAPE_925hPa_2D_Jperkg)
  printMinMax (avg_CAPE_925hPa_2D_Jperkg, 0)

  avg_CAPE_925hPa_2D_kJperkg = avg_CAPE_925hPa_2D_Jperkg / 1000
  avg_CAPE_925hPa_2D_kJperkg!0 = avg_CAPE_925hPa_2D_Jperkg!0
  avg_CAPE_925hPa_2D_kJperkg!1 = avg_CAPE_925hPa_2D_Jperkg!1
  avg_CAPE_925hPa_2D_kJperkg&g0_lat_2 = avg_CAPE_925hPa_2D_Jperkg&g0_lat_2
  avg_CAPE_925hPa_2D_kJperkg&g0_lon_3 = avg_CAPE_925hPa_2D_Jperkg&g0_lon_3
  avg_CAPE_925hPa_2D_kJperkg@units = "kJ/kg"
  avg_CAPE_925hPa_2D_kJperkg@long_name = "Convective available potential energy at 925 hPa pressure level"
  printVarSummary (avg_CAPE_925hPa_2D_kJperkg)
  printMinMax (avg_CAPE_925hPa_2D_kJperkg, 0)

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_1999-2018_ERA_interim_obs_10to1000hPa") ; Open a workstation.

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
;  res@lbOrientation         =  "Vertical"
;  res@lbBoxEndCapStyle = "TriangleBothEnds"

;  res@cnMinLevelValF = 0.2
;  res@cnMaxLevelValF = 3.6
;  res@cnLevelSpacingF  =  0.2

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, avg_CAPE_925hPa_2D_kJperkg, res)

  delete (input_file)

end
