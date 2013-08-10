(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** API Special Types                                                         *)

(* ************************************************************************** *)
(* Summary:                                                                   *)
(* - API Response                                                             *)
(* - Network stuff (GET POST ...)                                             *)
(* - Explicit types for parameters                                            *)
(* - Languages                                                                *)
(* - Requirements (Auth, Lang, ...)                                           *)
(* - Date & Time                                                              *)
(* - Information Element                                                      *)
(* - List Pagination                                                          *)
(* - Gender                                                                   *)
(* - Privacy                                                                  *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** {3 API Response}                                                          *)
(* ************************************************************************** *)

type 'a response =
  | Result of 'a
  | Error of ApiError.t

(* ************************************************************************** *)
(** {3 Network stuff (GET POST ...)}                                          *)
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
    | PostList of (string * string) list
    | PostEmpty
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Network : NETWORK

(* ************************************************************************** *)
(** {3 Explicit types for parameters}                                         *)
(* ************************************************************************** *)

type id       = string
type login    = string
type password = string
type email    = string
type url      = string
type token    = string

(* ************************************************************************** *)
(** {3 Languages}                                                             *)
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
module Lang : LANG

(* ************************************************************************** *)
(** {3 Requirements (Auth, Lang, ...)}                                        *)
(* ************************************************************************** *)

type curlauth = (login * password)

type auth =
  | Curl        of curlauth
  | Token       of token (* todo: should be ApiAuth.t *)
  | OAuthHTTP   of token  (* todo *)
  | OAuthToken  of token  (* todo *)
  | OAuthSecret of (login * token) (* todo *)

type requirements =
  | Auth of auth
  | Lang of Lang.t
  | NoneReq

(* ************************************************************************** *)
(** {3 Date & Time}                                                           *)
(* ************************************************************************** *)

(** Full time with date + hour                                                *)
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
module DateTime : DATETIME

(** Only date                                                                 *)
module type DATE =
sig
  type t = CalendarLib.Date.t
  val format : string

  val to_string : t -> string
  val of_string : string -> t

  val empty : t
  val today : unit -> t
end
module Date : DATE


(* ************************************************************************** *)
(** {3 Information Element}                                                   *)
(* ************************************************************************** *)

(* Almost all method data contains these information                          *)
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
module Info : INFO

(* ************************************************************************** *)
(** {3 List Pagination}                                                       *)
(* ************************************************************************** *)

module type LIST =
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
  (** Generate a list from the JSON tree using a converter function *)
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
module List : LIST

(* ************************************************************************** *)
(** {3 Gender}                                                                *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t = Male | Female | Other | Undefined
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Gender : GENDER

(* ************************************************************************** *)
(** {3 Privacy}                                                               *)
(* ************************************************************************** *)

module type PRIVACY =
sig
  type t = Enemy | Pure | Hardcore | Discutable
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Privacy : PRIVACY
