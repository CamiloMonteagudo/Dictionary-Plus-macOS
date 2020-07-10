//===================================================================================================================================================
//  AppData.h
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "DictMain.h"
#import "DictIndexes.h"
#import "DatosView.h"
#import "ViewController.h"

//===================================================================================================================================================
#define LGCount     4
#define SEP         5
#define WBTNS       20
#define HBTNS       20
#define HSUST_DATA  22

#define SWAP_DICT   0x0001
#define DEL_ALL     0x0002
#define DEL_SEL     0x0004
#define COPY_TEXT   0x0008
#define CONJ_WRD    0x0010
#define TRD_WRD     0x0020

#define All_BTNS    0xFFFF

#define FULL_FRASE  0x0001
#define VERB_UP     0x0002

#define DAYS_MAX    16
#define DAYS_TEST   20

//===================================================================================================================================================
// Define tipos de datos para la búsqueda
#define INT_LIST      NSMutableArray<NSNumber*>
#define FOUNDS_ENTRY  NSMutableDictionary<NSNumber*,  INT_LIST*>
#define GET_NUMBER(n) [NSNumber numberWithInt:n]

//===================================================================================================================================================

extern int LGSrc;
extern int LGDes;
extern int iUser;
extern int nBuyDays;

extern DictMain*       Dict;
extern DictIndexes*    DictIdx;
extern ViewController* Ctrller;

extern NSCharacterSet* lnSep;
extern NSCharacterSet* kySep;
extern NSCharacterSet* TypeSep;
extern NSCharacterSet* MeanSep;
extern NSCharacterSet* wrdSep;
extern NSCharacterSet* PntOrSpc;
extern NSCharacterSet* TrimSpc;

extern NSColor* SelColor;
extern NSColor* SustColor;
extern NSColor* BackColor;
extern NSColor* MsgBkgColor;
extern NSColor* MsgTxtColor;
extern NSColor* MsgSelColor;

//===================================================================================================================================================
extern NSString*  LGFlag( int lng);
extern NSString*  LGAbrv( int lng );
extern NSString*  LGName( int lng );

extern int       DIRSrc( int iDir );
extern int       DIRDes( int iDir );
extern int       DIRFromLangs(int src, int des);
extern int       DIRFirst();
extern int       DIRCount();
extern NSString* DIRName( int iDir, BOOL noFlags, BOOL noSpace );
extern NSString* DIRAbrv( int src, int des );

extern int CNJCount();
extern int CNJLang( int idx );
extern NSString* CNJTitle( int idx );

NSString* IndexDictName( int src, int des );
NSString* MainDictName( int src, int des );
NSString* PathForDict(NSString* FName);

extern BOOL IsLetter( NSInteger idx, NSString* Txt );
extern int HexDigit(int idx, NSString* str );

extern NSString* QuitaAcentos( NSString* wrd, int lng );
extern void WaitMsg();
extern NSAttributedString* MsgForDir( NSString* s, int Dir );

//===================================================================================================================================================


