# need to find problems on windows

test_that("NEH returns expected results", {
 suppressMessages(vcr::use_cassette("neh", {
   neh <- .neh_standardize("qualitative", "2019-01-01", "2020-01-01")
  }))
  expect_equal("FO-273176-21", neh$id[1])
})
