; T_vs_h_inversion_comparisons_model_vs_data.ncl

begin

  model_nc_file = addfile ("/Vol2/sarthak/programs/avg_no_of_T_inversions_per_monsoon_per_year_2009to2025_0to40N_40to100E_model_break.nc", "r")
  obs_nc_file = addfile ("/Vol2/sarthak/programs/avg_no_of_T_inversions_per_monsoon_per_year_1999to2018_0to40N_40to100E_observations_break.nc", "r")

  model_avg_T_inv_D3 = model_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_00UTC_D3
;  model_06_avg_T_inv_D3 = model_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_06UTC_D3
;  model_12_avg_T_inv_D3 = model_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_12UTC_D3
;  model_18_avg_T_inv_D3 = model_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D3

  obs_avg_T_inv_D3 = obs_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_00UTC_D3
;  obs_06_avg_T_inv_D3 = obs_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_06UTC_D3
;  obs_12_avg_T_inv_D3 = obs_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_12UTC_D3
;  obs_18_avg_T_inv_D3 = obs_nc_file->avg_no_of_T_inversions_per_monsoon_per_year_18UTC_D3

  T_inv_dimsizes_D1 = dimsizes (model_avg_T_inv_D3)
  n_levels = T_inv_dimsizes_D1 (0)
;  n_lat = T_inv_dimsizes_D1 (1)
;  n_lon = T_inv_dimsizes_D1 (2)

  n_inv_D2 = new ((/ n_levels, 2 /), integer)
  n_inv_D2 = 0
  
  model_avg_T_inv_per_level_D1 = dim_sum_n_Wrap (model_avg_T_inv_D3, (/ 1, 2 /))
  obs_avg_T_inv_per_level_D1 = dim_sum_n_Wrap (obs_avg_T_inv_D3, (/ 1, 2 /))

  do i_level = 0, n_levels - 1
    n_inv_D2 (i_level, 0) = model_avg_T_inv_per_level_D1 (i_level)
    n_inv_D2 (i_level, 1) = obs_avg_T_inv_per_level_D1 (i_level)
  end do

  wks = gsn_open_wks ("x11", "number_of_T_inversions_vs_P_level")          ; send graphics to PNG file

  sres = True
  sres@vpWidthF = 0.7
  sres@vpHeightF = 0.5
  sres@vpXF = .15
  sres@trXMinF = 0.4
  sres@trXMaxF = 6.6
;  sres@trYMinF = 0.4
;  sres@trYMaxF = 130
  sres@gsnDraw = True
  sres@gsnFrame = False
  sres@gsnXYBarChart = True
  sres@gsnXYBarChartBarWidth = 0.15           ; change bar widths
  sres@tmXBMode          = "Explicit"         ; explicit labels
  sres@tmXBValues        = (/ 1, 2, 3, 4, 5, 6 /)
  sres@tmXBLabels = (/ "1000", "925", "850", "700", "600", "500" /)
  sres@tmXBLabelFontHeightF = 0.0205
  sres@tmXTLabelFontHeightF = 0.0205
  sres@tmYLLabelFontHeightF = 0.0225
  sres@tiMainFontHeightF = 0.025
  sres@tiMainFont = "helvetica"
  sres@tiMainString = "Number of temperature inversions vs. pressure levels, at 00 GMT."
  sres@gsnRightString = ""
  sres@tiYAxisString = "Number of temperature inversions"
      
  sres@gsnXYBarChartColors = (/ "red" /)	
  plot1 = gsn_csm_xy (wks, fspan (.775, 11.775, 6), n_inv_D2 (:, 0), sres)		; draw each series seperately, not advancing the frame but tweaking where each time series is drawn on the X-axis
  sres@gsnXYBarChartColors = (/ "blue" /)					
  plot2 = gsn_csm_xy (wks, fspan (.925, 11.925, 6), n_inv_D2 (:, 1), sres)		

  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.3           ; labelbar width
  lbres@vpHeightF          = 0.1           ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.36          ; puts space between color boxes
  lbres@lbFillColors       = (/ "red", "blue" /)
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.035         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbPerimOn          = False
  lbres@lgPerimColor 	   = "white"
  labels = (/ "model", "observations" /)
  gsn_labelbar_ndc (wks, 2, labels, 0.52, 0.23, lbres)	; draw right labelbar column

end
