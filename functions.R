survivalProbability <- function(
	hazard,
	covariates,
	beta,
	center
) {
	
	res <- 1 - exp(-hazard * exp(covariates %*% beta - center))
	return(res)
	
}



createModelMatrix <- function(
	time = 4,
	age,
	rr,                # respiratory rate
	crp,               # C-reactive protein
	ldh,               # Lactatedehydrogenase
	outcome            # Now only mortality and icu are available
) {
	
	if (outcome == "mortality") {
		res <- matrix(
			c(
				time,
				age,
				log(rr),
				log(crp),
				log(ldh)
			),
			nrow = 1
		) 
	} else {
		res <- matrix(
			c(
				time,
				age,
				age^2,
				log(rr),
				log(crp),
				log(ldh)
			),
			nrow = 1
		)
	}
	
	return(res)
}



calculateRisk <- function(
	time = 4,
	age,
	rr,
	crp,
	ldh,
	betaCoefficients,
	baselineHazard
) {
	
	covariateVector <- createModelMatrix(
		age = age,
		rr  = rr,
		crp = crp,
		ldh = ldh,
		outcome = "mortality"
	)
	
	mortalityRisk <- survivalProbability(
		hazard     = baselineHazard$mortality,
		covariates = covariateVector,
		beta       = betaCoefficients$mortality,
		center     = 13.13958
	)
	
	covariateVector <- createModelMatrix(
		age = age,
		rr  = rr,
		crp = crp,
		ldh = ldh,
		outcome = "icu"
	)
	
	icuRisk <- survivalProbability(
		hazard     = baselineHazard$icu,
		covariates = covariateVector,
		beta       = betaCoefficients$icu,
		center     = 10.725
	)
	
	return(
		list(
			mortality = round(100 * mortalityRisk, 1),
			icu       = round(100 * icuRisk, 1)
		)
	)
	
}


# ----- Adds dotted lines for the prediction fifths in plotly -----
hline <- function(y = 0, color = "black") {
	list(
		type  = "line",
		x0    = 0,
		x1    = 1,
		xref  = "paper",
		y0    = y,
		y1    = y,
		layer = "below",
		line  = list(
			color = color,
			dash  = "dot"
		)
	)
}



# ----- Adds a colored rectangle in plotly ------
addRectangle <- function(
	x0,
	x1,
	y0,
	y1,
	fillcolor,
	opacity = .4
) {
	list(
		type      = "rect",
		fillcolor = fillcolor,
		layer     = "below",
		opacity   = opacity,
		x0        = x0,
		x1        = x1,
		y0        = y0,
		y1        = y1,
		line      = list(
			color = fillcolor,
			width = 0
		)
	)
}

# # ----- Adds an info button in the ui -----
# addInfo <- function(item, infoId) {
# 	infoTag <- tags$small(
# 		class = "badge pull-right action-button",
# 		style = "padding: 1px 6px 2px 6px; background-color: steelblue;",
# 		type  = "button",
# 		id    = infoId,
# 		"i"
# 	)
# 	
# 	item$children[[1]]$children <- append(item$children[[1]]$children, list(infoTag))
# 	
# 	return(item)
# }




plotRiskPrediction <- function(
	predictionData, 
	fifths,
	riskFifth,
	colorMap,
	rangeMax
) {
	
	# rangeMax <- 30   # the range of y axis
	# 
	# if (predictionData$y > 25) {
	# 	rangeMax <- 100
	# }

	predictionData	%>%
		plotly::plot_ly(
			x      = ~x,
			y      = ~y,
			type   = "bar",
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
			bgcolor     = colorMap$color[riskFifth - 1],
			bordercolor = "black",
			borderwidth = 1,
			showarrow   = FALSE,
			standoff    = 4,
			hoverinfo   = "none",
			hoverformat = "%{1}f",
			showlegend  = FALSE,
			font        = list(
				size = 18,
				color = "black"
			)
		) %>%
		plotly::layout(
			shapes = list(
				hline(
					fifths[1],
					color = "black"
				),
				hline(
					fifths[2],
					color = "black"
				),
				hline(
					fifths[3],
					color = "black"
				),
				hline(
					fifths[4],
					color = "black"
				),
				addRectangle(
					x0        = 0,
					x1        = 2,
					y0        = 0,
					y1        = fifths[1],
					fillcolor = colorMap$color[1]
				),
				addRectangle(
					x0        = 0,
					x1        = 2,
					y0        = fifths[1],
					y1        = fifths[2],
					fillcolor = colorMap$color[2]
				),
				addRectangle(
					x0        = 0,
					x1        = 2,
					y0        = fifths[2],
					y1        = fifths[3],
					fillcolor = colorMap$color[3]
				),
				addRectangle(
					x0        = 0,
					x1        = 2,
					y0        = fifths[3],
					y1        = fifths[4],
					fillcolor = colorMap$color[4]
				),
				addRectangle(
					x0        = 0,
					x1        = 2,
					y0        = fifths[4],
					y1        = 100,
					fillcolor = colorMap$color[5]
				)
			),
			yaxis = list(
				title = "Probability (%)",
				range = c(
					0,
					rangeMax
				)
			),
			xaxis = list(
				title = "",
				showticklabels = FALSE
			)
		)
}



plotCalibration <- function(
	calibrationData,
	fifths,
	colorMap,
	title = NULL,
	a,               # calibration intercept
	b,               # calibration slope
	c                # c-index
) {
	
	plotly::plot_ly(data = calibrationData) %>%
		plotly::add_trace(
			x     = c(0, .5), 
			y     = c(0, .5),
			mode  = 'lines',
			line  = list(dash = "dash"),
			color = I('black'),
			type  = 'scatter'
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
					x1        = fifths[1] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[1]
				),
				addRectangle(
					x0        = fifths[1] / 100,
					x1        = fifths[2] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[2]
				),
				addRectangle(
					x0        = fifths[2] / 100,
					x1        = fifths[3] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[3]
				),
				addRectangle(
					x0        = fifths[3] / 100,
					x1        = fifths[4] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[4]
				),
				addRectangle(
					x0        = fifths[4] / 100,
					x1        = .5,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[5]
				)
			),
			annotations = list(
				text = paste(
					paste(
						"a",
						a,
						sep = "="
					),
					paste(
						"b",
						b,
						sep = "="
					),
					paste(
						"c",
						c,
						sep = "="
					),
					sep = "\n"
				),
				x = .45,
				y = .08,
				bgcolor     = "white",
				opacity     = .6,
				borderwidth = 1,
				showarrow   = FALSE,
				standoff    = 4,
				hoverinfo   = "none",
				showlegend  = FALSE,
				font        = list(
					size = 13,
					color = "black"
				)
			),
			title = title,
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
}
