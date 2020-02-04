; moisture_balance_post-processing.ncl

begin

;********************************************************
; Import the data
;********************************************************  

  model_input_file = addfile ("/Vol2/sarthak/output_data/output_data_moisture_balance_CFSv2_vibeta.nc", "r")
  obs_input_file = addfile ("/Vol2/sarthak/output_data/output_data_moisture_balance_ERAinterim_vibeta.nc", "r")

  moisture_rate_00UTC_model_4D_mmperday = model_input_file->moisture_rate_00UTC_CFSv2_4D_mmperday
  moisture_rate_00UTC_model_1D_mmperday = dim_avg_n_Wrap (moisture_rate_00UTC_model_4D_mmperday, (/1, 2, 3 /))
  moisture_rate_06UTC_model_4D_mmperday = model_input_file->moisture_rate_06UTC_CFSv2_4D_mmperday
  moisture_rate_06UTC_model_1D_mmperday = dim_avg_n_Wrap (moisture_rate_06UTC_model_4D_mmperday, (/1, 2, 3 /))
  moisture_rate_12UTC_model_4D_mmperday = model_input_file->moisture_rate_12UTC_CFSv2_4D_mmperday
  moisture_rate_12UTC_model_1D_mmperday = dim_avg_n_Wrap (moisture_rate_12UTC_model_4D_mmperday, (/1, 2, 3 /))
  moisture_rate_18UTC_model_4D_mmperday = model_input_file->moisture_rate_18UTC_CFSv2_4D_mmperday
  moisture_rate_18UTC_model_1D_mmperday = dim_avg_n_Wrap (moisture_rate_18UTC_model_4D_mmperday, (/1, 2, 3 /))

  model_2D_mmperday = (/ moisture_rate_00UTC_model_1D_mmperday, moisture_rate_06UTC_model_1D_mmperday, moisture_rate_12UTC_model_1D_mmperday, moisture_rate_18UTC_model_1D_mmperday /)

  moisture_rate_00UTC_obs_3D_mmperday = obs_input_file->moisture_rate_00UTC_ERAinterim_3D_mmperday
  moisture_rate_00UTC_obs_1D_mmperday = dim_avg_n_Wrap (moisture_rate_00UTC_obs_3D_mmperday, (/ 1, 2 /))
  moisture_rate_06UTC_obs_3D_mmperday = obs_input_file->moisture_rate_06UTC_ERAinterim_3D_mmperday
  moisture_rate_06UTC_obs_1D_mmperday = dim_avg_n_Wrap (moisture_rate_06UTC_obs_3D_mmperday, (/ 1, 2 /))
  moisture_rate_12UTC_obs_3D_mmperday = obs_input_file->moisture_rate_12UTC_ERAinterim_3D_mmperday
  moisture_rate_12UTC_obs_1D_mmperday = dim_avg_n_Wrap (moisture_rate_12UTC_obs_3D_mmperday, (/ 1, 2 /))
  moisture_rate_18UTC_obs_3D_mmperday = obs_input_file->moisture_rate_18UTC_ERAinterim_3D_mmperday
  moisture_rate_18UTC_obs_1D_mmperday = dim_avg_n_Wrap (moisture_rate_18UTC_obs_3D_mmperday, (/ 1, 2 /))

  obs_2D_mmperday = (/ moisture_rate_00UTC_obs_1D_mmperday, moisture_rate_06UTC_obs_1D_mmperday, moisture_rate_12UTC_obs_1D_mmperday, moisture_rate_18UTC_obs_1D_mmperday /)

;  model_2D_kgpers = (/ (/5.94203e7, -0.1183616e7, 49.98051e7, 43.74197e7 /), (/ 8.769909e7, 4.56294e7, 46.09013e7, 42.04944e7 /), (/ 7.784837e7, 1.126384e7, 52.51095e7, 47.64494e7 /), (/ 9.002943e7, 2.448888e7, 47.00634e7, 43.74676e7 /) /)

;  obs_2D_kgpers = (/ (/ 8.836421e7, 2.826952e7, 66.28896e7, 51.22179e7 /), (/ 9.842519e7, 4.259714e7, 63.59292e7, 52.73012e7 /), (/ 8.277882e7, -0.3280596e7, 71.86292e7, 55.02776e7 /), (/ 8.742204e7, 4.293394e7, 64.01412e7, 50.26279e7 /) /)

;  model_start_lat_3D_kgpers = input_file_2->moisture_rate_CFSv2_start_lat_18UTC_3D_kgpers
  model_1_kgpers = model_2D_mmperday (0, 0) ; avg (model_start_lat_3D_kgpers)
;  model_stop_lat_3D_kgpers = input_file_2->moisture_rate_CFSv2_stop_lat_18UTC_3D_kgpers
  model_2_kgpers = model_2D_mmperday (1, 0) ; avg (model_stop_lat_3D_kgpers)
;  model_start_lon_3D_kgpers = input_file_2->moisture_rate_CFSv2_start_lon_18UTC_3D_kgpers
  model_3_kgpers = model_2D_mmperday (2, 0) ; avg (model_start_lon_3D_kgpers)
;  model_stop_lon_3D_kgpers = input_file_2->moisture_rate_CFSv2_stop_lon_18UTC_3D_kgpers
  model_4_kgpers = model_2D_mmperday (3, 0) ; avg (model_stop_lon_3D_kgpers)

;  obs_start_lat_2D_kgpers = input_file_1->moisture_rate_obs_start_lat_18UTC_2D_kgpers
  obs_1_kgpers = obs_2D_mmperday (0, 0) ; avg (obs_start_lat_2D_kgpers)
;  obs_stop_lat_2D_kgpers = input_file_1->moisture_rate_obs_start_lat_18UTC_2D_kgpers
  obs_2_kgpers = obs_2D_mmperday (1, 0) ; avg (obs_stop_lat_2D_kgpers)
;  obs_start_lon_2D_kgpers = input_file_1->moisture_rate_obs_start_lon_18UTC_2D_kgpers
  obs_3_kgpers = obs_2D_mmperday (2, 0) ; avg (obs_start_lon_2D_kgpers)i
;  obs_stop_lon_2D_kgpers = input_file_1->moisture_rate_obs_stop_lon_18UTC_2D_kgpers
  obs_4_kgpers = obs_2D_mmperday (3, 0) ; avg (obs_stop_lon_2D_kgpers)

  x = (/ 1, 2, 3, 4, 5, 6, 7, 8 /)
  y = (/ model_1_kgpers, obs_1_kgpers, model_2_kgpers, obs_2_kgpers, model_3_kgpers, obs_3_kgpers, model_4_kgpers, obs_4_kgpers /)
  labels = (/"0", "0", "6", "6", "12", "12", "18", "18" /)

;********************************************************
; create the plot
;********************************************************  
  wks_type = "png"
  wks_type@wkWidth = 2500
  wks_type@wkHeight = 2500
 
  wks = gsn_open_wks (wks_type, "/Vol2/sarthak/images/moisture_balance_08N_mmperday")  ; send graphics to PNG file
  res                       = True                 ; plot mods desired         
  res@gsnFrame              = False                ; don't advance frame yet
  res@gsnXYBarChart         = True                 ; turn on bar chart
  res@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  res@gsnXYBarChartColors = (/ "blue", "red", "blue", "red", "blue", "red", "blue", "red" /)   ; choose colors
  
  res@tmXBOn    = False                ; turn off tickmarks at bot
  res@trYMinF   = 0                    ; bring bars down to zero
  res@trYMaxF	= 15
  res@trXMinF   = 0                    ; adds space on either end
  res@trXMaxF   = 9                    ; of the 1st and last bars
  
  res@tiMainString          = "Moisture transfer rate (mm / day) accross boundaries"

  plot = gsn_csm_xy (wks, x, y, res)                  ; create plot
  
;**********************************************************
; add text labels
;**********************************************************  
  txres                     = True                 ; text mods desired
  txres@txFontHeightF       = 0.02                ; default size is HUGE!
  txres@txAngleF            = 50.                  ; text angle
  txres@txJust              = "CenterLeft"         ; puts text on top of bars
  
  do n = 1, 8
    gsn_text (wks, plot, labels(n-1), n, y(n-1) + 1500, txres) ; add labels
  end do
  frame (wks)
;**********************************************************
; create second plot
;**********************************************************  
  res@tiYAxisString = "Moisture transfer rate (mm / day)"
;  plot = gsn_csm_xy (wks,x,y,res)
;**********************************************************
; add labelbar to second plot
;********************************************************** 
  getvalues plot                ; get plot size for use in creating labelbar
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpHeightF" : vph
  "vpWidthF"  : vpw
  end getvalues

  lbw    = 0.4 * vpw           ; Make labelbar size a fraction of the plot.
  lbh    = 0.5 * vph
  nboxes = dimsizes (res@gsnXYBarChartColors)
   
  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.4 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = res@gsnXYBarChartColors ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.008         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
   
;  gsn_labelbar_ndc (wks,nboxes,labels,vpx+vph-lbw,0.77,lbres)
   
;  frame(wks)

end
