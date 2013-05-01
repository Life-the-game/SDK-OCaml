(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Medias (pictures, sounds, videos) stuff                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** Media                                                                     *)
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
(** Picture                                                                   *)
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
(** Video                                                                     *)
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
