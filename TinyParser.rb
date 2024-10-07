#
#  Parser Class
#
load "TinyLexer.rb"
load "TinyToken.rb"
load "AST.rb"

class Parser < Lexer

    def initialize(filename)
        super(filename)
        consume()
    end

    def consume()
        @lookahead = nextToken()
        while(@lookahead.type == Token::WS)
            @lookahead = nextToken()
        end
    end

    def match(dtype)
        if (@lookahead.type != dtype)
            puts "Expected #{dtype} found #{@lookahead.text}"
			@errors_found+=1
        end
        consume()
    end

    def program()
    	@errors_found = 0
		
		p = AST.new(Token.new("program","program"))
		
	    while( @lookahead.type != Token::EOF)
            p.addChild(statement())
        end
        
        puts "There were #{@errors_found} parse errors found."
      
		return p
    end

    def statement()
		stmt = AST.new(Token.new("statement","statement"))
        if (@lookahead.type == Token::PRINT)
			stmt = AST.new(@lookahead)
            match(Token::PRINT)
            stmt.addChild(exp())
        else
            stmt = assign()
        end
		return stmt
    end

    def exp()
        term = term()
        etail = etail()
        if (etail == nil)
            return term
        else
            etail.addChild(term)
            return etail
        end
    end

    def term()
        fctr = factor()
        ttail = ttail()
        if (ttail == nil)
            return fctr
        else
            ttail.addChild(fctr)
            return ttail
        end
    end

    def factor()
        fct = AST.new(Token.new("factor","factor"))
        if (@lookahead.type == Token::LPAREN)
            match(Token::LPAREN)
            fct = exp()
            if (@lookahead.type == Token::RPAREN)
                match(Token::RPAREN)
            else
				match(Token::RPAREN)
            end
        elsif (@lookahead.type == Token::INT)
            fct = AST.new(@lookahead)
            match(Token::INT)
        elsif (@lookahead.type == Token::ID)
            fct = AST.new(@lookahead)
            match(Token::ID)
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            @errors_found+=1
            consume()
        end
		return fct
    end

    def ttail()
        if (@lookahead.type == Token::MULTOP)
            multiply = AST.new(@lookahead)
            match(Token::MULTOP)
            multiply.addChild(factor())
            multiply.addChild(ttail())
            return multiply
        elsif (@lookahead.type == Token::DIVOP)
            divide = AST.new(@lookahead)
            match(Token::DIVOP)
            divide.addChild(factor())
            divide.addChild(ttail())
            return divide
		else
			return nil
        end
    end

    def etail()
        if (@lookahead.type == Token::ADDOP)
            add = AST.new(@lookahead)
            match(Token::ADDOP)
            add.addChild(term())
            add.addChild(etail())
            return add
        elsif (@lookahead.type == Token::SUBOP)
            subtract = AST.new(@lookahead)
            match(Token::SUBOP)
            subtract.addChild(term())
            subtract.addChild(etail())
            return subtract
		else
			return nil
        end
    end

    def assign()
        assgn = AST.new(Token.new("assignment","assignment"))
		if (@lookahead.type == Token::ID)
			idtok = AST.new(@lookahead)
			match(Token::ID)
			if (@lookahead.type == Token::ASSGN)
				assgn = AST.new(@lookahead)
				assgn.addChild(idtok)
            	match(Token::ASSGN)
				assgn.addChild(exp())
        	else
				match(Token::ASSGN)
			end
		else
			match(Token::ID)
        end
		return assgn
	end
end