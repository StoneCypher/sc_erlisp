
-module(sc_erlisp_tests).
-compile(export_all).

-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").





global_environment_test_() ->

    Has = fun(X) -> ?_assert(missing =/= sc_erlisp:env_find(sc_erlisp:global_environment(), X)) end,

    { "Global environment tests", [

	    { "Correctness tests", [
	        { "Is a map",                        ?_assert(true == is_map(sc_erlisp:global_environment())) },
	        { "Contains for atoms '+'",          Has( '+' ) },
	        { "Contains for binaries <<\"+\">>", Has( <<"+">> ) }
        ] },

	    { "Preamble tests", [

	        { "Preamble has +", Has( '+' ) },
	        { "Preamble has -", Has( '-' ) },
	        { "Preamble has *", Has( '*' ) },
	        { "Preamble has /", Has( '/' ) }

	    ] }
	] }.





read_test_() ->

    % todo stoch this
    X = [ <<"+">>,2, [ <<"/">>, 5,3 ] ],

    { "Read tests", [

        { "Round trip", ?_assert(X == sc_erlisp:read(sc_erlisp:to_binary(X))) }

    ] }.
