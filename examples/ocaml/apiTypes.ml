(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: API Special Types                                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
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

type id       = int
type login    = string
type password = string
type email    = string
type url      = string
type token    = string

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

type curlauth = (login * password)

type auth =
  | Curl        of curlauth
  | Token       of token
  | OAuthHTTP   of token  (* todo *)
  | OAuthToken  of token  (* todo *)
  | OAuthSecret of (login * token) (* todo *)

type requirements =
  | Auth of auth
  | Lang of Lang.t
  | NoneReq

(* ************************************************************************** *)
(* Date & Time                                                                *)
(* ************************************************************************** *)

(* Full time with date + hour                                                 *)
module type DATETIME =
sig
  type t = CalendarLib.Calendar.t
  val format : string

  val to_string : t -> string
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
  let format = Date.format ^ " %H:%M:%S"

  let to_string date =
    CalendarLib.Printer.Calendar.sprint format date
  let of_string str_date =
    CalendarLib.Printer.Calendar.from_fstring format str_date

  let empty = CalendarLib.Calendar.make 0 0 0 0 0 0
  let now () = CalendarLib.Calendar.now ()
  let is_past date =
    CalendarLib.Calendar.compare (now ()) date >= 0
end

(* ************************************************************************** *)
(* Information Element                                                        *)
(* ************************************************************************** *)

(* Almost all method data contains these information                          *)
module type INFO =
sig
  type t =
      {
	id       : int;
	creation : DateTime.t;
      }
  val from_json : Yojson.Basic.json -> t
end
module Info : INFO =
struct
  type t =
      {
	id       : int;
	creation : DateTime.t;
      }
  let from_json c =
    let open Yojson.Basic.Util in
	{
	  id       = c |> member "id" |> to_int;
	  creation = DateTime.of_string
            (c |> member "creation" |> to_string);
	}
end

(* ************************************************************************** *)
(* List Pagination                                                            *)
(* ************************************************************************** *)

module type LIST =
sig
  type 'a t =
      {
        server_size : int;
        index       : int;
	limit       : int;
        items       : 'a list;
      }
  (** Generate a list from the JSON tree using a converter function *)
  val from_json :
    (Yojson.Basic.json -> 'a)
    -> Yojson.Basic.json
    -> 'a t
end
module List : LIST =
struct
  type 'a t =
      {
        server_size : int;
        index       : int;
	limit       : int;
        items       : 'a list;
      }
  let from_json f c =
    let open Yojson.Basic.Util in
	{
	  server_size = c |> member "server_size" |> to_int;
	  index       = c |> member "index"       |> to_int;
	  limit       = c |> member "limit"       |> to_int;
	  items       = convert_each f (c |> member "items");
	}
end

(* ************************************************************************** *)
(* Gender                                                                     *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t
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
  type t
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
