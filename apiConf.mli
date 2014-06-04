(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Configuration of the library                                              *)

(** The URL of the API Web service                                            *)
val base_url : string ref

(** Print log messages or not?                                                *)
val verbose : bool ref

(** User-Agent used in the HTTP requests headers                              *)
(** Note: it's only changeable BEFORE the first call to an API method         *)
val user_agent : string ref

(** Where do I print the log messages?                                        *)
val verbose_output : out_channel ref
val set_verbose_file : string -> unit

(** Where do I print the info dumped by the ApiDump module?                   *)
val dump_output : out_channel ref
val set_dump_file : string -> unit

val set_all_output : string -> unit
