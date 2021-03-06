make_Conductance_graphs <- function(Gausian_Data,reduced_Gausian_Data,
                                    Liner_Data,reduced_Liner_Data,passive_Data,
                                    prefix,
                                    dt_row,
                                    dataNames,
                                    mainNames,
                                    colNames,
                                    doTest){
  dataList <- list(Gausian_Data,reduced_Gausian_Data,
                   Liner_Data,reduced_Liner_Data)


                                        #                 Tsuishi)

  N_data <- length(dataList)
  Colors <- c("red","orange","Blue","skyblue")
  LineType <- rep("solid",N_data)
  PointType <- c(rep("",N_data),"*","+")

  legends <- c("Gausian",
               "Gausian-reduced",
               "Liner",
               "Liner-reduced")


  rowNames <- rep(dt_row,length(colNames))

  mapply(function(data_name,mainName,rowname,colname){
    cat(mainName,"\n")
    Filename <- paste(OutputDir,prefix,data_name,".eps",sep="")

    data_list <- lapply(dataList,function(dataframe){
      return(make_matrix(dataframe,DELTA_T,data_name))})
    if(length(grep("amount",mainName))){
      data_list <- lapply(data_list,function(data_mat){
        return(data_mat*10^9)
      })
    }


    if(doTest){
      Gaus_liner_test <- rbind(DELTA_T,
                               sapply(DELTA_T,function(dt){
                                 t_test(subset(Gausian_Data,DT == dt)[[data_name]],
                                        subset(Liner_Data,DT == dt)[[data_name]],
                                        "two.sided",
                                        0.05)}))

      ## Gaus_reduced_test <- rbind(DELTA_T - 0.5,
      ##                             sapply(DELTA_T,function(dt){
      ##                               t_test(subset(Gausian_Data,DT == dt)[[data_name]],
      ##                                      subset(passive_Data,DT == dt)[[data_name]],
      ##                                      "two.sided",
      ##                                      0.05)}))
      
      ## Liner_reduced_test <- rbind(DELTA_T + 0.5,
      ##                             sapply(DELTA_T,function(dt){
      ##                               t_test(subset(Liner_Data,DT == dt)[[data_name]],
      ##                                      subset(passive_Data,DT == dt)[[data_name]],
      ##                                      "two.sided",
      ##                                      0.05)}))

      Gaus_reduced_test <- rbind(DELTA_T - 0.5,
                                  sapply(DELTA_T,function(dt){
                                    t_test(subset(Gausian_Data,DT == dt)[[data_name]],
                                           subset(reduced_Gausian_Data,DT == dt)[[data_name]],
                                           "two.sided",
                                           0.05)}))
      
      Liner_reduced_test <- rbind(DELTA_T + 0.5,
                                  sapply(DELTA_T,function(dt){
                                    t_test(subset(Liner_Data,DT == dt)[[data_name]],
                                           subset(reduced_Liner_Data,DT == dt)[[data_name]],
                                           "two.sided",
                                           0.05)}))

      Reduceds_test <- rbind(DELTA_T,
                             sapply(DELTA_T,function(dt){
                               t_test(subset(reduced_Gausian_Data,DT == dt)[[data_name]],
                                      subset(reduced_Liner_Data,DT == dt)[[data_name]],
                                      "two.sided",
                                      0.05)}))
      
    }else{
      Gausian_pass_test <- c()
      Gaus_reduced_test <- c()
      Liner_pass_test <- c()
      Liner_reduced_test <- c()
      Reduceds_test <- c()
    }

    plot_one_graph(data_list,
                   mainName,
                   rowname,
                   colname,
                   legends,
                   Colors,
                   LineType,
                   DELTA_T,
                   FALSE,
                   Gaus_liner_test,
                   list(Gaus_reduced_test,Liner_reduced_test),
                   Reduceds_test,
                   FALSE# star_black
                   )

    
    dev.copy2eps(file=Filename)
    cat("Output ->",Filename,"\n")
    cat("\n")
  },dataNames,mainNames,rowNames,colNames)

  cat("the legend \n")
  Filename <- paste(OutputDir,prefix,"legend",".eps",sep="")
  make_legends(legends,Colors,LineType,PointType)
  dev.copy2eps(file=Filename)
  cat("Output ->",Filename,"\n")

}
