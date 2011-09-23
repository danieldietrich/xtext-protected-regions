// $ANTLR 3.2 Sep 23, 2009 12:02:23 src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g 2011-09-23 04:25:45

  package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class ProtectedRegionSupportLexer extends Lexer {
    public static final int OTHER=6;
    public static final int EOF=-1;
    public static final int C_START=4;
    public static final int C_END=5;

    // delegates
    // delegators

    public ProtectedRegionSupportLexer() {;} 
    public ProtectedRegionSupportLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public ProtectedRegionSupportLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g"; }

    // $ANTLR start "C_START"
    public final void mC_START() throws RecognitionException {
        try {
            int _type = C_START;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:28:9: ( '/*' )
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:28:11: '/*'
            {
            match("/*"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "C_START"

    // $ANTLR start "C_END"
    public final void mC_END() throws RecognitionException {
        try {
            int _type = C_END;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:29:9: ( '*/' )
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:29:11: '*/'
            {
            match("*/"); 


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "C_END"

    // $ANTLR start "OTHER"
    public final void mOTHER() throws RecognitionException {
        try {
            int _type = OTHER;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:30:9: (~ ( C_START | C_END ) )
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:30:11: ~ ( C_START | C_END )
            {
            if ( (input.LA(1)>='\u0000' && input.LA(1)<='\uFFFF') ) {
                input.consume();

            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OTHER"

    public void mTokens() throws RecognitionException {
        // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:1:8: ( C_START | C_END | OTHER )
        int alt1=3;
        int LA1_0 = input.LA(1);

        if ( (LA1_0=='/') ) {
            int LA1_1 = input.LA(2);

            if ( (LA1_1=='*') ) {
                alt1=1;
            }
            else {
                alt1=3;}
        }
        else if ( (LA1_0=='*') ) {
            int LA1_2 = input.LA(2);

            if ( (LA1_2=='/') ) {
                alt1=2;
            }
            else {
                alt1=3;}
        }
        else if ( ((LA1_0>='\u0000' && LA1_0<=')')||(LA1_0>='+' && LA1_0<='.')||(LA1_0>='0' && LA1_0<='\uFFFF')) ) {
            alt1=3;
        }
        else {
            NoViableAltException nvae =
                new NoViableAltException("", 1, 0, input);

            throw nvae;
        }
        switch (alt1) {
            case 1 :
                // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:1:10: C_START
                {
                mC_START(); 

                }
                break;
            case 2 :
                // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:1:18: C_END
                {
                mC_END(); 

                }
                break;
            case 3 :
                // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:1:24: OTHER
                {
                mOTHER(); 

                }
                break;

        }

    }


 

}