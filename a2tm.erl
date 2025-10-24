%%====================================================================
%% @doc  a2tm – Simple aria2 download manager written in Erlang
%%
%%      This version removes the external configuration file and
%%      places all tunable parameters as compile‑time macros at the
%%      beginning of the file.  Edit the values below and recompile
%%      to change the behaviour.
%%====================================================================

-module(a2tm).
-compile(export_all).          % Export everything for quick testing.
                               % In production export only the needed functions.

%%--------------------------------------------------------------------
%%  CONFIGURATION – MODIFY THESE VALUES TO CUSTOMIZE THE TOOL
%%--------------------------------------------------------------------
-define(VERSION,                "0.1").
-define(MAX_SPEED_DOWNLOAD,     "300K").
-define(MAX_SPEED_UPLOAD,       "5K").
-define(BT_MAX_PEERS,           "25").
-define(MAX_DOWNLOADS,          "25").
-define(ENCRYPTION,             yes).          % yes | no
-define(RPC,                    yes).          % yes | no
-define(RPC_PORT,               "6800").
-define(SEEDING,                yes).          % yes | no
-define(SEED_RATIO,             "0.0").
-define(ARIA2_DEBUG,            no).           % yes | no
-define(DEBUG_LEVEL,            "info").
-define(FILE_ALLOCATION,        "none").
-define(CA_CERTIFICATE,         no).           % yes | no
-define(CA_CERTIFICATE_FILE,    "/etc/ssl/certs/ca-certificates.crt").

%% Default directories – automatically chosen according to OS
-define(DEFAULT_TORRENT_FOLDER,
        case os:type() of
            {unix,_}  -> filename:join(os:getenv("HOME"), "A2TM");
            {win32,_} -> "C:\\A2TM"
        end).

-define(DEFAULT_TORRENT_FILES,   filename:join(?DEFAULT_TORRENT_FOLDER, "files")).
-define(DEFAULT_TORRENT_DOWNLOAD,
        case os:type() of
            {unix,_}  -> filename:join(os:getenv("HOME"), "A2TM");
            {win32,_} -> "C:\\A2TM"
        end).

%%--------------------------------------------------------------------
%%  Helper functions
%%--------------------------------------------------------------------
clear_screen() ->
    case os:type() of
        {unix,_}  -> "clear";
        {win32,_} -> "cls";
        _         -> io:format("Error: unable to clear screen~n")
    end.

ensure_dir(Dir) ->
    case file:read_file_info(Dir) of
        {ok,_}          -> ok;
        {error,enoent}  -> file:make_dir(Dir);
        {error,Reason}  -> io:format("Could not create ~p: ~p~n", [Dir, Reason])
    end.

run_aria2(Cmd) ->
    io:format("Running: ~s~n", [Cmd]),
    os:cmd(Cmd).

%%--------------------------------------------------------------------
%%  Environment preparation
%%--------------------------------------------------------------------
setup_environment() ->
    ensure_dir(?DEFAULT_TORRENT_FOLDER),
    ensure_dir(?DEFAULT_TORRENT_FILES),
    ensure_dir(?DEFAULT_TORRENT_DOWNLOAD),

    %% Create minimal config files so aria2c can find them
    create_if_missing(filename:join(?DEFAULT_TORRENT_FOLDER, "aria2.conf")),
    create_if_missing(filename:join(?DEFAULT_TORRENT_FOLDER, "a2tm.conf")).

create_if_missing(Path) ->
    case file:read_file_info(Path) of
        {ok,_} -> ok;
        {error,enoent} ->
            ok = file:write_file(Path, <<"# Auto‑generated placeholder file\n">>),
            ok
    end.

%%--------------------------------------------------------------------
%%  Build the command‑line options for aria2c
%%--------------------------------------------------------------------
build_options() ->
    SpeedOpts = "--max-overall-download-limit=" ++ ?MAX_SPEED_DOWNLOAD ++
                " --max-overall-upload-limit="   ++ ?MAX_SPEED_UPLOAD,
    PeerOpts  = "--bt-max-peers=" ++ ?BT_MAX_PEERS,

    CertOpts = case ?CA_CERTIFICATE of
                   yes -> " --ca-certificate=" ++ ?CA_CERTIFICATE_FILE;
                   no  -> ""
               end,

    EncOpts = case ?ENCRYPTION of
                  yes -> " --bt-min-crypto-level=arc4 --bt-require-crypto=true";
                  no  -> " --bt-require-crypto=false"
              end,

    RpcOpts = case ?RPC of
                  yes -> " --enable-rpc --rpc-listen-all=true "
                         ++ "--rpc-allow-origin-all --rpc-listen-port=" ++ ?RPC_PORT;
                  no  -> " --rpc-listen-all=false"
              end,

    SeedOpts = case ?SEEDING of
                   yes -> " --seed-ratio=" ++ ?SEED_RATIO;
                   no  -> " --seed-time=0"
               end,

    DebugOpts = case ?ARIA2_DEBUG of
                    yes -> " --console-log-level=" ++ ?DEBUG_LEVEL;
                    no  -> ""
                end,

    OtherOpts = "-V -j " ++ ?MAX_DOWNLOADS ++
                " --file-allocation=" ++ ?FILE_ALLOCATION ++
                " --auto-file-renaming=false --allow-overwrite=false" ++
                CertOpts,

    lists:flatten([EncOpts, " ", SpeedOpts, " ", PeerOpts, " ",
                   RpcOpts, " ", SeedOpts, " ", DebugOpts, " ", OtherOpts]).

%%--------------------------------------------------------------------
%%  Main entry point
%%--------------------------------------------------------------------
main() ->
    setup_environment(),
    menu_loop().

menu_loop() ->
    clear_screen(),
    io:format("\n# a2tm v~s ##\n\n", [?VERSION]),
    io:format(" # Download folder   : ~s\n", [?DEFAULT_TORRENT_DOWNLOAD]),
    io:format(" # Torrent files     : ~s/*.torrent\n", [?DEFAULT_TORRENT_FILES]),
    io:format(" # Speed (down/up)   : ~s/~s\n",
              [?MAX_SPEED_DOWNLOAD, ?MAX_SPEED_UPLOAD]),
    io:format(" # Encryption        : ~p\n", [?ENCRYPTION]),
    io:format(" # RPC               : ~p (port ~s)\n", [?RPC, ?RPC_PORT]),
    io:format(" # Max peers / jobs  : ~s/~s\n",
              [?BT_MAX_PEERS, ?MAX_DOWNLOADS]),
    io:format(" # Seeding           : ~p (ratio ~s)\n", [?SEEDING, ?SEED_RATIO]),
    io:format(" # Debugging         : ~p (~s)\n", [?ARIA2_DEBUG, ?DEBUG_LEVEL]),
    io:format("\n# Options:\n"),
    io:format(" r -> Run aria2 service\n"),
    io:format(" l -> List .torrent files\n"),
    io:format(" m -> Create .torrent from magnet link\n"),
    io:format(" q -> Quit\n\n"),

    Input = string:trim(io:get_line("# Choose option (r/l/m/q): ")),
    handle_option(Input).

handle_option("r") -> run_service();
handle_option("l") -> list_torrents();
handle_option("m") -> create_from_magnet();
handle_option("q") -> io:format("\n# Exiting…\n");
handle_option(_)   -> io:format("\n# Invalid option\n"),
                     timer:sleep(1500),
                     menu_loop().

%%--------------------------------------------------------------------
%%  Option implementations
%%--------------------------------------------------------------------
run_service() ->
    clear_screen(),
    io:format("\n# Starting aria2c (Ctrl‑C to stop)…\n"),

    %% Generate a list of .torrent files
    ListCmd = case os:type() of
                  {unix,_}  -> "ls " ++ ?DEFAULT_TORRENT_FILES ++ "/*.torrent > aria2-list.txt";
                  {win32,_} -> "dir /B " ++ ?DEFAULT_TORRENT_FILES ++ "\\*.torrent > aria2-list.txt"
              end,
    os:cmd(ListCmd),

    Options = build_options(),
    Cmd = "aria2c " ++ Options ++ " -i aria2-list.txt -d " ++ ?DEFAULT_TORRENT_DOWNLOAD,
    run_aria2(Cmd),

    io:format("\n# Process finished\n"),
    timer:sleep(1000),
    menu_loop().

list_torrents() ->
    clear_screen(),
    io:format("\n# List of torrents that will be loaded:\n"),
    io:format("\n"),
    ListCmd = case os:type() of
                  {unix,_}  -> "ls " ++ ?DEFAULT_TORRENT_FILES ++ "/ | grep '.torrent'";
                  {win32,_} -> "dir /B " ++ ?DEFAULT_TORRENT_FILES ++ "\\*.torrent"
              end,
    io:format("~s~n", [os:cmd(ListCmd)]),
    io:format("\n# List of incomplete downloads:\n"),
    io:format("\n"),
    IncompCmd = case os:type() of
                    {unix,_}  -> "ls " ++ ?DEFAULT_TORRENT_DOWNLOAD ++ "/ | grep '.aria2'";
                    {win32,_} -> "dir /B " ++ ?DEFAULT_TORRENT_DOWNLOAD ++ "\\*.aria2"
                end,
    io:format("~s~n", [os:cmd(IncompCmd)]),

    _ = io:get_line("# Press ENTER to return "),
    menu_loop().

create_from_magnet() ->
    clear_screen(),
    Magnet = string:trim(io:get_line("# Enter magnet link (quotes optional): ")),
    Cmd = "aria2c --bt-metadata-only=true --bt-save-metadata=true -d "
          ++ ?DEFAULT_TORRENT_FILES ++ " " ++ Magnet,
    run_aria2(Cmd),
    _ = io:get_line("# Press ENTER to return "),
    menu_loop().
