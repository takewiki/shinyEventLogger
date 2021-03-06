% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log_wrappers.R
\name{log_message}
\alias{log_message}
\alias{log_warning}
\alias{log_error}
\title{Logging a message}
\usage{
log_message(...)

log_warning(...)

log_error(...)
}
\arguments{
\item{...}{Objects that are evaluated, coerced into character string,
collapsed and pasted as event name into log entry header.
The character string is also passed to the
message, warning, or error raised.}
}
\description{
\code{log_message}, \code{log_warning}, and \code{log_error} are
wrapper functions for logging events of type
\code{MESSAGE}, \code{WARNING}, or \code{ERROR}.
Relevant message, warning or error is raised after logging an event.
Raising an error is done using \code{\link{stop}} function
and it can stop the whole shiny app.
}
\section{Functions}{
\itemize{
\item \code{log_message}: Logging a message

\item \code{log_warning}: Logging a warning

\item \code{log_error}: Logging an error
}}

\examples{
\dontrun{

if (interactive()) {
  set_logging()
  shiny::shinyApp(
    ui = shiny::fluidPage(log_init()),
    server = function(input, output) {
      set_logging_session()
      log_message("Example of a message")
      log_warning("Example of a warning")
      log_error("Example of an error")
    }
  )
}
}
}
\seealso{
Other logging events functions: \code{\link{log_event}},
  \code{\link{log_output}}, \code{\link{log_started}},
  \code{\link{log_test}}, \code{\link{log_value}}
}
\concept{logging events functions}
