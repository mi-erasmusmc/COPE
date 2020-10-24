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
	prediction,
	colorMap,
	currentRiskFifth,
	riskFifths,
	rangeMax
) {
	
	riskFifthsExtended <- sort(
		c(
			0, riskFifths, rangeMax
		)
	)
	
	
	
	riskFifthsExtended <- diff(riskFifthsExtended)
	
	cols <- c(
		rev(colorMap$color), 
		"#3B6AA0"
	)
	
	highcharter::highchart() %>%
		highcharter::hc_add_series(
			name = "Highest risk",
			type = "area",
			data = rep(riskFifthsExtended[5], 3)
		) %>%
		highcharter::hc_add_series(
			name = "Higher risk",
			type = "area",
			data = rep(riskFifthsExtended[4], 3)
		) %>%
		highcharter::hc_add_series(
			name = "Intermediate risk",
			type = "area",
			data = rep(riskFifthsExtended[3], 3)
		) %>%
		highcharter::hc_add_series(
			name = "Lower risk",
			type = "area",
			data = rep(riskFifthsExtended[2], 3)
		) %>%
		highcharter::hc_add_series(
			name = "Lowest risk",
			type = "area",
			data = rep(riskFifthsExtended[1], 3)
		) %>%
		highcharter::hc_add_series(
			name = "Predicted risk",
			data = data.frame(
				x = 1,
				y = prediction
			),
			type = "column",
			highcharter::hcaes(
				x = x,
				y = y
			)
		) %>%
		highcharter::hc_plotOptions(
			area = list(
				stacking  = "normal",
				lineWidth = 0,
				marker = list(
					enabled   = FALSE,
					lineWidth = 0,
					lineColor = "#ffffff"
				),
				fillOpacity = .4
			),
			column = list(
				borderColor = "#000000",
				borderWidth = 2,
				dataLabels  = list(
					enabled         = TRUE,
					backgroundColor = colorMap$color[currentRiskFifth - 1],
					borderColor     = "#000000",
					borderRadius    = 10,
					borderWidth     = 2,
					shadow          = TRUE,
					format          = '{y} %',
					inside          = TRUE,
					animation       = list(defer = 2000),
					style           = list(fontSize = "18px")
				)
			)
		) %>%
		highcharter::hc_tooltip(
			formatter = highcharter::JS(
				"function () {
            return '<b>' + this.series.name + '</b>';
        }"
			),
			hideDelay     = 100,
			followPointer = TRUE,
			shared        = FALSE
		) %>%
		highcharter::hc_xAxis(
			max               = 1.5,
			min               = .5,
			categories        = c(0, 1, 2),
			tickmarkPlacement = "on",
			labels            = list(enabled = FALSE)
		) %>%
		highcharter::hc_yAxis(
			max   = rangeMax,
			title = list(text = "Probability (%)")
		) %>%
		hc_colors(cols) %>%
		highcharter::hc_legend(
			enabled = FALSE
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
