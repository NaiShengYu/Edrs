//
//  ChemicalSearchViewController.m
//  edrs
//
//  Created by 余文君, July on 15/9/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "ChemicalSearchViewController.h"
#import "MBProgressHUD.h"
@interface ChemicalSearchViewController (){
    UISegmentedControl *segmentedCl;
  
}

@end

@implementation ChemicalSearchViewController

-(void)segmentChanged:(id)sender{
    mSelectedIndex = -1;
    mPageIndex = 0;
    mCount = 0;
    [mDisasterChemicalArray removeAllObjects];
    [self getChemicalSearchList];
}

-(UIView *)titleView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-120, 44)];
    segmentedCl = [[UISegmentedControl alloc]initWithItems:@[@"常用检测因子",@"化学品库"]];
    segmentedCl.center = view.center;
    [segmentedCl setTintColor:[UIColor whiteColor]];
    [segmentedCl setSelectedSegmentIndex:0];
    [segmentedCl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segmentedCl];
    
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView =[self titleView];
    [Utility configuerNavigationBackItem:self];
    mPageSize = 20;
    
    mDisasterChemicalArray = [[NSMutableArray alloc]init];
    mSubmitFlag = NO;
    mSelectedIndex = -1;
    
    //pull to refresh
    __weak __typeof(self) weakSelf = self;
    self.chemicalResultTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getChemicalSearchRefresh];
    }];
    [weakSelf getChemicalSearchList];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}
#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{\
    if (mSubmitFlag && mDisasterChemicalArray.count == 0) {
        return 1;
    }
    else{
        return mDisasterChemicalArray.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0.001)];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableview heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0.001)];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (mSubmitFlag && mDisasterChemicalArray.count == 0) {
        return mNoChemicalLabelHeight+30.0*2;
    }
    else{
        return 44.0f;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"DisasterChemicalCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        if ([[cell.contentView subviews] lastObject]) {
            [[[cell.contentView subviews] lastObject] removeFromSuperview];
        }
    }
    if (mSubmitFlag && mDisasterChemicalArray.count == 0) {
        //搜索后，结果无
        NSString *tmpstr = [NSString stringWithFormat:@"注意：数据库没有直接对应%@的检测因子名称，请检查输入名称是否正确或稍微更改名称格式再次搜索；如确定数据库中没有此检测因子，请再按一次确定键", self.chemicalSearchBar.text];
        UILabel *label = [CustomUtil setTextInLabel:tmpstr labelW:SCREEN_WIDTH labelPadding:30 textAlign:NSTextAlignmentLeft textFont:[UIFont systemFontOfSize:17.0f]];
        [label setFrame:CGRectMake(label.frame.origin.x, 30, label.frame.size.width, label.frame.size.height+30)];
        [label setTextColor:[UIColor whiteColor]];
        mNoChemicalLabelHeight = label.frame.size.height;
        [cell.contentView addSubview:label];
        [cell.textLabel setText:@""];
        [cell.contentView setBackgroundColor:BLUE_COLOR];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    else{
        [cell.textLabel setText:mDisasterChemicalArray[indexPath.row][@"name"]];
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        
        if (mSelectedIndex != -1 && mSelectedIndex == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (mDisasterChemicalArray.count > 0) {
        mSelectedIndex = indexPath.row;
        
        [self.chemicalResultTableView reloadData];
    }
}

#pragma mark - search delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];

    mSelectedIndex = -1;
    mPageIndex = 0;
    mCount = 0;
    [mDisasterChemicalArray removeAllObjects];
    [self getChemicalSearchList];
  
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        mSubmitFlag = NO;
        [self.chemicalResultTableView reloadData];
    }
}

-(void)getChemicalSearchRefresh{
    if (mPageIndex < ceil((float)mCount/mPageSize) - 1) {
        mPageIndex ++;
        [self getChemicalSearchList];
    }
    else{
        [self.chemicalResultTableView.footer endRefreshingWithNoMoreData];
    }
}

-(void)getCommonFactor{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETCOMMON_FACTOR]
                   params:nil
                  success:^(id responseObj) {
                      NSArray *Items = (NSArray *)responseObj;
                      
                      for (int i = 0 ; i < [Items count]; i++) {
                          [mDisasterChemicalArray addObject:Items[i]];
                      }
                      if (mPageIndex >= ceil((float)mCount/mPageSize -1)) {
                          [self.chemicalResultTableView.footer endRefreshingWithNoMoreData];
                      }
                      else{
                          [self.chemicalResultTableView.footer endRefreshing];
                      }
                      
                      [self.chemicalResultTableView reloadData];
                      
                  }
                  failure:^(NSError *err) {
                      NSLog(@"fail to get chemicals , error = %@", err);
                  }];
   

}

-(void)getChemicalSearchList{
    NSString *key = self.chemicalSearchBar.text;
    BOOL isChemial = YES ;
    if(segmentedCl.selectedSegmentIndex==0){
        isChemial = NO;
        if(key.length ==0){
            [self getCommonFactor];
            return;
        }
    }else{
        isChemial = YES;
    }
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP,isChemial? EDRSHTTP_GETCHEMICAL_PAGE:EDRSHTTP_FACTOR_PAGE]
                  params:@{@"searchKey":key,@"pageIndex":[NSString stringWithFormat:@"%d",mPageIndex]}
                 success:^(id responseObj) {
                    // NSLog(@"get chemical successfully ,response = %@", responseObj);
                     NSArray *Items = [responseObj valueForKey:@"Items"];
                   //  NSInteger totals = [responseObj valueForKey:@"Totals"];
                     
                     for (int i = 0 ; i < [Items count]; i++) {
                         [mDisasterChemicalArray addObject:Items[i]];
                     }
                     if (mPageIndex >= ceil((float)mCount/mPageSize -1)) {
                         [self.chemicalResultTableView.footer endRefreshingWithNoMoreData];
                     }
                     else{
                         [self.chemicalResultTableView.footer endRefreshing];
                     }
                     
                     if(isChemial && Items.count==0){
                         [self getChemicalByType:key];
                     }else{
                         [self.chemicalResultTableView reloadData];
                     }
                    
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to get chemicals , error = %@", err);
                 }];
}

-(void)getChemicalByType:(NSString *)searchKey{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:searchKey forKey:@"tagName"];
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:CHEMICAL_GETBYTAG parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSLog(@"%@",[dictionary modelToJSONString]);
        NSArray *list = [dictionary valueForKey:@"list"];
        for (NSInteger i = 0; i<list.count; i++) {
            [mDisasterChemicalArray addObject:list[i]];
        }
         [self.chemicalResultTableView reloadData];
    } onError:^(NSError *engineError) {
        
    }];
}

-(BOOL)checkUpload:(NSString *)name{
    BOOL isUpload = NO;
    for (NSDictionary *sub in self.mChemicalsList) {
        if([[sub valueForKey:@"chemical_id"] isEqualToString:name]){
            isUpload = YES ;
        }
    }
    
    
    return isUpload;
}
#pragma mark - search submit
- (IBAction)actionSubmitDisasterChemicals:(id)sender {
   
    NSString *typeIndex = [NSString stringWithFormat:@"%ld",(long)segmentedCl.selectedSegmentIndex];
        if(mSubmitFlag){
            //必须提交当前search text
            NSLog(@"当前提交值为%@",self.chemicalSearchBar.text);
            NSMutableDictionary *tmpdict = [[NSMutableDictionary alloc]init];
            [tmpdict setObject:self.chemicalSearchBar.text forKey:@"name"];
            [tmpdict setObject:@"" forKey:@"id"];
            [tmpdict setValue:typeIndex forKey:@"typeIndex"];
            [self.delegate setDisasterChemical:tmpdict];
            [self.navigationController popViewControllerAnimated:YES];;
        }
        else{
            if(mDisasterChemicalArray.count == 0 && self.chemicalSearchBar.text.length > 0){
                mSubmitFlag = YES;
                [self.chemicalResultTableView reloadData];
            }
            else if(mDisasterChemicalArray.count > 0 && mSelectedIndex != -1){
                NSLog(@"当前提交值为选中的化学品，%@", mDisasterChemicalArray[mSelectedIndex][@"name"]);
                
                if([self checkUpload:mDisasterChemicalArray[mSelectedIndex][@"id"]]){
                    [CustomUtil showMBProgressHUD:@"该化学品已经添加,不能重复添加" view:self.view animated:YES];
                }else{
                    NSMutableDictionary *tmpdict = [[NSMutableDictionary alloc]init];
                    [tmpdict setDictionary:mDisasterChemicalArray[mSelectedIndex]];
                    [tmpdict setValue:typeIndex forKey:@"typeIndex"];
                    [self.delegate setDisasterChemical:tmpdict];
                    [self.navigationController popViewControllerAnimated:YES];
                }
               
            }
            else{
                NSLog(@"请选择化学品");
            }
        }
    

}
@end
