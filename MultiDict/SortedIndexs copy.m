///===================================================================================================================================
//  SortedIndexs.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/9/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///===================================================================================================================================

#import "SortedIndexs.h"
#import "AppData.h"

///===================================================================================================================================
// Maneja indices organizados por su ranking, de un grupo de entradas al diccionario de palabras, frases y oraciones
@implementation SortedIndexs

///-----------------------------------------------------------------------------------------------------------------------------------
// Crea una lista vacia
+(SortedIndexs*) Empty
  {
  SortedIndexs* obj = [SortedIndexs new];

  obj->Query   = nil;
  obj->Entries = [NSMutableArray<EntrySort*> new];

  return obj;
  }

///-----------------------------------------------------------------------------------------------------------------------------------
/// Ordena los indices en el diccionario 'foundEntries', según la semejanza entre el query y la entrada correspondiente
+(SortedIndexs*) SortEntries:(FOUNDS_ENTRY*) foundEntries Query:(TextQuery*) query
  {
  SortedIndexs* obj = [SortedIndexs new];

  obj->Query   = query;
  obj->Entries = [NSMutableArray<EntrySort*> new];

  for( NSNumber* idxEntry in foundEntries)
    [obj AddEntry:idxEntry WithPos:foundEntries[idxEntry] ];

  return obj;
  }

///-----------------------------------------------------------------------------------------------------------------------------------
/// Cantidad de entradas ordenadas
-(int) Count{return (int)Entries.count; }

///-----------------------------------------------------------------------------------------------------------------------------------
// Adiciona una entrada y la coloca de acuerdo al ranking dado
-(void) AddEntry:(NSNumber*) idxEntry WithPos:(INT_LIST*) WrdsPos
  {
  int rank = [self RankForEntry:idxEntry AndWrdsPos:WrdsPos ];

  EntrySort* Entry = [EntrySort EntryWihtInfo:idxEntry.intValue Rank:rank WithPos:WrdsPos];
  NSRange       rg = NSMakeRange(0, Entries.count);

  NSUInteger idx = [Entries indexOfObject: Entry
                            inSortedRange: rg
                                  options: NSBinarySearchingInsertionIndex
                          usingComparator: ^NSComparisonResult( EntrySort *obj1, EntrySort* obj2 )
                                             {
                                             if( obj1->Rank > obj2->Rank ) return NSOrderedAscending;
                                             if( obj1->Rank < obj2->Rank ) return NSOrderedDescending;

                                             return NSOrderedSame;
                                             } ];



  [Entries insertObject:Entry atIndex:idx ];
  }

///-----------------------------------------------------------------------------------------------------------------------------------
/// Calcula el ranking de la entrada 'idxEntry'
-(int) RankForEntry:(NSNumber*) idxEntry AndWrdsPos:(INT_LIST*) WrdsPos
  {
  int words = (int)Dict.Items[idxEntry.intValue].nWrds;           // Numero de palabra de la llave

  int found = (int)WrdsPos.count;                                 // Cantidad de palabras encontradas
  int del   = (int)Query->Count - found;                          // Cantidad de palabras que hay quitar del query
  int add   = words - found;                                      // Cantidad de palabras que hay que añadir al query

  int desp   = 0;                                                 // Cantidad de desplazamientos que hay que realizar
  int offset = 0;                                                 // Separación de la frase respecto al inicio

  if( found>0 )                                                   // Si se encontraron palabras
    {
    offset = WrdsPos[0].intValue;                                 // Toma desplazamiento del inicio de la primera palabra
    for( int i=1; i<found; i++ )                                  // Recorre todas las demas palabras
      {
      int dt = WrdsPos[i].intValue-(offset+i);                    // Desplazamiento respecto a la posición que le corresponde
      if( dt<0 ) dt = -dt;                                        // Si es negativo, le quita el signo

      desp += dt;                                                 // Acumula todos los desplazamientos
      }
    }

  return found*2500 - 10*(del+add) - 150*(offset) - 2*desp;       // Calcula el ranking
//  return found*1000 - 10*(del+add) - 1*(offset) - 2*desp;       // Calcula el ranking
  }

@end

///===================================================================================================================================
/// <summary> Maneja la información asocida a una entrada del diccionario </summary>
@implementation EntrySort

+(EntrySort*) EntryWihtInfo:(int) idx Rank:(int) rank WithPos:(INT_LIST*) WrdsPos
  {
  EntrySort* obj = [EntrySort new];

  obj->Index   = idx;
  obj->Rank    = rank;
  obj->WrdsPos = WrdsPos;

  return obj;
  }

@end
