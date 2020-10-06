shiny::shinyUI(
	shinydashboard::dashboardPage(
		skin      = "black",
		title     = "ED-COVID",
		shinydashboard::dashboardHeader(
			title = "Main title",
			tags$li(
				div(
					img(
						src    = 'logo_erasmus.png',
						title  = "Erasmus MC", 
						height = "46", 
						width  = "110px"
					),
					style = "padding-top:2px; padding-bottom:0px; padding-right:8px"
				),
				class = "dropdown"
			)
		),
		shinydashboard::dashboardSidebar(
			shinydashboard::sidebarMenu(
				id = "menu1",
				shinydashboard::menuItem(
					tabName = "calculation",
					text    = "Calculate risk",
					icon    = shiny::icon("calculator")
				),
				shinydashboard::menuItem(
					tabName = "description",
					text    = "Description",
					icon    = shiny::icon("align-justify")
				),
				shinydashboard::menuItem(
					tabName = "population",
					text    = "Population",
					icon    = shiny::icon("users")
				),
				shinydashboard::menuItem(
					tabName = "model",
					text    = "Model",
					icon    = shiny::icon("clipboard")
				),
				shinydashboard::menuItem(
					tabName = "performance",
					text    = "Performance",
					icon    = shiny::icon("tasks")
				)
			)
		),
		shinydashboard::dashboardBody(
			shinydashboard::tabItems(
				shinydashboard::tabItem(
					tabName = "description",
					shiny::includeHTML(
						"html/description_text.html"
					)
				),
				shinydashboard::tabItem(
					tabName = "calculation",
					shiny::fluidRow(
						shinydashboard::box(
							status = "primary",
							width  = 12,
							shiny::splitLayout(
								shinyBS::popify(
									shiny::numericInput(
										inputId = "age",
										label   = "Age",
										value   = 75,
										min     = 20,
										max     = 100
									),
									title   = "<b>Age</b>",
									content = shiny::includeHTML(
										path = "html/calculation_age.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								),
								shinyBS::popify(
									shiny::numericInput(
										inputId = "respiratoryAge",
										label   = "Respiratory age",
										value   = 30,
										min     = 0,
										max     = 100
									),
									title   = "<b>Respiratory age</b>",
									content = shiny::includeHTML(
										path = "html/calculation_respiratoryAge.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								),
								shinyBS::popify(
									shiny::numericInput(
										inputId = "oxygenSaturation",
										label   = "Oxygen saturation",
										value   = 100,
										min     = 80,
										max     = 100
									),
									title   = "<b>Oxygen saturation</b>",
									content = shiny::includeHTML(
										path = "html/calculation_oxygenSaturation.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								)
							),
							shiny::splitLayout(
								shinyBS::popify(
									shiny::numericInput(
										inputId = "ldh",
										label   = "LDH",
										value   = 5,
										min     = 0,
										max     = 100
									),
									title   = "<b>LDH</b>",
									content = shiny::includeHTML(
										path = "html/calculation_ldh.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								),
								shinyBS::popify(
									shiny::numericInput(
										inputId = "crp",
										label   = "CRP",
										value   = 2,
										min     = 20,
										max     = 100
									),
									title   = "<b>CRP</b>",
									content = shiny::includeHTML(
										path = "html/calculation_crp.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								),
								shinyBS::popify(
									shiny::numericInput(
										inputId = "leucocyteCount",
										label   = "Leucocyte count",
										value   = 50,
										min     = 20,
										max     = 100
									),
									title   = "<b>Leucocyte count",
									content = shiny::includeHTML(
										"html/calculation_leucocyteCount.html"
									),
									placement = "bottom",
									options   = list(
										container = "body"
									)
								)
							),
							shiny::actionButton(
								inputId = "calculatePredictionButton",
								label   = "Calculate",
								icon    = shiny::icon("calculator")
							)
						)
					),
					shiny::conditionalPanel(
						condition = "input.calculatePredictionButton",
						shinydashboard::box(
							status = "primary",
							title  = "Risk prediction",
							width  = 4,
							height = "470px",
							plotly::plotlyOutput(
								outputId = "calculationPlot"
							)
						),
						shinydashboard::box(
							status = "primary",
							title  = "Result explanation",
							width  = 8,
							height = "470px",
							textOutput(
								outputId = "resultExplanationBox"
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "population",
					DT::dataTableOutput(
						outputId = "table1"
					)
				),
				shinydashboard::tabItem(
					tabName = "model"
				),
				shinydashboard::tabItem(
					tabName = "performance",
					shiny::fluidRow(
						shinydashboard::box(
							title  = "Evaluation metrics",
							status = "primary",
							width  = 6,
							height = "700px",
							shiny::includeHTML(
								"html/performance_auc.html"
							)
						),
						shinydashboard::box(
							title  = "Calibration plot",
							status = "primary",
							width  = 6,
							height = "700px",
							plotly::plotlyOutput(
								outputId = "calibrationPlot",
								height = "500px"
							)
						)
					)
				)
			)
		)
	)
)