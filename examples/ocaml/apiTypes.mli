(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: API Special Types                                             *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

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
(** Gender type                                                               *)
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
