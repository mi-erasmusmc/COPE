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
					x = "Mortality",
					y = currentPrediction()
				)
				
				plotData %>%
					plotly::plot_ly(
						x = ~x,
						y = ~y,
						type = "bar",
						opacity = .8
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
		
		output$table1Overall <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data = table1$overall,
					colnames = c(
						"",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					)
				)
			}
		)
		
		output$table1Discharged <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data = table1$discharged,
					colnames = c(
						"",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					)
				)
			}
		)
		output$table1InHospital <- DT::renderDataTable(
			{
				table <- DT::datatable(
					data = table1$hospital,
					colnames = c(
						"",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					)
				)
			}
		)
		output$table1Dead<- DT::renderDataTable(
			{
				table <- DT::datatable(
					data = table1$dead,
					colnames = c(
						"",
						"Mean",
						"SD",
						"Median",
						"Min",
						"Max",
						"Missing",
						"%"
					)
				)
			}
		)
	}
)