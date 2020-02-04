; CAPE_model.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  t_UTC = "12"   ; Can be "00" or "06" or "12" or "18".

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  cdf_filename = "output_data_avg_CAPE_read_JJAS_2009to2025_0to40N_40to100E_CFSv2_model.nc"
;  system ("/bin/rm -f " + cdf_filename)
  cdf_file = addfile ("/Vol2/sarthak/output_data/" + cdf_filename, "w")    ; Write to netCDF file.
  cdf_file@title = "From analysis of CFS v2 model." ; Add some global attributes to the netCDF file.
  cdf_file@date = systemfunc ("date")

  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y20??/pgbf20??0[6-9]??" + t_UTC + ".01.2009020500")
  grib_files = addfiles (files + ".grib", "r")
  ListSetType (grib_files, "join")

  CAPE_SPDY_D3_Jperkg = grib_files[:]->CAPE_3_SPDY (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.
  CAPE_SFC_D3_Jperkg = grib_files[:]->CAPE_3_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

  printVarSummary (CAPE_SPDY_D3_Jperkg)
  printMinMax (CAPE_SPDY_D3_Jperkg, 0)
  printVarSummary (CAPE_SFC_D3_Jperkg)
  printMinMax (CAPE_SFC_D3_Jperkg, 0)

  avg_CAPE_SPDY_D2_Jperkg = dim_avg_n_Wrap (CAPE_SPDY_D3_Jperkg, 0)
  printVarSummary (avg_CAPE_SPDY_D2_Jperkg)
  printMinMax (avg_CAPE_SPDY_D2_Jperkg, 0)
  
  avg_CAPE_SFC_D2_Jperkg = dim_avg_n_Wrap (CAPE_SFC_D3_Jperkg, 0)
  printVarSummary (avg_CAPE_SFC_D2_Jperkg)
  printMinMax (avg_CAPE_SFC_D2_Jperkg, 0)

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks_SPDY = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_SPDY_" + t_UTC + "UTC_CFSv2model_0-40N_40-100E_JJAS_2009-2025") ; Open a workstation.
  wks_SFC = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_SFC_" + t_UTC + "UTC_CFSv2model_0-40N_40-100E_JJAS_2009-2025") 

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
  res@cnMaxLevelValF = 2100
  res@cnLevelSpacingF  =  150

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy_SPDY = gsn_csm_contour_map (wks_SPDY, avg_CAPE_SPDY_D2_Jperkg, res)
  xy_SFC = gsn_csm_contour_map (wks_SFC, avg_CAPE_SFC_D2_Jperkg, res)

  cdf_file->avg_CAPE_SPDY_JJAS_12UTC_D2_Jperkg = avg_CAPE_SPDY_D2_Jperkg
  cdf_file->avg_CAPE_SFC_JJAS_12UTC_D2_Jperkg = avg_CAPE_SFC_D2_Jperkg

  delete (grib_files)

end
