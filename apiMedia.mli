(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** Medias (pictures, sounds, videos) API methods                             *)

(* ************************************************************************** *)
(** {3 Media}                                                                 *)
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
module Media : MEDIA

(* ************************************************************************** *)
(** {3 Picture}                                                               *)
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
module Picture : PICTURE

(* ************************************************************************** *)
(** {3 Video}                                                                 *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      provider : ApiTypes.url;
    }
  val from_json : Yojson.Basic.json -> t
end
module Video : VIDEO
