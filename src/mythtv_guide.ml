open Prelude
open Core

let group_programs_by_time (g: Libmythtvguide.program_guide) : (Libmythtvguide.channel * Libmythtvguide.program) list Prelude.TimeUtils.TimeMap.t  =
    g.channels
    |> List.map (fun chan -> List.map (fun prog -> (chan, prog)) chan.Libmythtvguide.programs)
    |> List.flatten
    |> Prelude.TimeUtils.group_into_timemap (fun ((c: Libmythtvguide.channel), (p: Libmythtvguide.program)) -> Prelude.TimeUtils.at_start_of_hour p.Libmythtvguide.startTime)
;;

let time_to_hour_and_minute_str (t: Core.Time.t) = 
    Core.Time.format t "%H:%M" ~zone:Core.Time.Zone.local

let print_hour_lineup (hour: Core.Time.t) (lineup: (Libmythtvguide.channel * Libmythtvguide.program) list) =
    let channel_and_program_to_string ((c: Libmythtvguide.channel), (p: Libmythtvguide.program)) =
        Printf.sprintf "%s: %s %s" c.channelName p.title (time_to_hour_and_minute_str p.startTime)
    in
    let lineup_lines = lineup |> List.map channel_and_program_to_string in
    print_endline (time_to_hour_and_minute_str hour) ;
    print_endline "----------------------------------" ; 
    List.iter print_endline lineup_lines


let () =
    let now = Core.Time.now() in
    let tomorrow = (Core.Time.add now (Core.Time.Span.of_day 1.0)) in
    let maybe_guide = Lwt_main.run (Libmythtvguide.get_guide now tomorrow) in
    match maybe_guide with
    | `Ok guide     -> 
        group_programs_by_time guide 
        |> Prelude.TimeUtils.TimeMap.iter print_hour_lineup
    | `Error errmsg -> print_endline ("Error: " ^ errmsg)

