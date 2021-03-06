#############################################################
### Construct visual features for training/testing images ###
#############################################################

  library("EBImage")
  #library("rPython")
 
  
  features<-function(img_dir,type="train"){
    
  img_names<-list.files(img_dir)

    Rbin<-seq(0,1,length.out =  10) 
    Gbin<-seq(0,1,length.out = 10)
    Bbin<-seq(0,1,length.out = 10)

    Hbin<-seq(0,1,length.out =  10) 
    Sbin<-seq(0,1,length.out = 10)
    Vbin<-seq(0,0.005,length.out = 10)


    ## RGB features
    rgb_features<-data.frame(matrix(NA,3000,1001))
    colnames(rgb_features)<-c('Image',paste('rbg_',1:1000,sep=""))
    rgb_features$Image<-img_names
    ## HSV features
    hsv_features<-data.frame(matrix(NA,3000,1001))
    colnames(hsv_features)<-c('Image',paste('hsv_',1:1000,sep=""))
    hsv_features$Image<-img_names

    #gray features
    Gbin<-seq(0,1,length.out =  250)
    gray_features<-data.frame(matrix(NA,3000,251))
    colnames(gray_features)<-c('Image',paste('gray_',1:250,sep=""))

    for(i in 1:3000){
      #print(i)
      img<-readImage(paste(img_dir,img_names[i],sep=""))
      img<-resize(img,256,256)
      if(length(dim(img))!=3){
        # img_gray<-channel(img,"gray")
        # img_mat_gray<-imageData(img_gray)
        # freq_gray <- as.data.frame(table(factor(findInterval(img_mat_gray, Gbin), levels = 1:250)))
        # gray_features[i,2:251] <- as.numeric(freq_gray$Freq)/(ncol(img_mat_gray)*nrow(img_mat_gray))
        next
      }
      #img<-resize(img,256,256)
      img_mat<-imageData(img)
      
      ### RGB
      rgb_mat<-img_mat
      rgb_df=as.data.frame(table(factor(findInterval(rgb_mat[,,1],Rbin),levels = 1:10),
       factor(findInterval(rgb_mat[,,2],Gbin),levels = 1:10),
       factor(findInterval(rgb_mat[,,3],Bbin),levels = 1:10)))
      rgb_features[i,2:1001]<-rgb_df$Freq/(256^2)
      
      ### HSV
      dim(img_mat)<-c(256*256,3)
      hsv_mat<-rgb2hsv(t(img_mat))
      hsv_df=as.data.frame(table(factor(findInterval(hsv_mat[1,],Hbin),levels = 1:10),
       factor(findInterval(hsv_mat[2,],Sbin),levels = 1:10),
       factor(findInterval(hsv_mat[3,],Vbin),levels = 1:10)))
      hsv_features[i,2:1001]<-hsv_df$Freq/(256^2)
      
      ### Gray
      img_gray<-channel(img,"gray")
      #img<-resize(img,256,256)
      img_mat_gray<-imageData(img_gray)
      freq_gray <- as.data.frame(table(factor(findInterval(img_mat_gray, Gbin), levels = 1:250)))
      gray_features[i,2:251] <- as.numeric(freq_gray$Freq)/(ncol(img_mat_gray)*nrow(img_mat_gray))
    }

    color_features<-merge(rgb_features,hsv_features,by.x = "Image",by.y="Image")
    
    sift_features<-read.csv("~/Desktop/[ADS]Advanced Data Science/Fall2017-project3-fall2017-project3-grp9/data/training_set//sift_train.csv")
    
    ############################################
    ####### construct in python first ##########
    ############################################
    lbp_features<-read.csv("~/Desktop/[ADS]Advanced Data Science/Fall2017-project3-fall2017-project3-grp9/data/lbp_feature.csv")
    
    # write.csv(features_sift_color_lbp,"~/Desktop/[ADS]Advanced Data Science/Fall2017-project3-fall2017-project3-grp9/output/train_features_sift_color_lbp.csv")
    # write.csv(features_sift_color_lbp_gray,"~/Desktop/[ADS]Advanced Data Science/Fall2017-project3-fall2017-project3-grp9/output/train_features_sift_color_lbp_gray.csv")
    
    features_sift_color_lbp<-cbind(sift_features,color_features[,-1],lbp_features[,-1])
    features_sift_color_lbp_gray<-cbind(sift_features,color_features[,-1],lbp_features[,-1],gray_features)
    #save(features_sift_color_lbp,features_sift_color_lbp_gray,file="./data/train_features.RData")
    return(list(NoGray=features_sift_color_lbp,Gray=features_sift_color_lbp_gray))
  }

