# Functions 
pop_colors = c("darkgoldenrod2", "lightgoldenrod3", "darkgreen", "orangered3", "magenta4", 
               "royalblue4", "midnightblue", "lavenderblush4", "darkred", "tan4","darkslategrey")
pop_names = c('African', 'Amish', 'Latino', 'Ashkenazi Jewish',
              'East Asian', 'European (Finnish)', 'European (non-Finnish)',
              'Other', 'South Asian', 'Middle Eastern',"Brazilian ABraOM")

names(pop_colors) = pop_names

get_pop_dfs <- function(df=NULL, freq_threshold=0.01){
  
  col_idx_alternative <- 8
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
    pop_var_lists[[i]] <- c(pop[,"Variant ID"])
    i <- i+1
  }
  
  names(pop_var_lists) <- pop_names
  return(pop_var_lists)
}


get_number_of_vars <- function(pop_var_lists){
  all_vars <- unname(unlist(pop_var_lists, recursive = FALSE))
  return(length(unique(all_vars)))
}

barplot_population_variants <- function(num_total, num_common, num_private, pop_name, pop_color, num_all_among_pops,map){
  
  if(num_all_among_pops == 0){
    num_all_among_pops = num_total
  }
  
  if (pop_name == "European (Finnish)"){
    pop_name <- "Finnish"
  } else if (pop_name == "European (non-Finnish)"){
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
    title_size<-12
    text_size<-10
  }
  if(map==TRUE){
    title_size<-40
    text_size<-45
  }

  return(ggplot(barplot_df, aes(x = legend, y = value, fill=factor(fill_to_high, levels=c("toHigh","Value")))) + 
           geom_bar(stat = "identity", show.legend = FALSE, width=1, color='black', size=1.8) +
           scale_fill_manual(values = c("transparent",pop_color)) +
           labs(x='', y="") + 
           ggtitle(pop_name) +
           theme(plot.title = element_text(hjust = 0.5, size=title_size),
                 text = element_text(size=text_size, face="bold"),
                 axis.ticks.y = element_line(color = "black"),
                 axis.ticks.length = unit(0.2, "cm"),
                 axis.text.x=element_text(color="black",margin=margin(t=-2, b=15)),
                 axis.text.y=element_text(color="black",margin=margin(t=-2, b=15)),
                 axis.title.x=element_blank(),
                 axis.title=element_text(color="black"),
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



biovars_map<-function(current_dir, saving_path, plot_list){
  
  #Search for background image
  map_file <- paste(current_dir, "assets/world_map.png", sep='')
  ima <- readPNG(map_file)
  
  #Create the file 
  png(saving_path, width = 4500, height = 2500, units = "px",family="AvantGarde")
  plot.new()
  lim <- par()
  rasterImage(ima, lim$usr[1],lim$usr[3] ,lim$usr[2] , lim$usr[4])
  

  #Plot the pops_plots from the list
  #Latino
  vp <- viewport(.2, 0.55,width =.07, height = .15) 
  pl <- plot_list[[3]]
  invisible(capture.output(print(pl, vp = vp)))
  
  #Finish
  pl2 <- plot_list[6]
  vp2 <- viewport(.53, 0.92, width =.07, height = .15)
  invisible(capture.output(print(pl2, vp = vp2)))
  
  #European
  pl5 <- plot_list[7]
  vp5 <- viewport(.45, 0.78,width =.07, height = .15)
  invisible(capture.output(print(pl5, vp = vp5)))
  
  #East Asian
  pl4 <- plot_list[5]
  vp4 <- viewport(.73, 0.66,width =.07, height = .15)
  invisible(capture.output(print(pl4, vp = vp4)))
  
  #South Asian
  pl7 <- plot_list[9]
  vp7 <- viewport(.65, 0.62, width =.07, height = .15)
  invisible(capture.output(print(pl7, vp = vp7)))
  
  #Middle Eastern
  pl8 <- plot_list[10]
  vp8 <- viewport(.58, 0.6, width =.07, height = .15)
  invisible(capture.output(print(pl8, vp = vp8)))
  
  #Amish
  pl10 <- plot_list[2]
  vp10<- viewport(.23, 0.7,width =.07, height = .15)
  invisible(capture.output(print(pl10, vp = vp10)))
  
  #Ashkenazi Jewish
  pl9 <- plot_list[4]
  vp9 <- viewport(.57, 0.76, width =.07, height = .15)
  invisible(capture.output(print(pl9, vp = vp9)))
  
  if(length(plot_list)==11){
    #African
    pl3 <- plot_list[1]
    vp3 <- viewport(.5, 0.5,width =.07, height = .15)
    invisible(capture.output(print(pl3, vp = vp3)))
    
    #Brazilian
    pl11 <- plot_list[11]
    vp11 <- viewport(.31, 0.36, width =.07, height = .15)
    invisible(capture.output(print(pl11, vp = vp11)))
  }else{
    #African
    pl3 <- plot_list[1]
    vp3 <- viewport(.5, 0.5,width =.07, height = .15)
    invisible(capture.output(print(pl3, vp = vp3)))
  }
  
  # Legends
  legend(x="bottomleft", legend=c("1.Total Variants", "2.Shared Variants","3.Private Variants"),
         pch=16, col="grey", title="Number of Variants",cex=5.5,bty = "n")
  
  dev.off()
  
}


biovars_plot_list<- function(current_dir, saving_path, df, frequency=0.01, map=FALSE){
  
  if(map){
    pop_dfs <- get_pop_dfs(df,frequency)
    pops_vars <- get_pop_var_lists(pop_dfs)
    num_unique_vars <- get_number_of_vars(pops_vars)
    plot_list <- get_all_plots(pops_vars, pop_colors,map)
    biovars_map(current_dir, saving_path, plot_list)
  }
  else {
    pop_dfs <- get_pop_dfs(df,frequency)
    pops_vars <- get_pop_var_lists(pop_dfs)
    num_unique_vars <- get_number_of_vars(pops_vars)
    plot_list <- get_all_plots(pops_vars, pop_colors,map)
    grid_plot <- cowplot::plot_grid(plotlist = plot_list, align = "hv") 
    sink_output <- ggsave2(saving_path, grid_plot,width=10,height=8)
  }
}