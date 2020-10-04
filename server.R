shiny::shinyServer(
	function(
		input,
		output,
		session
	)
	{
		currentPrediction <- shiny::eventReactive(
			input$calculatePredictionButton,
			{
				prediction <- calculateRisk(
					age = input$age,
					rr = input$respiratoryAge,
					saturation = input$oxygenSaturation,
					crp = input$crp,
					ldh = input$ldh,
					leucocytes = input$leucocyteCount,
					baselineHazard = baselineHazard,
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
		
		# prediction <- shiny::eventReactive(
		# 	input$calculatePredictionButton,
		# 	{
		# 		currentPrediction()
		# 	}
		# )
		
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
						type = "bar"
					) %>%
					plotly::add_text(
						text = ~paste(
							y,
							"%"
						),
						hoverinfo = "none",
						textposition = "top",
						showlegend = FALSE,
						textfont = list(
							size = 20,
							color = "black"
						)
					) %>%
					plotly::layout(
						shapes = list(
							# hline(
							# 	fifth1,
							# 	color = "green"
							# ),
							# hline(
							# 	fifth2,
							# 	color = "yellow"
							# ),
							# hline(
							# 	fifth3,
							# 	color = "orange"
							# ),
							# hline(
							# 	fifth4,
							# 	color = "red"
							# ),
							addRectangle(
								y0 = 0,
								y1 = fifth1,
								fillcolor = "green"
							),
							addRectangle(
								y0 = fifth1,
								y1 = fifth2,
								fillcolor = "yellow"
							),
							addRectangle(
								y0 = fifth2,
								y1 = fifth3,
								fillcolor = "orange"
							),
							addRectangle(
								y0 = fifth3,
								y1 = fifth4,
								fillcolor = "red"
							),
							addRectangle(
								y0 = fifth4,
								y1 = 30,
								fillcolor = "purple"
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
		
	}
)