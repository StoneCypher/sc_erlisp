
-module(sc_erlisp).





-export([

    eval/1,
      eval/2

]).





global_environment() ->

    todo.

                                                                                 



eval(Thing) ->

    eval(Thing, global_environment()).





eval_symbol_or_const(Thing, Env) ->

    case is_a(symbol, Thing) of                % whargarbl what the
        true  -> Env.find(Env, Thing)[Thing];  % whargarbl nonsense syntax todo fixme
        false -> Thing
    end.





eval( NotAList,                      Env ) when not is_list(NotAList) -> eval_symbol_or_const(Thing, Env);

eval( [<<"quote">>, Expr],           Env )                            -> Expr;
eval( [<<"if">>, Test, Conseq, Alt], Env )                            -> case eval(Test, Env) of true -> Conseq; _AnythingElse -> Alt end;
eval( [<<"set!">>, Var, Expr],       Env )                            -> Env.find(Env, Val)[Var] = eval(Expr, Env);  % whargarbl nonsense syntax todo fixme
eval( [<<"define">>, Var, Expr],     Env )                            -> Env[Var] = eval(Expr, Env);
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
    Proc(ExprRes).
