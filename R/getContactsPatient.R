#' A function rather aimed at developers
#' @description A function that does blabla, blabla.
#' @keywords internal
#' @export
getContactsPatient <- function(x,y,dt){

  setDT(dt)
  # a <- dt[epi_mrnum==x & wkr_id==y,nurse_pat]
  # b <- dt[epi_mrnum==x & wkr_id==y,final]
  #
  a <- base::trimws(unlist(strsplit(x,'#')))
  a <- a[order(unlist(str_extract_all(a,  "(?<=\\().+?(?=\\))")))]

  b <- base::trimws(unlist(strsplit(y,'#')))
  b <- b[order(unlist(str_extract_all(b,  "(?<=\\().+?(?=\\))")))]

  new <- list()
  for(i in 1:length(a)){
    u <- b[which(gsub("-->.*", "",b) %in%  unlist(base::trimws(gsub('\\(','',str_extract_all(a[i], "clin_.+\\(")))))]

    u_dates <- u[which(unlist(str_extract_all(u,  "(?<=\\().+?(?=\\))")) >= unlist(str_extract_all(a[i],  "(?<=\\().+?(?=\\))")))]
    #Stage 3 ---
    if(length(u_dates) > 0 ){
      stg3_wrkr <- base::trimws(gsub('\\-->| \\(','',unlist(str_extract_all(u_dates, "-->.+\\("))))
      stg3_wrkr <- stg3_wrkr[order(stg3_wrkr)]
      stg3_wrkr_data <- strsplit(unique(dt[patient_id %in% unique(stg3_wrkr),pat_nurse]),'#')
      stg3_wrkr_ls_names <- unlist(lapply(stg3_wrkr_data,function(x) strsplit(x[1],'<--')[[1]][1]))
      names(stg3_wrkr_data) <- stg3_wrkr_ls_names
      new_l <- list()
      for(j in 1:length(stg3_wrkr)){
        #print(j)
        new_k <- list()

        curr <- unique(unlist(lapply(stg3_wrkr_data[[stg3_wrkr[j]]],function(x)strsplit(x,'<--')[[1]][1])))
        curr_data <- unlist(stg3_wrkr_data[[stg3_wrkr[j]]])
        u_curr <- u_dates[which(base::trimws(str_extract(u_dates, "(?<=-->)[^(]+")) %in% curr)]
        if(length(u_curr)>1){
          for (k in 1:length(u_curr)) {
            u_curr_dates <- curr_data[which(unlist(str_extract_all(curr_data,  "(?<=\\().+?(?=\\))")) >= unlist(str_extract_all(u_curr[k],  "(?<=\\().+?(?=\\))")))]
            #u_curr_new <- paste0(strrep(" ", max(nchar(a[i])) - 31), u_curr[k])
            #u_curr_dates <- paste0(strrep(" ", max(nchar(u_curr_new)) - 35), u_curr_dates)
            u_curr_new <- paste0(strrep(" ", max(nchar(gsub("(\\<-\\-).*",'\\1',a[i],perl = T)))), u_curr[k])
            u_curr_dates <- paste0(strrep(" ", max(nchar(gsub("(\\-\\->).*",'\\1',u_curr_new,perl = T)))), u_curr_dates)


            u_curr_dates <- gsub('Stage 1','Stage 3',u_curr_dates)
            u_curr_dates <- u_curr_dates[order(unlist(str_extract_all(u_curr_dates,  "(?<=\\().+?(?=\\))")))]

            #new_l[[j+k]] <- append(u_curr_new,u_curr_dates)
            new_k[[k]] <- append(u_curr_new,u_curr_dates)

          }
          new_l[[j]] <- c(unique(new_k),new_l[j])

        } else{

          u_curr_dates <- curr_data[which(unlist(str_extract_all(curr_data,  "(?<=\\().+?(?=\\))")) >= unlist(str_extract_all(u_curr,  "(?<=\\().+?(?=\\))")))]
          #u_curr_new <- paste0(strrep(" ", max(nchar(a[i])) - 31), u_curr)
          u_curr_new <- paste0(strrep(" ", max(nchar(gsub("(\\<-\\-).*",'\\1',a[i],perl = T)))), u_curr)
          u_curr_dates <- paste0(strrep(" ", max(nchar(gsub("(\\-\\->).*",'\\1',u_curr_new,perl = T)))), u_curr_dates)

          #u_curr_dates <- paste0(strrep(" ", max(nchar(u_curr_new)) - 35), u_curr_dates)
          u_curr_dates <- gsub('Stage 1','Stage 3',u_curr_dates)
          u_curr_dates <- u_curr_dates[order(unlist(str_extract_all(u_curr_dates,  "(?<=\\().+?(?=\\))")))]

          new_l[[j]] <- append(u_curr_new,u_curr_dates)
        }

      }

      u_dates_list <- unlist(unique(new_l))
      new[[i]] <- append(a[i],u_dates_list)


    } else {

      new[[i]] <- a[i]


    }

    #u_dates <- paste0(strrep(" ", max(nchar(a[i])) - 35), u_dates)

    #cat('\n')
    #cat(a[i],'\t\n\t' , paste0(u_dates, sep = '\n\t'))
  }
  new_2 <- unlist(new)
  return(new_2)

}
