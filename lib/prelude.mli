val numeric_string_compare : string -> string -> int

module TimeUtils : sig 
    module TimeMap : sig
        include module type of Map.Make(Core.Time)
    end

    val local_tz : Core.Time.Zone.t 

    val generate_time_range : Core.Time.t -> Core.Time.t -> Core.Time.Span.t -> Core.Time.t list 

    val group_into_timemap : ('a -> Core.Time.t) -> 'a list -> 'a list TimeMap.t 

    val at_midnight : ?zone:Core.Time.Zone.t -> Core.Time.t -> Core.Time.t

    val at_start_of_hour : ?zone:Core.Time.Zone.t -> Core.Time.t -> Core.Time.t 

    val at_half_hour_floor : ?zone:Core.Time.Zone.t -> Core.Time.t -> Core.Time.t 
end

(* Wrapper around Core.Time.t that allows de/serialization with ppx_deriving_yojson *)
module Time_Yojson_adapter : sig 
    type t = Core.Time.t
    val of_yojson : Yojson.Safe.json -> (t, string) result
    val to_yojson : t -> Yojson.Safe.json
end
