type program_recording_preferences = {
    status: string ;
    priority: string ;
    startTs: string ;
    endTs: string ;
    recordId: string ;
    recGroup: string ;
    playGroup: string ;
    recType: string ;
    dupInType: string ;
    dupMethod: string ;
    encoderId: string ;
    profile: string ;
} 
val program_recording_preferences_of_yojson : Yojson.Safe.json -> (program_recording_preferences, string) result
val program_recording_preferences_to_yojson : program_recording_preferences -> Yojson.Safe.json 

type program = {
    startTime: Prelude.Time_Yojson_adapter.t ;
    endTime: Prelude.Time_Yojson_adapter.t ;
    title: string ;
    subtitle: string ;
    category: string ;
    catType: string ;
    repeat: string ;
    recording: program_recording_preferences option ;
}
val program_of_yojson : Yojson.Safe.json -> (program, string) result
val program_to_yojson : program -> Yojson.Safe.json 

type channel = {
    chanId: string ;
    chanNum: string ;
    callSign: string ;
    iconURL: string ;
    channelName: string ;
    programs: program list ;
}
val channel_of_yojson : Yojson.Safe.json -> (channel, string) result
val channel_to_yojson : channel -> Yojson.Safe.json 

type program_guide = {
    asOf: string ;
    count: string ;
    details: string ;
    startTime: Prelude.Time_Yojson_adapter.t ;
    endTime: Prelude.Time_Yojson_adapter.t ;
    channels: channel list ;
}
val program_guide_of_yojson : Yojson.Safe.json -> (program_guide, string) result
val program_guide_to_yojson : program_guide -> Yojson.Safe.json 

type guide_response = {
    guide: program_guide ;
} 
val guide_response_of_yojson : Yojson.Safe.json -> (guide_response, string) result
val guide_response_to_yojson : guide_response -> Yojson.Safe.json 

val get_guide : ?channel_filter:(string option) -> ?program_name_filter:(string option) -> ?host:string -> Core.Time.t -> Core.Time.t -> [`Error of string | `Ok of program_guide ] Lwt.t 
