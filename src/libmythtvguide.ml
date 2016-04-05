open Lwt
open Cohttp
open Cohttp_lwt
open Cohttp_lwt_unix
open Core

type program_recording_preferences = {
    status: int [@key "Status"];
    priority: int [@key "Priority"];
    startTs: int [@key "StartTs"];
    endTs: int [@key "EndTs"];
    recordId: int [@key "RecordId"];
    recGroup: int [@key "RecGroup"];
    playGroup: int [@key "PlayGroup"];
    recType: int [@key "RecType"];
    dupInType: int [@key "DupInType"];
    dupMethod: int [@key "DupMethod"];
    encoderId: int [@key "EncoderId"];
    profile: int [@key "Profile"];
} [@@deriving yojson { strict = false }];;

type program = {
    startTime: string [@key "StartTime"];
    endTime: string [@key "EndTime"];
    title: string [@key "Title"];
    subtitle: string [@key "SubTitle"];
    category: string [@key "Category"];
    catType: string [@key "CatType"];
    repeat: bool [@key "Repeat"];
    recording: program_recording_preferences
} [@@deriving yojson { strict = false }];;

type channel = {
    chanId: string [@key "ChanId"];
    chanNum: string [@key "ChanNum"];
    callSign: string [@key "CallSign"];
    iconURL: string [@key "IconURL"];
    channelName: string [@key "ChannelName"];
    programs: program list [@key "Programs"];
} [@@deriving yojson { strict = false }];;

type program_guide = {
    startTime: string [@key "StartTime"];
    endTime: string [@key "EndTime"];
    startChanId: string [@key "StartChanId"];
    endChanId: string [@key "EndChanId"];
    numOfChannels: int [@key "NumOfChannels"];
    details: bool [@key "Details"];
    count: int [@key "Count"];
    asOf: string [@key "AsOf"];
    version: string [@key "Version"];
    protoVer: string [@key "ProtoVer"];
} [@@deriving yojson { strict = false }];;

let get_guide (start_date: Core.Time.t) (end_date: Core.Time.t) : program_guide =
    let (start_str, end_str) = (
        Core.Time.format start_date "%Y-%m-%d'T'%H:%M:%S" ~zone:Core.Time.Zone.local,
        Core.Time.format end_date "%Y-%m-%d'T'%H:%M:%S" ~zone:Core.Time.Zone.local
    ) in
    let guide_url = Uri.of_string ("http://localhost:6544/Guide/GetProgramGuide?StartTime=" ^ start_str  ^ "&EndTime=" ^ end_str) in
    let headers = Cohttp.Header.of_list [("Accept", "application/json")] in
    Client.get ~headers:headers guide_url >>= fun (resp, body) -> 
    body |> Cohttp_lwt_body.to_string >|= fun body -> body |> Yojson.Safe.from_string |> program_guide_of_yojson

