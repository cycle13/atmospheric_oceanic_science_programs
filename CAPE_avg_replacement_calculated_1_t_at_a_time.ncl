; CAPE_avg_replacement_calculated_1_t_at_a_time.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40
  lat_increment_deg = 1
  n_latitudes = ((stop_lat_deg_N - start_lat_deg_N) / lat_increment_deg) + 1
  latitudes_1D_degN = fspan (start_lat_deg_N, stop_lat_deg_N, n_latitudes)
  latitudes_1D_degN@units = "degrees north"

  start_lon_deg_E = 40
  stop_lon_deg_E = 100
  lon_increment_deg = 1
  n_longitudes = ((stop_lon_deg_E - start_lon_deg_E) / lon_increment_deg) + 1
  longitudes_1D_degE = fspan (start_lon_deg_E, stop_lon_deg_E, n_longitudes)
  longitudes_1D_degE@units = "degrees east"

;  P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000 /)
;  n_P = dimsizes (P_levels_1D_hPa)
;  extended_P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000, 1100 /)
;  n_extended_P = dimsizes (extended_P_levels_1D_hPa)
  n_P = 17

  folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  n_years_model = 17

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".
		; When changing, also change in output variable name below.
  print (t_UTC)

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_file_name = "output_data_CAPE_avg_calculated_full_JJAS_0-40N_40-100E_replacement_10-1000hPa_1_t_at_a_time.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w") ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 (model) 2009 to 2025, replacing temperature and water vapour mixing ratio at 925 hPa pressure level with those of ERA interim (observations) 1999 to 2018." ; Add some global attributes to the netCDF file.i
  output_file@date = systemfunc ("date")

  T_model_6D_K = new ( (/ n_years_model, 4, 31, n_P, n_latitudes, n_longitudes /), float)
  SH_model_6D = new ( (/ n_years_model, 4, 31, n_P, n_latitudes, n_longitudes /), float)
  GH_model_6D_gpm = new ( (/ n_years_model, 4, 31, n_P, n_latitudes, n_longitudes /), float)
  sfc_GH_model_5D_gpm = new ( (/ n_years_model, 4, 31, n_latitudes, n_longitudes /), float)
  sfc_P_model_5D_Pa = new ( (/ n_years_model, 4, 31, n_latitudes, n_longitudes /), float)

  y_avg_CAPE_5D_Jperkg = new ((/ 4, 31, n_P, n_latitudes, n_longitudes /), float)
  y_avg_CAPE_925hPa_4D_Jperkg = new ((/ 4, 31, n_latitudes, n_longitudes /), float)

;  SP_5D_hPa = new ((/ n_years, 4, 31, n_latitudes, n_longitudes /), float)

  T_obs_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/temperature/temperature_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  T_obs_files = addfiles (T_obs_files_list, "r")
  ListSetType (T_obs_files, "join")
  T_obs_925hPa_4D_K = T_obs_files[:]->T_GDS0_ISBL (:, :, {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (T_obs_925hPa_4D_K)
  printMinMax (T_obs_925hPa_4D_K, 0)

  avg_T_obs_925hPa_2D_K = dim_avg_n_Wrap (T_obs_925hPa_4D_K, (/ 0, 1 /))
  printVarSummary (avg_T_obs_925hPa_2D_K)
  printMinMax (avg_T_obs_925hPa_2D_K, 0)

  SH_obs_files_list = systemfunc ("ls /Vol2/sarthak/ERA_interim_data/specific_humidity/specific_humidty_ERAint_" + t_UTC + "UTC_1x1deg_JJAS_????_40N40E10S100E_10to1000hPa.nc")
  SH_obs_files = addfiles (SH_obs_files_list, "r")
  ListSetType (SH_obs_files, "join")
  SH_obs_925hPa_4D = SH_obs_files[:]->Q_GDS0_ISBL (:, :, {925}, {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E})
  printVarSummary (SH_obs_925hPa_4D)
  printMinMax (SH_obs_925hPa_4D, 0)

  avg_SH_obs_925hPa_2D = dim_avg_n_Wrap (SH_obs_925hPa_4D, (/ 0, 1 /))
  printVarSummary (avg_SH_obs_925hPa_2D)
  printMinMax (avg_SH_obs_925hPa_2D, 0)

  do i_year = 0, n_years_model - 1
    year = i_year + 2009
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)

        i_month = month - 6
        i_day = day - 1

        ; print (i_month + " " + i_day)
        f_in = folder_path + "y" + year + "/pgbf" + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + t_UTC + ".01.2009020500"
;        print (f_in)

        grib_file = addfile (f_in + ".grb", "r")

        if month .eq. 6 then
          previous_days_count = 0
        else if month .eq. 7 then
          previous_days_count = 30
        else if month .eq. 8 then
          previous_days_count = 61
        else if month .eq. 9 then
          previous_days_count = 92
        end if
        end if
        end if
	end if

;  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y201?/pgbf201?0[6-9]??" + t_UTC + ".01.2009020500")
;  grib_files = addfiles (files + ".grib", "r")
;  ListSetType (grib_files, "join")

  P_levels_1D_hPa = grib_file->lv_ISBL4
;  print (P_levels_1D_hPa)
;  n_P = dimsizes (P_levels_1D_hPa)

  sfc_P_model_5D_Pa (i_year, i_month, i_day, :, :) = grib_file->PRES_3_SFC ({latitudes_1D_degN}, {longitudes_1D_degE})    ; Store some data from the grib file to local variable.
;  avg_SP_2D_hPa = dim_avg_n_Wrap (SP_3D_hPa, 0)
;  printVarSummary (avg_SP_2D_hPa)
;  printMinMax (avg_SP_2D_hPa, 0)

  T_model_6D_K (i_year, i_month, i_day, :, :, :) = grib_file->TMP_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
;  T_3D_K ({925}, :, :) = (/ T_obs_925hPa_4D_K (i_year, previous_days_count + i_day, :, :) /)
;  avg_T_3D_K = dim_avg_n_Wrap (T_4D_K, 0)
;  printVarSummary (avg_T_3D_K)
;  printMinMax (avg_T_3D_K, 0)

  SH_model_6D (i_year, i_month, i_day, :, :, :) = grib_file->SPF_H_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
  
  sfc_GH_model_5D_gpm (i_year, i_month, i_day, :, :) = grib_file->HGT_3_SFC ({latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_surface_GH_2D_gpm = dim_avg_n_Wrap (surface_GH_3D_gpm, 0)
;  printVarSummary (avg_surface_GH_2D_gpm)
;  printMinMax (avg_surface_GH_2D_gpm, 0)

  GH_model_6D_gpm (i_year, i_month, i_day, :, :, :) = grib_file->HGT_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_GH_3D_gpm = dim_avg_n_Wrap (GH_4D_gpm, 0)
;  printVarSummary (avg_GH_3D_gpm)
;  printMinMax (avg_GH_3D_gpm, 0)
  
;  SP_5D_hPa (i_year, i_month, i_day, :, :) = SP_2D_hPa

  delete (grib_file)

      end do
    end do
  end do

  T_avg_3D_K = dim_avg_n_Wrap (T_model_6D_K, (/ 0, 1, 2 /))
  T_avg_3D_K ({925}, :, :) = (/ avg_T_obs_925hPa_2D_K /)
  printVarSummary (T_avg_3D_K)
  printMinMax (T_avg_3D_K, 0)

  P_3D_hPa = conform (T_avg_3D_K, P_levels_1D_hPa, 0)
  P_3D_Pa = P_3D_hPa * 100
  P_3D_Pa!0 = T_avg_3D_K!0
  P_3D_Pa!1 = T_avg_3D_K!1
  P_3D_Pa!2 = T_avg_3D_K!2
  P_3D_Pa&lv_ISBL4 = T_avg_3D_K&lv_ISBL4
  P_3D_Pa&lat_3 = T_avg_3D_K&lat_3
  P_3D_Pa&lon_3 = T_avg_3D_K&lon_3
  P_3D_Pa@units = "Pa"
  P_3D_Pa@long_name = "Full model pressure"
  printVarSummary (P_3D_Pa)
  printMinMax (P_3D_Pa, 0)

  SH_avg_3D = dim_avg_n_Wrap (SH_model_6D, (/ 0, 1, 2 /))
  SH_avg_3D ({925}, :, :) = (/ avg_SH_obs_925hPa_2D /)
  printVarSummary (SH_avg_3D)
  printMinMax (SH_avg_3D, 0)

  WVMR_avg_3D = SH_avg_3D / (1 - SH_avg_3D)
  WVMR_avg_3D!0 = SH_avg_3D!0
  WVMR_avg_3D!1 = SH_avg_3D!1
  WVMR_avg_3D!2 = SH_avg_3D!2
  WVMR_avg_3D&lv_ISBL4 = SH_avg_3D&lv_ISBL4
  WVMR_avg_3D&lat_3 = SH_avg_3D&lat_3
  WVMR_avg_3D&lon_3 = SH_avg_3D&lon_3
  WVMR_avg_3D@units = "kg/kg"
  WVMR_avg_3D@long_name = "Water vapor mixing ratio"
  printVarSummary (WVMR_avg_3D)
  printMinMax (WVMR_avg_3D, 0)

  GH_avg_model_3D_gpm = dim_avg_n_Wrap (GH_model_6D_gpm, (/0, 1, 2/))
  printVarSummary (GH_avg_model_3D_gpm)
  printMinMax (GH_avg_model_3D_gpm, 0)

  sfc_GH_avg_model_2D_gpm = dim_avg_n_Wrap (sfc_GH_model_5D_gpm, (/ 0, 1, 2 /))
  printVarSummary (sfc_GH_avg_model_2D_gpm)
  printMinMax (sfc_GH_avg_model_2D_gpm, 0)

  sfc_P_avg_model_2D_Pa = dim_avg_n_Wrap (sfc_P_model_5D_Pa, (/0, 1, 2 /))
  sfc_P_avg_model_2D_hPa = sfc_P_avg_model_2D_Pa / 100
;  SP_3D_hPa!0 = "time"
  sfc_P_avg_model_2D_hPa!0 = sfc_P_avg_model_2D_Pa!0
  sfc_P_avg_model_2D_hPa!1 = sfc_P_avg_model_2D_Pa!1
  sfc_P_avg_model_2D_hPa&lat_3 = sfc_P_avg_model_2D_Pa&lat_3
  sfc_P_avg_model_2D_hPa&lon_3 = sfc_P_avg_model_2D_Pa&lon_3

  c_P_3D_Pa = linmsg (P_3D_Pa, 0)
  c_P_3D_Pa!0 = T_avg_3D_K!0
  c_P_3D_Pa!1 = T_avg_3D_K!1
  c_P_3D_Pa!2 = T_avg_3D_K!2
  c_P_3D_Pa&lv_ISBL4 = T_avg_3D_K&lv_ISBL4
  c_P_3D_Pa&lat_3 = T_avg_3D_K&lat_3
  c_P_3D_Pa&lon_3 = T_avg_3D_K&lon_3

  T_avg_3D_K = linmsg (T_avg_3D_K, 0)
  WVMR_avg_3D = linmsg (WVMR_avg_3D, 0)
  GH_avg_model_3D_gpm = linmsg (GH_avg_model_3D_gpm, 0)
  sfc_GH_avg_model_2D_gpm = linmsg (sfc_GH_avg_model_2D_gpm, 0)
  sfc_P_avg_model_2D_hPa = linmsg (sfc_P_avg_model_2D_hPa, 0)

  output_4D =  wrf_cape_3d (c_P_3D_Pa, T_avg_3D_K, WVMR_avg_3D, GH_avg_model_3D_gpm, sfc_GH_avg_model_2D_gpm, sfc_P_avg_model_2D_hPa, False)
  printVarSummary (output_4D)
  printMinMax (output_4D, 0)

  CAPE_avg_3D_Jperkg = output_4D (0, :, :, :)
  CAPE_avg_3D_kJperkg = CAPE_avg_3D_Jperkg / 1000
  CAPE_avg_3D_kJperkg!0 = T_avg_3D_K!0
  CAPE_avg_3D_kJperkg!1 = T_avg_3D_K!1
  CAPE_avg_3D_kJperkg!2 = T_avg_3D_K!2
  CAPE_avg_3D_kJperkg&lv_ISBL4 = T_avg_3D_K&lv_ISBL4
  CAPE_avg_3D_kJperkg&lat_3 = T_avg_3D_K&lat_3
  CAPE_avg_3D_kJperkg&lon_3 = T_avg_3D_K&lon_3
  CAPE_avg_3D_kJperkg@units = "kJ/kg"
  CAPE_avg_3D_kJperkg@long_name = "Average convective available potential energy"
  printVarSummary (CAPE_avg_3D_kJperkg)
  printMinMax (CAPE_avg_3D_kJperkg, 0)

  CAPE_avg_925hPa_2D_kJperkg = CAPE_avg_3D_kJperkg ( {925}, :, :)
;  CAPE_925hPa_5D_kJperkg!0 = "year"
;  CAPE_925hPa_5D_kJperkg!1 = "month"
;  CAPE_925hPa_5D_kJperkg!2 = "day"
;  CAPE_925hPa_5D_kJperkg!3 = T_3D_K!1
;  CAPE_925hPa_5D_kJperkg!4 = T_3D_K!2
;  CAPE_925hPa_5D_kJperkg&lat_3 = T_3D_K&lat_3
;  CAPE_925hPa_5D_kJperkg&lon_3 = T_3D_K&lon_3
;  CAPE_925hPa_5D_kJperkg@units = "kJ/kg"
  CAPE_avg_925hPa_2D_kJperkg@long_name = "Average convective available potential energy at 925 hPa pressure level"
  printVarSummary (CAPE_avg_925hPa_2D_kJperkg)
  printMinMax (CAPE_avg_925hPa_2D_kJperkg, 0)

;  do i_lat = 0, n_latitudes - 1
;    do i_lon = 0, n_longitudes - 1
;      do i_level = 0, n_extended_P - 2
;        if (SP_2D_hPa (i_lat, i_lon) .gt. extended_P_levels_1D_hPa (i_level)) .and. (SP_2D_hPa (i_lat, i_lon) .lt. extended_P_levels_1D_hPa (i_level + 1)) then
;          surface_CAPE_5D_Jperkg (i_year, i_month, i_day, i_lat, i_lon) = CAPE_6D_Jperkg (i_year, i_month, i_day, i_level, i_lat, i_lon)
;          break
;        end if
;      end do
;    end do
;  end do

  output_file->CAPE_JJAS_12UTC_3D_replaced_kJperkg = CAPE_avg_3D_kJperkg
;  output_file->CAPE_925hPa_JJAS_00UTC_4D_kJperkg = y_avg_CAPE_925hPa_4D_kJperkg
  
  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_925hPa_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_full_replacement_10-1000hPa.png") ; Open a workstation.

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

;  res@cnMinLevelValF = 0
;  res@cnMaxLevelValF = 2100
;  res@cnLevelSpacingF  =  150

  res@mpMinLatF = start_lat_deg_N   ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N
  res@mpMinLonF = start_lon_deg_E
  res@mpMaxLonF = stop_lon_deg_E

  xy = gsn_csm_contour_map (wks, CAPE_avg_925hPa_2D_kJperkg, res)

  delete (T_obs_files)
  delete (SH_obs_files)

end
