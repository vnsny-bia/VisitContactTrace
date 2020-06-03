#6. Server Script Starts here------------

upload_button_style= 'border-radius: 0px;
                      moz-border-radius: 4px;
                      webkit-border-radius: 4px;

                      align:right;
                      height:40px;
                      width:150px;
                      display: inline-block;
                      border: none;
                      margin: 0;
                      margin-left: 38%;
                      margin-right: 38%;
                      text-decoration: none;
                      color: #ffffff;
                      font-size: 14px;
                      background-color:#005daa;
                      border-top-color: #005daa;'



upload_button_style1='margin: 0;
                      padding: 0;
                      border-color: transparent;
                      background: transparent;
                      font-weight: 400;
                      cursor: pointer;
                      position: relative;
                      font-size: 20px;
                      font-family: inherit;
                      padding: 5px 12px;
                      overflow: hidden;
                      border-width: 0;
                      border-radius: 2px;
                      background: #fff;
                        box-shadow: 0 2px 5px 0 rgba(0,0,0,.18), 0 1px 5px 0 rgba(0,0,0,.15);
                      -webkit-transition: all .25s cubic-bezier(.02,.01,.47,1);
                      transition: all .25s cubic-bezier(.02,.01,.47,1);
                      -webkit-transform: translateZ(0);
                      background-color:#3e4146d4;
                      text-decoration: none;
                      color: #ffffff;
                      font-size: 14px; width:100%;

                      transform: translateZ(0);'

#1. Server Script Starts here------------


server = function(input, output,session) {

  #_1.1 Refresh Button observeEvent -----
  observeEvent(input$refresh, {
    shinyjs::js$refresh()
  })

  #_1.2 Exit Button observeEvent -----
  observeEvent(input$quit,{
    js$closeWindow()
    shiny::stopApp()

  })

  #_1.3 Initial Data Upload Modal Dialog Box -----

  observeEvent(input$accept_btn,{
    showModal( modalDialog(
    title =HTML(paste0('<div class="basic_dwnld"> 
    <center><img src="www/VNSNY_single_bb.jpg" alt="Data Preview"  height="100" align="center"></center>

    <h2 align="center",style="color:#005daa; margin-top:-50px;">
    <i style="font-size:24px;color:rgb(255, 164, 27); class="fas fa-project-diagram"></i>
                  VisitContactTrace Application </h2>
                      <h3 align="center" style="color:#005daa;"><i class="fas fa-cloud-upload-alt" style="font-size:26px;color:#005daa;"></i>&ensp;Upload Data</h3>
      <br>
      <ul class="fa-ul">
        <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Please upload visit data file (.CSV or .XLSX) by clicking on the “Choose Data File” button.</li>
        <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Make sure the file contains the following columns: PATIENT_ID, PATIENT_NAME (required), VISIT_DATE (required), STAFF_ID, STAFF_NAME (required), PATIENT_STATUS, STAFF_STATUS</li>
        <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i> Click on the “View Selected File” button to review your uploaded data file and to rename columns</li>
        <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Click on the “Use Selected File” button when you are ready to display your data in the application.</li>
      </ul>
      <center>  <ui style="background-color:tomato;"><b>&#x26A0; Acceptable File Format/Type: .CSV/.XLSX </b> </ui><br></center></div><center><h4> Selected File Path : </h4>',textOutput('file_name_output'),'</center>')),
    footer=list(actionButton("demo", label="Try out demo data"),modalButton("Close")),
    list(shinyFilesButton(id = 'file', 'Choose Data File', 'Please select a file', FALSE,style = upload_button_style),  tags$br(),
         div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:95px; ",
             disabled(actionButton(inputId = 'review_btn',label= 'View Selected File',style = upload_button_style))),
         div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:60px; ",
             disabled(actionButton(inputId = 'submit_init',label= 'Use Selected File',style = upload_button_style)))

    )
  ))
  })
  
  
  output$license_txt <- renderPrint({
    rawText <- readLines(system.file('www','LICENSE',package = 'VisitContactTrace'))
    cat(rawText,sep = '\n')
  })
  

  showModal( modalDialog(
    title =  HTML(paste0("<center><h3> License Information </h3></center>",verbatimTextOutput('license_txt'))),
    
    footer=list(actionButton("accept_btn", label="Accept"),actionButton("decline_btn", label="Decline"))
  ))
  
 
  
  observeEvent(input$decline_btn,{
    js$closeWindow()
    shiny::stopApp()
    
  })

  #_1.4 Enable/Disable logic for upload file(ShinyFile) button -----

  observeEvent(input$file,{
    shinyjs::enable(id='submit_init')
    Sys.sleep(0.01)
    shinyjs::enable(id='review_btn')
  })



  #_1.5 Read Data logic using Upload button -----

  if(.Platform$OS.type == "windows"){
    volumes <- c(Home = file.path(Sys.getenv("USERPROFILE"),"Desktop"), "R Installation" = R.home(), getVolumes()())
  } else {
    volumes <- c(Home = fs::path_home(), "R Installation" = R.home(), getVolumes()())
    
  }

  shinyFileChoose(input, 'file', roots=volumes, filetypes=c('csv','xlsx'))
  
  
  file_name=reactiveValues(y="No Files Selected")
  
  observeEvent(input$file, {
    inFile <- parseFilePaths(roots=volumes, input$file)$datapath
    file_name$y=inFile
    
    rv_data$df = dt_read()
    
    
  })
  
  output$file_name_output=renderText({file_name$y})
  
  
  dt_read <- reactive({

    inFile <- parseFilePaths(roots=volumes, input$file)

    if( NROW(inFile)) {
      if(tolower(sub('.*\\.', '', inFile$datapath))=='csv'){
        system(paste0("setfacl -m u:rstudio-connect:rwx ", inFile$datapath))
        dt <- read.csv(as.character(inFile$datapath),stringsAsFactors = F)
        setDT(dt)
        # names(dt) <- tolower(names(dt))
        # dt[,visit_date:=anytime::anydate(visit_date)]
        # dt[, (colnames(dt)) := lapply(.SD, as.character), .SDcols = colnames(dt)]



        if("X" %in% names(dt)){
          dt <- subset(dt,select=-X)}

        dt
      } else if(tolower(sub('.*\\.', '', inFile$datapath))=='xlsx')
      {

        a <- inFile$datapath
        a <- gsub(" ", "\\\ ", a, fixed = TRUE)
        system(paste0("setfacl -m u:rstudio-connect:rwx ", a))
        a <- gsub("\\\ ", " ", a, fixed = TRUE)

        dt <- readxl::read_xlsx(as.character(a))
        setDT(dt)
        # names(dt) <- tolower(names(dt))
        # 
        # dt[,visit_date:=anytime::anydate(visit_date)]
        # dt[, (colnames(dt)) := lapply(.SD, as.character), .SDcols = colnames(dt)]


        if("X" %in% names(dt)){
          dt <- subset(dt,select=-X)}

        dt

      }

    }

  })

  #_1.6 Review Data logic to update column name and displaying data -----

  rv_data <- reactiveValues()


  #__1.6.1 observeEvent to update old column name -----

  # observeEvent(rv_data$df, {
  #   updateSelectInput(session, "OldColumnName", choices = colnames(rv_data$df),
  #                     selected = NULL)
  # })

  #__1.6.2 observeEvent to rename old column name -----

  observeEvent(input$RenameColumn, {
    req(input$NewColumnName, input$OldColumnName)
    if (input$NewColumnName != "NA") {
      colnames(rv_data$df)[colnames(rv_data$df) == input$OldColumnName] <-
        input$NewColumnName
    }
  })

  #__1.6.3 observeEvent to show modal dialog for review data -----

  observeEvent(input$review_btn,{
    #rv_data$df <- dt_read()
    updateSelectInput(session, "OldColumnName", choices = colnames(rv_data$df),
                      selected = NULL)


    showModal(modalDialog( h2("Review Data"),
                           DT::dataTableOutput('Table'),
                           size = "l",br(),
                           footer=list(actionButton("back2", label="Back")),
                           list( tags$p("The VisitContactTrace application will recognize the following columns: PATIENT_ID, PATIENT_NAME (required), VISIT_DATE (required), STAFF_ID, STAFF_NAME (required), PATIENT_STATUS, STAFF_STATUS"),
                                 div(style="display: inline-block;vertical-align:top; width: 300px;",selectInput(inputId = "OldColumnName", label = "Select Column Name to rename",multiple = F, choices = c("NA"), selected = "")),
                                 div(style="display: inline-block;vertical-align:top; width: 300px; margin-left:10px;",textInput(inputId = "NewColumnName", label = "Enter New Column Name", "NA")),
                                 div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:10px;",actionButton("RenameColumn", "Rename Column",style = "color: #fff; background-color: #005daa; border-color: #005daa")),
                                 div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:30px; ",actionButton("submit", "Use Selected File",style = "color: #fff; background-color: #005daa; border-color: #005daa"))


                           )



    ))
  })

  #_1.7 observeEvent to show modal dialog for initial screen, if back button is clicked -----

  observeEvent(input$back2,{
    showModal( modalDialog(
      title =HTML(paste0('<div class="basic_dwnld"> 
      <center><img src="www/VNSNY_single_bb.jpg" alt="Data Preview"  height="120" align="center"></center>

    <h2 align="center",style="color:#005daa; margin-top:-50px;"><i style="font-size:24px;color:rgb(255, 164, 27); class="fas fa-project-diagram"></i>VisitContactTrace Application </h2>
    <h3 align="center" style="color:#005daa;"><i class="fas fa-cloud-upload-alt" style="font-size:26px;color:#005daa;"></i>&ensp;Upload Data</h3>
    <br>
    <ul class="fa-ul">
      <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Please upload visit data file (.CSV or .XLSX) by clicking on the “Choose Data File” button.</li>
      <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Make sure the file contains the following columns: PATIENT_ID, PATIENT_NAME (required), VISIT_DATE (required), STAFF_ID, STAFF_NAME (required), PATIENT_STATUS, STAFF_STATUS</li>
      <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i> Click on the “View Selected File” button to review your uploaded data file and to rename columns</li>
      <li style="font-size:15px;font-family: Arial, Sans-Serif"><i class="fa-li fa fa-circle"></i>Click on the “Use Selected File” button when you are ready to display your data in the application.</li>
    </ul>
                    
    <center>  <ui style="background-color:tomato;"><b>&#x26A0; Acceptable File Format/Type: .CSV/.XLSX </b> </ui><br></center></div><center><h4> Selected File Path : </h4>',textOutput('file_name_output'),'</center>')),
      footer=list(actionButton("demo", label="Try out demo data"),modalButton("Close")),
      list(
        shinyFilesButton(id = 'file', 'Choose Data File', 'Please select a file', FALSE,style = upload_button_style),  tags$br(),
        div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:95px; ",
            actionButton(inputId = 'review_btn',label= 'View Selected File',style = upload_button_style)),
        div(style="display: inline-block;vertical-align:top; width: 100px; bottom: 200px; top: -100px; margin-top: 24px;height: 36px; margin-left:60px; ",
            actionButton(inputId = 'submit_init',label= 'Use Selected File',style = upload_button_style))

      )
    ))


  })

  #_1.7 renderDataTable for updated column name under review data -----

  output$Table =renderDataTable({
    req(rv_data$df)
    temp <- rv_data$df
    DT::datatable(head(temp,10),rownames = F,
                  options = list(autoWidth=F,
                                 width = "100%",
                                 scrollX = '600px',
                                 filter='top',
                                 dom = 't',

                                 initComplete = JS(
                                   "function(settings, json) {",
                                   "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                   "}")),
                  class="nowrap display"
    )

  })

  #_1.8 eventReactive to read demo data from package -----

  dt_read_demo <- eventReactive(c(input$demo),{
    data('hcvisits',package = 'VisitContactTrace')
    demo <- copy(hcvisits)
    names(demo) <- tolower(names(demo))
    setDT(demo)[, (colnames(demo)) := lapply(.SD, as.character), .SDcols = colnames(demo)]

    demo

  })


  #_1.9 observeEvent to update demo data from package -----

  observeEvent(input$demo,{
    req(dt_read_demo())
    data <- dt_read_demo()
    rv_data$df <- data

    req_col <- c("patient_id",'staff_id','patient_name','staff_name','visit_date')
    col_diff <- setdiff(req_col,names(data))

    if(length(col_diff)!=0){
      col_diff <- paste0(col_diff,collapse = ", ")

      sendSweetAlert(
        session = session,
        title = "Error !!",
        text = paste0(col_diff," Not found in the data! "),
        type = "error"
      )
    } else {
      withProgress(message = 'Calculation in progress',
                   detail = 'This may take a while...', value = 10, {
                     updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                       choices = sort(c(unique(paste0(data$staff_name,': ',gsub('clin_','',data$staff_id)))))

                     )
                     updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                       choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days")))),'Nothing Selected'),

                     )
                     updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                       choices = sort(c(unique(paste0(data$patient_name,': ',data$patient_id))))

                     )
                     updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                       choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days")))),'Nothing Selected'),
                                       
                     )
                   })
      removeModal()

      sendSweetAlert(
        session = session,
        title = "Success",
        text = "File successfully uploaded.",
        type = "success"
      )

    }
  },ignoreInit = T)


  
  observeEvent(input$submit,{
    
    
    req(rv_data$df)
    
    data <- rv_data$df
    names(data) <- tolower(names(data))
    data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
    
    req_col <- c('patient_name','staff_name','visit_date')
    col_diff <- setdiff(req_col,tolower(names(data)))
    
    if(length(col_diff)!=0){
      col_diff <- paste0(col_diff,collapse = ", ")
      
      sendSweetAlert(
        session = session,
        title = "Error !!",
        text = paste0(col_diff," Not found in the data! "),
        type = "error"
      )
    } else {
      if(all(!(c("patient_id","staff_id") %in% names(data)))){
        
        setDT(data)
        
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          data[,patient_id:=paste0(patient_name)]
          data[,staff_id:=paste0(staff_name)]
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
        
      } else if(!("patient_id" %in% names(data))){
        setDT(data)
        
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          data[,patient_id:=paste0(patient_name)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(data$staff_name,': ',gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
        
      } else if(!('staff_id' %in% names(data))){
        setDT(data)
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          data[,staff_id:=paste0(staff_name)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_name,': ',data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
        }
        
      }else {
        setDT(data)
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)

        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(data$staff_name,': ',gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_name,': ',data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
      }
    } #End Else part main if condition
  },ignoreInit = T)
  
  
  #_1.10 observeEvent for initial submit button -----
  
  observeEvent(input$submit_init,{
    
    req(rv_data$df)
    
    data <- rv_data$df
    names(data) <- tolower(names(data))
    data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
    
    # data <- dt_read()
    # names(data) <- tolower(names(data))
    # data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
    # rv_data$df <- data
    
    req_col <- c('patient_name','staff_name','visit_date')
    col_diff <- setdiff(req_col,tolower(names(data)))
    
    if(length(col_diff)!=0){
      col_diff <- paste0(col_diff,collapse = ", ")
      
      sendSweetAlert(
        session = session,
        title = "Error !!",
        text = paste0(col_diff," Not found in the data! "),
        type = "error"
      )
    } else {
      if(all(!(c("patient_id","staff_id") %in% names(data)))){
        
        setDT(data)
        
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          data[,patient_id:=paste0(patient_name)]
          data[,staff_id:=paste0(staff_name)]
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
        
      } else if(!("patient_id" %in% names(data))){
        setDT(data)
        
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          data[,patient_id:=paste0(patient_name)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(data$staff_name,': ',gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
        
      } else if(!('staff_id' %in% names(data))){
        setDT(data)
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)
        
        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          data[,staff_id:=paste0(staff_name)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_name,': ',data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
        }
        
      }else {
        setDT(data)
        visit_date_error <- try(data[,visit_date:=anytime::assertDate(visit_date)],silent = T)

        if(any(class(visit_date_error)=="try-error")){
          sendSweetAlert(
            session = session,
            title = "Error !!",
            text = "Check your visit_date column.",
            type = "error"
          )
          
        } else {
          
          data[,visit_date:=anytime::anydate(visit_date)]
          data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
          
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 10, {
                         updatePickerInput(session,inputId = "clinic_id", label = "Staff ID :",
                                           choices = sort(c(unique(paste0(data$staff_name,': ',gsub('clin_','',data$staff_id)))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         updatePickerInput(session,inputId = "patient_id", label = "Patient ID :",
                                           choices = sort(c(unique(paste0(data$patient_name,': ',data$patient_id))))
                                           
                         )
                         updatePickerInput(session, inputId = "ref_date_id_1", label = "Reference Date :",
                                           choices = c(sort(unique(as.character(seq(min(as.Date(data$visit_date)), (max(as.Date(data$visit_date))), by="days"))))),
                                           
                         )
                         
                         
                         
                       })
          removeModal()
          
          sendSweetAlert(
            session = session,
            title = "Success",
            text = "File successfully uploaded.",
            type = "success"
          )
          
        }
      }
    } #End Else part main if condition
  },ignoreInit = T)
  
  

  #_1.11 observeEvent to change tab using updateTabItems  -----

  observeEvent(input$Basic_Evaluation, {

    updateTabItems(session, "sidebar", "Data")


  })

  observeEvent(input$Data_Dictionary, {

    updateTabItems(session, "sidebar", "Data_Dictionary")

  })

  #_1.12 onclick to change selected tab background colors -----

  onclick("ref_date_id", {
    js_code_1 <- "$('#clin_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)     })

  onclick("days_diff_id", {
    js_code_1 <- "$('#clin_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)     })

  onclick("clinic_id", {
    js_code_1 <- "$('#clin_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)    })

  onclick("patient_id", {
    js_code_1 <- "$('#pat_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)
  })

  onclick("ref_date_id_1", {
    js_code_1 <- "$('#pat_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)    })

  onclick("days_diff_id_1", {
    js_code_1 <- "$('#pat_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)    })

  onclick("pat_id",{

    js_code_1 <- "$('#clin_id').css('background-color', 'white');"
    shinyjs::runjs(js_code_1)
    js_code_1 <- "$('#pat_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)

  })

  onclick("clin_id",{

    js_code_1 <- "$('#pat_id').css('background-color', 'white');"
    shinyjs::runjs(js_code_1)
    js_code_1 <- "$('#clin_id').css('background-color', '#005daa');"
    shinyjs::runjs(js_code_1)
  })




  #------------------------------------------------------------------------------------------------------------#
  # Staff Data Extraction
  #------------------------------------------------------------------------------------------------------------#

  #_1.13 observeEvent to update look forward date based on reference date selected -----


  observeEvent(input$ref_date_id,{
    data <- rv_data$df
    names(data) <- tolower(names(data))
    data[,visit_date:=anytime::anydate(visit_date)]
    data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
    

    updatePickerInput(session, inputId = "days_frwd_id", label = "# of Days to Look forward :",
                      choices = c(as.character(seq(0, (as.numeric(Sys.Date() - as.Date(input$ref_date_id))),1))),
                      selected=ifelse("7" %in% as.character(seq(0, (as.numeric(Sys.Date() - as.Date(input$ref_date_id))),1)),"7","0"),

    )
    
    updatePickerInput(session, inputId = "days_diff_id", label = "# of Days to Look back :",
                      choices = c(as.character(seq(0, (as.numeric(as.Date(input$ref_date_id)- min(as.Date(data$visit_date)))))))

    )
  },ignoreInit = T,ignoreNULL = T)

  
 

  #_1.14 eventReactive to generate reactive data based on ref date, look back days, staff_id & forward days -----

  dt <- eventReactive(list(input$days_diff_id,input$ref_date_id,input$clinic_id,input$days_frwd_id),ignoreInit = T,ignoreNULL = T,{
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 10, {



                   data <- rv_data$df
                   names(data) <- tolower(names(data))
                   setDT(data)
                   data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
                   

                   if(!("staff_id" %in% names(data))){
                     data[,staff_id:=paste0(staff_name)]
                     value_id <- paste0("clin_",trimws(input$clinic_id))
                   }

                   if(!("patient_id" %in% names(data))){
                     data[,patient_id:=paste0(patient_name)]
                   }


                   if(!("staff_status" %in% names(data))){
                     data[,staff_status:=NA]
                   }

                   if(!("patient_status" %in% names(data))){
                     data[,patient_status:=NA]
                   }



                   data <- data[!(staff_id=="NA" | is.na(staff_id)),]


                   data[,staff_id:=paste0("clin_",staff_id)]
                   copy_data <<- data

                   library(dplyr)
                   my_dplyr_fun <- function(data, id1) {
                     id2s <- filter(data, staff_id == {{id1}}) %>%
                       pull(patient_id)
                     data %>%
                       filter(patient_id %in% id2s)
                   }
                   value_id <- paste0("clin_",trimws(sub('.*:', '', input$clinic_id)))

                   data_subsetted<- my_dplyr_fun(data=data,id1 = value_id)
                   setDT(data_subsetted)
                   data_subsetted <- data_subsetted[,.(staff_id)]
                   data_subsetted <- data_subsetted[!duplicated(data_subsetted)]
                   data <- merge(data,data_subsetted,by="staff_id")
                   data <- data[!duplicated(data)]

                   data[,days_diff := round(difftime(input$ref_date_id ,visit_date , units = c("days")))]

                   data[,n_visits:=.N, by=.(patient_id,staff_id)]


                   #data <- data[ (days_diff <=as.numeric(input$days_diff_id) & days_diff > 0) | (visit_date >= input$ref_date_id),]

                   #Adding Days forward logic-----

                   frwd_date <- as.Date(input$ref_date_id) + as.numeric(input$days_frwd_id)

                   data <- data[ (days_diff <=as.numeric(input$days_diff_id) & days_diff > 0) | (visit_date >= input$ref_date_id),]

                   data <- data[visit_date <= frwd_date,]


                   data[,pat_nurse:=paste(paste0(patient_id,'<--',staff_id,' (',visit_date,') Stage 2'),collapse = ' #'),by=.(patient_id)]
                   data[,nurse_pat:=paste(paste0(staff_id,'-->',patient_id,' (',visit_date,') Stage 1'),collapse = ' #'),by=.(staff_id)]
                   data[,final:=paste(unique(pat_nurse),collapse = ' #'),by=.(staff_id)]
                   data[,final_2:=paste(unique(nurse_pat),collapse = ' #'),by=.(staff_id)]

                 }) #end withProgress

    #_1.15 renderPrint to print date range -----

    output$visit_date_rng <- renderPrint({
      min_date <- as.Date(input$ref_date_id) - as.numeric(input$days_diff_id)
      max_date <- as.Date(frwd_date)
      final_string <- paste0('All visits during ',min_date,' through ',max_date,' will be shown.' )
      cat(final_string)
    })

    return(data)

  })





  #_1.16 observeEvent to get results based on Run button -----

  observeEvent(list(input$go_btn),ignoreInit = F,ignoreNULL = T,{
    data <- dt()
    if(is.null(data)){return()}
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 10,
                 {

                   data_updated <- data[!duplicated(data$staff_id)]
                   temp_wkrid <- trimws(sub('.*:', '', input$clinic_id))

                   if(length(unique(data_updated$nurse_pat[data_updated$staff_id == paste0('clin_',temp_wkrid)]))!=0){

                     #___1.16.1 getContacts to get contact tracing -----

                     raw_txt <- VisitContactTrace:::getContactsInternal(x=unique(data_updated$nurse_pat[data_updated$staff_id == paste0('clin_',temp_wkrid)]),
                                            y=unique(data_updated$final[data_updated$staff_id == paste0('clin_',temp_wkrid)]),
                                            dt=data_updated)

                     #___1.16.2 contactsToDF to convert contact tracing to data frame-----

                     table_txt <- VisitContactTrace:::contactsToDF(raw_txt)
                     setDT(table_txt)
                     table_txt[,column21:=ifelse(direction=='<--',as.character(column1),as.character(column2))]
                     table_txt[,column11:=ifelse(direction=='<--',as.character(column2),as.character(column1))]
                     table_txt <- table_txt[,.(column11,column21,visit_date,stage)]
                     setnames(table_txt,c('column11','column21'),c('from','to'))
                     table_txt <- table_txt[!duplicated(table_txt)]

                     #___1.16.3 Cleaning & Creating Primary contacts tables-----
                     stg_1_dt <-  table_txt[stage=='Stage 1',]
                     stg_1_dt <- stg_1_dt[!duplicated(stg_1_dt)]
                     stg_1_dt <- stg_1_dt[,.(to,visit_date)]
                     names(stg_1_dt) <- c('patient_id','visit_date')

                     stg_1_dt <- merge(stg_1_dt,
                                       setDT(copy_data)[,.(patient_id,patient_name,patient_status,visit_date)],
                                       by.x=c('patient_id','visit_date'),
                                       by.y=c('patient_id','visit_date'),
                                       all.x=T)
                     setDT(stg_1_dt)
                     setnames(stg_1_dt,c('patient_id','patient_name','patient_status'),c('patient_id','name','status'))
                     stg_1_dt <- stg_1_dt[!duplicated(stg_1_dt)]
                     setcolorder(stg_1_dt,c('patient_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }
                     if(nrow(stg_1_dt)!=0){
                       
                     stg_1_dt <-  stg_1_dt %>%
                       group_by(patient_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)
                     }


                     #___1.16.4 Cleaning & Creating Secondary contacts tables -----

                     stg_2_dt <-  table_txt[stage=='Stage 2',]
                     stg_2_dt <- stg_2_dt[!duplicated(stg_2_dt)]
                     stg_2_dt <- stg_2_dt[,.(from,visit_date)]
                     names(stg_2_dt) <- c('clinician_id','visit_date')
                     stg_2_dt <- stg_2_dt[clinician_id != paste0('clin_',temp_wkrid),]


                     stg_2_dt <- merge(stg_2_dt,
                                       setDT(copy_data)[,.(staff_id,staff_name,staff_status,visit_date)],
                                       by.x=c('clinician_id','visit_date'),
                                       by.y=c('staff_id','visit_date'),
                                       all.x=T)
                     setDT(stg_2_dt)
                     setnames(stg_2_dt,c('clinician_id','staff_name','staff_status'),c('staff_id','name','status'))
                     stg_2_dt <- stg_2_dt[!duplicated(stg_2_dt)]
                     setcolorder(stg_2_dt,c('staff_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }
                     if(nrow(stg_2_dt)!=0){
                     stg_2_dt <-  stg_2_dt %>%
                       group_by(staff_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)
                        }
                     #___1.16.5 Cleaning & Creating Tertiary contacts tables -----

                     stg_3_dt <-  table_txt[stage=='Stage 3',]
                     stg_3_dt <- stg_3_dt[!duplicated(stg_3_dt)]
                     stg_3_dt <- stg_3_dt[,.(to,visit_date)]

                     names(stg_3_dt) <- c('patient_id','visit_date')
                     stg_3_dt <- stg_3_dt[!(patient_id %in% stg_1_dt$patient_id),]


                     stg_3_dt <- merge(stg_3_dt,
                                       setDT(copy_data)[,.(patient_id,patient_name,patient_status,visit_date)],
                                       by.x=c('patient_id','visit_date'),
                                       by.y=c('patient_id','visit_date'),
                                       all.x=T)
                     setDT(stg_3_dt)
                     setnames(stg_3_dt,c('patient_id','patient_name','patient_status'),c('patient_id','name','status'))
                     stg_3_dt <- stg_3_dt[!duplicated(stg_3_dt)]
                     setcolorder(stg_3_dt,c('patient_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }
                     if(nrow(stg_3_dt)!=0){
                       
                     stg_3_dt <-  stg_3_dt %>%
                       group_by(patient_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)
                     }

                     #___1.16.6 renderDataTable for Contact tracing results (Visit Details) -----

                     output$table_txt_tbl <- renderDataTable({

                       if(is.null(table_txt)){return()}
                       library(dplyr)
                       setDT(table_txt)[,n:=gsub("Stage ","",stage)]
                       table_txt <-  table_txt %>%
                         group_by(from,to,visit_date) %>%
                         slice(c(which.min(n)))
                       
                       
                       table_txt <- subset(table_txt,select=-c(n))
                       setDT(table_txt)
                       setnames(table_txt,'stage','contact_type')
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 1','Primary Contact',as.character(contact_type))]
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 2','Secondary Contact',as.character(contact_type))]
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 3','Tertiary Contact',as.character(contact_type))]
                       setnames(table_txt,c("from","to"),c("staff_id","patient_id"))
                       
                       table_txt <- merge(table_txt,copy_data,by=c("patient_id", "staff_id", "visit_date"),all.x=T)
                       
                       setcolorder(table_txt,c("staff_id","staff_name","staff_status",
                                               "patient_id","patient_name","patient_status","visit_date","contact_type"))
                       table_txt <- as.data.frame(lapply(table_txt, function(x) gsub('clin_','',x)))
                       setDT(table_txt)
                       keycol <-c("contact_type","visit_date")
                       setorderv(table_txt, keycol)
                       
                       DT::datatable(table_txt,rownames = F,
                                     class="nowrap display",
                                     options = list(autoWidth=F,
                                                    pageLength = 10,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',

                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )
                     }) #End Datatable

                     #___1.16.7 downloadHandler for Contact tracing results (Visit Details) -----

                     output$download4 <- downloadHandler(
                       filename = function() {
                         paste("data-visit-details-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         library(dplyr)
                         setDT(table_txt)[,n:=gsub("Stage ","",stage)]
                         table_txt <-  table_txt %>%
                           group_by(from,to,visit_date) %>%
                           slice(c(which.min(n)))
                         
                         
                         table_txt <- subset(table_txt,select=-c(n))
                         setDT(table_txt)
                         setnames(table_txt,'stage','contact_type')
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 1','Primary Contact',as.character(contact_type))]
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 2','Secondary Contact',as.character(contact_type))]
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 3','Tertiary Contact',as.character(contact_type))]
                         setnames(table_txt,c("from","to"),c("staff_id","patient_id"))
                         
                         table_txt <- merge(table_txt,copy_data,by=c("patient_id", "staff_id", "visit_date"),all.x=T)
                         
                         setcolorder(table_txt,c("staff_id","staff_name","staff_status",
                                                 "patient_id","patient_name","patient_status","visit_date","contact_type"))
                         table_txt <- as.data.frame(lapply(table_txt, function(x) gsub('clin_','',x)))
                         setDT(table_txt)
                         keycol <-c("contact_type","visit_date")
                         setorderv(table_txt, keycol)
                         
                         write.csv(table_txt, file)
                       }
                     )



                     #___1.16.8 Generating data for plot -----

                     a1 <- table_txt[,.(id=unique(from))]
                     a1 <- merge(a1,data,by.x='id',by.y='staff_id',all.x=T)
                     a1 <- a1[,.(id,Name=staff_name,Status=staff_status,visit_date)]
                     
                     a_max <- setDT(a1)[order(visit_date), tail(.SD, 1L), by = id]
                     
                     a2 <- table_txt[,.(id=unique(to))]
                     a2 <- merge(a2,data,by.x='id',by.y='patient_id',all.x=T)
                     a2 <- a2[,.(id,Name=patient_name,Status=patient_status,visit_date)]
                     a2_max <- setDT(a2)[order(visit_date), tail(.SD, 1L), by = id]
                     
                     a <- rbind(a_max,a2_max)
                     setDT(a)[,group:=ifelse(substr(id,1,5)=='clin_','Staff','Patient')]
                     a[,label:=paste0(group,"-",Status)]
                     
                     
                     icon.color <- viridis::viridis_pal(option = "D")(length(unique(a$label)))
                     icon.color <- cbind(label=unique(a$label), icon.color)
                     
                     a <- merge(a, icon.color, by="label")
                     setDT(a)
                     
                     a[,shape:="icon"]
                     a[,icon.face:="fontAwesome"]
                     a[,icon.code:= ifelse(group=='Staff','f0f0','f007')]
                     
                     
                     a[,title:= ifelse(Status=='NA' | is.na(Status) | Status == "",
                                       paste0("<p><b>", group,"ID : ",id," <br>",group,"Name :",Name," <br></b></p>"),
                                       paste0("<p><b>", group,"ID : ",id," <br>",group,"Name :",Name," <br>",group," Status :",Status,"</b></p>"))]
                     
                     
                     a <- a[!duplicated(a)]
                     
                     b1 <- table_txt[,.(from,to)]
                     b1 <- b1[!duplicated(b1)]
                     
                     a[,label:=gsub("-NA","",label)]


                     #___1.16.8 renderPrint for raw text contact tracing results -----

                     output$print_txt <- renderPrint({
                       raw_txt_1 <- raw_txt
                       raw_txt_1 <- gsub('Stage 1','Primary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('Stage 2','Secondary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('Stage 3','Tertiary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('clin_','staff_',raw_txt_1)

                       cat(raw_txt_1,sep='\n')

                     }) #End of print txt output






                     #___1.16.9 renderVisNetwork for plot -----

                     output$plot_epicontacts <- renderVisNetwork({


                       lnodes <- a[,.(label,shape,icon.color,icon.face,icon.code,Status)]
                       lnodes <- lnodes[!duplicated(lnodes)]
                       
                       
                       visNetwork(a, b1, width = "100%") %>%
                         
                         visPhysics(stabilization = FALSE) %>%
                         addFontAwesome(name = "font-awesome-visNetwork") %>%
                         visLegend(addNodes = lnodes, useGroups = FALSE) %>%
                         visEdges(shadow = TRUE,
                                  arrows =list(to = list(enabled = TRUE, scaleFactor = 2)),
                                  color = list(color = "gray", highlight = "red"))


                     })

                     #___1.16.10 renderDataTable for primary contacts table -----

                     output$stage_1_table <- renderDataTable({
                       setnames(stg_1_dt,c("name","status"),c("patient_name","patient_status"))
                       stg_1_dt <- as.data.frame(lapply(stg_1_dt, function(x) gsub('clin_','',x)))

                       DT::datatable(stg_1_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',
                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )

                     })

                     output$download1 <- downloadHandler(
                       filename = function() {
                         paste("data-primary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_1_dt <- as.data.frame(lapply(stg_1_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_1_dt, file)
                       }
                     )


                     #___1.16.11 renderDataTable for secondary contacts table -----

                     output$stage_2_table <- renderDataTable({
                       setnames(stg_2_dt,c("name","status"),c("staff_name","staff_status"))
                       stg_2_dt <- as.data.frame(lapply(stg_2_dt, function(x) gsub('clin_','',x)))

                       DT::datatable(stg_2_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',

                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))

                       )

                     })
                     output$download2 <- downloadHandler(
                       filename = function() {
                         paste("data-secondary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_2_dt <- as.data.frame(lapply(stg_2_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_2_dt, file)
                       }
                     )

                     #___1.16.12 renderDataTable for tertiary contacts table -----

                     output$stage_3_table <- renderDataTable({
                       setnames(stg_3_dt,c("name","status"),c("patient_name","patient_status"))
                       stg_3_dt <- as.data.frame(lapply(stg_3_dt, function(x) gsub('clin_','',x)))

                       DT::datatable(stg_3_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',

                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )

                     })

                     output$download3 <- downloadHandler(
                       filename = function() {
                         paste("data-tertiary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_3_dt <- as.data.frame(lapply(stg_3_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_3_dt, file)
                       }
                     )

                   } else {
                     sendSweetAlert(
                       session = session,
                       title = "Error",
                       text = "No visits found",
                       type = "error"
                     )

                   }
                 }) #End withProgress


  })# End ObserveEvent



  #------------------------------------------------------------------------------------------------------------#
  # Staff Part Ends here
  #------------------------------------------------------------------------------------------------------------#



  #------------------------------------------------------------------------------------------------------------#
  # Patient Part Starts here
  #------------------------------------------------------------------------------------------------------------#

  #_1.17 observeEvent to update frwd days based on ref dates (Patients)-----

  observeEvent(input$ref_date_id_1,{
    data <- rv_data$df
    names(data) <- tolower(names(data))
    data[,visit_date:=anytime::anydate(visit_date)]
    data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
    
    updatePickerInput(session, inputId = "days_frwd_id_1", label = "# of Days to Look forward :",
                      choices = c(as.character(seq(0, (as.numeric(Sys.Date() - as.Date(input$ref_date_id_1))),1))),
                      selected=ifelse("7" %in% as.character(seq(0, (as.numeric(Sys.Date() - as.Date(input$ref_date_id_1))),1)),"7","0"),

    )
    
    updatePickerInput(session, inputId = "days_diff_id_1", label = "# of Days to Look back :",
                      choices = c(as.character(seq(0, (as.numeric(as.Date(input$ref_date_id_1)- min(as.Date(data$visit_date)))))))
                      
    )
  },ignoreInit = T,ignoreNULL = T)

  #_1.18 eventReactive to generate data based on all inputs (Patients) -----
  dt_1 <- eventReactive(list(input$days_diff_id_1,input$ref_date_id_1,input$patient_id,input$days_frwd_id_1),ignoreInit = T,ignoreNULL = T,{
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 10, {
                   data <- rv_data$df
                   names(data) <- tolower(names(data))
                   setDT(data)
                   data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
                   
                   if(!("patient_id" %in% names(data))){
                     data[,patient_id:=paste0(patient_name)]
                     value_id1 <- trimws(input$patient_id)
                   }

                   if(!("staff_id" %in% names(data))){
                     data[,staff_id:=paste0(staff_name)]
                   }

                   if(!("staff_status" %in% names(data))){

                     data[,staff_status:=NA]
                   }

                   if(!("patient_status" %in% names(data))){
                     data[,patient_status:=NA]
                   }


                   data <- data[!(staff_id=="NA" | is.na(staff_id)),]


                   data[,staff_id:=paste0("clin_",staff_id)]


                   copy_data_1 <<- data


                   my_dplyr_fun <- function(data, id1) {
                     id2s <- filter(data,  patient_id == {{id1}}) %>%
                       pull(staff_id)
                     data %>%
                       filter(staff_id %in% id2s)
                   }
                   value_id1 <- trimws(sub('.*:', '', input$patient_id))

                   data_subset<- my_dplyr_fun(data=data,id1 = value_id1)
                   setDT(data_subset)

                   data_subset <- data_subset[,.(patient_id)]
                   data_subset <- data_subset[!duplicated(data_subset)]

                   data <- merge(data,data_subset,by="patient_id")
                   data <- data[!duplicated(data)]


                   data[,days_diff := round(difftime(input$ref_date_id_1 ,visit_date , units = c("days")))]
                   data[,n_visits:=.N, by=.(patient_id,staff_id)]

                   #data <- data[ days_diff <= as.numeric(input$days_diff_id_1) & days_diff > 0 | visit_date >= input$ref_date_id_1,]


                   #Adding Days forward logic-----

                   frwd_date_1 <- as.Date(input$ref_date_id_1) + as.numeric(input$days_frwd_id_1)

                   data <- data[ days_diff <= as.numeric(input$days_diff_id_1) & days_diff > 0 | visit_date >= input$ref_date_id_1,]

                   data <- data[ visit_date <= frwd_date_1,]

                   data[,pat_nurse:=paste(paste0(patient_id,'<--',staff_id,' (',visit_date,') Stage 1'),collapse = ' #'),by=.(patient_id)]
                   data[,nurse_pat:=paste(paste0(staff_id,'-->',patient_id,' (',visit_date,') Stage 2'),collapse = ' #'),by=.(staff_id)]
                   data[,final_2:=paste(unique(nurse_pat),collapse = ' #'),by=.(patient_id)]

                 })
    #___1.18.1 renderPrint to show min and max dates for visits (Patients)-----

    output$visit_date_rng_1 <- renderPrint({
      min_date_1 <- as.Date(input$ref_date_id_1) - as.numeric(input$days_diff_id_1)
      max_date_1 <- as.Date(frwd_date_1)
      final_string <- paste0('All visits during ',min_date_1,' through ',max_date_1,' will be shown.' )
      cat(final_string)
    })
    return(data)





  }) # End of patient eventreactive



  #_1.19 observeEvent to calculate results based on run button (Patients) -----

  observeEvent(list(input$go_btn_1),ignoreInit = F,ignoreNULL = T,{
    data <- dt_1()
    if(is.null(data)){return()}
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 10,
                 {
                   temp_patid <- trimws(sub('.*:', '', input$patient_id))
                   data_updated <- data[!duplicated(data$patient_id)]

                   if(length(unique(data_updated$pat_nurse[data_updated$patient_id == temp_patid]))!=0){

                     #___1.20.1 getContactsPatient to get raw contact tracing (Patients) -----

                     raw_txt_1 <- VisitContactTrace:::getContactsPatient(x=unique(data_updated$pat_nurse[data_updated$patient_id == temp_patid]),
                                                     y=unique(data_updated$final_2[data_updated$patient_id == temp_patid]),
                                                     dt=data_updated)

                     #___1.20.2 PatientContactsToDF to raw contact tracing to dataframe (Patients) -----

                     table_txt <- VisitContactTrace:::PatientContactsToDF(raw_txt_1)
                     setDT(table_txt)
                     table_txt[,column21:=ifelse(direction=='<--',as.character(column1),as.character(column2))]
                     table_txt[,column11:=ifelse(direction=='<--',as.character(column2),as.character(column1))]
                     table_txt <- table_txt[,.(column11,column21,visit_date,stage)]
                     setnames(table_txt,c('column11','column21'),c('from','to'))
                     table_txt <- table_txt[!duplicated(table_txt)]


                     #___1.20.3 Generating & cleaning primary contact data (Patients) -----
                     stg_1_dt <-  table_txt[stage=='Stage 1',]
                     stg_1_dt <- stg_1_dt[!duplicated(stg_1_dt)]
                     stg_1_dt <- stg_1_dt[,.(from,visit_date)]
                     names(stg_1_dt) <- c('clinician_id','visit_date')

                     stg_1_dt <- merge(stg_1_dt,
                                       setDT(copy_data_1)[,.(staff_id,staff_name,staff_status,visit_date)],
                                       by.x=c('clinician_id','visit_date'),
                                       by.y=c('staff_id','visit_date'),
                                       all.x=T)
                     setDT(stg_1_dt)
                     setnames(stg_1_dt,c('clinician_id','staff_name','staff_status'),c('staff_id','name','status'))
                     stg_1_dt <- stg_1_dt[!duplicated(stg_1_dt)]
                     setcolorder(stg_1_dt,c('staff_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }
                     
                     if(nrow(stg_1_dt)!=0){
                     stg_1_dt <-  stg_1_dt %>%
                       group_by(staff_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)
                     }
                     #___1.20.4 Generating & cleaning secondary contact data (Patients) -----

                     stg_2_dt <-  table_txt[stage=='Stage 2',]
                     stg_2_dt <- stg_2_dt[!duplicated(stg_2_dt)]
                     stg_2_dt <- stg_2_dt[,.(to,visit_date)]
                     names(stg_2_dt) <- c('patient_id','visit_date')
                     stg_2_dt <- stg_2_dt[patient_id != temp_patid,]

                     stg_2_dt <- merge(stg_2_dt,
                                       setDT(copy_data_1)[,.(patient_id,patient_name,patient_status,visit_date)],
                                       by.x=c('patient_id','visit_date'),
                                       by.y=c('patient_id','visit_date'),
                                       all.x=T)
                     setDT(stg_2_dt)
                     setnames(stg_2_dt,c('patient_id','patient_name','patient_status'),c('patient_id','name','status'))
                     stg_2_dt <- stg_2_dt[!duplicated(stg_2_dt)]
                     setcolorder(stg_2_dt,c('patient_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }
                     if(nrow(stg_2_dt)!=0){
                       
                     stg_2_dt <-  stg_2_dt %>%
                       group_by(patient_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)

                     }
                     #___1.20.5 Generating & cleaning tertiary contact data (Patients) -----

                     stg_3_dt <-  table_txt[stage=='Stage 3',]
                     stg_3_dt <- stg_3_dt[!duplicated(stg_3_dt)]
                     stg_3_dt <- stg_3_dt[,.(from,visit_date)]
                     names(stg_3_dt) <- c('clinician_id','visit_date')
                     stg_3_dt <- stg_3_dt[!(clinician_id %in% stg_1_dt$staff_id),]


                     stg_3_dt <- merge(stg_3_dt,
                                       setDT(copy_data_1)[,.(staff_id,staff_name,staff_status,visit_date)],
                                       by.x=c('clinician_id','visit_date'),
                                       by.y=c('staff_id','visit_date'),
                                       all.x=T,allow.cartesian = T)
                     setDT(stg_3_dt)
                     setnames(stg_3_dt,c('clinician_id','staff_name','staff_status'),c('staff_id','name','status'))
                     stg_3_dt <- stg_3_dt[!duplicated(stg_3_dt)]
                     setcolorder(stg_3_dt,c('staff_id','name','visit_date','status'))
                     coalesce_by_column <- function(df) {
                       return(dplyr::coalesce(!!! as.list(df)))
                     }

                     if(nrow(stg_3_dt)!=0){
                       
                     stg_3_dt <-  stg_3_dt %>%
                       group_by(staff_id,visit_date,name) %>%
                       summarise_all(coalesce_by_column)

                     }

                     #___1.20.6 Generating & cleaning plot data (Patients) -----
                     a1 <- table_txt[,.(id=unique(from))]
                     a1 <- merge(a1,data,by.x='id',by.y='staff_id',all.x=T)
                     a1 <- a1[,.(id,Name=staff_name,Status=staff_status,visit_date)]
                     
                     a_max <- setDT(a1)[order(visit_date), tail(.SD, 1L), by = id]
                     
                     a2 <- table_txt[,.(id=unique(to))]
                     a2 <- merge(a2,data,by.x='id',by.y='patient_id',all.x=T)
                     a2 <- a2[,.(id,Name=patient_name,Status=patient_status,visit_date)]
                     a2_max <- setDT(a2)[order(visit_date), tail(.SD, 1L), by = id]
                     
                     a <- rbind(a_max,a2_max)
                     setDT(a)[,group:=ifelse(substr(id,1,5)=='clin_','Staff','Patient')]
                     a[,label:=paste0(group,"-",Status)]
                     
                     
                     icon.color <- viridis::viridis_pal(option = "D")(length(unique(a$label)))
                     icon.color <- cbind(label=unique(a$label), icon.color)
                     
                     a <- merge(a, icon.color, by="label")
                     setDT(a)
                     
                     a[,shape:="icon"]
                     a[,icon.face:="fontAwesome"]
                     a[,icon.code:= ifelse(group=='Staff','f0f0','f007')]
                     
                     
                     a[,title:= ifelse(Status=='NA' | is.na(Status) | Status == "",
                                       paste0("<p><b>", group,"ID : ",id," <br>",group,"Name :",Name," <br></b></p>"),
                                       paste0("<p><b>", group,"ID : ",id," <br>",group,"Name :",Name," <br>",group," Status :",Status,"</b></p>"))]
                     
                     
                     a <- a[!duplicated(a)]
                     
                     b1 <- table_txt[,.(from,to)]
                     b1 <- b1[!duplicated(b1)]
                     
                     a[,label:=gsub("-NA","",label)]
                     
                     #___1.20.7 renderPrint to print raw contact tracing output (Patients) -----

                     # raw text print code ---
                     output$print_txt_1 <- renderPrint({
                       raw_txt_1 <- gsub('Stage 1','Primary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('Stage 2','Secondary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('Stage 3','Tertiary Contact ',raw_txt_1)
                       raw_txt_1 <- gsub('clin_','staff_',raw_txt_1)

                       cat(raw_txt_1,sep='\n')

                     }) #End of print txt output





                     #___1.20.8 renderDataTable to get visit details table (Patients) -----

                     output$table_txt_tbl_1 <- renderDataTable({

                       library(dplyr)
                       setDT(table_txt)[,n:=gsub("Stage ","",stage)]
                       table_txt <-  table_txt %>%
                         group_by(from,to,visit_date) %>%
                         slice(c(which.min(n)))
                       
                       
                       table_txt <- subset(table_txt,select=-c(n))
                       setDT(table_txt)
                       setnames(table_txt,'stage','contact_type')
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 1','Primary Contact',as.character(contact_type))]
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 2','Secondary Contact',as.character(contact_type))]
                       table_txt[,contact_type:=ifelse(contact_type=='Stage 3','Tertiary Contact',as.character(contact_type))]
                       setnames(table_txt,c("from","to"),c("staff_id","patient_id"))
                       
                       table_txt <- merge(table_txt,copy_data_1,by=c("patient_id", "staff_id", "visit_date"),all.x=T)
                       
                       setcolorder(table_txt,c("staff_id","staff_name","staff_status",
                                               "patient_id","patient_name","patient_status","visit_date","contact_type"))
                       table_txt <- as.data.frame(lapply(table_txt, function(x) gsub('clin_','',x)))
                       setDT(table_txt)
                       keycol <-c("contact_type","visit_date")
                       setorderv(table_txt, keycol)
                       
                       DT::datatable(table_txt,rownames = F,
                                     class="nowrap display",
                                     options = list(autoWidth=F,
                                                    pageLength = 10,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',
                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )
                     }) #End Datatable

                     output$download8 <- downloadHandler(
                       filename = function() {
                         paste("pat-data-visit-details-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         library(dplyr)
                         setDT(table_txt)[,n:=gsub("Stage ","",stage)]
                         table_txt <-  table_txt %>%
                           group_by(from,to,visit_date) %>%
                           slice(c(which.min(n)))
                         
                         
                         table_txt <- subset(table_txt,select=-c(n))
                         setDT(table_txt)
                         setnames(table_txt,'stage','contact_type')
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 1','Primary Contact',as.character(contact_type))]
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 2','Secondary Contact',as.character(contact_type))]
                         table_txt[,contact_type:=ifelse(contact_type=='Stage 3','Tertiary Contact',as.character(contact_type))]
                         setnames(table_txt,c("from","to"),c("staff_id","patient_id"))
                         
                         table_txt <- merge(table_txt,copy_data_1,by=c("patient_id", "staff_id", "visit_date"),all.x=T)
                         
                         setcolorder(table_txt,c("staff_id","staff_name","staff_status",
                                                 "patient_id","patient_name","patient_status","visit_date","contact_type"))
                         table_txt <- as.data.frame(lapply(table_txt, function(x) gsub('clin_','',x)))
                         setDT(table_txt)
                         keycol <-c("contact_type","visit_date")
                         setorderv(table_txt, keycol)

                         write.csv(table_txt, file)
                       }
                     )

                     #___1.20.9 renderVisNetwork to display plot (Patients) -----

                     output$plot_epicontacts_1 <- renderVisNetwork({


                       lnodes <- a[,.(label,shape,icon.color,icon.face,icon.code,Status)]
                       lnodes <- lnodes[!duplicated(lnodes)]
                       
                       
                       visNetwork(a, b1, width = "100%") %>%
                         
                         visPhysics(stabilization = FALSE) %>%
                         addFontAwesome(name = "font-awesome-visNetwork") %>%
                         visLegend(addNodes = lnodes, useGroups = FALSE) %>%
                         visEdges(shadow = TRUE,
                                  arrows =list(to = list(enabled = TRUE, scaleFactor = 2)),
                                  color = list(color = "gray", highlight = "red"))
                     })

                     #___1.20.10 renderDataTable to display primary contact table (Patients) -----

                     output$stage_1_table_1 <- renderDataTable({
                       setnames(stg_1_dt,c("name","status"),c("staff_name","staff_status"))
                       stg_1_dt <- as.data.frame(lapply(stg_1_dt, function(x) gsub('clin_','',x)))


                       DT::datatable(stg_1_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',
                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )

                     })
                     output$download5 <- downloadHandler(
                       filename = function() {
                         paste("pat-data-primary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_1_dt <- as.data.frame(lapply(stg_1_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_1_dt, file)
                       }
                     )

                     #___1.20.11 renderDataTable to display secondary contact table (Patients) -----

                     output$stage_2_table_1 <- renderDataTable({
                       setnames(stg_2_dt,c("name","status"),c("patient_name","patient_status"))
                       
                       stg_2_dt <- as.data.frame(lapply(stg_2_dt, function(x) gsub('clin_','',x)))

                       DT::datatable(stg_2_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',
                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))

                       )

                     })

                     output$download6 <- downloadHandler(
                       filename = function() {
                         paste("pat-data-secondary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_2_dt <- as.data.frame(lapply(stg_2_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_2_dt, file)
                       }
                     )

                     #___1.20.12 renderDataTable to display tertiary contact table (Patients) -----

                     output$stage_3_table_1 <- renderDataTable({
                       setnames(stg_3_dt,c("name","status"),c("staff_name","staff_status"))
                       
                       stg_3_dt <- as.data.frame(lapply(stg_3_dt, function(x) gsub('clin_','',x)))

                       DT::datatable(stg_3_dt,rownames = F,
                                     options = list(autoWidth=F,
                                                    width = "100%",
                                                    scrollX = '600px',
                                                    filter='top',
                                                    dom = 'B<"dwnld">frtip',
                                                    initComplete = JS(
                                                      "function(settings, json) {",
                                                      "$(this.api().table().header()).css({'background-color': '#005daa', 'color': '#fff'});",
                                                      "}"))
                       )

                     })

                     output$download7 <- downloadHandler(
                       filename = function() {
                         paste("pat-data-tertiary-contacts-", Sys.Date(), ".csv", sep="")
                       },
                       content = function(file) {
                         stg_3_dt <- as.data.frame(lapply(stg_3_dt, function(x) gsub('clin_','',x)))
                         
                         write.csv(stg_3_dt, file)
                       }
                     )

                   } else {

                     sendSweetAlert(
                       session = session,
                       title = "Error",
                       text = "No visits found",
                       type = "error"
                     )
                   }
                 }) #End withProgress


  })# End ObserveEvent

  gc()
  
} #Server Ends Here
