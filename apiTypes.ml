(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: API Special Types                                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* API Response                                                               *)
(* ************************************************************************** *)

type 'a response =
  | Result of 'a
  | Error of ApiError.t

(* ************************************************************************** *)
(* Explicit types for parameters                                              *)
(* ************************************************************************** *)

type id       = string
type login    = string
type password = string
type email    = string
type url      = string
type token    = string
(* PRIVATE *)
type ip       = string
(* /PRIVATE *)

type parameters = (string (* key *) * string (* value *)) list

(* ************************************************************************** *)
(* Files                                                                      *)
(* ************************************************************************** *)

type path = string list

let path_to_string = String.concat "/" (* todo dirsep unix *)

type contenttype = string

type file = (string (* name *) * path)

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
    | PostMultiPart of parameters * file list * (path -> contenttype option)
    | PostEmpty
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
  val option_filter  : (string * string option) list -> parameters
  val empty_filter   :  parameters -> parameters
  val files_filter   : file list -> file list
  val list_parameter : string list -> string
  val multiple_files : string -> path list -> file list
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
    | PostMultiPart of parameters * file list * (path -> contenttype option)
    | PostEmpty
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
      | (_, [])::t -> aux acc t
      | v::t -> aux (v::acc) t in
    aux [] l
  let list_parameter = String.concat ","
  let multiple_files name =
    List.fold_left (fun l path ->
      match path with [] -> l | path -> (name, path)::l) []
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
  val from_string : string -> t
  val to_string   : t      -> string
end
module Lang : LANG =
struct
  type t = string
  let list = ["en"; "fr"]
  let default = List.hd list
  let is_valid l = List.exists ((=) l) list
  let from_string s =
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
  | Both of (auth * Lang.t)

(* Transform an optional auth into a requirement                              *)
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
        creation     : DateTime.t;
        modification : DateTime.t;
      }
  val from_json : Yojson.Basic.json -> t
end
module Info : INFO =
struct
  type t =
      {
        id           : string;
        creation     : DateTime.t;
        modification : DateTime.t;
      }
  let from_json c =
    let open Yojson.Basic.Util in
        {
          id           = c |> member "id" |> to_string;
          creation     = DateTime.of_string
            (c |> member "creation" |> to_string);
          modification = DateTime.of_string
            (c |> member "creation" |> to_string);
        }
end

(* ************************************************************************** *)
(* Approvable elements                                                        *)
(*   Approvable elements contain this object AND MUST contain Info as well    *)
(* ************************************************************************** *)

module type APPROVABLE =
sig
  type t =
      {
        approvers_total    : int;
        disapprovers_total : int;
        approved           : bool option;
        disapproved        : bool option;
        score              : int;
      }
  val from_json : Yojson.Basic.json -> t
end
module Approvable : APPROVABLE =
struct
  type t =
      {
        approvers_total    : int;
        disapprovers_total : int;
        approved           : bool option;
        disapproved        : bool option;
        score              : int;
      }
  let from_json c =
    let open Yojson.Basic.Util in
        {
          approvers_total    = c |> member "approvers_total" |> to_int;
          disapprovers_total = c |> member "disapprovers_total" |> to_int;
          approved           = c |> member "approved" |> to_bool_option;
          disapproved        = c |> member "disapproved" |> to_bool_option;
          score              = c |> member "score" |> to_int;
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
  type 'a t =
      {
        server_size : int;
        index       : int;
        limit       : int;
        order       : order;
        direction   : direction;
        items       : 'a list;
      }
  type parameters =
  (int option (* index*)
   * int option (* limit*)
   * order option
   * direction option)
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
  val default_order : order
  val order_to_string : order -> string
  val order_of_string : string -> order
  val default_direction : direction
  val direction_to_string : direction -> string
  val direction_of_string : string -> direction
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
  type 'a t =
      {
        server_size : int;
        index       : int;
        limit       : int;
        order       : order;
        direction   : direction;
        items       : 'a list;
      }
  type parameters =
  (int option (* index*)
   * int option (* limit*)
   * order option
   * direction option)
  let default_parameters = (None, None, None, None)
  let next page =
    let nextpage = page.index + page.limit in
    if nextpage < page.server_size
    then Some (Some nextpage, Some page.limit,
               Some page.order, Some page.direction)
    else None
  let previous page =
    let previouspage = page.index + page.limit in
    if previouspage >= 0
    then Some (Some previouspage, Some page.limit,
               Some page.order, Some page.direction)
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
        {
          server_size = c |> member "server_size" |> to_int;
          index       = c |> member "index"       |> to_int;
          limit       = c |> member "limit"       |> to_int;
          order       = order_of_string (c |> member "order" |> to_string);
          direction   = direction_of_string
            (c |> member "direction" |> to_string);
          items       = convert_each f (c |> member "items");
        }
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

