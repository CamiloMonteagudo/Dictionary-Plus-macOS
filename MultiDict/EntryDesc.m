//===================================================================================================================================================
//  EntryDesc.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/2/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "EntryDesc.h"
#import "AppData.h"
#import "MngMarks.h"

//===================================================================================================================================================
@interface EntryDesc()
  {
  NSString* Key;
  NSString* Datos;

  int Src;
  int Des;

  NSMutableArray<InfoMark*> * KeyMarks;
  NSMutableArray<InfoMark*> * DataMarks;
  }

@end

//===================================================================================================================================================
// Esta clase se encarga de manejar los datos de la entrada para mostrarlos en pantalla
@implementation EntryDesc
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto EntryDict con las partes de una entrada del diccionario
+(EntryDesc*) DescWithEntry:(EntryDict*) entry Src:(int)src Des:(int)des;
  {
  EntryDesc* Desc = [EntryDesc new];

  Desc->Key   = entry.Key;
  Desc->Datos = entry.Datos;
  Desc->Src   = src;
  Desc->Des   = des;

  [Desc getMarksWithInfo:entry.InfoMarks];                            // Inicializa las marcas
  return Desc;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static NSCharacterSet * mrk1 = [NSCharacterSet characterSetWithCharactersInString:@"{"];
static NSCharacterSet * mrk2 = [NSCharacterSet characterSetWithCharactersInString:@"}"];
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la ubicación de las marcas en la llave y en los datos
- (void) getMarksWithInfo:(NSString*) infoMarks
  {
  [self GetKeyMarksWithInfo: infoMarks ];
  if( _nMarks==0 ) return;

  DataMarks = [NSMutableArray<InfoMark*> new];
  for( ;; )
    {
    NSInteger len = Datos.length;

    NSRange rgFind = NSMakeRange(0, len);

    NSUInteger iniMark = [Datos rangeOfCharacterFromSet:mrk1 options:0 range:rgFind].location;
    if( iniMark == NSNotFound ) break;

    rgFind = NSMakeRange(iniMark+1, len-iniMark-1);
    NSUInteger endMark = [Datos rangeOfCharacterFromSet:mrk2 options:0 range:rgFind ].location;

    NSRange rgMid = NSMakeRange(iniMark+1, endMark-iniMark-1);

    NSString* ini  = [Datos substringToIndex:   iniMark   ];
    NSString* mid  = [Datos substringWithRange: rgMid     ];
    NSString* end  = [Datos substringFromIndex: endMark+1 ];

    Datos = [[ini stringByAppendingString:mid] stringByAppendingString:end];

    [DataMarks addObject:[InfoMark InfoWithText:mid InLang:Des AndPos:iniMark] ];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de las marcas de la llave
- (void) GetKeyMarksWithInfo:(NSString*) info
  {
  _nMarks = 0;
  KeyMarks = [NSMutableArray<InfoMark*> new];

  if( info.length == 0 ) return;

  int len = (int)info.length;                                 // Longitud de la cadena que contiene los datos
  for( int i=0; i<len; )                                      // Recorre todos los caracteres de los datos
    {
    int pos1 = HexDigit(i++, info) * 16;                      // Primer digito de la posición
    int pos2 = HexDigit(i++, info);                           // Segundo digito de la posición

    int chrs1 = HexDigit(i++, info) * 16;                     // Primer digito del número de catacteres
    int chrs2 = HexDigit(i++, info);                          // Segundo digito del número de caracteres

    int pos = pos1 + pos2;
    int chrs = chrs1 + chrs2;

    NSRange rgTxt = NSMakeRange(pos, chrs);
    NSString* Txt = [Key substringWithRange:rgTxt];

    [KeyMarks addObject:[InfoMark InfoWithText: Txt InLang:Src AndPos:pos] ];
    ++_nMarks;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la información de la marca con el indice 'idx'
-(InfoMark*) MarkAtIndex:(int) idx
  {
  return KeyMarks[idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto para la marca de sustitución 'code' en la llave de la entrada
- (NSString*) TextInKeyForMark:(NSString*) code
  {
  for (InfoMark* info in KeyMarks)
    if( [info.Code isEqualToString:code] )
      return info.Txt;

  return @"";
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto para la marca de sustitución 'code' en los datos de la entrada
- (NSString*) TextInDataForMark:(NSString*) code
  {
  for (InfoMark* info in DataMarks)
    if( [info.Code isEqualToString:code] )
      return info.Txt;

  return @"";
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Sustituye la marca 'code' con el texto 'srcTxt' en la llave y 'desTxt' en los datos
- (void) ResplaceMark:(NSString*) code TextSrc:(NSString*) srcTxt TextDes:(NSString*) desTxt
  {
  [self ResplaceKeyMark:code Text:srcTxt];
  [self ResplaceDataMark:code Text:desTxt];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Sustituye la marca 'code' con el texto 'Txt' en la llave
- (void) ResplaceKeyMark:(NSString*) code Text:(NSString*) Txt
  {
  NSInteger dtIdx = 0;
  NSInteger newLen = Txt.length;

  for( InfoMark* info in KeyMarks)
    {
    info.Pos += dtIdx;

    if( [info.Code isEqualToString:code] )
      {
      NSString* sIni = [Key substringToIndex:info.Pos];
      NSString* sEnd = [Key substringFromIndex:info.Pos+info.Len];

      Key = [[sIni stringByAppendingString:Txt] stringByAppendingString:sEnd];

      dtIdx += (newLen - info.Len);

      info.Len = newLen;
      info.Txt = Txt;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Sustituye la marca 'code' con el texto 'Txt' en los datos
- (void) ResplaceDataMark:(NSString*) code Text:(NSString*) Txt
  {
  NSInteger dtIdx = 0;
  NSInteger newLen = Txt.length;

  for( InfoMark* info in DataMarks)
    {
    info.Pos += dtIdx;

    if( [info.Code isEqualToString:code] )
      {
      NSString* sIni = [Datos substringToIndex:info.Pos];
      NSString* sEnd = [Datos substringFromIndex:info.Pos+info.Len];

      Datos = [[sIni stringByAppendingString:Txt] stringByAppendingString:sEnd];

      dtIdx += (newLen - info.Len);

      info.Len = newLen;
      info.Txt = Txt;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el indice donde comienza la traducción, si no lo encuentra retorna -1
- (NSInteger) IndexTrdInString:(NSString*) txt
  {
  return [txt rangeOfString:LGFlag(Des)].location;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static CGFloat FontSize   = [NSFont systemFontSize];                                                        // Tamaño de la letras estandard del sistema

static NSFont* fontReg   = [NSFont systemFontOfSize:     FontSize+1];                                       // Fuente para los significados
static NSFont* fontBold  = [NSFont boldSystemFontOfSize: FontSize+2];                                       // Fuente para los textos resaltados dentro del significado
static NSFont* fontSmall = [NSFont boldSystemFontOfSize: FontSize];                                         // Fuente mas pequeña dentro del significado

static NSColor* ColKeys  = [NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.00];                      // Color para las definiciones del tipo gramatical
static NSColor* ColBody  = [NSColor blackColor];                                                             // Color para el cuerpo del significado
static NSColor* ColGray  = [NSColor darkGrayColor];                                                          // Color atenuado para las palabras que pueden cambiar dentro del significado
static NSColor* ColType  = [NSColor colorWithRed:0.06 green:0.06 blue:0.80 alpha:1.00];                      // Color para las definiciones del tipo gramatical
static NSColor* ColAttr  = [NSColor colorWithRed:0.20 green:0.40 blue:0.20 alpha:1.00];                      // Color para los atributos asociados al significado

static NSDictionary* attrKey   = @{ NSFontAttributeName:fontBold,  NSForegroundColorAttributeName:ColKeys };
static NSDictionary* attrBody  = @{ NSFontAttributeName:fontReg,   NSForegroundColorAttributeName:ColBody };
static NSDictionary* attrNote  = @{ NSFontAttributeName:fontReg,   NSForegroundColorAttributeName:ColGray };
static NSDictionary* attrSust  = @{ NSFontAttributeName:fontReg,   NSForegroundColorAttributeName:ColGray };
static NSDictionary* attrType  = @{ NSFontAttributeName:fontSmall, NSForegroundColorAttributeName:ColType };
static NSDictionary* attrAttr  = @{ NSFontAttributeName:fontSmall, NSForegroundColorAttributeName:ColAttr };

static NSMutableParagraphStyle* Paraf = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
static NSDictionary*        attrParrf = @{ NSParagraphStyleAttributeName:Paraf };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una cadena en formato enrriquecido que representa la entrada
- (NSAttributedString*) getAttrString
  {
  Paraf.paragraphSpacing = 6;

  NSString* des = [@"\U00002029" stringByAppendingString:LGFlag(Des)];

  NSMutableAttributedString* srcFlag = [[NSMutableAttributedString alloc] initWithString:LGFlag(Src)  attributes:attrParrf];
  NSMutableAttributedString* TxtKey  = [[NSMutableAttributedString alloc] initWithString:Key attributes:attrKey  ];

  NSMutableAttributedString* desFlag = [[NSMutableAttributedString alloc] initWithString:des    attributes:attrParrf];
  NSMutableAttributedString* sDatos  = [[NSMutableAttributedString alloc] initWithString:Datos attributes:attrBody ];

  [self SetAttribInKeyString:TxtKey];
  [self SetAttribInDataString:sDatos];

  [srcFlag appendAttributedString: TxtKey];
  [srcFlag appendAttributedString: desFlag];
  [srcFlag appendAttributedString: sDatos];
  
  return srcFlag;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone los atributos para la llave de la entrada
- (void) SetAttribInKeyString:(NSMutableAttributedString*) Txt
  {
  for( NSInteger i=0; i<KeyMarks.count; ++i )
    {
    InfoMark* Mark = KeyMarks[i];

    NSRange rg = NSMakeRange( Mark.Pos, Mark.Len );

    [Txt setAttributes:attrSust range:rg];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static NSCharacterSet * stopChrs2 = [NSCharacterSet characterSetWithCharactersInString:@".[<(;|"];
static NSCharacterSet * spaceChr  = [NSCharacterSet characterSetWithCharactersInString:@" "];
static NSCharacterSet * closeChr2 = [NSCharacterSet characterSetWithCharactersInString:@">"];
static NSCharacterSet * closeChr3 = [NSCharacterSet characterSetWithCharactersInString:@")"];

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone los atributos para una cadena de datos de una palabra
- (void) SetAttribInDataString:(NSMutableAttributedString*) Txt
  {
  for( NSInteger i=0; i<DataMarks.count; ++i )
    {
    InfoMark* Mark = DataMarks[i];

    NSRange rg = NSMakeRange( Mark.Pos, Mark.Len );

    [Txt setAttributes:attrSust range:rg];
    }

  NSString*     str = Txt.string;
  NSInteger     len = str.length;
  NSInteger ZoneIni = 0;                    // Inicio de la zona que se esta analizando
  int       ZoneTyp = 1;                    // Tipo de zona, 0- Significados, 1-Atributos tipo gramatical, 2- Atributos significado

  for( NSInteger idx=0; idx<len-1; ++idx)
    {
    NSRange rg = NSMakeRange(idx, len-idx);
    idx = [str rangeOfCharacterFromSet:stopChrs2 options:0 range:rg].location;
    if( idx==NSNotFound || idx>=len-1 ) return;

    switch( [str characterAtIndex: idx] )
      {
        case '.':
        {
        if( ZoneTyp==0 ) break;

        rg = NSMakeRange(ZoneIni, idx-ZoneIni+1);
        if( [str rangeOfCharacterFromSet:spaceChr options:0 range:rg].location != NSNotFound )
          break;

        if( idx>=1 && [str characterAtIndex:idx-1]=='f' && [str characterAtIndex:idx+1]==' ' )
          {
          [Txt setAttributes:attrAttr range: NSMakeRange(idx-1, 2) ];

          ZoneIni = idx+2;
          ZoneTyp = 2;
          continue;
          }

        if( idx>=2 && [str characterAtIndex:idx-2]=='p' && [str characterAtIndex:idx-1]=='l' && [str characterAtIndex:idx+1]==' ' )
          {
          [Txt setAttributes:attrAttr range: NSMakeRange(idx-2, 3) ];

          ZoneIni = idx+2;
          ZoneTyp = 2;
          continue;
          }

        if( ZoneTyp==1 )
          {
          if( [str characterAtIndex:idx+1]==' ')
            {
            [Txt setAttributes:attrType range:rg];

            ZoneIni = idx+2;
            ZoneTyp = 2;
            }
          continue;
          }

        break;
        }

        case ';':
        ZoneIni = idx+2;
        ZoneTyp = 2;
        continue;

        case '|':
        ZoneIni = idx+2;
        ZoneTyp = 1;
        continue;

        case '<':
        idx = [self SetAtrib:attrNote In:Txt From:idx To:closeChr2];
        if( idx==NSNotFound )return;
        break;

        case '(':
        idx = [self SetAtrib:attrAttr In:Txt From:idx To:closeChr3];
        if( idx==NSNotFound )return;
        ZoneIni = idx+1;
        continue;
      }

    ZoneTyp = 0;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el atributo 'Attr' desde 'idx' hasta el primer caracter de 'charSet' en la cadena 'Txt'
- (NSInteger) SetAtrib:(NSDictionary*) Attr In:(NSMutableAttributedString*) Txt From:(NSInteger) idx To:(NSCharacterSet *) chtSet
  {
  NSString* str = Txt.string;
  NSInteger len = str.length;
  NSInteger ini = idx;

  NSRange rg = NSMakeRange(idx, len-idx);
  idx = [str rangeOfCharacterFromSet:chtSet options:0 range:rg].location;
  if( idx==NSNotFound ) return idx;
  
  rg = NSMakeRange(ini, idx-ini+1);
  [Txt setAttributes:Attr range:rg];
  
  return idx+1;
  }

@end

//===================================================================================================================================================
@implementation InfoMark

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(InfoMark*) InfoWithText:(NSString*) Txt InLang:(int) lng AndPos:(NSUInteger) pos
  {
  InfoMark* Info = [InfoMark new];

  Info->_Pos  = pos;
  Info->_Len  = Txt.length;

  MngMarks* Marks = [MngMarks Get];

  Info->_Code = [Marks CodeFromText:Txt In: lng];
  Info->_Txt  = Txt;

  return Info;
  }

@end

//===================================================================================================================================================
