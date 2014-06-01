
-module(sc_erlisp).





-export([

    global_environment/0,

    env_find/2,

    eval_symbol_or_const/2,

    eval/1,
      eval/2

]).





is_a_symbol(Number) when is_number(Number) ->

    false;

is_a_symbol(Thing) ->

    true.     % todo not sure if this is correct.





env_find(Env, Item) ->

    {ok, I} = maps:find(Item, Env),
    I.





member(Env, Item) ->

    todo.





set_member_to(Env, Item, NewVal) ->

    todo.





global_environment() ->

    #{

        <<"*">> => fun(X,Y) -> X*Y end

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
