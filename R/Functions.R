createLinearPredictor <- function(
	modelMatrix,
	beta,
	intercept
) {
	beta <- matrix(
		beta,
		ncol = 1
	)
	
	linearPredictor <- modelMatrix %*% beta + intercept
	return(linearPredictor)
}


logisticProbability <- function(
	linearPredictor
) {
	res <- 1 / (1 + exp(-linearPredictor))
	return(round(100 * res, 1))
}


createModelMatrix <- function(
	covariates,
	transformations
) {
	res <- diag(sapply(transformations, mapply, covariates))
	return(res)
}


extractQuantiles <- function(
	calibrationQuantiles,
	outcome,
	center
) {
	calibrationQuantiles %>%
		dplyr::filter(
			!!outcome == outcome,
			!!center == center
		) %>%
		dplyr::select(
			quant20, quant40, quant60, quant80
		) %>%
		unlist()
}
