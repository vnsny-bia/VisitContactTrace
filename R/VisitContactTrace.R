#' A contact tracing application built to consume healthcare encounter data.
#'
#' @param viewer By default is opens up application in Browser. Options ('browser','pane','dialog')
#' @export

VisitContactTrace <- function(viewer = "browser") {


  if (viewer == "browser") {
    inviewer <- browserViewer(browser = getOption("browser"))
  } else if (viewer == "pane") {
    inviewer <- paneViewer(minHeight = "maximize")
  } else if (viewer == "dialog"){
    inviewer <- dialogViewer(
      "VNSNYCT",width=1350,height=1300

    )
  }

  appDir <- system.file("shiny-app", "app", package = "VisitContactTrace")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `VisitContactTrace`.", call. = FALSE)
  }


  shiny::runGadget(shiny::shinyAppDir(appDir = appDir),
                   viewer = inviewer
  )
}
