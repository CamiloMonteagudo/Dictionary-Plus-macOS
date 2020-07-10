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
// Recuadro donde se ponen los datos de una entrada del diccionario
@interface BuyMsgView : NSView

@property (nonatomic) int src;
@property (nonatomic) int des;

+ (instancetype) BuyMsgWithWidth:(CGFloat) w;

- (CGFloat) ResizeWithWidth:(CGFloat) w;
- (void) SelectedDatos;
- (void) UnSelectedDatos;

@end

//===================================================================================================================================================
