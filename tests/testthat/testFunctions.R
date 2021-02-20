testthat::test_that(
	"Logistic probability calculation from linear predictor works",
	{
		testthat::expect_equal(
			logisticProbability(0),
			50
		)
	}
)


testthat::test_that(
	"Creation of mortality model matrix works",
	{
		testthat::expect_equal(
			createModelMatrix(
				covariates      = rep(1, 6),
				transformations = transformationsMortality
			),
			c(1, rep(0, 5))
		)
	}
)


testthat::test_that(
	"Creation of linear predictor works",
	{
		testthat::expect_equal(
			createLinearPredictor(
				modelMatrix = rep(1, 6),
				beta        = rep(1, 6),
				intercept   = 1
			),
			matrix(7)
		)
	}
)


testthat::test_that(
	"Extraction of calibration quantiles works",
	{
		testthat::expect_equal(
			extractQuantiles(
				outcome              = 1,
				center               = 1,
				calibrationQuantiles = data.frame(
					center  = 1,
					outcome = 1,
					quant20 = 20,
					quant40 = 40,
					quant60 = 60,
					quant80 = 80
				)
			),
			c(
				quant20 = 20, quant40 = 40,
				quant60 = 60, quant80 = 80
			)
		)
	}
)