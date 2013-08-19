(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
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
  val path_to_contenttype : path -> contenttype option
end
module Picture : PICTURE

(* ************************************************************************** *)
(** {3 Video}                                                                 *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      url       : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val path_to_contenttype : path -> contenttype option
end
module Video : VIDEO

module type EXTERNALVIDEO =
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
module ExternalVideo : EXTERNALVIDEO

(* ************************************************************************** *)
(** {3 Media}                                                                 *)
(* ************************************************************************** *)

type t =
  | Picture of Picture.t
  | Video   of Video.t
  | ExternalVideo of ExternalVideo.t
  | Media   of (string * string)

val from_json : Yojson.Basic.json -> t

(** Will check for all the know medias formats *)
val path_to_contenttype : path -> contenttype option
