///=============================================================================================================================================================
//  TextQueryPlus.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///=============================================================================================================================================================

#import "AppData.h"
#import "TextQueryPlus.h"

static TextQueryPlus* LastQuery;            // Ultima consulta utilizada
static NSString* LastStrQuery;              // Texto de la última consulta utilizada
static NSString* LastStrParse;              // Texto de la última consulta analizada

///=============================================================================================================================================================
@implementation TextQueryPlus

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea un objeto, con la cadena de busqueda
+(TextQueryPlus*) QueryWithText:(NSString*) sQuery
  {
  sQuery = [sQuery lowercaseString];                        // Lleva todas las palabras a minusculas
  if( [sQuery isEqualToString:LastStrQuery] )
    return LastQuery;

  TextQueryPlus* query = [TextQueryPlus QuerySimpleWithText:sQuery];

  [query FillDatos];

  LastStrQuery = sQuery;
  LastQuery = query;

  return query;
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea un objeto, con la cadena de busqueda
+(TextQueryPlus*) QuerySimpleWithText:(NSString*) sQuery
  {
  TextQueryPlus* query = [TextQueryPlus new];

  [query ParseWithText:sQuery];
  return query;
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Reinicializa la clase
+(void) Reset
  {
  LastQuery = nil;
  LastStrQuery = @"";
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Analiza la cadena 'sQuery' y separa las palabras a buscar
-(void) ParseWithText:(NSString*) sQuery
  {
  if( [sQuery isEqualToString:LastStrParse] ) return;

  Items = [NSMutableArray new];

  NSScanner* sc = [NSScanner scannerWithString:sQuery];
  sc.charactersToBeSkipped = wrdSep;

  while( !sc.isAtEnd )
    {
    NSString* Wrd;
    [sc scanUpToCharactersFromSet:wrdSep intoString:&Wrd];

    NSInteger pos = sc.scanLocation-Wrd.length;
    NSRange    rg = NSMakeRange(pos, Wrd.length);

    WrdQuery *wrdQ = [WrdQuery WithWrd:Wrd AndRange:rg];

    [Items addObject:wrdQ];
    }

  LastStrParse = sQuery;
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Llena los datos del query según el ultimo query utilizado
-(void) FillDatos
  {
  if( LastQuery == nil ) return;

  int nWrds = (int)Items.count;                             // Número de palabras en la consulta
  for( int i=0; i<nWrds; ++i )                              // Recorre todas las palabras
    {
    WrdQuery* wQry = Items[i];

    [self GetForOldQueryWrd:wQry];
    }
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Llena los datos la palabra 'wQry' si esta en el query viejo
-(void) GetForOldQueryWrd:(WrdQuery*) wQry1
  {
  NSString* Wrd1 = wQry1->Words[0];                         // Obtiene primera palabra de los datos nuevos

  int nWrds = (int)LastQuery->Items.count;                  // Número de palabras en la consulta vieja
  for( int i=0; i<nWrds; ++i )                              // Recorre todas las palabras
    {
    WrdQuery* wQry2 = LastQuery->Items[i];
    NSString* Wrd2 = wQry2->Words[0];                       // Obtiene la primera palabra de los datos viejos

    if( [Wrd1 isEqualToString:Wrd2] )                        // Si las dos palabras son iguales
      {
      for( int j=1; j<wQry2->Words.count; ++j )              // Recorre todos los sinonimos de la palabra
        {
        NSString* wrd  = wQry2->Words[j];                    // Toma la palabra actual

        [wQry1->Words addObject:wrd];                        // La adicona a los datos nuevos
        }
      }
    }
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Busca palabras del query usando el diccionario de indices 'dictIndexs'
- (FOUNDS_ENTRY*) FindWords
  {
  FOUNDS_ENTRY* EntrysPos = [FOUNDS_ENTRY new];             // Entradas y posiciones de palabras en la entrada

  int nWrds = (int)Items.count;                             // Número de palabras en la consulta
  for( int i=0; i<nWrds; ++i )                              // Recorre todas las palabras
    {
    WrdQuery* wQry = Items[i];
    wQry->Entries = [NSMutableSet<NSNumber*> new];

    int nSin = (int)wQry->Words.count;                     // Número de sinonimos de la palabra

    for( int j=0; j<nSin; ++j )                             // Recorre todos los sinonimos de la palabra
      {
      NSString* wrd  = wQry->Words[j];                      // Toma la palabra a buscar
                wrd  = QuitaAcentos(wrd, LGSrc);            // Le quita los acentos

      EntryIndex* WrdData = DictIdx.Words[wrd];             // Obtiene todas las entradas donde esta la palabra

      if( WrdData==nil ) continue;                          // No esta en el diccionario de indices de palabras, la salta

      for( int k=0; k<WrdData.Count; ++k)                     // Recorre todas las entradas donde esta la palabra
        {
        int iEntry = WrdData.Entrys[k];                       // Obtiene el indice de la entrada donde esta la palabra
        if( iEntry==131946 || iEntry==131947)
          iEntry=iEntry;

        NSNumber* idx = GET_NUMBER( iEntry );                 // La convierte a un objeto

        if( [wQry->Entries containsObject:idx]  )             // Ya fue encontrada una de las palabras del grupo en la entrada
          continue;                                           // Salta la palabra

        [wQry->Entries addObject:idx];                        // Adiciona la entrada

        INT_LIST *WrdsPos = EntrysPos[idx];                   // Busca si la entrada ya existe

        if( WrdsPos==nil )                                    // Si no hay ninguna palabra en esa entrada
          {
          WrdsPos = [INT_LIST new];                           // Crea una nueva lista de posiciones de palabras
          EntrysPos[idx] = WrdsPos;                           // Adiciona la lista a diccionario de entradas
          }

        [WrdsPos addObject:GET_NUMBER(WrdData.Pos[k])];       // Adiciona la posición a la lista posiciones de entrada idx
        }
      }
    }

  return EntrysPos;                                         // Retorna lista de entradas, con las posiciones de las palabras encontradas
  }


@end
///=============================================================================================================================================================

@implementation WrdQuery

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea un objeto, la primera palabra y el rango donde esta
+(WrdQuery*) WithWrd:(NSString*) wrd AndRange:(NSRange) rg
  {
  WrdQuery* wrdQ = [WrdQuery new];

  wrdQ->Words = [NSMutableArray new];
  [wrdQ->Words addObject:wrd];
  wrdQ->Pos = rg;

  return wrdQ;
  }


@end
///=============================================================================================================================================================
