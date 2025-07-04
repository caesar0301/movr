context("Native C functions: _compress_mov and _flow_stat")

test_that("_compress_mov compresses movement history correctly", {
  # Example input: locations and times
  loc <- as.integer(c(1, 1, 2, 2, 1, 1))
  time <- as.numeric(c(0, 10, 20, 30, 40, 50))
  gap <- 15
  # Call the C function
  result <- .Call("_compress_mov", loc, time, gap)
  # Check structure: should be a list of 3 elements
  expect_type(result, "list")
  expect_length(result, 3)
  # Check that compressed locations are correct
  expect_equal(result[[1]], as.integer(c(1, 2, 1)))
  # Check that start and end times are correct
  expect_equal(result[[2]], c(0, 20, 40))
  expect_equal(result[[3]], c(10, 30, 50))
})

test_that("_flow_stat calculates flow statistics correctly", {
  # Example input: locations and times
  loc <- as.character(c("A", "A", "B", "B", "A", "A"))
  stime <- c(0, 20, 40)
  etime <- c(10, 30, 50)
  gap <- 15
  # Call the C function
  result <- .Call("_flow_stat", as.character(c("A", "B", "A")), stime, etime, gap)
  # Check structure: should be a list of 2 elements
  expect_type(result, "list")
  expect_length(result, 2)
  # Edges and flows
  expect_type(result[[1]], "character")
  expect_type(result[[2]], "integer")
}) 