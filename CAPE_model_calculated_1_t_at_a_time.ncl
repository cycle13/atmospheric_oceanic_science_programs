; CAPE_model_calculated_1_t_at_a_time.ncl

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
  extended_P_levels_1D_hPa = (/ 10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000, 1100 /)
  n_extended_P = dimsizes (extended_P_levels_1D_hPa)
  n_P = 17

  folder_path = "/Vol2/sarthak/CFSv2/"
  n_days_per_month_1D = (/ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)
  n_years = 17

  t_UTC = "18"   ; Can be "00" or "06" or "12" or "18".
		; When changing, also change in output variable name below.

  ; Saving variable n_avg_inv_per_year_D2 in netCDF file.
  output_file_name = "output_data_CAPE_calculated_JJAS_2009to2025_0to40N_40to100E_CFSv2_model.nc"
;  system ("/bin/rm -f " + cdf_filename)
  output_file = addfile ("/Vol2/sarthak/output_data/" + output_file_name, "w")    ; Write to netCDF file.
  output_file@title = "From analysis of CFS v2 model." ; Add some global attributes to the netCDF file.
  output_file@date = systemfunc ("date")

  CAPE_6D_Jperkg = new ((/ n_years, 4, 31, n_P, n_latitudes, n_longitudes /), float)
  surface_CAPE_5D_Jperkg = new ((/ n_years, 4, 31, n_latitudes, n_longitudes /), float)

  SP_5D_hPa = new ((/ n_years, 4, 31, n_latitudes, n_longitudes /), float)

  do i_year = 0, n_years - 1
    year = i_year + 2009
    print (year)
    do month = 6, 9
      do day = 1, n_days_per_month_1D (month)
        ; print (i_month + " " + i_day)
        f_in = folder_path + "y" + year + "/pgbf" + year + sprinti ("%0.2i", month) + sprinti ("%0.2i", day) + t_UTC + ".01.2009020500"
;        print (f_in)

        grib_file = addfile (f_in + ".grb", "r")


;  files = systemfunc ("ls /Vol2/sarthak/CFSv2/y201?/pgbf201?0[6-9]??" + t_UTC + ".01.2009020500")
;  grib_files = addfiles (files + ".grib", "r")
;  ListSetType (grib_files, "join")

  P_levels_1D_hPa = grib_file->lv_ISBL4
;  print (P_levels_1D_hPa)
  n_P = dimsizes (P_levels_1D_hPa)

  SP_2D_Pa = grib_file->PRES_3_SFC ({latitudes_1D_degN}, {longitudes_1D_degE})    ; Store some data from the grib file to local variable.
  SP_2D_hPa = SP_2D_Pa / 100
;  SP_3D_hPa!0 = "time"
  SP_2D_hPa!0 = SP_2D_Pa!0
  SP_2D_hPa!1 = SP_2D_Pa!1
  SP_2D_hPa&lat_3 = SP_2D_Pa&lat_3
  SP_2D_hPa&lon_3 = SP_2D_Pa&lon_3
;  avg_SP_2D_hPa = dim_avg_n_Wrap (SP_3D_hPa, 0)
;  printVarSummary (avg_SP_2D_hPa)
;  printMinMax (avg_SP_2D_hPa, 0)

  T_3D_K = grib_file->TMP_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_T_3D_K = dim_avg_n_Wrap (T_4D_K, 0)
;  printVarSummary (avg_T_3D_K)
;  printMinMax (avg_T_3D_K, 0)

  SH_3D = grib_file->SPF_H_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_SH_3D = dim_avg_n_Wrap (SH_4D, 0)
  WVMR_3D = SH_3D / (1 - SH_3D)
  WVMR_3D!0 = SH_3D!0
  WVMR_3D!1 = SH_3D!1
  WVMR_3D!2 = SH_3D!2
  WVMR_3D&lv_ISBL4 = SH_3D&lv_ISBL4
  WVMR_3D&lat_3 = SH_3D&lat_3
  WVMR_3D&lon_3 = SH_3D&lon_3
;  printVarSummary (avg_WVMR_3D)
;  printMinMax (avg_WVMR_3D, 0)
  
  surface_GH_2D_gpm = grib_file->HGT_3_SFC ({latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_surface_GH_2D_gpm = dim_avg_n_Wrap (surface_GH_3D_gpm, 0)
;  printVarSummary (avg_surface_GH_2D_gpm)
;  printMinMax (avg_surface_GH_2D_gpm, 0)

  P_3D_hPa = conform (T_3D_K, P_levels_1D_hPa, 0)
  P_3D_Pa = P_3D_hPa * 100
;  printVarSummary (P_3D_Pa)
;  printMinMax (P_3D_Pa, 0)

  GH_3D_gpm = grib_file->HGT_3_ISBL (:, {latitudes_1D_degN}, {longitudes_1D_degE})
;  avg_GH_3D_gpm = dim_avg_n_Wrap (GH_4D_gpm, 0)
;  printVarSummary (avg_GH_3D_gpm)
;  printMinMax (avg_GH_3D_gpm, 0)
  
  c_P_3D_Pa = linmsg (P_3D_Pa, 0)
  c_P_3D_Pa!0 = T_3D_K!0
  c_P_3D_Pa!1 = T_3D_K!1
  c_P_3D_Pa!2 = T_3D_K!2
  c_P_3D_Pa&lv_ISBL4 = T_3D_K&lv_ISBL4
  c_P_3D_Pa&lat_3 = T_3D_K&lat_3
  c_P_3D_Pa&lon_3 = T_3D_K&lon_3

  T_3D_K = linmsg (T_3D_K, 0)
  WVMR_3D = linmsg (WVMR_3D, 0)
  GH_3D_gpm = linmsg (GH_3D_gpm, 0)
  surface_GH_2D_gpm = linmsg (surface_GH_2D_gpm, 0)
  SP_2D_hPa = linmsg (SP_2D_hPa, 0)

  output_4D =  wrf_cape_3d (c_P_3D_Pa, T_3D_K, WVMR_3D, GH_3D_gpm, surface_GH_2D_gpm, SP_2D_hPa, False)
;  printVarSummary (output_4D)
;  printMinMax (output_4D, 0)

  i_month = month - 6
  i_day = day - 1

  CAPE_6D_Jperkg (i_year, i_month, i_day, :, :, :) = output_4D (0, :, :, :)

  SP_5D_hPa (i_year, i_month, i_day, :, :) = SP_2D_hPa

  do i_lat = 0, n_latitudes - 1
    do i_lon = 0, n_longitudes - 1
      do i_level = 0, n_extended_P - 2
        if (SP_2D_hPa (i_lat, i_lon) .gt. extended_P_levels_1D_hPa (i_level)) .and. (SP_2D_hPa (i_lat, i_lon) .lt. extended_P_levels_1D_hPa (i_level + 1)) then
          surface_CAPE_5D_Jperkg (i_year, i_month, i_day, i_lat, i_lon) = CAPE_6D_Jperkg (i_year, i_month, i_day, i_level, i_lat, i_lon)
          break
        end if
      end do
    end do
  end do

  delete (grib_file)

      end do
    end do
  end do

  surface_CAPE_5D_kJperkg = surface_CAPE_5D_Jperkg / 1000
  surface_CAPE_5D_kJperkg!0 = "year"
  surface_CAPE_5D_kJperkg!1 = "month"
  surface_CAPE_5D_kJperkg!2 = "day"
  surface_CAPE_5D_kJperkg!3 = T_3D_K!1
  surface_CAPE_5D_kJperkg!4 = T_3D_K!2
  surface_CAPE_5D_kJperkg&lat_3 = T_3D_K&lat_3
  surface_CAPE_5D_kJperkg&lon_3 = T_3D_K&lon_3
  surface_CAPE_5D_kJperkg@units = "kJ/kg"
  surface_CAPE_5D_kJperkg@long_name = "Surface convective available potential energy"
  printVarSummary (surface_CAPE_5D_kJperkg)
  printMinMax (surface_CAPE_5D_kJperkg, 0)

  CAPE_6D_kJperkg = CAPE_6D_Jperkg / 1000
  CAPE_6D_kJperkg!0 = "year"
  CAPE_6D_kJperkg!1 = "month"
  CAPE_6D_kJperkg!2 = "day"
  CAPE_6D_kJperkg!3 = T_3D_K!0
  CAPE_6D_kJperkg!4 = T_3D_K!1
  CAPE_6D_kJperkg!5 = T_3D_K!2
  CAPE_6D_kJperkg&lv_ISBL4 = T_3D_K&lv_ISBL4
  CAPE_6D_kJperkg&lat_3 = T_3D_K&lat_3
  CAPE_6D_kJperkg&lon_3 = T_3D_K&lon_3
  CAPE_6D_kJperkg@units = "kJ/kg"
  CAPE_6D_kJperkg@long_name = "Convective available potential energy"
  printVarSummary (CAPE_6D_kJperkg)
  printMinMax (CAPE_6D_kJperkg, 0)

;  CAPE_925hPa_5D_kJperkg = CAPE_6D_kJperkg (:, :, :, {925}, :, :)

  y_avg_CAPE_5D_kJperkg = dim_avg_n_Wrap (CAPE_6D_kJperkg, 0)
  printVarSummary (y_avg_CAPE_5D_kJperkg)
  printMinMax (y_avg_CAPE_5D_kJperkg, 0)

  y_avg_surface_CAPE_4D_kJperkg = dim_avg_n_Wrap (surface_CAPE_5D_kJperkg, 0)
  printVarSummary (y_avg_surface_CAPE_4D_kJperkg)
  printMinMax (y_avg_surface_CAPE_4D_kJperkg, 0)

  avg_surface_CAPE_2D_kJperkg = dim_avg_n_Wrap (y_avg_surface_CAPE_4D_kJperkg, (/ 0, 1 /))
  printVarSummary (avg_surface_CAPE_2D_kJperkg)
  printMinMax (avg_surface_CAPE_2D_kJperkg, 0)

;  selected_avg_CAPE_2D_kJperkg = avg_CAPE_3D_kJperkg ({925}, :, :)

  output_file->CAPE_JJAS_18UTC_5D_kJperkg = y_avg_CAPE_5D_kJperkg
  output_file->surface_CAPE_JJAS_18UTC_4D_kJperkg = y_avg_surface_CAPE_4D_kJperkg

  wks_type = "x11"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/avg_CAPE_surface_calculated_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2025_CFSv2_model.png") ; Open a workstation.

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

  xy = gsn_csm_contour_map (wks, avg_surface_CAPE_2D_kJperkg, res)

end
