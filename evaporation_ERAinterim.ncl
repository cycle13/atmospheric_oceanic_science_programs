; evaporation_ERAinterim.ncl

begin

;  water_evaporation_latent_heat_Jperkg = new (1, double)
  water_evaporation_latent_heat_Jperkg = 2430000.0
  water_density_kgperm3 = 997.0
  earth_radius_m = new (1, double)
  earth_radius_m = 6371000.0

  start_lat_deg_N = 8
  stop_lat_deg_N = 28
  lat_1D_degN = ispan (start_lat_deg_N, stop_lat_deg_N, 1)
  n_lat_ERAint = dimsizes (lat_1D_degN)

  start_lon_deg_E = 70
  stop_lon_deg_E = 90
  lon_1D_degE = ispan (start_lon_deg_E, stop_lon_deg_E, 1)
  n_lon_ERAint = dimsizes (lon_1D_degE)

  total_area_m2 = earth_radius_m * earth_radius_m * gc_qarea ((/ start_lat_deg_N, start_lat_deg_N, stop_lat_deg_N, stop_lat_deg_N /), (/ start_lon_deg_E, stop_lon_deg_E, stop_lon_deg_E, start_lon_deg_E /))
  print (total_area_m2)

  t_ERA = "00+6"  ; Can be "00+6" or "00+12" or "12+6" or "12+12". When changing, also change in output variable name below.
  print (t_ERA)

;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/output_data_evaporation_ERAinterim_precipitation_TRMM_8-28N_70-90E.nc", "c")  ; Write to netCDF file.
  output_file@title = "From analysis of ERA interim and TRMM observations." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

;  CFSv2_folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)

  years_1D = ispan (1999, 2018, 1)
  n_ERAint_years = dimsizes (years_1D)
;  months_1D = ispan (6, 9, 1)
;  n_months = dimsizes (months_1D)
  days_1D = ispan (1, 122, 1)
  n_ERAint_days = dimsizes (days_1D)
 
;  evap_point_rate_CFSv2_5D_kgperm2s = new ((/ n_years, n_days, n_lat, n_lon /) , float)

;  pcp_point_rate_CFSv2_5D_kgperm2s = new ((/ n_years, n_days, n_lat, n_lon /) , float)

; print (i_month + " " + i_day)

  ERAint_input_file_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/evaporation/evaporation_ERAint_" + t_ERA + "_UTC_1x1deg_JJAS_????_40N40E10S100E.grib2")
  ERAint_input_files = addfiles (ERAint_input_file_list, "r")
  ListSetType (ERAint_input_files, "join")

  evap_point_rate_ERAint_4D_m = ERAint_input_files[:]->E_GDS0_SFC (:, :, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

  g0_lat_1 = ERAint_input_files[:]->g0_lat_1 (0, {start_lat_deg_N : stop_lat_deg_N})
  g0_lon_2 = ERAint_input_files[:]->g0_lon_2 (0, {start_lon_deg_E : stop_lon_deg_E})

;  pcp_point_rate_CFSv2_5D_kgperm2s (i_year, i_month, i_day, :, :) = CFSv2_input_file->PRATE_3_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

;  lat_ERAint_1D_degN = ERAint_input_files[:]->g0_lat_1 (0, {start_lat_deg_N : stop_lat_deg_N})
;  lon_ERAint_1D_degE = ERAint_input_files[:]->g0_lon_2 (0, {start_lon_deg_E : stop_lon_deg_E})

  delete (ERAint_input_files)
	
  evap_point_rate_ERAint_4D_mm = evap_point_rate_ERAint_4D_m * 1000
  evap_point_rate_ERAint_4D_mm!0 = "year"
  evap_point_rate_ERAint_4D_mm!1 = "day"
  evap_point_rate_ERAint_4D_mm!2 = "latitude"
  evap_point_rate_ERAint_4D_mm!3 = "longitude"
  evap_point_rate_ERAint_4D_mm&year = years_1D
  evap_point_rate_ERAint_4D_mm&day = days_1D
  evap_point_rate_ERAint_4D_mm&latitude = lat_1D_degN
  evap_point_rate_ERAint_4D_mm&longitude = lon_1D_degE
  evap_point_rate_ERAint_4D_mm@unit = "mm"
  evap_point_rate_ERAint_4D_mm@long_name = "evaporation (ERA interim)"
  printVarSummary (evap_point_rate_ERAint_4D_mm)
  printMinmax (evap_point_rate_ERAint_4D_mm, 0)

;  output_file->evap_point_rate_ERAint_00_6_UTC_4D_mm = evap_point_rate_ERAint_4D_mm

  evap_point_rate_t_avg_2D_mm = dim_avg_n_Wrap (evap_point_rate_ERAint_4D_mm, (/ 2, 3 /))

  all_lon_1D_deg_E = (/ start_lon_deg_E, start_lon_deg_E + 1, start_lon_deg_E + 1, start_lon_deg_E /)

  varying_quad_areas_1D_m2 = new (n_lat_ERAint - 1, double)
  varying_quad_areas_1D_m2!0 = "latitudes"
  varying_quad_areas_1D_m2&latitudes = g0_lat_1

  area_pcp_product_2D_m2mm = new ((/ n_lat_ERAint - 1, n_lat_ERAint - 1 /), double)

  do lat = start_lat_deg_N, stop_lat_deg_N - 1
    index = lat - start_lat_deg_N
    varying_quad_areas_1D_m2 (index) = earth_radius_m * earth_radius_m * gc_qarea ((/ lat, lat, lat + 1, lat + 1 /), all_lon_1D)
    area_pcp_product_2D_m2mm ({lat}, :) = varying_quad_areas_1D_m2 (index) * evap_point_rate_t_avg_2D_mm ({lat}, :)
  end do
  print (varying_quad_areas_1D_m2)

  avg_evap_point_rate_mm = sum (area_pcp_product_2D_m2mm) / total_area_m2
  print (avg_evap_point_rate_mm)

end
