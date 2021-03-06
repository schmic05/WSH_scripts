#######################################################################################################
#' read_length_dependence.R
#-----------------------------------------------------------------------------------------------------
#' This scripts produces a plot similar to Figure 1C to visualize the overall dependence of the scores
#' on read length used for sequencing. You should specify the folder, where the results of performing #' the simulation experiment are stored as an argument and the folder where to store the results
#' as another.
#' folder.path: path to the results_pipeline folder for the simulation experiment
#' plot.path: folder to store the results
#' 
#' A single plot is the result.
folder.path <- "path_to_results_pipeline"
plot.path <- getwd()
library(reshape2)
library(ggplot2)
library(RnBeads)
folders <- list.files(folder.path,full.names = T)
data <- data.frame()
for(file in folders){
  read.length <- as.numeric(unlist(strsplit(file,"_"))[length(unlist(strsplit(file,"_")))])
  fdrp <- tryCatch(read.csv(file.path(file,'FDRP','FDRP.csv')),error=function(e){c()})
  fdrp <- mean(as.numeric(unlist(fdrp)),na.rm=TRUE)
  qfdrp <- tryCatch(read.csv(file.path(file,'qFDRP','qFDRP.csv')),error=function(e){c()})
  qfdrp <- mean(as.numeric(unlist(qfdrp)),na.rm=TRUE)
  pdr <- tryCatch(read.csv(file.path(file,'PDR','PDR.csv')),error=function(e){c()})
  pdr <- mean(as.numeric(unlist(pdr)),na.rm=TRUE)
  mhl <- tryCatch(read.table(file.path(file,'mhl.txt'),sep='\t',skip = 1),error=function(e)c())
  mhl <- mean(as.numeric(unlist(mhl[,2])),na.rm=TRUE)
  epipoly <- tryCatch(read.csv(file.path(file,'epipoly.csv')),error=function(e){c()})
  epipoly <- mean(as.numeric(unlist(epipoly$Epipolymorphism)),na.rm=TRUE)
  entropy <- tryCatch(read.csv(file.path(file,'entropy.csv')),error=function(e){c()})
  entropy <- mean(as.numeric(unlist(entropy$Entropy)),na.rm=TRUE)
  data <- rbind(data,c(read.length,fdrp,qfdrp,pdr,mhl,epipoly,entropy))
}
colnames(data) <- c('Read_Length','FDRP','qFDRP','PDR','MHL','Epipolymorphism','Entropy')
data.mean <- aggregate(data,by=list(data$Read_Length),mean,na.rm=T)
data.mean <- data.mean[,-1]
data.sd <- aggregate(data,by=list(data$Read_Length),function(x){sd(x,na.rm=T)/sqrt(length(x))})
data.sd <- data.sd[,-1]
melted <- melt(data.mean,id='Read_Length')
melted <- cbind(melt(data.mean,id='Read_Length'),melt(data.sd,id='Read_Length')$value)
colnames(melted)[2:4] <- c('Measure','Mean','SD')
colors <- rnb.getOption('colors.category')
temp <- colors[2]
colors[2] <- "#76bf23ff"
colors[1] <- "#00806fff"
colors[5] <- temp
plot <- ggplot(melted,aes(x=Read_Length,y=Mean,ymin=Mean-SD,ymax=Mean+SD,color=Measure))+geom_point(size=1)+geom_errorbar(width=0.5)+
  geom_line(size=1.2,aes(linetype=Measure))+theme(panel.background = element_rect(fill='white',color='black'),text=element_text(size=20,face='bold'),
                            panel.grid.major = element_blank(),
                            legend.key = element_rect(fill='white'),legend.position = 'top',legend.text = element_text(size=15))+
  scale_color_manual(values=colors)+xlab('Read Length [bp]')+ylab('Value')
ggsave(paste0(plot.path,"read_length_dependence.pdf"),plot,device="pdf",height=11,width=8.5,units="in")
