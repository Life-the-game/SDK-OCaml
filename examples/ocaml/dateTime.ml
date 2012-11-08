(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Usage of the Calendar lib as part of the API                  *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* Full time with date + hour                                                 *)
type t = CalendarLib.Calendar.t
(* Only date                                                                  *)
type date =  CalendarLib.Date.t

let dformat = "%Y-%m-%d"
let tformat = dformat ^ " %H:%M:%S"

let to_string date =
  CalendarLib.Printer.Calendar.sprint tformat date
let of_string str_date =
  CalendarLib.Printer.Calendar.from_fstring tformat str_date

let date_to_string date =
  CalendarLib.Printer.Date.sprint dformat date
let date_of_string str_date =
  CalendarLib.Printer.Date.from_fstring dformat str_date

let now () = CalendarLib.Calendar.now ()
let today () = CalendarLib.Date.today ()

