shiny::shinyUI(
	shinydashboard::dashboardPage(
		skin      = "black",
		title     = "COPE",
		shinydashboard::dashboardHeader(
			title = "COPE",
			tags$li(
				tags$div(
					"Covid Outcome Prediction in the Emergency Department",
					style = "padding-top:14px;font-style:italic;
					padding-right:10px;font-size: min(3vw, 14px)"
				),
				class = "dropdown"
			),
			tags$li(
				div(
					tags$a(
						img(
							src    = "EMC.jpg",
							title  = "Erasmus MC",
							height = "50px",
							width = "50px"
						),
						href = "https://www.erasmusmc.nl"
					)
					# style = "padding-top:10px;padding-bottom:0px;padding-right:2px"
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
			shinyalert::useShinyalert(),
			shinydashboard::tabItems(
				shinydashboard::tabItem(
					tabName = "description",
					shiny::includeHTML(
						"html/description_abstract.html"
					)
				),
				shinydashboard::tabItem(
					tabName = "calculation",
					shinydashboard::box(
						status = "primary",
						width  = 4,
						column(
							width = 6,
							shinyBS::popify(
								shiny::numericInput(
									inputId = "age",
									label   = shiny::div(
										shiny::HTML(
											"Age <em>(years)</em>"
										)
									),
									value   = 75,
									min     = 0,
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
									label   = shiny::div(
										shiny::HTML(
											"<b>Respiratory rate</b> <em>(per min)</em>"
										)
									),
									value   = 17,
									min     = 10,
									max     = 60
								),
								title   = "<b>Respiratory rate</b>",
								content = shiny::includeHTML(
									path = "html/calculation_respiratoryRate.html"
								),
								placement = "bottom",
								options   = list(
									container = "body"
								)
							),
							shinyBS::popify(
								shiny::numericInput(
									inputId = "ldh",
									label   = shiny::div(
										shiny::HTML(
											"LDH <em>(U per L)</em>"
										)
									),
									value   = 727,
									min     = 100,
									max     = 1000
								),
								title   = "<b>LDH</b>",
								content = shiny::includeHTML(
									path = "html/calculation_ldh.html"
								),
								placement = "bottom",
								options   = list(
									container = "body"
								)
							)
						),
						column(
							width = 6,
							shinyBS::popify(
								shiny::numericInput(
									inputId = "crp",
									label   = shiny::div(
										shiny::HTML(
											"CRP <em>(mg per L)</em>"
										)
									),
									value   = 30,
									min     = 1,
									max     = 400
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
									inputId = "albumin",
									label   = shiny::div(
										shiny::HTML(
											"Serum albumin <em>(g per L)</em>"
										)
									),
									value   = 26,
									min     = 10,
									max     = 60
								),
								title   = "<b>Serum albumin</b>",
								content = shiny::includeHTML(
									path = "html/calculation_albumin.html"
								),
								placement = "bottom",
								options   = list(
									container = "body"
								)
							),
							shinyBS::popify(
								shiny::numericInput(
									inputId = "urea",
									label   = shiny::div(
										shiny::HTML(
											"Serum urea <em>(mmol per L)</em>"
										)
									),
									value   = 1.7,
									min     = 1,
									max     = 80
								),
								title   = "<b>Serum urea</b>",
								content = shiny::includeHTML(
									path = "html/calculation_urea.html"
								),
								placement = "bottom",
								options   = list(
									container = "body"
								)
							),
							shiny::actionButton(
								inputId = "calculatePredictionButton",
								label   = "Calculate",
								icon    = shiny::icon("calculator"),
								class   = "btn-lg"
							)
						)
					),
					shiny::conditionalPanel(
						condition = "input.calculatePredictionButton",
						shinydashboard::box(
							status = "primary",
							title  = shiny::uiOutput(
								outputId = "titleMortalityRiskBox"
							),
							width  = 4,
							height = "320px",
							shinycssloaders::withSpinner(
								type = 4,
								highcharter::highchartOutput(
									outputId = "calculationPlotMortality",
									height = "250px"
								)
							)
						),
						shinydashboard::box(
							status = "primary",
							title  = shiny::uiOutput(
								outputId = "titleIcuRiskBox"
							),
							width  = 4,
							height = "320px",
							shinycssloaders::withSpinner(
								type = 4,
								highcharter::highchartOutput(
									outputId = "calculationPlotIcu",
									height   = "250px"
								)
							)
						),
						shinydashboard::box(
							status = "primary",
							title  = "Result Explanation",
							width  = 12,
							# height = "300px",
							shiny::htmlOutput(
								outputId = "resultExplanationBox"
							),
							tags$head(
								tags$style("#resultExplanationBox{
                                 font-size: 15px;
                                 }"
								)
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "population",
					shiny::tabsetPanel(
						id = "tab1",
						shiny::tabPanel(
							title = "Development",
							DT::dataTableOutput(
								outputId = "developmentTable1"
							)
						),
						shiny::tabPanel(
							title = "Validation",
							DT::dataTableOutput(
								outputId = "validationTable1"
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "model",
					shinydashboard::box(
						title  = "Mortality",
						status = "primary",
						width  = 12,
						# height = "300px",
						shiny::withMathJax(
							shiny::helpText(
								shiny::p(
									"The probability of mortality within 28 days
								was estimated using a Cox proportional hazards
								model. The natural logarithm of the hazard ratio
								is given by:
								$$
								\\log(HR_m)=0.052\\times Age + 
								1.529\\times\\log(RR) +
								0.2829\\times\\log(CRP) +
								1.041\\times\\log(LDH) - 
								14.94
								$$
								Then the probability of death within 28 days is:
								$$
								\\Pr(Death) = 1 - \\exp\\bigg(-0.06322\\times\\exp\\Big(\\log(HR_m)\\Big)\\bigg),
								$$
								where log is the natural logarithm, exp is the 
								natural exponent, RR (r/min) is the respiratory
								rate, CRP is the C-reactive protein level (mg/L)
								and LDH is the Lactate dehydrogenase level (U/L).
								The age of the patients is measured in years."
								)
							)
						),
						tags$head(
							tags$style(".help-block p {font-size: 15px;}")
						)
					),
					shinydashboard::box(
						title  = "ICU admission",
						status = "primary",
						width  = 12,
						# height = "300px",
						shiny::withMathJax(
							shiny::helpText(
								shiny::p(
									"The probability of admission to the ICU 
									within 28 days was estimated using a 
									re-calibrated version of the model for
									21-day mortality. More specifically, the 
									natural logarithm of the hazard ratio for
									ICU admission is given from:
									$$
									\\log(HR_{ICU}) = 0.7684\\times\\log(HR_m) +
									0.8952
									$$
									Then, the probability for 21-day ICU 
									admission can be estimted from:
									$$
									\\Pr(ICU) = 1 - \\exp\\bigg(-0.06079 \\times\\exp\\Big(\\log(HR_{ICU})\\Big)\\bigg)
									$$
									"
								)
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "performance",
					shiny::tabsetPanel(
						shiny::tabPanel(
							title = "Mortality",
							shinydashboard::box(
								title  = "Calibration plot for: Hospital 1",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationMortalityCenter1",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Hospital 2",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationMortalityCenter2",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Hospital 3",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationMortalityCenter3",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Hospital 4",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationMortalityCenter4",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Evaluation metrics",
								status = "primary",
								width  = 12,
								# height = "280px",
								shiny::includeHTML(
									"html/performance_text.html"
								)
							)
						),
						shiny::tabPanel(
							title = "ICU",
							shinydashboard::box(
								title  = "Calibration plot for: Hospital 1",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationIcuHospital1",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Hospital 2",
								status = "primary",
								width  = 3,
								height = "350px"
							),
							shinydashboard::box(
								title  = "Hospital 3",
								status = "primary",
								width  = 3,
								height = "350px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationIcuHospital3",
										height = "280px"
									)
								)
							),
							shinydashboard::box(
								title  = "Hospital 4",
								status = "primary",
								width  = 3,
								height = "350px"
							),
							shinydashboard::box(
								title  = "Evaluation metrics",
								status = "primary",
								width  = 12,
								# height = "280px",
								shiny::includeHTML(
									"html/performance_text.html"
								)
							)
						)
					)
				)
			)
		)
	)
)