//
//  DisasterDetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DisasterDetailViewController.h"
#import "DisasterMapViewController.h"
#import "LocalTypeManager.h"
#import "LocalChemicalsManager.h"
#import "Masonry.h"
#import "PollutionMapViewController.h"
#import "MyPDFViewController.h"
#import "SamplePlanModel.h"
#import "PollutionsViewController.h"
#import "UploadViewController.h"
@interface DisasterDetailViewController ()<PollutionMapDelegate>{
    NSInteger currentIndex;
    UIView *selectLightView;
//    NSString *address;
    NSString *locationStr;
    BOOL showPic;
    NSMutableDictionary *addressDic ;
    NSMutableDictionary *addressLBDic;
    CLLocationCoordinate2D updataLocation;
    
    BOOL showLocationInfo;
}
@property (strong, nonatomic) UIWindow *keyWindow;
@property (strong, nonatomic) NSArray *taskArray;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong ,nonatomic) NSMutableArray *imageIDs;

@property (strong, nonatomic) UINavigationController *photoNavigationController;


@end

@implementation DisasterDetailViewController

#pragma mark Network
-(void)getSamplePlanList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:self.did forKey:@"searchKey"];
    [parameters setValue:@"-1" forKey:@"pageIndex"];
    
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:SAMPLE_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        NSArray *array = [dictionary valueForKey:@"Items"];
        for (NSDictionary *sub in array ) {
            SamplePlanModel *model = [SamplePlanModel modelWithJSON:sub];
//            [self getPlanTaskList:model];
            [tempArray addObject:model];
        }
       self.taskArray = tempArray;
//        [self addTaskPoint];
    } onError:^(NSError *engineError) {
        
    }];
}

#pragma mark UIView
- (void)viewDidLoad {
      [super viewDidLoad];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewPoint:) name:@"GengXinShuZu" object:nil];
    [Utility configuerNavigationBackItem:self];
    mIsNotInit = NO;
    addressDic = [[NSMutableDictionary alloc]init];
    addressLBDic= [[NSMutableDictionary alloc]init];
    SD=[[Disaster alloc] init];
    SD.uniqueID=[[NSUUID alloc]initWithUUIDString:self.did];
    SD.starttime=[NSDate dateWithTimeIntervalSince1970:0];
    _imageIDs = [[NSMutableArray alloc]init];
    
    mBaseinfoList = [[NSMutableArray alloc]init];
    
    [mBaseinfoList addObject:@{@"cellLabel":@"事故性质",@"cellContent":@""}];
    [mBaseinfoList addObject:@{@"cellLabel":@"化学品",@"cellContent":@""}];
    //mChemicalsList = [[NSMutableArray alloc]init];
    mDisasterImageIds = [[NSMutableArray alloc]init];
    
    mBlockViews = [[NSMutableArray alloc]init];
    mImageViewsInBlockView = [[NSMutableArray alloc]init];
    mTimelineViews = [[NSMutableArray alloc]init];
    mBlockHeights = [[NSMutableArray alloc]init];
    mBlockOffsets = [[NSMutableArray alloc]init];
    
    [SD loadInputBatches];
    [SD loadDataLocs];
    
    mDisasterImageViews = [[NSMutableDictionary alloc]init];
    mDisasterLoadViews = [[NSMutableDictionary alloc]init];
    [self getSamplePlanList];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
}
-(void)addNewPoint:(NSNotification *)notification{
    
    //    [mMapView removeAnnotations:annArray];
    
    NSArray *userInfo =[notification object];
    self.taskArray =userInfo;
    
    
  
}
-(UIView *)buttonView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-120, 0, 120, 56)];
    view.backgroundColor = BLUE_COLOR ;
    UIButton *mapButton = [[UIButton alloc]initWithFrame:CGRectMake(65, 8, 45, 40)];
    [mapButton setBackgroundImage:[UIImage imageNamed:@"icon_explore"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(showMapViewAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:mapButton];
    
    UIButton *uploadButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 8, 45, 40)];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"icon_upload"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(showDataUploadViewAction) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:uploadButton];
    return view;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"view will disappear");
    [mGetRelatedDataTime invalidate];
    mGetRelatedDataTime = nil;
    [mCountDateTimer invalidate];
    mCountDateTimer = nil;
    [mGetImagesTimer invalidate];
    mGetImagesTimer = nil;
    
    [CustomHttp cancelAllRequest];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    //获取数据
    [self performSelector:@selector(getDisasterDetailData) withObject:nil afterDelay:0];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    showPic = NO;
}

-(void)dealloc{
    NSLog(@"dealloc");
}
-(void)showMapViewAction{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DisasterMapViewController *vc = [story instantiateViewControllerWithIdentifier:@"DisasterMapViewController"];
    vc.disasterId = self.did;
    vc.taskArray = self.taskArray;
    vc.hadLocation = showLocationInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showDataUploadViewAction{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UploadViewController *vc = [story instantiateViewControllerWithIdentifier:@"UploadViewController"];
    vc.did = self.did;
    vc.showLocationInfo = showLocationInfo;
    vc.taskArray = self.taskArray;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)showFileViewAction:(id)sender{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MyPDFViewController *pdfVC = [story instantiateViewControllerWithIdentifier:@"MyPDFViewController"];
    pdfVC.did = self.did;
    [self.navigationController pushViewController:pdfVC animated:YES];
}

-(void)setPollutionLocation:(CLLocationCoordinate2D)coor{
    
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:)){
        return YES;
    }else{
         return [super canPerformAction:action withSender:sender];
    }
}

-(void)getDisasterDetailData{
    __weak __typeof(self) weakSelf = self;
    //获取数据
    
    //详情
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_DETAIL] params:@{@"id":weakSelf.did} success:^(id responseObj) {
        NSLog(@"get disaster detail successfully, response = %@", responseObj);
     
        [SD populateDataWithDictionary:responseObj];
        if(SD.natureName == nil){
            [mBaseinfoList replaceObjectAtIndex:0 withObject:@{@"cellLabel":@"事故性质",@"cellContent":@"未知事故"}];
        }else{
            [mBaseinfoList replaceObjectAtIndex:0 withObject:@{@"cellLabel":@"事故性质",@"cellContent":SD.natureName}];
        }
        //当前事故发生中，加载计时条
        if (SD.endtime==nil){
            mStarttimeButton = [weakSelf createProcessingDisasterStartTime:nil];
            [self.view addSubview:[self buttonView]];
            mCountDateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(countDate:) userInfo:SD.starttime repeats:YES];
        }
        else{
            //不显示计时条，取消上传
            weakSelf.navigationItem.rightBarButtonItem = nil;
        }
        
        //第一次 直接获取
        [weakSelf intervalGetRelatedData];
        //开启计时器
        [weakSelf startToGetRelatedData];
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster detail , error = %@", err);
    }];
}

-(void)createDisasterDetailView{
    __weak __typeof(self) weakSelf = self;
    //事故性质
 
   
  
    
    //化学品数据获取
    if (mChemicalsList.count > 0) {
        NSMutableString *ms=[[NSMutableString alloc]init];
        for(int i=0;i<mChemicalsList.count;i++){
            if (i>0) [ms appendString:@", "];
            [ms appendString:mChemicalsList[i][@"chemical_chinesename"] ];
        }
         [mBaseinfoList replaceObjectAtIndex:1 withObject:@{@"cellLabel":@"化学品", @"cellContent":ms}];
    }
    else if([SD.locationSummary isEqualToString:@""]){
         [mBaseinfoList replaceObjectAtIndex:1 withObject:@{@"cellLabel":@"化学品", @"cellContent":@"点击查看附近的化学品"}];
    }
    
    //加载事故性质和化学品
    mBaseinfoTableView = [weakSelf createDisasterBaseinfo];
    
    //加载事故详情
    mDetailScrollView = [weakSelf createDetailScrollView];
 
    
}

#pragma mark - 图片加载，线程

-(void)loadImageFile:(NSString *)imgId{
    __weak __typeof(self) weakSelf = self;
    NSLog(@"%@", imgId);
    
    [CustomHttp httpGetImage:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETFILE] params:@{@"disasterid":weakSelf.did, @"fileid":imgId} success:^(id responseObj) {
        NSLog(@"获取图片");
        [weakSelf saveImageCache:weakSelf.did imagedata:responseObj imagename:imgId];
        [[mDisasterImageViews objectForKey:imgId] setImage:[UIImage imageWithData:responseObj]];
        [[mDisasterLoadViews objectForKey:imgId] stopAnimating];
        NSLog(@"imgid = %@",imgId);
        //[mDisasterImageIds removeObjectAtIndex:[mDisasterImageIds indexOfObject:imgId]];
        
    } failure:nil];
}


/*
-(void)getImageFilesWithMultiThread{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < mDisasterImageIds.count; i++) {
        dispatch_async(globalQueue, ^{
            //                if (mShouldStopImageGet) {
            //                    NSLog(@"停止图片获取");
            //                    return;
            //                }
            //                else{
            //                    [self loadImageFile:mDisasterImageIds[i] imageIndex:i];
            //                }
            [self loadImageFile:mDisasterImageIds[i]];
        });
    }
}*/
#pragma mark - 顶部item

-(void)loadSubViewWithIndex:(NSInteger)index{
    CGRect frame = selectLightView.frame;
    frame.origin.x = index*SCREEN_WIDTH/4;
    
    [UIView animateWithDuration:0.4 animations:^{
        selectLightView.frame = frame;
    }];
    
    mBlockOffsetY = 0.0f;
    //清空，重新加载
    [mBlockViews removeAllObjects];
    [mBlockHeights removeAllObjects];
    [mBlockOffsets removeAllObjects];
    [mDetailScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubviewsToDetail:nil];
    if(index ==1){
        [self reloadImageViews];
    }
}
-(void)topItemClicked:(id)sender{
    UIButton *buttton = (UIButton *)sender ;
    
    if(currentIndex !=buttton.tag){
        currentIndex = buttton.tag ;
        [self loadSubViewWithIndex:currentIndex];
    }
}

-(void)reloadImageViews{
    NSArray *idArray = [mDisasterImageViews allKeys];
    for (NSString *idstr in idArray) {
        UIImageView *tmpImageView = [mDisasterImageViews objectForKey:idstr];
        if (tmpImageView.image == nil) {
            UIImage *tmpimg = [self readImageCache:self.did imagename:idstr];
            tmpImageView.image = tmpimg;
            if(tmpimg){
              UIActivityIndicatorView *actionView  = [mDisasterLoadViews valueForKey:idstr];
                [actionView stopAnimating];
            }
        }
    }
   
}
#pragma mark - 界面
-(UIButton *)createProcessingDisasterStartTime:(NSString *)str{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56.0f)];
    [button setEnabled:NO];
    [button setBackgroundColor:BLUE_COLOR];
    [button.titleLabel setFont:[UIFont systemFontOfSize:22.0f]];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button setImage:[UIImage imageNamed:@"icon-timecounts"] forState:UIControlStateNormal];
    //[button setTitle:str forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
    
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@-120);
        make.height.equalTo(@56);
    }];
    [button setUserInteractionEnabled:NO];
    return button;
}
-(UITableView *)createDisasterBaseinfo{
    //添加事故性质和化学品
    if (!mBaseinfoTableView) {
        UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, mStarttimeButton.frame.size.height, SCREEN_WIDTH, 44*mBaseinfoList.count+50) style:UITableViewStylePlain];
        tableview.delegate = self;
        tableview.dataSource = self;
        [tableview setScrollEnabled:NO];
        tableview.tableFooterView = [self tableviewFooterView];
        [tableview setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 0.000001)]];
        [self.view addSubview:tableview];
        
        [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(mStarttimeButton.frame.size.height));
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@(44*mBaseinfoList.count+50));
        }];
        return tableview;
    }
    else{
        [mBaseinfoTableView reloadData];
        return mBaseinfoTableView;
    }
}

-(UIView *)tableviewFooterView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    NSArray *titles = @[@"全部",@"图片",@"文字",@"数据"];
    NSInteger length = self.view.frame.size.width/titles.count;
    
    selectLightView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, length, 50)];
    selectLightView.backgroundColor = [UIColor darkGrayColor];
    [view addSubview:selectLightView];
    for (NSInteger i = 0; i<titles.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i*length, 0, length, 50)];
        button.tag = i ;
        [button addTarget:self action:@selector(topItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [view addSubview:button];

    }
    
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}
-(UIScrollView *)createDetailScrollView{
    if (!mDetailScrollView) {
        UIScrollView *scrollview =[[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                                                mBaseinfoTableView.frame.size.height + mStarttimeButton.frame.size.height + 10,
                                                                                self.view.frame.size.width,
                                                                                self.view.frame.size.height - mBaseinfoTableView.frame.size.height - mStarttimeButton.frame.size.height - 64 -10)];
        //[scrollview  setPagingEnabled:YES];
        [self.view addSubview:scrollview];
        
        [scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(mBaseinfoTableView.frame.size.height + mStarttimeButton.frame.size.height + 10));
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        [scrollview setShowsVerticalScrollIndicator:NO];
        scrollview.delegate = self;
        return scrollview;
    }
    else{
        return mDetailScrollView;
    }
}

-(UIButton *)createDetailScrollViewIndicator{
    if (!mDetailScrollViewIndicatorView) {
        UIButton *indicator;
        indicator = [[UIButton alloc]initWithFrame:CGRectMake(0, mDetailScrollView.frame.size.height-30-10 , 40, 30)];
        [indicator setBackgroundColor:[UIColor lightGrayColor]];
        [indicator setAlpha:0.5];
        
        UIView *indicatorView = [[UIView alloc]initWithFrame:CGRectMake(mDetailScrollView.frame.size.width - 40, mDetailScrollView.frame.origin.y, 40, mDetailScrollView.frame.size.height)];
        [indicatorView addSubview: indicator];
        [self.view addSubview:indicatorView];
        mDetailScrollViewIndicatorView = indicatorView;
        
        [indicator addTarget:self action:@selector(touchesMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        mDetailScrollViewIndicator = indicator;
    }
    else{
        [mDetailScrollViewIndicatorView setFrame:CGRectMake(mDetailScrollView.frame.size.width - 40, mDetailScrollView.frame.origin.y, 40, mDetailScrollView.frame.size.height)];
        CGFloat tmpY = mDetailScrollViewIndicator.frame.origin.y;
        [mDetailScrollViewIndicator setFrame:CGRectMake(mDetailScrollViewIndicator.frame.origin.x, tmpY, mDetailScrollViewIndicator.frame.size.width, mDetailScrollViewIndicator.frame.size.height)];
    }
    
    return mDetailScrollViewIndicator;
}

-(void)imageTap:(UILongPressGestureRecognizer *)longPressGesture{
    NSInteger index = longPressGesture.view.tag;
    NSString *imid = [_imageIDs objectAtIndex:index];
    [self showPhotoBrowser:imid];
}

-(void)showInputView{
    [self performSegueWithIdentifier:@"UploadDataSegue" sender:nil];
}
#pragma mark - scrollview
-(void)addSubviewsToDetail:(NSMutableArray<InputBatch*>*)newArr{
    __weak __typeof(self) weakSelf = self;
    CGFloat padding = 8;
    CGFloat margin = 10;
    CGFloat labelHeight = 18.0f;
    CGFloat indicatorWidth = 40;
    CGFloat blockWidth = mDetailScrollView.frame.size.width - margin*2 - indicatorWidth;
    CGFloat innerLabelWidth = blockWidth - padding*2;
    
    int startindex = 0;
    
    if (mBlockViews.count ==0) {
         newArr=SD.inputBatches;
    }
    else{
        startindex = (int)mBlockViews.count;
    }
    for (int i = 0 ; i < newArr.count; i++) {
        InputBatch* ib=newArr[i];
        
        if(currentIndex ==2){
            if(ib.type !=IT_TEXT){
                continue;
            }
        }else if (currentIndex ==1){
            if(ib.type !=IT_IMAGE){
                continue;
            }
        }
//        else if (currentIndex ==3){
//            if(ib.type !=IT_VOICE && ib.type !=IT_VIDEO){
//                continue;
//            }
//        }
    else if (currentIndex ==3){
            if(ib.type !=IT_DATA){
                continue;
            }
        }
        
        BOOL tmpIsSpec = NO;
        //时间，报告人
        UILabel *dateReporterLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, padding, innerLabelWidth, labelHeight)];
        [dateReporterLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [dateReporterLabel setText:[NSString stringWithFormat:@"%@, %@", [Common stringFromDate2:ib.time] , ib.staffName]];
        
        int detailOffsetY = 0;
        
        DisasterDetailCellView *detailView = [[DisasterDetailCellView alloc]init];
        
        for (int j = 0; j < [ib.inputs count]; j++) {
            Input* inp=ib.inputs[j];
            
            INPUT_TYPE tmptype = inp.type;
            
            NSString *key = nil;
            switch (tmptype) {
                case InputbatchTypeText:{
                    TextContent* tc=(TextContent*)inp.contents;
                    UITextView *textLabel = [CustomUtil setTextInLabel:tc.text labelW:innerLabelWidth labelPadding:padding];
                    [textLabel setFrame:CGRectMake(textLabel.frame.origin.x, detailOffsetY, textLabel.frame.size.width, textLabel.frame.size.height)];
                    detailOffsetY += textLabel.frame.size.height + padding;
                    
                    [detailView addSubview:textLabel];
                    [detailView.textLabels addObject:textLabel];
                }
                    break;
                case InputbatchTypeImage:{
                    UIImageView *imgView = [[UIImageView alloc]init];
                    UIActivityIndicatorView *loadingimgView = [[UIActivityIndicatorView alloc]init];
                    //image&loading
                    NSString *imgid = [[inp.uniqueID UUIDString] lowercaseString];
                    ImageContent* ic=(ImageContent*)inp.contents;
                    CGFloat imgWidth = ic.width;
                    CGFloat imgHeight = ic.height;
                    if(imgHeight>200 || imgWidth>innerLabelWidth){
                        imgHeight = 200;
                        imgWidth = ic.width*200/ic.height;
                    }
//                    if(imgWidth > innerLabelWidth){
//                        [imgView setFrame:CGRectMake(padding, detailOffsetY, innerLabelWidth, imgHeight * innerLabelWidth / imgWidth)];
//                        imgScaleSize = innerLabelWidth/imgWidth * 1.2;
//                    }
//                    else{
//                        [imgView setFrame:CGRectMake(padding, detailOffsetY, imgWidth, imgHeight)];
//                        imgScaleSize = imgWidth/imgWidth * 1.2;
//                    }
                    [imgView setFrame:CGRectMake(padding, detailOffsetY, imgWidth, imgHeight)];
                    imgScaleSize = 1.2;
                    //NSLog(@"current device width = %f, height = %f",innerLabelWidth, imgHeight * innerLabelWidth / imgWidth);
                    
                    [loadingimgView setCenter:CGPointMake(imgView.frame.size.width/2+15, imgView.frame.size.height/2+15)];
                    [loadingimgView setFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, imgView.frame.size.width, imgView.frame.size.height)];
                    [loadingimgView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    [loadingimgView startAnimating];
                    detailOffsetY += imgView.frame.size.height + margin;
                    detailView.tag = _imageIDs.count;
//                    UIButton *button = [[UIButton alloc]initWithFrame:imgView.bounds];
//                    [button addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchUpInside];
//                    button.tag = _imageIDs.count;
                   
                    UILongPressGestureRecognizer *longTap =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap:)];
                    longTap.minimumPressDuration = 1;
                   
                    
                    [_imageIDs addObject:imgid];
                    [mDisasterImageViews setObject:imgView forKey:imgid];
                    [mDisasterLoadViews setObject:loadingimgView forKey:imgid];
                    
                
                    [detailView addSubview:imgView];
                    [detailView addGestureRecognizer:longTap];
                    [detailView addSubview:loadingimgView];
                }
                    break;
                    
                case InputbatchTypeData:{
                    DataContent* dc=(DataContent*)inp.contents;
                    NSString *tmpsampletypestr = @"大气样本";
                   
                    if (dc.sampleType==1) {
                        tmpsampletypestr = @"水样本";
//                        [LocalTypeManager saveType:@"水" withDisasterId:self.did];
                    }if (dc.sampleType==2) {
                        tmpsampletypestr = @"土样本";
                        //                        [LocalTypeManager saveType:@"水" withDisasterId:self.did];
                    }
//                    NSString *typeStr = [LocalTypeManager getTypeStrWith:self.did];
//                    if(typeStr){
//                        [mBaseinfoList replaceObjectAtIndex:0 withObject:@{@"cellLabel":@"事故性质",@"cellContent":typeStr}];
//                    }
                    //leonlin
                    updataLocation.latitude = ib.latitude;
                    updataLocation.longitude = ib.longitude;
                    NSString *datastr;
                    if([dc.eqname length]!=0){
                        datastr = [NSString stringWithFormat:@"使用 %@ 测定 %@(%@) 的浓度为 %0.3f %@",
                                   dc.eqname,
                                   dc.chemname,
                                   tmpsampletypestr,
//                                   dc.metric,
                                   dc.value,
                                   dc.unit];
                    }else{
                        datastr = [NSString stringWithFormat:@"测定 %@(%@) 的浓度为 %0.3f %@",
                                   dc.chemname,
                                   tmpsampletypestr,
//                                   dc.metric,
                                   dc.value,
                                   dc.unit];
                    }
                    
                
                    
                    UITextView *dataLabel = [CustomUtil setTextInLabel:datastr labelW:innerLabelWidth labelPadding:padding];
                    [dataLabel setFrame:CGRectMake(dataLabel.frame.origin.x, detailOffsetY, dataLabel.frame.size.width, dataLabel.frame.size.height)];
                    detailOffsetY += dataLabel.frame.size.height + padding;
                    
                    
                    [detailView addSubview:dataLabel];
                    [detailView.dataLabels addObject:dataLabel];
                    
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showInputView)];
                    tap.numberOfTapsRequired = 1;
                    tap.numberOfTouchesRequired = 1;
                    [detailView addGestureRecognizer:tap];
                }
                    break;
                case InputbatchTypeVoice:{
                    //voice
                }
                    break;
                case InputbatchTypeSpecial:{
                    SpecialContent* sc=(SpecialContent*)inp.contents;
                    
                    //special
                    tmpIsSpec = YES;
                    SPECIALINPUT_TYPE spectype=sc.type;
                    
                    NSString *specStr = @"";
                    
                    switch (spectype) {
                        case ST_NATURE_IDENTIFIED:{
                            //事故性质

                            specStr = [NSString stringWithFormat:@"事故性质 %@",SD.natureName] ;
                            break;
                        }
                        case ST_LOCATION_CHANGED:
                        {
                            NSArray *tmplocarr = [sc.remarks componentsSeparatedByString:@","];
                            NSArray *tempArray1 = [tmplocarr[1] componentsSeparatedByString:@"_$"];
                            if(tmplocarr.count ==2){
                                showLocationInfo = YES ;
                            }
                            if(tempArray1.count==1){
                                key = [NSString stringWithFormat:@"%0.8f,%0.8f",[tmplocarr[0] floatValue] ,[tmplocarr[1] floatValue]];
                                NSString *addres = [addressDic valueForKey:key];
                          
                                if(addres ==nil){
                                    
                                    specStr = [NSString stringWithFormat:@"污染源位置已定\n坐标为：%0.05fE , %0.05fN \n",
                                           [tmplocarr[0] floatValue], [tmplocarr[1] floatValue]];
                                    [self getGeoCode:sc.remarks];
                                }else{
                                    specStr = [NSString stringWithFormat:@"污染源位置已定\n坐标为：%0.05fE , %0.05fN \n %@",
                                               [tmplocarr[0] floatValue], [tmplocarr[1] floatValue],addres];
                                }
                            }else{
                                
                                specStr = [NSString stringWithFormat:@"污染源位置已定\n坐标为：%0.05fE , %0.05fN \n %@",
                                           [tmplocarr[0] floatValue], [tempArray1[0] floatValue],tempArray1[1]];
                            }
                            
                        }
                            break;
                            
                        case ST_CHEMICAL_IDENTIFIED:{
                            specStr = [NSString stringWithFormat:@"事故相关化学品为：%@", sc.remarks];
                            [LocalChemicalsManager saveChemical:sc.remarks withDisasterId:self.did];
                            NSString *chemicals = [LocalChemicalsManager getChemicalsWithID:self.did];
                            if(chemicals){
                                [mBaseinfoList replaceObjectAtIndex:1 withObject:@{@"cellLabel":@"化学品", @"cellContent":chemicals}];
                            }
                            break;
                        }
                            
                        case ST_WIND_CONDITION_SET:
                        {
                            NSArray *tmplocarr = [sc.remarks componentsSeparatedByString:@","];
                            float speed=[tmplocarr[1] floatValue]*3.6f;
                            specStr = [NSString stringWithFormat:@"风向：%0.1f 度 %@ \n风速：%0.1f m/s", [tmplocarr[0] floatValue],[CustomUtil getWindType:tmplocarr[0]], speed];
                        }
                            break;
                        case ST_DETECTION_REPORT:{
                            specStr = [NSString stringWithFormat:@"生成了监测报告"];
                        }
                            
                            break;
                        case ST_DETECTION_SCHEME:
                        {
                            specStr = [NSString stringWithFormat:@"生成了监测方案"];
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    UITextView *tmplabel = [CustomUtil setTextInLabel:specStr labelW:innerLabelWidth labelPadding:padding];
                    detailOffsetY += tmplabel.frame.size.height;
                    
                    if(spectype == ST_DETECTION_SCHEME||spectype == ST_DETECTION_REPORT){
                        //监测报告调整样式并添加button
                        CGRect rect = tmplabel.frame;
                        UIButton *tmpbtn = [[UIButton alloc]initWithFrame:CGRectZero];
                        [tmpbtn setTitle:@"点击查看" forState:UIControlStateNormal];
                        [tmpbtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
                        [tmpbtn setFrame:CGRectMake(innerLabelWidth - 60, rect.origin.y, 60, rect.size.height)];
                        
                        [detailView addSubview:tmpbtn];
                        
                        if(spectype == ST_DETECTION_SCHEME){
                        objc_setAssociatedObject(tmpbtn, "dsid", sc.refid1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        [tmpbtn addTarget:self action:@selector(checkDetectionScheme:) forControlEvents:UIControlEventTouchUpInside];
                        }else{
                        objc_setAssociatedObject(tmpbtn, "dsid", sc.refid1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                           [tmpbtn addTarget:self action:@selector(checkDetectionReport:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        
                        rect.size.width = rect.size.width - 60;
                        [tmplabel setFrame:rect];
                    }
                    [detailView addSubview:tmplabel];
                    if(spectype == ST_LOCATION_CHANGED){
                        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, detailOffsetY)];
                        [button addTarget:self action:@selector(showMapViewAction) forControlEvents:UIControlEventTouchUpInside];
                        [detailView addSubview:button];
                    }
                    if(spectype == ST_LOCATION_CHANGED && key !=nil){
                        [addressLBDic setValue:tmplabel forKey:key ];
                    }
                    [detailView.specLabels addObject:tmplabel];
                   
                }
                    break;
                default:
                    break;
            }
            
            [detailView setFrame:CGRectMake(0, dateReporterLabel.frame.size.height + dateReporterLabel.frame.origin.y + padding, blockWidth, detailOffsetY)];
        }
        
        //添加内容外包装，缓存内容和内容高度
        if ([mBlockHeights count] > 0) {
            mBlockOffsetY += [[mBlockHeights lastObject] floatValue] + MARGIN;
        }
        [mBlockOffsets addObject:[NSNumber numberWithFloat:mBlockOffsetY]];
        
        UIView *blockView = [[UIView alloc]initWithFrame:CGRectMake(margin, mBlockOffsetY, blockWidth, detailView.frame.size.height + detailView.frame.origin.y + padding)];
        
        [blockView.layer setCornerRadius:8];
        [blockView.layer setMasksToBounds:YES];
        if (tmpIsSpec) {
            [blockView setBackgroundColor:LIGHTORANGE_COLOR];
        }
        else{
            [blockView setBackgroundColor:LIGHTGRAY_COLOR];
        }
       
        //内容添加到区域内
        [blockView addSubview:dateReporterLabel];
        [blockView addSubview:detailView];
        
        [mBlockViews addObject:blockView];
        [mBlockHeights addObject:[NSNumber numberWithFloat:blockView.frame.size.height]];
    }

    //leonlin
    [weakSelf addBlockViewsToScrollView:startindex];
}



-(void)updateImagesInSubViews{
    __weak __typeof(self) weakSelf = self;
    for (int i = 0; i < SD.inputBatches.count /*mDisasterDetailList.count*/; i++) {
        InputBatch* ib=SD.inputBatches[i];
        if (ib.type!=IT_SPECIAL){
            
            for (int j = 0,k = 0; j< ib.inputs.count; j++) {
                @autoreleasepool {
                    Input* inp=ib.inputs[j];
                    if (inp.type==IT_IMAGE) {
                        UIView *tmpBlock = mBlockViews[i];
                        DisasterDetailCellView *tmpCell = [[tmpBlock subviews] objectAtIndex:1];
                        
                        if([[tmpCell.imageViews[k] subviews] count] == 0
                           && [[tmpCell.loadingimgViews[k] subviews] count] > 0){
                            
                            NSString *imgid = [inp.uniqueID UUIDString];
                         
                            UIImage *img = [weakSelf readImageCache:weakSelf.did imagename:imgid];
                            if (img) {
                                UIActivityIndicatorView *tmpv = tmpCell.loadingimgViews[k];
                                
                                NSLog(@"%@",img);
                                UIImageView *imgView = tmpCell.imageViews[k];
                                [imgView setImage:img];
                                [tmpv stopAnimating];
                                
                                k++;
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)addBlockViewsToScrollView:(int)startindex{
    __weak __typeof(self) weakSelf = self;
    //右侧时间条添加
    CGFloat blockOffsetY = mBlockOffsetY;
    
   
    
    for (int i = startindex; i < mBlockViews.count; i++) {
        @autoreleasepool {
            UIView *blockview = (UIView *)mBlockViews[i];
            CGFloat timeviewOffsetX = blockview.frame.size.width + MARGIN*2;
            
            UIView *timeView = [[UIView alloc]initWithFrame:CGRectMake(timeviewOffsetX, blockview.frame.origin.y, 40, [mBlockHeights[i] floatValue] + MARGIN)];
            [timeView setBackgroundColor:LIGHTGRAY_COLOR];
            UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 2, timeView.frame.size.height)];
            [yLabel setBackgroundColor:BLUE_COLOR];
            UILabel *xLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 10, 1)];
            [xLabel setBackgroundColor:BLUE_COLOR];
            [timeView addSubview:xLabel];
            [timeView addSubview:yLabel];
            
            [mDetailScrollView addSubview:blockview];
            [mDetailScrollView addSubview:timeView];

        }
    }
    
    blockOffsetY += [[mBlockHeights lastObject] floatValue] + MARGIN;
    
    int scrollviewHeight = self.view.frame.size.height - mStarttimeButton.frame.size.height - mBaseinfoTableView.frame.size.height - 64 -10;
    //添加滚动指示
    if (blockOffsetY > scrollviewHeight) {
        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
        mScrollViewIndicatorFlag = NO;
//        mDetailScrollViewIndicator = [weakSelf createDetailScrollViewIndicator];
    }else{
        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollviewHeight)];
    }
    mBaseinfoTableView.frame = CGRectMake(0, mStarttimeButton.frame.size.height, SCREEN_WIDTH, 44*mBaseinfoList.count+50);
    mDetailScrollView.frame = CGRectMake(0, mBaseinfoTableView.frame.origin.y+mBaseinfoTableView.frame.size.height+10, SCREEN_WIDTH, SCREEN_HEIGHT-(mBaseinfoTableView.frame.origin.y+mBaseinfoTableView.frame.size.height)) ;
}


-(void)loadBlocks:(int)start endIndex:(int)end{
    for (int i = 0; i < mBlockViews.count; i++) {
        [mBlockViews[i] removeFromSuperview];
    }
    for (int i = start; i < end; i++) {
        @autoreleasepool {
            UIView *blockview = (UIView *)mBlockViews[i];
            [mDetailScrollView addSubview:blockview];
        }
    }
}

-(void)loadBlocks:(NSTimer *)timeinfo{
    NSLog(@"%@",[timeinfo userInfo]);
    
    int start = [[[timeinfo userInfo] objectForKey:@"start"] intValue];
    int end = [[[timeinfo userInfo] objectForKey:@"end"] intValue];
    
    for (int i = start; i <= end; i++) {
        @autoreleasepool {
            InputBatch* ib=SD.inputBatches[i];
            
            if(ib.type == IT_IMAGE){
                for (int j = 0; j < ib.inputs.count; j++) {
                    Input* inp=ib.inputs[j];
                    NSString* idstr=[[inp.uniqueID UUIDString] lowercaseString];
                    
                    UIImageView *tmpImageView = [mDisasterImageViews objectForKey:idstr];
                    if (tmpImageView.image == nil) {
                        UIImage *tmpimg = [self readImageCache:self.did imagename:idstr];
                        if (tmpimg) {
                            //NSLog(@"read image successfully");
                            [tmpImageView setImage:tmpimg];
                            [(UIActivityIndicatorView *)[mDisasterLoadViews objectForKey:idstr] stopAnimating];
                        }
                        else{
                            [self loadImageFile:idstr];
                        }
                    }
                }
            }
        }
    }
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [CustomHttp cancelFileRequest];
    [mGetImagesTimer invalidate];
    mGetImagesTimer = nil;
    
    if(scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= scrollView.contentSize.height-scrollView.frame.size.height){
        CGFloat p = scrollView.contentOffset.y*(scrollView.frame.size.height-mDetailScrollViewIndicator.frame.size.height-10)/(scrollView.contentSize.height-scrollView.frame.size.height);
        mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, p, 40, 30);
    }
    
    //延时获取图片
    CGFloat tmpy = scrollView.contentOffset.y;
    int y1 = 0;
    int y2 = 0;
    for (int i = 0; i < mBlockOffsets.count; i++) {
        if ([mBlockOffsets[i] floatValue] < tmpy) {
            y1 = i;
        }
        if([mBlockOffsets[i] floatValue] > mDetailScrollView.frame.size.height + tmpy && y2 == 0){
            y2 = i;
        }
    }
    
    if (y2 < y1) {
        y2 = (int)mBlockOffsets.count - 1;
    }
    
//    NSLog(@"current offset y = %f", tmpy);
//    NSLog(@"offset y + frame height = %f",mDetailScrollView.frame.size.height + tmpy);
//    NSLog(@"y1 = %d, y2 = %d", y1, y2);
    
    mGetImagesTimer = [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(loadBlocks:) userInfo:@{@"start":[NSNumber numberWithInt:y1],@"end":[NSNumber numberWithInt:y2]} repeats:NO];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([mDetailScrollView pointInside:[touch locationInView:mDetailScrollView] withEvent:nil]) {
        
        CGPoint point = [touch locationInView:mDetailScrollViewIndicatorView];
        CGPoint prepoint = [touch previousLocationInView:mDetailScrollViewIndicatorView];
        
        [self setScrollViewScrollingWithIndicator:point prePoint:prepoint];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([mDetailScrollView pointInside:[touch locationInView:mDetailScrollView] withEvent:nil]) {
        
        CGPoint point = [touch locationInView:mDetailScrollViewIndicatorView];
        CGPoint prepoint = [touch previousLocationInView:mDetailScrollViewIndicatorView];
        
        [self setScrollViewScrollingWithIndicator:point prePoint:prepoint];
    }
}
-(void)setScrollViewScrollingWithIndicator:(CGPoint)point prePoint:(CGPoint)prepoint{
    
    if (point.y < 0) {
        mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, 0, 40, 30);
        [mDetailScrollView setContentOffset:CGPointMake(0, 0)];
    }
    else if (point.y > mDetailScrollViewIndicatorView.frame.size.height-mDetailScrollViewIndicator.frame.size.height - 10){
        mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, mDetailScrollViewIndicatorView.frame.size.height- mDetailScrollViewIndicator.frame.size.height - 10, 40, 30);
        [mDetailScrollView setContentOffset:CGPointMake(0, mDetailScrollView.contentSize.height - mDetailScrollView.frame.size.height)];
    }
    else{
        mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, mDetailScrollViewIndicator.frame.origin.y + point.y - prepoint.y, 40, 30);
        [mDetailScrollView setContentOffset:CGPointMake(0, (mDetailScrollView.contentSize.height - mDetailScrollView.frame.size.height)*point.y/(mDetailScrollView.frame.size.height - mDetailScrollViewIndicator.frame.size.height))];
    }
    
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mBaseinfoList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"BaseinfoTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //leonlin
    
    NSString *title = mBaseinfoList[indexPath.row][@"cellLabel"];
    NSString *subtitle = mBaseinfoList[indexPath.row][@"cellContent"];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@   %@",title,subtitle]];
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor darkGrayColor]
                          range:NSMakeRange(title.length+3, subtitle.length)];
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor blackColor]
                          range:NSMakeRange(0, title.length)];
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:16]
                          range:NSMakeRange(0, title.length)];
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:14]
                          range:NSMakeRange(title.length+3, subtitle.length)];
    cell.textLabel.attributedText = attributedStr;
    if ([mBaseinfoList[indexPath.row][@"cellLabel"] isEqualToString:@"化学品"]) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        //跳转到化学品页面
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:self.did forKey:@"id"];
//        [dict setObject:mChemicalsList forKey:@"chemicallist"];
        
        [self performSegueWithIdentifier:@"DisasterChemicalSegue" sender:dict];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - 页面跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DisasterChemicalSegue"]) {
        DisasterChemicalViewController *targetVC = segue.destinationViewController;
        targetVC.disasterId = sender[@"id"];
        targetVC.chemicalList = sender[@"chemicallist"];
        targetVC.disasterLocation = SD.locationSummary;
        
    }
    else if([segue.identifier isEqualToString:@"UploadSegue"]){
        //到上传信息页面
        UploadViewController *targetVC = segue.destinationViewController;
        targetVC.did = self.did;
        targetVC.sid = self.did;
        targetVC.mChemicalsList = mChemicalsList;
        targetVC.locationStr = locationStr;
    } else if ([segue.identifier isEqualToString:@"DataLocListSegue"]) {
 
        DisasterMapViewController  *targetVC = segue.destinationViewController;
        targetVC.disasterId = self.did;
        targetVC.locationStr = locationStr;
        
    }
    else if([segue.identifier isEqualToString:@"DetectionSchemeSegue"]){
        DetectionSchemeViewController *targetVC = segue.destinationViewController;
        targetVC.dsid = sender[@"dsid"];
        targetVC.did = self.did;
        targetVC.isReport = [sender[@"type"] boolValue];
    }
    else  if ([segue.identifier isEqualToString:@"UploadDataSegue"]) {
        UploadDataViewController *targetVC = segue.destinationViewController;
        targetVC.did = self.did;
        targetVC.mLocation = updataLocation;
    }
}

#pragma mark - 计时
-(void)countDate:(NSTimer *)t{
    NSDate* startdate=[t userInfo];
    
    NSTimeInterval tmpdate = [[NSDate date] timeIntervalSinceDate:startdate];
    int timecounts= tmpdate;
    int day = floor(timecounts/60/60/24);
    int hour = floor((timecounts-(day*24*60*60))/60/60);
    int mins = floor((timecounts-(day*24*60*60)-hour*60*60)/60);
    int secs = timecounts - day*24*60*60 - hour*60*60 - mins*60;
    NSString *daystr;
    NSString *hourstr;
    NSString *minsstr;
    NSString *secsstr;
    if (day != 0) {
        daystr = [NSString stringWithFormat:@"%d/",day];
    }
    else{
        daystr = @"";
    }
    hour = day*24 + hour;
    if(hour == 0){
        hourstr = @"";
    }
    else{
        hourstr = [NSString stringWithFormat:@"%d小时",hour];
    }
    if (mins<10) {
        minsstr = [NSString stringWithFormat:@"0%d分钟",mins];
    }
    else{
        minsstr = [NSString stringWithFormat:@"%d分钟",mins];
    }
    if (secs<10) {
        secsstr = [NSString stringWithFormat:@"0%d秒",secs];
    }
    else{
        secsstr = [NSString stringWithFormat:@"%d秒",secs];
    }
    
    [mStarttimeButton setTitle:[NSString stringWithFormat:@"%@%@%@", hourstr, minsstr, secsstr] forState:UIControlStateNormal];
}


-(NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}


#pragma mark - Retrieve data relted to disaster. i.e. inputbatches and datalocs
-(void)startToGetRelatedData{
    if (!mGetRelatedDataTime) {
        mGetRelatedDataTime = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(intervalGetRelatedData) userInfo:self repeats:YES];
    }
}

-(void)intervalGetRelatedData{
    __weak __typeof(self) weakSelf = self;

   
    [SD retrieveInputBatchesFromServerWithNewItems:^(NSMutableArray<InputBatch*>* newItems) {
        
        [weakSelf createDisasterDetailView];
        [weakSelf addSubviewsToDetail:newItems];
        if (!mIsNotInit) {
            if(mDetailScrollView.contentSize.height > mDetailScrollView.frame.size.height){
                [mDetailScrollView setContentOffset:CGPointMake(0, mDetailScrollView.contentSize.height - mDetailScrollView.frame.size.height)];
            }
            mIsNotInit = YES;
        }
        
    }];
    
    // tell disaster to load datalocs only in this controller
    // no callback is passed as no need to process the data as datalocs are not displayed
    [SD retrieveDataLocsFromServerWithNewItems:nil andOldItems:nil];
}


#pragma mark - 图片缓存和获取
-(void)saveImageCache:(NSString *)disasterid imagedata:(NSData *)imgdata imagename:(NSString *)imagekey{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *forlderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@",disasterid]];
    BOOL isdir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:forlderpath isDirectory:&isdir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:forlderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *imagepath = [forlderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", imagekey]];
    //NSLog(@"%@", imagepath);
    UIImage *img = [UIImage imageWithData:imgdata];
    
    //NSLog(@"img width = %f, img height = %f", img.size.width, img.size.height);
    
    NSData *scaleimgdata = UIImageJPEGRepresentation([CustomUtil scaleImage:img toScale:imgScaleSize], 0.75f);
    
    if ([scaleimgdata writeToFile:imagepath options:NSAtomicWrite error:nil]) {
        NSLog(@"写入成功");
    }
}
-(UIImage *)readImageCache:(NSString *)disasterid imagename:(NSString *)imagekey{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *imagepath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@/%@.jpg",disasterid, imagekey]];
    NSData *imgd = [NSData dataWithContentsOfFile:imagepath];
    UIImage *img = [UIImage imageWithData:imgd];
    return img;
}

#pragma mark - 跳转到对应监测方案显示页面
-(void)checkDetectionScheme:(UIButton *)btn{
    id tmpstr = objc_getAssociatedObject(btn, "dsid");
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[tmpstr,@"0"] forKeys:@[@"dsid",@"type"]];
    [self performSegueWithIdentifier:@"DetectionSchemeSegue" sender:dic];
}

-(void)checkDetectionReport:(UIButton *)btn{
    id tmpstr = objc_getAssociatedObject(btn, "dsid");
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[tmpstr,@"1"] forKeys:@[@"dsid",@"type"]];
    [self performSegueWithIdentifier:@"DetectionSchemeSegue" sender:dic];
}

#pragma mark - getter

- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

- (MWPhotoBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _photoBrowser.displayActionButton = YES;
        _photoBrowser.displayNavArrows = YES;
        _photoBrowser.displaySelectionButtons = NO;
        _photoBrowser.alwaysShowControls = NO;
        _photoBrowser.zoomPhotosToFill = YES;
        _photoBrowser.enableGrid = NO;
        _photoBrowser.startOnGrid = NO;
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.photoBrowser];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self.photoBrowser reloadData];
    return _photoNavigationController;
}

#pragma mark - MWPhotoBrowserDelegate
- (void)showPhotoBrowser:(NSString *)imid{
    if(!showPic){
        UIImage *image = [self readImageCache:self.did imagename:imid];
        MWPhoto *photo = [MWPhoto photoWithImage:image];
        self.photos = [NSMutableArray arrayWithArray:@[photo]];
      
        [self.navigationController presentViewController:self.photoNavigationController animated:YES completion:nil];
        showPic = YES ;
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}


#pragma mark -经纬度反编译
-(void)getGeoCode:(NSString *)remark{
    NSArray *items = [remark componentsSeparatedByString:@","];
    CLLocationCoordinate2D locationPoint = {[items[1] floatValue],[items[0] floatValue]};
    BMKReverseGeoCodeOption *reverseGCO = [[BMKReverseGeoCodeOption alloc]init];
    reverseGCO.reverseGeoPoint = locationPoint;
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    geoCodeSearch.delegate = self ;
    BOOL flag = [geoCodeSearch reverseGeoCode:reverseGCO];
    if(flag){
        NSLog(@"地理反检索成功");
    }else{
        NSLog(@"地理反检索失败");
    }
}

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if(error ==0){
        NSLog(@"%@",result.addressDetail.province);
//        address = result.address;
        NSString *keyStr =[NSString stringWithFormat:@"%0.8f,%0.8f",result.location.longitude ,result.location.latitude];
        [addressDic setValue:result.address forKey:keyStr];
        XLabel *tempLB =[addressLBDic valueForKey:keyStr];
        NSString *specStr =  tempLB.text ;
        tempLB.text = [NSString stringWithFormat:@"%@ %@",specStr,result.address];

    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak  DisasterDetailViewController *weakSelf = self ;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //计算旋转之后的宽度并赋值
        CGSize screen = [UIScreen mainScreen].bounds.size;
        //界面处理逻辑

        //动画播放完成之后
        if(screen.width > screen.height){
            NSLog(@"横屏");
          
        }else{
            NSLog(@"竖屏");
        }
        [self loadSubViewWithIndex:currentIndex];
        mBaseinfoTableView.tableFooterView = [weakSelf tableviewFooterView];
        NSInteger height =  mDetailScrollView.contentSize.height;
        mDetailScrollView.contentSize  =CGSizeMake(SCREEN_WIDTH, height);
        
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"动画播放完之后处理");
    }];
}
@end
