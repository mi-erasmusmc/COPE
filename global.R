library(shinyBS)
library(plotly)
library(tidyverse)
library(dashboardthemes)

betaCoefficients <- readRDS(
	"Data/coefficients.rds"
)

baselineHazard <- 0.06336707

fifth1 <- 0.021538467*100
fifth2 <- 0.051167435*100
fifth3 <- 0.096543873*100
fifth4 <- 0.179968413*100

table1 <- readRDS(
	"Data/table1.rds"
)

calculateRisk <- function(
	age,
	rr,
	saturation,
	crp,
	ldh,
	leucocytes,
	betaCoefficients,
	baselineHazard
)
{
	covariateVector <- c(
		age,
		rr,
		saturation,
		log(crp),
		log(ldh),
		log(leucocytes)
	)
	
	prediction <- 100*(1 - exp(-baselineHazard*exp(covariateVector%*%betaCoefficients)))
	
	return(c(round(prediction, 2)))
}


hline <- function(y = 0, color = "black") {
	list(
		type = "line",
		x0 = 0,
		x1 = 1,
		xref = "paper",
		y0 = y,
		y1 = y,
		layer = "below",
		line = list(
			color = color
		)
	)
}

addInfo <- function(item, infoId) {
	infoTag <- tags$small(
		class = "badge pull-right action-button",
		style = "padding: 1px 6px 2px 6px; background-color: steelblue;",
		type = "button",
		id = infoId,
		"i"
	)
	
	item$children[[1]]$children <- append(item$children[[1]]$children, list(infoTag))
	
	return(item)
}