%% Copyright (c) 2024 João Henrique Ferreira de Freitas
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%

-module(rebar3_rdl_compiler).

-behaviour(rebar_compiler).

-export([
    context/1,
    needed_files/4,
    dependencies/3,
    compile/4,
    clean/2
]).

%% specify what kind of files to find and where to find them. Rebar3 handles
%% doing all the searching from these concepts.
context(AppInfo) ->
    Dir = rebar_app_info:dir(AppInfo),
    Mappings = [{".erl", filename:join([Dir, "src"])}],
    #{
        src_dirs => ["rdl"],
        include_dirs => [],
        src_ext => ".rdl",
        out_mappings => Mappings
    }.

needed_files(_, FoundFiles, Mappings, AppInfo) ->
    FirstFiles = [],

    %% Remove first files from found files
    RestFiles = [
        Source
     || Source <- FoundFiles,
        not lists:member(Source, FirstFiles),
        rebar_compiler:needs_compile(Source, ".erl", Mappings)
    ],

    Opts = rebar_opts:get(rebar_app_info:opts(AppInfo), rdl_opts, []),
    Opts1 = update_opts(Opts, AppInfo),

    {{FirstFiles, Opts1}, {RestFiles, Opts1}}.

dependencies(_, _, _) ->
    [].

compile(Source, [{_, SrcDir}], Config, Opts) ->
    case find_peakrdl(Opts) of
        false ->
            rebar_api:error(
                "peakredl compiler not found. Make sure you have it installed and it is in your PATH",
                []
            ),
            rebar_compiler:error_tuple(Source, [], [], Opts);
        Exec ->
            DestSourceFile = filename:rootname(filename:basename(Source)),
            DestSource = make_dest_module_source(DestSourceFile, Opts),
            %rebar_api:console("Source: ~p", [DestSourceFile]),

            % For each .rdl two files are generated: .erl and .hrl
            Command = Exec ++ " beam -o " ++ SrcDir ++ "/" ++ DestSource ++ " " ++ Source,

            %rebar_api:console("Compiling: ~p", [Command]),
            {ok, Res} = rebar_utils:sh(Command, [abort_on_error]),
            rebar_compiler:ok_tuple(Source, Res, Config, Opts)
    end.

clean(RdlFiles, AppInfo) ->
    Opts = rebar_opts:get(rebar_app_info:opts(AppInfo), rdl_opts, []),
    AppDir = rebar_app_info:dir(AppInfo),
    RDLs = lists:flatmap(
        fun(RDL) ->
            make_dest_sources(filename:rootname(filename:basename(RDL)), Opts)
        end,
        RdlFiles
    ),
    ok = rebar_file_utils:delete_each([filename:join([AppDir, "src", RDL]) || RDL <- RDLs]).

find_peakrdl(Opts) ->
    case {os:find_executable("peakrdl"), proplists:is_defined(peakrdl, Opts)} of
        {false, true} ->
            proplists:get_value(peakrdl, Opts);
        {Exec, false} ->
            Exec;
        {_Exec, true} ->
            proplists:get_value(peakrdl, Opts)
    end.

update_opts(Opts, _AppInfo) ->
    Opts.

make_dest_module_source(DestSourceFile, Opts) ->
    lists:flatten([
        proplists:get_value(module_name_prefix, Opts, []),
        DestSourceFile,
        proplists:get_value(module_name_suffix, Opts, []),
        ".erl"
    ]).

make_dest_sources(DestSourceFile, Opts) ->
    M = make_dest_module_source(DestSourceFile, Opts),
    H = lists:flatten([
        proplists:get_value(module_name_prefix, Opts, []),
        DestSourceFile,
        proplists:get_value(module_name_suffix, Opts, []),
        ".hrl"
    ]),
    [M, H].
