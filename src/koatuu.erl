-module(koatuu).
-behaviour(application).
-behaviour(supervisor).
-include_lib("kvs/include/kvs.hrl").
-export([start/2, stop/1, init/1, debug/2, warning/2]).

debug(F, X) -> logger:debug(io_lib:format("KOATUU " ++ F, X)).
warning(F, X) -> logger:warning(io_lib:format("KOATUU " ++ F, X)).

stop(_) -> ok.
init([]) -> {ok, {{one_for_one, 5, 10}, []}}.
start(_, _) ->
    logger:add_handlers(koatuu),
    kvs:join([], #kvs{mod = kvs_rocks}),
    spawn(fun () -> koatuu_loader:boot() end),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).
