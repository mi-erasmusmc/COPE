shiny::shinyServer(
	function(
		input,
		output,
		session
	) {
		currentPrediction <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				prediction <- calculateRisk(
					age              = input$age,
					rr               = input$respiratoryRate,
					crp              = input$crp,
					ldh              = input$ldh,
					baselineHazard   = baselineHazard,
					betaCoefficients = betaCoefficients
				)
				
				return(prediction)
			}
		)
		
		riskFifthMortality <- shiny::reactive(
			{
				fifthsMortality <- fifths$mortality
				prediction <- currentPrediction()
				
				riskFifths <- c(
					0,
					fifthsMortality[1],
					fifthsMortality[2],
					fifthsMortality[3],
					fifthsMortality[4],
					100,
					prediction$mortality
				)
				
				return(rank(riskFifths)[7])
			}
		)
		
		riskFifthIcu <- shiny::reactive(
			{
				fifthsIcu <- fifths$icu
				prediction <- currentPrediction()
				

				
				riskFifths <- c(
					0,
					fifthsIcu[1],
					fifthsIcu[2],
					fifthsIcu[3],
					fifthsIcu[4],
					100,
					prediction$icu
				)
				
				return(rank(riskFifths)[7])
			}
		)
		
		output$calculationPlotMortality <- plotly::renderPlotly(
			{
				prediction <- currentPrediction()
				
				rangeMax <- ifelse(
					test = prediction$icu > 25 || prediction$mortality > 25,
					yes  = 100,
					no   = 30
				)
				
				predictionData <- data.frame(
					x = 1,
					y = prediction$mortality
				)
				
				plotRiskPrediction(
					predictionData = predictionData,
					fifths         = fifths$mortality,
					riskFifth      = riskFifthMortality(),
					colorMap       = colorMap,
					title          = "Mortality",
					rangeMax       = rangeMax
				)
				
			}
		)
		
		output$calculationPlotIcu <- plotly::renderPlotly(
			{
				prediction <- currentPrediction()
				
				rangeMax <- ifelse(
					test = prediction$icu > 25 || prediction$mortality > 25,
					yes  = 100,
					no   = 30
				)
				
				predictionData <- data.frame(
					x = 1,
					y = prediction$icu
				)
				
				plotRiskPrediction(
					predictionData = predictionData,
					fifths         = fifths$icu,
					riskFifth      = riskFifthIcu(),
					colorMap       = colorMap,
					title          = "ICU",
					rangeMax       = rangeMax
				)
				
			}
		)
		
		output$resultExplanationBox <- shiny::renderText(
			{
				"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dolor sed viverra ipsum nunc aliquet bibendum enim. Aenean vel elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi. Ut tristique et egestas quis ipsum. Vel pretium lectus quam id leo in. Nullam ac tortor vitae purus faucibus. Nisl vel pretium lectus quam id. Ultrices mi tempus imperdiet nulla malesuada. Sed risus ultricies tristique nulla aliquet enim tortor. Quam lacus suspendisse faucibus interdum. Est ante in nibh mauris cursus. Non sodales neque sodales ut etiam sit amet nisl purus."
			}
		)
		
		output$table1 <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data     = table1Long,
					colnames = c(
						"Status",
						"Variable",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					),
					options = list(
						pageLength = 6
					)
				)
				
				return(table)
			}
		)
		
		output$calibrationMortalityCenter1 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[1]],
					fifths = fifths$mortality,
					colorMap = colorMap
				)
			}
		)
		output$calibrationMortalityCenter2 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[2]],
					fifths = fifths$mortality,
					colorMap = colorMap
				)
			}
		)
		output$calibrationMortalityCenter3 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[3]],
					fifths = fifths$mortality,
					colorMap = colorMap
				)
			}
		)
		output$calibrationMortalityCenter4 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[4]],
					fifths = fifths$mortality,
					colorMap = colorMap
				)
			}
		)
	}
)