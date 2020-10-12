library(tidyverse)
library(shinyBS)

source("functions.R")


betaCoefficients <- list(
	mortality = readRDS(
		"Data/coefficientsMortality.rds"
	),
	icu = readRDS(
		"Data/coefficientsICU.rds"
	)
)

baselineHazard <- list(
	mortality = 0.0632205,
	icu       = 0.05825707
)

fifths <- list(
	mortality = c(
		.02137932 * 100,
		.04912515 * 100,
		.09175009 * 100,
		.17801975 * 100
	),
	icu = c(
		.02602234 * 100,
		.04661271 * 100,
		.07384097 * 100,
		.12741744 * 100
	)
)

calibration <- list(
	mortality = readRDS(
		"Data/calibrationDataMortality.rds"
	)
)


# ----- Color grid behind plotly output -----
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
  "Data/table1Long.rds"
) %>%
	dplyr::mutate(
		status = factor(
			.$status,
			levels = c(
				"overall",
				"dead",
				"discharged",
				"hospital"
			)
		)
	) %>%
	dplyr::arrange(
		.$status
	)

