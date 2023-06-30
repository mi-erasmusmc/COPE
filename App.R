library(shiny)
ui <- fluidPage(
	mainPanel(
		width = 9,
		p("COPE has been updated with data from 2021 and 2022."),
		p("The new web application can be found at",
		 a("https://cope2.nl/",
			href = "https://www.cope2.nl",
			target = "blank"),
		 "and is also available as mobile app (COPE Decision Support) in the",
		 a("Google Play Store", href = "https://play.google.com/store/apps/details?id=nl.erasmusmc.COPE", target  = "blank"),
		 "and the Apple App Store."
		 ),
		hr()
	)
)
server <- function(input, output) {}

shinyApp(ui = ui, server = server)
