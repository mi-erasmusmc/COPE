library(shiny)
library(testthat)

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
		
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 1001,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
	
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 99,
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
	
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = "test",
			crp                       = 48,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
	
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
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
		
		session$setInputs(
			age                       = 70,
			respiratoryRate           = 45,
			ldh                       = 244,
			crp                       = 401,
			albumin                   = 39,
			urea                      = 6.5,
			calculatePredictionButton = "click"
		)
	
		testthat::expect_equal(
			admissibleInput(),
			FALSE
		)
		
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


		
