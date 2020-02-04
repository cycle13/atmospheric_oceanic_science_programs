; compare_precipitation_model_observations.ncl

begin

  start_lat_deg_N = 0
  stop_lat_deg_N = 40

  start_lon_deg_E = 40
  stop_lon_deg_E = 100

  model_file = addfile ("/Vol2/sarthak/programs/result_data_avg_precipitation_JJAS_2009to2025_0to40N_40to100E_CFSv2_model.nc", "r")

  observations_file = addfile ("/Vol2/sarthak/programs/result_data_avg_precipitation_JJAS_1998to2014_0to40N_40to100E_TRMM_observations.nc", "r")

  model_lat = model_file->latitude
  model_lon = model_file->longitude
  obs_lat = observations_file->latitude
  obs_lon = observations_file->longitude

  t_UTC = "00"

  pcp_model_lores_D2_mmperhour = model_file->average_precipitation_00UTC_JJAS_2009_2025_D2_mmperhour ( {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )

  printVarSummary (pcp_model_lores_D2_mmperhour)
  printMinMax (pcp_model_lores_D2_mmperhour, 0)

  pcp_obs_hires_D2_mmperhour = observations_file->avg_pcp_00UTC_JJAS_1998_2014_D2_mmperhour ( {start_lat_deg_N : stop_lat_deg_N}, {start_lon_deg_E : stop_lon_deg_E} )

  printVarSummary (pcp_obs_hires_D2_mmperhour)
  printMinMax (pcp_obs_hires_D2_mmperhour, 0)

  opt = True
  opt@critpc = 75

  pcp_obs_lores_D2_mmperhour = area_hi2lores_Wrap (obs_lon, obs_lat, pcp_obs_hires_D2_mmperhour, False, 1, model_lon, model_lat, opt)

  printVarSummary (pcp_obs_lores_D2_mmperhour)
  printMinMax (pcp_obs_lores_D2_mmperhour, 0)

  pcp_diff_model_obs_D2_mmperhour = pcp_model_lores_D2_mmperhour - pcp_obs_lores_D2_mmperhour

  pcp_diff_model_obs_D2_mmperhour!0 = "latitude"
  pcp_diff_model_obs_D2_mmperhour!1 = "longitude"
  pcp_diff_model_obs_D2_mmperhour&latitude = model_lat
  pcp_diff_model_obs_D2_mmperhour&longitude = model_lon
  pcp_diff_model_obs_D2_mmperhour@units = "mm/hour"
  pcp_diff_model_obs_D2_mmperhour@long_name = "Precipitation difference (CFSv2 model - TRMM observation)"

  printVarSummary (pcp_diff_model_obs_D2_mmperhour)
  printMinMax (pcp_diff_model_obs_D2_mmperhour, 0)

  wks = gsn_open_wks ("ps", "plot_difference_avg_precipitation_model_obs_" + t_UTC + "UTC_0-40N_40-100E_JJAS_2009-2025") ; Open a workstation.

  res = True
  res@gsnDraw = True
  res@gsnFrame = True
  res@cnLevelSelectionMode = "ManualLevels"     ; Manual contour levels.
  res@cnFillOn = True                    ; Turn on colour.
  res@cnLinesOn = False
res@cnLineLabelsOn = False 
  res@gsnAddCyclic = False
  res@cnFillMode = "CellFill"
  res@mpFillOn = True
  cmap = read_colormap_file ("testcmap")
  res@cnFillPalette = cmap
res@mpOutlineOn           =  True
res@mpOutlineDrawOrder    =  "PostDraw"
res@mpDataBaseVersion    = "MediumRes"
res@mpFillOn = True
res@mpPerimOn = False
res@mpLandFillColor =   -1
res@mpFillDrawOrder =   "PostDraw"
;res@vpWidthF    =  .45
;res@vpHeightF   =  0.1
res@vpXF =  0.3                
;res@vpYF =  0.9         
res@gsnPaperOrientation  =  "landscape"
res@gsnStringFontHeightF  =  0.008
res@lbLabelBarOn    =  True
res@tmXTOn =  False
res@tmYROn =  False
res@pmTickMarkDisplayMode  =  "always"
res@pmTickMarkZone  = 5
;res@tmXBOn    =  True
;res@tmYLOn    =  True
res@gsnAddCyclic = False
res@tmXBMinorOn  = True
res@tmYLMinorOn  = True
res@tmYLBorderOn = True
res@tmYRBorderOn = True
res@tmXBBorderOn = True
res@tmXTBorderOn = True
res@tmBorderThicknessF = 2.0
res@gsnCenterString =  ""
res@gsnRightString =  ""
res@gsnCenterString =  ""
res@tmYLMajorLengthF = 0.01
res@tmXBMajorLengthF = 0.01
res@gsnLeftString =  ""
res@gsnStringFont = 26
res@gsnStringFontHeightF = 0.02
res@tmXBLabelFont = 26
res@tmYLLabelFont = 26
;res@mpGridLineThicknessF = 1
res@tmXBLabelFontHeightF  = 0.02
res@tmYLLabelFontHeightF  = 0.02
res@lbLabelFontThicknessF =  1
res@lbLabelAutoStride =  True
res@pmLabelBarOrthogonalPosF=  0.02
res@pmLabelBarWidthF      =   0.04
res@pmLabelBarHeightF      =   0.3
res@lbOrientation         =  "Vertical"
res@lbBoxEndCapStyle = "TriangleBothEnds"
res@lbBoxLineDashSegLenF = 0.5
res@lbBoxLineThicknessF = 0.5
res@lbLabelFont = 26
res@lbLabelFontHeightF = 0.01
res@lbRasterFillOn  = True
res@lbLabelStride  = 2
res@lbBoxLinesOn  = True
res@lbBoxLineDashPattern = 16
res@lbBoxMajorExtentF = 0.7

  res@cnMinLevelValF = - 1.0
  res@cnMaxLevelValF = 1.0
  res@cnLevelSpacingF  =  0.1
  res@gsnCenterString = " Prec difference : Model and Obs"
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res@mpMinLatF = start_lat_deg_N    ; Range to zoom in on.
  res@mpMaxLatF = stop_lat_deg_N        
  res@mpMinLonF = start_lon_deg_E       
  res@mpMaxLonF = stop_lon_deg_E

  plot = gsn_csm_contour_map (wks, pcp_diff_model_obs_D2_mmperhour, res)

  delete (model_file)
  delete (observations_file)

end
