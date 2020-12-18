library(dplyr)
library(shinyBS)
library(shinyalert)
library(data.table)
library(highcharter)

source("functions.R")


betaCoefficients <- readRDS(
	"Data/betaCoefficients.rds"
)

# baselineHazard <- list(
# 	mortality = 0.0632205,
# 	icu       = 0.06078579
# )

intercepts <- list(
	mortality = -5.13,
	icu       = -.1017
)

fifths <- list(
	mortality = c(
		.01291878 * 100,
		.03384067 * 100,
		.06871251 * 100,
		.13964134 * 100
	),
	icu = c(
		.06009314 * 100,
		.10752445 * 100,
		.15796628 * 100,
		.23229147 * 100
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
	age             = identity,
	respiratoryRate = log,
	saturation      = identity,
	crp             = log,
	ldh             = log,
	albumin         = log,
	urea            = log
)

transformationsIcu <- list(
	lp  = identity
)

