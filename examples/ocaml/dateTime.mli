(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Usage of the Calendar lib as part of the API                  *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* Full time with date + hour                                                 *)

type t = CalendarLib.Calendar.t

val to_string : t -> string
val of_string : string -> t

val now : unit -> t

(* Only date                                                                  *)

type date = CalendarLib.Date.t

val date_to_string : date -> string
val date_of_string : string -> date

val today : unit -> date
