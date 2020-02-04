; T_vs_h_inversion_many_t_observations.ncl

begin

  T_folder_path = "/Vol2/sarthak/ERA_interim_data/temperature/"
  SP_folder_path = "/Vol2/sarthak/ERA_interim_data/surface_pressure/"
  n_years = 20
;  t_UTC_D1_hour = (/"00", "06", "12", "18"/)
  t_UTC = "18" 	 ; Can be "00" or "06" or "12" or "18".
;  n_times = 4

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  
  start_P_level_hPa = 1000
  stop_P_level_hPa = 500
  n_levels = 6

  n_total_inv_D2 = new ((/n_latitudes, n_longitudes/), integer)
  n_total_inv_D2 = 0

  n_total_inv_D3 = new ((/n_levels, n_latitudes, n_longitudes/), integer)
  n_total_inv_D3 = 0

; do i_hour = 0, n_times - 1
  do i_year = 0, n_years - 1
    year = i_year + 1999
    T_file_in = T_folder_path + "temperature_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept" + year + "_40N40E10S100E_1000to100hPa.grib2"
    SP_file_in = SP_folder_path + "surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept" + year + "_40N40E10S100E.grib2"
    T_grib_file = addfile (T_file_in, "r")
    SP_grib_file = addfile (SP_file_in, "r")
    T_D4_K = T_grib_file->T_GDS0_ISBL (:, {start_P_level_hPa : stop_P_level_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
    SP_D3_Pa = SP_grib_file->SP_GDS0_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
    SP_D3_hPa = SP_D3_Pa / 100
    P_level_D1_hPa = T_grib_file->lv_ISBL1 ({start_P_level_hPa : stop_P_level_hPa})
;    T_lat_D1_deg_N = T_nc_file->latitude ({start_lat_deg_N : stop_lat_deg_N})
;    T_lon_D1_deg_E = T_nc_file->longitude ({start_lon_deg_E : stop_lon_deg_E})
;    SP_lat_D1_deg_N = SP_nc_file->latitude ({start_lat_deg_N : stop_lat_deg_N})
;    SP_lon_D1_deg_E = SP_nc_file->longitude ({start_lon_deg_E : stop_lon_deg_E})
;    T_time_D1_hour = T_nc_file->time
;    SP_time_D1_hour = SP_nc_file->time

    print (year)
;    printVarSummary (T_D4_K)
    printMinMax (T_D4_K, 0)
;    printVarSummary (SP_D3_Pa)
    printMinMax (SP_D3_Pa, 0)
;    printVarSummary (SP_D3_hPa)
;    printMinMax (SP_D3_hPa, 0)
;    print (P_level_D1_hPa)
;    print (T_lat_D1_deg_N)
;    print (T_lon_D1_deg_E)
;    print (SP_lat_D1_deg_N)
;    print (SP_lon_D1_deg_E)
;    print (T_time_D1_hour)
;    print (SP_time_D1_hour)

;    return

    dimsizes_T_D1 = dimsizes (T_D4_K)
    n_lon = dimsizes_T_D1 (3)
    n_lat = dimsizes_T_D1 (2)
    n_level = dimsizes_T_D1 (1)
    n_time = dimsizes_T_D1 (0)
    do i_time = 0, n_time - 1
      do i_lon = 0, n_lon - 1
        do i_lat = 0, n_lat - 1
          do i_level = 0, n_level - 2
            if P_level_D1_hPa (i_level) .le. SP_D3_hPa (i_time, i_lat, i_lon)
              if T_D4_K (i_time, i_level + 1, i_lat, i_lon) .gt. T_D4_K (i_time, i_level, i_lat, i_lon)
                n_total_inv_D2 (i_lat, i_lon) = n_total_inv_D2 (i_lat, i_lon) + 1
		n_total_inv_D3 (i_level, i_lat, i_lon) = n_total_inv_D3 (i_level, i_lat, i_lon) + 1
                break
              end if
            end if
          end do
        end do
      end do
    end do
    delete (T_grib_file)
    delete (SP_grib_file)
  end do

;  n_total_inv_D3!0 = "level"
;  n_total_inv_D3!1 = "latitude"
;  n_total_inv_D3!2 = "longitude"
;  n_total_inv_D3&level = T_D4_K&lv_ISBL1
;  n_total_inv_D3&latitude = T_D4_K&g0_lat_2
;  n_total_inv_D3&longitude = T_D4_K&g0_lon_3

  n_avg_inv_per_year_D3 = n_total_inv_D3 / n_years
  n_avg_inv_per_year_D3!0 = "level"
  n_avg_inv_per_year_D3!1 = "latitude"
  n_avg_inv_per_year_D3!2 = "longitude"
  n_avg_inv_per_year_D3&level = T_D4_K&lv_ISBL1
  n_avg_inv_per_year_D3&latitude = T_D4_K&g0_lat_2
  n_avg_inv_per_year_D3&longitude = T_D4_K&g0_lon_3

  n_avg_inv_per_year_D2 = n_total_inv_D2 / n_years
  n_avg_inv_per_year_D2!0 = "latitude"
  n_avg_inv_per_year_D2!1 = "longitude"
  ; latitude@units = "degrees north"
  ; longitude@units = "degrees east"
  n_avg_inv_per_year_D2&latitude = T_D4_K&g0_lat_2
  n_avg_inv_per_year_D2&longitude = T_D4_K&g0_lon_3

  res = True
  res@gsnDraw = True

  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  res@cnFillPalette = read_colormap_file ("WhiteBlue")

  res@cnMinLevelValF = 0
  res@cnMaxLevelValF = 122
  res@cnLevelSpacingF = 2

  res@mpMinLatF = start_lat_deg_N	; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E	 

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "Plot_T_inversions_" + t_UTC + "UTC_0-40N_40-100E_June-September_1999-2018_observations_break")
  plot = gsn_csm_contour_map (wks, n_avg_inv_per_year_D2, res) 
  
  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  cdf_filename = "avg_no_of_T_inversions_per_monsoon_per_year_1999to2018_0to40N_40to100E_observations_break.nc"
;  system ("/bin/rm -f " + cdf_filename)
  cdf_file = addfile ("/Vol2/sarthak/programs/" + cdf_filename, "w") 	; Write to netCDF file.
  cdf_file@title = "From analysis of observations using ERA interim data, for 20 years (1999 to 2018). Break in level loop when inversion is detected." ; Add some global attributes to the netCDF file.
  cdf_file@date = systemfunc ("date")
  cdf_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D2 = n_avg_inv_per_year_D2
  cdf_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D3 = n_avg_inv_per_year_D3
;  cdf_file->total_no_of_T_inversions_per_monsoon_06UTC_D3 = n_total_inv_D3

end
