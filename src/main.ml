open Prelude
open Core

let group_programs_by_time (g: Libmythtvguide.program_guide) : (Libmythtvguide.channel * Libmythtvguide.program) list Prelude.TimeUtils.TimeMap.t  =
    g.channels
    |> List.map (fun chan -> List.map (fun prog -> (chan, prog)) chan.Libmythtvguide.programs)
    |> List.flatten
    |> Prelude.TimeUtils.group_into_timemap (fun ((c: Libmythtvguide.channel), (p: Libmythtvguide.program)) -> Prelude.TimeUtils.at_half_hour_floor p.Libmythtvguide.startTime)
;;

let time_to_hour_and_minute_str (t: Core.Time.t) = 
    Core.Time.format t "%H:%M" ~zone:Core.Time.Zone.local

let channel_and_program_to_string ((c: Libmythtvguide.channel), (p: Libmythtvguide.program)) : string =
    Printf.sprintf "(%5s) %8s: %s (at %s)" 
        c.chanNum
        c.channelName 
        p.title 
        (time_to_hour_and_minute_str p.startTime)

let print_hour_lineup (hour: Core.Time.t) (lineup: (Libmythtvguide.channel * Libmythtvguide.program) list) =
    let lineup_lines = List.map channel_and_program_to_string lineup in
    let lines_to_print = List.append [
        (time_to_hour_and_minute_str hour) ;
        "--------------------------------------------" ; 
    ] lineup_lines 
    in
    List.iter print_endline lines_to_print ;
    print_endline ""

let main (start_time: Core.Time.t) (end_time: Core.Time.t)  =
    let maybe_guide = Lwt_main.run (Libmythtvguide.get_guide start_time end_time) in
    match maybe_guide with
    | `Ok guide     -> 
        group_programs_by_time guide 
        |> Prelude.TimeUtils.TimeMap.iter print_hour_lineup
    | `Error errmsg -> print_endline ("Error: " ^ errmsg)

(* CLI stuff *)
module CLI = struct 
    let start_time = ref (Core.Time.now())
    let end_time = ref (Core.Time.add (!start_time) (Core.Time.Span.of_day 1.0))

    let set_end_time (s: string)   = end_time := (Core.Time.of_string s)
    let set_start_time (s: string) = 
        start_time := (Core.Time.of_string s) ;
        end_time := (Core.Time.add (!start_time) (Core.Time.Span.of_day 1.0))

    let cli_opts = [
        ("-s", (Arg.String set_start_time), "Start time in 'YYYY-MM-DD HH:MM:SS' format");
        ("-e", (Arg.String set_end_time), "End time in 'YYYY-MM-DD HH:MM:SS' format");
    ]
end

let () =
    Arg.parse 
        CLI.cli_opts 
        (fun x -> 
            print_endline ("Unknown argument '" ^ x ^ "'");
            exit 1
        )
        "usage: mythtvguide [-s start_time] [-e end_time]" ;
    main (!CLI.start_time) (!CLI.end_time)
