
-module(sc_erlisp).





-export([

    eval/1,
      eval/2

]).





is_a(Kind, Thing) ->

    todo.





env_find(Env, Item) ->

    todo.





member(Env, Item) ->

    todo.





set_member_to(Env, Item, NewVal) ->

    todo.





global_environment() ->

    todo.

                                                                                 



eval(Thing) ->  % no environment?  pull the global one.

    eval(Thing, global_environment()).





eval_symbol_or_const(Thing, Env) ->

    case is_a(symbol, Thing) of                % whargarbl what the
        true  -> member(env_find(Env, Thing), Thing);  % whargarbl nonsense syntax todo fixme, was Env.find(Thing)[Thing]
        false -> Thing
    end.





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
    Proc(ExprRes).





eval_begin_loop(Items, Env) ->

    todo.
