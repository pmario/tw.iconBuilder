# Start at a Makefile or managing build activities.
# Expects a 'cook' script somewhere on the $PATH.
# See 'cook' in this directory for a sample you can use.
#
# For now uses the OSX specific "open" to run a test file. 
# Ubuntu users can use "gnome-open"
# 
# for other distros there may be similar options
#
# create a symlink to your "gnome-open" eg: ~/bin/open
# or change the OPEN parameter below
# $ which gnome-open will find the path
 
OPEN= open
PLUGINS_LIST= `cat plugins.list`
GIT_LIST= `cat git.list`

clean: clean-list
	rm *.html || true
	rm *.jar || true
	rm *.js || true

clean-list:
	rm *.list || true

upstream: upstream-html
	$(OPEN) upstream.html

test: tests-html
	$(OPEN) tests.html

tests-html:
	cook $(PWD)/tests.html.recipe tests.html

upstream-html: 
	cook $(PWD)/upstream.html.recipe upstream.html


# NOTE: the following section is quite hacky. 
# There are more files involved, than should be, for debugging reasons.
# It needs to be used in "production" for a while, to see if it works. :) 

# this are the "primary" dist commands.
plug:
	cat plugins/split.recipe | awk '{print "plugins/"$$2}' > plugins.list
	./upload.sh iconbuilder $(PLUGINS_LIST)

gitall: git-list
	./upload.sh iconbuilder $(GIT_LIST)

gitplugins: plugins-list
	./upload.sh iconbuilder $(PLUGINS_LIST)


# below are the tools

names.list: clean-list status-list
	@echo ""
	@echo "# names.list: IMPORTANT - Filenames with spaces can't be handled!"

	git add . 
	git diff-index --name-only HEAD > names.list	
	
status: status-list
	cat status.list

status-list:
	git status > status.list

plugins-list: names.list
	@echo ""
	@echo "# plugin-list: files used - dir plugins/ *.js, *.svg, *.tid, *.tiddler"

	egrep -o 'plugins/.*(\.js|\.svg|\.tid|\.tiddler)$$' names.list > plugins.list
	@echo ""
	cat plugins.list

git-list: names.list
	@echo ""
	@echo "# git-list: files used - <allSubdirs>/ *.js, *.svg, *.tid, *.tiddler"

	egrep -o '.*(\.js|\.svg|\.tid|\.tiddler)$$' names.list > git.list
	@echo ""
	cat git.list


# better listing
# git diff-index --name-status HEAD

# old
#	git status | egrep '(new file:|modified:) +plugins/.*(\.js|\.svg|\.tid|\.tiddler)$$' | awk -f awk.cmd > modified.list
	
# Compare filesystem against index or commit
# git diff --name-only --cached  --diff-filter=[A] HEAD | grep plugins

# or
# git diff --name-status --cached  --diff-filter=[A] HEAD

# modified-list
#	git status | egrep '(new file:|modified:) +plugins/.*(\.js|\.svg|\.tid|\.tiddler)$$' | egrep -o  '   .*$$' > modified.list

