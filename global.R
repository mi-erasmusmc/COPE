library(shinyBS)
library(plotly)
library(tidyverse)
library(dashboardthemes)

betaCoefficients <- readRDS(
	"Data/coefficients.rds"
)

baselineHazard <- 0.06336707

fifth1 <- 0.021538467
fifth2 <- 0.051167435
fifth3 <- 0.096543873
fifth4 <- 0.179968413

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
	
	prediction <- 1 - exp(-baselineHazard*exp(covariateVector%*%betaCoefficients))
	
	return(c(prediction))
}

hline <- function(y = 0, color = "black") {
	list(
		type = "line",
		x0 = 0,
		x1 = 1,
		xref = "paper",
		y0 = y,
		y1 = y,
		line = list(
			color = color
		)
	)
}