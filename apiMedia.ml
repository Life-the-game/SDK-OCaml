(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Medias (pictures, sounds, videos) stuff                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Yojson.Basic.Util

(* ************************************************************************** *)
(* Media                                                                      *)
(* ************************************************************************** *)

module type MEDIA =
sig
  type t =
      {
	title : string;
	url   : ApiTypes.url;
      }
  val from_json : Yojson.Basic.json -> t
end

module Media : MEDIA =
struct
  type t =
      {
	title : string;
	url   : ApiTypes.url;
      }
  let from_json c =
    {
      title = c |> member "title" |> to_string;
      url   = c |> member "url"   |> to_string;
    }
end

(* ************************************************************************** *)
(* Picture                                                                    *)
(* ************************************************************************** *)

module type PICTURE =
sig
  type t =
    {
      url_small : ApiTypes.url;
      url_big   : ApiTypes.url;
    }
  val from_json : Yojson.Basic.json -> t
end

module Picture : PICTURE =
struct
  type t =
    {
      url_small : ApiTypes.url;
      url_big   : ApiTypes.url;
    }
  let from_json c =
    {
      url_small = c |> member "url_small" |> to_string;
      url_big   = c |> member "url_big"   |> to_string;
    }
end

(* ************************************************************************** *)
(* Video                                                                      *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      provider : ApiTypes.url;
    }
  val from_json : Yojson.Basic.json -> t
end

module Video : VIDEO =
struct
  type t =
    {
      provider : ApiTypes.url;
    }
  let from_json c =
    {
      provider = c |> member "provider" |> to_string;
    }
end
