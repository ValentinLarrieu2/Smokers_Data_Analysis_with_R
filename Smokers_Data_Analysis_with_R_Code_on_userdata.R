library(xlsx)
library('ggplot2')
library(data.table) ## v 1.9.6+ 
library(epitools)
library(rgl)
install.packages("plot3D")
library(plot3D)
install.packages("lubridate")
library(lubridate)
library(shiny)
library(DT)

#######################################################################################FUNCTIONS
fctOnDataframe<-function(dfref,fct){
  return (which(dfref == fct(dfref, na.rm = TRUE), arr.ind = TRUE))
}

resetMatrix <- function(vect){
  for (i in 1:length(vect)){
    for (j in 1:length(vect[[1]])){
      vect[[i]][[j]]=0
    }
  }
  return (vect)
}
resetVector <- function(vect){
  for (i in 1:length(vect)){
    vect[i]=0
  }
  return (vect)
}
resetBoolVector <- function(vect){
  for (i in 1:length(vect)){
    vect[i]=FALSE
  }
  return (vect)
}
UserStat <- function(dataset){ 
  #initialisation
  previousUser=dataset$User[1]
  currentUser=0
  previousWeek=0
  currentWeek=0
  newWeek=FALSE
  ##########Total Cigarette
  listCigaretteTotal <- list()
  listUser <- list()
  counterTotalCig=0
  ##########Total by mode
  smokeByModeUser <- list()
  smokeByModeList <- list()
  ObsWC=CheatC=friendC=onTC=skpC=snooC=autoSkpC=0
  #########Total by week
  weeklist=sort(unlist(unique(dataset$Week)))
  couterWeekList=unique(dataset$Week)
  couterWeekList=resetVector(couterWeekList)
  totalByWeekList <- list()
  
  ##########Total by day of week
  
  daylist=sort(unlist(unique(dataset$DayOfWeek)))
  couterDayList=unique(dataset$DayOfWeek)
  couterDayList=resetVector(couterDayList)
  numberOFThatDay=unique(dataset$DayOfWeek)
  numberOFThatDay=resetVector(numberOFThatDay)
  totalDayList <- list()
  totalNumberOfDayList <- list()
  weekDayBool<-list(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)
  
  ##########Total by time interval
  intervallist=sort(unlist(unique(dataset$TimeInterval)))
  couterIntervalList=sort(unlist(unique(dataset$TimeInterval)))
  couterIntervalList=resetVector(couterIntervalList)
  totalByIntervalList <- list()
  
  ##########Last seven day
  lastSevenDayList <- list()
  
  ##########Smoking patern
  sevenList=list(0,0,0,0,0,0,0)
  intervalDayList=list(sevenList,sevenList,sevenList,sevenList)
  totalIntervalDayList= list()
  
  for ( u in 1:length(dataset$User)){
    currentUser=dataset$User[u]
    currentWeek=dataset$Week[u]
    if (currentWeek==previousWeek){
      newWeek=FALSE
    }
    else{
      newWeek=TRUE
    }
    if (currentUser==previousUser){#it is the same user
      #counterTotalCig=counterTotalCig+1 #total Cigarette Smoked increased by 1
      #########CountByType
      if (dataset$Type[u]=="Observation week"){
        ObsWC=ObsWC+1
      }
      if (dataset$Type[u]=="Cheated"){
        CheatC=CheatC+1
      }
      if (dataset$Type[u]=="Friend"){
        friendC=friendC+1
      }
      if (dataset$Type[u]=="On time"){
        onTC=onTC+1
      }
      if (dataset$Type[u]=="Skipped"){
        skpC=skpC+1
      }
      if (dataset$Type[u]=="Snoozed"){
        snooC=snooC+1
      }
      if (dataset$Type[u]=="Auto skipped"){
        autoSkpC=autoSkpC+1
      }
      #list of day
      if(((dataset$Type[u]!="Snoozed")&&(dataset$Type[u]!="Friend")&&(dataset$Type[u]!="Skipped")&&(dataset$Type[u]!="Auto skipped"))){
        counterTotalCig=counterTotalCig+1 #total Cigarette Smoked increased by 1
        for (i in 1:length(daylist)){
          if (daylist[i]==dataset$DayOfWeek[u]){
            couterDayList[i]=couterDayList[i]+1
            if (newWeek==FALSE){
              weekDayBool[i]=TRUE
            }
            else{
              for (k in 1:length(weekDayBool)){
                if(weekDayBool[k]==TRUE){
                  numberOFThatDay[k]=numberOFThatDay[k]+1
                }
              }
              weekDayBool<-resetBoolVector(weekDayBool)
            }
          }
        }
        #list of interval
        for (i in 1:length(intervallist)){
          if (intervallist[i]==dataset$TimeInterval[u]){
            couterIntervalList[i]=couterIntervalList[i]+1
          }
        }
        #list of week
        for (i in 1:length(weeklist)){
          if (weeklist[i]==dataset$Week[u]){
            couterWeekList[i]=couterWeekList[i]+1
          }
        }
        #smoking patern
        intervalDayList[[dataset$TimeInterval[u]]][[dataset$DayOfWeek[u]]]<- intervalDayList[[dataset$TimeInterval[u]]][[dataset$DayOfWeek[u]]] +1
      }
      
    }
    else{#it is another user
      ######Total cigarette handling
      listCigaretteTotal<-c(listCigaretteTotal,counterTotalCig) #we construct the total cigarette list
      listUser<-c(listUser,currentUser) #we add the user to the corresponding list
      counterTotalCig=1 #we increment the total counter
      
      ######Total by mode
      smokeByModeUser=list(ObsWC,CheatC,friendC,onTC,skpC,snooC,autoSkpC)
      smokeByModeList<-append(smokeByModeList, list(smokeByModeUser))
      ObsWC=CheatC=friendC=onTC=skpC=snooC=autoSkpC=0
      if (dataset$Type[u]=="Observation week"){
        ObsWC=ObsWC+1
      }
      if (dataset$Type[u]=="Cheated"){
        CheatC=CheatC+1
      }
      if (dataset$Type[u]=="Friend"){
        friendC=friendC+1
      }
      if (dataset$Type[u]=="On time"){
        onTC=onTC+1
      }
      if (dataset$Type[u]=="Skipped"){
        skpC=skpC+1
      }
      if (dataset$Type[u]=="Snoozed"){
        snooC=snooC+1
      }
      if (dataset$Type[u]=="Auto skipped"){
        autoSkpC=autoSkpC+1
      }
      
      ######Total by weekDay
      #if(((dataset$Type[u]!="Snoozed")&&(dataset$Type[u]!="Friend")&&(dataset$Type[u]!="Skipped")&&(dataset$Type[u]!="Auto skipped"))){
      
      totalDayList <- append(totalDayList, list(couterDayList))
      totalNumberOfDayList <- append(totalNumberOfDayList,list(numberOFThatDay))
      couterDayList=resetVector(couterDayList)
      numberOFThatDay=resetVector(numberOFThatDay)
      for (i in 1:length(daylist)){
        if (daylist[i]==dataset$DayOfWeek[u]){
          couterDayList[i]=couterDayList[i]+1
          for (k in 1:length(weekDayBool)){
            numberOFThatDay[k]=numberOFThatDay[k]+1
          }
          weekDayBool<-resetBoolVector(weekDayBool)
          weekDayBool[i]=TRUE
          currentWeek=0
        }
      }
      
      ######total by interval
      totalByIntervalList<- append(totalByIntervalList, list(couterIntervalList))
      couterIntervalList<-resetVector(couterIntervalList)
      for (i in 1:length(intervallist)){
        if (intervallist[i]==dataset$TimeInterval[u]){
          couterIntervalList[i]=couterIntervalList[i]+1
        }
      }
      
      ######total by week
      totalByWeekList<- append(totalByWeekList, list(couterWeekList))
      couterWeekList<-resetVector(couterWeekList)
      for (i in 1:length(weeklist)){
        if (weeklist[i]==dataset$Week[u]){
          couterWeekList[i]=couterWeekList[i]+1
        }
      }
      
      ######last 7 day
      lastDate=dataset$Time[u-1]
      countDay=1
      previousDay=dataset$DayNumber[u-1]
      currentDay=0
      countLastSeven=0
      for (i in (u-1):1) {
        if (countDay>7){
          break
        }
        currentDay=dataset$DayNumber[i]
        if (currentDay==previousDay){
          countLastSeven=countLastSeven+1
        }
        else{
          countDay=countDay+1
        }
        previousDay=currentDay
      }
      lastSevenDayList<- append(lastSevenDayList, list(countLastSeven))
      
      #smoking patern
      totalIntervalDayList<- append(totalIntervalDayList, list(intervalDayList))
      intervalDayList<-resetMatrix(intervalDayList)
      intervalDayList[[dataset$TimeInterval[u]]][[dataset$DayOfWeek[u]]]<- intervalDayList[[dataset$TimeInterval[u]]][[dataset$DayOfWeek[u]]] +1
      #}
    }
    previousUser=currentUser
    previousWeek=currentWeek
  }
  #We add the last elements
  #####Total Cigarette
  listCigaretteTotal<-c(listCigaretteTotal,counterTotalCig)
  listUser<-c(listUser,currentUser)
  
  #####Total by mode
  smokeByModeUser=list(ObsWC,CheatC,friendC,onTC,skpC,snooC,autoSkpC)
  #smokeByModeList<-c(smokeByModeList,smokeByModeUser)
  smokeByModeList<-append(smokeByModeList, list(smokeByModeUser))
  
  #########totalByDay
  totalDayList <- append(totalDayList, list(couterDayList))
  totalNumberOfDayList <- append(totalNumberOfDayList, list(numberOFThatDay))
  
  ########total by interval
  totalByIntervalList<- append(totalByIntervalList, list(couterIntervalList))
  
  ########total by week
  totalByWeekList<- append(totalByWeekList, list(couterWeekList))
  
  ########last seven days
  lastDate=dataset$Time[u-1]
  countDay=1
  previousDay=dataset$DayNumber[u-1]
  currentDay=0
  countLastSeven=0
  for (i in ((u-1):1)) {
    if (countDay>7){
      break
    }
    currentDay=dataset$DayNumber[i]
    if (currentDay==previousDay){
      countLastSeven=countLastSeven+1
    }
    else{
      countDay=countDay+1
    }
    previousDay=currentDay
  }
  lastSevenDayList<- append(lastSevenDayList, list(countLastSeven))
  
  #smoking patern
  totalIntervalDayList<- append(totalIntervalDayList, list(intervalDayList))
  
  return (list(listUser,listCigaretteTotal,smokeByModeList,list(daylist,totalNumberOfDayList,totalDayList),list(intervallist,totalByIntervalList),list(weeklist,totalByWeekList),lastSevenDayList,totalIntervalDayList))
}
#Smoking patern
getDataFrame<-function(dataf,dim1,dim2,dim3){
  test <- matrix(unlist(dataf[[dim1]][[dim2]]), ncol = dim3, byrow = TRUE)
  dftest=data.frame(test)
  return (dftest)
}
dailyMeanMyDataframe<-function(dataf,ref,uid){
  dataf$X1<- dataf$X1 /  ref[[4]][[2]][[uid]][[1]]
  dataf$X2<- dataf$X2 /  ref[[4]][[2]][[uid]][[2]]
  dataf$X3<- dataf$X3 /  ref[[4]][[2]][[uid]][[3]]
  dataf$X4<- dataf$X4 /  ref[[4]][[2]][[uid]][[4]]
  dataf$X5<- dataf$X5 /  ref[[4]][[2]][[uid]][[5]]
  dataf$X6<- dataf$X6 /  ref[[4]][[2]][[uid]][[6]]
  dataf$X7<- dataf$X7 /  ref[[4]][[2]][[uid]][[7]]
  return (dataf)
}  

labelDayMyDataframe<-function(dataf,ref){
  names(dataf)[names(dataf) == "X1"] <- ref[[4]][[1]][[1]]
  names(dataf)[names(dataf) == "X2"] <- ref[[4]][[1]][[2]]
  names(dataf)[names(dataf) == "X3"] <- ref[[4]][[1]][[3]]
  names(dataf)[names(dataf) == "X4"] <- ref[[4]][[1]][[4]]
  names(dataf)[names(dataf) == "X5"] <- ref[[4]][[1]][[5]]
  names(dataf)[names(dataf) == "X6"] <- ref[[4]][[1]][[6]]
  names(dataf)[names(dataf) == "X7"] <- ref[[4]][[1]][[7]]
  return (dataf)
}  
giveMeFullMeanLabelledIntervalDayDF<- function(ref,returnedListNb,uid,culumn,dataframe){
  dfres=getDataFrame(ref,returnedListNb,uid,culumn)
  dfres=dailyMeanMyDataframe(dfres,ref,uid)
  dfres=labelDayMyDataframe(dfres,ref)
  return (dfres)
}
###############################################################################

getwd()
setwd( "C:/Users/Valentin/Documents/Informatique/RStudio/")

#df4 <- read.csv("userdata.csv",sep=";",na.strings=c("","NA"))#Fill blank element with NA

preprocessData<-function(dataframe){
  df4=dataframe
  #We split the date into 2 columns
  setDT(df4)[, paste0("Date", 1:2) := tstrsplit(Time, " ")]
  
  #we specify the format of the column
  df4$Time <- as.Date(df4$Time, format = "%d/%m/%Y %H:%M")
  #df4$Date1 <- as.Date(df4$Date1, format = "%d/%m/%Y")
  df4$Date1<- NULL #that column has no use here so e suprress it
  
  #We create a column giving us the dayOfWeek, with 1 being Sunday 
  df4$DayOfWeek<-wday(df4$Time) 
  #We create the column containing the number of the week
  df4$Week<-week(df4$Time) 
  #We create the column containing the number of the day
  df4$DayNumber<-yday(df4$Time) 
  
  #We create a temporary column to store the hour and min
  df4$TimeHourMin<-hm(df4$Date2) 
  #We split the group of ours in 4 groups
  df4$TimeInterval[hour(df4$TimeHourMin)<6]<- 4 
  df4$TimeInterval[(hour(df4$TimeHourMin)>=18)]<- 3 
  df4$TimeInterval[(hour(df4$TimeHourMin)>=12) & (hour(df4$TimeHourMin)<18)]<- 2 
  df4$TimeInterval[(hour(df4$TimeHourMin)>=6) & (hour(df4$TimeHourMin)<12)]<- 1 
  return (df4)
}
generatePerModeDataframe<-function(dataframe){
  userStatList<-dataframe
  #Total of cigarettes per mode
  print("Cigarette smoked by day")
  tempo <- matrix(unlist(userStatList[[3]]), ncol = 7, byrow = TRUE)
  dfTotalPerMode=data.frame(tempo)
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X1"] <- "Observation week"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X2"] <- "Cheated"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X3"] <- "Friend"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X4"] <- "Ontime"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X5"] <- "Skipped"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X6"] <- "Snoozed"
  names(dfTotalPerMode)[names(dfTotalPerMode) == "X7"] <- "Auto skipped"
  #print(dfTotalPerMode)
  return(dfTotalPerMode)
}

generateMeanSmokeDataframe<-function(dataframe){
  #Mean of cigarette smoked per day
  userStatList<-dataset
  daySmoked <- matrix(unlist(userStatList[[4]][[2]]), ncol = 7, byrow = TRUE)
  numberSmoked <- matrix(unlist(userStatList[[4]][[3]]), ncol = 7, byrow = TRUE)
  mean=numberSmoked/daySmoked
  dfmeanDay=data.frame(mean)
  names(dfmeanDay)[names(dfmeanDay) == "X1"] <- userStatList[[4]][[1]][[1]]
  names(dfmeanDay)[names(dfmeanDay) == "X2"] <- userStatList[[4]][[1]][[2]]
  names(dfmeanDay)[names(dfmeanDay) == "X3"] <- userStatList[[4]][[1]][[3]]
  names(dfmeanDay)[names(dfmeanDay) == "X4"] <- userStatList[[4]][[1]][[4]]
  names(dfmeanDay)[names(dfmeanDay) == "X5"] <- userStatList[[4]][[1]][[5]]
  names(dfmeanDay)[names(dfmeanDay) == "X6"] <- userStatList[[4]][[1]][[6]]
  names(dfmeanDay)[names(dfmeanDay) == "X7"] <- userStatList[[4]][[1]][[7]]
  return(dfmeanDay)
}

computeEverything<-function(dataframe){
  df4=dataframe
  #We split the date into 2 columns
  df4<-preprocessData(df4)
  
  
  userStatList=UserStat(df4)
  
  dfTotalPerMode<-generatePerModeDataframe(userStatList)
  
  #########PLOT of results
  #Total Cigarette smoked by User
  message("TOTAL of cigarette smoked by user :")
  for (i in 1:length(userStatList[[2]])){
    message("USER ",i," TOTAL= ", userStatList[[2]][[i]])
  }
  #plot(userStatList[[1]],userStatList[[2]],main="Total cigarette smoked by user", xlab="User Id", ylab="Number of cigarette", pch=18, col="blue")
  
  
  #plot(dfTotalPerMode)
  
  #Mean of cigarette smoked per day
  dfmeanDay<-generateMeanSmokeDataframe(userStatList)
  
  #stardard deviation per day
  print("Standard deviation")
  
  std=list()
  for (i in 1:7){
    std<- append(std, sd(numberSmoked[,i]))
  }
  print(std)
  #plot(list(1,2,3,4,5,6,7),std,main="Standard deviation per day", xlab="Day number", ylab="STD", pch=18, col="blue")
  
  #Numer of consumed cigarette for the last seven day
  print("Last seven days")
  #plot(userStatList[[1]],userStatList[[7]],main="Number of cigarette consumed for the last 7 days", xlab="User Id", ylab="Number of cigarette", pch=18, col="blue")
  for (i in 1:length(userStatList[[2]])){
    message("USER ",i," Cigarette last 7 days = ", userStatList[[7]][[i]])
  }
  
  #Statistics on mode
  listModePercent=userStatList[[3]]
  for (i in 1:length(userStatList[[1]])){
    for (j in 1:7){
      listModePercent[[i]][[j]]=(listModePercent[[i]][[j]]/userStatList[[2]][[i]])*100
    }
  }
  tempo <- matrix(unlist(listModePercent), ncol = 7, byrow = TRUE)
  dfTotalPerModePercentage=data.frame(tempo)
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X1"] <- "Observation week"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X2"] <- "Cheated"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X3"] <- "Friend"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X4"] <- "Ontime"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X5"] <- "Skipped"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X6"] <- "Snoozed"
  names(dfTotalPerModePercentage)[names(dfTotalPerModePercentage) == "X7"] <- "Auto skipped"
  #plot(dfTotalPerModePercentage)
  
  #Percentage of improvement
  
  #listImprovementPercentFirstWeek=userStatList[[1]]
  listImprovementPercentFirstWeek=list(userStatList[[1]],userStatList[[1]],userStatList[[1]])
  for (i in 1:length(userStatList[[1]])){
    twoValues=0
    valueOne=0
    valueTwo=0
    valueThree=0
    for (j in 1:length(userStatList[[6]][[1]])){
      if (twoValues==3){
        #print("BREAK")
        break}
      else{
        #print(userStatList[[6]][[2]][[i]][[j]])
        if (userStatList[[6]][[2]][[i]][[j]]!=0){
          twoValues=twoValues+1
        }
        if (twoValues==1){
          valueOne=userStatList[[6]][[2]][[i]][[j]]
        }
        if (twoValues==2){
          valueTwo=userStatList[[6]][[2]][[i]][[j]]
        }
        if (twoValues==3){
          valueThree=userStatList[[6]][[2]][[i]][[j]]
        }
      }
    }
    listImprovementPercentFirstWeek[[1]][[i]]=(valueOne-valueTwo)/valueOne
    listImprovementPercentFirstWeek[[2]][[i]]=(valueOne-valueThree)/valueOne
    listImprovementPercentFirstWeek[[3]][[i]]=(valueTwo-valueThree)/valueTwo
  }
  for (i in 1:length(userStatList[[2]])){
    message("USER ",i," Improvement between observation weeks and week 1 = ", listImprovementPercentFirstWeek[[1]][[i]])
    message("USER ",i," Improvement between observation weeks and week 2 = ", listImprovementPercentFirstWeek[[2]][[i]])
    message("USER ",i," Improvement between weeks 1 and week 2 = ", listImprovementPercentFirstWeek[[3]][[i]])
  }
  
  #Mode study
  mode <- matrix(unlist(userStatList[[3]]), ncol = 7, byrow = TRUE)
  dfMode=data.frame(mode)
  transposedModeDf<- t(dfMode)
  transposedModeDf <- as.data.frame(transposedModeDf)
  transposedModeDf<-transform(transposedModeDf, sum=rowSums(transposedModeDf))
  
  plotme<-transposedModeDf
  plotme$sum<- NULL
  #persp3D(z = data.matrix(plotme), theta = 120)
  
  #Smoking patern
  dfIntervalDay1=giveMeFullMeanLabelledIntervalDayDF(userStatList,8,1,7)
  #plot(dfIntervalDay1)
  #persp3D(z = data.matrix(dfIntervalDay1), theta = 120)
  
  #Max and Min period of week
  print("MIN and MAX of the week")
  fctOnDataframe<-function(dfref,fct){
    return (which(dfref == fct(dfref, na.rm = TRUE), arr.ind = TRUE))
  }
  minIndex=fctOnDataframe(dfIntervalDay1,min)
  maxIndex=fctOnDataframe(dfIntervalDay1,max)
  print("Min")
  print(minIndex)
  print("Max")
  print(maxIndex)
  
  #User2
  dfIntervalDay2=giveMeFullMeanLabelledIntervalDayDF(userStatList,8,2,7)
  #plot(dfIntervalDay2)
  #persp3D(z = data.matrix(dfIntervalDay2), theta = 120)
  
  #Max and Min period of week
  minIndex=fctOnDataframe(dfIntervalDay2,min)
  maxIndex=fctOnDataframe(dfIntervalDay2,max)
  print("Min")
  print(minIndex)
  print("Max")
  print(maxIndex)
  
  ###All user stats
  m <- matrix(0, ncol = 8, nrow = 4)
  dfsum=data.frame(m)
  dfsum<-labelDayMyDataframe(dfsum,userStatList)
  names(dfsum)[names(dfsum) == "X8"] <- "Sum"
  for (i in 1:length(userStatList[[1]])){
    dfa<-giveMeFullMeanLabelledIntervalDayDF(userStatList,8,i,7)
    dfa<-transform(dfa, sum=rowSums(dfa))
    dfsum=dfsum+dfa
  }
  
  dftoplot=dfsum ##This dataframe contains the sum as a eight column
  dftoplot
  dftoplot$Sum<- NULL
  
  minIndex=fctOnDataframe(dftoplot,min)
  maxIndex=fctOnDataframe(dftoplot,max)
  print("Min")
  print(minIndex)
  print("Max")
  print(maxIndex)
  plot(dftoplot)
  #persp3D(z = data.matrix(dftoplot), theta = 120)
  
  transposedPlotDf<- t(dftoplot)
  transposedPlotDf <- as.data.frame(transposedPlotDf)
  transposedPlotDf<-transform(transposedPlotDf, sum=rowSums(transposedPlotDf))
  
  print("End of computation")
}
generateSumSmokePaternDataframe<-function(dataframe) {
  userStatList<-dataframe
  ###All user stats
  m <- matrix(0, ncol = 8, nrow = 4)
  dfsum=data.frame(m)
  dfsum<-labelDayMyDataframe(dfsum,userStatList)
  names(dfsum)[names(dfsum) == "X8"] <- "Sum"
  for (i in 1:length(userStatList[[1]])){
    dfa<-giveMeFullMeanLabelledIntervalDayDF(userStatList,8,i,7)
    dfa<-transform(dfa, sum=rowSums(dfa))
    dfsum=dfsum+dfa
  }
  
  dftoplot=dfsum ##This dataframe contains the sum as a eight column
  dftoplot
  dftoplot$Sum<- NULL
  names(dftoplot)[names(dftoplot) == "1"] <- "Sunday"
  names(dftoplot)[names(dftoplot) == "2"] <- "Monday"
  names(dftoplot)[names(dftoplot) == "3"] <- "Tuesday"
  names(dftoplot)[names(dftoplot) == "4"] <- "wednesday"
  names(dftoplot)[names(dftoplot) == "5"] <- "thirstday"
  names(dftoplot)[names(dftoplot) == "6"] <- "Friday"
  names(dftoplot)[names(dftoplot) == "7"] <- "Saturday"
  
  
  return(dftoplot)
  #persp3D(z = data.matrix(dftoplot), theta = 120)
}
generateSumModeDataframe<-function(dataframe) {
  userStatList<-dataframe
  #Mode study
  mode <- matrix(unlist(userStatList[[3]]), ncol = 7, byrow = TRUE)
  dfMode=data.frame(mode)
  names(dfMode)[names(dfMode) == "X1"] <- "Observation week"
  names(dfMode)[names(dfMode) == "X2"] <- "Cheated"
  names(dfMode)[names(dfMode) == "X3"] <- "Friend"
  names(dfMode)[names(dfMode) == "X4"] <- "Ontime"
  names(dfMode)[names(dfMode) == "X5"] <- "Skipped"
  names(dfMode)[names(dfMode) == "X6"] <- "Snoozed"
  names(dfMode)[names(dfMode) == "X7"] <- "Auto skipped"
  
  #persp3D(z = data.matrix(plotme), theta = 120)
  return(dfMode)
}
giveMeDayNumber<-function(text) {
  if (text=="Sunday"){
    return(1)
  }
  if (text=="Monday"){
    return(2)
  }
  if (text=="Tuesday"){
    return(3)
  }
  if (text=="wednesday"){
    return(4)
  }
  if (text=="Thirsday"){
    return(5)
  }
  if (text=="Friday"){
    return(6)
  }
  if (text=="Saturday"){
    return(7)
  }
  return (0)
}
giveMeModeNumber<-function(text) {
  if (text=="Observation week"){
    return(1)
  }
  if (text=="Cheated"){
    return(2)
  }
  if (text=="Friend"){
    return(3)
  }
  if (text=="Ontime"){
    return(4)
  }
  if (text=="Skipped"){
    return(5)
  }
  if (text=="Snoozed"){
    return(6)
  }
  if (text=="Auto skipped"){
    return(7)
  }
  return (0)
}
giveMeIntervalNumber<-function(text) {
  if (text=="06-12h"){
    return(1)
  }
  if (text=="12-18h"){
    return(2)
  }
  if (text=="18-00h"){
    return(3)
  }
  if (text=="00-06h"){
    return(4)
  }
  return (0)
}
generatelastSevenDayList<-function(dataframe) {
  userStatList<-dataframe
  result=list(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
  for (i in 1:length(userStatList[[1]])){
    result[[i]]<-userStatList[[7]][[i]]
  }
  return(result)
}
#####################################################################################################################UI
ui <- navbarPage(title = "Smoker Statistics",
                 tabPanel(title = "Import file",
                          # Sidebar panel for inputs ----
                          sidebarPanel(
                            
                            # Input: Select a file ----
                            fileInput("file1", "Choose CSV File",
                                      multiple = TRUE,
                                      accept = c("text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")),
                            
                            # Horizontal line ----
                            tags$hr(),
                            
                            # Input: Checkbox if file has header ----
                            checkboxInput("header", "Header", TRUE),
                            
                            # Input: Select separator ----
                            radioButtons("sep", "Separator",
                                         choices = c(Semicolon = ";"),
                                         selected = ";"),
                            
                            
                            # Horizontal line ----
                            tags$hr(),
                            
                            # Input: Select number of rows to display ----
                            radioButtons("disp", "Display",
                                         choices = c(Head = "head"),
                                         selected = "head")
                            
                          ),
                          verbatimTextOutput("text"),
                          # Main panel for displaying outputs ----
                          mainPanel(
                            
                            # Output: Data file ----
                            tableOutput("contents")
                            
                          )         
                          
                 ),
                 #h2("Data 1- X= , Y="),
                 
                 tabPanel(title = "All user",
                          h2("Cigarette smoked by the set"),
                          plotOutput("allUser1"),
                          tags$hr(),
                          h2("Last 7 days consumption"),
                          plotOutput("allUser4"),
                          tags$hr(),
                          h2("Smoking repartition: X=Day period (from 6h and every 6 hours)"),
                          DT::dataTableOutput("allUserDf2"),
                          plotOutput("allUser2"),
                          tags$hr(),
                          h2("Lighter Mode usage"),
                          DT::dataTableOutput("allUserDf3"),
                          plotOutput("allUser3")
                 ),
                 navbarMenu(title = "Individual User",
                            tabPanel(title = "General Stat",
                                     sidebarPanel(
                                       sliderInput(inputId = "UIDGen", 
                                                   label = "User ID", 
                                                   value = 1, min = 1, max = 32)
                                     ),
                                     mainPanel(
                                       
                                       # Output: Tabset w/ plot, summary, and table ----
                                       tabsetPanel(type = "tabs",
                                                   tabPanel("Per Mode", plotOutput("perMode")),
                                                   tabPanel("Per Day", plotOutput("perDay")),
                                                   tabPanel("Per Interval", plotOutput("perInterval"))
                                       )
                                       
                                     )
                            ),
                            tabPanel(title = "Precise Stat",
                                     sidebarPanel(
                                       sliderInput(inputId = "UIDInd", 
                                                   label = "User ID", 
                                                   value = 1, min = 1, max = 32),
                                       selectInput("weekDay", "Week Day:",
                                                   c("Sunday" = "Sunday",
                                                     "Monday" = "Monday",
                                                     "Tuesday" = "Tuesday",
                                                     "wednesday" = "wednesday",
                                                     "Thirsday" = "Thirsday",
                                                     "Friday" = "Friday",
                                                     "Saturday" = "Saturday")),
                                       selectInput("mode", "Mode:",
                                                   c("Observation week" = "Observation week",
                                                     "Cheated" = "Cheated",
                                                     "Friend" = "Friend",
                                                     "Ontime" = "Ontime",
                                                     "Skipped" = "Skipped",
                                                     "Snoozed" = "Snoozed",
                                                     "Auto skipped" = "Auto skipped")),
                                       selectInput("interval", "Interval:",
                                                   c("06-12h" = "06-12h",
                                                     "12-18h" = "12-18h",
                                                     "18-00h" = "18-00h",
                                                     "00-06h" = "00-06h"))
                                     ),
                                     h4("Total Cigarette smoked"),
                                     textOutput("userTotalNumber",inline=FALSE),
                                     h4("Smoked on that mode"),
                                     textOutput("userModeNumber",inline=FALSE),
                                     h4("Smoked on that day"),
                                     textOutput("userDayNumber",inline=FALSE),
                                     h4("Smoked on that interval"),
                                     textOutput("userIntervalNumber",inline=FALSE),
                                     h4("Last 7 day consumption"),
                                     textOutput("userSevenDay",inline=FALSE)
                            )
                 )
)


server <- function(input, output,session) {
  displayChange <- function() {
    if (length(userStatList)!=0){
      output$allUserDf2 <- DT::renderDataTable({
        smokePatern
      })
      output$allUserDf3 <- DT::renderDataTable({
        sumMode
      })
      
      output$allUser1 <- renderPlot({
        plot(userStatList[[1]],userStatList[[2]],main="Total cigarette smoked by users", xlab="User Id", ylab="Number of cigarette", pch=4, col="blue")
        lines(userStatList[[1]], userStatList[[2]], type="s",col="blue") 
      })
      output$allUser2 <- renderPlot({
        persp3D(z = data.matrix(smokePatern), theta = 120)
      })
      output$allUser3 <- renderPlot({
        persp3D(z = data.matrix(sumMode), theta = 120)
      })
      output$allUser4 <- renderPlot({
        plot(userStatList[[1]],sevenDayList,main="Total cigarette smoked for the last 7 days", xlab="User Id", ylab="Number of cigarette", pch=4, col="red")
        lines(userStatList[[1]], sevenDayList, type="s",col="red") 
      })
      output$perMode <- renderPlot({
        plot(numberList,userStatList[[3]][[input$UIDGen]],main="Per mode", xlab="Mode", ylab="Number of cigarette", pch=4, col="green")
        lines(numberList, userStatList[[3]][[input$UIDGen]], type="s",col="green") 
      })
      output$perDay <- renderPlot({
        plot(userStatList[[4]][[1]],userStatList[[4]][[3]][[input$UIDGen]],main="Per day", xlab="Day", ylab="Number of cigarette", pch=4, col="black")
        lines(userStatList[[4]][[1]], userStatList[[4]][[3]][[input$UIDGen]], type="s",col="black") 
      })
      output$perInterval <- renderPlot({
        plot(userStatList[[5]][[1]],userStatList[[5]][[2]][[input$UIDGen]],main="Per Interval of 6 hours", xlab="Interval", ylab="Number of cigarette", pch=4, col="orange")
        lines(userStatList[[5]][[1]], userStatList[[5]][[2]][[input$UIDGen]], type="s",col="orange") 
      })
      output$userTotalNumber  <- renderText({
        userStatList[[2]][[input$UIDInd]]
      })
      output$userModeNumber <- renderText({
        userStatList[[3]][[input$UIDInd]][[giveMeModeNumber(input$mode)]]
      })
      output$userDayNumber <- renderText({
        userStatList[[4]][[3]][[input$UIDInd]][[giveMeDayNumber(input$weekDay)]]
      })
      output$userIntervalNumber <- renderText({
        userStatList[[5]][[2]][[input$UIDInd]][[giveMeIntervalNumber(input$interval)]]
      })
      output$userSevenDay <- renderText({
        userStatList[[7]][[input$UIDInd]]
      })
    }
  }
  texte="Welcome - You need to upload a file & wait for this message to change"
  userStatList=list()
  smokePatern<-data.frame()
  sumMode<-data.frame()
  indivPerModeTotal<-data.frame()
  sevenDayList<-list()
  dayList=list("Sunday","Monday","Tuesday","wednesday","Thirsday","Friday","Saturday")
  modeList=list("Oservation week","Cheated","Friend","Ontime","Skipped","Snoozed","Auto skipped")
  numberList=list(1,2,3,4,5,6,7)
  
  #output$text <- renderPrint({
  output$text <- reactive({
    print(texte)
  })
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default
    req(input$file1)
    
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep)
    print("Begining")
    if(input$disp == "head") {
      
      texte<<-"Computation - WAIT - Computation is needed before navigation"
      output$text <<- reactive({
        print(texte)
      })
      print("Computation - WAIT")
      df1=df
      df2<-preprocessData(df1)
      userStatListLocal<-UserStat(df2)
      userStatList<<-userStatListLocal
      ###All users
      smokePatern<<-generateSumSmokePaternDataframe(userStatListLocal)
      sumMode<<-generateSumModeDataframe(userStatListLocal)
      ###Individual
      indivPerModeTotal<<-generatePerModeDataframe(userStatListLocal)
      sevenDayList<<-generatelastSevenDayList(userStatListLocal)
      print("Computation - DONE")
      texte<<-"Computation - DONE - You are free to naviguate"
      output$text <- reactive({
        print(texte)
      })
      displayChange()
      return(head(df))
    }
    
  })

  displayChange()
}

shinyApp(server = server, ui = ui)

#####################################################################################################################
