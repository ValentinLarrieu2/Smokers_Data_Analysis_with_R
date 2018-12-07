getwd()

df3 <- read.csv("./Files/Dataset.csv",sep=";",na.strings=c("","NA"))#Fill blank element with NA
library(plyr)

############################################################################################################CLEANING FUNCTIONS
#Function that reads a coma list and contruct new collumn using it
cleanComaList <- function(dataset,data,defaultColumnName,defaultValue,separator,correctList){ 
  #initialisation
  list1Value <- list()
  list1Features <- list()
  lineList=list()
  rawList=list()
  counter=0
  #If we want the list to start with a value
  if (defaultValue!=""){
    list1Features<-c(list1Features,defaultValue)
  }
  #we run through the set to separate data
  for ( u in 1:length(data)){
    #we split at the end character
    lineList=strsplit(as.character(data[u]),separator)
    rawList=unlist(lineList)
    #we run through the element to add new features if they were not in previously
    for (k in 1:length(rawList)){
      rawList[k]=specialCorrection(rawList[k]) #######AJOUT
      if (!is.element(rawList[k],list1Features)){
        list1Features<-c(list1Features,rawList[k])
      }
    }
    list1Value<-c(list1Value,lineList) #we put the line splited in the list
  }
  for (v in 1:length(list1Features)){
    columnToInsert=list()
    for (w in 1:length(list1Value)){
      if (is.element(list1Features[v],list1Value[w])){
        columnToInsert<-c(columnToInsert,"TRUE")
      }
      else{
        columnToInsert<-c(columnToInsert,"FALSE")
      }
    }
    
    set <- (ldply (columnToInsert, data.frame))
    dataset["toModify"]<-(set)
    #if (list1Features[v]==defaultValue){
    list1Features[v]<-gsub(" ","-",(paste(defaultColumnName,list1Features[v], sep="-")))
    #}
    colnames(dataset)[colnames(dataset)=="toModify"] <- (list1Features[v])
  }
  #we construct the list of TRUE/FALSE corresponding to the features
  
  return(dataset)
}

#Function specialised to change string value to another
specialCorrection<-function(word){
  if (word=="H" || word=="Hea" || word=="Healt"){
    word="Health"
  }
  if (word=="Wor"){
    word="Work"
  }
  if (word=="Champix)"){
    word="Medicine-based (e.g."
  }
  if (word=="iphone"){
    word=("iPhone")
  }
  if (word=="S"){
    word="Other"
  } 
  if (word=="P"){
    word="Prefer not to say"
  } 
  if (word=="I would like to q"|| word=="I would l"|| word=="I wou"|| word=="I w"|| word=="I"|| word=="I would like"|| word=="I would like to quit smok"){
    word="I would like to quit smoking"
  }
  if (word=="I would like to reduce smoki"){
    word="I would like to reduce smoking"
  } 
  if   (word=="I have major health problems that are greatly affecting my quality of life (e" | word=="I have major health problems that are greatly affecting my quality of life (example: cancer, diabetes, chronic ill" | word=="I have major health prob" | word=="I have major health problems that are greatl" | word=="I have major health problems that are greatly affecting my quality o" | word=="I have major health problems that are greatly affecting my quality of life (example: cancer, diabetes, chronic illn" )
  {
    word="I have major health problems that are greatly affecting my quality of life (example: cancer, diabetes, chronic illness)"
  } 
  
  if (word=="I have minor non chronic health issues, which are mildly affecting my"){
    word="I have minor non chronic health issues, which are mildly affecting my quality of life"
  } 
  if (word=="I am generally very" | word=="I am genera" ){
    word="I am generally very healthy"
  } 
  
  return (word)
}

#Functions that only keeps numbers
cleanNumber <- function(data){ 
  data=as.numeric( gsub('[^0-9.]', '', data))
  return(data)
}

#Function that keeps letter and numbers
cleanString <- function(data){ 
  data=( gsub('[^a-zA-Z0-9.]', '', data))
  return(data)
}

#Function that clean the Height column (scale little values and filter to keep numbers)
cleanHeight <- function(data){
  data=cleanNumber(data)
  for ( u in 1:length(data)){
    if (data[u]<=2){
      data[u]<-data[u]*100
    }
  }
  return(data)
}

#Function that clear the phone column
cleanSpecialString <- function(data){
  for ( u in 1:length(data)){
    data[u]<-(specialCorrection(data[u]))
  }
  return(data)
}

cleanPhone <- function(data){
  for ( u in 1:length(data)){
    if (data[u]=="iphone"){
      data[u]<-"iPhone"
    }
    if (data[u]=="S"){
      data[u]<-"Other"
    } 
  }
  return(data)
}

specialClearCountry <- function(data){
  for ( u in 1:length(data)){
    if (data[u]=="United states" || data[u]=="US" ){
      data[u]<-"US"
      next
    }
    if (data[u]=="United Kingdom"){
      data[u]<-"UK"
      next
    } 
    else{
      data[u]<-"Other"
    } 
  }
  return(data)
}
############################################################################################################

#Weight cleaning
df3$How.much.do.you.weigh...kg.=cleanNumber(df3$How.much.do.you.weigh...kg.)
df3$What.is.your.height...cm.=cleanHeight(df3$What.is.your.height...cm.)

#BMI construction
df3$BMI <- df3$How.much.do.you.weigh...kg. / ((df3$What.is.your.height...cm. / 100.) * (df3$What.is.your.height...cm. / 100.))

##########################-Categorie
df3$WeightCategorie[df3$How.much.do.you.weigh...kg.<=60]<- 1 #Light
df3$WeightCategorie[df3$How.much.do.you.weigh...kg.>=90]<- 3 #Heavy
df3$WeightCategorie[df3$How.much.do.you.weigh...kg.>3]<- 2 #Medium

#Height Cleaning
df3$What.is.your.height...cm.=cleanHeight(df3$What.is.your.height...cm.)
##########################-Categorie
df3$HeightCategorie[df3$What.is.your.height...cm.<=140]<- 1 #Short
df3$HeightCategorie[df3$What.is.your.height...cm.>=180]<- 3 #Tall
df3$HeightCategorie[df3$What.is.your.height...cm.>3]<- 2 #Medium

#Age categorising
##########################-Categorie
df3$AgeCategorie[df3$Age<=30]<- 1 #Young
df3$AgeCategorie[df3$Age>=50]<- 3 #Senior
df3$AgeCategorie[df3$Age>3]<- 2 #Medium

#Age started
df3$At.what.age.you.started.to.smoke.regularly.[df3$At.what.age.you.started.to.smoke.regularly.==0]<- 20 
##########################-Categorie
df3$AgeStartedCategorie[df3$At.what.age.you.started.to.smoke.regularly.<=15]<- 1 #VeryYoung
df3$AgeStartedCategorie[df3$At.what.age.you.started.to.smoke.regularly.>=30]<- 4 #Later
df3$AgeStartedCategorie[df3$At.what.age.you.started.to.smoke.regularly.>15 & df3$At.what.age.you.started.to.smoke.regularly.<=21]<- 2 #Medium
df3$AgeStartedCategorie[df3$At.what.age.you.started.to.smoke.regularly.>21 & df3$At.what.age.you.started.to.smoke.regularly.<30]<- 3 #Medium

#Gender cleaning
df3$Gender <- as.numeric(df3$Gender)

#Phone type cleaning
df3$What.type.of.phone.do.you.have.[df3$What.type.of.phone.do.you.have.=="S"]<- "Other"
df3$What.type.of.phone.do.you.have.[df3$What.type.of.phone.do.you.have.=="iphon"]<- "iPhone"
df3$What.type.of.phone.do.you.have.[df3$What.type.of.phone.do.you.have.=="iphone"]<- "iPhone"
df3$What.type.of.phone.do.you.have. <- droplevels(df3$What.type.of.phone.do.you.have.)
df3$What.type.of.phone.do.you.have. =as.numeric(df3$What.type.of.phone.do.you.have.)

#Education
df3$Education =as.numeric(df3$Education)

#Family status
df3$Family.status =as.numeric(df3$Family.status)

#########################################We populate the missing values with the most probables 
df3[, sapply(df3, function(x) !is.numeric(x))] <- apply(df3[, sapply(df3, function(x) !is.numeric(x))], 2, function(x) {x[is.na(x)] <- names(sort(table(x), decreasing = TRUE)[1]); x})


########################################We split the inline features into a lot of column
#Health problem
df3=cleanComaList(df3,df3$Do.you.have.or.have.you.had.any.of.the.below.health.conditions...select.all.that.apply.,"HealthProblem","None",", ",list())
df3$Do.you.have.or.have.you.had.any.of.the.below.health.conditions...select.all.that.apply.<- NULL

#Reason filtering
df3=cleanComaList(df3,df3$Why.do.you.want.to.reduce.quit.smoking.,"ReasonToReduce","Other",", ",list())
df3$Why.do.you.want.to.reduce.quit.smoking.<- NULL

#method tried to stop
df3=cleanComaList(df3,df3$What.method.did.you.try.to.quit.smoking.before...select.all.that.apply.,"MethodToStop","Other",", ",list())
df3$What.method.did.you.try.to.quit.smoking.before...select.all.that.apply.<- NULL

#Reduce smoking
df3$Do.you.prefer.to.quit.or.to.reduce.smoking.=cleanSpecialString(df3$Do.you.prefer.to.quit.or.to.reduce.smoking.)

#Contry
df3$Where.do.you.live.=specialClearCountry(df3$Where.do.you.live.)
df3$Where.do.you.live.[df3$Where.do.you.live.=="Other"]<- 1 
df3$Where.do.you.live.[df3$Where.do.you.live.=="UK"]<- 2
df3$Where.do.you.live.[df3$Where.do.you.live.=="US"]<- 3 

#Cigarette EveryDay
##########################-Categorie
df3$CigaretteEveryDay[df3$How.many.cigarettes.do.you.smoke.each.day.=="I do not smoke every day"]<- 1 #low
df3$CigaretteEveryDay[df3$How.many.cigarettes.do.you.smoke.each.day.=="10 or fewer"]<- 2 #low
df3$CigaretteEveryDay[df3$How.many.cigarettes.do.you.smoke.each.day.=="nov-20"]<- 3 #medium
df3$CigaretteEveryDay[df3$How.many.cigarettes.do.you.smoke.each.day.=="21-30"]<- 3 #medium
df3$CigaretteEveryDay[df3$How.many.cigarettes.do.you.smoke.each.day.=="31 or more"]<- 4 #long
##########################-Non categorie
df3$How.many.cigarettes.do.you.smoke.each.day.[df3$How.many.cigarettes.do.you.smoke.each.day.=="I do not smoke every day"]<- 1 #low
df3$How.many.cigarettes.do.you.smoke.each.day.[df3$How.many.cigarettes.do.you.smoke.each.day.=="10 or fewer"]<- 2 #low
df3$How.many.cigarettes.do.you.smoke.each.day.[df3$How.many.cigarettes.do.you.smoke.each.day.=="nov-20"]<- 3 #medium
df3$How.many.cigarettes.do.you.smoke.each.day.[df3$How.many.cigarettes.do.you.smoke.each.day.=="21-30"]<- 4 #medium
df3$How.many.cigarettes.do.you.smoke.each.day.[df3$How.many.cigarettes.do.you.smoke.each.day.=="31 or more"]<- 5 #long

#Wake up cigarette
##########################-Categorie
df3$FirstDailyCig[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="Within 5 minutes"]<- 1 #Soon
df3$FirstDailyCig[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="5-30 minutes"]<- 2 #Soon
df3$FirstDailyCig[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="31-60 minutes"]<- 2 #medium
df3$FirstDailyCig[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="After 60 minutes"]<- 3 #medium
df3$FirstDailyCig[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="After 2 or more hours"]<- 3 #Late
##########################-Non Categorie
df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="Within 5 minutes"]<- 1 #Soon
df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="5-30 minutes"]<- 2 #Soon
df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="31-60 minutes"]<- 3 #medium
df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="After 60 minutes"]<- 4 #medium
df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.[df3$How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette.=="After 2 or more hours"]<- 5 #Late

#Last time stop smoking
##########################-Categorie
df3$LastStopSmoking[df3$When.did.you.last.try.to.quit.smoking.=="Never tried to quit"]<- 4 #Never
df3$LastStopSmoking[df3$When.did.you.last.try.to.quit.smoking.=="Within the last month"]<- 1 #Recently
df3$LastStopSmoking[df3$When.did.you.last.try.to.quit.smoking.=="Within the last year"]<- 2 #1 year
df3$LastStopSmoking[df3$When.did.you.last.try.to.quit.smoking.=="Over 1 year ago"]<- 2 #1 year
df3$LastStopSmoking[df3$When.did.you.last.try.to.quit.smoking.=="Over 5 years ago"]<- 3 #Long time
##########################-Non Categorie
df3$When.did.you.last.try.to.quit.smoking.[df3$When.did.you.last.try.to.quit.smoking.=="Never tried to quit"]<- 1 #Never
df3$When.did.you.last.try.to.quit.smoking.[df3$When.did.you.last.try.to.quit.smoking.=="Within the last month"]<- 2 #Recently
df3$When.did.you.last.try.to.quit.smoking.[df3$When.did.you.last.try.to.quit.smoking.=="Within the last year"]<- 3 #1 year
df3$When.did.you.last.try.to.quit.smoking.[df3$When.did.you.last.try.to.quit.smoking.=="Over 1 year ago"]<- 4 #1 year
df3$When.did.you.last.try.to.quit.smoking.[df3$When.did.you.last.try.to.quit.smoking.=="Over 5 years ago"]<- 5 #Long time

#Stop using the method listed
##########################-Non Categorie
df3$Did.you.manage.to.quit.smoking.using.that.method.[df3$Did.you.manage.to.quit.smoking.using.that.method.=="No, I still smoke"]<- 1 #Never
df3$Did.you.manage.to.quit.smoking.using.that.method.[df3$Did.you.manage.to.quit.smoking.using.that.method.=="I managed to stop for a limited period"]<- 2 #Recently
df3$Did.you.manage.to.quit.smoking.using.that.method.[df3$Did.you.manage.to.quit.smoking.using.that.method.=="I managed to reduce the number of cigarettes"]<- 3 #1 year

#Family
##########################-Non Categorie
df3$How.would.you.categorize.your.family.[df3$How.would.you.categorize.your.family.=="Non-smokers"]<- 1 #Non-smokers
df3$How.would.you.categorize.your.family.[df3$How.would.you.categorize.your.family.=="Social smokers"]<- 2 #Social Smokers
df3$How.would.you.categorize.your.family.[df3$How.would.you.categorize.your.family.=="Moderate smokers"]<- 3 #Moderate smokers
df3$How.would.you.categorize.your.family.[df3$How.would.you.categorize.your.family.=="Heavy smokers"]<- 4 #Heavy Smoker
df3$How.would.you.categorize.your.family.[df3$How.would.you.categorize.your.family.=="Other"]<- 5 #Other

#Friends
##########################-Non Categorie
df3$How.would.you.categorize.your.friends.[df3$How.would.you.categorize.your.friends.=="Non-smokers"]<- 1 #Non-smokers
df3$How.would.you.categorize.your.friends.[df3$How.would.you.categorize.your.friends.=="Social smokers"]<- 2 #Social Smokers
df3$How.would.you.categorize.your.friends.[df3$How.would.you.categorize.your.friends.=="Moderate smokers"]<- 3 #Moderate smokers
df3$How.would.you.categorize.your.friends.[df3$How.would.you.categorize.your.friends.=="Heavy smokers"]<- 4 #Heavy Smoker
df3$How.would.you.categorize.your.friends.[df3$How.would.you.categorize.your.friends.=="Other"]<- 5 #Other

#Type of cigarettes
df3$Which.type.of.cigarettes.box.do.you.buy.[df3$Which.type.of.cigarettes.box.do.you.buy.=="Roll up"]<- 1 #Non-smokers
df3$Which.type.of.cigarettes.box.do.you.buy.[df3$Which.type.of.cigarettes.box.do.you.buy.=="20 cigarettes per pack" | df3$Which.type.of.cigarettes.box.do.you.buy.=="10 cigarettes per pack"]<- 2 #Social Smokers

#Own lighter
##########################-Non Categorie
df3$How.important.is.having.your.own.lighter.in.your.smoking.process.experience.[df3$How.important.is.having.your.own.lighter.in.your.smoking.process.experience.!="Not Important (I smoke the same amount of cigarettes as I always end up finding someone who would light my cigarette)"]<- 2 #Vital
df3$How.important.is.having.your.own.lighter.in.your.smoking.process.experience.[df3$How.important.is.having.your.own.lighter.in.your.smoking.process.experience.=="Not Important (I smoke the same amount of cigarettes as I always end up finding someone who would light my cigarette)"]<- 1 #Non important


#Brand of cigarette
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Marlboro"]<- 1 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Allure"]<- 2 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Dunhill"]<- 3 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Davidoff"]<- 4 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Winston"]<- 5 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Gitane"]<- 6 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Kent"]<- 7 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Parliament"]<- 8 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Cedars"]<- 9 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Gauloises"]<- 10 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Camel"]<- 11 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Winchester"]<- 12 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Other"]<- 13 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Superkings"]<- 14 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Lucky Strike"]<- 15 
df3$What.is.the.brand.of.your.cigarettes.[df3$What.is.the.brand.of.your.cigarettes.=="Rothmans"]<- 16 

#Salary
df3$How.much.salary.do.you.earn.each.month.=cleanSpecialString(df3$How.much.salary.do.you.earn.each.month.)
df3$How.much.salary.do.you.earn.each.month.[df3$How.much.salary.do.you.earn.each.month.=="Prefer not to say" | df3$How.much.salary.do.you.earn.each.month.=="P"]<- 1 
df3$How.much.salary.do.you.earn.each.month.[df3$How.much.salary.do.you.earn.each.month.=="Below $1,000"]<- 2 
df3$How.much.salary.do.you.earn.each.month.[df3$How.much.salary.do.you.earn.each.month.=="$1,000-$5,000"]<- 3 
df3$How.much.salary.do.you.earn.each.month.[df3$How.much.salary.do.you.earn.each.month.=="$5,000-$10,000"]<- 4 
df3$How.much.salary.do.you.earn.each.month.[df3$How.much.salary.do.you.earn.each.month.=="$10,000 and more"]<- 5 

#health description
df3$How.do.you.describe.your.health.=cleanSpecialString(df3$How.do.you.describe.your.health.)
df3$How.do.you.describe.your.health.[df3$How.do.you.describe.your.health.=="I am generally very healthy"]<- 1 
df3$How.do.you.describe.your.health.[df3$How.do.you.describe.your.health.=="I have minor non chronic health issues, which are mildly affecting my quality of life"]<- 2 
df3$How.do.you.describe.your.health.[df3$How.do.you.describe.your.health.=="I have major health problems that are greatly affecting my quality of life (example: cancer, diabetes, chronic illness)"]<- 3 

#Want to stop or reduce
df3$Do.you.prefer.to.quit.or.to.reduce.smoking.[df3$Do.you.prefer.to.quit.or.to.reduce.smoking.=="I am happy and would not like to change anything"]<- 1 
df3$Do.you.prefer.to.quit.or.to.reduce.smoking.[df3$Do.you.prefer.to.quit.or.to.reduce.smoking.=="I would like to reduce smoking"]<- 2 
df3$Do.you.prefer.to.quit.or.to.reduce.smoking.[df3$Do.you.prefer.to.quit.or.to.reduce.smoking.=="I would like to quit smoking"]<- 3 
df3$Do.you.prefer.to.quit.or.to.reduce.smoking. =as.numeric(df3$Do.you.prefer.to.quit.or.to.reduce.smoking.)

#print.data.frame(df3)

#we convert all the column to numerical
df3[1:ncol(df3)] <- lapply(df3[1:ncol(df3)], as.numeric)

#column renaming
names(df3)[names(df3) == "Family.status"] <- "FamilyStatus"
names(df3)[names(df3) == "How.much.do.you.weigh...kg."] <- "Weight"
names(df3)[names(df3) == "What.is.your.height...cm."] <- "Height"
names(df3)[names(df3) == "At.what.age.you.started.to.smoke.regularly."] <- "AgeStarted"
names(df3)[names(df3) == "How.many.cigarettes.do.you.smoke.each.day."] <- "CigaretteEveryday"
names(df3)[names(df3) == "How.soon.after.you.wake.up.do.you.smoke.your.first.cigarette."] <- "wakeUpCigarette"
names(df3)[names(df3) == "When.did.you.last.try.to.quit.smoking."] <- "LastStopSmoking"
names(df3)[names(df3) == "Did.you.manage.to.quit.smoking.using.that.method."] <- "SucessfulStop"
names(df3)[names(df3) == "How.would.you.categorize.your.friends."] <- "FriendsCategorie"
names(df3)[names(df3) == "How.would.you.categorize.your.family."] <- "FamilyCategorie"
names(df3)[names(df3) == "What.is.the.brand.of.your.cigarettes."] <- "CigaretteBrand"
names(df3)[names(df3) == "Which.type.of.cigarettes.box.do.you.buy."] <- "CigaretteBox"
names(df3)[names(df3) == "How.important.is.having.your.own.lighter.in.your.smoking.process.experience."] <- "OwnLighter"
names(df3)[names(df3) == "What.type.of.phone.do.you.have."] <- "PhoneType"
names(df3)[names(df3) == "Where.do.you.live."] <- "Country"
names(df3)[names(df3) == "How.much.salary.do.you.earn.each.month."] <- "Salary"
names(df3)[names(df3) == "How.do.you.describe.your.health."] <- "Health"
names(df3)[names(df3) == "Do.you.prefer.to.quit.or.to.reduce.smoking."] <- "QuitOrReduce"

#Statitstics
plot(density(df3$Age))
summary(df3$Age)

plot(density(df3$Weight))
summary(df3$Weight)


plot(density(df3$Height))
summary(df3$Height)

plot(density(df3$BMI))
summary(df3$BMI)

plot(density(df3$Education))
pie(table(df3$Education))

plot(density(df3$Gender))
pie(table(df3$Gender))


fivenum(df3$Age)
sapply(df3, mean, na.rm=TRUE)
sapply(df3, sd, na.rm=TRUE)
#pairs(df3)

#Some graphics
library('ggplot2')
qplot(Education,Salary, data=df3,color=CigaretteBrand)
qplot(Education,Salary, data=df3,color=PhoneType)
qplot(Education,Salary, data=df3,color=Gender)
qplot(Education,AgeStarted, data=df3,color=BMI)
qplot(CigaretteBrand,Salary, data=df3,color=Country)
qplot(AgeStarted,CigaretteEveryday, data=df3,color=Gender)
qplot(FamilyStatus,CigaretteEveryday, data=df3,color=Gender)

#barchart(table(df3$Gender))
df4<-df3[1:22]
pairs(df4)

#Corelations
cor(df3$Height,df3$BMI)
cor(df3$Salary,df3$PhoneType)

cor(df4)
##############################################################Clustering
####################################KMEAN
(kmeans.result<-kmeans(df4,10)) #.result$cluster for inst
table(df4$BMI,kmeans.result$cluster)
#plot
plot(df4[c("Age","Weight")],col=kmeans.result$cluster)
points(kmeans.result$centers[,c("Age","Weight")],col=1:3,pch=8,cex=2) #pch is the type of point

####################################Medoids
#install.packages('fpc')
library(fpc)
pamk.result<-pamk(df4)
#number of clusters
pamk.result$nc
table(pamk.result$pamobject$clustering,df4$BMI)
layout(matrix(c(1,2),1,2))
plot(pamk.result$pamobject)
layout(matrix(1)) #the silhouette is the proba it is well clustered

#####################################APRIORI
#install.packages("arulesViz")
library(arules)
library(arulesViz)
df5<-df3[8:22]
df5 <- data.frame(sapply(df5,as.factor))
rules<- apriori(df5)
quality(rules)<-round(quality(rules),digits=3)
#rules.all
inspect(rules)

inspect(head(sort(rules, by="lift"),20));

plot(rules)
head(quality(rules))
plot(rules, measure=c("support","lift"), shading="confidence")
plot(rules, shading="order", control=list(main ="Two-key plot"))

sel = plot(rules, measure=c("support","lift"), shading="confidence", interactive=TRUE)
subrules = rules[quality(rules)$confidence > 0.8]
subrules

plot(subrules, method="matrix", measure="lift")
plot(subrules, method="matrix", measure="lift", control=list(reorder=TRUE))
plot(subrules, method="matrix3D", measure="lift")
plot(subrules, method="matrix3D", measure="lift", control = list(reorder=TRUE))
plot(subrules, method="matrix", measure=c("lift", "confidence"))
plot(subrules, method="matrix", measure=c("lift","confidence"), control = list(reorder=TRUE))
plot(rules, method="grouped")
plot(rules, method="grouped", control=list(k=50))
sel = plot(rules, method="grouped", interactive=TRUE)

subrules2 = head(sort(rules, by="lift"), 30)
plot(subrules2, method="graph")
plot(subrules2, method="graph", control=list(type="items"))
plot(subrules2, method="paracoord")
plot(subrules2, method="paracoord", control=list(reorder=TRUE))
oneRule = sample(rules, 1)
inspect(oneRule)
