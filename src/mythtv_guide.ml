open Core

let () =
    let now = Core.Time.now() in
    let tomorrow = (Core.Time.add now (Core.Time.Span.of_day 1.0)) in
    let maybe_guide = Lwt_main.run (Libmythtvguide.get_guide now tomorrow) in
    match maybe_guide with
    | `Ok guide     -> print_endline (guide |> Libmythtvguide.program_guide_to_yojson |> Yojson.Safe.pretty_to_string)
    | `Error errmsg -> print_endline ("Error: " ^ errmsg)

