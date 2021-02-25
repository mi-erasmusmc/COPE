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
	prediction,
	colorMap,
	currentRiskFifth,
	riskFifths,
	rangeMax
) {
	
	riskLevels <- c(
		"Lowest", "Lower",
		"Intermediate",
		"Higher", "Highest"
	)
	
	plotly::plot_ly(
		data = data.frame(
			x = 0, 
			prediction = prediction,
			width = .4
		)
	) %>%
		plotly::add_bars(
			x = ~x,
			y = ~prediction,
			width = ~width,
			text = ~prediction,
			textposition = "outside",
			texttemplate = "<b>%{text}%</b>",
			textfont = list(size = 18),
			hoverinfo = "text",
			hovertext = paste(
				"<b>Risk ranking:</b>\n",
				riskLevels[currentRiskFifth - 1]
			)
		) %>%
		plotly::layout(
			xaxis = list(
				visible = FALSE
			),
			yaxis = list(
				range = c(0, rangeMax),
				title = ""
			),
			shapes = list(
				addRectangle(
					y0        = 0,
					y1        = riskFifths[1],
					x0        = -.5,
					x1        = .5,
					fillcolor = colorMap$color[1],
					layer = "below"
				),
				addRectangle(
					y0        = riskFifths[1],
					y1        = riskFifths[2],
					x0        = -.5,
					x1        = .5,
					fillcolor = colorMap$color[2],
					layer = "below"
				),
				addRectangle(
					y0        = riskFifths[2],
					y1        = riskFifths[3],
					x0        = -.5,
					x1        = .5,
					fillcolor = colorMap$color[3],
					layer = "below"
				),
				addRectangle(
					y0        = riskFifths[3],
					y1        = riskFifths[4],
					x0        = -.5,
					x1        = .5,
					fillcolor = colorMap$color[4],
					layer = "below"
				),
				addRectangle(
					y0        = riskFifths[4],
					y1        = rangeMax,
					x0        = -.5,
					x1        = .5,
					fillcolor = colorMap$color[5],
					layer = "below"
				)
			)
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
			),
			hoverinfo = "text",
			hovertext = paste(
				"<b>Predicted:</b>",
				paste0(
					round(calibrationData$predicted, 2),
					"%"
				),
				"<br><b>Observed:</b>",
				paste0(
					round(calibrationData$observed, 2),
					"%"
				)
			)
		) %>%
		plotly::layout(
			font = list(size = 11),
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
				x           = .42,
				y           = .08,
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
					"Predicted 28-day",
					outcome
				),
				range = c(-.01, .5)
			),
			yaxis = list(
				title = paste(
					"Observed 28-day",
					outcome
				),
				range = c(-.01, .5)
			),
			showlegend = FALSE
		)
}