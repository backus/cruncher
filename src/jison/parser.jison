/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

.+":"$                   return 'HEADING'
[\s"$""%"]+              /* skip whitespace, units */
""+                    return 'FREE' /* horrible hack */
[0-9\.\,]+               return 'NUMBER'
"NaN"                    return 'NUMBER'
"="                      return 'EQUALS'
"*"                      return 'MUL'
"/"                      return 'DIV'
"-"                      return 'MINUS'
"+"                      return 'PLUS'
"^"                      return 'POW'
"("                      return 'PAREN_OPEN'
")"                      return 'PAREN_CLOSE'
<<EOF>>                  return 'EOF'
[^\s\(\)]+               /* skip text */

/lex

/* operator associations and precedence */

%left EQUALS
%left 'PLUS' 'MINUS'
%left 'MUL' 'DIV'
%left 'POW'
%left '%off'
%left UMINUS
%left UNIT

%start expressions

%% /* language grammar */

expressions
    : e EQUALS e EOF
        {return new Cruncher.Equation($e1, $e2);}
    | e EOF
        {return $1;}
    | EOF
        {return null;}
    ;

value
    : MINUS value %prec UMINUS
        {$$ = $value.neg();}
    | NUMBER
        {$$ = new Cruncher.Value(Number($NUMBER.replace(/,/g, '')));}
    | FREE
        {$$ = new Cruncher.Value(null);}
    ;

e
    : e PLUS e
        {$$ = $e1.op('PLUS', $e2);}
    | e MINUS e
        {$$ = $e1.op('MINUS', $e2);}
    | e MUL e
        {$$ = $e1.op('MUL', $e2);}
    | e DIV e
        {$$ = $e1.op('DIV', $e2);}
    | e POW e
        {$$ = $e1.op('POW', $e2);}
    | MINUS e %prec UMINUS
        {$$ = $e.op('MUL', new Cruncher.Expression(new Cruncher.Value(-1)));}
    | PAREN_OPEN e PAREN_CLOSE
        {$$ = $e;}
    | value
        {$$ = new Cruncher.Expression($value.setLocation(@value.first_column, @value.last_column));}
    | HEADING
        {$$ = null;}
    ;
