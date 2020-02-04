; T_vs_h_inversion_many_t_model_corrected.nc

begin

  folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_D1 = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  n_years = 17
  t_UTC = "18" 	 ; Can be "00" or "06" or "12" or "18".

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

  n_total_inv_D2 = new ((/ n_latitudes, n_longitudes /), integer)
  n_total_inv_D2 = 0

  n_total_inv_D3 = new ((/ n_levels, n_latitudes, n_longitudes /), integer)
  n_total_inv_D3 = 0

  ; To save variable n_avg_inv_per_year_D2 in netCDF file.
  cdf_filename = "avg_no_of_T_inversions_per_monsoon_per_year_2009to2025_0to40N_40to100E_model_break.nc"
;  system ("rm " + cdf_filename)
  cdf_file = addfile ("/Vol2/sarthak/programs/" + cdf_filename, "w")    ; Write to netCDF file.
  cdf_file@title = "From analysis of model using data from grib files, for 17 years (2009 to 2025). Break in inner-most loop (of level) when a temperature inversion is detected." ; Add some global attributes to the netCDF file.
  cdf_file@date = systemfunc ("date")

  do i_year = 0, n_years - 1
    year = i_year + 2009
    do i_month = 6, 9
      do i_day = 1, n_days_per_month_D1 (i_month)
        ; print (i_month + " " + i_day)
        f_in = folder_path + "y" + year + "/pgbf" + year + sprinti ("%0.2i", i_month) + sprinti ("%0.2i", i_day) + t_UTC + ".01.2009020500"
;        print (f_in)

        grb_file = addfile (f_in + ".grb", "r")
        T_D3_K = grb_file->TMP_3_ISBL ({start_P_level_hPa : stop_P_level_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
	SP_D2_Pa = grb_file->PRES_3_SFC ({start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
	SP_D2_hPa = SP_D2_Pa / 100
	P_level_D1_hPa = grb_file->lv_ISBL4 ({start_P_level_hPa : stop_P_level_hPa})

	print (year)
        printMinMax (T_D3_K, 0)
	printMinMax (SP_D2_Pa, 0)

        dimsizes_T_D1 = dimsizes (T_D3_K)
        n_lon = dimsizes_T_D1 (2)
        n_lat = dimsizes_T_D1 (1)
        n_level = dimsizes_T_D1 (0)
        do i_lat = 0, n_lat - 1
          do i_lon = 0, n_lon - 1
            do i_level = 0, n_level - 2
	      if P_level_D1_hPa (i_level) .le. SP_D2_hPa (i_lat, i_lon)
                if T_D3_K (i_level + 1, i_lat, i_lon) .gt. T_D3_K (i_level, i_lat, i_lon)
                  n_total_inv_D2 (i_lat, i_lon) = n_total_inv_D2 (i_lat, i_lon) + 1
		  n_total_inv_D3 (i_level, i_lat, i_lon) = n_total_inv_D3 (i_level, i_lat, i_lon) + 1
                  break
                end if
	      end if
            end do
          end do
        end do
        delete (grb_file)
      end do
    end do
  end do

  n_avg_inv_per_year_D3 = n_total_inv_D3 / n_years
  n_avg_inv_per_year_D3!0 = "level"
  n_avg_inv_per_year_D3!1 = "latitude"
  n_avg_inv_per_year_D3!2 = "longitude"
  n_avg_inv_per_year_D3&level = T_D3_K&lv_ISBL4
  n_avg_inv_per_year_D3&latitude = T_D3_K&lat_3
  n_avg_inv_per_year_D3&longitude = T_D3_K&lon_3

  n_avg_inv_per_year_D2 = n_total_inv_D2 / n_years
  n_avg_inv_per_year_D2!0 = "latitude"
  n_avg_inv_per_year_D2!1 = "longitude"
  ; latitude@units = "degrees north"
  ; longitude@units = "degrees east"
  n_avg_inv_per_year_D2&latitude = T_D3_K&lat_3
  n_avg_inv_per_year_D2&longitude = T_D3_K&lon_3

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

  wks = gsn_open_wks (wks_type, "Plot_T_inversions_" + t_UTC + "UTC_0-40N_40-100E_June-September_2009-2025_model_break")
  plot = gsn_csm_contour_map (wks, n_avg_inv_per_year_D2, res) 
  
  cdf_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D2 = n_avg_inv_per_year_D2
  cdf_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D3 = n_avg_inv_per_year_D3

end
