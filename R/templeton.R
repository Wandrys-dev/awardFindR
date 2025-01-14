#' Scrape the Templeton grants database from html to a data.frame
#' @return A data.frame
#' @export
#' @examples
#' \dontrun{templeton <- templeton_df()}
templeton_df <- function() {
  url <- "https://www.templeton.org/grants/grant-database"
  html <- request(url, "get")
  table <- xml2::xml_find_first(html, "//table[@id='grants-table']/tbody")
  # Capture the table headers
  vars <- xml2::xml_text(xml2::xml_find_all(table, "//thead//th/text()"))
  entries <- xml2::xml_children(table)

  full <- lapply(entries, function(x) {
    info <- xml2::xml_text(xml2::xml_find_all(x, ".//td"))
    data.frame(t(info), stringsAsFactors = FALSE)
  })
  full <- do.call(rbind.data.frame, full)
  names(full) <- vars # Use the captured table headers
  full$link <- xml2::xml_text(xml2::xml_find_all(entries, ".//td/a/@href"))

  full$Featured <- NULL
  # Get rid of all the $ and commas
  full$`Grant Amount` <- gsub("^\\$|,", "", full$`Grant Amount`)

  full
}

#' Search for a set of keywords in the Templeton grants database.
#' @param keywords vector of keywords to query
#' @param from_year Beginning year to search
#' @param to_year Ending year to search
#' @return A data.frame
#' @export
#' @examples
#' \dontrun{
#' templeton <- templeton_get(c("qualitative data", "case studies"), 2018, 2020)
#' }
templeton_get <- function(keywords, from_year, to_year) {
  url <- "https://www.templeton.org/?limit=500&s="
  links <- lapply(keywords, function(keyword) {
    response <- request(paste0(url, xml2::url_escape(keyword)), "get")

    link <- xml2::xml_text(
      xml2::xml_find_all(response, "//h2/a[@rel='bookmark']/@href"))

    if (length(link)==0) {
      return(NULL)
    }
    data.frame(keyword, link, stringsAsFactors = FALSE)
  })
  links <- do.call(rbind.data.frame, links)
  if (nrow(links)==0) {
    return(NULL)
  }

  all <- templeton_df()
  vars <- c("year", "id", "title", "pi", "grantee",
            "amount", "area", "region", "link")
  names(all) <- vars

  selected <- merge(links, all, by="link")
  year <- NULL # For R CMD check
  subset(selected, from_year <= year & to_year >= year)
}

.templeton_standardize <- function(keywords, from_date, to_date) {
  raw <- templeton_get(keywords,
                       format.Date(from_date, "%Y"), format.Date(to_date, "%Y"))
  if (is.null(raw)) {
    return(NULL)
  }

  if (nrow(raw)==0) {
    return(NULL)
  }

  with(raw, data.frame(
    institution=grantee, pi, year, start=NA, end=NA, program=area, amount,
    id, title, abstract=NA, keyword, source="Templeton",
    stringsAsFactors = FALSE
  ))

}
