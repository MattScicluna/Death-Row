#Death row inmates R analysis


#Install necessary packages
pckgs = list("tm", "lsa", "tsne")

func <- function(x){
  if(!is.element(x, rownames(installed.packages())))
  {install.packages(x)}
  }

lapply(pckgs, func)
lapply(pckgs, library, character.only=TRUE)


#Read in the data
data=read.csv(".\\Death Row Data.csv")
dataset=DataframeSource(data[1])
mycorpus<-Corpus(dataset, readerControl=list(language="eng", reader=readPlain))
mycorpus <- tm_map(mycorpus, removePunctuation)
mycorpus <- tm_map(mycorpus, removeNumbers)
mycorpus <- tm_map(mycorpus, stemDocument)
stopwordseng=stopwords(kind = "en")
mycorpus <- tm_map(mycorpus, removeWords, stopwordseng)
mycorpus <- tm_map(mycorpus, content_transformer(tolower))


#getTransformations() to see your options!!!
TDM=TermDocumentMatrix(mycorpus)
TDMred=removeSparseTerms(TDM, 0.9)
findFreqTerms(TDM, 30)
findAssocs(TDM, "jesus", 0.3)


TDMMat<-as.matrix(TDMred)
head(TDMMat[,1:2]) #sees beginning of first 2 documents only


#Perform Latent Semantic Analysis
LSAOBJ=lsa(TDMMat)
TK=as.matrix(as.data.frame(LSAOBJ[1]))
DK=as.matrix(as.data.frame(LSAOBJ[2]))
SK=as.matrix(as.data.frame(LSAOBJ[3]))

#make SK diagonal matrix
SK=diag(SK[,1])

dim(TK) #Note the dimensions!
#[1] 53 13
dim(SK)
#[1] 13  13
dim(DK)
#[1] 495  13
dim(TDM2)
#[1]  53 495

MK=TK%*%SK%*%t(DK)

#compare the reconstruction
TDMred=as.matrix(TDMred)
head(as.matrix(TDMred))
head(MK)


#Now lets reconstruct document 1 using this
recon=solve(SK)%*%t(TK)%*%TDMred[,1]
recon2=solve(SK)%*%t(TK)%*%TDMred[,2]


#compare cosine of original docs and reconstruction
cosine(as.vector(recon),as.vector(recon2))
cosine(as.vector(TDMred[,1]),as.vector(TDMred[,2]))
cosine(as.vector(MK[,1]),as.vector(MK[,2]))


#Reduced the dimensionality from 53 to 13.
recon=solve(SK)%*%t(TK)%*%TDMred


#Doing K means test on the reconstruction
KMEANSTEST=kmeans(t(recon),2)
data=as.vector(data)
racecluster1=data[,7][unlist(KMEANSTEST[1])==1]
racecluster2=data[,7][unlist(KMEANSTEST[1])==2]

summary(racecluster1) #Is race causing this cluster?
summary(racecluster2)

countycluster1=data[,8][unlist(KMEANSTEST[1])==1]
countycluster2=data[,8][unlist(KMEANSTEST[1])==2]

summary(countycluster1) #Is county affecting this cluster?
summary(countycluster2)

year=substr(data[,6],7,10) #Gets the year
yearcluster1=year[unlist(KMEANSTEST[1])==1]
yearcluster2=year[unlist(KMEANSTEST[1])==2]
summary(factor(yearcluster1))
summary(factor(yearcluster2))


TDMC1=TDMMat[,unlist(KMEANSTEST[1])==1]
TDMC2=TDMMat[,unlist(KMEANSTEST[1])==2]


#Another cool way to cluster the data using tsne!
test=tsne(t(TDMred),k=2)
KMEANSTEST=kmeans(test,2)
plot(test)
points(as.matrix(as.data.frame(KMEANSTEST[2])),col='red')
