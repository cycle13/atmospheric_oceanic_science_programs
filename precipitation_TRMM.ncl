; precipitation_TRMM.ncl

begin

  t_TRMM = "00"
  t_TRMM_minus3 = "21"
  t_TRMM_minus6 = "18"

  TRMM_years_1D = ispan (1998, 2014, 1)
  n_TRMM_years = dimsizes (TRMM_years_1D)
  months_1D = ispan (6, 9, 1)
  n_months = dimsizes (months_1D)
  TRMM_days_1D = ispan (1, 31, 1)
  n_TRMM_days = dimsizes (TRMM_days_1D)

  TRMM_interval_deg = 0.25
  n_lat_TRMM = ((stop_lat_deg_N - start_lat_deg_N) / TRMM_interval_deg) + 1
  n_lon_TRMM = ((stop_lon_deg_E - start_lon_deg_E) / TRMM_interval_deg) + 1

  pcp_point_rate_TRMM_5D_mmper6hours = new ((/ n_TRMM_years, n_months, n_TRMM_days, n_TRMM_lat, n_TRMM_lon /), float)

  do i_year = 0, n_TRMM_years - 1
    year = i_year + 1998
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)

        i_month = month - 6
        i_day = day - 1

        ; print (i_month + " " + i_day)
        f_in = "/Vol2/sarthak/TRMM_data/" + year + "/3B42." + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + "." + t_TRMM + ".7A.nc"
;        print (f_in)
        TRMM_input_file = addfile (f_in, "r")
        pcp_TRMM_2D_mmperhour = TRMM_input_file->pcp (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

        f_in_minus3 = "/Vol2/sarthak/TRMM_data/" + year + "/3B42." + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day - 1) + "." + t_TRMM_minus3 + ".7A.nc"
;        print (f_in)
        TRMM_minus3_input_file = addfile (f_in_minus3, "r")
        pcp_TRMM_minus3_2D_mmperhour = TRMM_minus3_input_file->pcp (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

        f_in_minus6 = "/Vol2/sarthak/TRMM_data/" + year + "/3B42." + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day - 1) + "." + t_TRMM_minus6 + ".7A.nc"
;        print (f_in)
        TRMM_minus6_input_file = addfile (f_in_minus6, "r")
        pcp_TRMM_minus6_2D_mmperhour = TRMM_minus6_input_file->pcp (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})

        pcp_point_rate_TRMM_5D_mmper6hours (i_year, i_month, i_day, :, :) = (1.5 * pcp_TRMM_minus6_2D_mmperhour) + (3 * pcp_TRMM_minus3_2D_mmperhour) + (1.5 * pcp_TRMM_2D_mmperhour)

        delete (TRMM_input_file)
        delete (TRMM_minus3_input_file)
        delete (TRMM_minus6_input_file)

      end do
    end do
  end do

  pcp_point_rate_TRMM_5D_mmperday = pcp_point_rate_TRMM_5D_mmper6hours * 4

  pcp_point_rate_TRMM_5D_mmperday!3 = "latitude"
  pcp_point_rate_TRMM_5D_mmperday&latitude = latitude
  pcp_point_rate_TRMM_5D_mmperday!4 = "longitude"
  pcp_point_rate_TRMM_5D_mmperday&longitude = longitude

  do lat_deg_N = start_lat_deg_N, stop_lat_deg_N - 1
;    i_lat = lat_deg_N - start_lat_deg_N
    pcp_point_rate_TRMM_5D_kgpers (:, :, :, {lat_deg_N}, :) = pcp_point_rate_CFSv2_5D_kgperm2s (:, :, :, {lat_deg_N}, :) * earth_radius_m * earth_radius_m * gc_qarea ((/ lat_deg_N, lat_deg_N, lat_deg_N + 1, lat_deg_N + 1 /), all_lon_1D_deg_E)
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
  output_file->evaporation_rate_06UTC_3D_mmperday = evaporation_rate_3D_mmperday

  evaporation_rate_avg_mmperday = avg (evaporation_rate_3D_mmperday)
  print (evaporation_rate_avg_mmperday)

  precipitation_rate_3D_mmperday = precipitation_rate_3D_kgpers * 60 * 60 * 24 * 1000 / (water_density_kgperm3 * total_area_m2)
  precipitation_rate_3D_mmperday!0 = "year"
  precipitation_rate_3D_mmperday!1 = "month"
  precipitation_rate_3D_mmperday!2 = "day"
  precipitation_rate_3D_mmperday&year = years_1D
  precipitation_rate_3D_mmperdat&month = months_1D
  precipitation_rate_3D_mmperday&day = days_1D
  precipitation_rate_3D_mmperday@units = "mm/day"
  precipitation_rate_3D_mmperday@long_name = "precipitation rate"
  printVarSummary (precipitation_rate_3D_mmperday)
  printMinMax (precipitation_rate_3D_mmperday, 0)
  output_file->precipitation_rate_06UTC_3D_mmperday = precipitation_rate_3D_mmperday

  precipitation_rate_avg_mmperday = avg (precipitation_rate_3D_mmperday)
  print (precipitation_rate_avg_mmperday)

end
