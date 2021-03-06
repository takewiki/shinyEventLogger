library(shiny)
library(shinyEventLogger)

  set_logging(
    # Logging to R console
    r_console  = TRUE,
    # Logging to browser JavaScript console
    js_console = TRUE,
    # Logging to file if exists
    file       = ifelse(file.exists("events.log"), TRUE, FALSE),
    # Logging to database if exists
    database   = ifelse(file.exists(".db_url"),    TRUE, FALSE),

    # Adding app build version as a global parameter to all events
    build      = 140L
    )

ui <- fluidPage(

  # Initiate shinyEventLogger JavaScripts
  log_init(),

  titlePanel("ShinyEventLogger: DEMO APP"),

  sidebarLayout(

    sidebarPanel(width = 3,

      selectInput("dataset", "Dataset:",
                  choices = c("faithful", "mtcars", "iris", "random"),
                  selected = "iris"),

      selectInput("variable", "Variable:",
                  choices = ""),

      sliderInput("bins", "Number of bins:",
                  min = 1, max = 50, value = 10),

      p(style = "height: 400px")

    ),

    mainPanel(

      tabsetPanel(type = "pills",

        tabPanel(title = "Histogram", plotOutput("histogram"))

      )
    )
  )
) # end of ui

server <- function(input, output, session) {

  set_logging_session()

  log_event("App (re)started")

  dataset <- reactive({

    req(input$dataset)

    # Setting local logging parameters
    log_params(resource = "dataset",
               fun      = "reactive",
               dataset  = input$dataset)

    # Starting timing the event
    log_started("Loading dataset")

      if (input$dataset == "random") {

        dataset <- data.frame("RandomValue" = rnorm(n = 500000))

      } else {

        dataset <- eval(base::parse(text = input$dataset))

      }

    # Stopping timing the event
    log_done("Loading dataset")

    # Logging a value of number of rows
    log_value(NROW(dataset), params = list(n_rows = NROW(dataset)))

    # Logging function output
    log_output(str(dataset))

    # Logging data.frame
    log_output(head(dataset))

    dataset

  })

  observeEvent(input$dataset, {

    log_params(resource = "input$dataset",
               fun = "observer",
               dataset = input$dataset)

    # Logging arbitratry named event with value in output
    log_event(input$dataset, name = "Dataset was selected")
    # Logging the same value using deparsed expression as event name
    log_value(input$dataset)

    updateSelectInput(session, "variable",
                      choices = names(dataset()))

  })

  observeEvent(input$variable, {

    log_params(resource = "input$variable",
               fun = "observer",
               dataset = input$dataset)

    log_event(input$variable, name = "Variable was selected")
    log_value(input$variable)

  })

  output$histogram <- renderPlot(height = 600, {

    req(input$variable)
    req(input$bins)

    log_params(resource = "output$histogram",
               fun = "rendering",
               dataset = input$dataset)

    # Debugging the error:
      # Error in [.data.frame: undefined columns selected
      # while changing datasets

      # log_value(names(dataset()))
      # log_value(input$variable)

    # Fixing the error
    req(input$variable %in% names(dataset()))

    x <- dataset()[, input$variable]

    # Logging inside-app unit test
    # This one logs silent error when variable Species from iris is selected.
    log_test(testthat::expect_is(x, "numeric"),
             params = list('variable' = input$variable))

    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    log_event("Plotting histogram")

    hist(x,
         breaks = bins,
         col = 'darkgray',
         border = 'white',
         main = paste0("Histogram of ", input$variable)
         )

   })

   observe({

     log_params(resource = "input$bins",
                fun = "observer",
                dataset = input$dataset)

     # Logging current input value
     log_value(input$bins)

     # Logging conditional named event
     if (input$bins < 20)
       log_event(name = "Number of bins are safe", input$bins)

     # Logging and rising a diagnostic message
     if (input$bins >= 30 & input$bins < 40)
       log_message("50 bins are comming...")

     # Logging and rising a non-critical warning
     if (input$bins >= 40 & input$bins < 50)
       log_warning("Very close to 50 bins!")

     log_test(testthat::expect_lt(input$bins, 50),
              params = list(bins = input$bins))
          # Logging and rising a critical error
     if (input$bins == 50) {

       log_error("50 bins are not allowed!")

     }

   })


} # end of server

shinyApp(ui = ui, server = server)
