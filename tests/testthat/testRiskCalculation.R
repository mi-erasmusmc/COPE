library(shiny)
library(testthat)

shiny::testServer(
	expr = {
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 19,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		# Is the reactive input dataframe correct?
		testthat::expect_equal(
			currentInputData(),
			data.frame(
				age             = 70,
				respiratoryRate = 19,
				crp             = 48,
				ldh             = 244,
				albumin         = 39,
				urea            = 6.5
			)
		)
		
		# Is the initial input admissible?
		testthat::expect_equal(
			admissibleInput(),
			TRUE
		)
		
		# Is the prediction for the starting values correct?
		testthat::expect_equal(
			currentPrediction(),
			list(
				mortality = 4.8,
				icu       = 13.3
			)
		)
		
		# Is the predicted mortality risk assigned to the correct stratum of risk?
		testthat::expect_equal(
			riskFifthMortality(),
			4
		)
		
		# Is the predicted ICU risk assigned to the correct stratum of risk?
		testthat::expect_equal(
			riskFifthIcu(),
			4
		)
		
		# Is the output of the result explanation box correct?
		testthat::expect_equal(
			output$resultExplanationBox,
			paste(
				shiny::includeHTML(here::here("html/calculation_result_explanation1.html")),
				shiny::HTML(paste0(4.8, "%.")),
				shiny::includeHTML(here::here("html/calculation_result_explanation2.html")),
				shiny::HTML("intermediate"),
				shiny::includeHTML(here::here("html/calculation_result_explanation3.html")),
				shiny::includeHTML(here::here("html/calculation_result_explanation4.html")),
				shiny::HTML(paste0(13.3, "%.")),
				shiny::includeHTML(here::here("html/calculation_result_explanation2.html")),
				shiny::HTML("intermediate"),
				shiny::includeHTML(here::here("html/calculation_result_explanation6.html"))
			)
		)
		
		# Is the predicted mortality risk also presented at the top of the box 
		# in the barplot?
		testthat::expect_equal(
			output$titleMortalityRiskBox,
			"<p>Death within 28 days: <b> 4.8 %</b></p>"
		)
		
		# Is the predicted ICU risk also presented at the top of the box in 
		# the barplot?
		testthat::expect_equal(
			output$titleIcuRiskBox,
			"<p>ICU admission within 28 days: <b> 13.3 %</b></p>"
		)
	}
)

		