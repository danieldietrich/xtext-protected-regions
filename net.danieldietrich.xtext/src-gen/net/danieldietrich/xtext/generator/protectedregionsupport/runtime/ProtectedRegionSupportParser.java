// $ANTLR 3.2 Sep 23, 2009 12:02:23 src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g 2011-09-23 11:29:50

  package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class ProtectedRegionSupportParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "C_START", "C_END", "OTHER"
    };
    public static final int OTHER=6;
    public static final int EOF=-1;
    public static final int C_END=5;
    public static final int C_START=4;

    // delegates
    // delegators


        public ProtectedRegionSupportParser(TokenStream input) {
            this(input, new RecognizerSharedState());
        }
        public ProtectedRegionSupportParser(TokenStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        

    public String[] getTokenNames() { return ProtectedRegionSupportParser.tokenNames; }
    public String getGrammarFileName() { return "src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g"; }


        private boolean comment;



    // $ANTLR start "document"
    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:15:1: document[IWritableDocument doc] : ( block[doc] )* EOF ;
    public final void document(IWritableDocument doc) throws RecognitionException {

            comment = false;
          
        try {
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:19:3: ( ( block[doc] )* EOF )
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:19:5: ( block[doc] )* EOF
            {
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:19:5: ( block[doc] )*
            loop1:
            do {
                int alt1=2;
                int LA1_0 = input.LA(1);

                if ( ((LA1_0>=C_START && LA1_0<=OTHER)) ) {
                    alt1=1;
                }


                switch (alt1) {
            	case 1 :
            	    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:19:5: block[doc]
            	    {
            	    pushFollow(FOLLOW_block_in_document45);
            	    block(doc);

            	    state._fsp--;


            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);

            match(input,EOF,FOLLOW_EOF_in_document49); 
             doc.flush(); 

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "document"


    // $ANTLR start "block"
    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:22:1: block[IWritableDocument doc] : ( C_START | C_END | OTHER );
    public final void block(IWritableDocument doc) throws RecognitionException {
        Token OTHER1=null;

        try {
            // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:23:3: ( C_START | C_END | OTHER )
            int alt2=3;
            switch ( input.LA(1) ) {
            case C_START:
                {
                alt2=1;
                }
                break;
            case C_END:
                {
                alt2=2;
                }
                break;
            case OTHER:
                {
                alt2=3;
                }
                break;
            default:
                NoViableAltException nvae =
                    new NoViableAltException("", 2, 0, input);

                throw nvae;
            }

            switch (alt2) {
                case 1 :
                    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:23:5: C_START
                    {
                    match(input,C_START,FOLLOW_C_START_in_block66); 
                     if (!comment) { doc.save(comment); comment = true; } doc.dump("/*"); 

                    }
                    break;
                case 2 :
                    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:24:5: C_END
                    {
                    match(input,C_END,FOLLOW_C_END_in_block74); 
                     doc.dump("*/"); if (comment) { doc.save(comment); comment = false; } 

                    }
                    break;
                case 3 :
                    // src/net/danieldietrich/xtext/generator/protectedregionsupport/generator/ProtectedRegionSupport.g:25:5: OTHER
                    {
                    OTHER1=(Token)match(input,OTHER,FOLLOW_OTHER_in_block84); 
                     doc.dump((OTHER1!=null?OTHER1.getText():null)); 

                    }
                    break;

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        return ;
    }
    // $ANTLR end "block"

    // Delegated rules


 

    public static final BitSet FOLLOW_block_in_document45 = new BitSet(new long[]{0x0000000000000070L});
    public static final BitSet FOLLOW_EOF_in_document49 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_C_START_in_block66 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_C_END_in_block74 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_OTHER_in_block84 = new BitSet(new long[]{0x0000000000000002L});

}