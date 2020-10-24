library(dplyr)
library(shinyBS)
library(shinyalert)
library(data.table)

source("functions.R")


betaCoefficients <- readRDS(
	"Data/betaCoefficients.rds"
)

baselineHazard <- list(
	mortality = 0.0632205,
	icu       = 0.06078579
)

fifths <- list(
	mortality = c(
		.020562059 * 100,
		.047966477 * 100,
		.090997030 * 100,
		.182960687 * 100
	),
	icu = c(
		.06322953 * 100,
		.11972550 * 100,
		.19091041 * 100,
		.31256813 * 100
	)
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


table1Long <- readRDS(
  "Data/table1.rds"
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
	time            = identity,
	age             = identity,
	respiratoryRate = log,
	crp             = log,
	ldh             = log
)

transformationsIcu <- list(
	lp  = identity,
	age = identity
)

