(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: API Special Types                                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Summary:                                                                   *)
(* - API Response                                                             *)
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
(** API Response                                                              *)
(* ************************************************************************** *)

type 'a response =
  | Result of 'a
  | Error of ApiError.t

(* ************************************************************************** *)
(** Explicit types for parameters                                             *)
(* ************************************************************************** *)

type login    = string
type password = string
type url      = string
type token    = string

(* ************************************************************************** *)
(** Languages                                                                 *)
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
(** Requirements (Auth, Lang, ...)                                            *)
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
(** Date & Time                                                               *)
(* ************************************************************************** *)

(** Full time with date + hour                                                *)
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
(** Information Element                                                       *)
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
module Info : INFO

(* ************************************************************************** *)
(** List Pagination                                                           *)
(* ************************************************************************** *)

module type LIST =
sig
  type 'a t =
      {
        server_size : int;
        index       : int;
        items       : 'a list;
      }
  (** Generate a list from the JSON tree using a converter function *)
  val from_json :
    (Yojson.Basic.json -> 'a)
    -> Yojson.Basic.json
    -> 'a t
end
module List : LIST

(* ************************************************************************** *)
(** Gender                                                                    *)
(* ************************************************************************** *)

module type GENDER =
sig
  type t
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Gender : GENDER

(* ************************************************************************** *)
(** Privacy                                                                   *)
(* ************************************************************************** *)

module type PRIVACY =
sig
  type t
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module Privacy : PRIVACY
