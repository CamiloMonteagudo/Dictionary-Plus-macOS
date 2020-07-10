//===================================================================================================================================================
//  DatosView.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 3/1/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "DatosView.h"
#import "ZoneDatosView.h"
#import "MarkView.h"
#import "EntryDesc.h"
#import "ConjCore.h"

//===================================================================================================================================================
// Boton con cursor de la manito
@implementation MyButton

- (void)resetCursorRects
  {
  if( self.enabled ) [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
  else               [self addCursorRect:self.bounds cursor:[NSCursor arrowCursor]];
  }

@end

//===================================================================================================================================================
// Editor personalizado para saber cuando se selecciona una zona de datos
@implementation MyEdit

- (void)mouseDown:(NSEvent *)theEvent
  {
  [ZoneDatosView SelectDatos: (DatosView*)self.superview];

  [super mouseDown:theEvent];
  }

@end

//===================================================================================================================================================
// Vista para mostrar los datos de una entrada en el diccionario
@interface DatosView()
  {
  MyEdit* Text;                                     // Texto de la tradución
  MyButton*   btnSust;                              // Botón para mostrar/quitar zona de sustutución de palabras en los datos

  NSTrackingRectTag TrackTag;                       // Rectangulo donde debe estar el mouse para que se muestren los botones

  NSInteger HSust;                                  // Altura del recuadro de sustitución
  NSInteger HText;                                  // Altura del recuadro de texto

  NSBox*    SustBox;                                // Recuadro donde se pone los datos de sustitución de palabras

  EntryDesc* Entry;                                 // Descripcion de la entrada en el diccionario

  NSMutableArray<MarkView*> *Marks;                 // Controles para cambiar las marcas

  CGFloat wSustData;                                // Contiene el mayor ancho de los datos de los textos de sustitución en la entrada
  }

@end

//===================================================================================================================================================
@implementation MarkNum
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
 // Crea objeto con los datos de la entrada 'Idx' en el diccionario actual
+ (MarkNum*) Create
  {
  MarkNum* obj = [MarkNum new];
  
  obj.Count = 1;
  obj.Now   = 1;
  
  return obj;
  }
  
@end

//===================================================================================================================================================
static NSImage* imgOpenSust;
static NSImage* imgCloseSust;

//===================================================================================================================================================
// Vista donde se ponen los datos de una palabra
@implementation DatosView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea objeto con los datos de la entrada 'Idx' en el diccionario actual
+ (DatosView*) DatosForIndex:(NSInteger) Idx With:(CGFloat) w
  {
  EntryDict* Entry = [Dict getDataAt: Idx];                       // Obtiene los datos de la entrada en el diccionario general

  return [DatosView DatosForEntry:Entry Src:LGSrc Des:LGDes With:w];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea objeto con los datos de la entrada 'Idx'
+ (DatosView*) DatosForEntry:(EntryDict*) Entry Src:(int)src Des:(int)des With:(CGFloat) w
  {
  if( imgOpenSust == nil )
    {
    imgOpenSust  = [NSImage imageNamed:@"OpenSust"];
    imgCloseSust = [NSImage imageNamed:@"CloseSust"];
    }

  DatosView* Datos = [[DatosView alloc] init];                    // Crea vista de datos nueva
  Datos.src = src;
  Datos.des = des;

  [Datos CreateTextWithEntry:Entry];                              // Crea e inicializa los controles

  [Datos ResizeWithWidth:w];                                      // Dimensiona adecuadamente los controles

  return Datos;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hace que el sistema de cordenada sea el normal
- (BOOL)isFlipped
  {
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea todas las subviews que van dentro de la zona de datos
- (void) CreateTextWithEntry:(EntryDict *) entry
  {
  Text = [[MyEdit alloc] init];                                   // TextView para poner la descricción de los datos

  Text.backgroundColor = [NSColor clearColor];                    // Pone color trasparente (Se usa el fondo de DatosView)
  Text.editable = FALSE;                                          // Pone que el texto no se puede editar

  Entry = [EntryDesc DescWithEntry:entry Src:_src Des:_des];

  [Text.textStorage setAttributedString: [Entry getAttrString]];  // Le pone el contenido al TextView
  [self addSubview:Text];                                         // Adiciona el TextView a DatosView

  Text.delegate = self;                                           // Pone este objeto como delegado del Textview

  if( Entry.nMarks>0  )                                           // Si hay marcas
    [self CreateSustButton];                                      // Pone el boton para sustituir las marcas
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Ocurre cada vez que se cambia la selección del texto
- (void)textViewDidChangeSelection:(NSNotification *)notification
  {
  [Ctrller DisenableBtns:TRD_WRD|CONJ_WRD];

  int lang;
  NSString* selTxt = [self getSelWordAndLang:&lang];
  if( selTxt.length==0 ) return;

  if( [ConjCore IsVerbWord:selTxt InLang:lang] )
    [Ctrller EnableBtns:CONJ_WRD];

  if( lang==_des && [selTxt rangeOfCharacterFromSet:wrdSep].location == NSNotFound )
    [Ctrller EnableBtns:TRD_WRD];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra seleccionada y el idioma
- (NSString*) getSelWordAndLang:(int *)lang
  {
  NSRange rg = Text.selectedRange;                                     // Obtiene el rango selecciondo
  if( rg.length==0 ) return @"";                                       // Si hay no hace nada

  NSString* selTxt = [Text.string substringWithRange:rg];              // Obtiene el texto seleccionado
  
  selTxt = [selTxt stringByReplacingOccurrencesOfString:LGFlag(_src) withString:@"" ];      // Quita las banderitas
  selTxt = [selTxt stringByReplacingOccurrencesOfString:LGFlag(_des) withString:@"" ];

  NSInteger iDes   = [Entry IndexTrdInString:Text.string];             // Obtiene el indice donde comienza la traducción
  *lang = ( rg.location>iDes )? _des: _src;                            // Determina el idioma del texto seleccionado
  
  return selTxt;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Copia el texto seleccionado o la traducción al portapapeles
- (void) CopyText
  {
  NSString* Txt;                                                        // Texto a copiar
  
  NSRange rg = Text.selectedRange;                                      // Obtiene el rango selecciondo
  if( rg.length==0 )                                                    // No hay texto seleccionado
    {
    NSInteger iDes = [Entry IndexTrdInString:Text.string];             // Obtiene el indice donde comienza la traducción
    if( iDes<=0 ) return;
    
    rg = NSMakeRange(iDes, Text.string.length-iDes);                    // Rango de donde empieza la traducción hasta el final
    }
  
  Txt = [Text.string substringWithRange:rg];                            // Obtiene el texto a copiar
  
  Txt = [Txt stringByReplacingOccurrencesOfString:LGFlag(_src) withString:@"" ];      // Quita las banderitas
  Txt = [Txt stringByReplacingOccurrencesOfString:LGFlag(_des) withString:@"" ];
  
  NSPasteboard *gpBoard = [NSPasteboard generalPasteboard];             // Obtiene ep pasteboard
  
  [gpBoard clearContents];                                              // Limpia el contenido anterior
  
  [gpBoard writeObjects: @[Txt] ];                                      // Escribe el objeto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita estos datos de la lista
//- (void)OnDelItem:(NSButton *)sender
//  {
//  NSView* parent = self.superview;
//
//  [self removeFromSuperview];
//
//  [parent resizeWithOldSuperviewSize: NSMakeSize(0, 0)];
//  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton para mostrar/ocultar los datos de sustitución
- (void) CreateSustButton
  {
  NSRect frm = NSMakeRect(10,1, WBTNS, WBTNS );                   // Rectangulo para los botones

  btnSust = [[MyButton alloc] initWithFrame:frm];

  [btnSust setButtonType: NSMomentaryPushInButton];
  btnSust.bordered = FALSE;
  //btnSust.hidden = true;

  btnSust.target = self;
  btnSust.action = @selector(OnSustWords:);

  [self addSubview:btnSust];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Oculta los controles de sustitución
- (void)OnSustWords:(NSButton *)sender
  {
  if( HSust==0 ) [self CreateSustBoxView ];
  else           HSust = -HSust;

  [ZoneDatosView SelectDatos:self];
  
  [self.superview resizeWithOldSuperviewSize: NSMakeSize(0, 0)];
  }

static NSCharacterSet * Nums = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un recuadro con los controles de sustitución de marcadores
- (void) CreateSustBoxView
  {
  NSRect frm = NSMakeRect(0,0, 30, 300 );

  SustBox = [[NSBox alloc] initWithFrame:frm];
  SustBox.title = NSLocalizedString(@"Sustituciones", nil);

  [self addSubview:SustBox];

  Marks = [NSMutableArray<MarkView*> new];

  HSust = 23;                                                     // Altura minima del recuadro para sustitución
  wSustData = 0;                                                  // Ancho maximo para las vistas con datos de sustitución
  
  NSMutableDictionary<NSString*,MarkNum*>* dicNum = [self GetNumMarkInfo];
  
  for( int i=0; i<Entry.nMarks; ++i )
    {
    InfoMark* info = [Entry MarkAtIndex:i];
    MarkNum*   mrk = dicNum[ [info.Code stringByTrimmingCharactersInSet:Nums] ];

    MarkView* view = [MarkView CreateWithMark: info.Code MarkNum:mrk InView:self];

    [SustBox addSubview:view];

    [Marks addObject:view];

    if( view.frame.size.width > wSustData )
      wSustData = view.frame.size.width;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la información sobre el numero de marcas de cada tipo
- (NSMutableDictionary<NSString*,MarkNum*>*) GetNumMarkInfo
  {
  NSMutableDictionary<NSString*,MarkNum*>* dicNum = [NSMutableDictionary<NSString*,MarkNum*> new];
  for( int i=0; i<Entry.nMarks; ++i )
    {
    InfoMark* info = [Entry MarkAtIndex:i];
    NSString* Cod  = [info.Code stringByTrimmingCharactersInSet:Nums];
    
    MarkNum* mrk = dicNum[Cod];
    
    if( mrk== nil ) dicNum[Cod] = [MarkNum Create];
    else            ++mrk.Count;
    }
  
  return dicNum;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto para la marca de sustitución 'code' en la llave de la entrada
- (NSString*) TextInKeyForMark:(NSString*) code
  {
  return [Entry TextInKeyForMark: code];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto para la marca de sustitución 'code' en los datos de la entrada
- (NSString*) TextInDataForMark:(NSString*) code
  {
  return [Entry TextInDataForMark: code];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Sustituye la marca 'code' con el texto 'srcTxt' en la llave y 'desTxt' en los datos
- (void) ResplaceMark:(NSString*) code TextSrc:(NSString*) srcTxt TextDes:(NSString*) desTxt
  {
  [Entry ResplaceMark:code TextSrc:srcTxt TextDes:desTxt];

  [Text.textStorage setAttributedString: [Entry getAttrString]];  // Le pone el contenido al TextView

  NSView* parent = self.superview;
  [parent resizeWithOldSuperviewSize: NSMakeSize(0, 0)];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas dentro de la zona de datos
- (CGFloat) ResizeWithWidth:(CGFloat) w
  {
  w -= (2*SEP);

  CGFloat wTxt = w-(2*SEP);
  CGFloat y = SEP;                                          // Altura donde va la proxima vista

  Text.frame = NSMakeRect(SEP, y, wTxt, 40 );               // Inicial del texto

  [Text sizeToFit];                                         // Determina el tamaño real del texto
  HText = Text.frame.size.height+0.5;                       // Calcula la altura real del texto
  y += HText + SEP;

  if( Entry.nMarks>0  )                                     // Si hay marcas
    [self SustButtonPositionX:w Y:y];                       // Posiciona el boton para sustituir las marcas

  if( HSust>0 )                                             // Si hay controles de sustitución
    {
    [self ResizeSustBoxWidth:wTxt AndPos:y];                // Redimensiona cuadro de sustitución completo

    y += HSust + SEP;                                       // Avanza la y en la altura de recuadro
    SustBox.hidden = false;                                 // Muestra el recuadro de sustitución
    }
  else                                                      // Si no hay controles de sustitución
    SustBox.hidden = true;                                  // Oculta el recuadro de sustitución

  y += SEP;                                                 // Separación entre los datos
  self.frame = NSMakeRect(SEP, 0, w, y);                    // Rectangulo para el recuadro de datos
  return y;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Posiciona correctamente el boton de mostrar/ocultar el botón de sustituicón de marcas
- (void) SustButtonPositionX:(CGFloat)x Y:(CGFloat) y
  {
  [btnSust setFrameOrigin: NSMakePoint(x-WBTNS-SEP, y-HBTNS) ];   // Mueve el boton

  if( HSust>0 ) btnSust.image = imgCloseSust;                 // Si el cuadro de sustitución esta visible, pone icon de ocultar
  else          btnSust.image = imgOpenSust;                  // Si el cuadro de sustitución esta oculto, pone icon de mostrar
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimenciona el recuadro con los controles de sustitución de marcas de acuerdo al ancho disponible
- (void) ResizeSustBoxWidth:(CGFloat) w AndPos:(CGFloat) yPos
  {
  int nCols = (w+SEP)/(wSustData+SEP);                      // Número de columnas de datos a mostrar para al ancho dado
  if( nCols==0 ) nCols = 1;                                 // Cuando los datos no caben en una columna

  int nRows = ((int)Marks.count+(nCols-1))/nCols;           // Número de filas de datos a mostrar

  CGFloat x, y = SEP + nRows*(HSUST_DATA+SEP);              // Altura superior de la zona de datos

  HSust = y + 23;                                           // Altura del recuadro de todos los datos
  SustBox.frame = NSMakeRect(SEP, yPos, w, HSust );         // Posiciona y posiciona el recuadro de datos

  int i = 0;                                                // Inidice del dato a posicionar
  for( int row=0; row<nRows; ++row )                        // Recorre todas la filas de datos
    {
    y -= (HSUST_DATA+SEP);                                  // Define la posición en y de los datos de la fila
    x = 0;                                                  // Pone la x al inicio de la fila

    for( int col=0; col<nCols; ++col )                      // Recorre la columna
      {
      if( i>=Marks.count ) break;                           // Si no hay datos por posicnar, termina

      Marks[i++].FrameOrigin = NSMakePoint(x, y);           // Posiciona la vista y pasa al proximo dato

      x += (wSustData+SEP);                                 // Avanza la posición en la x
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el fondo de la zona
- (void)drawRect:(NSRect)dirtyRect
  {
  [super drawRect:dirtyRect];

  NSRect rc = self.bounds;
  rc.size.height -= SEP;

  [[NSColor darkGrayColor] set];
  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:10 yRadius:10 ] fill];

  rc = NSInsetRect(rc, 1, 1);

  if( self == [ZoneDatosView SelectedDatos] ) [SelColor set];
  else                                        [[NSColor whiteColor] set];

  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:9 yRadius:9 ] fill];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
  {
  [ZoneDatosView SelectDatos:self];
  }

////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Pone el tracking rect cuando se adiciona la vista a la ventana
//- (void)viewDidMoveToWindow
//  {
//  [self SetTrackingView];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Quita el tracking rect cuando se quita la vista de la ventana
//- (void)viewWillMoveToWindow:(NSWindow *)newWindow
//  {
//  if( [self window] && TrackTag )
//    [self removeTrackingRect:TrackTag];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Redefine el tracking rect cuando se cambia el frame de la vista
//- (void)setFrame:(NSRect)frame
//  {
//  [super setFrame:frame];
//  [self SetTrackingView];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Redefine el tracking rect cuando se cambia la zona de dibujo de la vista
//- (void)setBounds:(NSRect)bounds
//  {
//  [super setBounds:bounds];
//  [self SetTrackingView];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Pone todo el area de la vista como un tracking rect
//- (void) SetTrackingView
//  {
//  if( [self window] && TrackTag )
//    [self removeTrackingRect:TrackTag];
//
//  TrackTag = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Cuando el mouse entra a la vista, muestra los botones de opciones
//- (void)mouseEntered:(NSEvent *)theEvent
//  {
//  NSInteger x = _frame.frame.size.width - WBTNS - 3;
//
//  [btnDel setFrameOrigin: NSMakePoint(x, 3)];
//
//  btnDel.hidden = false;
//
//  if( Entry.nMarks>0  )
//    {
//    NSInteger y = HText + SEP - HBTNS;
//
//    [btnSust setFrameOrigin: NSMakePoint(x, y)];
//
//    if( HSust>0 ) btnSust.image = imgCloseSust;
//    else          btnSust.image = imgOpenSust;
//
//    btnSust.hidden = false;
//    }
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Cuando el mouse sale de la vista, oculta los botones de opciones
//- (void)mouseExited:(NSEvent *)theEvent
//  {
//  btnDel.hidden = true;
//  btnSust.hidden = true;
//  }

@end

//===================================================================================================================================================
