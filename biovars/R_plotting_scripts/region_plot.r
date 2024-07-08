library(ggplot2)
library(httr)
library( httr )
library(jsonlite )
library( xml2 )
library(grid)
library(dplyr)
library(RColorBrewer)
library(stringr)
library(gridExtra)
library(gggenes)
library(cowplot)
library(curl)

#Heatmap
##hetamap for frequencies and annotations 
info_to_plot<-function(data,start,end){
  `%ni%` <- Negate(`%in%`)
  #get populations names
  names<-colnames(data)
  pops_name<-names[9:length(names)]
  length_pops_name<- length(pops_name)
  #get the position 
  data<-data[(data$Location>start & data$Location<end),]
  #Verify if data contains any position 
  if(dim(data)[1]==0 & 0 == length(which(start>=data$Location & end<=data$Location))){
     print("The data does not contain the range given.Try again by providing another start and end position")
  }
  position <- as.numeric(data$Location[])
  ID <- as.character(data$`Variant ID`[])
  Annotation <- as.character(data$Annotation[])
  vetor<-vector()
  vetor2 <- vector()
  vetor3<-vector()
  for(i in 1:length(position)){
      vetor<-append(vetor,rep(position[i],length_pops_name))
      vetor2<-append(vetor2,rep(ID[i],length_pops_name))}
  info<- data.frame(vetor,vetor2)
  colnames(info)<-c('Position','ID')
  info['Population']<- rep(pops_name[1:length_pops_name],length(info$Position)/length_pops_name)
  frequency<- vector()
  annotation<-vector()
  begin<-grep(pops_name[1], colnames(data))
  #Get frequency and annotation information from data
  frequency<- vector()
  annotation<-vector()
  begin<-9
  for(i in 1:length(data$Location)){
      for(j in begin:length(colnames(data))){
        frequency <- append(frequency,data[i,j])
        if(data[i,j]!=0){
          annotation<- append(annotation,Annotation[i])
        }else{
          annotation<- append(annotation,'No Variant')
        }}}
  info['Frequency']<-frequency
  info['Annotation']<-annotation
  #Adjustments
  info$Position<- as.character(info$Position)
  info$ID <- as.character(info$ID[])
  split_ID=strsplit(info$ID,'-')
  dat<-data.frame(t(sapply(split_ID,c)))
  dat <-dat %>% mutate_if(is.factor, as.character)
  dat$X3 <- lapply(dat$X3, str_trunc, 2, ellipsis = "")
  dat$X4 <- lapply(dat$X4, str_trunc, 2, ellipsis = "")
  info$ID<- as.character(paste(dat$X2,dat$X3,dat$X4,sep='-'))
  return(info)}



biovars_plot<- function(data,start,end,mut=F){
  start<-as.numeric(start)
  end<-as.numeric(end)
  info<-info_to_plot(data,start,end)
  info_length<-length(unique(info$ID))
  if(info_length > 80){
    return('Not acceptable range. Range needs to be equal or less than 80nt or you try to plot a range greater than the data lentgth')
    #TODO: return above message as code to be logged by biovars package
  } else{
    min_value <-min(info$Frequency[info$Frequency > 0])
    max_value<-max(info$Frequency[info$Frequency > 0])
    gene=data$Gene[1]
    if(mut==F){
      h<-ggplot(info,aes(x=ID,y=Population,fill=Frequency))+
        geom_tile(colour="grey95",size=0.5)+
        scale_fill_gradientn(colours = c('grey100',brewer.pal(name='Reds',n=8)), values = c(0, 0.0001, 1))+
        coord_fixed(ratio = 1.2)+
        scale_y_discrete(expand=c(0,0))+
        scale_x_discrete(expand=c(0,0))+
        labs(x="Variant_ID",y="")+
        guides(fill = guide_colourbar(barwidth = 1.0, barheight = 7))+
        theme(text=element_text(family="AvantGarde"),
              axis.text.y = element_text(size = 12, color='grey10',hjust=0),
              legend.text = element_text(size=12),
              legend.title =  element_text(size=12),
              axis.text.x = element_text(size = 9, angle= 70,vjust = 0.5, hjust=1,color='grey10', margin = margin(t = -23, r = 20, b = 2, l = 0)),
              axis.title.x= element_text(size = 10, color='grey10',margin = margin(1.5,0,0,0,unit="cm"),face = "bold"))
      return(h)}
    if(mut==T){
      colours=c('No Variant'='grey95',
                '5_prime_UTR_variant'='darkgoldenrod2',
                "start_lost"="lightgoldenrod3",
                "missense_variant"="darkgreen",
                "inframe_insertion"="orangered3", 
                "synonymous_variant"="magenta4",
                "inframe_deletion"="royalblue4", 
                "stop_gained"="midnightblue",
                "frameshift_variant"="lavenderblush4", 
                "splice_region_variant"="#F58D05", 
                "intron_variant"="darkred", 
                "splice_donor_variant"="tan4",
                "stop_lost"="#485744",
                "3_prime_UTR_variant"="#FCEC3A",
                "exonic;splicing"='indianred1',
                "upstream"='magenta')
      h<-ggplot(info,aes(ID,Population,fill=Annotation))+
        geom_tile(colour="white",size=0.5)+
        coord_fixed(ratio = 1.2)+
        scale_fill_manual(values = colours) +
        labs(x="Position",y="")+
        theme(text=element_text(family="AvantGarde"),
              axis.text.y = element_text(size = 12, color='grey10',hjust=0),
              panel.background = element_blank(),
              legend.text = element_text(size=12),
              legend.position = "bottom",
              legend.title = element_text(size=12),
              axis.text.x = element_text(size = 9, angle= 70,vjust = 0.5, hjust=1,color='grey10', margin = margin(t = -23, r = 20, b = 2, l = 0)),
              axis.title.x= element_text(size = 10, color='grey10',margin = margin(1.5,0,0,0,unit="cm"),face = "bold",))
      #h<-h+guides(fill=guide_legend(nrow=2,byrow=TRUE))
      return(h)}}}


#TRANSCRIPT INFORMATION
#Get data from ensembl
ensembl_info <- function(gene,version){
  if (version== 'hg38' | version=='GRCh38'){
    server <- "http://rest.ensembl.org"
  }
  if (version == 'hg19' | version=='GRCh37'){
    server <- "https://grch37.rest.ensembl.org"
  }
  
  ext <-gsub("v",gene,"/lookup/symbol/homo_sapiens/v?expand=1")
  r <- GET(paste(server, ext, sep = ""), content_type("application/json"))
  stop_for_status(r)
  return(data.frame(fromJSON(toJSON(content(r),))))
  
}

#get the data 
transcript_info <-function(data,version,gene,start,end,
                          transcript_region,
                          canonical_color="orange", 
                          ncanonical_color="lightblue"){
  gene=toupper(gene)
  resu<-ensembl_info(gene,version)
  value<-as.numeric(rownames(subset(resu,resu$Transcript.is_canonical==1)))
  transcript <-data.frame(resu$Transcript.Exon[value])
  transcript['Transcript_ID']<-rep(as.character(resu$Transcript.id[value]),length(transcript$strand))
  transcript['Type'] <-rep('Canonical',length(transcript$strand))
  for(i in 1:length(resu$Transcript.is_canonical)){
    if(as.numeric(resu$Transcript.is_canonical[i])==0){
      temp_transcript <-data.frame(resu$Transcript.Exon[i])
      temp_transcript['Transcript_ID'] <- c(rep(as.character(resu$Transcript.id[i]),length(temp_transcript$strand)))
      temp_transcript['Type'] <-rep('Non Canonical',length(temp_transcript$strand))
      transcript <- rbind(transcript,temp_transcript)
      temp_transcript <-NULL}}
  transcript$start<-as.numeric(transcript$start)
  transcript$end<-as.numeric(transcript$end)
  transcript$Transcript_ID<-as.character(transcript$Transcript_ID)
  transcript$object_type<-as.character(transcript$object_type)
  transcript$strand<-as.numeric(transcript$strand)
  info_start<-(data[which.min(abs(start-data$Location)),])
  start_pos<-info_start$Location
  info_end<-(data[which.min(abs(end-data$Location)),])
  end_pos<-info_end$Location
  if (start_pos==end_pos){
    if (start==start_pos){
      start_pos<- start_pos+1
    } else{
      end_pos<-end_pos+1
    }
  }
  if(end_pos<start_pos){
    out<-transcript[transcript$end>=end_pos & transcript$start<=start_pos, ]
  }
  if(end>start){
    out<-transcript[transcript$end>start & transcript$start<end, ]
  }
  if(transcript_region==FALSE){
      resu<-plot_transcripts(transcript,gene,start,end,transcript_region,canonical_color, ncanonical_color)}
  if(transcript_region==TRUE){
     resu<-plot_transcripts(out,gene,start,end,transcript_region,canonical_color, ncanonical_color)}
  return(resu)
}


# Plot transcript information
plot_transcripts<-function(data,gene,start,end,transcript_region,canonical_color, ncanonical_color){
  #condition to arrow 
  data$strand <- data$strand == 1
  
  t<-ggplot(data, aes(xmin = start, xmax = end, y = Transcript_ID,fill=Type, forward = strand)) +
  geom_gene_arrow()+
  scale_fill_manual(values=c(canonical_color, ncanonical_color))+
  geom_gene_arrow(arrowhead_height = unit(3.5, "mm"), arrowhead_width = unit(3.5, "mm"))+
  theme_genes()+
  theme(text=element_text(family="AvantGarde"),
        axis.text.y = element_text(size = 12, color='grey10',hjust=1),
        legend.spacing.x = unit(1.0, 'cm'),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12),
        axis.text.x = element_text(size=9),
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y=element_blank(),
        panel.border = element_blank())
  if(transcript_region==FALSE){
    t<-t+annotate("rect", xmin=as.numeric(start), xmax=as.numeric(end), ymin=1, ymax=Inf, 
                  alpha=0.2, fill="blue",colour='grey')
  }

  t<-t+guides(fill=guide_legend(nrow=1,byrow=T))
}

#Get legend 
get_legend<-function(h){
  tmp <- ggplot_gtable(ggplot_build(h))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}


#Plot heat with and without transcripts (final plot)

# You can set the color of transcripts with canonical_color and ncanonical_color parameters,
# I will implement the same in heatmap for mut=F and mut=T to see annotation for each variant
#Transcript_region to show all transcript length or just the region where the region falls.
#If transcript_region==False, it shows all transcripts length and a shadow in the regions that
#was select to view variants.

heat_region_plot <- function(saving_path, data, 
                              version, start, end, mut,
                              transcript_region=TRUE,
                              canonical_color="orange2",
                              ncanonical_color="lightblue"){

  abraom='Brazilian ABraOM' %in% colnames(data) # we do not need it anymore.
  heat<-biovars_plot(data,start,end,mut)
  data<-data[(data$Location> start & data$Location<end),]
  gene<- unique(data$Gene)
  if (length(gene)==1 && gene != 'None'){
    #legendheat<-get_legend(heat)
    heat <- heat + theme(legend.position="right")
    if(mut==T){ legend_pos="left"}else{legend_pos="top"}
    trasncripts_annotation<- transcript_info(data,version,gene,as.numeric(start),
                                            as.numeric(end),transcript_region,
                                            canonical_color, ncanonical_color)
    trasncripts_annotation<-trasncripts_annotation+guides(fill=guide_legend(title.position = 'top'))
    trasncripts_annotation <- trasncripts_annotation + theme(legend.position="right")
    g<-plot_grid(heat, trasncripts_annotation, nrow = 2, rel_heights = c(1/2.1, 1/2.5))
    ggsave(file=saving_path, g, width = 15, height = 8)

  } else{
    g<-grid.arrange(heat)
    #print('The region contains more than one gene or non gene.')
    # TODO: return above message to be printed as log by biovars package
    ggsave(file="rplot_biovars.pdf",g, width = 10, height = 8)
  }  
}

