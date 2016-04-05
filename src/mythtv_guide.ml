open Core

let () =
    let now = Core.Time.now() in
    let tomorrow = (Core.Time.add now (Core.Time.Span.of_day 1.0)) in
    let guide = Lwt_main.run (Libmythtvguide.get_guide now tomorrow) in
    printfn ""

