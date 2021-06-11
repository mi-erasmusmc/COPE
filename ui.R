shiny::shinyUI(
	shinydashboardPlus::dashboardPage(
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
							src    = "ce_logo.png",
							title  = "CE",
							height = "40px",
							width = "50px"
						)
					)
					# style = "padding-top:10px;padding-bottom:0px;padding-right:2px"
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
						href = "https://www.publichealthrotterdam.com/"
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
					tabName = "about",
					text    = "About",
					icon    = shiny::icon("info-circle")
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
				),
				shinydashboard::menuItem(
					tabName = "supplier",
					text    = "Supplier",
					icon    = shiny::icon("tools")
				)
			)
		),
		shinydashboard::dashboardBody(
			shinyWidgets::setShadow(class = "box"),
			shinyalert::useShinyalert(),
			shinydashboard::tabItems(
				shinydashboard::tabItem(
					tabName = "supplier",
					shiny::includeHTML(
						"html/supplier.html"
					)
				),
				shinydashboard::tabItem(
					tabName = "about",
					shiny::includeHTML(
						"html/description_abstract.html"
					),
					shiny::downloadButton(
						"manual",
						label = "User manual"
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
									value   = 70,
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
									value   = 19,
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
									value   = 244,
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
									value   = 48,
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
									value   = 39,
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
									value   = 6.5,
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
								plotly::plotlyOutput(
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
								plotly::plotlyOutput(
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
										 was estimated using a logistic regression
										 model. The linear predictor of the model 
										 is given by:
								$$
								\\begin{align}
                                \\ LP_{mort} = &-13.6 \\\\
                                \\ & + 0.046\\times Age + 1.654\\times log(RR) \\\\
                                \\ & + 0.169\\times log(CRP) + 1.197\\times log(LDH) \\\\
                                \\ & - 1.585\\times log(Albumin) + 0.595\\times log(Urea)
                                \\end{align}
                                $$
								Then the probability of death in 28 days is given
									from:
									$$
									Pr(Death) = \\frac{1}{1+exp(-LP_{mort})}
									$$
									"
									
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
									28-day mortality. More specifically, the linear
									predictor of the model for
									ICU admission is given from:
									$$
									LP_{ICU} = -0.089 + 0.597\\times LP_{mort}
									$$
									Then, the probability for 28-day ICU 
									admission can be estimated from:
									$$
									Pr(ICU) = \\frac{1}{1+exp(-LP_{ICU})}
									$$
									"
								),
								shiny::hr(),
								shiny::em(
									"Note: here",
									shiny::strong("log"),
									"is the natural logarithm and",
									shiny::strong("exp"),
									"is the natural exponential"
								)
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "performance",
					shiny::tabsetPanel(
						shiny::tabPanel(
							title = "Overall",
							shinydashboard::box(
								title  = "Calibration plot for mortality",
								status = "primary",
								width  = 6,
								height = "450px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationMortalityOverall",
										height = "380px"
									)
								)
							),
							shinydashboard::box(
								title  = "Calibration plot for ICU admission",
								status = "primary",
								width  = 6,
								height = "450px",
								shinycssloaders::withSpinner(
									type = 4,
									plotly::plotlyOutput(
										outputId = "calibrationIcuOverall",
										height = "380px"
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
							title = "By hospital",
							shiny::tabsetPanel(
								id = "byHospital",
								type = "pills",
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
						)
					)
				)
			)
		)
	)
)