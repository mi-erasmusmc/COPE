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
					shinydashboard::box(
						status = "primary",
						width  = 2,
						height = "450px",
						shinyBS::popify(
							shiny::numericInput(
								inputId = "age",
								label   = "Age",
								value   = 66,
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
								inputId = "respiratoryRate",
								label   = "Respiratory rate",
								value   = 25,
								min     = 0
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
								inputId = "ldh",
								label   = "LDH",
								value   = 293,
								min     = 0
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
								value   = 85
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
						shiny::actionButton(
							inputId = "calculatePredictionButton",
							label   = "Calculate",
							icon    = shiny::icon("calculator")
						)
					),
					shiny::conditionalPanel(
						condition = "input.calculatePredictionButton",
						shinydashboard::box(
							status = "primary",
							title  = "Mortality risk prediction",
							width  = 5,
							height = "450px",
							plotly::plotlyOutput(
								outputId = "calculationPlotMortality",
								height = "380px"
							)
						),
						shinydashboard::box(
							status = "primary",
							title  = "ICU risk prediction",
							width  = 5,
							height = "450px",
							plotly::plotlyOutput(
								outputId = "calculationPlotIcu",
								height = "380px"
							)
						),
						shinydashboard::box(
							status = "primary",
							title  = "Result explanation",
							width  = 12,
							height = "240px",
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
					shiny::tabsetPanel(
						shiny::tabPanel(
							title = "Mortaltiy",
							shinydashboard::box(
								title  = "Calibration plot for: Center 1",
								status = "primary",
								width  = 3,
								height = "390px",
								plotly::plotlyOutput(
									outputId = "calibrationMortalityCenter1",
									height = "300px"
								)
							),
							shinydashboard::box(
								title  = "Center 2",
								status = "primary",
								width  = 3,
								height = "390px",
								plotly::plotlyOutput(
									outputId = "calibrationMortalityCenter2",
									height = "300px"
								)
							),
							shinydashboard::box(
								title  = "Center 3",
								status = "primary",
								width  = 3,
								height = "390px",
								plotly::plotlyOutput(
									outputId = "calibrationMortalityCenter3",
									height = "300px"
								)
							),
							shinydashboard::box(
								title  = "Center 4",
								status = "primary",
								width  = 3,
								height = "390px",
								plotly::plotlyOutput(
									outputId = "calibrationMortalityCenter4",
									height = "300px"
								)
							),
							shinydashboard::box(
								title  = "Evaluation metrics",
								status = "primary",
								width  = 12,
								height = "300px",
								shiny::includeHTML(
									"html/performance_auc.html"
								)
							)
						),
						shiny::tabPanel(
							title = "ICU",
							shinydashboard::box(
								title  = "Calibration plot",
								status = "primary",
								width  = 3,
								height = "390px"
							),
							shinydashboard::box(
								title  = "Calibration plot",
								status = "primary",
								width  = 3,
								height = "390px"
							),
							shinydashboard::box(
								title  = "Calibration plot",
								status = "primary",
								width  = 3,
								height = "390px"
							),
							shinydashboard::box(
								title  = "Calibration plot",
								status = "primary",
								width  = 3,
								height = "390px"
							),
							shinydashboard::box(
								title  = "Evaluation metrics",
								status = "primary",
								width  = 12,
								height = "300px",
								shiny::includeHTML(
									"html/performance_auc.html"
								)
							)
						)
					)
				)
			)
		)
	)
)