(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Configuration of the library                                              *)

(** The URL of the API Web service                                            *)
let base_url = ref "http://apipy.life.tl/"

(** Print log messages or not?                                                *)
let verbose = ref false

(** Set the authentication token
    Note: It's automatically set on call to the ApiAuth.login function        *)
let _auth_token = ref ""
let auth_token = ref (fun () -> !_auth_token)
let remove_oauth_token = ref (fun () -> _auth_token := "")

(** Set the language in the header                                            *)
let lang = ref ApiTypes.Lang.default

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
