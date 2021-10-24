library(rmarkdown)
plot_summary <- function(current_dir, saving_dir, data, genome_version, start, end, frequency,
                            colorfreqheat=c("grey96",'#9ab7d0','#8c96c6','#8856a7','#810f7c'),
                            coloranotheat=NULL, colortranscript=c("#b3cde3","#8856a7")){
  file <- paste(current_dir, "assets/biovars_interactive.Rmd", sep='')
  options(warn=-1)
  `%ni%` = Negate(`%in%`)

  output_file = paste(saving_dir, "biovars_summary.html")

  info_gene<- unique(data$Gene)
  abraom= 'ABraOM' %in% colnames(data)
  if (length(info_gene)==1){
  rmarkdown::render(input  = file,quiet=TRUE,output_file,params= list( data= data,
                                                                        genome_version= genome_version,
                                                                        gene=info_gene,
                                                                        start= as.character(start),
                                                                        end=as.character(end),
                                                                        abraom= abraom,
                                                                        frequency=frequency,
                                                                        colorfreqheat=colorfreqheat,
                                                                        colortranscript=colortranscript))
  }
  if (length(info_gene) > 1  ){
     cat('Data contains more than one gene\n')
     cat(info_gene)
     gene <- readline(prompt="Chose gene to analyze: ")
     if(gene %ni%  info_gene){
       return(' Select one gene.')
     } else{
      message<- readline(prompt="Change the start and end position? [y/n] ")
      if (message=='y' || message== 'Y'){
         start <- readline(prompt="Start: ")
         end <- readline(prompt="End: ")
      }
      if (message=='n' || message== 'N'){
          print('Continue...')
      }
      if (message  %ni% c('y','Y','n','N')){
          return('Exiting.')
      }
     # Subset all rows based on gene input in data 
     dat<-subset(data, data$Gene %in% gene)
     # Plot it
     rmarkdown::render(input  = file,quiet=TRUE,output_file,params= list( data= dat,
                                                                           genome_version= genome_version,
                                                                           gene=gene,
                                                                           start= as.character(start),
                                                                           end=as.character(end),
                                                                           frequency=frequency,
                                                                           abraom=abraom,
                                                                           colorfreqheat=colorfreqheat,
                                                                           colortranscript=colortranscript))}
  }
}
