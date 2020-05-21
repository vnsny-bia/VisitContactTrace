

#2. Header Code------------
myModal <- function() {
  div(id = "test",
      modalDialog(downloadButton("download1","Download Data as csv"),
                  # br(),
                  # br(),
                  # downloadButton("download2","Download Data as xlsx"),
                  easyClose = TRUE, title = "Download Table")
  )
}

jscode <- "shinyjs.closeWindow = function() { window.close(); }"


title_logo <-  tags$a(href='http://www.vnsny.org',
                      tags$img(src='www/logo.png',height='50',width='180'),style="color:white;","VisitContactTrace Application")
header <- dashboardHeader(title = title_logo,titleWidth = 500,


                          tags$li(a(onclick = "openTab('Data')",
                                    href = NULL,'',
                                    HTML('<i class="fa fa-user-md"></i>'),"Staff",
                                    title = "Staff",
                                    style = "cursor: pointer;  font-size: 16px;, face:bold; "),
                                  class = "dropdown active",
                                  id="clin_id",
                                  tags$style(".main-header .navbar {
                                                  margin-left: 500px;
                                              }

                                              .main-header .logo {
                                                  width: 500px;
                                              }
                                               "),
                                  tags$script(HTML("
                                       var openTab = function(tabName){
                                       $('a', $('.sidebar')).each(function() {
                                       if(this.getAttribute('data-value') == tabName) {
                                       this.click()
                                       };
                                       });
                                        }"))),

                          tags$li(a(onclick = "openTab('Data_Dictionary')",
                                    href = NULL,
                                    HTML("<i class='fas fa-procedures'></i>"),"Patient",
                                    title = "Patient",
                                    style = "cursor: pointer;font-size: 16px;, face:bold;"),
                                  class = "dropdown",
                                  id="pat_id",
                                  tags$script(HTML("
                                       var openTab = function(tabName){
                                       $('a', $('.sidebar')).each(function() {
                                       if(this.getAttribute('data-value') == tabName) {
                                       this.click()
                                       };
                                       });
                                       }"))),
                          VisitContactTrace:::dropdownActionMenu(id="refresh1",title= "",icon = icon("chevron-circle-down"),
                                                                 VisitContactTrace:::actionItem("refresh",tags$p(tags$i(class="fa fa-refresh fa-spin",style="font-size:14px"),HTML("&nbsp;")," Reload Data")),
                                                                 VisitContactTrace:::actionItem("quit",tags$p(tags$i(class="fas fa-window-close",style="font-size:14px"),HTML("&nbsp;")," Exit")),
                                                                 VisitContactTrace:::actionItem("github","Report Issue" ,icon = icon("exclamation-triangle"),onclick_event = "window.open('https://github.com/vnsny-bia/Visit-Contact-Tracing/issues', '_blank')")

                          )


)


#3. Sidebar Code------------

sidebar <-   dashboardSidebar(width = '600px',
                              textInput("text", ""),

                              sidebarMenu(
                                id = "tabs",
                                menuItem("Data", icon = icon("th"),tabName = "Data"),
                                menuItem("Data Dictionary", icon = icon("th"),tabName = "Data_Dictionary")

                              ),collapsed = T

)

body <- dashboardBody(

  #4 HTML/CSS styling tags---------------
 # tags$head(includeCSS("./www/style1.css")),
  tags$head(tags$link(href = "www/style.css", rel = "stylesheet")),
  tags$style('.dataTables_wrapper .dataTables_scroll {
    clear: both;
    color: black;
}'),
  tags$title('This is my page'),

  tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: #005daa}")),
  tags$style(".small-box.bg-yellow { background-color: #dee8d3 !important; color: #000000 !important; height:400px;
               overflow: hidden;
                    border-width: 0;
                    border-radius: 2px;
                    box-shadow: 0 4px 10px 0 rgba(0,0,0,.18), 0 2px 10px 0 rgba(0,0,0,.15);
                    -webkit-transition: all .25s cubic-bezier(.02,.01,.47,1);
                    transition: all .25s cubic-bezier(.02,.01,.47,1);
                    -webkit-transform: translateZ(0);}
             .alert-info, .bg-aqua, .callout.callout-info, .label-info, .modal-info .modal-body {
                    background-color: #dee8d3!important;
                    color:black; }
              #fluidbox1 * {
                    width: 100%;
                    height: 10%;
                    color: black; }"
  ),
  useShinyjs(),  # Set up shinyjs
  useShinyalert(),  # Set up shinyalert
  shinyjs::extendShinyjs(text = jscode, functions = c("closeWindow")),

  shinyjs::extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),

  tags$script(HTML( "$(document).ready(function(){
                                            $('.dropdown').click(function(e){
                                            		$('.navbar-nav .dropdown').removeClass('active')
                                            		$(this).addClass('active')
                                             });
                                          });")),
  tags$head(
    tags$style(
      HTML('.skin-blue .wrapper .main-header .navbar .navbar-custom-menu { float: left;}
                      .skin-blue .main-header .navbar .sidebar-toggle {display: none;}'))),



  tabItems(

    tabItem("Data",
            fluidRow(
              tabBox(id='main_data', width = 6, height = '620px',title = tagList(shiny::icon("table"),""),
                     tabPanel(tagList(shiny::icon("table"),"Input Data"),

                              fluidRow(box(width=12,height = '90px',


                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "clinic_id", label = "Staff ID :",
                                                 choices = c(''),
                                                 multiple = F ,
                                                 width='200px',

                                                 options = list(width=200, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "ref_date_id", label = "Reference Date :",
                                                 choices = c(''),
                                                 multiple = F,
                                                 selected = 'Nothing Selected' ,
                                                 width='150px',
                                                 options = list(width=150, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "days_diff_id", label = "# of Days to Look Back :",
                                                 choices = c(0:25),
                                                 selected = 0,
                                                 multiple = F,
                                                 options = list(width=125, `live-search`=TRUE),
                                                 width='125px'
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "days_frwd_id", label = "# of Days to Look forward :",
                                                 choices = c(0:30),
                                                 selected = 0,
                                                 multiple = F,
                                                 options = list(width=125, `live-search`=TRUE),
                                                 width='125px'
                                               )
                                           ),

                                           div(style="display:inline-block;padding-bottom:10px",
                                               actionBttn(
                                                 inputId = "go_btn",
                                                 label = "Run",
                                                 style = "material-flat",size = 'sm'
                                               )
                                           ),

                                           tags$head(
                                             tags$style(
                                               HTML(".shiny-notification {
                                                           height: 200px;
                                                           width: 400px;
                                                           position:fixed;
                                                           top: calc(50% - 50px);
                                                           left: calc(50% - 200px);
                                                           font-size: 250%;
                                                           text-align: center;
                                                           background-color:black;
                                                           color:#fff;
                                               }
                                                           .bttn-material-flat.bttn-default {
                                                              background: #231f20;
                                                              color: #ffffff;
                                                              width: 80px;
                                                              height: 32px;
                                                              margin-left: 4px;
                                                              top: 2px;
                                                          }
                                                           "
                                               )
                                             )
                                           )),
                                       verbatimTextOutput('visit_date_rng',placeholder = F),
                                       tags$head(
                                         tags$style(HTML("
                                                    #visit_date_rng {
                                                      padding: 9.5px;
                                                      margin: 0 0 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                      background-color: #f5f5f5;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      max-height: 550px;
                                                      overflow: auto;
                                                      width:736px;
                                                      background-color: #222527;
                                                  }
                                              "))),
                                       tags$style(HTML("<br>")),
                                       div(style="display: inline-block;",
                                           box(width=12,
                                               height = '425px',
                                               div(style = 'overflow-y: scroll; height:400px;',
                                                   HTML('<div class="header_csv"><center><p id="preloader6">
                                                                <span></span>
                                                                <span></span>
                                                                <span></span>
                                                                <span></span></p> </center>
                                                                <h4 align="left" style="color:#3c8dbc;"><u><b>Introduction</b> </u></h4>
                                                                <p>This application allows you to conduct HCHB visit-level contact tracing for a CHHA/Hospice patient or clinician known/suspected to have COVID-19 (“index person”). Based on VNSNY visit data, this application will list all primary, secondary, and tertiary clinician or patient contacts within a look-back time period for a given index person. You must comply with all applicable requirements and <a href="https://vnsny.sharepoint.com/COVID/SitePages/Homepage%20-%20COVID-19.aspx" target="_blank"> VNSNY’s COVID-19 Policies & Procedures </a> when conducting visit-based contact tracing.</p>
                                                                <h4 align="left" style="color:#3c8dbc;"><u><b>Instructions</b> </u></h4>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>First choose whether you are starting with a clinician or a patient by clicking the on the “clinician” or “patient” tile.</p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the reference date. Ideally, this should be the date of symptom onset for the index person. </p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the number of days to look back from the reference date. The application is designed to return all primary, secondary, and tertiary visit contacts of the index patient during the look-back period up until present day.</p>
                                                                   <table>
                                                                      <tr>
                                                                      <th></th>
                                                                      <th>If a clinician is the index person…</th>
                                                                      <th>If a patient is the index person…</th>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Primary contact</td>
                                                                      <td>The patients that the index clinician visited </td>
                                                                      <td>The clinicians that visited the index patient</td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Secondary contact</td>
                                                                      <td>The clinicians that visited the primary contact patients </td>
                                                                      <td>The patients that the primary contact clinicians visited </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Tertiary contact</td>
                                                                      <td>The patients that were visited by the secondary contact clinicians </td>
                                                                      <td>The clinicians that visited the secondary contact patients </td>
                                                                      </tr>

                                                                      </table><br>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the Clinician ID (or Patient ID) of the index person.</p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Click on the “run” button </p>

                                                                <center><br></center></div>


                                                   ')



                                               )




                                           ))),

                              div(style="display: inline-block; width: 800px;",HTML("<br>"))

                     )


              ),
              tabBox(id='conf_summary', width = 6,
                     height = '675px',
                     title = "",
                     tabPanel(tagList(HTML('<i class="fa fa-newspaper-o"></i>'),"Contact Lists"),
                              tabBox(id='stg_tbls',width = 12,
                                     title = "",
                                     tabPanel(tagList(shiny::icon("table"),"Primary Contact Patients"),
                                              downloadButton("download1","Download"),
                                              DT::dataTableOutput("stage_1_table")),
                                     tabPanel(tagList(shiny::icon("table"),"Secondary Contact Staffs"),
                                              downloadButton("download2","Download"),
                                              DT::dataTableOutput("stage_2_table")),
                                     tabPanel(tagList(shiny::icon("table"),"Tertiary Contact Patients"),
                                              downloadButton("download3","Download"),
                                              DT::dataTableOutput("stage_3_table"))
                              ),
                              value = 'stg_tbls'),
                     tabPanel(tagList(HTML('<i class="fa fa-group"></i>'),"Contact Tracing"),
                              div(style="display:inline-block;padding-upper:'0px';padding-left:'2px';overflow-y: auto;",
                                  conditionalPanel("input.go_btn > 0",verbatimTextOutput('print_txt',placeholder = F)),
                                  tags$head(tags$style(HTML("
                                                    #print_txt {
                                                      padding: 9.5px;
                                                      margin: 0 0 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                      background-color: #f5f5f5;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      max-height: 550px;
                                                      overflow: auto;
                                                      width:735px;
                                                      background-color: #222527;
                                                  }
                                              ")))
                              ),
                              value = 'model_perf1'),
                     tabPanel(tagList(shiny::icon("bar-chart-o"),"Plot"),
                              visNetworkOutput('plot_epicontacts',height = '550px'),
                              value = 'model_perf'),

                     tabPanel(tagList(HTML("<i class='fas fa-notes-medical'></i>"),"Visit Details"),
                              box(width=12,
                                  downloadButton("download4","Download"),
                                  withSpinner(DT::dataTableOutput("table_txt_tbl",height ="500px"),
                                              color = '#3c8dbc'),
                                  value = 'table_4')
                     )


              )

            )



    ),#End of data tab
    tabItem("Data_Dictionary",
            fluidRow(
              tabBox(id='main_data', width = 6, height = '600px',title = tagList(shiny::icon("table"),""),
                     tabPanel(tagList(shiny::icon("table"),"Input Data"),

                              fluidRow(box(width=12,height = '90px',


                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "patient_id", label = "Patient ID :",
                                                 choices = c(''),
                                                 multiple = F,
                                                 width='200px',
                                                 options = list(width=200, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "ref_date_id_1", label = "Reference Date :",
                                                 choices = c(''),
                                                 multiple = F,
                                                 selected = 'Nothing Selected',
                                                 width='150px',
                                                 options = list(width=150, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "days_diff_id_1", label = "# of Days to Look Back :",
                                                 choices = c(0:25),
                                                 selected = 0,
                                                 multiple = F,
                                                 width='125px',
                                                 options = list(width=125, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "days_frwd_id_1", label = "# of Days to Look forward :",
                                                 choices = c(0:25),
                                                 selected = 0,
                                                 multiple = F,
                                                 width='125px',
                                                 options = list(width=125, `live-search`=TRUE)
                                               )
                                           ),
                                           div(style="display:inline-block",
                                               actionBttn(
                                                 inputId = "go_btn_1",
                                                 label = "Run",
                                                 style = "material-flat",size = 'sm'
                                               )
                                           ),
                                           tags$head(
                                             tags$style(
                                               HTML(".shiny-notification {
                                                           height: 200px;
                                                           width: 400px;
                                                           position:fixed;
                                                           top: calc(50% - 50px);
                                                           left: calc(50% - 200px);
                                                           font-size: 250%;
                                                           text-align: center;
                                                           background-color:black;
                                                           color:#fff;
                                               }
                                                           table {
                                                            font-family: arial, sans-serif;
                                                            border-collapse: collapse;
                                                            width: 100%;
                                                          }

                                                          td, th {
                                                            border: 1px solid black;
                                                            text-align: left;
                                                            padding: 8px;
                                                          }

                                                          tr:nth-child(even) {
                                                            background-color: #dddddd;
                                                          }
                                                           "
                                               )
                                             )
                                           )),
                                       tags$style(HTML("<br>")),
                                       verbatimTextOutput('visit_date_rng_1',placeholder = F),
                                       tags$head(
                                         tags$style(HTML("
                                                    #visit_date_rng_1 {
                                                      padding: 9.5px;
                                                      margin: 0 0 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                      background-color: #f5f5f5;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      max-height: 550px;
                                                      overflow: auto;
                                                      width:736px;
                                                      background-color: #222527;
                                                  }
                                              "))),
                                       tags$style(HTML("<br>")),

                                       div(style="display: inline-block;",
                                           box(width=12,
                                               height = '425px',
                                               div(style = 'overflow-y: scroll; height:400px;',

                                                   #New Addition-----

                                                   HTML('<div class="header_csv"><center><p id="preloader6">
                                                                <span></span>
                                                                <span></span>
                                                                <span></span>
                                                                <span></span></p> </center>
                                                                <h4 align="left" style="color:#3c8dbc;"><u><b>Introduction</b> </u></h4>
                                                                <p>This application allows you to conduct HCHB visit-level contact tracing for a CHHA/Hospice patient or clinician known/suspected to have COVID-19 (“index person”). Based on VNSNY visit data, this application will list all primary, secondary, and tertiary clinician or patient contacts within a look-back time period for a given index person. You must comply with all applicable requirements and <a href="https://vnsny.sharepoint.com/COVID/SitePages/Homepage%20-%20COVID-19.aspx" target="_blank"> VNSNY’s COVID-19 Policies & Procedures </a> when conducting visit-based contact tracing.</p>
                                                                <h4 align="left" style="color:#3c8dbc;"><u><b>Instructions</b> </u></h4>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>First choose whether you are starting with a clinician or a patient by clicking the on the “clinician” or “patient” tile.</p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the reference date. Ideally, this should be the date of symptom onset for the index person. </p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the number of days to look back from the reference date. The application is designed to return all primary, secondary, and tertiary visit contacts of the index patient during the look-back period up until present day.</p>
                                                                   <table>
                                                                      <tr>
                                                                      <th></th>
                                                                      <th>If a clinician is the index person…</th>
                                                                      <th>If a patient is the index person…</th>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Primary contact</td>
                                                                      <td>The patients that the index clinician visited </td>
                                                                      <td>The clinicians that visited the index patient</td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Secondary contact</td>
                                                                      <td>The clinicians that visited the primary contact patients </td>
                                                                      <td>The patients that the primary contact clinicians visited </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Tertiary contact</td>
                                                                      <td>The patients that were visited by the secondary contact clinicians </td>
                                                                      <td>The clinicians that visited the secondary contact patients </td>
                                                                      </tr>

                                                                      </table><br>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Choose the Clinician ID (or Patient ID) of the index person.</p>
                                                                <p> <i style="font-size:18px; color:#3c8dbc;" class="fa">&#xf0a4;</i>Click on the “run” button </p>

                                                                <center><br></center></div>


                                                   ')

                                               )




                                           ))),




                              div(style="display: inline-block; width: 800px;",HTML("<br>"))

                     )


              ),
              tabBox(id='conf_summary_1', width = 6,
                     height = '645px',
                     title = "",

                     tabPanel(tagList(HTML('<i class="fa fa-newspaper-o"></i>'),"Contact Lists"),
                              tabBox(id='stg_tbls_1',width = 12,
                                     title = "",
                                     tabPanel(tagList(shiny::icon("table"),"Primary Contact Staffs"),
                                              downloadButton("download5","Download"),
                                              DT::dataTableOutput("stage_1_table_1")),
                                     tabPanel(tagList(shiny::icon("table"),"Secondary Contact Patients"),
                                              downloadButton("download6","Download"),
                                              DT::dataTableOutput("stage_2_table_1")),
                                     tabPanel(tagList(shiny::icon("table"),"Tertiary Contact Staffs"),
                                              downloadButton("download7","Download"),
                                              DT::dataTableOutput("stage_3_table_1"))
                              ),

                              value = 'stg_tbls'),
                     tabPanel(tagList(HTML('<i class="fa fa-group"></i>'),"Contact Tracing"),
                              div(style="display:inline-block;padding-upper:'0px';padding-left:'2px';overflow-y: auto;",
                                  conditionalPanel("input.go_btn_1 > 0",verbatimTextOutput('print_txt_1',placeholder = F)),
                                  tags$head(tags$style(HTML("
                                                    #print_txt_1 {
                                                      padding: 9.5px;
                                                      margin: 0 0 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                      background-color: #f5f5f5;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      max-height: 550px;
                                                      overflow: auto;
                                                      width:735px;
                                                      background-color: #222527;
                                                  }
                                              ")))
                              ),

                              value = 'model_perf'),
                     tabPanel(tagList(shiny::icon("bar-chart-o"),"Plot"),
                              visNetworkOutput('plot_epicontacts_1',height = '550px'),
                              value = 'model_perf'),
                     tabPanel(tagList(HTML("<i class='fas fa-notes-medical'></i>"),"Visit Details"),
                              box(width=12,
                                  downloadButton("download8","Download"),
                                  withSpinner(DT::dataTableOutput("table_txt_tbl_1",height ="500px"),
                                              color = '#3c8dbc'),
                                  value = 'table_4'))
              )

            )



    ) #End of patient tab

  ) #End of main Tab items

)# End of Body


#5. Calling shiny app components together------------


ui = dashboardPage(title = 'Contact Tracing',
    header,
    sidebar,
    body
  )