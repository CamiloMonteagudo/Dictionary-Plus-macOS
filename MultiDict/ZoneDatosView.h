//===================================================================================================================================================
//  ZoneDatosView.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 3/1/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "DatosView.h"

//===================================================================================================================================================
// Zona donde se muestran los datos de las palabras
@interface ZoneDatosView : NSView

@property (nonatomic,readonly) int Count;         // Cantidad de datos que se estan mostrando

+(void) SelectDatos:(DatosView*) view;
+(DatosView*) SelectedDatos;

- (void) AddDatosAtIndex:(NSInteger)Idx;
- (void) AddAfterSelDatos:(EntryDict*) entry Src:(int)src Des:(int)des;
- (void) ClearDatos;
- (void) DeleteSelectedDatos;

@end

//===================================================================================================================================================
