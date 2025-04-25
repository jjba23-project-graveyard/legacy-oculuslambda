# oculuslambda - the eye into the system's functioning

# Copyright © "Josep Bigorra" known as "jjba23" <jjbigorra@gmail.com>

# oculuslambda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# oculuslambda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with oculuslambda.  If not, see <https://www.gnu.org/licenses/>.

# Code:

# Constants

OCULUSLAMBDA_LOCATION="/etc/oculuslambda"
OCULUSLAMBDA_DB="oculuslambda.db"
COPYRIGHT_HOLDERS="Josep Bigorra"
I18N_LOCATION="sys/i18n/locale"

# System details
GUIX_VERSION := $(shell guix --version)

.PHONY: dir-install dir-uninstall dev server production-server fmt init-db compile-i18n new-i18n join-i18n init-i18n-nl init-i18n-en merge-i18n-nl merge-i18n-en

# Logging helpers

define oculuslambda-log-info
	@printf "\n\033[1m[info] $(shell date +%s) - %s\033[0m\n" $(1)
endef

define oculuslambda-notify
	@-notify-send $(1)
endef

# i18n helpers

# Define a function for compiling the translation file (.po) into a machine-readable (.mo) format
# Arguments: $(1) represents the language code (e.g., "en_US", "nl_NL", etc.)
# Use msgfmt to compile the .po file into a .mo file for the specified language
# The output .mo file will be placed in the LC_MESSAGES directory under the language's folder
define oculuslambda-msgfmt
	msgfmt -v -o $(I18N_LOCATION)/$(1)/LC_MESSAGES/translate.mo \
		$(I18N_LOCATION)/$(1)/LC_MESSAGES/translate.po
endef

# Define a function to initialize a new translation file from a template (.pot) for a specific language
# Arguments: $(1) represents the language code (e.g., "en_US", "nl_NL", etc.)
# Use msginit to generate a .po file from the .pot template for the specified language
# The -l option sets the language, and --no-translator means no translator is pre-filled in the .po file
# The generated .po file is placed in the LC_MESSAGES directory for the given language
define oculuslambda-msginit
	mkdir -p $(I18N_LOCATION)/$(1)/LC_MESSAGES
	msginit -l $(1).UTF8 -o $(I18N_LOCATION)/$(1)/LC_MESSAGES/translate.po \
		-i $(I18N_LOCATION)/translate.pot --no-translator
endef

# Define a function to merge translation updates from the template (.pot) into an existing .po file
# Arguments: $(1) represents the language code (e.g., "en_US", "nl_NL", etc.)
# Use msgmerge to update the specified language's .po file with new translations from the template (.pot)
# The -U flag updates the .po file in place
# This ensures the .po file stays up-to-date with the latest changes in the template
define oculuslambda-merge
	msgmerge -U $(I18N_LOCATION)/$(1)/LC_MESSAGES/translate.po \
		$(I18N_LOCATION)/translate.pot
endef

# Define a function to extract translatable strings from Scheme source files using xgettext
# Arguments: $(1) should be either "--join-existing" for updating template
#   or "" to start from scratch.
# Run xgettext to extract strings marked for translation from Scheme source files
define oculuslambda-xgettext
	xgettext --default-domain=translate \
		--output=$(I18N_LOCATION)/translate.pot \
		--language=Scheme \
		--keyword=G_ \
		--sort-by-file \
		$(1) \
		--copyright-holder=$(COPYRIGHT_HOLDERS) \
		--package-name="oculuslambda" \
		lib/oculuslambda/*.scm \
		app/controllers/*.scm \
		app/views/*.scm \
		ENTRY \
		--from-code UTF-8
endef


# Target to prepare directories for the oculuslambda project
# Create the necessary directory for job cloning, if it doesn't exist
# Change ownership of the oculuslambda location to the current user
dir-install:
	$(call oculuslambda-log-info,"preparing directories for oculuslambda")
	sudo mkdir -pv $(OCULUSLAMBDA_LOCATION)/job-clone || true
	sudo chown -R $(shell whoami) $(OCULUSLAMBDA_LOCATION)

# Target to clean up the oculuslambda installation (remove job files)
# Remove all files in the oculuslambda location, ignoring errors
dir-uninstall:
	$(call oculuslambda-log-info,"cleaning oculuslambda installation")
	rm -rfv $(OCULUSLAMBDA_LOCATION)/* || true

watchexec:
	watchexec -i "dist/**" -r -e scm,css,js -- "make server"

# Target to start a development server for oculuslambda
# Use watchexec to watch for file changes and restart the server on changes
dev:
	$(call oculuslambda-log-info,"starting development server for oculuslambda")
	make watchexec


# Target to start the oculuslambda server
# Start the server with the default configuration
server:
	$(call oculuslambda-log-info,"starting oculuslambda server")
	guix shell -m manifest.scm -- art work

# Target to start the oculuslambda server with production configuration
production-server:
	$(call oculuslambda-log-info,"starting production oculuslambda server")
	guix shell -m manifest.scm -- art work -c conf/production.conf

# Target to format source code files according to the style guide
# Find all .scm files and format them using 'guix style'
fmt:
	$(call oculuslambda-log-info,"formatting all Scheme files")
	find . -maxdepth 8 -name "*.scm" -type f -exec guix style -f {} \;


# Initialize a new database and enable WAL mode for higher concurrent writes to SQLite 3
init-db:
	$(call oculuslambda-log-info,"initializing a new database")
	-rm -v $(OCULUSLAMBDA_DB) $(OCULUSLAMBDA_DB)-shm $(OCULUSLAMBDA_DB)-wal
	touch oculuslambda.db
	guix shell -m manifest.scm -- sqlite3 oculuslambda.db 'PRAGMA journal_mode=WAL;'

# Compile translation files to .mo files
compile-i18n:
	$(call oculuslambda-log-info,"compiling translation files")
	$(call oculuslambda-msgfmt,"en_US")
	$(call oculuslambda-msgfmt,"nl_NL")
	$(call oculuslambda-msgfmt,"es_ES")

# Create new i18n template from source code
new-i18n:
	$(call oculuslambda-log-info,"creating new i18n template from source code")
	$(call oculuslambda-xgettext,"")

# Update i18n template from source code
join-i18n:
	$(call oculuslambda-log-info,"updating i18n template from source code")
	$(call oculuslambda-xgettext,"--join-existing")

# en_US - English language targets
init-i18n-en:
	$(call oculuslambda-msginit,"en_US")
merge-i18n-en:
	$(call oculuslambda-merge,"en_US")

# Development REPL
repl:
	guix shell -m manifest.scm -- guile --fresh-auto-compile -c '((@ (ares server) run-nrepl-server))'
