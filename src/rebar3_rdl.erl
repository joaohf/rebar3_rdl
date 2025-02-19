-module(rebar3_rdl).

-export([init/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    %% This adds the new compiler module:
    State1 = rebar_state:prepend_compilers(State, [rebar3_rdl_compiler]),
    %% If needing the new compiler module to take precedence over
    %% other ones (i.e. generating .erl files from another format):
    %% State2 = rebar_state:append_compilers(State1, [translator_mod]),
    {ok, State1}.
