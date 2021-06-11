shiny::shinyServer(
	function(
		input,
		output,
		session
	) {
		
		currentInputData <- shiny::reactive(
			{
				data.frame(
					age             = input$age,
					respiratoryRate = input$respiratoryRate,
					crp             = input$crp,
					ldh             = input$ldh,
					albumin         = input$albumin,
					urea            = input$urea
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
					is.numeric(input$albumin) &&
					is.numeric(input$urea) &&
					data.table::between(input$age, 0, 100) &&
					data.table::between(input$respiratoryRate, 10, 60) &&
					data.table::between(input$ldh, 50, 4000) &&
					data.table::between(input$crp, 1, 500) &&
					data.table::between(input$albumin, 10, 60) &&
					data.table::between(input$urea, 1, 80)
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
					beta        = betaCoefficients$mortality,
					intercept   = intercepts$mortality
				)
			}
		)
		
		currentPrediction <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				mortalityRisk <- logisticProbability(
					linearPredictor = mortalityLinearPredictor()
				)
				
				icuLinearPredictor <- betaCoefficients$icu * (mortalityLinearPredictor()) +
					intercepts$icu
				
				icuRisk <- logisticProbability(
					linearPredictor = icuLinearPredictor
				)
				
				prediction <- list(
					mortality = as.vector(mortalityRisk),
					icu       = as.vector(icuRisk)
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
		
		output$manual <- downloadHandler(
			filename = "manual.pdf",
			content = function(file) {
				file.copy("www/manual.pdf", file)
			}
		)
		
		output$calculationPlotMortality <- plotly::renderPlotly(
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
						"<p>Death within 28 days: <b>",
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
						"<p>ICU admission within 28 days: <b>",
						currentPrediction()$icu,
						"%</b>"
					),
					"</p>"
				)
			}
		)
		
		output$calculationPlotIcu <- plotly::renderPlotly(
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
		
		output$developmentTable1 <- DT::renderDataTable( {
			table <- DT::datatable(
				data     = develTab1Long,
				colnames = c(
					"Status at 28 days",
					"Variable",
					"N",
					"Missing",
					"%",
					"Mean",
					"SD",
					"Min",
					"1st quartile",
					"Median",
					"3rd quartile",
					"Max"
				),
				caption = htmltools::tags$caption(
					style = 'font-size:16px;',
					"Table: Baseline characteristics of development patient cohort.
				Status, \"Overall\", \"Discharged\",\"In hospital\" and
				\"Dead\" is measured at 28 days after hospital admission"
				),
				options = list(
					pageLength   = 22,
					lengthChange = FALSE
				)
			) %>%
				DT::formatRound(
					columns = 5:12,
					digits  = 2
				)
			
			return(table)
		} )
		
		output$validationTable1 <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data     = validationTab1Long,
					colnames = c(
						"Status at 28 days", "Variable", "N",
						"Missing", "%", "Mean", "SD", "Min",
						"1st quartile", "Median", "3rd quartile", "Max"
					),
					caption = htmltools::tags$caption(
						style = 'font-size:16px;',
						"Table: Baseline characteristics of validation patient cohort.
				Status, \"Overall\", \"Discharged\",\"In hospital\" and
				\"Dead\" is measured at 28 days after hospital admission"
					),
					options = list(
						pageLength   = 22,
						lengthChange = FALSE
					)
				) %>%
					DT::formatRound(
						columns = 5:12,
						digits = 2
					)
				
				return(table)
			}
		)
		
		output$calibrationMortalityOverall <- plotly::renderPlotly(
			{
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 0,
					center               = 0
				)
				
				plotCalibration(
					calibrationData = calibration$mortality[[5]],
					fifths          = quantiles,
					colorMap        = colorMap,
					outcome         = "mortality",
					a               = calibrationIntercept$mortality[5],
					b               = calibrationSlope$mortality[5],
					c               = auc$mortality[5]
				)
			}
		)
		
		output$calibrationIcuOverall <- plotly::renderPlotly(
			{
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 1,
					center               = 0
				)
				plotCalibration(
					calibrationData = calibration$icu[[3]],
					fifths          = quantiles,
					colorMap        = colorMap,
					outcome         = "ICU admisison",
					a               = calibrationIntercept$icu[3],
					b               = calibrationSlope$icu[3],
					c               = auc$icu[3]
				)
			}
		)
		
		output$calibrationMortalityCenter1 <- plotly::renderPlotly(
			{
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 0,
					center               = 1
				)
				plotCalibration(
					calibrationData = calibration$mortality[[1]],
					fifths          = quantiles,
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
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 0,
					center               = 2
				)
				plotCalibration(
					calibrationData = calibration$mortality[[2]],
					fifths          = quantiles,
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
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 0,
					center               = 3
				)
				plotCalibration(
					calibrationData = calibration$mortality[[3]],
					fifths          = quantiles,
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
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 0,
					center               = 4
				)
				plotCalibration(
					calibrationData = calibration$mortality[[4]],
					fifths          = quantiles,
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
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 1,
					center               = 1
				)
				plotCalibration(
					calibrationData = calibration$icu[[1]],
					fifths          = quantiles,
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
				quantiles <- extractQuantiles(
					calibrationQuantiles = calibrationQuantiles,
					outcome              = 1,
					center               = 3
				)
				plotCalibration(
					calibrationData = calibration$icu[[2]],
					fifths          = quantiles,
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