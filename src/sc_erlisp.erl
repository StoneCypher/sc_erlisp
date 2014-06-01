
-module(sc_erlisp).





-export([

    global_environment/0,

    env_find/2,

    eval_symbol_or_const/2,

    eval/1,
      eval/2,

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

        <<"not">>      => fun(<<"#f">>) -> <<"#t">>; (_) -> <<"#f">> end,
        <<"boolean?">> => fun(<<"#f">>) -> <<"#t">>; (<<"#t">>) -> <<"#t">>; (_) -> <<"#f">> end,
        <<"eqv?">>     => fun(X,Y)      -> case (X == Y) of true -> <<"#t">>; _ -> <<"#f">> end end,  % todo whargarbl not an adequate impl
        <<"symbol?">>  => fun(X)        -> is_a_symbol(X) end,

        <<"+">>        => fun(X,Y) -> X+Y end,
        <<"-">>        => fun(X,Y) -> X-Y end,
        <<"*">>        => fun(X,Y) -> X*Y end,
        <<"/">>        => fun(X,Y) -> X/Y end

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

    case { Parsed, Overflow } = read_from(Tokens, []) of
        { _, [Item|_] } -> { error, unexpected_end_of_file };
        { P, [] } -> P
    end.





read_from([], [Work]) ->

    { Work, [] };





read_from([ <<"(">> | Remainder ], Work) ->

    { Parsed, Overflow } = read_from(Remainder, []),
    read_from(Overflow, [Parsed] ++ Work );





read_from([ <<")">> | Remainder ], Work) ->

    { lists:reverse(Work), Remainder };





read_from([ Token | Remainder ], Work) ->

    read_from(Remainder, [atomize(Token)]++Work).





read(X) ->

    read_from( tokenize(X) ).





run(X) ->

    eval(read(X)).