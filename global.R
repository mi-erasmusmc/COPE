library(dplyr)
library(shinyBS)
library(shinyalert)
library(data.table)
library(highcharter)

source("functions.R")


betaCoefficients <- readRDS(
	"Data/betaCoefficients.rds"
)


intercepts <- list(
	mortality = -13.6,
	icu       = -.08949
)

fifths <- list(
	mortality = c(
		.01300704 * 100,
		.03418947 * 100,
		.06762459 * 100,
		.14041268 * 100
	),
	icu = c(
		.06701038 * 100,
		.11692562 * 100,
		.16903291 * 100,
		.24799012 * 100
	)
)

calibrationQuantiles <- readRDS(
	"Data/calibrationQuantiles.rds"
)

calibration <- readRDS(
	"Data/calibration.rds"
)

auc <- readRDS(
	"Data/auc.rds"
)

calibrationIntercept <- readRDS(
	"Data/calibrationIntercept.rds"
)

calibrationSlope <- readRDS(
	"Data/calibrationSlope.rds"
)


# ----- Color grid behind graph output -----
colorMap <- data.frame(
	fifth = 1:5,
	color = c(
		"#dffbdf",
		"#44D492",
		"#F5EB67",
		"#FFA15C",
		"#FA233E"
	)
)


develTab1Long <- readRDS(
  "Data/developTable1.rds"
) %>%
	dplyr::mutate(
		status = factor(
			.$status,
			levels = c(
				"Overall",
				"Dead",
				"Discharged",
				"In hospital"
			)
		)
	) %>%
	dplyr::arrange(
		.$status,
		.$variable
	)

validationTab1Long <- readRDS(
  "Data/validateTable1.rds"
) %>%
	dplyr::mutate(
		status = factor(
			.$status,
			levels = c(
				"Overall",
				"Dead",
				"Discharged",
				"In hospital"
			)
		)
	) %>%
	dplyr::arrange(
		.$status,
		.$variable
	)


transformationsMortality <- list(
	age             = identity,
	respiratoryRate = log,
	crp             = log,
	ldh             = log,
	albumin         = log,
	urea            = log
)

transformationsIcu <- list(
	lp  = identity
)

