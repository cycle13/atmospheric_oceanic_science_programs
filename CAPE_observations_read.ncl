; CAPE_observations_read.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  t_UTC = "12+6"   ; Can be "00+12" or "00+6" or "12+12" or "12+6".

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
;  cdf_filename = "output_data_avg_CAPE_JJAS_2009to2025_0to40N_40to100E_CFSv2model.nc"
;  system ("/bin/rm -f " + cdf_filename)
;  cdf_file = addfile ("/Vol2/sarthak/output_data/" + cdf_filename, "w")    ; Write to netCDF file.
;  cdf_file@title = "From analysis of observations using ERA interim data, for 20 years (1999 to 2018). Break in level loop when inversion is detected." ; Add some global attributes to the netCDF file.
;  cdf_file@date = systemfunc ("date")

  files = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/CAPE/CAPE_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_surface.grib2")
  grib_files = addfiles (files + ".grib", "r")
  ListSetType (grib_files, "cat")

  CAPE_SFC_D3_Jperkg = grib_files[:]->CAPE_GDS0_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.

  printVarSummary (CAPE_SFC_D3_Jperkg)
  printMinMax (CAPE_SFC_D3_Jperkg, 0)
  
  avg_CAPE_SFC_D2_Jperkg = dim_avg_n_Wrap (CAPE_SFC_D3_Jperkg, 0)
  printVarSummary (avg_CAPE_SFC_D2_Jperkg)
  printMinMax (avg_CAPE_SFC_D2_Jperkg, 0)

  avg_CAPE_SFC_D2_kJperkg = avg_CAPE_SFC_D2_Jperkg / 1000
  avg_CAPE_SFC_D2_kJperkg!0 = avg_CAPE_SFC_D2_Jperkg!0
  avg_CAPE_SFC_D2_kJperkg!1 = avg_CAPE_SFC_D2_Jperkg!1
  avg_CAPE_SFC_D2_kJperkg&g0_lat_1 = avg_CAPE_SFC_D2_Jperkg&g0_lat_1
  avg_CAPE_SFC_D2_kJperkg&g0_lon_2 = avg_CAPE_SFC_D2_Jperkg&g0_lon_2
  avg_CAPE_SFC_D2_kJperkg@units = "kJ/kg"
  avg_CAPE_SFC_D2_kJperkg@long_name = "Average surface convective available potential energy"

  printVarSummary (avg_CAPE_SFC_D2_kJperkg)
  printMinMax (avg_CAPE_SFC_D2_kJperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_SFC = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_surface_" + t_UTC + "UTC_ERA_interim_obs_0-40N_40-100E_JJAS_1999-2018") 

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

  res@cnMinLevelValF = 0.15
  res@cnMaxLevelValF = 2.4
  res@cnLevelSpacingF  = 0.15

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy_SFC = gsn_csm_contour_map (wks_SFC, avg_CAPE_SFC_D2_kJperkg, res)

;  cdf_file->avg_CAPE_surface_JJAS_12UTC_D2_Jperkg = avg_CAPE_SFC_D2_Jperkg

  delete (grib_files)

end
