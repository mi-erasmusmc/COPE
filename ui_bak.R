shiny::shinyUI(
	shinydashboard::dashboardPage(
		skin = "black",
		title = "ED-COVID",
		shinydashboard::dashboardHeader(
			title = "Main title",
			tags$li(
				div(
					img(
						src = 'logo_erasmus.png',
						title = "Erasmus MC", 
						height = "46", 
						width = "110px"
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
					text = "Calculate risk",
					icon = shiny::icon("calculator")
				),
				shinydashboard::menuItem(
					tabName = "description",
					text = "Description",
					icon = shiny::icon("align-justify")
				),
				shinydashboard::menuItem(
					tabName = "population",
					text = "Population",
					icon = shiny::icon("users")
				),
				shinydashboard::menuItem(
					tabName = "model",
					text = "Model",
					icon = shiny::icon("clipboard")
				),
				shinydashboard::menuItem(
					tabName = "performance",
					text = "Performance",
					icon = shiny::icon("tasks")
				)
			),
			shiny::conditionalPanel(
				condition = "input.menu1 == 'calculation'",
				shinyBS::popify(
					shiny::numericInput(
						inputId = "age",
						label = "Age",
						value = 50,
						min = 20,
						max = 100
					),
					title = "<b>Age</b>",
					content = shiny::includeHTML(
						path = "html/age.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shinyBS::popify(
					shiny::numericInput(
						inputId = "respiratoryAge",
						label = "Respiratory age",
						value = 50,
						min = 20,
						max = 100
					),
					title = "<b>Respiratory age</b>",
					content = shiny::includeHTML(
						path = "html/respiratoryAge.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shinyBS::popify(
					shiny::numericInput(
						inputId = "oxygenSaturation",
						label = "Oxygen saturation",
						value = 100,
						min = 80,
						max = 100
					),
					title = "<b>Oxygen saturation</b>",
					content = shiny::includeHTML(
						path = "html/oxygenSaturation.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shinyBS::popify(
					shiny::numericInput(
						inputId = "ldh",
						label = "LDH",
						value = 50,
						min = 20,
						max = 100
					),
					title = "<b>LDH</b>",
					content = shiny::includeHTML(
						path = "html/ldh.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shinyBS::popify(
					shiny::numericInput(
						inputId = "crp",
						label = "CRP",
						value = 50,
						min = 20,
						max = 100
					),
					title = "<b>CRP</b>",
					content = shiny::includeHTML(
						path = "html/crp.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shinyBS::popify(
					shiny::numericInput(
						inputId = "leucocyteCount",
						label = "Leucocyte count",
						value = 50,
						min = 20,
						max = 100
					),
					title = "<b>Leucocyte count",
					content = shiny::includeHTML(
						"html/leucocyteCount.html"
					),
					placement = "right",
					options = list(
						container = "body"
					)
				),
				shiny::actionButton(
					inputId = "calculate",
					label = "Calculate"
				)
			)
		),
		shinydashboard::dashboardBody(
			shinydashboard::tabItems(
				shinydashboard::tabItem(
					tabName = "description",
					shiny::includeHTML(
						"html/description.html"
					)
				),
				shinydashboard::tabItem(
					tabName = "calculation",
					# plotly::plotlyOutput(
					# 	outputId = "calculationPlot",
					# 	width = "50%"
					# )
					shiny::fluidRow(
						shinydashboard::valueBoxOutput(
							"probabilityBox",
							width = 4
						),
						shinydashboard::box(
							title = "Result explanation",
							width = 8,
							shiny::textOutput(
								outputId = "resultExplanationBox"
							)
						)
					)
				),
				shinydashboard::tabItem(
					tabName = "population"
				),
				shinydashboard::tabItem(
					tabName = "model"
				),
				shinydashboard::tabItem(
					tabName = "performance"
				)
			)
		)
	)
)