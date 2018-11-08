//
//  ChemicalDetailInfoViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 16/8/19.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import "ChemicalDetailInfoViewController.h"
#import "AppDelegate.h"
@interface ChemicalDetailInfoViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
}
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) UITableView *tableView;
@end

@implementation ChemicalDetailInfoViewController

-(NSString *)getNameWithDic:(NSDictionary *)itemDic{
    return itemDic[@"name"];
}

-(NSString *)getSourceWithDic:(NSDictionary *)itemDic{
     return itemDic[@"source"];
}

-(NSString *)getMetricWithDic:(NSDictionary *)itemDic{
    return [NSString stringWithFormat:@"%@%@ %@%@ %@%@ %@%@ %@%@ %@%@",itemDic[@"metric1"],itemDic[@"value1"],itemDic[@"metric2"],itemDic[@"value2"],itemDic[@"metric3"],itemDic[@"value3"],itemDic[@"metric4"],itemDic[@"value4"],itemDic[@"metric5"],itemDic[@"value5"],itemDic[@"metric6"],itemDic[@"value6"]];
    
}

-(UIView *)topView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = [UIColor whiteColor];
    NSInteger length = SCREEN_WIDTH/6;
    NSArray *titles = @[@"标准名称",@"来源",@"标准数值"];
    for (NSInteger i = 0; i<titles.count; i++) {
        UILabel *label = [[UILabel alloc]init];
        label.text = titles[i];
        label.textAlignment = NSTextAlignmentCenter ;
        if(i==0){
            label.frame = CGRectMake(0, 0, 2*length, view.frame.size.height);
        }else if (i==1){
           label.frame = CGRectMake(2*length, 0, length, view.frame.size.height);
        }else{
          label.frame = CGRectMake(3*length, 0, 3*length, view.frame.size.height);
        }
        [view addSubview:label];
    }
    return view ;
}

-(void)getDetailInfo{
    
    __weak ChemicalDetailInfoViewController *weakSelf = self ;
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETCHEMICAL_STANDARDS] params:@{@"id":self.cid} success:^(id responseObj) {
        NSLog(@"get test success , response = %@", responseObj);
        if([responseObj isKindOfClass:[NSArray class]]){
            NSArray *list = (NSArray *)responseObj;
            for (NSDictionary *itemDic in list ) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[[weakSelf getNameWithDic:itemDic],[weakSelf getSourceWithDic:itemDic],[weakSelf getMetricWithDic:itemDic]] forKeys:@[@"name",@"source",@"value"]];
                [weakSelf.dataArray addObject:dic];
                [weakSelf.tableView reloadData];
            }
           
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to get test");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title =  @"环境标准";
    [Utility configuerNavigationBackItem:self];
    self.view.backgroundColor = [UIColor lightGrayColor];
    _dataArray= [[ NSMutableArray alloc]init];
    [self.view addSubview:[self topView]];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 105, SCREEN_WIDTH, SCREEN_HEIGHT-64-40)];
    _tableView.dataSource = self ;
    _tableView.delegate  =self ;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"chemicalCell"];
    [self getDetailInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chemicalCell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDictionary *dic = [_dataArray objectAtIndex:[indexPath row]];
    UILabel *left = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 2*SCREEN_WIDTH/6, 90)];
    left.text = [dic valueForKey:@"name"];
    left.numberOfLines = 99;
    left.font = [UIFont systemFontOfSize:14];
    left.adjustsFontSizeToFitWidth = YES ;
    [cell.contentView addSubview:left];
    
    UILabel *middle = [[UILabel alloc]initWithFrame:CGRectMake( 2*SCREEN_WIDTH/6, 0, SCREEN_WIDTH/6, 90)];
    middle.text = [dic valueForKey:@"source"];
    middle.numberOfLines = 99;
    middle.font = [UIFont systemFontOfSize:14];
    middle.adjustsFontSizeToFitWidth = YES ;
    [cell.contentView addSubview:middle];
    
    UILabel *right = [[UILabel alloc]initWithFrame:CGRectMake( 3*SCREEN_WIDTH/6, 0, 3*SCREEN_WIDTH/6, 90)];
    right.text = [dic valueForKey:@"value"];
    right.numberOfLines = 99;
    right.font = [UIFont systemFontOfSize:14];
    right.textAlignment = NSTextAlignmentRight;
    right.adjustsFontSizeToFitWidth = YES ;
    [cell.contentView addSubview:right];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
