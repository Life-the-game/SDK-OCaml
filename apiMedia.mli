(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)
(** Medias (pictures, sounds, videos) API methods                             *)

open ApiTypes

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
  type provider =
    | Youtube
    | DailyMotion
    | Vimeo
    | Unknown
  type t =
    {
      provider  : provider;
      video_url : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val provider_to_string : provider -> string
  val provider_of_string : string -> provider
end
module Video : VIDEO

(* ************************************************************************** *)
(** {3 Media}                                                                 *)
(* ************************************************************************** *)

type media =
  | Picture of Picture.t
  | Video   of Video.t
