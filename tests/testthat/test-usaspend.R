test_that("Expected USAspending results", {
  suppressMessages(vcr::use_cassette("usaspend", {
    usa <- .usaspend_standardize("test", "2012-01-01", "2014-01-01")
  }))
  expect_equal(usa$id[1], "S330B130017")
})
