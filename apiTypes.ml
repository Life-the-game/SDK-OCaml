(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let convert_each_ (c : Yojson.Basic.json) (f : Yojson.Basic.json -> 'a) : 'a list =
  let open Yojson.Basic.Util in
  match c |> to_option (convert_each f) with
    | Some l -> l
    | None -> []

let convert_each = convert_each_

(* ************************************************************************** *)
(* Explicit types for parameters                                              *)
(* ************************************************************************** *)

type id       = string
type login    = string
type password = string
type email    = string
type url      = string
type token    = string
type color    = string
type mimetype = string
(* PRIVATE *)
type ip       = string
(* /PRIVATE *)

type parameters = (string (* key *) * string (* value *)) list

(* ************************************************************************** *)
(* Files                                                                      *)
(* ************************************************************************** *)

type filename = string
type contenttype = string
type path = string list
type file = (path * contenttype)
type either_file =
  | FileUrl of url
  | File of file
  | NoFile
type file_parameter = (filename * file)

let path_to_string = String.concat "/" (* todo dirsep unix *)

(* ************************************************************************** *)
(* Network stuff (GET POST ...)                                               *)
(* ************************************************************************** *)

module type NETWORK =
sig
  type t =
    | GET
    | POST
    | PUT
    | DELETE
  type post =
    | PostText of string
    | PostList of parameters
    | PostMultiPart of parameters * file_parameter list * (contenttype -> bool)
    | PostEmpty
  type code = int
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
  val option_filter  : (string * string option) list -> parameters
  val empty_filter   :  parameters -> parameters
  val files_filter   : (filename * either_file) list -> file_parameter list
  val list_parameter : string list -> string
  val multiple_files : string -> file list -> file_parameter list
end
module Network : NETWORK =
struct
  type t =
    | GET
    | POST
    | PUT
    | DELETE
  type parameters = (string (* key *) * string (* value *)) list
  type post =
    | PostText of string
    | PostList of parameters
    | PostMultiPart of parameters * file_parameter list * (contenttype -> bool)
    | PostEmpty
  type code = int
  let default = GET
  let to_string = function
    | GET    -> "GET"
    | POST   -> "POST"
    | PUT    -> "PUT"
    | DELETE -> "DELETE"
  let of_string = function
    | "GET"    -> GET
    | "POST"   -> POST
    | "PUT"    -> PUT
    | "DELETE" -> DELETE
    | _        -> default
  let option_filter l =
    let rec aux acc = function
      | []   -> acc
      | (k, v)::t ->
        (match v with
          | Some "" -> aux acc t
          | Some v -> aux ((k, v)::acc) t
          | None   -> aux acc t) in
    aux [] l
  let empty_filter l =
    let rec aux acc = function
      | []   -> acc
      | (k, v)::t ->
        if v = ""
        then aux acc t
        else aux ((k, v)::acc) t in
    aux [] l
  let files_filter l =
    let rec aux acc = function
      | []   -> acc
      | (name, File f)::t -> aux ((name, f)::acc) t
      | _::t -> aux acc t
    in
    aux [] l
  let list_parameter = String.concat ","
  let multiple_files name =
    List.fold_left (fun l ((path, _) as file) ->
      match path with [] -> l | path -> (name, file)::l) []
end

(* ************************************************************************** *)
(* Languages                                                                  *)
(* ************************************************************************** *)

module type LANG =
sig
  type t
  val list        : string list
  val default     : t
  val is_valid    : string -> bool
  val of_string : string -> t
  val to_string   : t      -> string
end
module Lang : LANG =
struct
  type t = string
  let list = ["en"; "fr"]
  let default = List.hd list
  let is_valid l = List.exists ((=) l) list
  let of_string s =
    match is_valid s with
      | true  -> s
      | false -> default
  let to_string l = l
end

(* ************************************************************************** *)
(* Requirements (Auth, Lang, ...)                                             *)
(* ************************************************************************** *)

type auth =
  | Token       of token
  | OAuthHTTP   of token  (* todo *)
  | OAuthToken  of token  (* todo *)
  | OAuthSecret of (login * token) (* todo *)

type requirements =
  | Auth of auth
  | Lang of Lang.t
  | Auto of (auth option * Lang.t)
  | Both of (auth * Lang.t)

let opt_auth = function
  | Some auth -> Some (Auth auth)
  | None      -> None

(* ************************************************************************** *)
(* Date & Time                                                                *)
(* ************************************************************************** *)

(* Full time with date + hour                                                 *)
module type DATETIME =
sig
  type t = CalendarLib.Calendar.t
  val format : string

  val to_string : t -> string
  val to_simple_string : t -> string
  val of_string : string -> t

  val empty : t
  val now : unit -> t
  val is_past : t -> bool
end

(* Only date                                                                  *)
module type DATE =
sig
  type t = CalendarLib.Date.t
  val format : string

  val to_string : t -> string
  val of_string : string -> t

  val empty : t
  val today : unit -> t
end

(* Only date                                                                  *)
module Date : DATE =
struct
  type t =  CalendarLib.Date.t
  let format = "%Y-%m-%d"

  let to_string date =
    CalendarLib.Printer.Date.sprint format date
  let of_string str_date =
    CalendarLib.Printer.Date.from_fstring format str_date

  let empty = CalendarLib.Date.make 0 0 0
  let today () = CalendarLib.Date.today ()
end
(* Full time with date + hour                                                 *)
module DateTime : DATETIME =
struct
  type t = CalendarLib.Calendar.t
  let format = Date.format ^ "T%H:%M:%SZ"
  let simple_format = Date.format ^ " %H:%M"

  let to_string date =
    CalendarLib.Printer.Calendar.sprint format date
  let to_simple_string date =
    CalendarLib.Printer.Calendar.sprint simple_format date
  let of_string str_date =
    CalendarLib.Printer.Calendar.from_fstring format str_date

  let empty = CalendarLib.Calendar.make 0 0 0 0 0 0
  let now () = CalendarLib.Calendar.now ()
  let is_past date =
    CalendarLib.Calendar.compare (now ()) date >= 0
end

(* ************************************************************************** *)
(* Information Element                                                        *)
(*   Almost all API object contain this object                                *)
(* ************************************************************************** *)

module type INFO =
sig
  type t =
      {
        id           : string;
        creation     : DateTime.t option;
        modification : DateTime.t option;
      }
  val from_json : Yojson.Basic.json -> t
end
module Info : INFO =
struct
  type t =
      {
        id           : string;
        creation     : DateTime.t option;
        modification : DateTime.t option;
      }
  let from_json c =
    let open Yojson.Basic.Util in
        {
          id           = c |> member "id" |> to_string;
          creation     = Option.map DateTime.of_string (c |> member "creation" |> to_string_option);
          modification = Option.map DateTime.of_string (c |> member "modification" |> to_string_option);
        }
end

(* ************************************************************************** *)
(* Approvable elements                                                        *)
(*   Approvable elements contain this object AND MUST contain Info as well    *)
(* ************************************************************************** *)

module type APPROVABLE =
sig
  type vote = Approved | Disapproved
  type t =
      {
        approvers_total    : int;
        disapprovers_total : int;
        approved           : bool option;
        disapproved        : bool option;
        (* score              : int; *)
	vote               : vote option;
      }
  val from_json : Yojson.Basic.json -> t
  val to_string : vote -> string
  val of_string : string -> vote
end
module Approvable : APPROVABLE =
struct
  type vote = Approved | Disapproved
  type t =
      {
        approvers_total    : int;
        disapprovers_total : int;
        approved           : bool option;
        disapproved        : bool option;
        (* score              : int; *)
	vote               : vote option;
      }
  let to_string = function
    | Approved     -> "approved"
    | Disapproved  -> "disapproved"
  let of_string = function
    | "approved"     -> Approved
    | "disapproved"  -> Disapproved
    | _              -> Approved
  let from_json c =
    let open Yojson.Basic.Util in
        {
          approvers_total    = c |> member "approvers_total" |> to_int;
          disapprovers_total = c |> member "disapprovers_total" |> to_int;
          approved           = c |> member "approved" |> to_bool_option;
          disapproved        = c |> member "disapproved" |> to_bool_option;
          (* score              = c |> member "score" |> to_int; *)
	  vote               = c |> member "vote" |> to_option
	      (fun vote -> of_string (vote |> to_string));
        }
end

(* ************************************************************************** *)
(* List Pagination                                                            *)
(* ************************************************************************** *)

module type PAGE =
sig
  type order =
    | Smart
    | Date_modified
    | Alphabetic
    | Score
    | Nb_comments
  type direction = Asc | Desc
  type index = int
  type limit = int
  type 'a t =
      {
        server_size : int;
        index       : int;
	count       : int;
        limit       : int;
        order       : order;
        direction   : direction;
        items       : 'a list;
      }
  type parameters = (index * limit * (order * direction) option)
  val default_parameters : parameters
  (** Take a page and return the arguments to get the next one,
      or None if there's no next page *)
  val next : 'a t -> parameters option
  val previous : 'a t -> parameters option
  (** Generate a page from the JSON tree using a converter function *)
  val from_json :
    (Yojson.Basic.json -> 'a)
    -> Yojson.Basic.json
    -> 'a t
  val just_limit : int -> parameters
  val default_order : order
  val order_to_string : order -> string
  val order_of_string : string -> order
  val default_direction : direction
  val direction_to_string : direction -> string
  val direction_of_string : string -> direction
  val get_total: 'a t -> int
end
module Page : PAGE =
struct
  type order =
    | Smart
    | Date_modified
    | Alphabetic
    | Score
    | Nb_comments
  type direction = Asc | Desc
  type index = int
  type limit = int
  type 'a t =
      {
        server_size : int;
        index       : int;
	count       : int;
        limit       : int;
        order       : order;
        direction   : direction;
        items       : 'a list;
      }
  type parameters = (index * limit * (order * direction) option)
  let just_limit n = (0, n, None)
  let default_parameters = (0, 10, None)
  let next page =
    let nextpage = page.index + page.limit in
    if nextpage < page.server_size
    then Some (nextpage, page.limit, None) (* todo order direction params *)
    else None
  let previous page =
    let previouspage = page.index + page.limit in
    if previouspage >= 0
    then Some (previouspage, page.limit, None) (* todo order direction params *)
    else None
  let default_order = Smart
  let order_to_string = function
    | Smart         -> "smart"
    | Date_modified -> "date_modified"
    | Alphabetic    -> "alphabetic"
    | Score         -> "score"
    | Nb_comments   -> "nb_comments"
  let order_of_string = function
    | "smart"         -> Smart
    | "date_modified" -> Date_modified
    | "alphabetic"    -> Alphabetic
    | "score"         -> Score
    | "Nb_comments"   -> Nb_comments
    | _               -> default_order
  let default_direction = Asc
  let direction_to_string = function
    | Asc  -> "asc"
    | Desc -> "desc"
  let direction_of_string = function
    | "asc"  -> Asc
    | "desc" -> Desc
    | _      -> default_direction
  let from_json f c =
    let open Yojson.Basic.Util in
	try {
          server_size = c |> member "server_size" |> to_int;
          index       = c |> member "index"       |> to_int;
          count       = c |> member "count"       |> to_int;
          limit       = c |> member "limit"       |> to_int;
          order       = order_of_string (c |> member "order" |> to_string);
          direction   = direction_of_string
            (c |> member "direction" |> to_string);
          items       = convert_each_ (c |> member "items") f;
        } with Yojson.Json_error "Blank input data" -> {
          server_size = 0; index = 0; count = 0; limit = 0;
	  order = default_order; direction = default_direction; items = [];
	}
  let get_total page = page.server_size
end

(* ************************************************************************** *)
(* Gender                                                                     *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t = Male | Female | Other | Undefined
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Gender : GENDER =
struct
  type t = Male | Female | Other | Undefined
  let default = Undefined
  let to_string = function
    | Male      -> "male"
    | Female    -> "female"
    | Other     -> "other"
    | Undefined -> "undefined"
  let of_string = function
    | "male"      -> Male
    | "female"    -> Female
    | "other"     -> Other
    | "undefined" -> Other
    | _           -> default
end

(* ************************************************************************** *)
(* Status                                                                     *)
(* ************************************************************************** *)

module type STATUS =
sig
  type t =
    | Objective
    | Achieved
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS =
struct
  type t =
    | Objective
    | Achieved
  let to_string = function
    | Objective -> "objective"
    | Achieved  -> "achieved"
  let of_string = function
    | "objective" -> Objective
    | "achieved"  -> Achieved
    | _           -> Objective
end

(* ************************************************************************** *)
(* Privacy                                                                    *)
(* ************************************************************************** *)

module type PRIVACY =
sig
  type t = Enemy | Pure | Hardcore | Discutable
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Privacy : PRIVACY =
struct
  type t = Enemy | Pure | Hardcore | Discutable
  let default = Discutable
  let to_string = function
    | Enemy      -> "enemy"
    | Pure       -> "pure"
    | Hardcore   -> "hardcore"
    | Discutable -> "discutable"
  let of_string = function
    | "enemy"      -> Enemy
    | "pure"       -> Pure
    | "hardcore"   -> Hardcore
    | "discutable" -> Hardcore
    | _            -> default
end

(* ************************************************************************** *)
(* Color                                                                      *)
(* ************************************************************************** *)

let colors =
  [
    ("lightlightgreen", "#8ee7bc");
    ("lightgreen", "#4eda97");
    ("green", "#26b671");
    ("darkgreen", "#14623d");
    ("darkdarkgreen", "#115334");
    ("lightlightblue", "#b6daf2");
    ("lightblue", "#75b9e7");
    ("blue", "#3498db");
    ("darkblue", "#196090");
    ("darkdarkblue", "#16527a");
    ("lightlightpurple", "#dbc3e5");
    ("lightpurple", "#bb8ecd");
    ("purple", "#9b59b6");
    ("darkpurple", "#623475");
    ("darkdarkpurple", "#542c64");
    ("lightlightnightblue", "#7795b4");
    ("lightnightblue", "#4f6f8f");
    ("nightblue", "#34495e");
    ("darknightblue", "#10161c");
    ("darkdarknightblue", "#0d1318");
    ("lightlightyellow", "#f9e8a0");
    ("lightyellow", "#f5d657");
    ("yellow", "#f1c40f");
    ("darkyellow", "#927608");
    ("darkdarkyellow", "#7c6407");
    ("lightlightorange", "#ffb686");
    ("lightorange", "#ff883a");
    ("orange", "#ec5e00");
    ("darkorange", "#863500");
    ("darkdarkorange", "#722d00");
    ("lightlightred", "#f5b4ae");
    ("lightred", "#ef8b80");
    ("red", "#e74c3c");
    ("darkred", "#a82315");
    ("darkdarkred", "#8f1d12");
    ("lightlightgrey", "#ffffff");
    ("lightgrey", "#e6e9ea");
    ("grey", "#bdc3c7");
    ("darkgrey", "#869198");
    ("darkdarkgrey", "#727b81");
    ("lightlightpink", "#fffdfd");
    ("lightpink", "#f8b8c3");
    ("pink", "#f17288");
    ("darkpink", "#e6173b");
    ("darkdarkpink", "#c41332");
    (* ("main", "#26b671"); *)
    (* ("lightmain", "#4eda97"); *)
    (* ("lightlightmain", "#8ee7bc"); *)
    (* ("darkmain", "#14623d"); *)
    (* ("darkdarkmain", "#115334"); *)
  ]

let name_to_color color = List.assoc color colors

let main_colors =
  let is_main (name, _) =
    try
      if (String.sub name 0 8) = "darkdark"
      then false
      else if (String.sub name 0 10) = "lightlight"
      then false
      else true
    with Invalid_argument _ -> true in
  List.filter is_main colors

let light_colors =
  let is_light (name, _) =
    try
      if (String.sub name 0 4) = "dark"
      then false
      else if (String.sub name 0 8) = "darkdark"
      then false
      else true
    with Invalid_argument _ -> true in
  List.filter is_light colors

(* ************************************************************************** *)
(* Location                                                                   *)
(* ************************************************************************** *)

module type LOCATION =
sig
  type t = {
    latitude: float;
    longitude: float;
    radius: int;
  }
  type parameters = (float * float)
  val to_string : parameters -> string
  val of_string : ?radius : int -> string -> t
  val from_json : Yojson.Basic.json -> t
end
module Location : LOCATION =
struct
  type t = {
    latitude: float;
    longitude: float;
    radius: int;
  }
  type parameters = (float * float)
  let of_string ?(radius = 0) s = {
    latitude = 0.; (* todo *)
    longitude = 0.; (* todo *)
    radius = radius;
  }
  let to_string (latitude, longitude) =
    "lat" ^ (string_of_float latitude) ^ "long" ^ (string_of_float longitude)
  let from_json c =
    let open Yojson.Basic.Util in
    of_string ~radius:(c |> member "radius" |> to_int)
      (c |> member "location" |> to_string)
end

(* ************************************************************************** *)
(* Visibility                                                                 *)
(* ************************************************************************** *)

module type VISIBILITY =
sig
  type t =
    | Official
    | Community
    | Sponsored
    | Unknown
  val default : t
  val to_string : t -> string
  val of_string : string -> t
end
module Visibility : VISIBILITY =
struct
  type t =
    | Official
    | Community
    | Sponsored
    | Unknown
  let default = Unknown
  let of_string = function
    | "official" -> Official
    | "community" -> Community
    | "sponsored" -> Sponsored
    | _ -> default
  let to_string = function
    | Official -> "official"
    | Community -> "community"
    | Sponsored -> "sponsored"
    | Unknown -> "unknown"
end

(* ************************************************************************** *)
(* Error                                                                      *)
(* ************************************************************************** *)

type bad_request =
  | Invalid of string * string list
  | Requested of string * string list

type not_acceptable = mimetype list * Lang.t list

type error =
  | BadRequest of bad_request list
  | NotFound
  | NotAllowed
  | NotAcceptable of not_acceptable
  | NotImplemented
  | Client of string
  | Unknown of Network.code

let error_from_json code c =
  let open Yojson.Basic.Util in

  let bad_request_from_json () =
    let f ca =
      let message = ca |> member "mesage" |> to_string in
      try Invalid (message, convert_each_ (ca |> member "invalid") to_string)
      with _ -> Requested (message, convert_each_ (ca |> member "requested") to_string) in
    convert_each_ c f in

  let not_acceptable_from_json () =
    (convert_each_ (c |> member "accept-media") to_string,
     convert_each_ (c |> member "accept-language")
       (fun s -> Lang.of_string (to_string s))) in

  match code with
    | 400 -> BadRequest (bad_request_from_json ())
    | 404 -> NotFound
    | 405 -> NotAllowed
    | 406 -> NotAcceptable (not_acceptable_from_json ())
    | 501 -> NotImplemented
    | code -> Unknown code

(* ************************************************************************** *)
(* Client-side errors                                                         *)
(* ************************************************************************** *)

let generic = Client "Something went wrong"
let network msg = Client ("Network error: " ^ msg)
let invalid_json msg = Client ("The JSON tree response is not formatted as expected: " ^ msg)
let requirement_missing = Client "One requirement is missing"
let invalid_format = Client "Invalid file format"
let invalid_argument msg = Client ("Invalid Argument: " ^ msg)
let auth_required = Client "Authentication required"
let file_not_found = Client "File not found"
let notfound = Client "Not found"

(* ************************************************************************** *)
(* API Response                                                               *)
(* ************************************************************************** *)

type 'a t =
  | Result of 'a
  | Error of error
