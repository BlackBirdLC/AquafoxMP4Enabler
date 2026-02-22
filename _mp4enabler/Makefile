# Must run with gmake

# Commands
RM = /bin/rm
MV = /bin/mv
CSH = /bin/csh
SED = /usr/bin/sed
PERL = /usr/bin/perl
LIPO = /usr/bin/lipo
MKDIR = /bin/mkdir
STRIP = /usr/bin/strip
HDIUTIL = /usr/bin/hdiutil
PLATYPUS = /opt/local/bin/platypus

# Library Names
LIBAVCODEC = libavcodec.57.dylib
LIBAVFORMAT = libavformat.57.dylib
LIBAVUTIL = libavutil.55.dylib

# General Configuration
VERSION = 3.4.14
APPNAME = Aquafox\ MP4\ Enabler

# 7450 Configuration
OBJS_7450 = __7450libs/$(LIBAVCODEC) __7450libs/$(LIBAVFORMAT) __7450libs/$(LIBAVUTIL)
SCRIPT_7450 = installer_7450.pl
DIR_7450 = app_7450
APPNAME_7450 = AquafoxMP4Enabler-7450
APP_7450 = $(DIR_7450)/$(APPNAME)\ G4-7450.app
DMG_7450 = AquafoxMP4Enabler-G4-7450.dmg

# 970 Configuration
OBJS_970 = __970libs/$(LIBAVCODEC) __970libs/$(LIBAVFORMAT) __970libs/$(LIBAVUTIL)
SCRIPT_970 = installer_970.pl
DIR_970 = app_970
APPNAME_970 = AquafoxMP4Enabler-970
APP_970 = $(DIR_970)/$(APPNAME_970).app
DMG_970 = AquafoxMP4Enabler-G5.dmg

# Define common HDIUTIL options
HDIUTIL_OPTIONS = -sectors 30000 -fs HFS+ -fsargs "-c c=64,a=16,e=16" -volname "Aquafox MP4 Enabler" -format UDBZ

.PHONY: default clean

# Default target to build both 7450 and 970 applications
default: $(DMG_7450) $(DMG_970)

# Clean target to remove generated files
clean:
	@echo "Cleaning up generated files..."
	$(RM) -rf __7450libs __970libs \
		$(SCRIPT_7450) $(SCRIPT_970) \
		$(DIR_7450) $(DIR_970) \
		$(DMG_7450) $(DMG_970)

# Build application for a given architecture
define build_app
	@echo "Building application for $(2)..."
	( cd $(1) && $(PLATYPUS) -a $(APPNAME) \
		-I org.blackbirdlc.aquafox.mp4enabler \
		-i ../icon.icns \
		-c ../$(SCRIPT_$(2)) \
		-o "Progress Bar" \
		-p $(PERL) \
		-V $(VERSION) \
		-R \
		-l \
		-f $(LIBAVCODEC) \
		-f $(LIBAVFORMAT) \
		-f $(LIBAVUTIL) \
		-y ../$(APP_$(2)) )
	@echo "Lipoing for $(2)..."
	( $(LIPO) -thin ppc \
		$(APP_$(2))/Contents/MacOS/$(APPNAME) \
		-output /tmp/exec && \
		$(MV) /tmp/exec $(APP_$(2))/Contents/MacOS/$(APPNAME) ) \
		|| echo "Warning: Error during lipo for $(2)"
	@echo "Stripping $(APPNAME)..."
	$(STRIP) $(APP_$(2))/Contents/MacOS/$(APPNAME) \
	|| echo "Warning: Error stripping $(APPNAME)"
endef

# Build libraries for 7450 and 970 architectures
define build_libs
	@echo "Building libraries for $(1)..."
	$(RM) -rf __$(1)libs && cd .. && \
		$(MAKE) clean && \
		$(CSH) _mp4enabler/_$(1)-CONFIG.LINE && \
		$(MAKE) -j3 && \
		$(CSH) _mp4enabler/_CONVLIBS.csh && \
		$(MV) _mp4enabler/_libs _mp4enabler/__$(1)libs
endef

# Create DMGs for 7450 and 970 applications
$(DMG_7450): $(APP_7450)
	@echo "Creating DMG for 7450 application..."
	$(RM) -f $(DMG_7450)
	$(HDIUTIL) create $(HDIUTIL_OPTIONS) -srcfolder $(DIR_7450) $(DMG_7450)

$(DMG_970): $(APP_970)
	@echo "Creating DMG for 970 application..."
	$(RM) -f $(DMG_970)
	$(HDIUTIL) create $(HDIUTIL_OPTIONS) -srcfolder $(DIR_970) $(DMG_970)

# Create applications for 7450 and 970
$(APP_7450): $(DIR_7450) $(SCRIPT_7450) $(OBJS_7450)
	$(call build_app,__7450libs,7450)

$(APP_970): $(DIR_970) $(SCRIPT_970) $(OBJS_970)
	$(call build_app,__970libs,970)

# Create directories for 7450 and 970 applications
$(DIR_7450):
	@echo "Creating directory for 7450 application..."
	$(MKDIR) -p $(DIR_7450)

$(DIR_970):
	@echo "Creating directory for 970 application..."
	$(MKDIR) -p $(DIR_970)

# Generate installer scripts for 7450 and 970
$(SCRIPT_7450): installer.pl
	@echo "Generating installer script for 7450..."
	$(SED) "s/Terminal/$(APPNAME_7450)/" installer.pl > $(SCRIPT_7450)

$(SCRIPT_970): installer.pl
	@echo "Generating installer script for 970..."
	$(SED) "s/Terminal/$(APPNAME_970)/" installer.pl > $(SCRIPT_970)

# Build libraries for 7450 and 970 architectures
$(OBJS_7450):
	$(call build_libs,7450)

$(OBJS_970):
	$(call build_libs,970)

