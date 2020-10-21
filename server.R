shiny::shinyServer(
	function(
		input,
		output,
		session
	) {
		observe({
			shinyalert::shinyalert(
				"Disclaimer", 
				shiny::includeHTML("html/disclaimer.html"),
				type = "info",
				html = TRUE,
				size = "m",
			)	
		}) 
		
		currentInputData <- shiny::reactive(
			{
				data.frame(
					time            = 4,
					age             = input$age,
					respiratoryRate = input$respiratoryRate,
					crp             = input$crp,
					ldh             = input$ldh
				)
			}
		)
		
		mortalityLinearPredictor <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				modelMatrix <- createModelMatrix(
					covariates      = currentInputData(),
					transformations = transformationsMortality
				)
				
				createLinearPredictor(
					modelMatrix = modelMatrix,
					beta        = betaCoefficients$mortality
				)
			}
		)
		
		currentPrediction <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				
				mortalityRisk <- survivalProbability(
					baselineHazard  = baselineHazard$mortality,
					linearPredictor = mortalityLinearPredictor(),
					center          = 13.13958
				)
				
				icuLinearPredictor <- betaCoefficients$icu * (mortalityLinearPredictor() - 13.13958)
				
				icuRisk <- survivalProbability(
					baselineHazard  = baselineHazard$icu,
					linearPredictor = icuLinearPredictor,
					center          = -.8952993 
				)
				
				prediction <- list(
					mortality = mortalityRisk,
					icu       = icuRisk
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
					test = prediction$icu > 30 || prediction$mortality > 30, 
					yes  = 60,
					no   = 35
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
					rangeMax       = rangeMax
				)
				
			}
		)
		
		output$calculationPlotIcu <- plotly::renderPlotly(
			{
				prediction <- currentPrediction()
				
				rangeMax <- ifelse(
					test = prediction$icu > 30 || prediction$mortality > 30,
					yes  = 60,
					no   = 35
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
					rangeMax       = rangeMax
				)
				
			}
		)
		
		output$resultExplanationBox <- shiny::renderText(
			{
				prediction <- currentPrediction()
				riskLevelLabels <- c(
					"very low",
					"low",
					"intermediate",
					"high",
					"very high"
				)
				
				paste(
					shiny::includeHTML("html/calculation_result_explanation1.html"),
					shiny::HTML(paste0(prediction$mortality, "%.")),
					shiny::includeHTML("html/calculation_result_explanation2.html"),
					shiny::HTML(riskLevelLabels[riskFifthMortality() - 1]),
					shiny::includeHTML("html/calculation_result_explanation3.html"),
					shiny::HTML("<br/><br/>"),
					shiny::includeHTML("html/calculation_result_explanation4.html"),
					shiny::HTML(paste0(prediction$icu, "%.")),
					shiny::includeHTML("html/calculation_result_explanation2.html"),
					shiny::HTML(riskLevelLabels[riskFifthIcu() - 1]),
					shiny::includeHTML("html/calculation_result_explanation6.html")
				)
			}
		)
		
		output$table1 <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data     = table1Long,
					colnames = c(
						"Status at 21 days",
						"Variable",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					),
					caption = htmltools::tags$caption(
						style = 'font-size:16px;',
						"Table 1: Key patient characteristics at the moment
					of prediction. For all patients (N=4612), the results are displayed
					first. By hitting \"Next\", you can view the characteristics of 
					3 sub-populations of interest: ",
						htmltools::em("Dead"),
						"at 21 days (N=495),",
						htmltools::em("Discharged"),
						"(N=3632) at 21 days and ",
						htmltools::em("In hospital"),
						"(N=485) at 21 days."
					),
					options = list(
						pageLength = 13
					)
				)
				
				return(table)
			}
		)
		
		output$calibrationMortalityCenter1 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[1]],
					fifths          = fifths$mortality,
					colorMap        = colorMap,
					a               = calibrationIntercept$mortality[1],
					b               = calibrationSlope$mortality[1],
					c               = auc$mortality[1]
				)
			}
		)
		output$calibrationMortalityCenter2 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[2]],
					fifths          = fifths$mortality,
					colorMap        = colorMap,
					a               = calibrationIntercept$mortality[2],
					b               = calibrationSlope$mortality[2],
					c               = auc$mortality[2]
				)
			}
		)
		output$calibrationMortalityCenter3 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[3]],
					fifths          = fifths$mortality,
					colorMap        = colorMap,
					a               = calibrationIntercept$mortality[3],
					b               = calibrationSlope$mortality[3],
					c               = auc$mortality[3]
				)
			}
		)
		output$calibrationMortalityCenter4 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$mortality[[4]],
					fifths          = fifths$mortality,
					colorMap        = colorMap,
					a               = calibrationIntercept$mortality[4],
					b               = calibrationSlope$mortality[4],
					c               = auc$mortality[4]
				)
			}
		)
	}
)