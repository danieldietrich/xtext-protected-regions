grammar ProtectedRegionSupport;

@lexer::header {
  package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;
}

@parser::header {
  package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;
}

@members {
    private boolean comment;
}

document [IWritableDocument doc]
  @init {
    comment = false;
  }
  : block[doc]* EOF { doc.flush(); }
  ;

block [IWritableDocument doc]
  : C_START { if (!comment) { doc.save(comment); comment = true; } doc.dump("/*"); }
  | C_END   { if (comment) { doc.dump("*/"); doc.save(comment); comment = false; } }
  | OTHER   { doc.dump($OTHER.text); }
  ;
  
C_START : '/*' ;
C_END   : '*/' ;
OTHER   : ~(C_START | C_END);
