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
				predictionData <- data.frame(
					x = 1,
					y = prediction$mortality
				)
				
				plotRiskPrediction(
					predictionData = predictionData,
					fifths         = fifths$mortality,
					riskFifth      = riskFifthMortality(),
					colorMap       = colorMap,
					title          = "Mortality"
				)
				
			}
		)
		
		output$calculationPlotIcu <- plotly::renderPlotly(
			{
				prediction <- currentPrediction()
				predictionData <- data.frame(
					x = 1,
					y = prediction$icu
				)
				
				plotRiskPrediction(
					predictionData = predictionData,
					fifths         = fifths$icu,
					riskFifth      = riskFifthIcu(),
					colorMap       = colorMap,
					title          = "ICU"
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
		
		output$calibrationPlot <- plotly::renderPlotly( {
			plotly::plot_ly(data = calibrationData) %>%
				plotly::add_trace(
					x     = c(0, .5), 
					y     = c(0, .5),
					mode  = 'lines',
					line  = list(dash = "dash"),
					color = I('black'),
					type  = 'scatter'
				) %>%
				plotly::add_trace(
					data    = calibrationData,
					x       = ~predicted,
					y       = ~observed,
					type    = "scatter",
					marker  = list(color = "blue"),
					error_y = list(
						type       = "data",
						array      = calibrationData$upper - calibrationData$observed,
						arrayminus = calibrationData$observed - calibrationData$lower,
						color      = "blue"
					)
				) %>%
				plotly::layout(
					shapes = list(
						addRectangle(
							x0        = 0,
							x1        = fifth1 / 100,
							y0        = 0,
							y1        = .5,
							fillcolor = colorMap$color[1]
						),
						addRectangle(
							x0        = fifth1 / 100,
							x1        = fifth2 / 100,
							y0        = 0,
							y1        = .5,
							fillcolor = colorMap$color[2]
						),
						addRectangle(
							x0        = fifth2 / 100,
							x1        = fifth3 / 100,
							y0        = 0,
							y1        = .5,
							fillcolor = colorMap$color[3]
						),
						addRectangle(
							x0        = fifth3 / 100,
							x1        = fifth4 / 100,
							y0        = 0,
							y1        = .5,
							fillcolor = colorMap$color[4]
						),
						addRectangle(
							x0        = fifth4 / 100,
							x1        = .5,
							y0        = 0,
							y1        = .5,
							fillcolor = colorMap$color[5]
						)
					),
					title = "External validation",
					xaxis = list(
						title = "Predicted 21-day mortality",
						range = c(-.01, .5)
					),
					yaxis = list(
						title = "Observed 21-day mortality",
						range = c(-.01, .5)
					),
					showlegend = FALSE
				)
		} )
	}
)