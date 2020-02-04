; evaporation_precipitation_CFSv2.ncl

begin

;  water_evaporation_latent_heat_Jperkg = new (1, double)
  water_evaporation_latent_heat_Jperkg = 2430000.0
  water_density_kgperm3 = 997.0
  earth_radius_m = new (1, double)
  earth_radius_m = 6371000.0

  start_lat_deg_N = 8
  stop_lat_deg_N = 28
  lat_1D_deg_N = ispan (start_lat_deg_N, stop_lat_deg_N, 1)
  n_lat = dimsizes (lat_1D_deg_N)

  start_lon_deg_E = 70
  stop_lon_deg_E = 90
  lon_1D_deg_E = ispan (start_lon_deg_E, stop_lon_deg_E, 1)
  n_lon = dimsizes (lon_1D_deg_E)

  total_area_m2 = earth_radius_m * earth_radius_m * gc_qarea ((/ start_lat_deg_N, start_lat_deg_N, stop_lat_deg_N, stop_lat_deg_N /), (/ start_lon_deg_E, stop_lon_deg_E, stop_lon_deg_E, start_lon_deg_E /))
  print (total_area_m2)

  t_UTC = "18"  ; Can be "00" or "06" or "12" or "18". When changing, also change in output variable names below.
  print (t_UTC)

  output_file_name = "output_data_evaporation_precipitation_8-28N_70-90E_CFSv2.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")  ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

;  CFSv2_folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  years_1D = ispan (2009, 2025, 1)
  n_years = dimsizes (years_1D)
  months_1D = ispan (6, 9, 1)
  n_months = dimsizes (months_1D)
  days_1D = ispan (1, 31, 1)
  n_days = dimsizes (days_1D)
 
  all_lon_1D_deg_E = (/ start_lon_deg_E, start_lon_deg_E + 1, start_lon_deg_E + 1, start_lon_deg_E /)

;  varying_quad_areas_1D_m2 = new (n_lat_CFSv2 - 1, double)
;  do lat = start_lat_deg_N, stop_lat_deg_N - 1
;    index = lat - start_lat_deg_N
;    varying_quad_areas_1D_m2 (index) = earth_radius_m * earth_radius_m * gc_qarea ((/ lat, lat, lat + 1, lat + 1 /), all_lon_1D)
;  end do
;  print (varying_quad_areas_1D_m2)
;  return

  evap_point_rate_CFSv2_5D_kgperm2s = new ((/ n_years, n_months, n_days, n_lat, n_lon /) , float)

  pcp_point_rate_CFSv2_5D_kgperm2s = new ((/ n_years, n_months, n_days, n_lat, n_lon /) , float)

  do i_year = 0, n_years - 1
    year = i_year + 2009
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)

        i_month = month - 6
        i_day = day - 1

        ; print (i_month + " " + i_day)
        CFSv2_input_path = "/Vol2/sarthak/CFSv2/y" + year + "/pgbf" + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + t_UTC + ".01.2009020500.grib"
;        print (f_in)

        CFSv2_input_file = addfile (CFSv2_input_path, "r")

        evap_point_rate_CFSv2_5D_kgperm2s (i_year, i_month, i_day, :, :) = CFSv2_input_file->LHTFL_3_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E}) / water_evaporation_latent_heat_Jperkg
	
	pcp_point_rate_CFSv2_5D_kgperm2s (i_year, i_month, i_day, :, :) = CFSv2_input_file->PRATE_3_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

	latitude = CFSv2_input_file->lat_3 ({start_lat_deg_N : stop_lat_deg_N})
        longitude = CFSv2_input_file->lon_3 ({start_lon_deg_E : stop_lon_deg_E})

	delete (CFSv2_input_file)	
	
      end do
    end do
  end do

;  evap_point_rate_CFSv2_5D_kgperm2s = latent_heat_flux_CFSv2_5D_Wperm2 / water_evaporation_latent_heat_Jperkg

  evap_point_rate_CFSv2_5D_kgperm2s!3 = "latitude"
  evap_point_rate_CFSv2_5D_kgperm2s&latitude = latitude
  evap_point_rate_CFSv2_5D_kgperm2s!4 = "longitude"
  evap_point_rate_CFSv2_5D_kgperm2s&longitude = longitude

  pcp_point_rate_CFSv2_5D_kgperm2s!3 = "latitude"
  pcp_point_rate_CFSv2_5D_kgperm2s&latitude = latitude
  pcp_point_rate_CFSv2_5D_kgperm2s!4 = "longitude"
  pcp_point_rate_CFSv2_5D_kgperm2s&longitude = longitude

  evap_point_rate_CFSv2_5D_kgpers = new ((/ n_years, n_months, n_days, n_lat, n_lon /), double)
  evap_point_rate_CFSv2_5D_kgpers!3 = "latitude"
  evap_point_rate_CFSv2_5D_kgpers&latitude = latitude
  evap_point_rate_CFSv2_5D_kgpers!4 = "longitude"
  evap_point_rate_CFSv2_5D_kgpers&longitude = longitude

  pcp_point_rate_CFSv2_5D_kgpers = new ((/ n_years, n_months, n_days, n_lat, n_lon /), double)
  pcp_point_rate_CFSv2_5D_kgpers!3 = "latitude"
  pcp_point_rate_CFSv2_5D_kgpers&latitude = latitude
  pcp_point_rate_CFSv2_5D_kgpers!4 = "longitude"
  pcp_point_rate_CFSv2_5D_kgpers&longitude = longitude

  do lat_deg_N = start_lat_deg_N, stop_lat_deg_N - 1
;    i_lat = lat_deg_N - start_lat_deg_N
    evap_point_rate_CFSv2_5D_kgpers (:, :, :, {lat_deg_N}, :) = evap_point_rate_CFSv2_5D_kgperm2s (:, :, :, {lat_deg_N}, :) * earth_radius_m * earth_radius_m * gc_qarea ((/ lat_deg_N, lat_deg_N, lat_deg_N + 1, lat_deg_N + 1 /), all_lon_1D_deg_E)
    pcp_point_rate_CFSv2_5D_kgpers (:, :, :, {lat_deg_N}, :) = pcp_point_rate_CFSv2_5D_kgperm2s (:, :, :, {lat_deg_N}, :) * earth_radius_m * earth_radius_m * gc_qarea ((/ lat_deg_N, lat_deg_N, lat_deg_N + 1, lat_deg_N + 1 /), all_lon_1D_deg_E)
  end do

  evaporation_rate_3D_kgpers = dim_sum_n_Wrap (evap_point_rate_CFSv2_5D_kgpers, (/ 3, 4 /))
  precipitation_rate_3D_kgpers = dim_sum_n_Wrap (pcp_point_rate_CFSv2_5D_kgpers, (/ 3, 4 /))

  evaporation_rate_3D_mmperday = evaporation_rate_3D_kgpers * 60 * 60 * 24 * 1000 / (water_density_kgperm3 * total_area_m2)
  evaporation_rate_3D_mmperday!0 = "year"
  evaporation_rate_3D_mmperday!1 = "month"
  evaporation_rate_3D_mmperday!2 = "day"
  evaporation_rate_3D_mmperday&year = years_1D
  evaporation_rate_3D_mmperday&month = months_1D
  evaporation_rate_3D_mmperday&day = days_1D
  evaporation_rate_3D_mmperday@units = "mm/day"
  evaporation_rate_3D_mmperday@long_name = "evaporation rate"
  printVarSummary (evaporation_rate_3D_mmperday)
  printMinMax (evaporation_rate_3D_mmperday, 0)
  output_file->evaporation_rate_18UTC_3D_mmperday = evaporation_rate_3D_mmperday

  evaporation_rate_avg_mmperday = avg (evaporation_rate_3D_mmperday)
  print (evaporation_rate_avg_mmperday)

  precipitation_rate_3D_mmperday = precipitation_rate_3D_kgpers * 60 * 60 * 24 * 1000 / (water_density_kgperm3 * total_area_m2)
  precipitation_rate_3D_mmperday!0 = "year"
  precipitation_rate_3D_mmperday!1 = "month"
  precipitation_rate_3D_mmperday!2 = "day"
  precipitation_rate_3D_mmperday&year = years_1D
  precipitation_rate_3D_mmperday&month = months_1D
  precipitation_rate_3D_mmperday&day = days_1D
  precipitation_rate_3D_mmperday@units = "mm/day"
  precipitation_rate_3D_mmperday@long_name = "precipitation rate"
  printVarSummary (precipitation_rate_3D_mmperday)
  printMinMax (precipitation_rate_3D_mmperday, 0)
  output_file->precipitation_rate_18UTC_3D_mmperday = precipitation_rate_3D_mmperday

  precipitation_rate_avg_mmperday = avg (precipitation_rate_3D_mmperday)
  print (precipitation_rate_avg_mmperday)

end
