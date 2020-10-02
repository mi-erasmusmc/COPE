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
				plotResult <- plotly::plot_ly(
					x = "Mortality",
					y = currentPrediction(),
					type = "bar"
				) %>%
					plotly::layout(
						yaxis = list(
							title = "",
							range = c(
								0,
								.4
							)
						)
						
					) %>%
					plotly::layout(
						shapes = list(
							hline(
								fifth1,
								color = "green"
							),
							hline(
								fifth2,
								color = "yellow"
							),
							hline(
								fifth3,
								color = "orange"
							),
							hline(
								fifth4,
								color = "red"
							)
						)
					) %>%
					plotly::layout(
						shapes=list(
							list(
								type=rect, 
								x0=0, 
								x1=2, 
								y0=0, 
								y1=fifth1, 
								fillcolor='orange', 
								layer='below'
							)
						)
					)
			}
		)
		
		output$probabilityBox <- shinydashboard::renderValueBox(
			{
				shinydashboard::valueBox(
					tagList(
						100*currentPrediction(),
						tags$sup(
							style="font-size: 20px", "%"
						)
					),
					"Calculated risk",
					icon("calculator")
				)
			}
		)
		
		output$resultExplanationBox <- shiny::renderText(
			{
				"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dolor sed viverra ipsum nunc aliquet bibendum enim. Aenean vel elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi. Ut tristique et egestas quis ipsum. Vel pretium lectus quam id leo in. Nullam ac tortor vitae purus faucibus. Nisl vel pretium lectus quam id. Ultrices mi tempus imperdiet nulla malesuada. Sed risus ultricies tristique nulla aliquet enim tortor. Quam lacus suspendisse faucibus interdum. Est ante in nibh mauris cursus. Non sodales neque sodales ut etiam sit amet nisl purus."
			}
		)
	}
)