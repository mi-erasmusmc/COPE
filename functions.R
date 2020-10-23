createLinearPredictor <- function(
	modelMatrix,
	beta
) {
	beta <- matrix(
		beta,
		ncol = 1
	)
	
	linearPredictor <- modelMatrix %*% beta
	return(linearPredictor)
}


survivalProbability <- function(
	baselineHazard,
	linearPredictor,
	center
) {
	
	res <- 1 - exp(-baselineHazard * exp(linearPredictor - center))
	return(round(100 * res, 1))
	
}


createModelMatrix <- function(
	covariates,
	transformations
) {
	res <- diag(sapply(transformations, mapply, covariates))
	return(res)
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
	linewidth = 0,
	opacity = .4,
	layer = NULL
) {
	res <- list(
		type      = "rect",
		fillcolor = fillcolor,
		# layer     = "below",
		opacity   = opacity,
		x0        = x0,
		x1        = x1,
		y0        = y0,
		y1        = y1,
		line      = list(
			color = "black",
			width = linewidth
		)
	)
	
	if (!is.null(layer)) {
		res$layer <- layer
	}
	
	return(res)
}


plotRiskPrediction <- function(
	predictionData, 
	fifths,
	riskFifth,
	colorMap,
	rangeMax
) {
	
	plotly::plot_ly() %>%
		plotly::add_polygons(
			mode = "markers",
			x          = c(0, 0, 2, 2),
			y          = c(0, fifths[1], fifths[1], 0),
			fillcolor  = 'rgba(223, 251, 223, 0.2)',
			text       = "Lowest risk",
			hoveron    = "fills",
			hoverinfo  = "text",
			line       = list(width=0),
			inherit    = FALSE,
			showlegend = FALSE
		) %>%
		plotly::add_polygons(
			x          = c(0, 0, 2, 2),
			y          = c(fifths[1], fifths[2], fifths[2], fifths[1]),
			fillcolor  = 'rgba(68,212,146, 0.4)',
			text       = "Lower risk",
			hoveron    = "fills",
			hoverinfo  = "text",
			line       = list(width=0),
			inherit    = FALSE,
			showlegend = FALSE
		) %>%
		plotly::add_polygons(
			x          = c(0, 0, 2, 2),
			y          = c(fifths[2], fifths[3], fifths[3], fifths[2]),
			fillcolor  = 'rgba(245,235,103, 0.4)',
			text       = "Intermediate risk",
			hoveron    = "fills",
			hoverinfo  = "text",
			inherit    = FALSE,
			line       = list(width=0),
			showlegend = FALSE
		) %>%
		plotly::add_polygons(
			x          = c(0, 0, 2, 2),
			y          = c(fifths[3], fifths[4], fifths[4], fifths[3]),
			fillcolor  = 'rgba(255,161,92, 0.4)',
			text       = "Higher risk",
			hoveron    = "fills",
			hoverinfo  = "text",
			inherit    = FALSE,
			line       = list(width=0),
			showlegend = FALSE
		) %>%
		plotly::add_polygons(
			x          = c(0, 0, 2, 2),
			y          = c(fifths[4], 100, 100, fifths[4]),
			fillcolor  = 'rgba(250,35,62, 0.4)',
			text       = "Highest risk",
			hoveron    = "fills",
			hoverinfo  = "text",
			inherit    = FALSE,
			line       = list(width=0),
			showlegend = FALSE
		) %>%
		plotly::add_annotations(
			data = predictionData,
			x = ~x,
			y = ~y,
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
				addRectangle(
					x0 = .5,
					x1 = 1.5,
					y0 = 0,
					y1 = ~y,
					fillcolor = "#3B6AA0",
					opacity = 1,
					linewidth = 2
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
			),
			hoverlabel=list(bgcolor="white")
		) 
}



plotCalibration <- function(
	calibrationData,
	fifths,
	colorMap,
	title = NULL,
	outcome,
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
			mode    = "markers",
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
					fillcolor = colorMap$color[1],
					layer = "below"
				),
				addRectangle(
					x0        = fifths[1] / 100,
					x1        = fifths[2] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[2],
					layer = "below"
				),
				addRectangle(
					x0        = fifths[2] / 100,
					x1        = fifths[3] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[3],
					layer = "below"
				),
				addRectangle(
					x0        = fifths[3] / 100,
					x1        = fifths[4] / 100,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[4],
					layer = "below"
				),
				addRectangle(
					x0        = fifths[4] / 100,
					x1        = .5,
					y0        = 0,
					y1        = .5,
					fillcolor = colorMap$color[5],
					layer = "below"
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
				x = .42,
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
				title = paste(
					"Predicted 21-day",
					outcome
				),
				range = c(-.01, .5)
			),
			yaxis = list(
				title = paste(
					"Observed 21-day",
					outcome
				),
				range = c(-.01, .5)
			),
			showlegend = FALSE
		)
}
