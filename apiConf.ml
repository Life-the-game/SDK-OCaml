(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Configuration of the library                                              *)

(** The URL of the API Web service                                            *)
let base_url = ref "http://api.glife.fr"

(** Print log messages or not?                                                *)
let verbose = ref false

(** User-Agent used in the HTTP requests headers                              *)
(** Note: it's only changeable BEFORE the first call to an API method         *)
let user_agent = ref "OCaml-library-v2"

(** Where do I print the log messages?                                        *)
let verbose_output = ref stdout
let set_verbose_file str =
  verbose_output := open_out str

(** Where do I print the info dumped by the ApiDump module?                   *)
let dump_output = ref stdout
let set_dump_file str =
  dump_output := open_out str

let set_all_output str =
  let o = open_out str in
  verbose_output := o;
  dump_output := o
