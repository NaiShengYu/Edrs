//
//  DisasterDetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DisasterDetailViewController.h"

@interface DisasterDetailViewController ()

@end

@implementation DisasterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mIsBaseinfoGetted = NO;
    mIsChemicalsGetted = NO;
    mIsInputsGetted = NO;
    mIsNotInit = NO;
    mShouldStopImageGet = NO;
    
    mDisasterNatureIdentifier = @"";
    mDisasterBaseinfo = [[NSMutableDictionary alloc]init];
    mBaseinfoList = [[NSMutableArray alloc]init];
    mChemicalsList = [[NSMutableArray alloc]init];
    mDisasterImages = [[NSMutableDictionary alloc]init];
    mDisasterImageIds = [[NSMutableArray alloc]init];
    mBlockViews = [[NSMutableArray alloc]init];
    mDisasterDetailList = [self readDisasterInputbatches:self.did];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    //获取数据
    [self getDisasterDetailData];
    //获取数据获得状态，此处为并发，获取到全部数据以前界面不呈现
    mGetDataTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(checkforDataGetted) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated{
    //取消定时器
    [mGetInputbatchesTimer invalidate];
    mGetInputbatchesTimer = nil;
    //取消还未完成的图片获取
    mShouldStopImageGet = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    if (mIsNotInit) {
        [self intervalGetInputbatches];
        [self startToGetInputbatches];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
}

-(void)getDisasterDetailData{
    //获取数据
    
    //详情
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_DETAIL] params:@{@"disasterid":self.did} success:^(id responseObj) {
        NSLog(@"get disaster detail successfully, response = %@", responseObj);
        mDisasterBaseinfo = responseObj;
        mIsBaseinfoGetted = YES;
        
        //当前事故发生中，加载计时条
        if ([mDisasterBaseinfo[@"end_time"] isEqualToString:ENDTIME]) {
            mStarttimeButton = [self createProcessingDisasterStartTime:mDisasterBaseinfo[@"start_time"]];
            [self countForDisaster:mDisasterBaseinfo[@"start_time"]];
        }
        else{
            //不显示计时条，取消上传
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        
        
        //时间线事件
        [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP , EDRSHTTP_GETDISASTER_DETAIL_INPUTS] params:@{@"time":mDisasterBaseinfo[@"start_time"], @"disasterid":self.did} success:^(id responseObj) {
            NSLog(@"get disaster detail inputs successfully , response = %@", responseObj);
            
            //记录当前时间
            mLastTime = [mDisasterDetailList lastObject][@"time"];
            [self startToGetInputbatches];
            
            for (int i = 0 ; i < [responseObj count]; i++) {
                [mDisasterDetailList addObject:responseObj[i]];
                //处理返回数据，抽取当前事故性质
                if([responseObj[i][@"type"] intValue] == InputbatchTypeSpecial){
                    if([responseObj[i][@"details"][0][@"type"] intValue] == InputbatchTypeSpecial){
                        if ([responseObj[i][@"details"][0][@"contents"][@"specialtype"] intValue] == SpecialInputTypeDisasterNatureIdentified) {
                            mDisasterNatureIdentifier = responseObj[i][@"details"][0][@"contents"][@"remarks"];
                        }
                    }
                }
                //处理返回数据，抽取当前化学品列表
                if ([responseObj[i][@"type"] intValue] != InputbatchTypeSpecial) {
                    for (int j = 0; j < [responseObj[i][@"details"] count]; j++) {
                        if ([responseObj[i][@"details"][j][@"type"] intValue] == InputbatchTypeData) {
                            NSMutableDictionary *tmpd = [[NSMutableDictionary alloc]init];
                            [tmpd setObject:responseObj[i][@"details"][j][@"contents"][@"chemical"] forKey:@"cid"];
                            [tmpd setObject:responseObj[i][@"details"][j][@"contents"][@"chemicalname"] forKey:@"cname"];
                            [mChemicalsList addObject:tmpd];
                        }
                    }
                }
            }
            
//            本地测试而已。。。
//            NSMutableArray *tmpArr = [CustomHttp getDataFromFile:@"disasterdetail"];
//            for (int i = 0; i < [tmpArr count]; i++) {
//                [mDisasterDetailList addObject:tmpArr[i]];
//            }
//            NSLog(@"mDisasterDetailList = %@", mDisasterDetailList);
            
            mIsChemicalsGetted = YES;
            mIsInputsGetted = YES;
            mIsNotInit = YES;
            //[self createDisasterDetailView];
            
        } failure:^(NSError *err) {
            NSLog(@"fail to get disaster detail inputs, error = %@", err);
            
            mIsInputsGetted = NO;
        }];
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster detail , error = %@", err);
        mIsBaseinfoGetted = NO;
    }];
}

-(void)createDisasterDetailView{
    //事故性质数据获取
    if (!mDisasterBaseinfo[@"naturename"]) {
        if ([mDisasterBaseinfo[@"nature"] intValue] == 0) {;
            [mBaseinfoList addObject:@{@"cellLabel":@"事故性质",@"cellContent":@"大气事故"}];
        }
        else if([mDisasterBaseinfo[@"nature"] intValue] == 1){
            [mBaseinfoList addObject:@{@"cellLabel":@"事故性质",@"cellContent":@"水事故"}];
        }
        else{
            
        }
    }
    else{
        //当前事故性质在inputbatch中进行了重写
        if([mDisasterNatureIdentifier isEqualToString:@"0"]){
            [mBaseinfoList addObject:@{@"cellLabel":@"事故性质",@"cellContent":@"大气事故"}];
        }
        else if([mDisasterNatureIdentifier isEqualToString:@"1"]){
            [mBaseinfoList addObject:@{@"cellLabel":@"事故性质",@"cellContent":@"水事故"}];
        }
        else{
            
        }
    }
    
    //化学品数据获取
    if (mChemicalsList.count > 0) {
        [mBaseinfoList addObject:@{@"cellLabel":@"化学品", @"cellContent":mChemicalsList[0][@"cname"]}];
    }
    
    //加载事故性质和化学品
    mBaseinfoTableView = [self createDisasterBaseinfo];
    
    //加载事故详情
    mDetailScrollView = [self createDetailScrollView];
    [self addSubviewsToDetail];
    if(mDetailScrollView.contentSize.height > mDetailScrollView.frame.size.height){
        [mDetailScrollView setContentOffset:CGPointMake(0, mDetailScrollView.contentSize.height - mDetailScrollView.frame.size.height)];    //滚动到底部
    }
}

#pragma mark - 图片加载，线程
-(void)loadImageFile:(NSString *)imgId{
    NSLog(@"%@", imgId);
    //获取对应uiimage 添加到对象数组中
    if(![[mDisasterImages objectForKey:imgId] isKindOfClass:[UIImage class]]){
        //网络交互，获取对应图片
        [CustomHttp httpGetImage:nil params:nil success:^(id responseObj) {
            UIImage *img = [UIImage imageWithData:responseObj];
            [mDisasterImages setObject:img forKey:imgId];
            [self performSelectorOnMainThread:@selector(updateImagesInSubViews) withObject:nil waitUntilDone:YES];
        } failure:nil];
    }
}

-(void)getImageFilesWithMultiThread{
    //开启多线程获取图片
//    for(int i = 0; i< mDisasterImageIds.count; i++){
//        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadImageFile:) object:mDisasterImageIds[i]];
//        [thread start];
//    }
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < mDisasterImageIds.count; i++) {
        if(![[mDisasterImages objectForKey:mDisasterImageIds[i]] isKindOfClass:[UIImage class]]){
            dispatch_async(globalQueue, ^{
                if (mShouldStopImageGet) {
                    NSLog(@"停止图片获取");
                    return;
                }
                else{
                    [self loadImageFile:mDisasterImageIds[i]];
                }
            });
        }
    }
}

-(void)checkforDataGetted{
    if (mIsBaseinfoGetted == YES && mIsChemicalsGetted == YES && mIsInputsGetted == YES) {
        [mGetDataTimer invalidate]; //停止当前计时器
        [self createDisasterDetailView];
        NSLog(@"开始加载页面");
    }
}

#pragma mark - 界面
-(UIButton *)createProcessingDisasterStartTime:(NSString *)str{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 56.0f)];
    [button setEnabled:NO];
    [button setBackgroundColor:BLUE_COLOR];
    [button.titleLabel setFont:[UIFont systemFontOfSize:22.0f]];
    [button setImage:[UIImage imageNamed:@"icon-time"] forState:UIControlStateNormal];
    [button setTitle:str forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self.view addSubview:button];
    [button setUserInteractionEnabled:NO];
    return button;
}
-(UITableView *)createDisasterBaseinfo{
    //添加事故性质和化学品
    if (!mBaseinfoTableView) {
        UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, mStarttimeButton.frame.size.height + 64, self.view.frame.size.width, 44*mBaseinfoList.count) style:UITableViewStyleGrouped];
        tableview.delegate = self;
        tableview.dataSource = self;
        [tableview setScrollEnabled:NO];
        [tableview setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 0.000001)]];
        [self.view addSubview:tableview];
        return tableview;
    }
    else{
        [mBaseinfoTableView reloadData];
        return mBaseinfoTableView;
    }
}
-(UIScrollView *)createDetailScrollView{
    if (!mDetailScrollView) {
        UIScrollView *scrollview =[[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                                                mBaseinfoTableView.frame.size.height + mStarttimeButton.frame.size.height + 64 + 10,
                                                                                self.view.frame.size.width,
                                                                                self.view.frame.size.height - mBaseinfoTableView.frame.size.height - mStarttimeButton.frame.size.height - 64 -10)];
        [self.view addSubview:scrollview];
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


#pragma mark - scrollview
-(void)addSubviewsToDetail{
    
    CGFloat padding = 8;
    CGFloat margin = 10;
    CGFloat labelHeight = 18.0f;
    CGFloat blockOffsetY = 0;
    CGFloat indicatorWidth = 40;
    CGFloat blockWidth = mDetailScrollView.frame.size.width - margin*2 - indicatorWidth;
    CGFloat innerLabelWidth = blockWidth - padding*2;
    
    //清空，重新加载
    [mBlockViews removeAllObjects];
    while ([[mDetailScrollView subviews] lastObject]) {
        [[[mDetailScrollView subviews] lastObject] removeFromSuperview];
    }
    
    //添加数据到滚动区域中
    for (int i = 0 ; i < mDisasterDetailList.count; i++) {
        BOOL tmpIsSpec = NO;
        //时间，报告人
        UILabel *dateReporterLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, padding, innerLabelWidth, labelHeight)];
        [dateReporterLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [dateReporterLabel setText:[NSString stringWithFormat:@"%@,%@", [CustomUtil getFormatedDateString:mDisasterDetailList[i][@"time"]], mDisasterDetailList[i][@"users"]]];
        
        //坐标写入
        if (mDisasterLocation.latitude == 0 || mDisasterLocation.longitude == 0) {
            NSLog(@"当前事故坐标未定义,请赋值");
            if(![mDisasterDetailList[i][@"lat"] isEqual:[NSNull null]])
                mDisasterLocation.latitude = [mDisasterDetailList[i][@"lat"] intValue];
            if(![mDisasterDetailList[i][@"lng"] isEqual:[NSNull null]])
                mDisasterLocation.longitude = [mDisasterDetailList[i][@"lng"] intValue];
        }
        
        NSMutableArray *detailArray = [[NSMutableArray alloc]initWithArray:mDisasterDetailList[i][@"details"]];
        //UIView *detailView = [[UIView alloc]init];
        int detailOffsetY = padding;
        
        DisasterDetailCellView *detailView = [[DisasterDetailCellView alloc]init];
        
        UIActivityIndicatorView *emptyView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [emptyView setCenter:CGPointMake(22, 22)];
//        [emptyView setFrame:CGRectMake(innerLabelWidth/2, 0, emptyView.frame.size.width, emptyView.frame.size.height)];
        
        for (int j = 0; j < [detailArray count]; j++) {
            int tmptype = [detailArray[0][@"type"] intValue];
            
//            UILabel *textLabel;
//            UILabel *dataLabel;
//            UIView *specView;
//            UIImageView *imgView;
//            UIActivityIndicatorView *loadingimgView;
            
            switch (tmptype) {
                case InputbatchTypeText:{
                    //text
                    UILabel *textLabel = [CustomUtil setTextInLabel:detailArray[j][@"contents"][@"text"] labelW:innerLabelWidth labelPadding:padding];
                    [textLabel setFrame:CGRectMake(textLabel.frame.origin.x, detailOffsetY, textLabel.frame.size.width, LINE_HEIGHT/2)];
                    detailOffsetY += textLabel.frame.size.height;
                    
                    [detailView addSubview:textLabel];
                    [detailView.textLabels addObject:textLabel];
                }
                    break;
                case InputbatchTypeImage:{
                    UIImageView *imgView = [[UIImageView alloc]init];
                    UIActivityIndicatorView *loadingimgView = [[UIActivityIndicatorView alloc]init];
                    //image&loading
                    NSString *imgid = detailArray[j][@"id"];
                    CGFloat imgWidth = [detailArray[j][@"contents"][@"width"] floatValue];
                    CGFloat imgHeight = [detailArray[j][@"contents"][@"height"] floatValue];
                    [mDisasterImageIds addObject:imgid];
                    
                    if(imgWidth > innerLabelWidth){
                        [imgView setFrame:CGRectMake(padding, detailOffsetY, innerLabelWidth, imgHeight * innerLabelWidth / imgWidth)];
                    }
                    else{
                        [imgView setFrame:CGRectMake(padding, detailOffsetY, imgWidth, imgHeight)];
                    }
                    [loadingimgView setCenter:CGPointMake(imgView.frame.size.width/2+15, imgView.frame.size.height/2+15)];
                    [mDisasterImages setObject:loadingimgView forKey:imgid];
                    [loadingimgView startAnimating];
                    detailOffsetY += imgView.frame.size.height;
                    
                    if ([[mDisasterImages objectForKey:imgid] isKindOfClass:[UIImage class]]) {
                        UIImage *img = [mDisasterImages objectForKey:imgid];
                        [imgView setImage:img];
                        [loadingimgView stopAnimating];
                    }
                    
                    [detailView addSubview:imgView];
                    [detailView.imageViews addObject:imgView];
                    
                    [detailView addSubview:loadingimgView];
                    [detailView.loadingimgViews addObject:loadingimgView];
//                    if ([mDisasterImages objectForKey:imgid]) {
//                        UIImage *img = [mDisasterImages objectForKey:imgid];
//                        if(img.size.width > innerLabelWidth){
//                            imgView = [[UIImageView alloc]initWithFrame:CGRectMake(padding, detailOffsetY, innerLabelWidth, img.size.height * innerLabelWidth / img.size.width)];
//                        }
//                        else{
//                            imgView = [[UIImageView alloc]initWithFrame:CGRectMake(padding, detailOffsetY, img.size.width, img.size.height)];
//                        }
//                        [imgView setImage:img];
//                        detailOffsetY += imgView.frame.size.height;
//                    }
//                    else{
//                        
//                    }
                    
//                    NSURL *imgurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",EDRSHTTP,detailArray[j][@"contents"][@"path"]]];
//                    NSData *imgdata = [NSData dataWithContentsOfURL:imgurl];
//                    UIImage *img = [UIImage imageWithData:imgdata];
//                    if(img.size.width > innerLabelWidth){
//                        imgView = [[UIImageView alloc]initWithFrame:CGRectMake(padding, detailOffsetY, innerLabelWidth, img.size.height * innerLabelWidth / img.size.width)];
//                    }
//                    else{
//                        imgView = [[UIImageView alloc]initWithFrame:CGRectMake(padding, detailOffsetY, img.size.width, img.size.height)];
//                    }
//                    NSLog(@"current disasterid = %@", self.did);
//                    NSLog(@"current fileid = %@", detailArray[j][@"id"]);
//                    [imgView setImage:img];
//                    detailOffsetY += imgView.frame.size.height;
                }
                    break;
                case InputbatchTypeData:{
                    //data
                    NSString *datastr = [NSString stringWithFormat:@"使用%@测定%@的%@为%f%@",
                                         detailArray[j][@"contents"][@"equipmentname"],
                                         detailArray[j][@"contents"][@"chemicalname"],
                                         detailArray[j][@"contents"][@"metric"],
                                         [detailArray[j][@"contents"][@"value"] floatValue],
                                         detailArray[j][@"contents"][@"unit"]];
                    UILabel *dataLabel = [CustomUtil setTextInLabel:datastr labelW:innerLabelWidth labelPadding:padding];
                    [dataLabel setFrame:CGRectMake(dataLabel.frame.origin.x, dataLabel.frame.origin.y, dataLabel.frame.size.width, LINE_HEIGHT/2)];
                    detailOffsetY += dataLabel.frame.size.height;
                    
                    [detailView addSubview:dataLabel];
                    [detailView.dataLabels addObject:dataLabel];
                }
                    break;
                case InputbatchTypeVoice:{
                    //voice
                }
                    break;
                case InputbatchTypeSpecial:{
                    //special
                    tmpIsSpec = YES;
                    int spectype = [detailArray[j][@"contents"][@"specialtype"] intValue];
                    NSString *specStr = @"";
                    if (spectype == SpecialInputTypeDisasterNatureIdentified) {
                        //事故性质
                        if([detailArray[j][@"contents"][@"remarks"] isEqualToString:@"0"]){
                            specStr = [NSString stringWithFormat:@"事故性质定义为：大气事故"];
                        }
                        else if([detailArray[j][@"contents"][@"remarks"] isEqualToString:@"1"]){
                            specStr = [NSString stringWithFormat:@"事故性质定义为：水事故"];
                        }
                        else{
                            
                        }
                    }
                    else if (spectype == SpecialInputTypeDisasterStartTimeIdentified){
                        //开始时间
                    }
                    else if (spectype == SpecialInputTypeDisasterNamedChanged){
                        //事故名称
                    }
                    else if(spectype == SpecialInputTypeDisasterLocationPinpointed){
                        //事故位置
                        specStr = [NSString stringWithFormat:@"污染源已定位：%@",detailArray[j][@"contents"][@"remarks"]];
                    }
                    else if(spectype == SpecialInputTypeDisasterChemicalIdentified){
                        //事故涉及化学品
                        specStr = [NSString stringWithFormat:@"事故相关化学品为：%@",detailArray[j][@"contents"][@"remarks"]];
                    }
                    else if(spectype == SpecialInputTypeSimulationResultObtained){
                        //模拟结果
                    }
                    else if(spectype == SpecialInputTypeHealthRiskAssessed){
                        //健康评估
                    }
                    else{
                        
                    }
                    
                    UIView *specView = [[UIView alloc]initWithFrame:CGRectMake(padding, detailOffsetY, innerLabelWidth, labelHeight)];
                    //                        UILabel *tmplabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, innerLabelWidth, labelHeight)];
                    //                        [tmplabel setTextAlignment:NSTextAlignmentRight];
                    //                        [tmplabel setFont:[UIFont systemFontOfSize:14.0f]];
                    //                        [tmplabel setText:detailArray[j][@"contents"][@"remarks"]];
                    UILabel *tmplabel = [CustomUtil setTextInLabel:specStr labelW:innerLabelWidth labelPadding:padding];
                    [specView addSubview:tmplabel];
                    detailOffsetY += specView.frame.size.height;
                    
                    [detailView addSubview:tmplabel];
                    [detailView.specLabels addObject:tmplabel];
                }
                    break;
                default:
                    break;
            }
            
            [detailView setFrame:CGRectMake(0, dateReporterLabel.frame.size.height + dateReporterLabel.frame.origin.y + padding, innerLabelWidth, detailOffsetY)];
            
//            detailView = [[UIView alloc]initWithFrame:CGRectMake(0, dateReporterLabel.frame.size.height + dateReporterLabel.frame.origin.y + padding, innerLabelWidth, detailOffsetY)];
//            [detailView addSubview:textLabel];
//            [detailView addSubview:dataLabel];
//            [detailView addSubview:specView];
//            [detailView addSubview:imgView];
//            [detailView addSubview:loadingimgView];
        }
        
        //添加内容外包装
        UIView *blockView = [[UIView alloc]initWithFrame:CGRectMake(margin, blockOffsetY, blockWidth, detailView.frame.size.height + detailView.frame.origin.y + padding)];
       
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
        
        //时间指示条
//        CGFloat timeviewOffsetX = blockView.frame.size.width + margin*2;
//        UIView *timeView = [[UIView alloc]initWithFrame:CGRectMake(timeviewOffsetX, blockOffsetY, 40, blockView.frame.size.height + margin)];
//        [timeView setBackgroundColor:LIGHTGRAY_COLOR];
//        UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 2, timeView.frame.size.height)];
//        [yLabel setBackgroundColor:BLUE_COLOR];
//        UILabel *xLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 10, 1)];
//        [xLabel setBackgroundColor:BLUE_COLOR];
//        [timeView addSubview:xLabel];
//        [timeView addSubview:yLabel];
//        
//        //偏移值更新
//        blockOffsetY += blockView.frame.size.height + margin;
//        NSLog(@"%f",blockView.frame.size.height);
//        [mDetailScrollView addSubview:blockView];
//        [mDetailScrollView addSubview:timeView];
    }
    
//    int scrollviewHeight = self.view.frame.size.height - mStarttimeButton.frame.size.height - mBaseinfoTableView.frame.size.height - 64;
//    if (blockOffsetY > scrollviewHeight) {
//        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
//        mScrollViewIndicatorFlag = NO;
//        mDetailScrollViewIndicator = [self createDetailScrollViewIndicator];
//    }else{
//        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollviewHeight)];
//    }
    [self addBlockViewsToScrollView];
    
    //循环开始加载图片
    [self getImageFilesWithMultiThread];
}
-(void)updateImagesInSubViews{
    
    for (int i = 0; i < mDisasterDetailList.count; i++) {
        NSMutableDictionary *tmpDict = mDisasterDetailList[i];
        if ([tmpDict[@"type"] intValue] != InputbatchTypeSpecial) {
            
            for (int j = 0,k = 0; j< [tmpDict[@"details"] count]; j++) {
                NSMutableDictionary *tmpDetail = tmpDict[@"details"][j];
                if ([tmpDetail[@"type"] intValue] == InputbatchTypeImage) {
                    UIView *tmpBlock = mBlockViews[i];
                    DisasterDetailCellView *tmpCell = [[tmpBlock subviews] objectAtIndex:1];
                    
                    if([[tmpCell.imageViews[k] subviews] count] == 0
                       && [[tmpCell.loadingimgViews[k] subviews] count] > 0){
                        
                        NSString *imgid = tmpDetail[@"id"];
                        if ([[mDisasterImages objectForKey:imgid] isKindOfClass:[UIImage class]]) {
                            UIActivityIndicatorView *tmpv = tmpCell.loadingimgViews[k];
                            
                            //ImageView中添加Image
                            UIImage *img = [mDisasterImages objectForKey:imgid];
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


-(void)addBlockViewsToScrollView{
    //右侧时间条添加
    CGFloat blockOffsetY = 0;
    for (int i = 0; i < mBlockViews.count; i++) {
        UIView *blockview = (UIView *)mBlockViews[i];
        NSLog(@"block offsety = %f", blockOffsetY);
        CGFloat timeviewOffsetX = blockview.frame.size.width + MARGIN*2;
        UIView *timeView = [[UIView alloc]initWithFrame:CGRectMake(timeviewOffsetX, blockOffsetY, 40, blockview.frame.size.height + MARGIN)];
        [timeView setBackgroundColor:LIGHTGRAY_COLOR];
        UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 2, timeView.frame.size.height)];
        [yLabel setBackgroundColor:BLUE_COLOR];
        UILabel *xLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 10, 1)];
        [xLabel setBackgroundColor:BLUE_COLOR];
        [timeView addSubview:xLabel];
        [timeView addSubview:yLabel];
        
        [blockview setFrame:CGRectMake(MARGIN, blockOffsetY, blockview.frame.size.width, blockview.frame.size.height)];
        blockOffsetY += blockview.frame.size.height + MARGIN;
        [mDetailScrollView addSubview:blockview];
        [mDetailScrollView addSubview:timeView];
    }
    
    int scrollviewHeight = self.view.frame.size.height - mStarttimeButton.frame.size.height - mBaseinfoTableView.frame.size.height - 64 -10;
    //添加滚动指示
    if (blockOffsetY > scrollviewHeight) {
        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
        mScrollViewIndicatorFlag = NO;
        mDetailScrollViewIndicator = [self createDetailScrollViewIndicator];
    }else{
        [mDetailScrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollviewHeight)];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%f",scrollView.contentOffset.y);
//    NSLog(@"%f",scrollView.contentSize.height);
//    NSLog(@"%f",scrollView.frame.size.height);
    
    if(scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= scrollView.contentSize.height-scrollView.frame.size.height){
        CGFloat p = scrollView.contentOffset.y*(scrollView.frame.size.height-mDetailScrollViewIndicator.frame.size.height-10)/(scrollView.contentSize.height-scrollView.frame.size.height);
        mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, p, 40, 30);
    }
//    CGFloat p = scrollView.contentOffset.y * (scrollView.contentSize.height - mDetailScrollViewIndicator.frame.size.height)/(scrollView.contentSize.height - scrollView.frame.size.height);
//    mDetailScrollViewIndicator.frame = CGRectMake(mDetailScrollViewIndicator.frame.origin.x, p, 40, 30);
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
    else{
        while ([[cell.contentView subviews] lastObject]) {
            [[[cell.contentView subviews] lastObject] removeFromSuperview];
        }
    }
    
    [cell.textLabel setText:mBaseinfoList[indexPath.row][@"cellLabel"]];
    UILabel *tmplabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width-100-44, 44)];
    [tmplabel setTextColor:[UIColor grayColor]];
    [tmplabel setText:mBaseinfoList[indexPath.row][@"cellContent"]];
    [cell.contentView addSubview:tmplabel];
    
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
        [dict setObject:mChemicalsList forKey:@"chemicallist"];
        
        [self performSegueWithIdentifier:@"DisasterChemicalSegue" sender:dict];
    }
}

#pragma mark - 页面跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DisasterChemicalSegue"]) {
        DisasterChemicalViewController *targetVC = segue.destinationViewController;
        targetVC.disasterId = sender[@"id"];
        targetVC.chemicalList = sender[@"chemicallist"];
        
    }
    else if([segue.identifier isEqualToString:@"UploadSegue"]){
        //到上传信息页面
        UploadViewController *targetVC = segue.destinationViewController;
        targetVC.did = self.did;
        targetVC.sid = self.did;
    }
}

#pragma mark - 计时
-(void)countForDisaster:(NSString *)time{
    //获取当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *tmptime;
    if (time.length > 0) {
        tmptime = [CustomUtil getFormatedDateString:time];
    }
    else{
        return;
    }
    NSDate *startdate = [formatter dateFromString:tmptime];
    NSTimeInterval tmpdate = [[NSDate date] timeIntervalSinceDate:startdate];
    __block int timecounts= tmpdate;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timecounts<=0){
            dispatch_source_cancel(_timer);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //时间计算显示(这里显示的是事故已经发生了多久）
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
                if (hour<10) {
                    hourstr = [NSString stringWithFormat:@"0%d",hour];
                }
                else{
                    hourstr = [NSString stringWithFormat:@"%d",hour];
                }
                if (mins<10) {
                    minsstr = [NSString stringWithFormat:@"0%d",mins];
                }
                else{
                    minsstr = [NSString stringWithFormat:@"%d",mins];
                }
                if (secs<10) {
                    secsstr = [NSString stringWithFormat:@"0%d",secs];
                }
                else{
                    secsstr = [NSString stringWithFormat:@"%d",secs];
                }
                
                [mStarttimeButton setTitle:[NSString stringWithFormat:@"%@%@:%@:%@",daystr, hourstr, minsstr, secsstr] forState:UIControlStateNormal];
            });
            timecounts++;
        }  
    });  
    dispatch_resume(_timer);
}

-(NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}

-(void)startToGetInputbatches{
   mGetInputbatchesTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(intervalGetInputbatches) userInfo:self repeats:YES];
}
-(void)intervalGetInputbatches{
    if (mDisasterDetailList.count > 0) {
        mLastTime = [mDisasterDetailList lastObject][@"time"];
    }
    else{
        mLastTime = mDisasterBaseinfo[@"start_time"];
    }
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP , EDRSHTTP_GETDISASTER_DETAIL_INPUTS]
                  params:@{@"time":mLastTime, @"disasterid":self.did}
                 success:^(id responseObj) {
                     NSLog(@"get disaster detail inputbatches successfully , response = %@", responseObj);
        
                    //记录当前时间
                    if ([responseObj count] > 0) {
                        for (int i = 0 ; i < [responseObj count]; i++) {
                            [mDisasterDetailList addObject:responseObj[i]];
                        }
                        [self addSubviewsToDetail];
                    }

    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster detail inputs, error = %@", err);
    }];
}

#pragma mark - cache save & read
-(void)saveDisasterInputbatches:(NSMutableArray *)arr disasterid:(NSString *)did{
    NSString *newpath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.plist", EDRS_UD_INFO, did]];
    if ([arr writeToFile:newpath atomically:YES]) {
        NSLog(@"save info successfully");
    }
}
-(NSMutableArray *)readDisasterInputbatches:(NSString *)did{
    NSString *filepath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.plist",EDRS_UD_INFO, did]];
    NSMutableArray *tmparr = [[NSMutableArray alloc]initWithContentsOfFile:filepath];
    if (!tmparr) {
        tmparr = [[NSMutableArray alloc]init];
    }
    return tmparr;
}

@end
