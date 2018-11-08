//
//  WebApiPath.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/13.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

//static    NSString * const EDRSHTTP_GETSTATION = @"/api/login/getstationName";
//
//static    NSString * const EDRSHTTP_LOGIN = @"/api/login/Login";

static    NSString * const SAMPLE_LIST = @"/api/Sampleplan/PagedList";

static    NSString * const CHEMICAL_GETBYTAG= @"/api/chemical/getbytag";

static    NSString * const PLAN_TASKS = @"/api/Sampletask/GetPlanTasks";

static    NSString * const SOURCE_FACTOR_LIST = @"/api/factor/GetSourceFactorList";

static    NSString * const SET_INPUT_ID = @"/api/FactorData/SetInputID";

static    NSString * const FACTOR_DATA_ADD = @"/api/FactorData/Add";

static    NSString * const TASK_ANALYSLS_TYPELIST = @"/api/Sampletask/GetTaskAnalysisTypeList";

static    NSString * const TASK_UPLOAD_FRAGMENT = @"/api/Sampletask/UploadFragment";

static    NSString * const GET_DISASTER_PLANFACTOR = @"/api/Sampleplan/GetDisasterPlanFactor";

static    NSString * const GET_ALLPLAN_SAMPLE = @"/api/Sampleplan/GetALLPlanSample";

static    NSString * const GET_EQUIPMENT_LIST = @"/api/equipment/PagedList";

static    NSString * const GET_TESTMETHOD_SEQUENCE = @"/api/chemical/testmethodsequence";

static    NSString * const ADD_DISASTER_DATA = @"/api/Disasterdata/Add";

static    NSString * const GET_PLAN_BYCODE = @"/api/FactorData/GetPlanByQrCode";

static    NSString * const GET_PLAN_BYCODEDETAIL = @"/api/FactorData/GetSampleData";

static    NSString * const UPDATE_ANALYSIS_FCTOR = @"/api/factor/UpdateAnalysisFactor";

static    NSString * const ADD_ANALYSIS_FCTOR = @"/api/Analysistype/Add";

static     NSString * const DISASTER_SET_WIND = @"/api/disaster/setdisasterwind";

static     NSString * const DISASTER_SETDISTATER_NATURE= @"/api/disaster/setdisasternature";

static     NSString * const DISASTER_INPUTBATCH_ADD= @"/api/inputbatch/add";

static     NSString * const EDRSHTTP_GETCOMMON_FACTOR = @"/api/factor/GetCommonFactor";

static     NSString * const DISASTER_INPUTBATCH_COMMIT= @"/api/inputbatch/commit";

static     NSString * const DISASTER_STANDARD_LIST= @"/api/archive/PagedList";

static     NSString * const STAFF_PAGE_LIST   = @"/api/staff/PagedList";

static     NSString * const ANALYSIS_TYPE_PAGELIST   = @"/api/Analysistype/PagedList";

static     NSString * const SAMPLE_TASK_ADD   = @"/api/Sampletask/Add";

static     NSString * const SAMPLE_TASK_UPDATA   = @"/api/Sampletask/Update";

static     NSString * const SOURCE_TYPE_PAGELIST  = @"/api/Sourcetype/PagedList";

static     NSString * const SAMPLE_TASK_DELETE  = @"/api/Sampletask/Delete";

static     NSString * const SAMPLE_TASK_UPDATAType  = @"/api/Sampletask/UpdateTaskAnalysisType";
