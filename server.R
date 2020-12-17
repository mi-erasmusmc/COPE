shiny::shinyServer(
	function(
		input,
		output,
		session
	) {
		
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
		admissibleInput <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				is.numeric(input$age) &&
					is.numeric(input$respiratoryRate) &&
					is.numeric(input$ldh) &&
					is.numeric(input$crp) &&
					data.table::between(input$age, 0, 100) &&
					data.table::between(input$respiratoryRate, 10, 60) &&
					data.table::between(input$ldh, 100, 1000) &&
					data.table::between(input$crp, 1, 400)
			}
		)
		
		shiny::observeEvent(
			input$calculatePredictionButton,
			{
				if (!admissibleInput()) {
					shinyalert(
						title = "Non-admissible input",
						shiny::includeHTML("html/admissibleInput.html"),
						type = "error",
						html = TRUE,
						size = "m",
					)
				}
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
				mortalityRisk <- logisticProbability(
					intercept = intercepts$mortality,
					linearPredictor = mortalityLinearPredictor()
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
		
		output$calculationPlotMortality <- highcharter::renderHighchart(
			{
				shiny::req(admissibleInput())
				
				prediction <- currentPrediction()
				cols       <- c(rev(colorMap$color), "#3B6AA0")
				riskFifth  <- riskFifthMortality()
				
				maxRisk   <- max(prediction$mortality, prediction$icu)
				test      <- c( 5, 10, 20, 30, 50, 100)
				threshold <- c(10, 20, 30, 40, 60, 100)
				rangeMax  <- min(threshold[maxRisk < test])
				
				plotRiskPrediction(
					prediction       = prediction$mortality,
					colorMap         = colorMap,
					currentRiskFifth = riskFifth,
					riskFifths       = fifths$mortality,
					rangeMax         = rangeMax
				)
				
			}
		)
		
		output$titleMortalityRiskBox <- shiny::renderPrint(
			{
				shiny::req(admissibleInput())
				shiny::HTML(
					cat(
						"<p>Death within 21 days: <b>",
						currentPrediction()$mortality,
						"%</b>"
					),
					"</p>"
				)
			}
		)
		
		output$titleIcuRiskBox <- shiny::renderPrint(
			{
				shiny::req(admissibleInput())
				shiny::HTML(
					cat(
						"<p>ICU admission within 21 days: <b>",
						currentPrediction()$icu,
						"%</b>"
					),
					"</p>"
				)
			}
		)
		
		output$calculationPlotIcu <- highcharter::renderHighchart(
			{
				shiny::req(
					admissibleInput()
				)
				
				prediction <- currentPrediction()
				cols <- c(rev(colorMap$color), "#3B6AA0")
				riskFifth <- riskFifthIcu()
				
				maxRisk <- max(prediction$mortality, prediction$icu)
				test      <- c( 5, 10, 20, 30, 50, 100)
				threshold <- c(10, 20, 30, 40, 60, 100)
				rangeMax  <- min(threshold[maxRisk < test])
				
				plotRiskPrediction(
					prediction = prediction$icu,
					colorMap = colorMap,
					currentRiskFifth = riskFifth,
					riskFifths = fifths$icu,
					rangeMax = rangeMax
				)
			}
		)
		
		output$resultExplanationBox <- shiny::renderText(
			{
				shiny::req(
					admissibleInput()
				)
				
				prediction <- currentPrediction()
				riskLevelLabels <- c(
					"lowest",
					"lower",
					"intermediate",
					"higher",
					"highest"
				)
				
				paste(
					shiny::includeHTML("html/calculation_result_explanation1.html"),
					shiny::HTML(paste0(prediction$mortality, "%.")),
					shiny::includeHTML("html/calculation_result_explanation2.html"),
					shiny::HTML(riskLevelLabels[riskFifthMortality() - 1]),
					shiny::includeHTML("html/calculation_result_explanation3.html"),
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
					outcome         = "mortality",
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
					outcome         = "mortality",
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
					outcome         = "mortality",
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
					outcome         = "mortality",
					a               = calibrationIntercept$mortality[4],
					b               = calibrationSlope$mortality[4],
					c               = auc$mortality[4]
				)
			}
		)
		
		output$calibrationIcuHospital1 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$icu[[1]],
					fifths          = fifths$icu,
					colorMap        = colorMap,
					outcome         = "ICU admission",
					a               = calibrationIntercept$icu[1],
					b               = calibrationSlope$icu[1],
					c               = auc$icu[1]
				)
			}
		)
		
		output$calibrationIcuHospital3 <- plotly::renderPlotly(
			{
				plotCalibration(
					calibrationData = calibration$icu[[2]],
					fifths          = fifths$icu,
					colorMap        = colorMap,
					outcome         = "ICU admission",
					a               = calibrationIntercept$icu[2],
					b               = calibrationSlope$icu[2],
					c               = auc$icu[2]
				)
			}
		)
		
		output$disclaimer <- shiny::renderText(
			shiny::includeHTML("html/disclaimer.html")
		)
	}
)