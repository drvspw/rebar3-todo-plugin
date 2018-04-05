-module('todo').

-export([init/1]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    rebar_api:info("IN ~p:init()", [?MODULE]),
    {ok, State1} = 'todo_prv':init(State),
    {ok, State1}.
