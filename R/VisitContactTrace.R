#' A contact tracing application built to consume healthcare encounter data.
#'
#' @param viewer By default is opens up application in Browser. Options ('browser','pane','dialog')
#' @param browserURL By default is NULL and is used to provide custom browser path for shiny app.
#' @export

VisitContactTrace <- function(viewer = "browser",browserURL=NULL) {


  if (viewer == "browser") {
    if(is.null(browserURL)){
      inviewer <- browserViewer(browser = getOption("browser"))
    } else{
      
      inviewer <- browserViewer(browser = browserURL)
      
    }
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
