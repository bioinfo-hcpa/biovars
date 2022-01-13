library(rmarkdown)
plot_summary <- function(current_dir, saving_dir, data, genome_version, info_gene, start, end, frequency,
                            colorfreqheat=c("grey96",'#9ab7d0','#8c96c6','#8856a7','#810f7c'),
                            coloranotheat=NULL, colortranscript=c("#b3cde3","#8856a7")){
  file <- paste(current_dir, "assets/biovars_interactive.Rmd", sep='')
  world_png_file <- paste(current_dir, "assets/world_map.png", sep='') 
  output_file <- paste(saving_dir, "biovars_summary.html", sep='')

  options(warn=-1)
  `%ni%` = Negate(`%in%`)
  abraom <- 'Brazilian ABraOM' %in% colnames(data)

  rmarkdown::render(input  = file,quiet=TRUE,output_file=output_file,params= list( data= data,
                                                                        genome_version= genome_version,
                                                                        gene=info_gene,
                                                                        start= as.character(start),
                                                                        end=as.character(end),
                                                                        abraom=abraom,
                                                                        world_png_file=world_png_file,
                                                                        frequency=frequency,
                                                                        colorfreqheat=colorfreqheat,
                                                                        colortranscript=colortranscript))
  
  
}


