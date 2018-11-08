//
//  Constants.h
//  edrs
//
//  Created by 余文君, July on 15/8/12.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef edrs_Constants_h
#define edrs_Constants_h

#endif

typedef NS_ENUM(NSInteger, SpecialInputType){
    SpecialInputTypeDisasterNatureIdentified = 0,
    SpecialInputTypeDisasterStartTimeIdentified = 1,
    SpecialInputTypeDisasterNamedChanged = 2,
    SpecialInputTypeDisasterLocationPinpointed = 3,
    SpecialInputTypeDisasterChemicalIdentified = 4,
    SpecialInputTypeSimulationResultObtained = 5,
    SpecialInputTypeHealthRiskAssessed = 6,
    SpecialInputTypeDisasterWindDirectionSpeed = 7
};

typedef NS_ENUM(NSInteger, InputbatchType) {
    InputbatchTypeText = 0,
    InputbatchTypeImage = 1,
    InputbatchTypeData = 2,
    InputbatchTypeVoice = 3,
    InputbatchTypeSpecial = 4
};


extern NSString * const LOGOUT;
extern NSString * const LOGINFAILURE;

extern NSString* const USERNAME;
extern NSString* const PASSWORD;
extern NSString* const STATION;
extern NSString* const STATIONID;
extern NSString* const STATIONURL;
extern NSString* const USERID;
extern NSString* const REMEMBERPWD;
extern NSString* const STATIONARRAY;
extern NSString* const DUTYALARM;

extern NSString* const SESSION;
extern NSString* const TOKEN;

extern NSString * const EDRSHTTP;
extern NSString * const EDRSHTTP_GETSTATION;
extern NSString * const EDRSHTTP_LOGIN;
extern NSString * const EDRSHTTP_APPVERSION;
extern NSString * const EDRSHTTP_LOGIN_OUT;
extern NSString * const EDRSHTTP_INDEX;
extern NSString * const EDRSHTTP_mainTypeTow;

extern NSString * const EDRSHTTP_SEARCH;

extern NSString * const EDRSHTTP_GETCHEMICAL_LENGTH;
extern NSString * const EDRSHTTP_GETCHEMICAL_PAGE;
extern NSString * const EDRSHTTP_FACTOR_PAGE ;
extern NSString * const EDRSHTTP_GETCHEMICAL_SEARCH;
extern NSString * const EDRSHTTP_GETCHEMICAL_SEARCHLENGTH;

extern NSString * const EDRSHTTP_GETCHEMICAL_DETAIL;
extern NSString * const EDRSHTTP_GETCHEMICAL_TEST;
extern NSString * const EDRSHTTP_GETCHEMICAL_STANDARDS;
extern NSString * const EDRSHTTP_GETCHEMICAL_TEST_DETAIL;

extern NSString * const EDRSHTTP_GETEQUIPMENT_PAGE;
extern NSString * const EDRSHTTP_GETEQUIPMENT_LENGTH;
extern NSString * const EDRSHTTP_GETEQUIPMENT_DETAIL;
extern NSString * const EDRSHTTP_GETEQUIPMENT_ALLMETRICS;

extern NSString * const EDRSHTTP_GETCASES_PAGE;//成功案例

extern NSString * const EDRSHTTP_GETPOLLUTION_LENGTH;
extern NSString * const EDRSHTTP_GETPOLLUTION_ALL;
extern NSString * const EDRSHTTP_GETPOLLUTION_SEARCH;
extern NSString * const EDRSHTTP_GETPOLLUTION_SEARCHLENGTH;

extern NSString * const EDRSHTTP_GETPOLLSRC_CENTER;
extern NSString * const EDRSHTTP_GETPOLLUTION_DETAIL;

extern NSString * const EDRSHTTP_GETDISASTER_ALL;
extern NSString * const EDRSHTTP_GETDISASTER_UPLOAD;
extern NSString * const EDRSHTTP_GETDISASTER_NEWDISASTER ;
extern NSString * const EDRSHTTP_GETDISASTER_UPLOAD_DISASTERLOC;
extern NSString * const EDRSHTTP_GETDISASTER_CURRENT;

extern NSString * const EDRSHTTP_GETDISASTER_DETAIL;
extern NSString * const EDRSHTTP_GETDISASTER_DETAIL_CHEMICALS;
extern NSString * const EDRSHTTP_NUITMEASURE_GETUNIT;
extern NSString * const EDRSHTTP_GETDISASTER_DETAIL_FACTORS;
extern NSString * const EDRSHTTP_GETDISASTER_DETAIL_SET_CHEMICALS;

extern NSString * const EDRSHTTP_GETDISASTER_DETAIL_INPUTS;

extern NSString * const EDRSHTTP_GETDISASTER_CHEMICALS_RADIUS;
extern NSString * const EDRSHTTP_GETDISASTER_CHEMICAL_TESTMETHOD;
extern NSString * const EDRSHTTP_GETDISASTER_POLLUTIONS_RADIUSE;

extern NSString * const EDRSHTTP_DISASTER_ADD;
extern NSString * const EDRSHTTP_DISASTER_GETGPS;
extern NSString * const EDRSHTTP_DISASTER_SETLOCATION;
extern NSString * const EDRSHTTP_DETECTION_SCHEME;
extern NSString * const EDRSHTTP_GET_DETECTION_SCHEME_PDF;
extern NSString * const EDRSHTTP_GET_DETECTION_Repot_FILE;
extern NSString * const EDRSHTTP_GETDATALOC;

extern NSString * const EDRSHTTP_DUTYSET;

extern NSString * const EDRSHTTP_GETFILE;
extern NSString * const EDRSHTTP_DUTY_INFO;

extern NSString * const EDRSHTTP_UPLOAD_ADD;
extern NSString * const EDRSHTTP_UPLOAD_COMMIT;
extern NSString * const EDRSHTTP_UPLOAD_FILE;

extern NSString * const EDRS_UD_DISASTERS;
extern NSString * const EDRS_UD_CURRENTDISASTERS;
extern NSString * const EDRS_UD_UPLOAD;
extern NSString * const EDRS_UD_INFO;
extern NSString * const EDRS_UD_UP_IMAGES;
extern NSString * const EDRS_UD_INFO_IMAGES;

extern NSString * const EDRS_UD_DATALOC;
