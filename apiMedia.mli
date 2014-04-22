(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Medias (pictures, sounds, videos) API methods                             *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val extension : string -> string
val extension_of_path : path -> string
val checker : contenttype -> bool

val guess_contenttype : string -> contenttype
val guess_contenttype_from_extension : string -> contenttype
val guess_contenttype_from_path : path -> contenttype

(* ************************************************************************** *)
(** {3 Picture}                                                               *)
(* ************************************************************************** *)

module type PICTURE =
sig
  type t =
    {
      info      : Info.t;
      url_small : ApiTypes.url;
      url_big   : ApiTypes.url;
    }
  val from_json : Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
end
module Picture : PICTURE

(* ************************************************************************** *)
(** {3 Video}                                                                 *)
(* ************************************************************************** *)

module type VIDEO =
sig
  type t =
    {
      info      : Info.t;
      url       : url;
      thumbnail : Picture.t;
    }
  val from_json : Yojson.Basic.json -> t
  val contenttypes : contenttype list
  val checker : contenttype -> bool
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
      info      : Info.t;
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
  | Id      of string

val from_json : Yojson.Basic.json -> t
val thumbnail : t -> url
val url       : t -> url
val id        : t -> id
