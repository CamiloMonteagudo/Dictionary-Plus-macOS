//=============================================================================================================================================================
//  MngMarks.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//=============================================================================================================================================================

#import "MngMarks.h"

//=========================================================================================================================================================

static NSCharacterSet * lineSep = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
static NSCharacterSet * infoSep = [NSCharacterSet characterSetWithCharactersInString:@"|"];

static MngMarks* MarkObj = nil;

//=============================================================================================================================================================
//Maneja todas las marcas utilizadas en los diccionarios
@implementation MngMarks

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el objeto y carga las marcas desde un fichero
+(MngMarks*) Get
  {
  if( MarkObj == nil )
    {
    MarkObj = [MngMarks new];

    [MarkObj LoadFile];
    }

  return MarkObj;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga toda la información de las marcas desde un fichero
-(BOOL) LoadFile
  {
  _Marks = [NSMutableDictionary<NSString*, MarkDatos*> new];

  _EsSust = [NSMutableDictionary<NSString*, NSString*> new];
  _EnSust = [NSMutableDictionary<NSString*, NSString*> new];
  _ItSust = [NSMutableDictionary<NSString*, NSString*> new];
  _FrSust = [NSMutableDictionary<NSString*, NSString*> new];

  NSStringEncoding Enc;
  NSError          *Err;

  NSString *DicPath = [self GetMarkFilePath];
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;

  NSArray<NSString*> *Lines = [Txt componentsSeparatedByCharactersInSet:lineSep];

  for(int i=0; i<Lines.count; ++i )
    {
    NSArray<NSString*> *Parts = [Lines[i] componentsSeparatedByCharactersInSet:infoSep];

    if( Parts.count>=6 )
      [self AddMark: Parts];
    }

  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre y el camino completo del diccionario
- (NSString*) GetMarkFilePath
  {
  NSString *Path = [NSBundle mainBundle].resourcePath ;
  Path = [Path stringByAppendingPathComponent: @"Datos"];

  return [Path stringByAppendingPathComponent:@"Marcas.txt"];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona una marca con el código y toda la información
-(void) AddMark:(NSArray<NSString*> *) datos
  {
  MarkDatos* info = [MarkDatos InfoFromArray:datos];

  NSString* code = [datos[0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];
  _Marks[ code ] = info;

  _EsSust[info.Es] = code;
  _EnSust[info.En] = code;
  _ItSust[info.It] = code;
  _FrSust[info.Fr] = code;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el código de una marca conociendo el texto y el idioma
-(NSString*) CodeFromText:(NSString*) Txt In:(int) lng
  {
  NSMutableDictionary<NSString*, NSString*> *Sust;

  switch( lng )
    {
    case 0: Sust = _EsSust; break;
    case 1: Sust = _EnSust; break;
    case 2: Sust = _ItSust; break;
    case 3: Sust = _FrSust; break;

    default: return @"";
    }

  NSString* Mark = [[@"{" stringByAppendingString:Txt] stringByAppendingString:@"}"];

  NSString* Code = Sust[Mark];
  if( Code==nil ) Code = @"";

  return Code;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si existe una marca con el codigo dado
-(BOOL) Exist:(NSString*) code
  {
  return (_Marks[code] != nil);
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene informacion asociada a la marca con el codigo dado
-(MarkDatos*) Info:(NSString*) code
  {
  return _Marks[code];
  }

@end

//=============================================================================================================================================================
/// Mantiene la información relacionada con una marca
@implementation MarkDatos

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
//Crea informacion de la marca con un arreglo de cadenas
+(MarkDatos*) InfoFromArray:(NSArray<NSString*> *) datos
  {
  MarkDatos* obj = [MarkDatos new];

  obj->_Desc = [datos[1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];

  obj->_Es = [datos[2] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];
  obj->_En = [datos[3] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];
  obj->_It = [datos[4] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];
  obj->_Fr = [datos[5] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];

  return obj;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
//Obtiene la cadena de sustitución para un idioma dado
-(NSString*) StringForLang:(int) lng
  {
  switch( lng )
    {
    case 0: return _Es;
    case 1: return _En;
    case 2: return _It;
    case 3: return _Fr;
    }

  return @"";
  }

@end

//=============================================================================================================================================================

