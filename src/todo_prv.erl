-module('todo_prv').

-export([init/1, do/1, format_error/1]).

-define(PROVIDER, 'todo').
-define(DEPS, [app_discovery]).

%% ===================================================================
%% Public API
%% ===================================================================
-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
            {name, ?PROVIDER},            % The 'user friendly' name of the task
            {module, ?MODULE},            % The module implementation of the task
            {bare, true},                 % The task can be run by the user, always true
            {deps, ?DEPS},                % The list of dependencies
            {example, "rebar3 todo"}, % How to use the plugin
            {opts, []},                   % list of options understood by the plugin
            {short_desc, "example rebar3 plugin"},
            {desc, "example rebar3 plugin"}
    ]),
    rebar_api:info("IN ~p:init()", [?MODULE]),
    {ok, rebar_state:add_provider(State, Provider)}.


-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    rebar_api:info("IN ~p:do()", [?MODULE]),
    lists:foreach(fun check_todo_app/1, rebar_state:project_apps(State)),
    {ok, State}.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    rebar_api:info("IN ~p:format_error()", [?MODULE]),
    io_lib:format("~p", [Reason]).


check_todo_app(App) ->
    rebar_api:info("IN ~p:check_todo_app()", [?MODULE]),
    Path = filename:join(rebar_app_info:dir(App),"src"),
    Mods = find_source_files(Path),
    case lists:foldl(fun check_todo_mod/2, [], Mods) of
        [] -> ok;
        Instances -> display_todos(rebar_app_info:name(App), Instances)
    end.

find_source_files(Path) ->
    rebar_api:info("IN ~p:find_source_files()", [?MODULE]),
    [filename:join(Path, Mod) || Mod <- filelib:wildcard("*.erl", Path)].

check_todo_mod(ModPath, Matches) ->
    rebar_api:info("IN ~p:check_todo_mod()", [?MODULE]),
    {ok, Bin} = file:read_file(ModPath),
    case find_todo_lines(Bin) of
        [] -> Matches;
        Lines -> [{ModPath, Lines} | Matches]
    end.

find_todo_lines(File) ->
    rebar_api:info("IN ~p:todo_lines()", [?MODULE]),
    case re:run(File, "%+.*(TODO:.*)", [{capture, all_but_first, binary}, global, caseless]) of
        {match, DeepBins} ->     rebar_api:info("TODO found"), lists:flatten(DeepBins);
        nomatch ->     rebar_api:info("NO TODO's"), []
    end.

display_todos(App, []) -> 
    rebar_api:info("IN ~p:display_todos()", [?MODULE]),
    io:format("Application ~s~nHas no TODOs~n",[App]),
    ok;
display_todos(App, FileMatches) ->
    rebar_api:info("IN ~p:display()", [?MODULE]),
    io:format("Application ~s~n",[App]),
    [begin
      io:format("\t~s~n",[Mod]),
      [io:format("\t  ~s~n",[TODO]) || TODO <- TODOs]
     end || {Mod, TODOs} <- FileMatches],
    ok.
