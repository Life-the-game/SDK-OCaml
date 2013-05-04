(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      login              : login;
      firstname          : string;
      lastname           : string;
      avatar             : ApiMedia.Picture.t;
      gender             : Gender.t;
      birthday           : Date.t;
      is_friend          : bool option;
      profile_url        : url;
    }

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Create a user                                                             *)
val create :
  login:login
  -> email:email
  -> password:string
  -> lang:Lang.t
  -> ?firstname:string option
  -> ?lastname:string option
  -> ?gender:Gender.t option
  -> ?birthday:Date.t option
  -> unit -> t Api.t

