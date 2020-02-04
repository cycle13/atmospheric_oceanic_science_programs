; average_precipitation_JJAS_observations.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
;  lat_increment_deg = 1
;  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
;  lon_increment_deg = 1
;  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".

  ; To save variable n_avg_inv_per_year_D2 in netCDF file.
  CDF_filename = "result_data_avg_precipitation_JJAS_1998to2014_0to40N_40to100E_TRMM_observations.nc"
;  system ("rm " + cdf_filename)
  CDF_file = addfile ("/Vol2/sarthak/programs/" + CDF_filename, "w")    ; Write to netCDF file.
  CDF_file@title = "From analysis of TRMM observation data from netCDF files, for 17 years (1998 to 2014)." ; Add some global attributes to the netCDF file.
  CDF_file@date = systemfunc ("date")

  files = systemfunc ("ls /Vol2/sarthak/TRMM_data/2010/3B42.2010?[6-9]??." + t_UTC + ".*.nc")
  NC_files = addfiles (files, "r")
  ListSetType (NC_files, "join")
  precipitation_D4_mmperhour = NC_files[:]->pcp (:, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the grib file to local variable.

  printVarSummary (precipitation_D4_mmperhour)
  printMinMax (precipitation_D4_mmperhour, 0)

  pcp_avg_D2_mmperhour = dim_avg_n_Wrap (precipitation_D4_mmperhour, (/ 0, 1 /))

  pcp_avg_D2_mmperhour!0 = "latitude"
  pcp_avg_D2_mmperhour!1 = "longitude"
  pcp_avg_D2_mmperhour&latitude = precipitation_D4_mmperhour&latitude
  pcp_avg_D2_mmperhour&longitude = precipitation_D4_mmperhour&longitude
  pcp_avg_D2_mmperhour@long_name = "Average precipitation at " + t_UTC + " GMT"
  pcp_avg_D2_mmperhour@units = "mm/hour"

  printVarSummary (pcp_avg_D2_mmperhour)
  printMinMax (pcp_avg_D2_mmperhour, 0)

  wks = gsn_open_wks ("png", "plot_avg_precipitation_" + t_UTC + "UTC_TRMM_observations_0-40N_40-100E_JJAS_2009-2025") ; Open a workstation.

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

  XY = gsn_csm_contour_map (wks, pcp_avg_D2_mmperhour, res) 

  CDF_file->avg_pcp_18UTC_JJAS_1998_2014_D2_mmperhour = pcp_avg_D2_mmperhour

  delete (NC_files)

end

