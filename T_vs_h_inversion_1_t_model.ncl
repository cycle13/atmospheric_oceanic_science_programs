; T_vs_h_inversion_1_t.ncl

begin

  grb_file = addfile ("/Vol2/sarthak/CFSv2/y2018/pgbf2018062506.01.2009020500.grb", "r")

  isobaric_level_hPa = grb_file->lv_ISBL4 ({700:})
  latitudes_deg_N = grb_file->lat_3({-5:35})
  longitudes_deg_E = grb_file->lon_3({40:80})

  temperature = grb_file->TMP_3_ISBL ({isobaric_level_hPa}, {latitudes_deg_N}, {longitudes_deg_E})
  temp_avg_lon = dim_avg_n_Wrap (temperature, 2)
  temp_avg_lon_lat = dim_avg_n_Wrap (temp_avg_lon, 1)

  print (temp_avg_lon_lat)
  print (isobaric_level_hPa)

  number_of_inversions_matrix = new ((/ dimsizes (latitudes_deg_N), dimsizes (longitudes_deg_E) /), integer)

  number_of_inversions_matrix!0 = "latitude"
  number_of_inversions_matrix!1 = "longitude"

  latitude_points = latitudes_deg_N
  longitude_points = longitudes_deg_E

  latitude_points@unit = "degrees north"
  longitude_points@unit = "degrees east"

  number_of_inversions_matrix&latitude = latitude_points
  number_of_inversions_matrix&longitude = longitude_points

  number_of_inversions_matrix = 0

  do n_lat = 0, (dimsizes (latitudes_deg_N)) - 1, 1
     do n_lon = 0, (dimsizes (longitudes_deg_E)) - 1, 1
      do n_level = 0, (dimsizes (isobaric_level_hPa)) - 2, 1
        if temperature (n_level, n_lat, n_lon) .gt. temperature (n_level + 1, n_lat, n_lon)
          number_of_inversions_matrix (n_lat, n_lon) = number_of_inversions_matrix (n_lat, n_lon) + 1
        end if
      end do
    end do
  end do

;  print (number_of_inversions_matrix)
  
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
  res@cnMaxLevelValF = 4
  res@cnLevelSpacingF  =  1

  res@mpMinLatF = -5.	; Range to zoom in on.
  res@mpMaxLatF = 35.	 
  res@mpMinLonF = 40.	 
  res@mpMaxLonF = 80.	 

  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500

  wks = gsn_open_wks (wks_type, "Plot_T_inversions")

  xy = gsn_csm_contour_map (wks, number_of_inversions_matrix, res) 

end

