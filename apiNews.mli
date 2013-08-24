(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** News API methods                                                          *)

open ApiTypes

(* ************************************************************************** *)
(* {3 Type}                                                                   *)
(* ************************************************************************** *)

type t =
    {
      info     : Info.t;
      author   : ApiUser.t;
      content  : string;
      lang     : Lang.t;
      keywords : string list;
      medias   : ApiMedia.t list;
    }

(* ************************************************************************** *)
(* {3 Tools}                                                                  *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t

