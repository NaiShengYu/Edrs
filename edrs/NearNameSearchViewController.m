//
//  AirEnvironmentViewController.m
//  ProjectDemo
//
//  Created by Nasheng Yu on 2018/1/8.
//  Copyright © 2018年 俞乃胜, Stephen. All rights reserved.
//

#import "NearNameSearchViewController.h"

#import "CustomeSearchView.h"//搜索框

#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface NearNameSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,BMKPoiSearchDelegate>

@property (nonatomic,strong)UITableView *myTable;

@property (nonatomic,strong)NSMutableArray *dataArray;



@property (nonatomic,strong)BMKPoiSearch *poiSearch;
@end

@implementation NearNameSearchViewController

- (UITableView *)myTable{
    if (!_myTable) {
        _myTable =[[UITableView alloc]initWithFrame:CGRectMake(0,50, SCREEN_WIDTH, SCREEN_HEIGHT-StartBarHeight-50) style:UITableViewStyleGrouped];
        _myTable.delegate =self;
        _myTable.dataSource =self;
    }
    return _myTable;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray =[[NSMutableArray alloc]init];
    [self.view addSubview:self.myTable];
    [self customNavigationBar];
    [self creatSearchView];
    self.view.backgroundColor =[UIColor groupTableViewBackgroundColor];
    
    _poiSearch = [[BMKPoiSearch alloc]init];
    _poiSearch.delegate =self;
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
  
    _poiSearch.delegate = nil;
    
}



- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        [self.dataArray removeAllObjects];
        
            poiResult.currPoiNum = 30;
            for (int i = 0; i < poiResult.poiInfoList.count; i++) {
                BMKPoiInfo* poi = [poiResult.poiInfoList objectAtIndex:i];
                [self.dataArray addObject:poi];
            }
   
        [self.myTable reloadData];
    } else if (errorCode == BMK_SEARCH_PERMISSION_UNFINISHED){
        NSLog(@"用户没有授权");
    }else{
        NSLog(@"检索失败：%d",errorCode);
    }
    
   
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
       cell =[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cell"];

    }
 
    BMKPoiInfo* poi = self.dataArray[indexPath.row];
    cell.textLabel.text =poi.name;
    cell.textLabel.numberOfLines =0;
    cell.detailTextLabel.text =poi.address;
    cell.detailTextLabel.numberOfLines =0;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKPoiInfo* poi = self.dataArray[indexPath.row];
    if(self.selectSucceseBlock){
        self.selectSucceseBlock(poi.pt);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --让cell的横线到最左边
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)creatSearchView{
    CustomeSearchView *searchView =[[CustomeSearchView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];
    [self.view addSubview:searchView];
    searchView.backgroundColor =[UIColor whiteColor];
    searchView.delegate =self;
    searchView.contentInset =UIEdgeInsetsMake(5, 15, 5, 15);
    for (UIView *subView in searchView.subviews) {
        if ([subView isKindOfClass:[UIView class]]) {
            if ([[subView.subviews objectAtIndex:0] isKindOfClass:[UITextField class]]) {
                UITextField *TX = [subView.subviews objectAtIndex:0];
                TX.placeholder =@"输入地点";
                TX.font =FontSize(19);
                UIImageView *imgV =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25,25)];
                imgV.image =[UIImage imageNamed:@"search"];
                TX.leftView =imgV;
            }
        }
    }
}

//发送搜索请求
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"] &&searchBar.returnKeyType ==UIReturnKeySearch){
        [self getSearchResult:searchBar.text];
        [self.view endEditing:YES];

        //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}


#pragma mark --自定义导航栏
- (void)customNavigationBar{
    self.title =@"地址搜索";
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationController.navigationBar.hidden =NO;
    self.tabBarController.tabBar.hidden =YES;
    
    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];    leftBarButtonItem.imageInsets =UIEdgeInsetsMake(0, -10, 0, 10);
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:151/255.0 green:217/255.0 blue:204/255.0 alpha:0.5];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    
//    UIButton *rightBut =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [rightBut setTitle:@"确定" forState:UIControlStateNormal];
//    [rightBut addTarget:self action:@selector(goMap) forControlEvents:UIControlEventTouchUpInside];
//    //    [rightBut setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
//    UIBarButtonItem *rigth =[[UIBarButtonItem alloc]initWithCustomView:rightBut];
//    rigth.tintColor =[UIColor lightGrayColor];
//    self.navigationItem.rightBarButtonItem =rigth;
}


- (void)goBack{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark --获取搜索结果
- (void)getSearchResult:(NSString *)searchKey{
   
    BMKNearbySearchOption * option = [[BMKNearbySearchOption alloc]init];
    
    /***
     <这个值本来是传过来的不是固定的，我这里写的固定是方便大家看>
     ***/
    option.keyword = searchKey;
//    option.location = userLocation.location.coordinate;
    
    option.radius = 50000;
    option.location = self.location;
    /***
     <因为我需要一个定位所以我就拿一个位置的信息>
     ***/
    option.pageCapacity = 30;
    
    BOOL flag = [_poiSearch poiSearchNearBy:option];
    if (flag) {
        NSLog(@"检索发送成功");
    }else{
        NSLog(@"检索发送失败");
    }
  
}



@end

