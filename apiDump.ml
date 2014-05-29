(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes

let _ = Printexc.record_backtrace true

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let lprint_string str = output_string !ApiConf.dump_output str
let lprint_endline str = lprint_string (str ^ "\n"); flush_all ()

let verbose str =
  if !ApiConf.verbose
  then output_string !ApiConf.verbose_output (str ^ "\n")

(* ************************************************************************** *)
(* Dump results in a human readable format                                    *)
(* ************************************************************************** *)

let available_languages () =
  lprint_string "  Available languages: ";
  lprint_endline (String.concat ", " Lang.list)

let error e =
  lprint_endline "[Error]";
  match e with
    | BadRequest r -> lprint_endline ("  BadRequest" ^ r)
    | NotFound s -> lprint_endline ("  Not found" ^ s)
    | NotAllowed s -> lprint_endline ("  NotAllowed" ^ s)
    | NotAcceptable s -> lprint_endline ("  NotAcceptable" ^ s)
    | InternalServerError s -> lprint_endline ("  InternalServerError" ^ s)
    | NotImplemented s -> lprint_endline ("  NotImplemented" ^ s)
    | Client s -> lprint_endline ("  Client-side: " ^ s)
    | Unknown (code, s) -> lprint_endline ("  Unknown Error " ^ (string_of_int code) ^ " " ^ s)

let page l f =
  lprint_endline "[Page]";
  lprint_endline ("  Total items in page: " ^
                    (string_of_int l.Page.total));
  lprint_endline ("  Page Size: " ^
                    (string_of_int l.Page.size));
  lprint_endline ("  Page number: " ^
                    (string_of_int l.Page.number));
  lprint_endline "  Items:";
  if List.length l.Page.items = 0
  then lprint_endline "    Empty page"
  else List.iter f l.Page.items

let print a =
  lprint_endline (ExtLib.dump a)

