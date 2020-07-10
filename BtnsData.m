//
//  BtnsData.m
//  Translation Dictionary Spanish
//
//  Created by Admin on 5/1/18.
//  Copyright © 2018 BigXSoft. All rights reserved.
//

#import "BtnsData.h"
#import "AppData.h"

//===================================================================================================================================================
static NSImage* imgOpenSust;
static NSImage* imgCloseSust;

static BtnsData* BotnsBox;

static NSButton* btnSustMarks;

static NSButton* btnFindWord;
static NSButton* btnConjWord;

//===================================================================================================================================================
@interface BtnsData()
  {
  DatosView* DatView;                                // Cuadro que enecierra todos los datos de la llave
  }

@end

//===================================================================================================================================================
// Maneja la vista que contienes todos los botones que pueden actual sobre los datos seleccionados
@implementation BtnsData

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una vista con todos los botones de acción
+(BtnsData*) BtnsDataForView:(DatosView*) parent;
  {
  NSSize sz = parent.frame.size;
  
  NSRect frm = NSMakeRect( SEP, sz.height-(HBTNS+SEP+5), sz.width-(2*SEP) , HBTNS );
  
  if( BotnsBox == nil )
    {
    BotnsBox = [[BtnsData alloc] initWithFrame:frm];
  
    BotnsBox.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    
    imgOpenSust  = [NSImage imageNamed:@"OpenSust"];
    imgCloseSust = [NSImage imageNamed:@"CloseSust"];
    
    [BotnsBox AddBtns];
    }
  else
    {
    [BotnsBox removeFromSuperview];
  
    BotnsBox.frame = frm;
    }
  
  BotnsBox->DatView = parent;
  
  BotnsBox.subviews[0].hidden = !parent.HasSustMarks;
  
  if( parent.HasSustMarks )
    {
    if( parent.HSustMarks>0 ) btnSustMarks.image = imgCloseSust;
    else                      btnSustMarks.image = imgOpenSust;
    }
  
  [parent addSubview:BotnsBox];
  
  return BotnsBox;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)AddBtns
  {
  btnSustMarks = [self CreateBtnPos: -2 Image:@"OpenSust" ToolTip:@"TTipBtnSustMark" Action:@selector(OnSustWords:)];
  
  [self CreateBtnPos:-1 Image:@"DelMean" ToolTip:@"TTipBtnDelDato" Action:@selector(OnRemoveDatos:)];
  [self CreateBtnPos:-3 Image:@"Copy"    ToolTip:@"TTipBtnCopyText" Action:@selector(OnCopyText:)];
  
  btnConjWord = [self CreateBtnPos:-4 Image:@"ConjVerb2" ToolTip:@"TTipBtnCnjWord" Action:@selector(OnConjugaVerb:)];
  btnFindWord = [self CreateBtnPos:-5 Image:nil          ToolTip:@"TTipBtnTrdWord" Action:@selector(OnFindWord:)];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton para mostrar/ocultar los datos de sustitución
- (MyButton *) CreateBtnPos:(int) pos Image:(NSString*) sImg ToolTip:(NSString*) sTip Action:(SEL) actionFn
  {
  CGFloat x = WBTNS * pos;
  
  if( x!=0 ) x += (3 * (pos-1));
  if( x<0 ) x = self.frame.size.width + x;
  
  NSRect frm = NSMakeRect( x, 0, WBTNS, WBTNS );
  
  MyButton* btn = [[MyButton alloc] initWithFrame:frm];
  
  [btn setButtonType: NSMomentaryPushInButton];
  if( pos<0 )
    btn.autoresizingMask = NSViewMinXMargin;
  
  btn.bordered = FALSE;
  btn.toolTip  = NSLocalizedString(sTip, nil);
  
  if( sImg!=nil ) btn.image = [NSImage imageNamed:sImg];
  else            btn.title = @"";
  
  btn.target = self;
  btn.action = actionFn;
  
  [self addSubview:btn];
  return btn;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Oculta los controles de sustitución
- (void)OnSustWords:(NSButton *)sender
  {
  [DatView SustWords];
  
  if( DatView.HSustMarks>0 ) sender.image = imgCloseSust;
  else                       sender.image = imgOpenSust;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton de borrar los dato se una entrada
- (void) OnRemoveDatos:(NSButton *)sender
  {
  [Ctrller DelEntry];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el botón de copiar un texto
- (void) OnCopyText:(NSButton *)sender
  {
  [DatView CopyText];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el botón de conjugar un verbo
- (void) OnConjugaVerb:(NSButton *)sender
  {
  [Ctrller ConjWordOnData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el botón de buscar una palabra en el diccionario
- (void) OnFindWord:(NSButton *)sender
  {
  [Ctrller TrdWordOnData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Retorna los botones
+(NSButton*) BtnConjWord  { return btnConjWord;  }
+(NSButton*) BtnFindWord  { return btnFindWord;  }
+(NSButton*) BtnSustMarks { return btnSustMarks; }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//- (void)drawRect:(NSRect)dirtyRect
//  {
//  [super drawRect:dirtyRect];
//    
//  NSRect rc = self.bounds;
//    
//  [[NSColor redColor] set];
//  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:0 yRadius:0 ] fill];
//  }

@end
