library(shiny)
library(testthat)

# age below admissible input
shiny::testServer(
	expr = {
		session$setInputs(
			age                       = -1,
			respiratoryRate           = 19,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# age above admissible input
		session$setInputs(
			age                       = 101,
			respiratoryRate           = 19,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# age as character input
		session$setInputs(
			age                       = "seventy",
			respiratoryRate           = 19,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		# respiratory rate below admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 9,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# respiratory rate above admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 61,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# respiratory rate as character input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = "ten",
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		# ldh above admissible input	
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 4001,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# ldh below admissible input	
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 49,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		# ldh as character input	
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = "two hundred",
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# crp below admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 0,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# crp above admissible input	
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 501,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# crp as character input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = "two hundred",
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# albumin below admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 9,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# albumin above admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 61,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# albumin as character input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = "twenty",
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# urea below admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 20,
			urea                      = 0,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# urea above admissible input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 20,
			urea                      = 81,
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		# urea as character input
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 48,
			albumin                   = 20,
			urea                      = "four",
			calculatePredictionButton = "click"
		)
		
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
	}
)



