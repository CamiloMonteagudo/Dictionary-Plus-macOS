//===================================================================================================================================================
//  DatosView.h
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 3/1/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "AppData.h"

//===================================================================================================================================================
// Botón para poner un icono y el cursor de la manito
@interface MyButton : NSButton

@end

//===================================================================================================================================================
// Botón para poner un icono y el cursor de la manito
@interface MyEdit : NSTextView

@end

//===================================================================================================================================================
// Botón para poner un icono y el cursor de la manito
@interface MarkNum : NSObject

@property (nonatomic) int Count;
@property (nonatomic) int Now;
  
+ (MarkNum*) Create;
  
@end


//===================================================================================================================================================
// Recuadro donde se ponen los datos de una entrada del diccionario
@interface DatosView : NSView <NSTextViewDelegate>

@property (nonatomic) int src;
@property (nonatomic) int des;

@property (nonatomic, readonly) BOOL HasSustMarks;
@property (nonatomic, readonly) BOOL HSustMarks;

+ (DatosView*) DatosForIndex:(NSInteger) Idx With:(CGFloat) w;
+ (DatosView*) DatosForEntry:(EntryDict*) Entry Src:(int)src Des:(int)des With:(CGFloat) w;

- (CGFloat) ResizeWithWidth:(CGFloat) w;

- (NSString*) TextInKeyForMark:(NSString*) code;
- (NSString*) TextInDataForMark:(NSString*) code;

- (void) ResplaceMark:(NSString*) code TextSrc:(NSString*) srcTxt TextDes:(NSString*) desTxt;

- (NSString*) getSelWordAndLang:(int *)lang;

- (void) CopyText;
- (void) SelectedDatos;
- (void) SustWords;
- (void) UnSelectedDatos;

@end

//===================================================================================================================================================
