#Functions 
pop_colors = c("darkgoldenrod2", "lightgoldenrod3", "darkgreen", "orangered3", "magenta4", 
               "royalblue4", "midnightblue", "lavenderblush4", "darkred", "tan4","grey")
pop_names = c('African', 'Amish', 'Latino', 'Ashkenazi.Jewish',
              'East.Asian', 'European..Finnish.', 'European..non.Finnish.',
              'Other', 'South.Asian', 'Middle.Eastern',"Brazilian.ABraOM")

names(pop_colors) = pop_names

get_reoordered_df <- function(df){
  col_idx_homo <- grep("Number.of.Homozygotes", names(df))
  col_idx_hemi <- grep("Number.of.Hemizygotes", names(df))
  col_len <- length(names(df))
  
  return(df[, c(1:col_idx_homo,col_idx_hemi,(col_idx_homo+1):col_len)[-col_idx_hemi-1]])
}



get_pop_dfs <- function(df=NULL, freq_threshold=0.01){
  
  col_idx_alternative <- grep("Alternative", names(df))
  population_indexes <- c((col_idx_alternative+1):length(names(df)))
  
  populations_dfs <- c()
  i <- 1
  for (pop_idx in population_indexes){
    df_temp <- df[, c(1:col_idx_alternative,pop_idx)]
    populations_dfs[[i]] <- df_temp[df_temp[,ncol(df_temp)] > freq_threshold, ]
    i <- i + 1
  }
  
  return(populations_dfs)
}


get_pop_var_lists <- function(populations_dfs=NULL){
  
  pop_var_lists <- list()
  pop_names <- c()
  i <- 1
  for (pop in populations_dfs){
    
    pop_names[i] <- names(pop)[length(names(pop))]
    pop_var_lists[[i]] <- c(pop[,"Variant.ID"])
    i <- i+1
  }
  
  names(pop_var_lists) <- pop_names
  return(pop_var_lists)
}


keep_singles <- function(v){
  v[!(v %in% v[duplicated(v)])] 
}


get_number_of_vars <- function(pop_var_lists){
  all_vars <- unname(unlist(pop_var_lists, recursive = FALSE))
  unique <- keep_singles(all_vars)
  return(length(unique))
}

barplot_population_variants <- function(num_total, num_common, num_private, pop_name, pop_color, num_all_among_pops,map){
  
  if(num_all_among_pops == 0){
    num_all_among_pops = num_total
  }
  
  if (pop_name == "European..Finnish."){
    pop_name <- "Finnish"
  } else if (pop_name == "European..non.Finnish."){
    pop_name <- "European"
  }
  pop_name <- gsub("\\."," ",pop_name)
  
  
  value <- c(num_total, num_common, num_private, num_all_among_pops-num_total, 
             num_all_among_pops-num_common, num_all_among_pops-num_private)
  fill_to_high <- c("Value", "Value", "Value", "toHigh", "toHigh", "toHigh")
  legend <- c("1", "2", "3", "1", "2", "3")
  barplot_df <- data.frame(value,legend,fill_to_high)
  barplot_df$legend = factor(barplot_df$legend, levels = c("1","2","3"))
  
  if(map==FALSE){
    title_size<-15
    text_size<-10
  }
  if(map==TRUE){
    title_size<-30
    text_size<-30
  }
  return(ggplot(barplot_df, aes(x = legend, y = value, fill=factor(fill_to_high, levels=c("toHigh","Value")))) + 
           geom_bar(stat = "identity", show.legend = FALSE, width=1, color='black', size=1.8) +
           scale_fill_manual(values = c("transparent",pop_color)) +
           labs(x="", y="") + 
           ggtitle(pop_name) +
           theme(plot.title = element_text(hjust = 0.5, size=title_size),
                 text = element_text(size=text_size, face="bold", family="AvantGarde"),
                 axis.line=element_blank(),
                 axis.text.x=element_text(color="black", margin=margin(t=-2, b=15)),
                 axis.text.y=element_blank(),
                 axis.ticks=element_blank(),
                 axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 legend.position="none",
                 panel.background=element_blank(),
                 panel.border=element_blank(),
                 panel.grid.major=element_blank(),
                 panel.grid.minor=element_blank(),
                 plot.background=element_blank()))
}

get_all_plots <- function(pops_variants, pop_colors,map){
  
  num_all_among_pops <- get_number_of_vars(pops_variants)
  plot_list <- list()
  
  i <- 1
  for(pop in pops_variants){
    current_variants <- pop
    current_pop_name <- names(pops_variants)[i]
    all_other_variants <- unlist(unname(pops_variants[c(1:length(pops_variants))[-i]]))
    
    num_total <- length(current_variants)
    num_common <- length(intersect(current_variants, all_other_variants))
    num_private <- num_total-num_common 
    
    pop_plot <- barplot_population_variants(num_total, num_common, num_private, current_pop_name, 
                                            pop_colors[current_pop_name][[1]], num_all_among_pops,map)
    
    plot_list[[i]] <- pop_plot
    i <- i+1
  }
  
  return (plot_list)
}



biovars_map<-function(plot_list){
  
  #Search for background image
  map_file=system("ls -f -R  ~/*/biovars_file_world_map.png", intern = TRUE)
  ima <- readPNG(map_file)
  
  #Create the file 
  png("rplot_world_view.png", width = 4500, height = 2500, units = "px",family="AvantGarde")
  plot.new()
  lim <- par()
  rasterImage(ima, lim$usr[1],lim$usr[3] ,lim$usr[2] , lim$usr[4])
  
  #Plot the pops_plots from the list
  vp <- viewport(.2, 0.55,width =.04, height = .10) 
  pl <- plot_list[3]
  print(pl, vp = vp)
  
  pl2 <- plot_list[6]
  vp2 <- viewport(.53, 0.87, width =.04, height = .10)
  print(pl2, vp = vp2)
  
  pl5 <- plot_list[7]
  vp5 <- viewport(.5, 0.78,width =.04, height = .10)
  print(pl5, vp = vp5)
  
  pl3 <- plot_list[1]
  vp3 <- viewport(.5, 0.5,width =.04, height = .10)
  print(pl3, vp = vp3)
  
  pl4 <- plot_list[5]
  vp4 <- viewport(.73, 0.66,width =.04, height = .10)
  print(pl4, vp = vp4)
  
  pl7 <- plot_list[9]
  vp7 <- viewport(.65, 0.62, width =.04, height = .10)
  print(pl7, vp = vp7)
  
  pl8 <- plot_list[10]
  vp8 <- viewport(.58, 0.6, width =.04, height = .10)
  print(pl8, vp = vp8)
  
  pl10 <- plot_list[2]
  vp10<- viewport(.23, 0.7,width =.04, height = .10)
  print(pl10, vp = vp10)
  
  pl9 <- plot_list[4]
  vp9 <- viewport(.57, 0.7, width =.04, height = .10)
  print(pl9, vp = vp9)
  
  if(length(plot_list)==11){
    pl11 <- plot_list[11]
    vp11 <- viewport(.31, 0.36, width =.04, height = .10)
    print(pl11, vp = vp11)}
  
  # Legends
  legend(x="bottomleft", legend=c("1.Total Variants", "2.Common Variants","3.Private Variants"),
         pch=16, col="grey", title="Variants distribution",cex=4.0,bty = "n")
  
  
  legend(x="bottomright", legend='bioinfo-HCPA', col="grey",cex=2.8,bty = "n")
  dev.off()
  
}



biovars_plot_list<- function(df,frequency=0.01,map=FALSE){

  # Dataframe is from biovars 
  if("Brazilian ABraOM" %in% colnames(df)){
    new_names<-c("Variant.ID","rsID", "Gene","Annotation","Chromosome", "Location", "Reference","Alternative","African", "Amish", "Latino","Ashkenazi.Jewish",      
                 "East.Asian","European..Finnish.","European..non.Finnish.", "Other","South.Asian","Middle.Eastern","Brazilian.ABraOM") 
    colnames(df)<- new_names
  }
  # Dataframe is from pynoma only 
   else{
     df <- get_reoordered_df(df)
   }

  #Pot the data based with or without image.
  if(map==FALSE){
    pop_dfs <- get_pop_dfs(df,frequency)
    pops_vars <- get_pop_var_lists(pop_dfs)
    num_unique_vars <- get_number_of_vars(pops_vars)
    plot_list <- get_all_plots(pops_vars, pop_colors,map)
    return(cowplot::plot_grid(plotlist = plot_list, align = "hv"))
  }
  if(map ==TRUE){
    pop_dfs <- get_pop_dfs(df,frequency)
    pops_vars <- get_pop_var_lists(pop_dfs)
    num_unique_vars <- get_number_of_vars(pops_vars)
    plot_list <- get_all_plots(pops_vars, pop_colors,map)
    biovars_map(plot_list)
  }
}
#Teste 
#data<-read.csv('/home/lola/Documents/BIOVARS/biovars/aqui.csv')
#biovars_plot_list(data,map=TRUE,frequency=0.8)

