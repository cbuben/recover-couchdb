-module(recover_couchdb).

-export([main/1]).

main([DbFilename]) ->
    couch_util:to_binary(just_confirming_that_couchdb_is_somewhere_out_there_in_space),

    PathToDbFile = filename:absname(DbFilename),
    DatabaseDir = filename:dirname(PathToDbFile),
    DatabaseName = filename:basename(DbFilename, ".couch"),

    % Fake the couch config.
    couch_config:start_link([]),
    couch_config:set("couchdb", "database_dir", DatabaseDir),
    couch_config:set("couchdb", "max_dbs_open", "100"),
    couch_config:set("log", "level", "debug"),
    couch_config:set("log", "file", DatabaseName ++ "_recovery.log"),

    % Start required OTP servers.
    application:start(crypto),
    couch_log:start_link(),
    couch_rep_sup:start_link(),
    couch_task_status:start_link(),
    couch_server:sup_start_link(),
    gen_event:start_link({local, couch_db_update}),

    RepairName = "lost+found/" ++ DatabaseName,
    io:format("Checking database: ~s~n", [DatabaseName]),
    io:format("Source file: ~s~n", [PathToDbFile]),
    io:format("Target file: ~s~n", [DatabaseDir ++ "/" ++ RepairName]),
    io:format("~n", []),
    couch_db_repair:make_lost_and_found(DatabaseName, PathToDbFile, couch_util:to_binary(RepairName)),
    %couch_db_repair:make_lost_and_found(DatabaseName),
    ok;

main(_) ->
    usage().

usage() ->
    io:format("usage: recover_couchdb /path/to/your/database.couch\n"),
    halt(1).

% vim: sw=4 sts=4 et
