//
//  Constants.m
//  edrs
//
//  Created by 余文君, July on 15/8/12.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "Constants.h"

NSString * const LOGOUT = @"EDRSLogout";
NSString * const LOGINFAILURE = @"EDRSLoginfailure";

NSString * const USERNAME = @"EDRSUsername";
NSString * const PASSWORD = @"EDRSPassword";
NSString * const STATION = @"EDRSStation";
NSString * const STATIONID = @"EDRSStationId";
NSString * const STATIONURL = @"EDRSStationUrl";
NSString * const USERID = @"EDRSUserId";
NSString * const REMEMBERPWD = @"EDRSRememberpwd";
NSString * const STATIONARRAY = @"EDRSStationArray";
NSString * const DUTYALARM = @"EDRSDutyAlarm";

NSString * const SESSION = @"EDRSSession";
NSString * const TOKEN = @"EDRSToken";
NSString * const USERTOKEN = @"USERToken";


NSString * const EDRSHTTP = @"";
NSString * const EDRSHTTP_GETSTATION = @"/api/login/getstationName";
NSString * const EDRSHTTP_LOGIN = @"/api/login/Login";
NSString * const EDRSHTTP_LOGIN_OUT = @"/api/login/LoginOut";
NSString * const EDRSHTTP_APPVERSION= @"/api/login/GetAppVersion";
NSString * const EDRSHTTP_INDEX = @"/api/station/getstats";
NSString * const EDRSHTTP_mainTypeTow = @"/api/disaster/PagedList";//maintypeTow


NSString * const EDRSHTTP_SEARCH = @"/api/station/getsearch";

NSString * const EDRSHTTP_GETCHEMICAL_LENGTH = @"/api/chemical/getlength";
NSString * const EDRSHTTP_GETCHEMICAL_PAGE = @"/api/chemical/PagedList";

NSString *const EDRSHTTP_GETCASES_PAGE = @"/api/archive/PagedList";//成功案例列表

NSString * const EDRSHTTP_FACTOR_PAGE = @"/api/factor/PagedList";
NSString * const EDRSHTTP_GETCHEMICAL_SEARCH = @"/api/chemical/search";
NSString * const EDRSHTTP_GETCHEMICAL_SEARCHLENGTH = @"/api/chemical/getsearchlength";

NSString * const EDRSHTTP_GETCHEMICAL_DETAIL = @"/api/chemical/GetDetail";
NSString * const EDRSHTTP_GETCHEMICAL_TEST = @"/api/chemical/gettestmethods";
NSString * const EDRSHTTP_GETCHEMICAL_STANDARDS = @"/api/chemical/getstandards";
NSString * const EDRSHTTP_GETCHEMICAL_TEST_DETAIL = @"/api/chemical/gettestmethoddetails";

NSString * const EDRSHTTP_GETEQUIPMENT_PAGE = @"/api/equipment/PagedList";
NSString * const EDRSHTTP_GETEQUIPMENT_LENGTH = @"/api/equipment/getallcount";
NSString * const EDRSHTTP_GETEQUIPMENT_DETAIL = @"/api/equipment/GetDetail";
NSString * const EDRSHTTP_GETEQUIPMENT_ALLMETRICS = @"/api/equipment/getallmetrics";

NSString * const EDRSHTTP_GETPOLLUTION_LENGTH = @"/api/pollsource/getlength";
NSString * const EDRSHTTP_GETPOLLUTION_ALL = @"/api/pollsource/PagedList";
NSString * const EDRSHTTP_GETPOLLUTION_SEARCH = @"/api/pollsource/search";
NSString * const EDRSHTTP_GETPOLLUTION_DETAIL = @"/api/pollsource/GetDetail";
NSString * const EDRSHTTP_GETPOLLUTION_SEARCHLENGTH = @"/api/pollsource/count";

NSString * const EDRSHTTP_GETPOLLSRC_CENTER = @"/api/disaster/getpollsrccenter";
NSString * const EDRSHTTP_GETDISASTER_UPLOAD = @"/api/disaster/isupload";
NSString * const EDRSHTTP_GETDISASTER_NEWDISASTER = @"/api/disaster/isnewdisaster";

NSString * const EDRSHTTP_GETDISASTER_UPLOAD_DISASTERLOC = @"/api/disaster/UploadDisasterLoc";
NSString * const EDRSHTTP_GETDISASTER_ALL = @"/api/disaster/getall";
NSString * const EDRSHTTP_GETDISASTER_CURRENT = @"/api/disaster/getcurrent";

NSString * const EDRSHTTP_GETDISASTER_DETAIL = @"/api/disaster/get";
NSString * const EDRSHTTP_GETDISASTER_DETAIL_CHEMICALS = @"/api/disaster/getchemicals";
NSString * const EDRSHTTP_GETDISASTER_DETAIL_FACTORS = @"/api/disaster/GetDisasterFactors";

NSString * const EDRSHTTP_NUITMEASURE_GETUNIT = @"api/UnitMeasure/GetUnits";
NSString * const EDRSHTTP_GETDISASTER_DETAIL_SET_CHEMICALS = @"/api/disaster/setdisasterchemicaldata";

NSString * const EDRSHTTP_GETDISASTER_DETAIL_INPUTS = @"/api/inputbatch/inputbatchesdetailssince";

NSString * const EDRSHTTP_GETDISASTER_CHEMICALS_RADIUS = @"/api/pollsource/getallpotentialchemicalswithinradius";
NSString * const EDRSHTTP_GETDISASTER_CHEMICAL_TESTMETHOD = @"/api/chemical/testmethodsequence";
NSString * const EDRSHTTP_GETDISASTER_POLLUTIONS_RADIUSE = @"/api/pollsource/getallpotentialchemicalswithinradius";




NSString * const EDRSHTTP_DISASTER_ADD = @"/api/disaster/add";
NSString * const EDRSHTTP_DISASTER_GETGPS = @"/api/disaster/GetBdToGps";
NSString * const EDRSHTTP_DISASTER_SETLOCATION = @"/api/disaster/setdisasterlocation";
NSString * const EDRSHTTP_DETECTION_SCHEME = @"/api/plan/getplan";
NSString * const EDRSHTTP_GET_DETECTION_SCHEME_PDF = @"/api/plan/getPdf";
NSString * const EDRSHTTP_GET_DETECTION_Repot_FILE= @"/api/plan/getreportfile";
NSString * const EDRSHTTP_GETDATALOC = @"/api/dataloc/getall";

NSString * const EDRSHTTP_DUTYSET = @"/api/staff/switchduty";

NSString * const EDRSHTTP_UPLOAD_ADD = @"/api/inputbatch/add";
NSString * const EDRSHTTP_UPLOAD_COMMIT = @"/api/inputbatch/commit";
NSString * const EDRSHTTP_UPLOAD_FILE = @"/api/inputbatch/uploadfragment";

NSString * const EDRSHTTP_GETFILE = @"/api/disaster/getfile";

NSString * const EDRSHTTP_DUTY_INFO = @"/api/staff/getdutyinfo";

NSString * const EDRS_UD_DISASTERS = @"EDRS_UD_DISASTERS";
NSString * const EDRS_UD_CURRENTDISASTERS = @"EDRS_UD_CURRENTDISASTERS";
NSString * const EDRS_UD_UPLOAD = @"EDRS_UD_UPLOAD_";
NSString * const EDRS_UD_INFO = @"EDRS_UD_INFO_";
NSString * const EDRS_UD_UP_IMAGES = @"EDRS_UD_UP_IMAGES_";
NSString * const EDRS_UD_INFO_IMAGES = @"EDRS_UD_INFO_IMAGES_";

NSString * const EDRS_UD_DATALOC = @"EDRS_UD_DATALOC_";

