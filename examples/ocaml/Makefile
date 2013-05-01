## ########################################################################## ##
## Project: La Vie Est Un Jeu - Public API, example with OCaml                ##
## Description: Makefile compiling the OCaml example of the API               ##
## Author: Tuxkowo                                                            ##
## Modified by: db0 (db0company@gmail.com, http://db0.fr/)                    ##
## Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   ##
## ########################################################################## ##

NAME		=	api.cma

SRC		=	apiError.ml \
			apiTypes.ml \
			api.ml \
			apiAuth.ml \
			apiMedia.ml \
			apiAchievement.ml \
			apiUser.ml

SRCI		=	apiError.mli \
			apiTypes.mli \
			api.mli \
			apiAuth.mli \
			apiMedia.mli \
			apiAchievement.mli \
			apiUser.mli

SRCDOC		=	api.ml
PACKS		=	curl,yojson,calendar

VERSION		=	1.0.0

FLAGS		=	-linkpkg

CMO		=	$(SRC:.ml=.cmo)
CMI		=	$(SRC:.ml=.cmi)

COMPILER	=	ocamlc
DOCCOMPILER	=	ocamldoc
OCAMLFIND	=	ocamlfind
RM		=	rm -f

all		:	
			$(OCAMLFIND) $(COMPILER) -a -o $(NAME) -package $(PACKS) $(SRCI) $(SRC) $(FLAGS)

doc		:
			$(OCAMLFIND) $(DOCCOMPILER) -html -package $(PACKS) $(SRCDOC)

clean		:
			$(RM) $(CMI) $(CMO)

fclean		:	clean
			$(RM) $(NAME)

re		:	fclean all
