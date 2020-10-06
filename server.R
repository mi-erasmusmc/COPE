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
					rr               = input$respiratoryAge,
					saturation       = input$oxygenSaturation,
					crp              = input$crp,
					ldh              = input$ldh,
					leucocytes       = input$leucocyteCount,
					baselineHazard   = baselineHazard,
					betaCoefficients = betaCoefficients
				)
				
				return(
					round(
						prediction,
						4
					)
				)
			}
		)
		
		riskFifth <- shiny::reactive(
			{
				riskFifths <- c(
					0,
					fifth1,
					fifth2,
					fifth3,
					fifth4,
					100,
					currentPrediction()
				)
				
				return(rank(riskFifths)[7])
			}
		)
		
		output$calculationPlot <- plotly::renderPlotly(
			{
				plotData <- data.frame(
					x = 1,
					y = currentPrediction()
				)
				
				plotData %>%
					plotly::plot_ly(
						x = ~x,
						y = ~y,
						type = "bar",
						marker = list(
							line = list(
								width = 2,
								color = "black"
							)
						)
					) %>%
					plotly::add_annotations(
						text = ~paste(
							y,
							"%"
						),
						bgcolor     = colorMap$color[riskFifth() - 1],
						bordercolor = "black",
						borderwidth = 1,
						showarrow   = FALSE,
						standoff    = 4,
						hoverinfo   = "none",
						showlegend  = FALSE,
						font        = list(
							size = 18,
							color = "black"
						)
					) %>%
					plotly::layout(
						shapes = list(
							hline(
								fifth1,
								color = "black"
							),
							hline(
								fifth2,
								color = "black"
							),
							hline(
								fifth3,
								color = "black"
							),
							hline(
								fifth4,
								color = "black"
							),
							addRectangle(
								x0        = 0,
								x1        = 2,
								y0        = 0,
								y1        = fifth1,
								fillcolor = colorMap$color[1]
							),
							addRectangle(
								x0        = 0,
								x1        = 2,
								y0        = fifth1,
								y1        = fifth2,
								fillcolor = colorMap$color[2]
							),
							addRectangle(
								x0        = 0,
								x1        = 2,
								y0        = fifth2,
								y1        = fifth3,
								fillcolor = colorMap$color[3]
							),
							addRectangle(
								x0        = 0,
								x1        = 2,
								y0        = fifth3,
								y1        = fifth4,
								fillcolor = colorMap$color[4]
							),
							addRectangle(
								x0        = 0,
								x1        = 2,
								y0        = fifth4,
								y1        = 30,
								fillcolor = colorMap$color[5]
							)
						),
						yaxis = list(
							title = "",
							range = c(
								0,
								30
							)
						),
						xaxis = list(
							title = ""
						)
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
					type  ='scatter'
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