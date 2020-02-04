; average_precipitation_JJAS_model.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".

  ; To save variable n_avg_inv_per_year_D2 in netCDF file.
  cdf_filename = "result_data_avg_precipitation_JJAS_2009to2025_0to40N_40to100E_CFSv2model.nc"
;  system ("rm " + cdf_filename)
  cdf_file = addfile ("/Vol2/sarthak/programs/" + cdf_filename, "w")    ; Write to netCDF file.
  cdf_file@title = "From analysis of CFS version 2 model using data from grib files, for 17 years (2009 to 2025)." ; Add some global attributes to the netCDF file.
  cdf_file@date = systemfunc ("date")

  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y20??/pgbf20??0[6-9]??" + t_UTC + ".01.2009020500")
  grib_files = addfiles (files + ".grib", "r")
  ListSetType (grib_files, "join")
  precipitation_rate_D3_kgperm2s2 = grib_files[:]->PRATE_3_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.

  printVarSummary (precipitation_rate_D3_kgperm2s2)
  printMinMax (precipitation_rate_D3_kgperm2s2, 0)

  pcp_avg_D2_kgperm2s2 = dim_avg_n_Wrap (precipitation_rate_D3_kgperm2s2, 0)
  printVarSummary (pcp_avg_D2_kgperm2s2)
  printMinMax (pcp_avg_D2_kgperm2s2, 0)

  water_density_kgperm3 = 997
  
  pcp_avg_D2_mmperhour = 3600 * 1000 * pcp_avg_D2_kgperm2s2 / water_density_kgperm3

  pcp_avg_D2_mmperhour!0 = "latitude"
  pcp_avg_D2_mmperhour!1 = "longitude"
  pcp_avg_D2_mmperhour&latitude = precipitation_rate_D3_kgperm2s2&lat_3
  pcp_avg_D2_mmperhour&longitude = precipitation_rate_D3_kgperm2s2&lon_3
  pcp_avg_D2_mmperhour@long_name = "average precipitation"
  pcp_avg_D2_mmperhour@units = "mm/hour"

  printVarSummary (pcp_avg_D2_mmperhour)
  printMinMax (pcp_avg_D2_mmperhour, 0)

  wks = gsn_open_wks ("png", "plot_avg_precipitation_" + t_UTC + "UTC_CFSv2model_0-40N_40-100E_JJAS_2009-2025") ; Open a workstation.

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

  res@cnMinLevelValF = 0.0
  res@cnMaxLevelValF = 1.0
  res@cnLevelSpacingF  =  0.01

  res@mpMinLatF = start_lat_deg_N	; -5   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N	; 40
  res@mpMinLonF = start_lon_deg_E	; 40
  res@mpMaxLonF = stop_lon_deg_E	; 100

  xy = gsn_csm_contour_map (wks, pcp_avg_D2_mmperhour, res) 

  cdf_file->average_precipitation_18UTC_JJAS_2009_2025_D2_mmperhour = pcp_avg_D2_mmperhour

  delete (grib_files)

end

