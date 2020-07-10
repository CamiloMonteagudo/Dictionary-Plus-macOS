//===================================================================================================================================================
//  IndexEntry.h
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>

@interface EntryIndex : NSObject

@property (nonatomic) int       Count;         // Cantidad de entradas donde se encuentra la palabra
@property (nonatomic) int*      Entrys;        // Arreglo con indices a las entradas donde esta la palabra
@property (nonatomic) int*      Pos;           // Arreglo con las posiciones de las palabras dentro del indice

+(EntryIndex*) EntryFromDatos:(NSString*) sDat;

-(void) Free;

@end
//===================================================================================================================================================
