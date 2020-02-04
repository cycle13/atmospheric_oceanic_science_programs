; average_geopotential_contour_map.ncl

begin

  t_UTC = "18"
  n_years = 2

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1

  start_P_level_hPa = 1000
  stop_P_level_hPa = 200
  n_levels = 10

  n_time = 122

  sum_GP_valid_D4_m2pers2 = new ((/ n_time, n_levels, n_latitudes, n_longitudes /), float)
  sum_GP_valid_D4_m2pers2 = 0

  do i_year = 0, n_years - 1
    year = i_year + 1999

    GP_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/geopotential/geopotential_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept" + year + "_40N40E10S100E_1000to100hPa.grib2", "r")

    SP_grib_file = addfile ("/Vol2/sarthak/ERA_interim_data/surface_pressure/surface_pressure_ERAint_" + t_UTC + "UTC_1x1deg_June2Sept" + year + "_40N40E10S100E.grib2", "r")

    GP_D4_m2pers2 = GP_grib_file->Z_GDS0_ISBL (:, {start_P_level_hPa : stop_P_level_hPa}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})    ; Store some data from the netCDF file to local variable.

    P_level_D1_hPa = GP_grib_file->lv_ISBL1 ({start_P_level_hPa : stop_P_level_hPa})

    SP_D3_Pa = SP_grib_file->SP_GDS0_SFC (:, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
    SP_D3_hPa = SP_D3_Pa / 100

    printVarSummary (GP_D4_m2pers2)
    printMinMax (GP_D4_m2pers2, 0)

    print (P_level_D1_hPa)

    printVarSummary (SP_D3_hPa)
    printMinMax (SP_D3_hPa, 0)

;  SP_avg_time_D2_hPa = dim_avg_n_Wrap (SP_D3_hPa, (/ 0 /))
;  printVarSummary (SP_avg_time_D2_hPa)
;  printMinMax (SP_avg_time_D2_hPa, 0)

    dimsizes_GP_D1 = dimsizes (GP_D4_m2pers2)
    n_lon = dimsizes_GP_D1 (3)
    n_lat = dimsizes_GP_D1 (2)
    n_level = dimsizes_GP_D1 (1)
    n_time = dimsizes_GP_D1 (0)


    do i_time = 0, n_time - 1
      do i_lon = 0, n_lon - 1
        do i_lat = 0, n_lat - 1
          do i_level = 0, n_level - 2
            if P_level_D1_hPa (i_level) .le. SP_D3_hPa (i_time, i_lat, i_lon)
              sum_GP_valid_D4_m2pers2 (i_time, i_level, i_lat, i_lon) = sum_GP_valid_D4_m2pers2 (i_time, i_level, i_lat, i_lon) + GP_D4_m2pers2 (i_time, i_level, i_lat, i_lon)
            end if
          end do
        end do
      end do
    end do
  end do

  annual_avg_GP_valid_D4_m2pers2 = sum_GP_valid_D4_m2pers2 / n_years

  GP_avg_time_level_D2_m2pers2 = dim_avg_n_Wrap (annual_avg_GP_valid_D4_m2pers2, (/ 0, 1 /))
  printVarSummary (GP_avg_time_level_D2_m2pers2)
  printMinMax (GP_avg_time_level_D2_m2pers2, 0)   

  wks = gsn_open_wks ("x11", "average_geopotential_" + t_UTC + "_UTC_ERA_interim_observations") ; Open a workstation.

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

  ; res@cnMinLevelValF = 0.0
  ; res@cnMaxLevelValF = 1.0
  ; res@cnLevelSpacingF  =  0.01

  res@mpMinLatF = start_lat_deg_N	; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N	;
  res@mpMinLonF = start_lon_deg_E	;
  res@mpMaxLonF = stop_lon_deg_E	;

  xy = gsn_csm_contour_map (wks, GP_avg_time_level_D2_m2pers2, res) 

end

