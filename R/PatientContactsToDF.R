#' A function rather aimed at developers
#' @description A function that does blabla, blabla.
#' @keywords internal
#' @export

PatientContactsToDF <- function(a){

  frwd_dir <- grep('-->',a,value = T)
  bkwd_dir <- grep('<--',a,value = T)

  first_column_frwd <- trimws(sub('-->.*$','', frwd_dir))
  second_column_frwd <- trimws(sub('.*\\-->', '', frwd_dir))
  third_column_frwd <- trimws(str_extract_all(second_column_frwd,  "(?<=\\().+?(?=\\))"))
  forth_column_frwd <- trimws(sub('.*\\)', '', second_column_frwd))
  #second_column_frwd <- trimws(sub("^\\s*(\\S+).*", "\\1", second_column_frwd))
  second_column_frwd <- trimws(gsub("\\(.+\\).*", "", second_column_frwd))


  first_column_bkwd <- trimws(sub('<--.*$','', bkwd_dir))
  second_column_bkwd <- trimws(sub('.*\\--', '', bkwd_dir))
  third_column_bkwd <- trimws(str_extract_all(second_column_bkwd,  "(?<=\\().+?(?=\\))"))
  forth_column_bkwd <- trimws(sub('.*\\)', '', second_column_bkwd))
  #second_column_bkwd <- trimws(sub("^\\s*(\\S+\\S+).*", "\\1", second_column_bkwd))
  second_column_bkwd <- trimws(gsub("\\(.+\\).*", "", second_column_bkwd))

  df_frwd <- data.frame(column1=first_column_frwd,
                        column2=second_column_frwd,
                        direction="-->",
                        visit_date=third_column_frwd,
                        stage=forth_column_frwd)
  df_bkwd <- data.frame(column1=first_column_bkwd,
                        column2=second_column_bkwd,
                        direction="<--",
                        visit_date=third_column_bkwd,
                        stage=forth_column_bkwd)

  df <- rbind(df_frwd,df_bkwd)
  return(df)

}
