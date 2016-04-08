open Prelude
open Core


(* Utilities for printing output nicely *)
module OutputUtils = struct
    type channel_program_pair = {c: Libmythtvguide.channel; p: Libmythtvguide.program}

    let group_programs_by_time (g: Libmythtvguide.program_guide) : channel_program_pair list Prelude.TimeUtils.TimeMap.t  =
        g.channels
        |> List.map (fun chan -> List.map (fun prog -> {c = chan; p = prog}) chan.Libmythtvguide.programs)
        |> List.flatten
        |> Prelude.TimeUtils.group_into_timemap (fun (cp: channel_program_pair) -> Prelude.TimeUtils.at_half_hour_floor (cp.p.startTime))
        |> Prelude.TimeUtils.TimeMap.map (List.sort (fun (cp1: channel_program_pair) (cp2: channel_program_pair) -> Prelude.numeric_string_compare cp1.c.chanNum cp2.c.chanNum))
    ;;

    let time_to_hour_and_minute_str (t: Core.Time.t) = 
        Core.Time.format t "%I:%M%p %a, %b %d" ~zone:Core.Time.Zone.local

    let channel_and_program_to_string (cp: channel_program_pair) : string =
        Printf.sprintf "(%5s) %8s: %s (at %s)" 
            cp.c.chanNum
            cp.c.channelName 
            cp.p.title 
            (time_to_hour_and_minute_str cp.p.startTime)

    let print_hour_lineup (hour: Core.Time.t) (lineup: channel_program_pair list) =
        let lineup_lines = List.map channel_and_program_to_string lineup in
        let lines_to_print = List.append [
            (time_to_hour_and_minute_str hour) ;
            "--------------------------------------------" ; 
        ] lineup_lines 
        in
        List.iter print_endline lines_to_print ;
        print_endline ""
end

(* CLI option stuff *)
module CLI = struct 
    let start_time = ref (Core.Time.now())
    let end_time = ref (Core.Time.add (!start_time) (Core.Time.Span.of_day 1.0))
    let channel_name_filter = ref (None)
    let program_name_filter = ref (None)

    let set_end_time (s: string)   = end_time := (Core.Time.of_string s)
    let set_start_time (s: string) = 
        start_time := (Core.Time.of_string s) ;
        end_time := (Core.Time.add (!start_time) (Core.Time.Span.of_day 1.0))
    let set_channel_name_filter (s: string) =
        if (String.length s) > 0 then
            channel_name_filter := (Some s)
        else
            channel_name_filter := None

    let set_program_name_filter (s: string) =
        if (String.length s) > 0 then
            program_name_filter := (Some s)
        else
            program_name_filter := None

    let cli_option_specs = [
        ("-s", (Arg.String set_start_time), "Start time in 'YYYY-MM-DD HH:MM:SS' format");
        ("-e", (Arg.String set_end_time), "End time in 'YYYY-MM-DD HH:MM:SS' format");
        ("-channelname", (Arg.String set_channel_name_filter), "Channel name filter");
        ("-programname", (Arg.String set_program_name_filter), "Program name filter");
    ]
end

let main (start_time: Core.Time.t) (end_time: Core.Time.t) (channel_name_filter: string option) (program_name_filter: string option) =
    let maybe_guide = Lwt_main.run (
        Libmythtvguide.get_guide 
            ~channel_filter:channel_name_filter 
            ~program_name_filter:program_name_filter
            start_time 
            end_time
    ) 
    in
    match maybe_guide with
    | `Ok guide     -> 
        OutputUtils.group_programs_by_time guide 
        |> Prelude.TimeUtils.TimeMap.iter OutputUtils.print_hour_lineup
    | `Error errmsg -> print_endline ("Error: " ^ errmsg)

let () =
    Arg.parse 
        CLI.cli_option_specs 
        (fun x -> 
            print_endline ("Unknown argument '" ^ x ^ "'");
            exit 1
        )
        "usage: mythtvguide [-s start_time] [-e end_time]" ;
    main (!CLI.start_time) (!CLI.end_time) (!CLI.channel_name_filter) (!CLI.program_name_filter)
