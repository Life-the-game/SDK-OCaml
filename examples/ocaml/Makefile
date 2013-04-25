## ########################################################################## ##
## Project: La Vie Est Un Jeu - Public API, example with OCaml                ##
## Description: Makefile compiling the OCaml example of the API               ##
## Author: Tuxkowo                                                            ##
## Modified by: db0 (db0company@gmail.com, http://db0.fr/)                    ##
## Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   ##
## ########################################################################## ##

NAME		=	api_example_ocaml
SRC		=	api.ml
SRCI		=	apiError.ml apiTypes.ml api.mli
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
			$(OCAMLFIND) $(COMPILER) -o $(NAME) -package $(PACKS) $(SRCI) $(SRC) $(FLAGS)

doc		:
			$(OCAMLFIND) $(DOCCOMPILER) -html -package $(PACKS) $(SRCDOC)

clean		:
			$(RM) $(CMI) $(CMO)

fclean		:	clean
			$(RM) $(NAME)

re		:	fclean all
