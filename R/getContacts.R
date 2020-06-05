#' @title Get contact tracing list and plot.
#' @description To get primary, secondary & tertiary contact list from data for specific staff/patient id.
#' @param staff_id character - unique staff identifier for each staff in the homecare dataset
#' @param patient_id character - unique patient identifier for each patient in the homecare dataset
#' @param reference_date character - The date user assume that staff/patient started showing onset symptoms. ('2020-03-01')
#' @param look_forward_days character - How many days forward you want to look from reference date ('7')
#' @param look_back_days character - How many days backward you want to look from reference date ('0')
#' @param plot logical - If TRUE then plot object will be added in the output list. (FALSE)
#' @param data data.table - Data with following columns: PATIENT_ID, PATIENT_NAME (required), VISIT_DATE (required), STAFF_ID, STAFF_NAME (required), PATIENT_STATUS, STAFF_STATUS
#' @return returns a list with 4 elements:
#' \itemize{
#'   \item primary_contact_list - The primary contact data frame.
#'   \item secondary_contact_list - The primary contact data frame.
#'   \item tertiary_contact_list - The tertiary contact data frame.
#'   \item plot - A plot object, if logical parameter in the function is TRUE.
#' }
#' The second example below generates plot. \cr
#' 
#' @examples 
#' # Below example is used to get contact tracing lists based on staff id.
#'             
#' getContacts(staff_id= '1',
#'              patient_id = NA,
#'              reference_date = "2020-03-01",
#'              look_forward_days = 20,
#'              look_back_days = 3,
#'              data= hcvisits,
#'              plot=FALSE)
#'              
#' # Below example is used to get contact tracing lists based on patient id. 
#'            
#'  getContacts(staff_id= NA,
#'              patient_id = '1000',
#'              reference_date = "2020-03-01",
#'              look_forward_days = 50,
#'              look_back_days = 3,
#'              data= hcvisits,
#'              plot=TRUE)     
#' @export

getContacts <- function(staff_id= NA,
                        patient_id = NA,
                        reference_date = "2020-03-01",
                        look_forward_days = 7,
                        look_back_days = 0,
                        plot=F,
                        data= NULL){
  
  
  
  if(is.null(data)){
    stop("Error: Data can't be NULL. Provide data.")
  }
  
  if(is.na(staff_id) & is.na(patient_id)){
    stop("Error: Both staff_id & patient_id cannot be NA. Provide proper input id.")
  }
  
  if(!is.na(staff_id) & !is.na(patient_id)){
    stop("Error: Both staff_id & patient_id cannot be used at the same time. Provide proper input id.")
  }
  
  setDT(data)   
  data[, (colnames(data)) := lapply(.SD, as.character), .SDcols = colnames(data)]
  
  if(!is.na(staff_id)){
    
    assertthat::assert_that(is.character(staff_id))
    setDT(data)
    
    if(!("staff_id" %in% names(data))){
      data[,staff_id:=paste0(staff_name)]
      value_id <- paste0("clin_",trimws(staff_id))
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
    data_all <- data
    
    library(dplyr)
    my_dplyr_fun <- function(data, id1) {
      id2s <- filter(data, staff_id == {{id1}}) %>%
        pull(patient_id)
      data %>%
        filter(patient_id %in% id2s)
    }
    value_id <- paste0("clin_",trimws(sub('.*:', '', staff_id)))
    
    data_subsetted<- my_dplyr_fun(data=data,id1 = value_id)
    setDT(data_subsetted)
    data_subsetted <- data_subsetted[,.(staff_id)]
    data_subsetted <- data_subsetted[!duplicated(data_subsetted)]
    data <- merge(data,data_subsetted,by="staff_id")
    data <- data[!duplicated(data)]
    
    data[,days_diff := round(difftime(reference_date ,visit_date , units = c("days")))]
    
    data[,n_visits:=.N, by=.(patient_id,staff_id)]
    
    
    #Adding Days forward logic-----
    
    frwd_date <- as.Date(reference_date) + as.numeric(look_forward_days)
    
    data <- data[ (days_diff <=as.numeric(look_back_days) & days_diff > 0) | (visit_date >= reference_date),]
    
    data <- data[visit_date <= frwd_date,]
    
    
    if(nrow(data)==0){
      stop("No Visits found. Try changing input parameters.")
    }
    
    data[,pat_nurse:=paste(paste0(patient_id,'<--',staff_id,' (',visit_date,') Stage 2'),collapse = ' #'),by=.(patient_id)]
    data[,nurse_pat:=paste(paste0(staff_id,'-->',patient_id,' (',visit_date,') Stage 1'),collapse = ' #'),by=.(staff_id)]
    data[,final:=paste(unique(pat_nurse),collapse = ' #'),by=.(staff_id)]
    data[,final_2:=paste(unique(nurse_pat),collapse = ' #'),by=.(staff_id)]
    
    
    temp_wkrid <- staff_id
    
    if(length(unique(data$nurse_pat[data$staff_id == paste0('clin_',temp_wkrid)]))==0){
      stop("No Visits found. Try changing input parameters.")
      
    }
      
    raw_txt <- VisitContactTrace:::getContactsInternal(x=unique(data$nurse_pat[data$staff_id == paste0('clin_',temp_wkrid)]),
                                               y=unique(data$final[data$staff_id == paste0('clin_',temp_wkrid)]),
                                               dt=data)
    
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
                      setDT(data_all)[,.(patient_id,patient_name,patient_status,visit_date)],
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
      
      setnames(stg_1_dt,c("name","status"),c("patient_name","patient_status"))
      stg_1_dt <- as.data.frame(lapply(stg_1_dt, function(x) gsub('clin_','',x)))
    }
    
    #___1.16.4 Cleaning & Creating Secondary contacts tables -----
    
    stg_2_dt <-  table_txt[stage=='Stage 2',]
    stg_2_dt <- stg_2_dt[!duplicated(stg_2_dt)]
    stg_2_dt <- stg_2_dt[,.(from,visit_date)]
    names(stg_2_dt) <- c('clinician_id','visit_date')
    stg_2_dt <- stg_2_dt[clinician_id != paste0('clin_',temp_wkrid),]
    
    
    stg_2_dt <- merge(stg_2_dt,
                      setDT(data_all)[,.(staff_id,staff_name,staff_status,visit_date)],
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
      
      setnames(stg_2_dt,c("name","status"),c("staff_name","staff_status"))
      
      stg_2_dt <- as.data.frame(lapply(stg_2_dt, function(x) gsub('clin_','',x)))
    }
    #___1.16.5 Cleaning & Creating Tertiary contacts tables -----
    
    stg_3_dt <-  table_txt[stage=='Stage 3',]
    stg_3_dt <- stg_3_dt[!duplicated(stg_3_dt)]
    stg_3_dt <- stg_3_dt[,.(to,visit_date)]
    
    names(stg_3_dt) <- c('patient_id','visit_date')
    stg_3_dt <- stg_3_dt[!(patient_id %in% stg_1_dt$patient_id),]
    
    
    stg_3_dt <- merge(stg_3_dt,
                      setDT(data_all)[,.(patient_id,patient_name,patient_status,visit_date)],
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
      
      setnames(stg_3_dt,c("name","status"),c("patient_name","patient_status"))
      stg_3_dt <- as.data.frame(lapply(stg_3_dt, function(x) gsub('clin_','',x)))
    }
    
    if(plot==TRUE){ 
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
      
      
      #icon.color <- viridis::viridis_pal(option = "D")(length(unique(a$label)))
      #icon.color <- RColorBrewer::brewer.pal(length(unique(a$label)), "Set1")
      icon.color <- pals::viridis(length(unique(a$label)))
      
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
      
      lnodes <- a[,.(label,shape,icon.color,icon.face,icon.code,Status)]
      lnodes <- lnodes[!duplicated(lnodes)]
      
      
      plot= visNetwork(a, b1, width = "100%") %>%
        
        visPhysics(stabilization = FALSE) %>%
        addFontAwesome(name = "font-awesome-visNetwork") %>%
        visLegend(addNodes = lnodes, useGroups = FALSE) %>%
        visEdges(shadow = TRUE,
                 arrows =list(to = list(enabled = TRUE, scaleFactor = 2)),
                 color = list(color = "gray", highlight = "red"))
      
    }
    
    
    result <- list(primary_contact_list = stg_1_dt,
                   secondary_contact_list =stg_2_dt,
                   tertiary_contact_list =stg_3_dt,
                   plot=plot)
    
    return(result)
    
  } else if(!is.na(patient_id)){
    
        setDT(data)
        assertthat::assert_that(is.character(patient_id))
        
        if(!("patient_id" %in% names(data))){
          data[,patient_id:=paste0(patient_name)]
          value_id1 <- trimws(patient_id)
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
        
        
        data_all <- data
        
        
        my_dplyr_fun <- function(data, id1) {
          id2s <- filter(data,  patient_id == {{id1}}) %>%
            pull(staff_id)
          data %>%
            filter(staff_id %in% id2s)
        }
        value_id1 <- trimws(sub('.*:', '', patient_id))
        
        data_subset<- my_dplyr_fun(data=data,id1 = value_id1)
        setDT(data_subset)
        
        data_subset <- data_subset[,.(patient_id)]
        data_subset <- data_subset[!duplicated(data_subset)]
        
        data <- merge(data,data_subset,by="patient_id")
        data <- data[!duplicated(data)]
        
        
        data[,days_diff := round(difftime(reference_date ,visit_date , units = c("days")))]
        data[,n_visits:=.N, by=.(patient_id,staff_id)]
        
        
        frwd_date_1 <- as.Date(reference_date) + as.numeric(look_forward_days)
        
        data <- data[ days_diff <= as.numeric(look_back_days) & days_diff > 0 | visit_date >= reference_date,]
        
        data <- data[ visit_date <= frwd_date_1,]
        if(nrow(data)==0){
          stop("No Visits found. Try changing input parameters.")
        }
        
        data[,pat_nurse:=paste(paste0(patient_id,'<--',staff_id,' (',visit_date,') Stage 1'),collapse = ' #'),by=.(patient_id)]
        data[,nurse_pat:=paste(paste0(staff_id,'-->',patient_id,' (',visit_date,') Stage 2'),collapse = ' #'),by=.(staff_id)]
        data[,final_2:=paste(unique(nurse_pat),collapse = ' #'),by=.(patient_id)]
        data <- data[!duplicated(data$patient_id)]
        
        temp_patid <- trimws(sub('.*:', '', patient_id))
        
        if(length(unique(data$pat_nurse[data$patient_id == temp_patid]))==0){
          stop("No Visits found. Try changing input parameters.")
          
        }
        raw_txt_1 <- VisitContactTrace:::getContactsPatient(x=unique(data$pat_nurse[data$patient_id == temp_patid]),
                                                            y=unique(data$final_2[data$patient_id == temp_patid]),
                                                            dt=data)
        
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
                          setDT(data_all)[,.(staff_id,staff_name,staff_status,visit_date)],
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
                          setDT(data_all)[,.(patient_id,patient_name,patient_status,visit_date)],
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
                          setDT(data_all)[,.(staff_id,staff_name,staff_status,visit_date)],
                          by.x=c('clinician_id','visit_date'),
                          by.y=c('staff_id','visit_date'),
                          all.x=T)
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
        
        if(plot==TRUE){ 
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
          
          
          #icon.color <- viridis::viridis_pal(option = "D")(length(unique(a$label)))
          #icon.color <- RColorBrewer::brewer.pal(length(unique(a$label)), "Set1")
          #icon.color <- randomcoloR::randomColor(length(unique(a$label)),luminosity="dark")
          icon.color <- pals::viridis(length(unique(a$label)))
          
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
          
          lnodes <- a[,.(label,shape,icon.color,icon.face,icon.code,Status)]
          lnodes <- lnodes[!duplicated(lnodes)]
          
          
          plot= visNetwork(a, b1, width = "100%") %>%
            
            visPhysics(stabilization = FALSE) %>%
            addFontAwesome(name = "font-awesome-visNetwork") %>%
            visLegend(addNodes = lnodes, useGroups = FALSE) %>%
            visEdges(shadow = TRUE,
                     arrows =list(to = list(enabled = TRUE, scaleFactor = 2)),
                     color = list(color = "gray", highlight = "red"))
          
        }
        
        result <- list(primary_contact_list = stg_1_dt,
                       secondary_contact_list =stg_2_dt,
                       tertiary_contact_list =stg_3_dt,
                       plot=plot)
        
        return(result)
        
        
      }
  
}
