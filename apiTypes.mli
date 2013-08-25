(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** API Special Types                                                         *)

(* ************************************************************************** *)
(** {3 Summary}                                                               *)
(** {ol
    {- API Response }
    {- Explicit types for parameters }
    {- Files }
    {- Network stuff (GET POST ...) }
    {- Languages }
    {- Requirements (Auth, Lang, ...) }
    {- Date & Time }
    {- Information Element }
    {- Approvable elements }
    {- List Pagination }
    {- Gender }
    {- Privacy }
    }                                                                         *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** {3 API Response}                                                          *)
(* ************************************************************************** *)

type 'a response =
  | Result of 'a
  | Error of ApiError.t

(* ************************************************************************** *)
(** {3 Explicit types for parameters}                                         *)
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
(** {3 Files}                                                                 *)
(* ************************************************************************** *)

type path = string list

val path_to_string : path -> string

type contenttype = string

type file = (string (* name *) * path)

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
    | PostList of parameters
    | PostMultiPart of parameters * file list * (path -> contenttype option)
    | PostEmpty
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
(** Clean an option list by removing all the "None" and empty elements.
    Note that the order of the list will be reversed. *)
  val option_filter  : (string * string option) list -> parameters
  val empty_filter   :  parameters -> parameters
  val files_filter   : file list -> file list
  val list_parameter : string list -> string
  val multiple_files : string -> path list -> file list
end
module Network : NETWORK

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

type auth =
  | Token       of token (* todo: should be ApiAuth.t *)
  | OAuthHTTP   of token  (* todo *)
  | OAuthToken  of token  (* todo *)
  | OAuthSecret of (login * token) (* todo *)

type requirements =
  | Auth of auth
  | Lang of Lang.t
  | Auto of (auth option * Lang.t)
  | Both of (auth * Lang.t)

(** Transform an optional auth into a requirement                             *)
val opt_auth : auth option -> requirements option

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
(**  Almost all API object contains this object                               *)
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
module Info : INFO

(* ************************************************************************** *)
(** {3 Approvable elements}                                                   *)
(**   Approvable elements contain this object AND MUST contain Info as well   *)
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
module Approvable : APPROVABLE

(* ************************************************************************** *)
(** {3 List Pagination}                                                       *)
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
module Page : PAGE

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
