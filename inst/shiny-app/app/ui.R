

#2. Header Code------------
myModal <- function() {
  div(id = "test",
      modalDialog(downloadButton("download1","Download Data as csv"),
                  easyClose = TRUE, title = "Download Table")
  )
}

jscode <- "shinyjs.closeWindow = function() { window.close(); }"


title_logo <-  tags$a(href='http://www.vnsny.org',target="_blank",
                      tags$img(src='www/VNSNY_BB.jpg',height='55'),style="color:#005daa;","VisitContactTrace Application")
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
                                                                 VisitContactTrace:::actionItem("refresh",tags$h4(style="color:black;",tags$i(class="fa fa-refresh fa-spin",style="font-size:16px"),HTML("&nbsp;")," Load New Dataset")),
                                                                 VisitContactTrace:::actionItem("github",tags$h4(style="color:black;",tags$i(class="fa fa-exclamation-circle",style="font-size:16px"),HTML("&nbsp;")," Report Issue"),onclick_event = "window.open('https://github.com/vnsny-bia/VisitContactTrace/issues', '_blank')"),
                                                                 VisitContactTrace:::actionItem("quit",tags$h4(style="color:black;",tags$i(class="fas fa-window-close",style="font-size:16px"),HTML("&nbsp;")," Exit"))

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
 tags$head(tags$script('
                        var width = 0;
                        $(document).on("shiny:connected", function(e) {
                          width = window.innerWidth;
                          Shiny.onInputChange("width", width);
                        });
                        $(window).resize(function(e) {
                          width = window.innerWidth;
                          Shiny.onInputChange("width", width);
                        });
                        ')),
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
              tabBox(id='main_data', width = 6, 
                     height = '700px',
                     title = tagList(shiny::icon("table"),""),
                     tabPanel(tagList(shiny::icon("table"),"Input Data"),

                              fluidRow(box(width=12,


                                           div(style="display:inline-block",
                                               pickerInput(
                                                 inputId = "clinic_id", label = "Staff ID :",
                                                 choices = c(''),
                                                 multiple = F ,
                                                 width='200px',

                                                 options = list(width=200, `live-search`=TRUE)
                                               )
                                           ),
                                           
                                           div(style="display:inline-block;",
                                               dateInput(
                                                 inputId = "ref_date_id",
                                                 label = "Reference Date :",width='150px'
                                               )
                                           ),
                                           # div(style="display:inline-block;top:-30px;position:relative;",
                                           #     airDatepickerInput(inputId = "ref_date_id",
                                           #                        label = "Reference Date :",
                                           #                        width='150px')
                                           # ),
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

                                           div(style="display:inline-block;padding-bottom:10px;",
                                               actionBttn(
                                                 inputId = "go_btn",
                                                 label = "Run",
                                                 style = "material-flat",size = 'sm'
                                               )
                                           ),
                                           # tags$br(),
                                           div(id="verbtext",fluidRow(verbatimTextOutput('visit_date_rng',placeholder = F))),
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
                                                              background: #005daa;
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
                                       tags$head(tags$style(HTML("
                                        #license_txt { 
                                        display: block;
                                        font-size: 13px;
                                        line-height: 1.42857143;
                                        color: white;
                                        word-break: break-all;
                                        word-wrap: break-word;
                                        background-color: #005daa;
                                        border: 1px solid #ccc;
                                        border-radius: 4px;
                                        max-height: 560px;
                                        }
                                        "))),
                                       tags$head(
                                         tags$style(HTML("
                                                    #visit_date_rng {
                                                      padding: 9.5px;
                                                      margin: 0 25px 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      overflow: auto;
                                                      background-color: #005daa;
                                                  }
                                              "))),
                                       # tags$style(HTML("<br>")),

                                       div(style="display: inline-block;",
                                           box(width=12,
                                               #height = '300px',
                                               div(style = 'overflow-y: scroll; height:350px;',
                                                   HTML('<div class="header_csv"><center><p id="preloader6">
                                                                <span></span>
                                                                <span></span>
                                                                <span></span>
                                                                <span></span></p> </center>
                                                                <h4 align="left" style="color:#005daa;"><u><b>Introduction</b> </u></h4>
                                                                <p style="font-size:14px;font-family: Arial, Sans-Serif">This application allows you to conduct visit-level contact tracing for a patient or staff member known/suspected to have an infectious disease (“index person”). Based on the visit data you supply, this application will list all primary, secondary, and tertiary patient or staff contacts within a look-back time period for a given index person.</p>
                                                                <h4 align="left" style="color:#005daa;"><u><b>Instructions</b> </u></h4>
                                                                
                                                            
                                                              
                                                             <ul class="fa-ul">
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> First choose whether you are starting with an index staff member or a patient by clicking the on the “Staff” or “Patient” tile.</li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the Staff ID (or Patient ID) of the index person. </li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the reference date. Ideally, this should be the date of symptom onset of the index person. </li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the number of days to look back from the reference date (e.g. the incubation period of the disease) and the number of days to look forward from the reference date.</li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Click on the “run” button.</li>
                                                                </ul>

                                                                <table class= "beta" style="font-size:14px;font-family: Arial, Sans-Serif">
                                                                      <tr>
                                                                      <th></th>
                                                                      <th>If a staff member is the index person…</th>
                                                                      <th>If a patient is the index person… </th>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Primary contact</td>
                                                                      <td>The patients that the index staff member visited </td>
                                                                      <td>The staff members that visited the index patient </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Secondary contact</td>
                                                                      <td>The staff members that visited the primary contact patients  </td>
                                                                      <td>The patients that the primary contact staff members visited </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Tertiary contact</td>
                                                                      <td>The patients that were visited by the secondary contact staff members </td>
                                                                      <td>The staff members that visited the secondary contact patients  </td>
                                                                      </tr>

                                                                      </table><br>
                                                                
                                                                <center><br></center></div>


                                                   ')



                                               )




                                           ))),

                              div(style="display: inline-block;",HTML("<br>"))

                     )


              ),
              tabBox(id='conf_summary', width = 6,
                     height = '700px',
                     title = "",
                     tabPanel(tagList(shiny::icon("bar-chart-o"),"Plot"),
                              visNetworkOutput('plot_epicontacts',height = '550px'
                                               ),
                              value = 'model_perf'),
                     tabPanel(tagList(HTML('<i class="fa fa-newspaper-o"></i>'),"Contact Lists"),
                              tabBox(id='stg_tbls',width = 12,
                                     title = "",
                                     tabPanel(tagList(shiny::icon("table"),"Primary Contact Patients"),
                                              downloadButton("download1","Download"),
                                              DT::dataTableOutput("stage_1_table")),
                                     tabPanel(tagList(shiny::icon("table"),"Secondary Contact Staff"),
                                              downloadButton("download2","Download"),
                                              DT::dataTableOutput("stage_2_table")),
                                     tabPanel(tagList(shiny::icon("table"),"Tertiary Contact Patients"),
                                              downloadButton("download3","Download"),
                                              DT::dataTableOutput("stage_3_table"))
                              ),
                              value = 'stg_tbls'),
                   
                     tabPanel(tagList(HTML("<i class='fas fa-notes-medical'></i>"),"Visit Details"),
                              box(width=12,
                                  downloadButton("download4","Download"),
                                  withSpinner(DT::dataTableOutput("table_txt_tbl",height ="500px"),
                                              color = '#005daa'),
                                  value = 'table_4')
                     )


              )

            )



    ),#End of data tab
    tabItem("Data_Dictionary",
            fluidRow(
              tabBox(id='main_data', width = 6, 
                     height = '700px',title = tagList(shiny::icon("table"),""),
                     tabPanel(tagList(shiny::icon("table"),"Input Data"),

                              fluidRow(box(width=12,


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
                                             dateInput(inputId = "ref_date_id_1",
                                                       label = "Reference Date :",
                                                       width='150px')
                                           ),
                                           # div(style="display:inline-block;top:-30px;position:relative;",
                                           #     airDatepickerInput(inputId = "ref_date_id_1",
                                           #                        label = "Reference Date :",
                                           #                        width='150px')
                                           # ),
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
                                           div(style="display:inline-block;padding-bottom:10px;",
                                               actionBttn(
                                                 inputId = "go_btn_1",
                                                 label = "Run",
                                                 style = "material-flat",size = 'sm'
                                               )
                                           ),
                                           div(id="verbtext_1",fluidRow(verbatimTextOutput('visit_date_rng_1',placeholder = F))),
                                           
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
                                                           .beta table {
                                                            font-family: arial, sans-serif;
                                                            border-collapse: collapse;
                                                            width: 100%;
                                                          }

                                                         .beta td, th {
                                                            border: 1px solid black;
                                                            text-align: left;
                                                            padding: 8px;
                                                          }

                                                         .beta tr:nth-child(even) {
                                                            background-color: #dddddd;
                                                          }
                                                           "
                                               )
                                             )
                                           )
                                           ),
                                       
                                       #tags$style(HTML("<br>")),
                                       #verbatimTextOutput('visit_date_rng_1',placeholder = F),
                                       tags$head(
                                         tags$style(HTML("
                                                    #visit_date_rng_1 {
                                                      padding: 9.5px;
                                                      margin: 0 25px 10px;
                                                      margin-left: 14px;
                                                      font-size: 13px;
                                                      line-height: 1.42857143;
                                                      color: #fff;
                                                          word-break: break-all;
                                                      word-wrap: break-word;
                                                          border: 1px solid #ccc;
                                                      border-radius: 4px;
                                                      max-height: 550px;
                                                      overflow: auto;
                                                      /*width:700px;*/
                                                      background-color: #005daa;
                                                  }
                                              "))),
                                       
                                       div(style="display: inline-block;",
                                           box(width=12,
                                               height = '350px',
                                               div(style = 'overflow-y: scroll; height:400px;',

                                                   #New Addition-----

                                                   HTML('<div class="header_csv"><center><p id="preloader6">
                                                                <span></span>
                                                                <span></span>
                                                                <span></span>
                                                                <span></span></p> </center>
                                                                <h4 align="left" style="color:#005daa;"><u><b>Introduction</b> </u></h4>
                                                                <p style="font-size:14px;font-family: Arial, Sans-Serif">This application allows you to conduct visit-level contact tracing for a patient or staff member known/suspected to have an infectious disease (“index person”). Based on the visit data you supply, this application will list all primary, secondary, and tertiary patient or staff contacts within a look-back time period for a given index person.</p>
                                                                <h4 align="left" style="color:#005daa;"><u><b>Instructions</b> </u></h4>
                                                                
                                                            
                                                             <ul class="fa-ul">
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> First choose whether you are starting with an index staff member or a patient by clicking the on the “Staff” or “Patient” tile.</li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the Staff ID (or Patient ID) of the index person. </li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the reference date. Ideally, this should be the date of symptom onset of the index person. </li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Choose the number of days to look back from the reference date (e.g. the incubation period of the disease) and the number of days to look forward from the reference date.</li>
                                                                <li style="font-size:14px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle" style="font-size:10px;color:#005daa;"></i> Click on the “run” button.</li>
                                                                </ul>

                                                                <table class="beta" style="font-size:14px;font-family: Arial, Sans-Serif">
                                                                      <tr>
                                                                      <th></th>
                                                                      <th>If a staff member is the index person…</th>
                                                                      <th>If a patient is the index person… </th>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Primary contact</td>
                                                                      <td>The patients that the index staff member visited </td>
                                                                      <td>The staff members that visited the index patient </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Secondary contact</td>
                                                                      <td>The staff members that visited the primary contact patients  </td>
                                                                      <td>The patients that the primary contact staff members visited </td>
                                                                      </tr>
                                                                      <tr>
                                                                      <td>Tertiary contact</td>
                                                                      <td>The patients that were visited by the secondary contact staff members </td>
                                                                      <td>The staff members that visited the secondary contact patients  </td>
                                                                      </tr>

                                                                      </table><br>
                                                                
                                                                <center><br></center></div>


                                                   ')
                                               )
                                           ))),
                              div(style="display: inline-block;",HTML("<br>"))
                     )

              ),
              tabBox(id='conf_summary_1', width = 6,
                     height = '700px',
                     title = "",
                     tabPanel(tagList(shiny::icon("bar-chart-o"),"Plot"),
                              visNetworkOutput('plot_epicontacts_1',height = '550px'),
                              value = 'model_perf'),
                     tabPanel(tagList(HTML('<i class="fa fa-newspaper-o"></i>'),"Contact Lists"),
                              tabBox(id='stg_tbls_1',width = 12,
                                     title = "",
                                     tabPanel(tagList(shiny::icon("table"),"Primary Contact Staff"),
                                              downloadButton("download5","Download"),
                                              DT::dataTableOutput("stage_1_table_1")),
                                     tabPanel(tagList(shiny::icon("table"),"Secondary Contact Patients"),
                                              downloadButton("download6","Download"),
                                              DT::dataTableOutput("stage_2_table_1")),
                                     tabPanel(tagList(shiny::icon("table"),"Tertiary Contact Staff"),
                                              downloadButton("download7","Download"),
                                              DT::dataTableOutput("stage_3_table_1"))
                              ),

                              value = 'stg_tbls'),
                   
                     
                     tabPanel(tagList(HTML("<i class='fas fa-notes-medical'></i>"),"Visit Details"),
                              box(width=12,
                                  downloadButton("download8","Download"),
                                  withSpinner(DT::dataTableOutput("table_txt_tbl_1",height ="500px"),
                                              color = '#005daa'),
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
