let numeric_string_compare (a: string) (b: string) : int =
    Core.Float.compare (Core.Float.of_string a) (Core.Float.of_string b)

module TimeUtils = struct 
    module TimeMap = Map.Make (Core.Time)
    let local_tz = Core.Lazy.force Core.Time.Zone.local

    let rec generate_time_range (start_time: Core.Time.t) (end_time: Core.Time.t) (step: Core.Time.Span.t) =
        if start_time >= end_time then
            [end_time]
        else 
            start_time :: (generate_time_range (Core.Time.add start_time step) end_time step)

    let group_into_timemap (f: 'a -> Core.Time.t) (l : 'a list) =
        List.fold_left (fun map v ->
            let key = f v in
            let before =
                match TimeMap.find_opt key map with
                | None -> []
                | Some a -> a
            in TimeMap.add key (v :: before) map
        ) TimeMap.empty l

    let at_midnight ?zone:(z=local_tz) (time: Core.Time.t) : Core.Time.t =
        let date = Core.Time.to_date time ~zone:z in
        Core.Time.of_date_ofday date (Core.Time.Ofday.start_of_day) ~zone:local_tz

    let at_start_of_hour ?zone:(z=local_tz) (datetime: Core.Time.t) : Core.Time.t =
        let (date, time) = Core.Time.to_date_ofday datetime ~zone:z in
        let hour = 
            (Core.Time.Ofday.to_parts time)
            |> (fun parts -> parts.hr)
        in
        let start_of_hour = Core.Time.Ofday.create ~hr:hour () in
        Core.Time.of_date_ofday ~zone:z date start_of_hour

    let at_half_hour_floor ?zone:(z=local_tz) (datetime: Core.Time.t) : Core.Time.t =
        let (date, time) = Core.Time.to_date_ofday datetime ~zone:z in
        let (hour, minute) = 
            (Core.Time.Ofday.to_parts time)
            |> (fun parts -> (parts.hr, parts.min))
        in
        let new_min = if (minute < 30) then 0 else 30 in
        let half_hour_floor = Core.Time.Ofday.create ~hr:hour ~min:new_min () in
        Core.Time.of_date_ofday ~zone:z date half_hour_floor
end

(* Wrapper around Core.Time.t that allows de/serialization with ppx_deriving_yojson *)
module Time_Yojson_adapter = struct
    type t = Core.Time.t
    let of_yojson (json: Yojson.Safe.json) = 
        try 
            json 
            |> Yojson.Safe.to_string 
            |> (fun s -> Core.String.lstrip ~drop:(function | '\\' -> true | '"' -> true | _ -> false) s)
            |> (fun s -> Core.String.rstrip ~drop:(function | '\\' -> true | '"' -> true | _ -> false) s)
            |> Core.Time.of_string
            |> (fun t -> Ok t)
        with
            _ -> Error "Failed Parsing Date"

    let to_yojson (t: t) : Yojson.Safe.json = 
        t 
        |> (fun s -> Core.Time.format s "%Y-%m-%dT%H:%M:%SZ" ~zone:TimeUtils.local_tz)
        |> (fun s -> "\"" ^ s ^ "\"")
        |> Yojson.Safe.from_string
end
