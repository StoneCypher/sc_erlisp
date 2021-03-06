
-module(sc_erlisp).

% http://people.csail.mit.edu/jaffer/r5rs_8.html





-export([

    global_environment/0,

    env_find/2,

    eval_symbol_or_const/2,

    eval/1,
      eval/2,

    to_binary/1,

    atomize/1,

    read/1,
      read_from/1,
      tokenize/1,

    run/1

]).





is_a_symbol(Number) when is_number(Number) ->

    false;


is_a_symbol( <<"#t">> ) ->

    false;


is_a_symbol( <<"#f">> ) ->

    false;


is_a_symbol(Thing) ->

    true.     % todo not sure if this is correct.





env_find(Env, Item) when is_atom(Item) ->

    env_find(Env, list_to_binary(atom_to_list(Item)));





env_find(Env, Item) ->

% todo this is wrong probably and needs to go to parent envs

    {ok, I} = maps:find(Item, Env),
    I.





member(Env, Item) ->

    {ok, I} = maps:find(Item, Env),
    I.





set_member_to(Env, Item, NewVal) ->

    todo.





global_environment() ->

    #{

        <<"not">>       => fun(<<"#f">>) -> <<"#t">>; (_) -> <<"#f">> end,
        <<"boolean?">>  => fun(<<"#f">>) -> <<"#t">>; (<<"#t">>) -> <<"#t">>; (_) -> <<"#f">> end,
        <<"eqv?">>      => fun(X,Y)      -> case (X == Y) of true -> <<"#t">>; _ -> <<"#f">> end end,  % todo whargarbl not an adequate impl
        <<"symbol?">>   => fun(X)        -> is_a_symbol(X) end,

        <<"+">>         => fun(X,Y)      -> X+Y end,   % todo whargarbl needs to take /* instead of /2
        <<"-">>         => fun(X,Y)      -> X-Y end,   % optional /*
        <<"*">>         => fun(X,Y)      -> X*Y end,   % todo whargarbl needs to take /* instead of /2
        <<"/">>         => fun(X,Y)      -> X/Y end,   % optional /*
        <<"abs">>       => fun(X)        -> abs(X) end,
        <<"quotient">>  => fun(X,Y)      -> X div Y end,
        <<"remainder">> => fun(X,Y)      -> X rem Y end,
        <<"modulo">>    => fun(X,Y)      -> X rem Y end,
        <<"expt">>      => fun(X,Y)      -> math:pow(X,Y) end,  % todo whargarbl add to tests - error: should return int for int,int -> int; returns float because c stdlib
        <<"sqrt">>      => fun(X)        -> math:sqrt(X) end,

        <<"min">>       => fun(X,Y)      -> min(X,Y) end,  % todo whargarbl needs to take /* instead of /2
        <<"max">>       => fun(X,Y)      -> max(X,Y) end,  % todo whargarbl needs to take /* instead of /2

        <<"floor">>     => fun(X)        -> sc_math:floor(X) end,
        <<"ceiling">>   => fun(X)        -> sc_math:ceil(X) end,
        <<"ceil">>      => fun(X)        -> sc_math:ceil(X) end,
        <<"truncate">>  => fun(X)        -> trunc(X) end,
        <<"trunc">>     => fun(X)        -> trunc(X) end,

        <<"zero?">>     => fun(0)        -> <<"#t">>; (0.0) -> <<"#t">>; (X) when is_number(X) -> <<"#f">> end,  % todo should this be typesafe?  is zero? 0.0 #t?
        <<"positive?">> => fun(X)        when X > 0, is_number(X) -> <<"#t">>; (X) when is_number(X) -> <<"#f">> end, 
        <<"negative?">> => fun(X)        when X < 0, is_number(X) -> <<"#t">>; (X) when is_number(X) -> <<"#f">> end, 
        <<"odd?">>      => fun(X)        when X rem 2 == 1 -> <<"#t">>; (X) when is_integer(X) -> <<"#f">> end,
        <<"even?">>     => fun(X)        when X rem 2 == 0 -> <<"#t">>; (X) when is_integer(X) -> <<"#f">> end,

        <<"gcd">>       => fun(X,Y)      -> sc_math:gcd(X,Y) end,  % todo whargarbl probably needs to take /* instead of /2
        <<"lcm">>       => fun(X,Y)      -> sc_math:lcm(X,Y) end   % todo whargarbl probably needs to take /* instead of /2

    }.  % todo

                                                                                 



%% @doc Evaluates a tokenized series of binaries as a scheme program in the global context.

eval(Thing) ->  % no environment?  pull the global one.

    eval(Thing, global_environment()).





%% @doc Evaluates a given individual symbol or constant in the context provided.

eval_symbol_or_const(Thing, Env) ->

    case is_a_symbol(Thing) of
        true  -> env_find(Env, Thing);
        false -> Thing
    end.





%% @doc Evaluates a tokenized series of binaries as a scheme program in the context provided.

eval( Atom,                          Env ) when is_atom(Atom)         -> eval(list_to_binary(atom_to_list(Atom)), Env);

eval( NotAList,                      Env ) when not is_list(NotAList) -> eval_symbol_or_const(NotAList, Env);

eval( [<<"quote">>, Expr],           Env )                            -> Expr;
eval( [<<"if">>, Test, Conseq, Alt], Env )                            -> case eval(Test, Env) of true -> Conseq; _AnythingElse -> Alt end;
eval( [<<"set!">>, Var, Expr],       Env )                            -> set_member_to(env_find(Env, Var), Var, eval(Expr, Env));  % whargarbl nonsense syntax todo fixme
eval( [<<"define">>, Var, Expr],     Env )                            -> set_member_to(Env, Var, eval(Expr, Env));
eval( [<<"lambda">>, Vars, Expr],    Env )                            -> todo;
eval( [<<"begin">> | Rem ],          Env )                            -> eval_begin_loop(Rem, Env);

eval( [X|_] = OSF,                   Env ) when X == <<"quote">>;
                                                X == <<"if">>;
                                                X == <<"set!">>;
                                                X == <<"define">>;
                                                X == <<"lambda">>     -> { error, "Wrong argument count to special form", OSF };
                                                % begin has no fixed length and is intentionally exlcuded here

eval( SimpleList, Env ) -> 

    [ Proc | ExprRes ] = [ eval(Item, Env) || Item <- SimpleList  ],
    apply(Proc, ExprRes).





eval_begin_loop(Items, Env) ->

    todo.





atomize(<<"+">>) -> <<"+">>;  % inexplicably, binary_to_integer( <<"+">> ) is zero.  ffs.
atomize(<<"-">>) -> <<"-">>;

atomize(X) ->

    case catch binary_to_integer(X) of
        {'EXIT', _} -> case catch binary_to_float(X) of
            {'EXIT', _} -> X;
            FResult     -> FResult
        end;
        IResult -> IResult
    end.





tokenize(X) when is_list(X) ->

    tokenize(list_to_binary(X));





tokenize(X) ->

    [
        B
    ||
        B <- binary:split(
                 binary:replace(
                    binary:replace(X, <<"(">>, <<" ( ">>, [global])
                , <<")">>, <<" ) ">>, [global])
             , <<" ">>, [global]),

        B =/= <<>>
    ].





read_from(Tokens) ->

    case { Parsed, Overflow } = read_from(Tokens, [], 0) of
        { _, [Item|_] } -> { error, unexpected_end_of_file };
        { P, [] } -> P
    end.





read_from([], [Work], 0) ->

    { Work, [] };





read_from([], Work, OpenParenCount) when OpenParenCount > 0 ->

    throw(unexpected_end_of_file);





read_from([ <<"(">> | Remainder ], Work, OpenParenCount) ->

    { Parsed, Overflow } = read_from(Remainder, [], OpenParenCount + 1),
    read_from(Overflow, [Parsed] ++ Work, OpenParenCount);





read_from([ <<")">> | Remainder ], Work, 0) ->

    throw(unexpected_close_parenthesis);





read_from([ <<")">> | Remainder ], Work, OpenParenCount) ->

    { lists:reverse(Work), Remainder };





read_from([ Token | Remainder ], Work, OpenParenCount) ->

    read_from(Remainder, [atomize(Token)]++Work, OpenParenCount).





read(X) ->

    read_from( tokenize(X) ).





run(X) ->

    eval(read(X)).





to_binary(Bin)   when is_binary(Bin)  -> Bin;
to_binary(Int)   when is_integer(Int) -> integer_to_binary(Int);
to_binary(Float) when is_float(Float) -> float_to_binary(Float);
to_binary(List)  when is_list(List)   -> list_to_binary([ <<"(">>, sc_list:between([ to_binary(L) || L <- List], <<" ">>), <<")">> ]).