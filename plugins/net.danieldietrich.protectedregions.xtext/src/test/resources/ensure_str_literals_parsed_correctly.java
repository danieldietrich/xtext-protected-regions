package internal;

// Hack: Use our own Lexer superclass by means of import. 
// Currently there is no other way to specify the superclass for the lexer.
import org.eclipse.xtext.parser.antlr.Lexer;

@SuppressWarnings("all")
public class InternalMyDslLexer extends Lexer {
	
    // InternalMyDsl.g:152:11: ( '^' )? ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
	
    static final String[] DFA12_transitionS = {
            "\11\12\2\11\2\12\1\11\22\12\1\11\1\2\1\6\4\12\1\7\7\12\1\10"+
            "\12\5\7\12\7\4\1\1\22\4\3\12\1\3\1\4\1\12\32\4\uff85\12",
            "\1\13",
            "",
            "\32\14\4\uffff\1\14\1\uffff\32\14",
            "",
            "",
            "\0\17",
            "\0\17",
            "\1\20\4\uffff\1\21",
            "",
            "",
            "\1\23",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\24",
            "\1\25",
            "\12\14\7\uffff\32\14\4\uffff\1\14\1\uffff\32\14",
            ""
    };

    class DFA12 extends DFA {

        if ( (LA12_0=='\"') ) {s = 6;}

        else if ( (LA12_0=='\'') ) {s = 7;}

        else ( (LA12_0=='/') ) {s = 8;}
    }


}