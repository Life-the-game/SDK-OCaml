(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Call the web-service to handle the API methods                            *)

open ApiTypes

type 'a t = 'a ApiTypes.t

(** When you're done using the library, it's nice to disconnect it            *)
val disconnect : unit -> unit

(** {e Everything below this line is for library's developers only.}          *)

(** Handle an API method completely. Take a function to transform the json.

    More detailed information about the parameters on
    {{: https://github.com/Life-the-game/SDK-OCaml #readme} the repository
    documentation} *)
val go :
  session:session
  -> ?httpauth:(login * password) option (** Will perform a Curl auth request *)
  -> ?auth_required:bool          (** Will check the presence of a token *)
  -> ?rtype:Network.t             (** GET, POST, ... *)
  -> ?path:string list            (** URL/path/ *)
  -> ?page:Page.parameters option (** index, limit, ... *)
  -> ?get:parameters              (** GET parameters (URL?a=b&c=d) *)
  -> ?post:Network.post           (** POST parameters *)
  -> (Yojson.Basic.json -> 'a)    (** Function to transform from JSON *)
  -> 'a t

(** Helper function to be used as the from_json parameter when methods does
    not return anything (unit)                                               *)
val noop : Yojson.Basic.json -> unit

(** For resources that can be voted                                          *)
val vote :
  session:session
  -> string -> (Yojson.Basic.json -> 'a) -> id -> Vote.vote -> unit t
val cancel_vote :
  session:session
  -> string -> (Yojson.Basic.json -> 'a) -> id -> unit t

