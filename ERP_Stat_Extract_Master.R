##Extract adpative mean, mean, peak, and amplitude for an ROI from mutliple text files
##Text Files must have columns as channels and rows as observations
##Well tailored for text files extracted from the ERP PCA Toolkit
##This version is for the 2019 ERP Bootcamp

###################################AD data contain correct and error files
##File names should be structured DATASET_rb_ID#_CONDITION.txt
##For example, ADCombo_rb_101_Correct.txt, ADCombo_rb2118___Error.txt, or CA_Cont_210_cC.txt
##There cannot be "_" (underscore) after the condition.txt
##For example, Error_.txt (NO!) or cC_NR.txt (NO!)
##cCNR.txt (OK!) NegPic.txt (OK!) 
###################################Define dataset variables below

##Where are your text files to be extracted?
save.user.wd <- "~/Desktop/text_files/" 
#####ONLY TXT FILES to be extracted should be in this folder########

##Where would you like the data file saved? 
save.path <- "~/Desktop/Intensity_ERN_values_01012020.csv" 
########### MUST END IN .csv ############

which.chan<- "6,7,106,129"              ##Channels in ROI (NO spaces, SEPARATE by commas)
epoch.begin.seg<- -400     ##Beginning of segment (e.g., -400; should ALWAYS be negative)
epoch.end.seg<- 800           ##End of segment (e.g., 800; should ALWAYS be positive)
startwin.ms<- 0              ##Begining of Adaptive Mean Window in ms
endwin.ms<- 100            ##End of Adaptive Mean Window in ms
start.meanwin.ms<- 0       ##Begining of Mean amplitude window in ms
end.meanwin.ms<- 100         ##End of Mean amplitude windown in ms
size.adp.ms<- 16              ##How many ms before/after to average around peak
samp.rate <- 250              ##Sampling rate in Hz (e.g., 250, 500, or 1000)
which.peak <- "neg"           ##Extract for negative peak (neg) or positive peak (pos)


##################################################################################################################
############################################Don't touch me!######################################################
##################################################################################################################

setwd(save.user.wd)
##Convert variables from milliseconds to samples based on sampling rate ("samp.rate")
ms.per.samp<-1000/samp.rate
pre.stim<-((0-epoch.begin.seg)/ms.per.samp)
epoch.length.samp<- (abs(epoch.begin.seg)+abs(epoch.end.seg))/ms.per.samp
startwin<- (startwin.ms-epoch.begin.seg)/ms.per.samp
endwin<- (endwin.ms-epoch.begin.seg)/ms.per.samp
size.adp<- (size.adp.ms/ms.per.samp)
startwin <- as.integer(startwin)
endwin <- as.integer(endwin)
size.adp <- as.integer(size.adp)
start.meanwin.samp <- (start.meanwin.ms-epoch.begin.seg)/ms.per.samp
end.meanwin.samp<- (end.meanwin.ms-epoch.begin.seg)/ms.per.samp
start.meanwin.samp<- as.integer(start.meanwin.samp)
end.meanwin.samp<- as.integer(end.meanwin.samp)
pre.chans <- unlist(strsplit(which.chan, ","))
ROI.ChanCount <- length(pre.chans)
pre.chans <- as.numeric(pre.chans)
chandum<-1

meanamp.store <- rep(0,length(pre.chans))
adpmean.store <- rep(0,length(pre.chans))
peak.store <- rep(0,length(pre.chans))
latency.store <- rep(0,length(pre.chans))
cent.store <- rep(0,length(pre.chans))


##To Loop columns and add in as many columns as necessary for a variable number of conditions
##Get file names
files <- system("ls", intern=TRUE)

##Put file names in a matrix
files.mat <- as.matrix(files)

##Put file names in a vector
files.vec <- as.vector(files)

##Count number of files in the directory
numfiles <- length(files.mat)

##Define a new function to add columns
add.col <- function(df, new.col, name) { 
  n.row <- dim(df)[1] 
  length(new.col) <- n.row 
  test <- cbind(df, new.col) 
  names(test) <- c(names(df), name) 
  return(test)
}
options(show.error.messages=FALSE) 

##Start counting the number of conditions pulled from file names
condition.count<-0
##Blank and id placeholder to check id against
id.place<-"blllllank"
##Make a blank vector
condition.list<-"bllllank"

temp.1 <- unlist(strsplit(files.vec[1], "_"))
temp1 <- unlist(strsplit(temp.1,"rb"))
id.place<-temp1[3]

##Extract all possible conditions from file extensions
for (i in 1:numfiles) {
  
  ##Get the id value out of the file name
  temp.1 <- unlist(strsplit(files.vec[i], "_"))
  temp1 <- unlist(strsplit(temp.1,"rb"))
  last.temp1 <- length(temp1)
  condition <- unlist(strsplit(temp1[last.temp1],".txt"))
  ##Get id 
  id<-temp1[3]
  
  if (id != id.place) stop ()
  condition.list[i] <- paste(condition)
  id.place<-id
  condition.count<-condition.count+1
  
} 
options(show.error.messages=TRUE)

condition.count <- length(condition.list)
master <- data.frame(participant=-999)
part.temp <- data.frame(participant=-999)
dum.var <- 1

while (dum.var <= (condition.count)) {
  col.mean<-paste(c(condition.list[dum.var],"_Mean"),collapse="")
  master <- add.col (master, -999, col.mean)
  part.temp <- add.col (part.temp, -999, col.mean)
  col.peak<-paste(c(condition.list[dum.var],"_Peak"),collapse="")
  master <- add.col (master, -999, col.peak)
  part.temp <- add.col (part.temp, -999, col.peak)
  col.adpmean<-paste(c(condition.list[dum.var],"_AdpMean"),collapse="")
  master <- add.col (master, -999, col.adpmean)
  part.temp <- add.col (part.temp, -999, col.adpmean)
  col.lat<-paste(c(condition.list[dum.var],"_Lat"),collapse="")
  master <- add.col (master, -999, col.lat)
  part.temp <- add.col (part.temp, -999, col.lat)
  col.cent<-paste(c(condition.list[dum.var],"_Cent"),collapse="")
  master <- add.col (master, -999, col.cent)
  part.temp <- add.col (part.temp, -999, col.cent)
  dum.var <- dum.var+1
}

part.file <- read.table (files.mat[1,1], header = FALSE, sep="", skip=0, fill=TRUE, na.strings = "\xa5")
##Create a list of variable names
chan.names <- c(1:ncol(part.file))
default.part.temp <- part.temp
condition.count.temp <- 1

#####################################################################Start Loop to pull data
for (i in 1:numfiles) {
  ##Read participant file
  part.file <- read.table (files.mat[i,1], header = FALSE, sep="", skip=0, col.names=chan.names, fill=TRUE, na.strings = "\xa5")
  
  for (chandum in 1:ROI.ChanCount) {
    
    ##Read in data from channel and average
    dummy <-as.matrix(part.file[pre.chans[chandum]])
    startwin.foradp<-startwin-size.adp ##make shorter by length of one side of adp mean
    endwin.foradp<-endwin+size.adp     ##make longer by length of one side of adp mean
    ROI.ForMeanAmp<-dummy[row=start.meanwin.samp:end.meanwin.samp]
    ROI.ForMean<-dummy[row=startwin:endwin]
    ROI.1<-dummy[row=startwin.foradp:endwin.foradp]
    
    if (which.peak == "neg") {
      ##Find minimum for adaptive mean
      centeradp<-(which.min(ROI.ForMean)+size.adp)
      ##Find mean amplitude
      meanamp<-mean(ROI.ForMeanAmp)
      ##Find minimum peak
      peak<-min(ROI.ForMean)
      ##Find latency of minimum
      latency<-which.min(ROI.ForMean)+startwin-(pre.stim+1) ##to take out time before 0ms 
      ##Find centroid latency
      ROI.Cent <- data.frame(ROI.ForMean)
      ROI.Cent <- cbind(ROI.Cent, 1:nrow(ROI.Cent))
      colnames(ROI.Cent) <- c("Volt", "time")
      cent<- (mean((ROI.Cent$time)*(ROI.Cent$Volt-min(ROI.Cent$Volt))/mean(ROI.Cent$Volt-min(ROI.Cent$Volt))))+startwin-(pre.stim+1) ##to take out time before 0ms
    }  
    
    if (which.peak == "pos") {
      ##Find minimum for adaptive mean
      centeradp<-(which.max(ROI.ForMean)+size.adp)
      ##Find mean amplitude
      meanamp<-mean(ROI.ForMeanAmp)
      ##Find minimum peak
      peak<-max(ROI.ForMean)
      ##Find latency of minimum
      latency<-which.max(ROI.ForMean)+startwin-(pre.stim+1) ##to take out time before 0ms 
      ##Find centroid latency
      ROI.Cent <- data.frame(ROI.ForMean)
      ROI.Cent <- cbind(ROI.Cent, 1:nrow(ROI.Cent))
      colnames(ROI.Cent) <- c("Volt", "time")
      cent<- (mean((ROI.Cent$time)*(ROI.Cent$Volt-max(ROI.Cent$Volt))/mean(ROI.Cent$Volt-max(ROI.Cent$Volt))))+startwin-(pre.stim+1) ##to take out time before 0ms
    }
    
    ##Define adaptive mean window
    startadp <- centeradp - size.adp
    endadp <- centeradp + size.adp
    
    ##Pull window for adaptive mean
    ROI.2<-ROI.1[row=startadp:endadp]
    
    ##Take adaptive mean of data points
    adpmean<-mean(ROI.2)
    
    meanamp.store[chandum]<- meanamp
    adpmean.store[chandum]<- adpmean
    peak.store[chandum]<- peak
    latency.store[chandum]<- latency
    cent.store[chandum]<- cent
  }
  
  meanamp<-mean(meanamp.store)
  adpmean<-mean(adpmean.store)
  peak<-mean(peak.store)
  latency<-mean(latency.store)
  cent<-mean(cent.store)
  
  ##Get the id value out of the file name
  temp1 <- unlist(strsplit(files.vec[i], "_"))
  temp.1 <- unlist(strsplit(files.vec[i], "_"))
  temp1 <- unlist(strsplit(temp.1,"rb"))
  ##Get id 
  id<-temp1[3]
  ##Get Condition out of the file name
  condition <- unlist(strsplit(temp1[last.temp1],".txt"))
  
  
  ##Store data in respective columns
  
  if (condition==condition.list[1]) {
    part.temp$participant <-id
    condition.count.temp<-1
  }
  
  col.mean<-paste(c(condition,"_Mean"),collapse="")
  col.peak<-paste(c(condition,"_Peak"),collapse="")
  col.adpmean<-paste(c(condition,"_AdpMean"),collapse="")
  col.lat<-paste(c(condition,"_Lat"),collapse="")
  col.cent<-paste(c(condition,"_Cent"),collapse="")
  
  part.temp[col.adpmean] <- adpmean
  part.temp[col.mean] <- meanamp
  part.temp[col.peak] <- peak
  part.temp[col.lat] <- latency*ms.per.samp ##convert to ms
  part.temp[col.cent] <- cent*ms.per.samp ##convert to ms
  
  if (condition.count.temp==condition.count) {
    ##add participant info stored in "part.temp" to master data.frame "master"
    master <- rbind(master,part.temp)
    ##rest part.temp to dummy values
    part.temp <- default.part.temp
    condition.count.temp <- 1
  }
  condition.count.temp <- condition.count.temp + 1
}

##Delete first dummy row of master
master <- master[2:nrow(master),]


##Put extraction information in a header
cat(paste(temp1[1]),file=save.path,sep="\n")
cat("Data extracted from the following folder ",file= save.path,append=TRUE)
cat(paste(save.user.wd),file= save.path,sep="\n",append=TRUE)
cat(c("Data Segment:",paste(epoch.begin.seg),"ms to",paste(epoch.end.seg),"ms"),append=TRUE,file= save.path,"\n")
cat(c("Sampling Rate:",paste(samp.rate),"Hz"),append=TRUE,file= save.path,"\n")
cat(c("Extraction Window for Adaptive Mean and Peak Amplitude:",paste(startwin.ms),"ms to",paste(endwin.ms),"ms"),append=TRUE,file= save.path,"\n")
cat(c("Extraction Window for Mean Amplitude:",paste(start.meanwin.ms),"ms to",paste(end.meanwin.ms),"ms"),append=TRUE,file= save.path,"\n")
cat(c("Adaptive Mean from",paste(size.adp.ms),"ms before the peak to",paste(size.adp.ms),"ms after the peak"),append=TRUE,file= save.path,"\n")
cat(c("Electrodes:",paste(pre.chans)),append=TRUE,file= save.path,"\n")
if (which.peak == "neg") cat(c("Negative Peak Measurement"),append=TRUE,file=save.path,"\n") else cat(c("Positive Peak Measurement"),append=TRUE,file= save.path,"\n")
cat(append=TRUE,file= save.path,"\n")

suppressWarnings(write.table(master, file = save.path, append=TRUE, row.names=FALSE, sep=",", quote = FALSE))

##Display sample
head(master)

##Print where the output is saved
paste(c("File Location:",paste(save.path)),collapse="")