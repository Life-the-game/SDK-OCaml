(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(* Type                                                                       *)
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
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in
      {
        info     = Info.from_json c;
        author   = ApiUser.from_json (c |> member "author");
        content  = c |> member "content" |> to_string;
        lang     = Lang.from_string (c |> member "lang" |> to_string);
        keywords = convert_each to_string (c |> member "keywords");
        medias   = convert_each ApiMedia.from_json (c |> member "medias");
      }
