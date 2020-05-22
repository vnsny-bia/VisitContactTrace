.onAttach <- function(libname, pkgname) {
  shiny::addResourcePath('www',
                         system.file('www',
                                     package = 'VisitContactTrace'))
}



dropdownActionMenu <- function (..., id="menu",title=NULL, icon = NULL, .list = NULL, header=NULL) {
  items <- c(list(...), .list)
  lapply(items, shinydashboard:::tagAssert, type = "li")
  type <- "notifications" # TODO créer action + CSS
  dropdownClass <- paste0("dropdown ", type, "-menu")
  tags$li(id=id,class = dropdownClass, a(href = "#", class = "dropdown-toggle",
                                         `data-toggle` = "dropdown", icon, title), tags$ul(class = "dropdown-menu",
                                                                                           if(!is.null(header)) tags$li(class="header",header),
                                                                                           tags$li(tags$ul(class = "menu", items))))
}

actionItem = function (inputId, text, icon = NULL, tabSelect=FALSE,onclick_event=NULL) {
  if(!is.null(icon)) {
    shinydashboard:::tagAssert(icon, type = "i")
    icon <- tagAppendAttributes(icon, class = paste0("text-", "success"))
  }
  if(tabSelect) {
    tags$li(a(onclick=paste0("shinyjs.tabSelect('",inputId,"')"),icon,text))
  } else {
    tags$li(actionLink(inputId,text,icon))
  }
  if(!is.null(onclick_event)){
    tags$li(a(onclick=paste0(onclick_event),icon,text))
  } else {
    tags$li(actionLink(inputId,text,icon))
  }

}


cases_pal <- function (n)
{
  if (!is.numeric(n)) {
    stop("n is not a number")
  }
  n <- as.integer(n)
  colors <- c("#005082", "#ffa41b")
  if (n < length(colors)) {
    return(colors[seq_len(n)])
  }
  else {
    return((grDevices::colorRampPalette(colors))(n))
  }
}


jscode <- "shinyjs.closeWindow = function() { window.close(); }"

